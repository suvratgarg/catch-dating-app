import test from "node:test";
import assert from "node:assert/strict";
import {BudgetLedger} from "../../platform/budget.mjs";
import {hashValue} from "../../platform/canonical-json.mjs";
import {createSalesPreparationAdapter} from "./preparation-adapter.mjs";
import {freezeSalesPreparationPolicy} from "./preparation-policy.mjs";

const stageBudget = {modelCalls: 1, modelInputTokens: 100, modelOutputTokens: 40,
  modelCostMicros: 1000, networkRequests: 1};
const writing = {observationAlias: "option_0", capabilityAlias: "option_1",
  referenceAlias: null, ctaAlias: "option_2", reasonToBlock: null, omittedAliases: []};
const research = {facts: [{claimKey: "operation", knowledgeStatus: "observed",
  value: "Weekly events", excerpt: "Weekly events use Calendar.", sourceAliases: ["source_0"], rationale: "Literal public capture."}],
workflowComparison: {knowledgeStatus: "inferred", visibleTools: [{name: "Calendar", sourceAlias: "source_0"}],
  strongestPlausibleWorkflow: "Calendar supports the public weekly event schedule.",
  incrementalValue: "A reviewed suggestion for manual evaluation.", remainingQuestions: ["How is scheduling managed?"]}};
const source = {dataClassification: "reviewed_public", sourceId: "private-source-identity",
  url: "https://example.com/events", text: "Weekly events use Calendar.",
  capturedAt: "2026-10-07T12:00:00.000Z", contentHash: hashValue("Weekly events use Calendar."),
  crmNotes: "private notes", guestList: ["private guest"]};
const clauses = [
  {kind: "observation", id: "private-observation", text: "Public weekly events"},
  {kind: "capability", id: "private-capability", text: "An approved public capability"},
  {kind: "cta", id: "private-cta", text: "An approved public CTA"},
].map((clause) => ({...clause, approved: true, dataClassification: "reviewed_public",
  email: "fixture@example.com", crmNotes: "private notes"}));

function fixture({providerId = "deepseek", output = writing, ...extra} = {}) {
  const config = (stage) => ({executionMode: "api", providerId, modelId: `${providerId}-fixture`,
    prompt: `Synthetic public ${stage} JSON prompt.`, promptVersion: `${stage}-v1`,
    budget: {...stageBudget}, billingSourceId: "fixture-billing-ref", fallback: "disabled"});
  const policy = {schemaVersion: 1, revision: 1, research: config("research"), writing: config("writing")};
  const frozen = freezeSalesPreparationPolicy(policy);
  const records = new Map();
  let calls = 0; let activations = 0; let creations = 0; let sent; let created;
  const factory = (options) => {creations++; created = options; return {run: async (request) => {
    calls++; sent = request;
    return {schemaVersion: 1, output: structuredClone(output),
      usage: {inputTokens: 12, outputTokens: 5, costMicros: request.maxCostMicros},
      metadata: {providerId, modelId: request.modelId, requestId: "fixture_1", attemptCount: 1, durationMs: 1,
        finishReason: "stop", costBasis: "reserved_ceiling", estimatedCostMicros: null,
        tokens: {inputTotal: 12, ordinaryInput: null, cacheRead: null, cacheWrite: null,
          outputTotal: 5, reasoningOutput: null}}};
  }};};
  const factories = {createDeepSeekProvider: factory, createOpenAIProvider: factory, createAnthropicProvider: factory};
  const monthlyBudget = new BudgetLedger({limits: {modelCalls: 10, modelInputTokens: 1000,
    modelOutputTokens: 400, modelCostMicros: 10000, networkRequests: 10}});
  const adapter = createSalesPreparationAdapter({enabled: true, factories,
    cache: {get: async (key) => records.get(key), put: async (key, value) => records.set(key, value)},
    monthlyBudget, monthlyWindow: "2026-10", activationPort: {current: async (binding) => {
      activations++; return {...binding, status: "active", authorizationId: "fixture-authorization",
        expiresAt: "2026-10-08T00:00:00.000Z"};
    }}, clock: () => new Date("2026-10-07T13:00:00.000Z"),
    providerOptions: {serverSecretRef: "fixture-ref", timeoutMs: 1000}, ...extra});
  const request = (stage = "writing") => ({stage, frozen, currentPolicy: policy, ownerUid: "private-owner",
    context: {organizerId: "private-organizer", contactId: "private-contact", opportunityId: "private-opportunity"},
    publicClauses: structuredClone(clauses), publicSources: [structuredClone(source)], estimatedInputTokens: 100});
  return {adapter, request, records, monthlyBudget, policy, frozen,
    calls: () => calls, activations: () => activations, creations: () => creations,
    sent: () => sent, created: () => created};
}

test("Sales preparation defaults disabled before activation, factory or cache", async () => {
  const f = fixture({enabled: false});
  await assert.rejects(f.adapter.run(f.request()), {code: "MODEL_DISABLED"});
  assert.equal(f.activations(), 0); assert.equal(f.creations(), 0); assert.equal(f.records.size, 0);
  await assert.rejects(createSalesPreparationAdapter().run({}), {code: "MODEL_DISABLED"});
});

for (const providerId of ["deepseek", "openai", "anthropic"]) {
  test(`${providerId}: named factory receives independent prompt, exact limits and public alias DTO`, async () => {
    const f = fixture({providerId});
    const result = await f.adapter.run(f.request());
    assert.equal(f.created().modelId, `${providerId}-fixture`);
    assert.equal(f.created().promptVersion, "writing-v1");
    assert.equal(f.created().maxAttempts, 1); assert.equal(f.created().maxNetworkRequests, 1);
    assert.equal(f.created().maxCostMicros, 1000);
    assert.deepEqual(f.sent().input.options.map((option) => option.alias), ["option_0", "option_1", "option_2"]);
    assert.doesNotMatch(JSON.stringify(f.sent()), /private-|crmNotes|guestList|fixture@example/);
    assert.equal(result.selection.organizerId, "private-organizer");
    assert.equal(result.selection.observationId, "private-observation");
    assert.equal(result.selection.capabilityId, "private-capability");
    assert.equal(result.selection.ctaId, "private-cta");
    assert.equal(result.sendAuthority, false);
    assert.equal(result.provenance.metadata.costBasis, "reserved_ceiling");
    const cached = await f.adapter.run(f.request());
    assert.equal(cached.provenance.cacheHit, true); assert.equal(f.calls(), 1);
    assert.ok(f.activations() >= 2);
  });
}

test("research exposes text aliases only, restores source bindings, remains an unverified proposal", async () => {
  const f = fixture({output: research});
  const result = await f.adapter.run(f.request("research"));
  assert.equal(f.created().promptVersion, "research-v1");
  assert.deepEqual(f.sent().input, {sources: [{alias: "source_0", text: source.text}]});
  assert.doesNotMatch(JSON.stringify(f.sent()), /private-|crmNotes|guestList|capturedAt|example.com/);
  assert.deepEqual(result.proposal.facts[0].sourceIds, [source.sourceId]);
  assert.equal(result.proposal.workflowComparison.visibleTools[0].sourceId, source.sourceId);
  assert.equal(result.verifiedEvidence, false); assert.equal(result.qualificationAuthority, false);
  assert.equal(result.sendAuthority, false);
});

test("unclassified/private captures or unapproved clauses fail before authorization and I/O", async () => {
  for (const stage of ["research", "writing"]) {
    const f = fixture(); const request = f.request(stage);
    (stage === "research" ? request.publicSources[0] : request.publicClauses[0]).dataClassification = "private";
    await assert.rejects(f.adapter.run(request), {code: "SALES_PUBLIC_INPUT_INVALID"});
    assert.equal(f.activations(), 0); assert.equal(f.calls(), 0);
  }
  const f = fixture(); const request = f.request(); request.publicClauses[0].approved = false;
  await assert.rejects(f.adapter.run(request), {code: "SALES_PUBLIC_INPUT_INVALID"});
});

test("stale policy, expired authorization, inactive mode and unknown provider never fall back", async () => {
  const stale = fixture(); const request = stale.request(); request.currentPolicy = {...stale.policy, revision: 2};
  await assert.rejects(stale.adapter.run(request), {code: "SALES_PREPARATION_POLICY_STALE"});
  assert.equal(stale.calls(), 0);
  const expired = fixture({activationPort: {current: async (binding) => ({...binding, status: "active",
    authorizationId: "expired", expiresAt: "2020-01-01T00:00:00.000Z"})}});
  await assert.rejects(expired.adapter.run(expired.request()), {code: "SALES_API_INACTIVE"});
  assert.equal(expired.creations(), 0);
  const inactive = fixture();
  inactive.policy.writing = {...inactive.policy.writing, executionMode: "deterministic",
    providerId: null, modelId: null, billingSourceId: null,
    budget: Object.fromEntries(Object.keys(stageBudget).map((key) => [key, 0]))};
  const inactiveRequest = inactive.request(); inactiveRequest.frozen = freezeSalesPreparationPolicy(inactive.policy);
  await assert.rejects(inactive.adapter.run(inactiveRequest), {code: "SALES_PROVIDER_STAGE_INACTIVE"});
  assert.equal(inactive.creations(), 0);
  const unsupported = fixture({providerId: "other"});
  await assert.rejects(unsupported.adapter.run(unsupported.request()), {code: "MODEL_CAPABILITY_UNSUPPORTED"});
  assert.equal(unsupported.creations(), 0);
});

test("full canonical constraints and grounded aliases validate before cache or reconciliation", async () => {
  for (const output of [
    {...writing, observationAlias: "invented"},
    {...writing, observationAlias: "option_1"},
    {...writing, reasonToBlock: "x".repeat(201)},
    {...writing, omittedAliases: ["option_0", "option_0"]},
  ]) {
    const f = fixture({output}); await assert.rejects(f.adapter.run(f.request()));
    assert.equal(f.records.size, 0);
    assert.equal(f.monthlyBudget.snapshot().consumed.modelInputTokens, 100);
  }
  for (const output of [
    {...research, facts: [{...research.facts[0], sourceAliases: ["invented"]}]},
    {...research, facts: [{...research.facts[0], value: "Unsupported claim"}]},
    {...research, facts: [{...research.facts[0], rationale: "x".repeat(1001)}]},
  ]) {
    const f = fixture({output}); await assert.rejects(f.adapter.run(f.request("research")));
    assert.equal(f.records.size, 0);
    assert.equal(f.monthlyBudget.snapshot().consumed.modelCostMicros, 1000);
  }
});

test("prompt/policy changes isolate caches even when version and public options are unchanged", async () => {
  const f = fixture(); const first = await f.adapter.run(f.request());
  f.policy.writing.prompt = "Changed reviewed public JSON prompt";
  const next = f.request(); next.frozen = freezeSalesPreparationPolicy(f.policy);
  const second = await f.adapter.run(next);
  assert.notEqual(second.provenance.cacheKey, first.provenance.cacheKey); assert.equal(f.calls(), 2);
});

test("current authority is rechecked before cached proposals are returned", async () => {
  let active = true;
  const f = fixture({activationPort: {current: async (binding) => ({...binding,
    status: active ? "active" : "inactive", authorizationId: "fixture-auth",
    expiresAt: "2026-10-08T00:00:00.000Z"})}});
  await f.adapter.run(f.request()); active = false;
  await assert.rejects(f.adapter.run(f.request()), {code: "SALES_API_INACTIVE"});
  assert.equal(f.calls(), 1);
});

test("monthly network/token budgets and explicit estimate fail before provider invocation", async () => {
  for (const dimension of ["networkRequests", "modelInputTokens"]) {
    const f = fixture({monthlyBudget: new BudgetLedger({limits: {...stageBudget, [dimension]: 0}})});
    await assert.rejects(f.adapter.run(f.request()), {code: "BUDGET_EXCEEDED"}); assert.equal(f.calls(), 0);
  }
  const f = fixture(); const request = f.request(); delete request.estimatedInputTokens;
  await assert.rejects(f.adapter.run(request), {code: "MODEL_BUDGET_ESTIMATE_REQUIRED"});
  assert.equal(f.creations(), 0);
});

test("cancellation and unknown outcomes retain spending without another provider call", async () => {
  let calls = 0;
  const controller = new AbortController();
  const f = fixture({factories: {createDeepSeekProvider: () => ({run: async () => {
    calls++; controller.abort("fixture-private-reason"); return new Promise(() => {});
  }}), createOpenAIProvider: () => assert.fail("no fallback"),
  createAnthropicProvider: () => assert.fail("no fallback")}});
  await assert.rejects(f.adapter.run({...f.request(), signal: controller.signal}), {code: "MODEL_PROVIDER_CANCELLED"});
  assert.equal(calls, 1); assert.equal(f.records.size, 0);
  assert.equal(f.monthlyBudget.snapshot().consumed.modelCostMicros, 1000);
  assert.equal(f.monthlyBudget.snapshot().consumed.networkRequests, 1);
});

test("authority expiring during cache waits prevents spending and cached replay", async () => {
  for (const cached of [false, true]) {
    let now = new Date("2026-10-07T13:00:00.000Z");
    const seed = fixture();
    const seedResult = cached ? await seed.adapter.run(seed.request()) : null;
    const f = fixture({clock: () => now, cache: {
      get: async () => {now = new Date("2026-10-09T00:00:00.000Z");
        return seedResult ? seed.records.get(seedResult.provenance.cacheKey) : null;},
      put: async () => assert.fail("expired result must not be cached"),
    }});
    await assert.rejects(f.adapter.run(f.request()), {code: "SALES_API_INACTIVE"});
    assert.equal(f.calls(), 0); assert.equal(f.monthlyBudget.snapshot().consumed.modelCalls, 0);
  }
});

test("current UTC month is required initially and after asynchronous cache waits", async () => {
  const stale = fixture({monthlyWindow: "2026-09"});
  await assert.rejects(stale.adapter.run(stale.request()), {code: "MODEL_MONTHLY_WINDOW_REQUIRED"});
  assert.equal(stale.calls(), 0);
  let now = new Date("2026-10-31T23:59:59.000Z");
  const f = fixture({clock: () => now,
    activationPort: {current: async (binding) => ({...binding, status: "active",
      authorizationId: "fixture-auth", expiresAt: "2026-12-01T00:00:00.000Z"})},
    cache: {get: async () => {now = new Date("2026-11-01T00:00:00.000Z"); return null;}, put: async () => {}}});
  await assert.rejects(f.adapter.run(f.request()), {code: "MODEL_MONTHLY_WINDOW_REQUIRED"});
  assert.equal(f.calls(), 0); assert.equal(f.monthlyBudget.snapshot().consumed.networkRequests, 0);
});

test("live public field getters reject before authorization without exposing their values", async () => {
  for (const [stage, key] of [["writing", "text"], ["research", "url"], ["research", "text"]]) {
    const f = fixture(); const request = f.request(stage);
    const row = stage === "writing" ? request.publicClauses[0] : request.publicSources[0];
    let reads = 0;
    Object.defineProperty(row, key, {get: () => {reads++; return "private-getter-value";}});
    await assert.rejects(f.adapter.run(request), (error) => {
      assert.equal(error.code, "SALES_PUBLIC_INPUT_INVALID");
      assert.doesNotMatch(JSON.stringify(error), /private-getter-value/); return true;
    });
    assert.equal(reads, 0); assert.equal(f.activations(), 0); assert.equal(f.calls(), 0);
  }
});

test("activation read exceptions are redacted without secrets, raw causes or fallback", async () => {
  const f = fixture({activationPort: {current: async () => {throw new Error("private-activation-token");}}});
  await assert.rejects(f.adapter.run(f.request()), (error) => {
    assert.equal(error.code, "SALES_API_INACTIVE"); assert.equal(error.cause, undefined);
    assert.doesNotMatch(JSON.stringify(error), /private-activation-token/); return true;
  });
  assert.equal(f.calls(), 0); assert.equal(f.creations(), 0);
});

test("unblocked writing requires observation, capability and CTA before caching", async () => {
  for (const output of [
    {...writing, observationAlias: null}, {...writing, capabilityAlias: null},
    {...writing, ctaAlias: null}, {...writing, reasonToBlock: "   "},
  ]) {
    const f = fixture({output});
    await assert.rejects(f.adapter.run(f.request()), {code: "SALES_SELECTION_INVALID"});
    assert.equal(f.records.size, 0); assert.equal(f.monthlyBudget.snapshot().consumed.modelInputTokens, 100);
  }
  const f = fixture({output: {...writing, observationAlias: null, capabilityAlias: null,
    ctaAlias: null, reasonToBlock: "Missing reviewed clauses."}});
  assert.equal((await f.adapter.run(f.request())).selection.reasonToBlock, "Missing reviewed clauses.");
});
