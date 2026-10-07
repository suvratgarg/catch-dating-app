import test from "node:test";
import assert from "node:assert/strict";
import {GuardedModelRunner} from "../src/platform/model/guarded-model-runner.mjs";
import {BudgetLedger} from "../src/platform/budget.mjs";

const schema = {type: "object", additionalProperties: false, required: ["draft"],
  properties: {draft: {type: "string"}}};
const limits = {modelCalls: 2, modelInputTokens: 40, modelOutputTokens: 20,
  modelCostMicros: 200, networkRequests: 4};
const request = (extra = {}) => ({task: "sales-writing", promptVersion: "draft-v1",
  input: {text: "Synthetic public copy"}, outputSchema: schema,
  estimatedInputTokens: 20, maxOutputTokens: 10, maxCostMicros: 100, maxNetworkRequests: 2, ...extra});

function fixture(extra = {}) {
  const records = new Map();
  const cache = {get: async (key) => records.get(key), put: async (key, record) => records.set(key, record)};
  const budget = new BudgetLedger({limits});
  const monthlyBudget = new BudgetLedger({limits});
  let calls = 0;
  const providerId = extra.providerId ?? "deepseek";
  const modelId = extra.modelId ?? "fixture-model";
  const response = () => ({schemaVersion: 1, output: {draft: "Fixture draft"},
    usage: {inputTokens: 7, outputTokens: 3, costMicros: 100},
    metadata: {providerId, modelId, requestId: "safe_1", attemptCount: 1, durationMs: 5,
      finishReason: "stop", costBasis: "reserved_ceiling", estimatedCostMicros: null,
      tokens: {inputTotal: 7, ordinaryInput: null, cacheRead: null, cacheWrite: null,
        outputTotal: 3, reasoningOutput: null}}});
  const provider = {run: async () => {calls++; return response();}};
  const runner = new GuardedModelRunner({enabled: true, provider, cache, budget,
    monthlyBudget, monthlyWindow: "2026-10", providerId, modelId, ...extra});
  return {runner, budget, monthlyBudget, cache, records, response, calls: () => calls};
}

test("provider and model identities separate caches; matching hits consume nothing", async () => {
  const first = fixture();
  const result = await first.runner.run(request());
  const replay = await first.runner.run(request());
  assert.equal(first.calls(), 1);
  assert.equal(replay.provenance.cacheHit, true);
  for (const extra of [{providerId: "openai"}, {modelId: "other-model"}]) {
    const other = fixture({...extra, cache: first.cache});
    const output = await other.runner.run(request());
    assert.notEqual(output.provenance.cacheKey, result.provenance.cacheKey);
    assert.equal(other.calls(), 1);
  }
  assert.equal(first.budget.snapshot().consumed.networkRequests, 1);
});

test("normalized request and usage metadata survive cache without raw vendor fields", async () => {
  let captured;
  const f = fixture();
  f.runner.provider = {run: async (value) => {
    captured = value;
    const response = f.response();
    response.metadata.headers = {authorization: "fixture-secret"};
    response.metadata.tokens.privateField = "fixture-private";
    return response;
  }};
  const signal = new AbortController().signal;
  const result = await f.runner.run(request({signal}));
  assert.equal(captured.signal, signal);
  assert.equal(captured.estimatedInputTokens, 20);
  assert.equal(captured.maxNetworkRequests, 2);
  assert.deepEqual(result.provenance.request, {maxInputBytes: 32768,
    estimatedInputTokens: 20, maxOutputTokens: 10, maxCostMicros: 100, maxNetworkRequests: 2});
  assert.equal(result.provenance.metadata.costBasis, "reserved_ceiling");
  assert.equal(result.provenance.metadata.tokens.cacheRead, null);
  assert.doesNotMatch(JSON.stringify(result.provenance), /fixture-secret|fixture-private|Synthetic public/);
  assert.deepEqual((await f.runner.run(request())).provenance.metadata, result.provenance.metadata);
});

test("both ledgers reserve model and network ceilings before I/O", async () => {
  const f = fixture();
  f.runner.provider = {run: async () => {
    for (const ledger of [f.budget, f.monthlyBudget]) {
      assert.equal(ledger.snapshot().consumed.networkRequests, 2);
      assert.equal(ledger.snapshot().consumed.modelCostMicros, 100);
    }
    return f.response();
  }};
  await f.runner.run(request());
  for (const ledger of [f.budget, f.monthlyBudget]) {
    assert.equal(ledger.snapshot().consumed.networkRequests, 1);
    assert.equal(ledger.snapshot().consumed.modelInputTokens, 7);
    assert.equal(ledger.snapshot().consumed.modelCostMicros, 100);
  }
});

test("missing network caps and either exhausted ledger stop before I/O", async () => {
  const missing = fixture();
  await assert.rejects(missing.runner.run(request({maxNetworkRequests: undefined})), {code: "MODEL_NETWORK_BUDGET_REQUIRED"});
  for (const key of ["budget", "monthlyBudget"]) {
    for (const dimension of ["networkRequests", "modelInputTokens", "modelCalls", "modelCostMicros"]) {
      const f = fixture({[key]: new BudgetLedger({limits: {...limits, [dimension]: 0}})});
      await assert.rejects(f.runner.run(request()), {code: "BUDGET_EXCEEDED"});
      assert.equal(f.calls(), 0);
    }
  }
});

test("cancellation before cache access skips I/O and reservation", async () => {
  const controller = new AbortController(); controller.abort("private abort reason");
  const f = fixture({cache: {get: () => assert.fail("cache must not run"), put: () => {}}});
  await assert.rejects(f.runner.run(request({signal: controller.signal})), {code: "MODEL_PROVIDER_CANCELLED"});
  assert.equal(f.calls(), 0);
  assert.equal(f.budget.snapshot().consumed.modelCalls, 0);
});

test("in-flight cancellation bounds ignored ports, retains reservations and discards late success", async () => {
  const controller = new AbortController();
  let finish;
  let started;
  const submitted = new Promise((resolve) => {started = resolve;});
  const f = fixture({provider: {run: (value) => {
    assert.equal(value.signal, controller.signal); started();
    return new Promise((resolve) => {finish = resolve;});
  }}});
  const pending = f.runner.run(request({signal: controller.signal}));
  await submitted; controller.abort("private abort reason");
  await assert.rejects(pending, (error) => error.code === "MODEL_PROVIDER_CANCELLED" && error.details.outcome === "unknown");
  finish(f.response());
  await new Promise((resolve) => setImmediate(resolve));
  assert.equal(f.records.size, 0);
  for (const ledger of [f.budget, f.monthlyBudget]) {
    assert.equal(ledger.snapshot().consumed.modelCostMicros, 100);
    assert.equal(ledger.snapshot().consumed.networkRequests, 2);
  }
});

test("unknown paid errors are redacted and never automatically retried or cached", async () => {
  let calls = 0;
  const f = fixture({provider: {run: async () => {calls++; throw new Error("secret-token guest-private");}}});
  await assert.rejects(f.runner.run(request()), (error) => {
    assert.equal(error.code, "MODEL_PROVIDER_FAILED");
    assert.equal(error.details.outcome, "unknown");
    assert.equal(error.cause, undefined);
    assert.doesNotMatch(JSON.stringify(error), /secret-token|guest-private/);
    return true;
  });
  assert.equal(calls, 1); assert.equal(f.records.size, 0);
  assert.equal(f.budget.snapshot().consumed.networkRequests, 2);
});

test("invalid schema, metadata or over-reservation usage cannot release ceilings or cache", async () => {
  for (const mutate of [
    (response) => {response.output = {invalid: true};},
    (response) => {response.metadata.providerId = "wrong-provider";},
    (response) => {response.metadata.attemptCount = 3;},
    (response) => {response.metadata.tokens.cacheRead = 8;},
    (response) => {response.metadata.requestId = "Authorization: private";},
    (response) => {response.usage.inputTokens = 21; response.metadata.tokens.inputTotal = 21;},
  ]) {
    const f = fixture();
    f.runner.provider = {run: async () => {const response = f.response(); mutate(response); return response;}};
    await assert.rejects(f.runner.run(request()));
    assert.equal(f.records.size, 0);
    assert.equal(f.budget.snapshot().consumed.modelInputTokens, 20);
    assert.equal(f.monthlyBudget.snapshot().consumed.networkRequests, 2);
  }
});

test("cache provenance cannot substitute another provider", async () => {
  const f = fixture();
  const result = await f.runner.run(request());
  f.records.get(result.provenance.cacheKey).provenance.providerId = "anthropic";
  await assert.rejects(f.runner.run(request()), {code: "MODEL_CACHE_INVALID"});
  assert.equal(f.calls(), 1);
});

test("input/schema snapshot remains stable across an asynchronous cache lookup", async () => {
  let resume;
  const pendingCache = new Promise((resolve) => {resume = resolve;});
  const f = fixture({cache: {get: () => pendingCache, put: async () => {}}});
  let sent;
  f.runner.provider = {run: async (value) => {sent = value; return f.response();}};
  const input = request({input: {text: "original"}, outputSchema: structuredClone(schema)});
  const pending = f.runner.run(input);
  input.input.text = "private mutation"; input.outputSchema.properties.draft.type = "number";
  resume(null); await pending;
  assert.equal(sent.input.text, "original");
  assert.equal(sent.outputSchema.properties.draft.type, "string");
});
