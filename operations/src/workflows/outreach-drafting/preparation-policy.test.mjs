import assert from "node:assert/strict";
import test from "node:test";
import {authorizePreparationStage, freezeSalesPreparationPolicy} from "./preparation-policy.mjs";
const now = "2026-10-04T12:00:00.000Z";
const budget = {modelCalls: 0, modelInputTokens: 0, modelOutputTokens: 0,
  modelCostMicros: 0, networkRequests: 0};
function policy() {
  const config = {executionMode: "deterministic", providerId: null, modelId: null,
    promptVersion: "v1", prompt: "Use only current approved sources.", budget,
    billingSourceId: null, fallback: "disabled"};
  return structuredClone({schemaVersion: 1, revision: 1, research: config,
    writing: {...config, prompt: "Write an approachable private message for human review."}});
}
function apiPolicy() {
  const p = policy();
  p.writing = {...p.writing, executionMode: "api", providerId: "writing-provider",
    modelId: "approachable-model", billingSourceId: "owner-billing-source",
    budget: {modelCalls: 1, modelInputTokens: 4000, modelOutputTokens: 500,
      modelCostMicros: 10000, networkRequests: 0}};
  return p;
}
test("research and approachable writing configuration are independently frozen", () => {
  const first = freezeSalesPreparationPolicy(policy());
  const changed = policy(); changed.writing.promptVersion = "v2";
  const second = freezeSalesPreparationPolicy(changed);
  assert.equal(first.stageHashes.research, second.stageHashes.research);
  assert.notEqual(first.stageHashes.writing, second.stageHashes.writing);
  assert.notEqual(first.policyHash, second.policyHash);
});
test("deterministic execution grants no provider or fallback authority", async () => {
  const p = policy(); const frozen = freezeSalesPreparationPolicy(p);
  const result = await authorizePreparationStage({frozen, stage: "writing", currentPolicy: p, clock: () => now});
  assert.equal(result.providerAuthority, false); assert.equal(result.fallbackAuthority, false);
  const bad = policy(); bad.research.budget.modelCalls = 1;
  assert.throws(() => freezeSalesPreparationPolicy(bad), {code: "SALES_DETERMINISTIC_POLICY_INVALID"});
});
test("API configuration remains inactive without an exact current billing authorization", async () => {
  const p = apiPolicy(); const frozen = freezeSalesPreparationPolicy(p);
  await assert.rejects(authorizePreparationStage({frozen, stage: "writing", currentPolicy: p,
    ownerUid: "owner", clock: () => now}), {code: "SALES_API_INACTIVE"});
  const active = {ownerUid: "owner", stage: "writing", policyHash: frozen.policyHash,
    stageHash: frozen.stageHashes.writing, billingSourceId: p.writing.billingSourceId,
    status: "active", authorizationId: "reviewed-decision", expiresAt: "2026-10-05T00:00:00.000Z"};
  for (const altered of [{...active, ownerUid: "other"}, {...active, stage: "research"},
    {...active, billingSourceId: "other"}, {...active, expiresAt: now},
    {...active, stageHash: "stale"}, {...active, status: "inactive"}]) {
    await assert.rejects(authorizePreparationStage({frozen, stage: "writing", currentPolicy: p,
      ownerUid: "owner", clock: () => now, activationPort: {current: async () => altered}}), {code: "SALES_API_INACTIVE"});
  }
  const result = await authorizePreparationStage({frozen, stage: "writing", currentPolicy: p,
    ownerUid: "owner", clock: () => now, activationPort: {current: async () => active}});
  assert.equal(result.fallbackAuthority, false);
});
test("source policy drift and mutated frozen input reject resume", async () => {
  const p = policy(); const frozen = freezeSalesPreparationPolicy(p);
  const changed = policy(); changed.revision++;
  await assert.rejects(authorizePreparationStage({frozen, stage: "research", currentPolicy: changed, clock: () => now}),
    {code: "SALES_PREPARATION_POLICY_STALE"});
  frozen.policy.research.prompt = "Changed";
  await assert.rejects(authorizePreparationStage({frozen, stage: "research", currentPolicy: p, clock: () => now}),
    {code: "SALES_PREPARATION_POLICY_DRIFT"});
});

test("authorization keeps the validated snapshot when caller-owned configuration mutates during the port wait", async () => {
  const p = apiPolicy(); const frozen = freezeSalesPreparationPolicy(p);
  let complete;
  const decision = {ownerUid: "owner", stage: "writing", policyHash: frozen.policyHash,
    stageHash: frozen.stageHashes.writing, billingSourceId: p.writing.billingSourceId,
    status: "active", authorizationId: "reviewed-decision", expiresAt: "2026-10-05T00:00:00.000Z"};
  const pending = authorizePreparationStage({frozen, stage: "writing", currentPolicy: p,
    ownerUid: "owner", clock: () => now, activationPort: {current: () => new Promise((resolve) => {complete = resolve;})}});
  frozen.policy.writing.modelId = "changed-model";
  frozen.policy.writing.budget.modelCostMicros = 999999;
  frozen.stageHashes.writing = "changed";
  complete(decision);
  const result = await pending;
  assert.equal(result.config.modelId, p.writing.modelId);
  assert.equal(result.config.budget.modelCostMicros, 10000);
});

test("activation expiring during a port wait cannot authorize a provider attempt", async () => {
  const p = apiPolicy(); const frozen = freezeSalesPreparationPolicy(p);
  let complete; let at = now;
  const decision = {ownerUid: "owner", stage: "writing", policyHash: frozen.policyHash,
    stageHash: frozen.stageHashes.writing, billingSourceId: p.writing.billingSourceId,
    status: "active", authorizationId: "reviewed-decision", expiresAt: "2026-10-05T00:00:00.000Z"};
  const pending = authorizePreparationStage({frozen, stage: "writing", currentPolicy: p,
    ownerUid: "owner", clock: () => at,
    activationPort: {current: () => new Promise((resolve) => {complete = resolve;})}});
  at = decision.expiresAt;
  complete(decision);
  await assert.rejects(pending, {code: "SALES_API_INACTIVE"});
});
