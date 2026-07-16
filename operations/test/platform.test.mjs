import assert from "node:assert/strict";
import fs from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import {BudgetLedger} from "../src/platform/budget.mjs";
import {hashValue, stableStringify} from "../src/platform/canonical-json.mjs";
import {
  assertRun,
  MAX_WORK_ITEMS_PER_RUN,
  MIN_WORK_ITEMS_PER_RUN,
  transitionWorkItem,
} from "../src/platform/contracts.mjs";
import {GuardedModelRunner, modelCachePort} from "../src/platform/model/guarded-model-runner.mjs";
import {FileOperationsStore} from "../src/platform/storage/file-store.mjs";
import {SUPPLY_INTAKE_TRANSITIONS} from
  "../src/workflows/supply-intake/definition.mjs";
import {temporaryDirectory} from "./helpers.mjs";

test("canonical JSON and hashes are key-order independent", () => {
  assert.equal(stableStringify({b: 2, a: 1}), '{"a":1,"b":2}');
  assert.equal(hashValue({b: 2, a: 1}), hashValue({a: 1, b: 2}));
});

test("budgets fail closed before exceeding a capability allowance", () => {
  const budget = new BudgetLedger({limits: {workItems: 2, networkRequests: 0, modelCalls: 0, modelInputTokens: 0, modelOutputTokens: 0, modelCostMicros: 0, publicWrites: 0}});
  budget.consume({workItems: 2}, {reason: "fixture"});
  assert.throws(() => budget.consume({workItems: 1}), {code: "BUDGET_EXCEEDED"});
  assert.throws(() => budget.consume({networkRequests: 1}), {code: "BUDGET_EXCEEDED"});
});

test("the platform rejects runs above its canonical work-item capacity", () => {
  for (const workItems of [
    MIN_WORK_ITEMS_PER_RUN - 1,
    MAX_WORK_ITEMS_PER_RUN + 1,
  ]) {
    assert.throws(() => assertRun({
      runId: "run-invalid-capacity",
      mode: "shadow",
      status: "planned",
      budget: {limits: {workItems}},
    }), {code: "RUN_SHARD_REQUIRED"});
  }
});

test("file store provides immutable actions, idempotency, checkpoints, and exclusive leases", async () => {
  const store = await new FileOperationsStore(await temporaryDirectory()).initialize();
  const now = "2026-07-14T00:00:00.000Z";
  const lease = await store.acquireLease("run:test", {owner: "worker-a", ttlMs: 60_000, now});
  await assert.rejects(
    store.acquireLease("run:test", {owner: "worker-b", ttlMs: 60_000, now}),
    {code: "LEASE_HELD"}
  );
  assert.equal(await store.releaseLease(lease), true);

  const first = await store.recordIdempotency("run:plan", {runId: "run-one"});
  const second = await store.recordIdempotency("run:plan", {runId: "run-two"});
  assert.equal(first.created, true);
  assert.equal(second.created, false);
  assert.equal(second.record.runId, "run-one");

  const action = {schemaVersion: 1, actionId: "action-one", runId: "run-one", type: "test", at: now, actor: {kind: "test"}, payload: {value: 1}};
  await store.appendAction(action);
  await store.appendAction(action);
  await assert.rejects(store.appendAction({...action, payload: {value: 2}}), {code: "ACTION_CONFLICT"});
  assert.equal((await store.listActions("run-one")).length, 1);

  await store.putCheckpoint("run-one", "step-one", {completed: true, outputHash: "abc"});
  assert.equal((await store.getCheckpoint("run-one", "step-one")).completed, true);
});

test("lease fencing rejects expired and superseded workers on every run write", async () => {
  const store = await new FileOperationsStore(await temporaryDirectory()).initialize();
  const start = "2026-07-14T00:00:00.000Z";
  const renewedAt = "2026-07-14T00:00:00.500Z";
  const takeoverAt = "2026-07-14T00:00:01.500Z";
  await store.createRun({
    schemaVersion: 1,
    runId: "run-fenced",
    workflowId: "supply-intake",
    mode: "shadow",
    status: "planned",
    budget: new BudgetLedger({limits: {
      workItems: 1,
      networkRequests: 0,
      modelCalls: 0,
      modelInputTokens: 0,
      modelOutputTokens: 0,
      modelCostMicros: 0,
      publicWrites: 0,
    }}).snapshot(),
  });
  const workItem = {
    schemaVersion: 1,
    workItemId: "work-fenced",
    runId: "run-fenced",
    workflowId: "supply-intake",
    entityKind: "event",
    sourceEntity: {id: "event-fenced", title: "Fenced event"},
    primaryStage: "incoming",
    lifecycleStatus: "active",
    taskFlags: [],
    blockers: [],
    evidence: {artifactHash: "artifact-fenced"},
    decisionProvenance: {},
    confidence: {},
  };
  await store.putWorkItem(workItem);
  const first = await store.acquireLease("run:run-fenced", {
    owner: "worker-a",
    ttlMs: 1_000,
    now: start,
  });
  const renewed = await store.renewLease(first, {ttlMs: 1_000, now: renewedAt});
  assert.equal(first.fencingToken, 1);
  assert.equal(renewed.fencingToken, 1);
  assert.equal(renewed.heartbeatAt, renewedAt);
  await assert.rejects(
    store.renewLease(renewed, {ttlMs: 1_000, now: takeoverAt}),
    {code: "LEASE_EXPIRED"}
  );
  const second = await store.acquireLease("run:run-fenced", {
    owner: "worker-b",
    ttlMs: 1_000,
    now: takeoverAt,
  });
  assert.equal(second.fencingToken, 2);
  const staleOptions = {lease: renewed, now: takeoverAt};
  await assert.rejects(
    store.updateRun("run-fenced", (run) => ({...run, status: "running"}), staleOptions),
    {code: "LEASE_LOST"}
  );
  await assert.rejects(
    store.putWorkItem({...workItem, primaryStage: "verify"}, staleOptions),
    {code: "LEASE_LOST"}
  );
  await assert.rejects(
    store.putCheckpoint("run-fenced", "stale", {completed: true}, staleOptions),
    {code: "LEASE_LOST"}
  );
  await assert.rejects(
    store.appendAction({
      schemaVersion: 1,
      actionId: "stale-action",
      runId: "run-fenced",
      type: "stale",
      at: takeoverAt,
      actor: {kind: "test"},
      payload: {},
    }, staleOptions),
    {code: "LEASE_LOST"}
  );
  await store.updateRun(
    "run-fenced",
    (run) => ({...run, status: "running"}),
    {lease: second, now: takeoverAt}
  );
  assert.equal((await store.requireRun("run-fenced")).leaseFencingToken, 2);
  assert.equal(await store.releaseLease(second), true);
});

test("file store recovers a lease guard orphaned by a dead process", async () => {
  const root = await temporaryDirectory();
  const store = await new FileOperationsStore(root).initialize();
  const resourceId = "run:orphaned-guard";
  const guardDirectory = path.join(root, "leases", `${encodeURIComponent(resourceId)}.guard`);
  await fs.mkdir(guardDirectory);
  await fs.writeFile(path.join(guardDirectory, "owner-orphan.json"), JSON.stringify({
    schemaVersion: 1,
    token: "orphan",
    pid: 2_147_483_647,
    acquiredAt: "2026-07-14T00:00:00.000Z",
  }));

  const lease = await store.acquireLease(resourceId, {
    owner: "recovery-worker",
    ttlMs: 60_000,
    now: "2026-07-14T00:01:00.000Z",
  });
  assert.equal(lease.owner, "recovery-worker");
  assert.equal(lease.fencingToken, 1);
  assert.equal(await store.releaseLease(lease), true);
});

test("lease guard recovery preserves a directory when any owner process is live", async () => {
  const root = await temporaryDirectory();
  const store = await new FileOperationsStore(root, {leaseGuardStaleMs: 0}).initialize();
  const resourceId = "run:mixed-guard-owners";
  const guardDirectory = path.join(root, "leases", `${encodeURIComponent(resourceId)}.guard`);
  await fs.mkdir(guardDirectory);
  await Promise.all([
    fs.writeFile(path.join(guardDirectory, "owner-live.json"), JSON.stringify({
      schemaVersion: 1,
      token: "live",
      pid: process.pid,
      acquiredAt: new Date().toISOString(),
    })),
    fs.writeFile(path.join(guardDirectory, "owner-dead.json"), JSON.stringify({
      schemaVersion: 1,
      token: "dead",
      pid: 2_147_483_647,
      acquiredAt: new Date().toISOString(),
    })),
  ]);

  await assert.rejects(
    store.acquireLease(resourceId, {
      owner: "recovery-worker",
      ttlMs: 60_000,
      now: "2026-07-14T00:01:00.000Z",
    }),
    {code: "LEASE_RACE"}
  );
  assert.deepEqual(
    (await fs.readdir(guardDirectory)).sort(),
    ["owner-dead.json", "owner-live.json"]
  );
});

test("lease recovery rechecks owners after marking a stale guard", async () => {
  const root = await temporaryDirectory();
  const recoveryInspected = deferred();
  const continueRecovery = deferred();
  let pauseRecovery = true;
  const store = await new FileOperationsStore(root, {
    leaseGuardStaleMs: 0,
    leaseGuardHooks: {
      beforeRecoveryMarker: async () => {
        if (!pauseRecovery) return;
        pauseRecovery = false;
        recoveryInspected.resolve();
        await continueRecovery.promise;
      },
    },
  }).initialize();
  const resourceId = "run:owner-added-during-recovery";
  const guardDirectory = path.join(root, "leases", `${encodeURIComponent(resourceId)}.guard`);
  await fs.mkdir(guardDirectory);
  await fs.writeFile(path.join(guardDirectory, "owner-dead.json"), JSON.stringify({
    schemaVersion: 1,
    token: "dead",
    pid: 2_147_483_647,
    acquiredAt: new Date().toISOString(),
  }));

  const acquisition = store.acquireLease(resourceId, {
    owner: "recovery-worker",
    ttlMs: 60_000,
    now: "2026-07-14T00:01:00.000Z",
  });
  await recoveryInspected.promise;
  await fs.writeFile(path.join(guardDirectory, "owner-live.json"), JSON.stringify({
    schemaVersion: 1,
    token: "live",
    pid: process.pid,
    acquiredAt: new Date().toISOString(),
  }));
  continueRecovery.resolve();

  await assert.rejects(acquisition, {code: "LEASE_RACE"});
  assert.deepEqual(
    (await fs.readdir(guardDirectory)).sort(),
    ["owner-dead.json", "owner-live.json"]
  );
});

test("lease guard ownership survives an ownerless-directory quarantine race", async () => {
  const root = await temporaryDirectory();
  const pausedAfterMkdir = deferred();
  const resumeFirstWorker = deferred();
  const secondWorkerEntered = deferred();
  const releaseSecondWorker = deferred();
  let pauseFirstAttempt = true;
  let firstWorkerInside = false;
  let secondWorkerInside = false;
  const firstStore = await new FileOperationsStore(root, {
    leaseGuardStaleMs: 0,
    leaseGuardHooks: {
      afterMkdir: async () => {
        if (!pauseFirstAttempt) return;
        pauseFirstAttempt = false;
        pausedAfterMkdir.resolve();
        await resumeFirstWorker.promise;
      },
    },
  }).initialize();
  const secondStore = await new FileOperationsStore(root, {leaseGuardStaleMs: 0}).initialize();
  const resourceId = "run:guard-quarantine-race";

  const first = firstStore.withLeaseGuard(resourceId, async () => {
    firstWorkerInside = true;
    assert.equal(secondWorkerInside, false);
  });
  await pausedAfterMkdir.promise;
  const second = secondStore.withLeaseGuard(resourceId, async () => {
    secondWorkerInside = true;
    secondWorkerEntered.resolve();
    await releaseSecondWorker.promise;
    secondWorkerInside = false;
  });
  await secondWorkerEntered.promise;

  resumeFirstWorker.resolve();
  await new Promise((resolve) => setTimeout(resolve, 25));
  assert.equal(firstWorkerInside, false);
  assert.equal(secondWorkerInside, true);

  releaseSecondWorker.resolve();
  await second;
  await first;
  assert.equal(firstWorkerInside, true);
});

test("guarded model runner fails closed but can replay schema-valid cache", async () => {
  const store = await new FileOperationsStore(await temporaryDirectory()).initialize();
  const request = {
    task: "extract-event",
    promptVersion: "extract-v1",
    input: {text: "untrusted source excerpt"},
    outputSchema: {
      type: "object",
      additionalProperties: false,
      required: ["title"],
      properties: {title: {type: "string", minLength: 1}},
    },
  };
  const runner = new GuardedModelRunner({enabled: false, cache: modelCachePort(store), modelId: "test-model"});
  await assert.rejects(runner.run(request), {code: "MODEL_DISABLED"});

  const cacheKey = hashValue({schemaVersion: 1, task: request.task, promptVersion: request.promptVersion, modelId: "test-model", input: request.input, outputSchema: request.outputSchema});
  await store.putModelCache(cacheKey, {
    schemaVersion: 1,
    output: {title: "Cached title"},
    provenance: {task: request.task, promptVersion: request.promptVersion, modelId: "test-model"},
  });
  const result = await runner.run(request);
  assert.equal(result.output.title, "Cached title");
  assert.equal(result.provenance.cacheHit, true);
});

test("enabled model calls require reservations and reconcile actual usage", async () => {
  const store = await new FileOperationsStore(await temporaryDirectory()).initialize();
  const budget = new BudgetLedger({
    limits: {
      modelCalls: 1,
      modelInputTokens: 20,
      modelOutputTokens: 10,
      modelCostMicros: 1_000,
    },
  });
  const request = {
    task: "extract-event",
    promptVersion: "extract-v1",
    input: {text: "bounded source excerpt"},
    outputSchema: {
      type: "object",
      additionalProperties: false,
      required: ["title"],
      properties: {title: {type: "string", minLength: 1}},
    },
  };
  const runner = new GuardedModelRunner({
    enabled: true,
    cache: modelCachePort(store),
    budget,
    modelId: "test-model",
    provider: {
      run: async () => ({
        output: {title: "Bounded title"},
        usage: {inputTokens: 7, outputTokens: 2, costMicros: 40},
      }),
    },
  });
  await assert.rejects(runner.run(request), {code: "MODEL_BUDGET_ESTIMATE_REQUIRED"});
  const result = await runner.run({
    ...request,
    estimatedInputTokens: 10,
    maxOutputTokens: 5,
    maxCostMicros: 100,
  });
  assert.equal(result.provenance.usage.inputTokens, 7);
  assert.deepEqual(budget.snapshot().consumed, {
    workItems: 0,
    networkRequests: 0,
    modelCalls: 1,
    modelInputTokens: 7,
    modelOutputTokens: 2,
    modelCostMicros: 40,
    publicWrites: 0,
  });
});

test("primary stage transitions reject terminal states", () => {
  const item = {
    schemaVersion: 1,
    workItemId: "event:test",
    runId: "run:test",
    workflowId: "supply-intake",
    entityKind: "event",
    sourceEntity: {id: "test", title: "Test"},
    primaryStage: "incoming",
    lifecycleStatus: "active",
    taskFlags: [],
    blockers: [],
    evidence: {artifactHash: "hash"},
    decisionProvenance: {},
    confidence: {},
  };
  assert.equal(transitionWorkItem(item, "ready", {
    at: "2026-07-14T00:00:00.000Z",
    allowedTransitions: SUPPLY_INTAKE_TRANSITIONS,
  }).primaryStage, "ready");
  assert.throws(() => transitionWorkItem(item, "expired", {
    at: "2026-07-14T00:00:00.000Z",
    allowedTransitions: SUPPLY_INTAKE_TRANSITIONS,
  }), {code: "INVALID_TRANSITION"});
});

function deferred() {
  let resolve;
  let reject;
  const promise = new Promise((resolvePromise, rejectPromise) => {
    resolve = resolvePromise;
    reject = rejectPromise;
  });
  return {promise, resolve, reject};
}
