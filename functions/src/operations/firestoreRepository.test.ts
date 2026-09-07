import assert from "node:assert/strict";
import test from "node:test";
import {Firestore} from "firebase-admin/firestore";
import {OperationConflictError} from "./errors";
import {FirestoreOperationsRepository} from "./firestoreRepository";
import {operationCollections} from "./collections";
import {
  CommitWorkItemAction,
  operationActionId,
  operationContentHash,
} from "./durableActions";
import {operationResourceLeaseId} from "./firestoreLeaseRepository";
import {
  hashes, operationActionReceipt, operationRun, operationWorkItem,
} from "./testFixtures";

import {FakeFirestore} from "./testFirestore";

interface Harness {
  firestore: FakeFirestore;
  repository: FirestoreOperationsRepository;
  clock: {now: number};
}

function harness(): Harness {
  const firestore = new FakeFirestore();
  const clock = {now: Date.parse("2026-07-14T08:01:00.000Z")};
  return {
    firestore,
    clock,
    repository: new FirestoreOperationsRepository(
      firestore as unknown as Firestore, () => clock.now
    ),
  };
}

test("Firestore repository round-trips serializable run and work items",
  async () => {
    const {repository} = harness();
    await repository.createRun(operationRun());
    await repository.createWorkItem(operationWorkItem());
    assert.equal((await repository.getRun(
      "run:mumbai:2026-07-14"
    ))?.workflowId, "supply-intake");
    assert.equal((await repository.getWorkItem(
      "work:event:1"
    ))?.primaryStage, "incoming");
  });

function leaseRequest(
  clock: Harness["clock"], ownerId = "worker:1", idempotencyKey = "acquire:1"
) {
  return {
    leaseId: operationResourceLeaseId("work_item", "work:event:1"),
    resourceType: "work_item" as const,
    resourceId: "work:event:1",
    ownerId,
    idempotencyKey,
    acquiredAt: new Date(clock.now).toISOString(),
    expiresAt: new Date(clock.now + 60_000).toISOString(),
  };
}

async function actionHarness() {
  const result = harness();
  await result.repository.createRun(operationRun({
    status: "running", startedAt: "2026-07-14T08:00:00.000Z",
  }));
  await result.repository.createWorkItem(operationWorkItem());
  const lease = await result.repository.acquireLease(
    leaseRequest(result.clock));
  const workItem = operationWorkItem({
    revision: 1, primaryStage: "verify", lifecycleStatus: "in_progress",
    updatedAt: new Date(result.clock.now).toISOString(),
  });
  const receipt = operationActionReceipt({
    actionId: operationActionId(workItem.runId, workItem.workItemId, "step:1"),
    idempotencyKey: "step:1", outputHash: operationContentHash(workItem),
  });
  const action: CommitWorkItemAction = {workItem, receipt, lease};
  return {...result, action};
}

test("resource leases serialize workers and survive repository restart",
  async () => {
    const {firestore, repository, clock} = harness();
    const attempts = await Promise.allSettled([
      repository.acquireLease(leaseRequest(clock)),
      repository.acquireLease(leaseRequest(clock, "worker:2", "acquire:2")),
    ]);
    const winners = attempts.filter((result) => result.status === "fulfilled");
    assert.equal(winners.length, 1);
    const rejected = attempts.find((result) => result.status === "rejected");
    assert.equal(rejected?.reason.code, "lease_conflict");
    const restarted = new FirestoreOperationsRepository(
      firestore as unknown as Firestore, () => clock.now
    );
    const original = await repository.getLease(leaseRequest(clock).leaseId);
    assert.deepEqual(await restarted.acquireLease(leaseRequest(clock)),
      original);
    await assert.rejects(restarted.acquireLease({
      ...leaseRequest(clock), leaseId: "lease:alias",
    }), {code: "lease_resource_mismatch"});
    await assert.rejects(restarted.acquireLease({
      ...leaseRequest(clock), acquiredAt: new Date(clock.now + 1).toISOString(),
    }), {code: "invalid_lease_time"});
    await assert.rejects(restarted.acquireLease({
      ...leaseRequest(clock), expiresAt: new Date(clock.now + 121_000)
        .toISOString(),
    }), {code: "invalid_lease_duration"});
  });

test("expired lease replays cannot resurrect stale worker ownership",
  async () => {
    const {repository, clock, action} = await actionHarness();
    clock.now += 60_000;
    await assert.rejects(repository.acquireLease(leaseRequest(clock)),
      {code: "lease_expired"});
    await assert.rejects(repository.heartbeatLease({
      ...action.lease, heartbeatAt: new Date(clock.now).toISOString(),
      expiresAt: new Date(clock.now + 60_000).toISOString(),
    }), {code: "lease_expired"});
    const replacement = await repository.acquireLease(
      leaseRequest(clock, "worker:2", "acquire:2")
    );
    assert.equal(replacement.fencingToken, action.lease.fencingToken + 1);
    await assert.rejects(repository.commitWorkItemAction(action),
      {code: "lease_owner_mismatch"});
    await assert.rejects(repository.releaseLease({
      ...action.lease, releasedAt: new Date(clock.now).toISOString(),
    }), {code: "lease_owner_mismatch"});
    assert.equal((await repository.getWorkItem("work:event:1"))?.revision, 0);
  });

test("heartbeat is monotonic and released leases retain fencing history",
  async () => {
    const {repository, clock} = harness();
    const lease = await repository.acquireLease(leaseRequest(clock));
    clock.now += 10_000;
    const renewed = await repository.heartbeatLease({
      ...lease, heartbeatAt: new Date(clock.now).toISOString(),
      expiresAt: new Date(clock.now + 60_000).toISOString(),
    });
    assert.equal(renewed.fencingToken, lease.fencingToken);
    await assert.rejects(repository.heartbeatLease({
      ...lease, heartbeatAt: lease.acquiredAt, expiresAt: lease.expiresAt,
    }), {code: "lease_time_regression"});
    const release = {...renewed, releasedAt: new Date(clock.now).toISOString()};
    const released = await repository.releaseLease(release);
    assert.deepEqual(await repository.releaseLease(release), released);
    const replacement = await repository.acquireLease(
      leaseRequest(clock, "worker:2", "acquire:2")
    );
    assert.equal(replacement.fencingToken, 2);
  });

test("action checkpoint and receipt survive interruption and lost replies",
  async () => {
    const {repository, firestore, clock, action} = await actionHarness();
    firestore.failNextCommit = true;
    await assert.rejects(repository.commitWorkItemAction(action),
      /injected transaction interruption/);
    assert.equal((await repository.getWorkItem("work:event:1"))?.revision, 0);
    assert.equal(await repository.getActionReceipt(
      action.receipt.actionId), null);
    const committed = await repository.commitWorkItemAction(action);
    assert.equal(committed.replayed, false);
    // The first response was lost. A new process retries after lease expiry.
    clock.now += 60_000;
    const restarted = new FirestoreOperationsRepository(
      firestore as unknown as Firestore, () => clock.now
    );
    const replay = await restarted.commitWorkItemAction(action);
    assert.equal(replay.replayed, true);
    assert.deepEqual(replay.receipt, action.receipt);
    assert.equal((await restarted.findActionReceiptByIdempotencyKey(
      action.workItem.runId, action.workItem.workItemId, "step:1"
    ))?.actionId, action.receipt.actionId);
    const receipts = firestore.entries().filter(([path]) =>
      path.startsWith(operationCollections.actionReceipts + "/"));
    assert.equal(receipts.length, 1);
  });

test("competing actions for one revision cannot both commit", async () => {
  const {repository, action} = await actionHarness();
  const competing = structuredClone(action);
  competing.receipt.idempotencyKey = "competing:1";
  competing.receipt.actionId = operationActionId(action.workItem.runId,
    action.workItem.workItemId, "competing:1");
  const results = await Promise.allSettled([
    repository.commitWorkItemAction(action),
    repository.commitWorkItemAction(competing),
  ]);
  assert.equal(results.filter((result) => result.status === "fulfilled").length,
    1);
  const rejected = results.find((result) => result.status === "rejected");
  assert.equal(rejected?.reason.code, "revision_conflict");
});

test("committed keys reject changed input and checkpoint drift", async () => {
  const {repository, firestore, action} = await actionHarness();
  await repository.commitWorkItemAction(action);
  await assert.rejects(repository.commitWorkItemAction({
    ...action, receipt: {...action.receipt, inputHash: hashes.dataset},
  }), {code: "idempotency_conflict"});
  firestore.write(operationCollections.workItems + "/work:event:1", {
    ...action.workItem, normalizedPayload: {corrupted: true},
  });
  await assert.rejects(repository.commitWorkItemAction(action),
    {code: "action_checkpoint_drift"});
});

test("invalid run and item states cannot advance", async () => {
  for (const variant of ["paused", "deadline", "scope", "terminal"] as const) {
    const {repository, firestore, clock, action} = await actionHarness();
    if (variant === "paused" || variant === "deadline") {
      const run = await repository.getRun(action.workItem.runId);
      assert.ok(run);
      await repository.saveRun({...run, revision: 1,
        status: variant === "paused" ? "paused" : "running",
        budgets: {...run.budgets, deadlineAt: variant === "deadline" ?
          new Date(clock.now).toISOString() : run.budgets.deadlineAt},
      }, 0);
    } else {
      firestore.write(operationCollections.workItems + "/work:event:1", {
        ...operationWorkItem(),
        ...(variant === "scope" ? {workflowId: "another-workflow"} :
          {lifecycleStatus: "terminal", outcome: "cancelled"}),
      });
    }
    await assert.rejects(repository.commitWorkItemAction(action), {
      code: variant === "scope" ? "action_scope_mismatch" :
        variant === "terminal" ? "terminal_work_item" : "run_not_executable",
    });
    assert.equal(await repository.getActionReceipt(
      action.receipt.actionId), null);
  }
});

test("canonical evidence is stable and scoped ids do not alias", () => {
  assert.equal(operationContentHash({a: 1, b: [2, 3]}),
    operationContentHash({b: [2, 3], a: 1}));
  assert.notEqual(operationActionId("a:b", "c", "d"),
    operationActionId("a", "b:c", "d"));
  for (const invalid of [undefined, NaN, Infinity, {missing: undefined},
    new Date(), [undefined]]) {
    assert.throws(() => operationContentHash(invalid),
      {code: "invalid_json_value"});
  }
});

test("Firestore repository compares revisions in a transaction", async () => {
  const {repository} = harness();
  await repository.createWorkItem(operationWorkItem());
  await repository.saveWorkItem(operationWorkItem({
    revision: 1,
    primaryStage: "verify",
    lifecycleStatus: "in_progress",
  }), 0);
  await assert.rejects(repository.saveWorkItem(operationWorkItem({
    revision: 2,
    primaryStage: "resolve",
    lifecycleStatus: "waiting",
  }), 0), (error: unknown) => {
    assert.ok(error instanceof OperationConflictError);
    assert.equal(error.code, "revision_conflict");
    return true;
  });
});

test("Firestore repository filters before stable document-id pagination",
  async () => {
    const {repository} = harness();
    for (let index = 0; index < 3; index += 1) {
      await repository.createWorkItem(operationWorkItem({
        workItemId: `work:event:${index}`,
        entityKind: index === 2 ? "organizer" : "event",
      }));
    }
    const first = await repository.listWorkItems({
      workflowId: "supply-intake",
      primaryStage: "incoming",
      entityKind: "event",
      limit: 1,
    });
    assert.deepEqual(first.items.map((item) => item.workItemId), [
      "work:event:0",
    ]);
    assert.equal(first.nextCursor, "work:event:0");
    const second = await repository.listWorkItems({
      workflowId: "supply-intake",
      primaryStage: "incoming",
      entityKind: "event",
      limit: 1,
      cursor: first.nextCursor,
    });
    assert.deepEqual(second.items.map((item) => item.workItemId), [
      "work:event:1",
    ]);
  });

test("Firestore repository can page the canonical human-review queue",
  async () => {
    const {repository} = harness();
    await repository.createWorkItem(operationWorkItem({
      workItemId: "work:event:ordinary",
    }));
    await repository.createWorkItem(operationWorkItem({
      workItemId: "work:event:human",
      taskFlags: ["human_review_required"],
      normalizedPayload: {owner: "human"},
    }));
    const page = await repository.listWorkItems({
      workflowId: "supply-intake",
      runId: "run:mumbai:2026-07-14",
      humanReviewRequired: true,
      limit: 200,
    });
    assert.deepEqual(page.items.map((item) => item.workItemId), [
      "work:event:human",
    ]);
  });
