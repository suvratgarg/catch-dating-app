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

test("prepared checkpoint joins domain writes and rolls back as one commit",
  async () => {
    const {repository, firestore, action} = await actionHarness();
    const execute = () => firestore.runTransaction(async (tx) => {
      const prepared = await repository.prepareWorkItemAction(
        tx as unknown as import("firebase-admin/firestore").Transaction,
        action);
      tx.create(firestore.collection("domain").doc("effect"), {done: true});
      prepared.commit();
    });
    const before = firestore.entries();
    firestore.failNextCommit = true;
    await assert.rejects(execute(), /interruption/);
    assert.deepEqual(firestore.entries(), before);
    await execute();
    assert.equal(firestore.read("domain/effect")?.done, true);
    assert.equal((await repository.getWorkItem("work:event:1"))?.revision, 1);
    assert.ok(await repository.getActionReceipt(action.receipt.actionId));
  });

test("prepared checkpoint freezes caller input and rechecks the commit clock",
  async () => {
    for (const boundary of ["lease", "deadline", "input"] as const) {
      const {repository, firestore, clock, action} = await actionHarness();
      if (boundary === "deadline") {
        const run = (await repository.getRun(action.workItem.runId))!;
        firestore.write(operationCollections.runs + "/" + run.runId,
          {...run, budgets: {...run.budgets,
            deadlineAt: new Date(clock.now + 1000).toISOString()}});
      }
      const before = firestore.entries();
      const execute = () => firestore.runTransaction(async (tx) => {
        const prepared = await repository.prepareWorkItemAction(
          tx as unknown as import("firebase-admin/firestore").Transaction,
          action);
        if (boundary === "input") {
          action.workItem.normalizedPayload = {tampered: true};
          action.receipt.outputHash = "a".repeat(64);
        } else clock.now += boundary === "deadline" ? 1000 : 60_000;
        tx.create(firestore.collection("domain").doc("effect"), {done: true});
        prepared.commit();
      });
      if (boundary === "input") {
        await execute();
        assert.notDeepEqual((await repository.getWorkItem("work:event:1"))
          ?.normalizedPayload, {tampered: true});
      } else {
        await assert.rejects(execute(), {code: boundary === "lease" ?
          "lease_expired" : "run_not_executable"});
        assert.deepEqual(firestore.entries(), before);
      }
    }
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

const adminQuery = {
  workflowId: "supply-intake", runId: "run:mumbai:2026-07-14", limit: 2,
  allowedPrimaryStages: ["incoming", "verify", "resolve", "ready"],
};

test("admin scan uses raw page boundaries and leaves lookahead unvalidated",
  async () => {
    for (const invalidIds of [["work:b"], ["work:a"], ["work:c"],
      ["work:a", "work:b", "work:c"]]) {
      const {repository, firestore} = harness();
      for (const id of ["work:a", "work:b", "work:c"]) {
        const item = operationWorkItem({workItemId: id});
        firestore.write(`${operationCollections.workItems}/${id}`, {
          ...item,
          ...(invalidIds.includes(id) ? {candidateHash: "invalid"} : {}),
        });
      }
      const first = await repository.listWorkItemsForAdmin(adminQuery);
      assert.equal(first.scannedCount, 2);
      assert.equal(first.nextCursor, "work:b");
      assert.deepEqual(first.items.map((item) => item.workItemId),
        ["work:a", "work:b"].filter((id) => !invalidIds.includes(id)));
      assert.deepEqual(first.unavailableRecords.map((row) => row.documentId),
        ["work:a", "work:b"].filter((id) => invalidIds.includes(id)));
      const second = await repository.listWorkItemsForAdmin({
        ...adminQuery, cursor: first.nextCursor,
      });
      assert.equal(second.scannedCount, 1);
      assert.equal(second.nextCursor, null);
      assert.deepEqual(second.items.map((item) => item.workItemId),
        invalidIds.includes("work:c") ? [] : ["work:c"]);
      assert.equal(second.unavailableRecords.length,
        invalidIds.includes("work:c") ? 1 : 0);
      const empty = await repository.listWorkItemsForAdmin({
        ...adminQuery, cursor: "work:c",
      });
      assert.deepEqual(empty, {items: [], scannedCount: 0,
        unavailableRecords: [], nextCursor: null});
    }
  });

test("all-invalid maximum pages have bounded evidence and continuation",
  async () => {
    const {repository, firestore} = harness();
    for (let index = 0; index < 201; index++) {
      const id = `work:${String(index).padStart(3, "0")}`;
      firestore.write(`${operationCollections.workItems}/${id}`, {
        ...operationWorkItem({workItemId: id}),
        warningCodes: Array(50).fill(42),
        privatePayload: "synthetic-private-content",
      });
    }
    const first = await repository.listWorkItemsForAdmin({
      ...adminQuery, limit: 200,
    });
    assert.deepEqual(first.items, []);
    assert.equal(first.scannedCount, 200);
    assert.equal(first.unavailableRecords.length, 200);
    assert.equal(first.nextCursor, "work:199");
    assert.ok(first.unavailableRecords.every((row) =>
      row.issues.length <= 10 && row.issuesTruncated &&
      row.issues.every((issue) => issue.path.length <= 200 &&
        issue.code.length <= 80 && !("message" in issue))));
    assert.ok(!JSON.stringify(first).includes("synthetic-private-content"));
    const last = await repository.listWorkItemsForAdmin({
      ...adminQuery, limit: 200, cursor: first.nextCursor,
    });
    assert.equal(last.scannedCount, 1);
    assert.equal(last.unavailableRecords.length, 1);
    assert.equal(last.nextCursor, null);
  });

test("admin projection checks document identity and query scope independently",
  async () => {
    const variants = [
      {field: "workItemId", value: "work:alias",
        reason: "document_id_mismatch"},
      {field: "workflowId", value: "other-workflow", reason: "scope_mismatch"},
      {field: "runId", value: "run:other", reason: "scope_mismatch"},
      {field: "primaryStage", value: "approve", reason: "unsupported_stage"},
      {field: "entityKind", value: "organizer", reason: "scope_mismatch"},
      {field: "lifecycleStatus", value: "ready", reason: "scope_mismatch"},
      {field: "taskFlags", value: [], reason: "scope_mismatch"},
    ];
    for (const variant of variants) {
      // Simulate a corrupt query result; validation and joins run in the real
      // repository rather than being bypassed by a typed repository stub.
      const item = {...operationWorkItem({workItemId: "work:a",
        taskFlags: ["human_review_required"]}),
      [variant.field]: variant.value};
      const calls: Array<unknown[]> = [];
      const query = {
        where: (...args: unknown[]) => {
          calls.push(args); return query;
        },
        orderBy: (...args: unknown[]) => {
          calls.push(args); return query;
        },
        startAfter: (...args: unknown[]) => {
          calls.push(args); return query;
        },
        limit: (...args: unknown[]) => {
          calls.push(args); return query;
        },
        get: async () => ({docs: [{id: "work:a", data: () => item}]}),
      };
      const db = {collection: () => query} as unknown as Firestore;
      const repository = new FirestoreOperationsRepository(db);
      const page = await repository.listWorkItemsForAdmin({
        ...adminQuery, entityKind: "event", lifecycleStatus: "queued",
        humanReviewRequired: true, cursor: "work:0",
      });
      assert.deepEqual(page.items, []);
      assert.equal(page.scannedCount, 1);
      assert.deepEqual(page.unavailableRecords, [{documentId: "work:a",
        reason: variant.reason, issues: [{path: variant.field,
          code: variant.reason}], issuesTruncated: false}]);
      assert.ok(calls.some((args) => args[0] === "taskFlags" &&
        args[1] === "array-contains" && args[2] === "human_review_required"));
      assert.ok(calls.some((args) => args.length === 1 && args[0] === 3));
      assert.ok(calls.some((args) =>
        args.length === 1 && args[0] === "work:0"));
    }
  });

test("query and snapshot transport errors cannot become unavailable records",
  async () => {
    const failure = new Error("synthetic query error");
    for (const boundary of ["query", "snapshot"] as const) {
      const query = {
        where: () => query, orderBy: () => query, limit: () => query,
        get: async () => {
          if (boundary === "query") throw failure;
          return {docs: [{id: "work:a", data: () => {
            throw failure;
          }}]};
        },
      };
      const repository = new FirestoreOperationsRepository({
        collection: () => query,
      } as unknown as Firestore);
      await assert.rejects(repository.listWorkItemsForAdmin(adminQuery),
        (error) => error === failure);
    }
    const {repository} = harness();
    for (const limit of [0, 201, 1.5]) {
      await assert.rejects(repository.listWorkItemsForAdmin({
        ...adminQuery, limit,
      }), {code: "invalid_page_limit"});
    }
  });

test("unavailable records remain invalid for strict reads, writes and actions",
  async () => {
    const {repository, firestore, action} = await actionHarness();
    const malformed = {...action.workItem, candidateHash: "malformed"};
    const before = firestore.entries();
    await assert.rejects(repository.createWorkItem({...malformed,
      workItemId: "work:new", revision: 0}), {code: "invalid_entity"});
    await assert.rejects(repository.saveWorkItem(malformed, 0),
      {code: "invalid_entity"});
    await assert.rejects(repository.commitWorkItemAction({
      ...action, workItem: malformed,
    }), {code: "invalid_entity"});
    assert.deepEqual(firestore.entries(), before);
    firestore.write(`${operationCollections.workItems}/${malformed.workItemId}`,
      {...malformed, revision: 0});
    const stored = firestore.entries();
    const page = await repository.listWorkItemsForAdmin(adminQuery);
    assert.equal(page.unavailableRecords.length, 1);
    await assert.rejects(repository.getWorkItem(malformed.workItemId),
      {code: "invalid_entity"});
    await assert.rejects(repository.listWorkItems(adminQuery),
      {code: "invalid_entity"});
    await assert.rejects(repository.commitWorkItemAction(action),
      {code: "invalid_entity"});
    assert.deepEqual(firestore.entries(), stored);
  });


test("repository preserves long raw document cursors without truncation",
  async () => {
    const {repository, firestore} = harness();
    const id = "a".repeat(1001);
    firestore.write(`${operationCollections.workItems}/${id}`,
      {...operationWorkItem()});
    await repository.createWorkItem(operationWorkItem({workItemId: "work:z"}));
    const first = await repository.listWorkItemsForAdmin({
      ...adminQuery, limit: 1,
    });
    assert.equal(first.nextCursor, id);
    assert.equal(first.unavailableRecords[0].documentId, id);
    const second = await repository.listWorkItemsForAdmin({
      ...adminQuery, limit: 1, cursor: first.nextCursor,
    });
    assert.deepEqual(second.items.map((row) => row.workItemId), ["work:z"]);
    assert.equal(second.nextCursor, null);
  });
