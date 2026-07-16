import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest} from "firebase-functions/v2/https";
import {InMemoryOperationsRepository} from
  "../operations/inMemoryRepository";
import {operationRun, operationWorkItem} from
  "../operations/testFixtures";
import {adminListIntakeOperationsHandler} from "./intakeOperations";

const now = "2026-07-14T09:00:00.000Z";

async function harness() {
  const repository = new InMemoryOperationsRepository();
  const rateLimitCalls: string[] = [];
  await repository.createRun(operationRun({
    runId: "run:mumbai:2026-07-07",
    createdAt: "2026-07-07T08:00:00.000Z",
    updatedAt: "2026-07-07T08:00:00.000Z",
    metadata: {projection: {
      workItemCount: 1,
      activeItems: 1,
      terminalItems: 0,
      humanReviewCount: 0,
      stageCounts: {incoming: 1, verify: 0, resolve: 0, ready: 0},
    }},
  }));
  await repository.createRun(operationRun({
    runId: "run:mumbai:2026-07-14",
    metadata: {projection: {
      workItemCount: 1,
      activeItems: 1,
      terminalItems: 0,
      humanReviewCount: 1,
      stageCounts: {incoming: 0, verify: 0, resolve: 1, ready: 0},
    }},
  }));
  await repository.createRun(operationRun({
    runId: "run:zz-lexically-high-but-old",
    createdAt: "2026-06-01T08:00:00.000Z",
    updatedAt: "2026-06-01T08:00:00.000Z",
    metadata: {projection: {
      workItemCount: 0,
      activeItems: 0,
      terminalItems: 0,
      humanReviewCount: 0,
      stageCounts: {incoming: 0, verify: 0, resolve: 0, ready: 0},
    }},
  }));
  await repository.createWorkItem(operationWorkItem({
    workItemId: "work:event:old",
    runId: "run:mumbai:2026-07-07",
  }));
  await repository.createWorkItem(operationWorkItem({
    workItemId: "work:event:new",
    runId: "run:mumbai:2026-07-14",
    primaryStage: "resolve",
    lifecycleStatus: "waiting",
    taskFlags: ["human_review_required"],
    blockerCodes: ["official_source_required"],
    normalizedPayload: {title: "Current event", owner: "human"},
  }));
  return {
    repository,
    rateLimitCalls,
    deps: {
      firestore: () => ({}) as FirebaseFirestore.Firestore,
      repository,
      now: () => new Date(now),
      checkRateLimit: async (
        _db: FirebaseFirestore.Firestore,
        uid: string,
        action: string
      ) => {
        rateLimitCalls.push(`${uid}:${action}`);
      },
    },
  };
}

test("adminListIntakeOperations returns the latest run inventory", async () => {
  const h = await harness();
  const result = await adminListIntakeOperationsHandler(
    callableRequest("admin-1", {}, {support: true}),
    h.deps
  );

  assert.deepEqual(result.runs.map((run) => run.runId), [
    "run:mumbai:2026-07-14",
    "run:mumbai:2026-07-07",
    "run:zz-lexically-high-but-old",
  ]);
  assert.equal(result.summary.loadedRunCount, 3);
  assert.deepEqual(result.workItems.map((item) => item.workItemId), [
    "work:event:new",
  ]);
  assert.deepEqual(result.summary.stages, {
    incoming: 0,
    verify: 0,
    resolve: 1,
    ready: 0,
  });
  assert.equal(result.summary.humanReviewCount, 1);
  assert.deepEqual(h.rateLimitCalls, [
    "admin-1:adminListIntakeOperations",
  ]);
  assert.deepEqual(result.capabilities, {
    requestRuns: false,
    networkFetches: false,
    modelCalls: false,
    publicWrites: false,
    ruleDeployment: false,
  });
});

test("labels the run summary as loaded inventory when another page exists",
  async () => {
    const h = await harness();
    const result = await adminListIntakeOperationsHandler(
      callableRequest("admin-1", {runLimit: 2}, {admin: true}),
      h.deps
    );
    assert.equal(result.runs.length, 2);
    assert.equal(result.summary.loadedRunCount, 2);
    assert.ok(result.nextRunCursor);
  });

test("can inspect an exact historical operations run", async () => {
  const h = await harness();
  const result = await adminListIntakeOperationsHandler(
    callableRequest("admin-1", {
      runId: " run:mumbai:2026-07-07 ",
    }, {admin: true}),
    h.deps
  );
  assert.deepEqual(result.runs.map((run) => run.runId), [
    "run:mumbai:2026-07-07",
  ]);
  assert.deepEqual(result.workItems.map((item) => item.workItemId), [
    "work:event:old",
  ]);
});

test("can page the canonical human-review exception inventory", async () => {
  const h = await harness();
  const result = await adminListIntakeOperationsHandler(
    callableRequest("admin-1", {
      runId: "run:mumbai:2026-07-14",
      humanReviewRequired: true,
    }, {admin: true}),
    h.deps
  );
  assert.deepEqual(result.workItems.map((item) => item.workItemId), [
    "work:event:new",
  ]);
  assert.ok(result.workItems.every((item) =>
    item.taskFlags.includes("human_review_required")));
});

test("uses persisted full-run aggregates beyond the returned item page",
  async () => {
    const h = await harness();
    const run = await h.repository.getRun("run:mumbai:2026-07-14");
    assert.ok(run);
    await h.repository.saveRun({
      ...run,
      revision: 1,
      budgets: {...run.budgets, maxWorkItems: 2_500},
      metadata: {
        projection: {
          workItemCount: 2_500,
          activeItems: 2_500,
          terminalItems: 0,
          humanReviewCount: 12,
          stageCounts: {
            incoming: 400,
            verify: 1_800,
            resolve: 12,
            ready: 288,
          },
        },
      },
    }, 0);
    const result = await adminListIntakeOperationsHandler(
      callableRequest("admin-1", {}, {admin: true}),
      h.deps
    );
    assert.equal(result.workItems.length, 1);
    assert.equal(result.summary.workItemCount, 2_500);
    assert.equal(result.summary.humanReviewCount, 12);
    assert.deepEqual(result.summary.stages, {
      incoming: 400,
      verify: 1_800,
      resolve: 12,
      ready: 288,
    });
  });

test("fails closed when projection aggregates exceed the frozen run budget",
  async () => {
    const h = await harness();
    const run = await h.repository.getRun("run:mumbai:2026-07-14");
    assert.ok(run);
    await h.repository.saveRun({
      ...run,
      revision: 1,
      metadata: {projection: {
        workItemCount: run.budgets.maxWorkItems + 1,
        activeItems: run.budgets.maxWorkItems + 1,
        terminalItems: 0,
        humanReviewCount: 0,
        stageCounts: {
          incoming: run.budgets.maxWorkItems + 1,
          verify: 0,
          resolve: 0,
          ready: 0,
        },
      }},
    }, 0);
    await assert.rejects(
      adminListIntakeOperationsHandler(
        callableRequest("admin-1", {}, {admin: true}),
        h.deps
      ),
      (error: unknown) => {
        assert.equal((error as {code?: string}).code, "failed-precondition");
        return true;
      }
    );
  });

test("fails closed without authoritative full-run projection aggregates",
  async () => {
    const h = await harness();
    const run = await h.repository.getRun("run:mumbai:2026-07-14");
    assert.ok(run);
    await h.repository.saveRun({
      ...run,
      revision: 1,
      metadata: {},
    }, 0);
    await assert.rejects(
      adminListIntakeOperationsHandler(
        callableRequest("admin-1", {}, {admin: true}),
        h.deps
      ),
      (error: unknown) => {
        assert.equal(
          (error as {code?: string}).code,
          "failed-precondition"
        );
        return true;
      }
    );
  });

test("fails closed on a non-Supply stage in the persisted projection",
  async () => {
    const h = await harness();
    const item = await h.repository.getWorkItem("work:event:new");
    assert.ok(item);
    await h.repository.saveWorkItem({
      ...item,
      revision: item.revision + 1,
      primaryStage: "approve",
      updatedAt: now,
    }, item.revision);

    await assert.rejects(
      adminListIntakeOperationsHandler(
        callableRequest("admin-1", {}, {admin: true}),
        h.deps
      ),
      (error: unknown) => {
        assert.equal(
          (error as {code?: string}).code,
          "failed-precondition"
        );
        return true;
      }
    );
  });

test("adminListIntakeOperations rejects non-operator admin roles", async () => {
  const h = await harness();
  await assert.rejects(
    adminListIntakeOperationsHandler(
      callableRequest("viewer-1", {}, {analyticsViewer: true}),
      h.deps
    ),
    (error: unknown) => {
      assert.equal((error as {code?: string}).code, "permission-denied");
      return true;
    }
  );
});

test("rejects lifecycle values as operations stages", async () => {
  const h = await harness();
  await assert.rejects(
    adminListIntakeOperationsHandler(
      callableRequest("admin-1", {primaryStage: "published"}, {admin: true}),
      h.deps
    ),
    (error: unknown) => {
      assert.equal((error as {code?: string}).code, "invalid-argument");
      return true;
    }
  );
});

test("rejects unindexed human-review filter combinations", async () => {
  const h = await harness();
  await assert.rejects(
    adminListIntakeOperationsHandler(
      callableRequest("admin-1", {
        humanReviewRequired: true,
        primaryStage: "resolve",
      }, {admin: true}),
      h.deps
    ),
    (error: unknown) => {
      assert.equal((error as {code?: string}).code, "invalid-argument");
      return true;
    }
  );
});

function callableRequest(
  uid: string | null,
  data: Record<string, unknown>,
  token: Record<string, unknown> = {}
): CallableRequest<unknown> {
  return {
    auth: uid ? {uid, token} as CallableRequest["auth"] : undefined,
    data,
    rawRequest: {headers: {}} as CallableRequest["rawRequest"],
  } as CallableRequest<unknown>;
}
