import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import {test} from "node:test";
import {OperationsEngine} from "../src/platform/engine.mjs";
import {FileOperationsStore} from "../src/platform/storage/file-store.mjs";
import {hashValue} from "../src/platform/canonical-json.mjs";
import {BudgetLedger} from "../src/platform/budget.mjs";
import {OutreachDraftingWorkflow} from "../src/workflows/outreach-drafting/workflow.mjs";

const at = "2026-09-28T10:00:00.000Z";
function memoryMonthPort(initial) {
  let state = initial;
  const attempts = new Map();
  return {
    snapshot: () => state,
    reserveAttempt: async ({attemptId, monthKey, limitsHash,
      expectedConsumed, reservation}) => {
      assert.equal(monthKey, "2026-09");
      assert.equal(limitsHash, hashValue(state.limits));
      if (hashValue(expectedConsumed) !== hashValue(state.consumed)) {
        throw Object.assign(new Error("stale monthly balance"),
          {code: "MONTHLY_BUDGET_STALE"});
      }
      if (attempts.has(attemptId)) throw new Error("duplicate attempt");
      const ledger = new BudgetLedger({limits: state.limits,
        consumed: state.consumed});
      ledger.reserve(reservation);
      state = ledger.snapshot();
      attempts.set(attemptId, reservation);
    },
    completeAttempt: async ({attemptId, monthKey, usage}) => {
      assert.equal(monthKey, "2026-09");
      const reservation = attempts.get(attemptId);
      assert(reservation);
      const ledger = new BudgetLedger({limits: state.limits,
        consumed: state.consumed});
      ledger.reconcileReservation(reservation,
        {modelCalls: 1, modelInputTokens: usage.inputTokens,
          modelOutputTokens: usage.outputTokens,
          modelCostMicros: usage.costMicros});
      state = ledger.snapshot();
    },
  };
}
function input() {
  return {schemaVersion: 1,
    organizer: {organizerId: "org-1", name: "Example Collective", revision: 2,
      identityStatus: "verified"},
    contact: {contactId: "contact-1", revision: 3, role: "organizer",
      eligibility: "eligible", suppressionStatus: "clear", claimStatus: "verified"},
    opportunity: {opportunityId: "opp-1", revision: 4, stage: "qualified",
      motion: "first_pilot"},
    language: "en", channel: "email", purpose: "first_message", evaluatedAt: at,
    evidenceConflictStatus: "clear",
    policy: {promptVersion: "selection-v1", playbookVersion: "reviewed-v1",
      modelId: "disabled"},
    observations: [{id: "obs-1", text: "Your next event is scheduled for October.",
      revision: 5, organizerId: "org-1", approved: true,
      validUntil: "2026-11-01T00:00:00.000Z"}],
    capabilities: [{id: "cap-1", text: "Catch can collect applications for review.",
      revision: 6, organizerId: "org-1", approved: true,
      validUntil: "2026-11-01T00:00:00.000Z"}],
    references: [],
    ctas: [{id: "cta-1", text: "Would a short walkthrough be useful?", revision: 1}],
    priorInteraction: null};
}
function current(snapshot = input()) {
  return {organizerId: snapshot.organizer.organizerId,
    organizerRevision: snapshot.organizer.revision,
    contactId: snapshot.contact.contactId,
    contactRevision: snapshot.contact.revision,
    opportunityId: snapshot.opportunity.opportunityId,
    opportunityRevision: snapshot.opportunity.revision,
    stage: snapshot.opportunity.stage, identityStatus: "verified",
    evidenceConflictStatus: snapshot.evidenceConflictStatus,
    promptVersion: snapshot.policy.promptVersion,
    playbookVersion: snapshot.policy.playbookVersion,
    contactEligible: true, suppressed: false, capabilityClaimsEligible: true,
    approvedClauseRevisions: Object.fromEntries([
      ...snapshot.observations, ...snapshot.capabilities,
      ...snapshot.references].map((row) => [row.id, row.revision])),
    approvedCtaRevisions: Object.fromEntries(snapshot.ctas.map(
      (row) => [row.id, row.revision])),
    priorInteractionRevision: snapshot.priorInteraction?.revision ?? null,
    supportedCapabilityIds: snapshot.capabilities.map((row) => row.id),
    permittedReferenceIds: snapshot.references.map((row) => row.id)};
}
async function fixture(options = {}) {
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), "outreach-draft-"));
  const store = await new FileOperationsStore(directory).initialize();
  const snapshot = input();
  const live = current(snapshot);
  const eligibilityPort = {getCurrent: async () => ({...live})};
  const workflow = new OutreachDraftingWorkflow({store, eligibilityPort,
    clock: () => new Date(at), ...options});
  const engine = new OperationsEngine({store, workflow,
    clock: () => new Date(at), leaseClock: () => new Date(), workerId: "test-worker"});
  return {directory, store, snapshot, live, eligibilityPort, workflow, engine};
}

test("registered engine persists a private draft, replay and exact-text approval receipt", async (t) => {
  const f = await fixture();
  t.after(() => fs.rm(f.directory, {recursive: true, force: true}));
  const plan = f.workflow.createPlan({inputs: [f.snapshot], now: at});
  assert.equal(plan.capabilities.modelCalls, false);
  assert.equal(plan.budgets.modelCalls, 0);
  const first = await f.engine.start(plan);
  assert.equal(first.run.status, "completed");
  const [item] = await f.store.listWorkItems({runId: first.run.runId});
  assert.equal(item.primaryStage, "human_review");
  const draft = item.decisionProvenance.draft;
  assert.equal(draft.text, [f.snapshot.observations[0].text,
    f.snapshot.capabilities[0].text, f.snapshot.ctas[0].text].join("\n\n"));
  assert.deepEqual(draft.sentences[0].sourceIds, ["obs-1"]);
  assert.equal(draft.sendAuthority, false);
  assert.equal(draft.contentHash, hashValue({subject: draft.subject, text: draft.text}));
  const replay = await f.engine.start(plan);
  assert.equal(replay.idempotentReplay, true);
  const receipt = await f.workflow.approveDraft({runId: first.run.runId,
    workItemId: item.workItemId, actorId: "reviewer-1",
    expectedContentHash: draft.contentHash,
    factualValidity: "verified", tone: "approved",
    channelReadiness: "manual_copy_only"});
  assert.equal(receipt.payload.exactContentHash, draft.contentHash);
  assert.equal(receipt.payload.sendAuthority, false);
  await assert.rejects(f.workflow.approveDraft({runId: first.run.runId,
    workItemId: item.workItemId, actorId: "reviewer-2",
    expectedContentHash: draft.contentHash,
    factualValidity: "unchecked", tone: "approved",
    channelReadiness: "manual_copy_only"}),
  {code: "INVALID_OUTREACH_APPROVAL"});
  const again = await f.workflow.approveDraft({runId: first.run.runId,
    workItemId: item.workItemId, actorId: "reviewer-1",
    expectedContentHash: draft.contentHash,
    factualValidity: "verified", tone: "approved",
    channelReadiness: "manual_copy_only"});
  assert.deepEqual(again, receipt);
  await assert.rejects(f.workflow.approveDraft({runId: first.run.runId,
    workItemId: item.workItemId, actorId: "reviewer-1",
    expectedContentHash: "0".repeat(64),
    factualValidity: "verified", tone: "approved",
    channelReadiness: "manual_copy_only"}), {code: "OUTREACH_DRAFT_CHANGED"});
  f.live.suppressed = true;
  await assert.rejects(f.workflow.approveDraft({runId: first.run.runId,
    workItemId: item.workItemId, actorId: "reviewer-2",
    expectedContentHash: draft.contentHash,
    factualValidity: "verified", tone: "approved",
    channelReadiness: "manual_copy_only"}),
  {code: "OUTREACH_CURRENT_ELIGIBILITY_CHANGED"});
});

test("sparse evidence blocks drafting and stale contact fails before cache", async (t) => {
  const f = await fixture();
  t.after(() => fs.rm(f.directory, {recursive: true, force: true}));
  f.snapshot.observations = [];
  const plan = f.workflow.createPlan({inputs: [f.snapshot], now: at});
  const result = await f.engine.start(plan);
  const [item] = await f.store.listWorkItems({runId: result.run.runId});
  assert.equal(item.primaryStage, "blocked");
  assert.deepEqual(item.blockers, ["research_needed"]);
  f.live.contactRevision = 8;
  await assert.rejects(f.workflow.review(item, {now: at}),
    {code: "OUTREACH_CURRENT_ELIGIBILITY_CHANGED"});
});

test("unknown model clauses and target changes are rejected without rendering", async (t) => {
  const f = await fixture();
  t.after(() => fs.rm(f.directory, {recursive: true, force: true}));
  const eligible = {observations: f.snapshot.observations,
    capabilities: f.snapshot.capabilities, references: []};
  const base = {organizerId: "org-1", contactId: "contact-1",
    opportunityId: "opp-1", language: "en", observationId: "obs-1",
    capabilityId: "cap-1", referenceId: null, ctaId: "cta-1",
    reasonToBlock: null, omittedIds: []};
  assert.throws(() => f.workflow.assertSelection(f.snapshot,
    {...base, observationId: "unknown"}, eligible), {code: "OUTREACH_UNKNOWN_CLAUSE"});
  assert.throws(() => f.workflow.assertSelection(f.snapshot,
    {...base, contactId: "other"}, eligible), {code: "OUTREACH_TARGET_MISMATCH"});
  assert.throws(() => f.workflow.assertSelection(f.snapshot,
    {...base, inventedText: "Unsupported claim"}, eligible),
  {code: "INVALID_OUTREACH_SELECTION"});
  assert.throws(() => f.workflow.assertSelection(f.snapshot,
    {...base, language: "hi"}, eligible), {code: "INVALID_OUTREACH_SELECTION"});
});

test("input validation rejects invented evidence, unrelated identity and fake follow-up", async (t) => {
  const f = await fixture();
  t.after(() => fs.rm(f.directory, {recursive: true, force: true}));
  assert.throws(() => f.workflow.assertInput({...f.snapshot, extra: "secret"}),
    {code: "INVALID_OUTREACH_INPUT"});
  assert.throws(() => f.workflow.assertInput({...f.snapshot,
    observations: [{...f.snapshot.observations[0], organizerId: "other"}]}),
  {code: "OUTREACH_TARGET_MISMATCH"});
  assert.throws(() => f.workflow.assertInput({...f.snapshot, purpose: "follow_up"}),
    {code: "OUTREACH_PRIOR_INTERACTION_REQUIRED"});
});

test("guarded model chooses only approved IDs and records usage in the durable run", async (t) => {
  let calls = 0;
  const provider = {run: async ({input: request}) => {
    calls += 1;
    assert.equal(request.inputHash.length, 64);
    assert.equal(request.playbookVersion, "reviewed-v1");
    return {output: {organizerId: request.organizerId,
      contactId: request.contactId, opportunityId: request.opportunityId,
      language: request.language, observationId: "obs-1",
      capabilityId: "cap-1", referenceId: null, ctaId: "cta-1",
      reasonToBlock: null, omittedIds: []},
    usage: {inputTokens: 12, outputTokens: 8, costMicros: 40}};
  }};
  const monthlyBudget = new BudgetLedger({limits: {modelCalls: 10,
    modelInputTokens: 1000, modelOutputTokens: 1000, modelCostMicros: 1000}});
  const f = await fixture({modelActivation: {reviewed: true, policyDecisionId: "synthetic-reviewed-policy",
    modelId: "synthetic-model",
    estimatedInputTokens: 100, maxOutputTokens: 50, maxCostMicros: 100},
  modelProvider: provider, monthlyBudget,
  monthlyBudgetPort: memoryMonthPort(monthlyBudget.snapshot()),
  monthlyWindow: "2026-09"});
  t.after(() => fs.rm(f.directory, {recursive: true, force: true}));
  f.snapshot.policy.modelId = "synthetic-model";
  const plan = f.workflow.createPlan({inputs: [f.snapshot], now: at});
  assert.equal(plan.capabilities.modelCalls, true);
  assert.equal(plan.budgets.modelCalls, 1);
  const result = await f.engine.start(plan);
  assert.equal(result.run.budget.consumed.modelCalls, 1);
  assert.equal(result.run.budget.consumed.modelCostMicros, 40);
  const [item] = await f.store.listWorkItems({runId: result.run.runId});
  assert.equal(item.decisionProvenance.draft.model.modelId, "synthetic-model");
  assert.equal(item.decisionProvenance.draft.text.includes("synthetic-model"), false);
  assert.equal(calls, 1);
  await f.engine.start(plan);
  assert.equal(calls, 1);
});

test("cached model output cannot bypass changed contact eligibility", async (t) => {
  let calls = 0;
  const provider = {run: async ({input: request}) => {
    calls += 1;
    return {output: {organizerId: request.organizerId,
      contactId: request.contactId, opportunityId: request.opportunityId,
      language: request.language, observationId: "obs-1",
      capabilityId: "cap-1", referenceId: null, ctaId: "cta-1",
      reasonToBlock: null, omittedIds: []},
    usage: {inputTokens: 12, outputTokens: 8, costMicros: 40}};
  }};
  const monthlyBudget = new BudgetLedger({limits: {modelCalls: 10,
    modelInputTokens: 1000, modelOutputTokens: 1000, modelCostMicros: 1000}});
  const f = await fixture({modelActivation: {reviewed: true, policyDecisionId: "synthetic-reviewed-policy",
    modelId: "synthetic-model",
    estimatedInputTokens: 100, maxOutputTokens: 50, maxCostMicros: 100},
  modelProvider: provider, monthlyBudget,
  monthlyBudgetPort: memoryMonthPort(monthlyBudget.snapshot()),
  monthlyWindow: "2026-09"});
  t.after(() => fs.rm(f.directory, {recursive: true, force: true}));
  f.snapshot.policy.modelId = "synthetic-model";
  const plan = f.workflow.createPlan({inputs: [f.snapshot], now: at});
  const result = await f.engine.start(plan);
  const [item] = await f.store.listWorkItems({runId: result.run.runId});
  f.live.contactRevision += 1;
  await assert.rejects(f.workflow.review(item, {now: at,
    budget: new BudgetLedger({limits: plan.budgets})}),
  {code: "OUTREACH_CURRENT_ELIGIBILITY_CHANGED"});
  assert.equal(calls, 1);
});

test("known contradictory evidence requires research review", async (t) => {
  const f = await fixture();
  t.after(() => fs.rm(f.directory, {recursive: true, force: true}));
  f.snapshot.evidenceConflictStatus = "needs_review";
  f.live.evidenceConflictStatus = "needs_review";
  const result = await f.engine.start(f.workflow.createPlan({inputs: [f.snapshot], now: at}));
  const [item] = await f.store.listWorkItems({runId: result.run.runId});
  assert.equal(item.primaryStage, "blocked");
  assert.deepEqual(item.blockers, ["conflicting_evidence_review_needed"]);
});

test("uncertain provider outcome preserves reservation and blocks replay after restart", async (t) => {
  let calls = 0;
  const monthlyBudget = new BudgetLedger({limits: {modelCalls: 10,
    modelInputTokens: 1000, modelOutputTokens: 1000, modelCostMicros: 1000}});
  const activation = {reviewed: true, policyDecisionId: "synthetic-reviewed-policy",
    modelId: "synthetic-model", estimatedInputTokens: 100,
    maxOutputTokens: 50, maxCostMicros: 100};
  const provider = {run: async () => {
    calls += 1;
    throw new Error("synthetic provider timeout");
  }};
  const monthlyBudgetPort = memoryMonthPort(monthlyBudget.snapshot());
  const f = await fixture({modelActivation: activation, modelProvider: provider,
    monthlyBudget, monthlyWindow: "2026-09", monthlyBudgetPort});
  t.after(() => fs.rm(f.directory, {recursive: true, force: true}));
  f.snapshot.policy.modelId = "synthetic-model";
  const plan = f.workflow.createPlan({inputs: [f.snapshot], now: at});
  await assert.rejects(f.engine.start(plan), /synthetic provider timeout/);
  const runId = `run-${plan.planId}`;
  const failed = await f.store.requireRun(runId);
  assert.equal(failed.status, "failed");
  assert.equal(failed.budget.consumed.modelCalls, 1);
  assert.equal(monthlyBudgetPort.snapshot().consumed.modelCalls, 1);
  const actions = await f.store.listActions(runId);
  assert(actions.some((action) => action.type === "outreach.model_attempt_reserved"));
  assert(actions.some((action) => action.type === "outreach.model_attempt_indeterminate"));
  const restoredMonth = new BudgetLedger({
    limits: monthlyBudgetPort.snapshot().limits,
    consumed: monthlyBudgetPort.snapshot().consumed});
  const restartedWorkflow = new OutreachDraftingWorkflow({store: f.store,
    eligibilityPort: f.eligibilityPort, modelActivation: activation,
    modelProvider: provider, monthlyBudget: restoredMonth,
    monthlyWindow: "2026-09", clock: () => new Date(at),
    monthlyBudgetPort});
  const restartedEngine = new OperationsEngine({store: f.store,
    workflow: restartedWorkflow, clock: () => new Date(at),
    leaseClock: () => new Date(), workerId: "restarted-worker"});
  await assert.rejects(restartedEngine.resume(runId, plan),
    {code: "OUTREACH_MODEL_ATTEMPT_UNCERTAIN"});
  assert.equal(calls, 1);
});

test("stale parallel monthly reservation rejects the losing run before provider I/O", async (t) => {
  let providerCalls = 0;
  const provider = {run: async ({input: request}) => {
    providerCalls += 1;
    return {output: {organizerId: request.organizerId,
      contactId: request.contactId, opportunityId: request.opportunityId,
      language: request.language, observationId: "obs-1",
      capabilityId: "cap-1", referenceId: null, ctaId: "cta-1",
      reasonToBlock: null, omittedIds: []},
    usage: {inputTokens: 12, outputTokens: 8, costMicros: 40}};
  }};
  const limits = {modelCalls: 10, modelInputTokens: 1000,
    modelOutputTokens: 1000, modelCostMicros: 1000};
  const monthlyBudgetPort = memoryMonthPort(new BudgetLedger({limits}).snapshot());
  const activation = {reviewed: true, policyDecisionId: "synthetic-reviewed-policy",
    modelId: "synthetic-model", estimatedInputTokens: 100,
    maxOutputTokens: 50, maxCostMicros: 100};
  const make = () => fixture({modelActivation: activation, modelProvider: provider,
    monthlyBudget: new BudgetLedger({limits}), monthlyBudgetPort,
    monthlyWindow: "2026-09"});
  const first = await make();
  const second = await make();
  t.after(async () => {
    await fs.rm(first.directory, {recursive: true, force: true});
    await fs.rm(second.directory, {recursive: true, force: true});
  });
  first.snapshot.policy.modelId = "synthetic-model";
  second.snapshot.policy.modelId = "synthetic-model";
  second.snapshot.contact.contactId = "contact-2";
  second.live.contactId = "contact-2";
  const firstPlan = first.workflow.createPlan({inputs: [first.snapshot], now: at});
  const secondPlan = second.workflow.createPlan({inputs: [second.snapshot], now: at});
  await first.engine.start(firstPlan);
  await assert.rejects(second.engine.start(secondPlan),
    {code: "MONTHLY_BUDGET_STALE"});
  assert.equal(providerCalls, 1);
  assert.equal(monthlyBudgetPort.snapshot().consumed.modelCalls, 1);
  const losingRun = await second.store.requireRun(`run-${secondPlan.planId}`);
  assert.equal(losingRun.budget.consumed.modelCalls, 1);
});

test("planning rejects symlink and oversized input before reading", async (t) => {
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), "outreach-input-"));
  t.after(() => fs.rm(directory, {recursive: true, force: true}));
  const target = path.join(directory, "snapshot.json");
  const alias = path.join(directory, "alias.json");
  await fs.writeFile(target, "[]");
  await fs.symlink(target, alias);
  const workflow = new OutreachDraftingWorkflow();
  assert.throws(() => workflow.planningContext({inputPath: alias}),
    {code: "OUTREACH_INPUT_INVALID_FILE"});
  await fs.writeFile(target, "x".repeat(500_001));
  assert.throws(() => workflow.planningContext({inputPath: target}),
    {code: "OUTREACH_INPUT_INVALID_FILE"});
});

test("month rollover before reservation prevents provider I/O", async (t) => {
  let calls = 0;
  let ticks = 0;
  const limits = {modelCalls: 10, modelInputTokens: 1000,
    modelOutputTokens: 1000, modelCostMicros: 1000};
  const monthlyBudget = new BudgetLedger({limits});
  const monthlyBudgetPort = memoryMonthPort(monthlyBudget.snapshot());
  const f = await fixture({modelActivation: {reviewed: true,
    policyDecisionId: "synthetic-reviewed-policy", modelId: "synthetic-model",
    estimatedInputTokens: 100, maxOutputTokens: 50, maxCostMicros: 100},
  modelProvider: {run: async () => {calls += 1; throw new Error("should not call");}},
  monthlyBudget, monthlyBudgetPort, monthlyWindow: "2026-09",
  clock: () => new Date(ticks++ < 2 ? at : "2026-10-01T00:00:00.000Z")});
  t.after(() => fs.rm(f.directory, {recursive: true, force: true}));
  f.snapshot.policy.modelId = "synthetic-model";
  const plan = f.workflow.createPlan({inputs: [f.snapshot], now: at});
  await assert.rejects(f.engine.start(plan),
    {code: "OUTREACH_MONTHLY_BUDGET_REQUIRED"});
  assert.equal(calls, 0);
  assert.equal(monthlyBudgetPort.snapshot().consumed.modelCalls, 0);
});
