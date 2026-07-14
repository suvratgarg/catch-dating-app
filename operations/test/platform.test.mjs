import assert from "node:assert/strict";
import test from "node:test";
import {BudgetLedger} from "../src/platform/budget.mjs";
import {hashValue, stableStringify} from "../src/platform/canonical-json.mjs";
import {transitionWorkItem} from "../src/platform/contracts.mjs";
import {GuardedModelRunner, modelCachePort} from "../src/platform/model/guarded-model-runner.mjs";
import {FileOperationsStore} from "../src/platform/storage/file-store.mjs";
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
  assert.equal(transitionWorkItem(item, "ready", {at: "2026-07-14T00:00:00.000Z"}).primaryStage, "ready");
  assert.throws(() => transitionWorkItem(item, "expired", {at: "2026-07-14T00:00:00.000Z"}), {code: "INVALID_TRANSITION"});
});
