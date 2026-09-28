import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {OperationsEngine} from "../src/platform/engine.mjs";
import {hashValue} from "../src/platform/canonical-json.mjs";
import {FileOperationsStore} from "../src/platform/storage/file-store.mjs";
import {
  discoveryReviewBinding,
  readDiscoveryKnowledge,
} from "../src/workflows/supply-intake/discovery-knowledge.mjs";
import {finalizeSupplyInputSnapshot} from "../src/workflows/supply-intake/input-snapshot.mjs";
import {SupplyIntakeWorkflow} from "../src/workflows/supply-intake/workflow.mjs";
import {fixtureInputSnapshot} from "./helpers.mjs";

const NOW = "2026-09-28T00:00:00.000Z";
const MARKET = "indore";

function candidate(number) {
  const id = `candidate-${String(number).padStart(2, "0")}`;
  const url = `https://${id}.example/`;
  return {
    candidateId: id, batchId: "synthetic-batch", resultId: id, rank: number,
    query: "synthetic organizers",
    queryIntent: {activityKind: "organizer-discovery", entityHint: null, marketSlug: MARKET},
    observedAt: "2026-09-28", title: id, snippet: null,
    url, canonicalUrl: url, platform: "officialWebsite", surfaceKind: "website",
    normalizedKey: `domain:${id}.example`,
    suggestedSurface: {
      confidence: {city: "high", entityMatch: "medium", ownership: "low"},
      crawl: {eventDiscoveryStatus: "disabled", policy: "manualOnly", supportsEventExtraction: false},
      evidenceRefs: [], normalizedKey: `domain:${id}.example`, notes: "Synthetic only.",
      platform: "officialWebsite", role: "secondary", status: "candidate",
      surfaceId: `surface-${id}`, surfaceKind: "website", url,
    },
    existingEntityMatches: [], reviewAction: "verify_ownership_before_attach",
    diagnostics: [],
  };
}

async function setup(t, {reviewEvery = 25, count = 28} = {}) {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "discovery-engine-"));
  t.after(() => fs.rm(root, {recursive: true, force: true}));
  const base = await fixtureInputSnapshot(root, MARKET);
  const candidates = Array.from({length: count}, (_, index) => candidate(index));
  const snapshot = finalizeSupplyInputSnapshot({
    ...base, organizerSearchCandidates: candidates,
  });
  const decisions = candidates.map((source, index) => ({
    candidateId: source.candidateId,
    candidateInputHash: hashValue(source),
    identityKey: source.normalizedKey,
    segment: "synthetic-segment",
    disposition: index === 0 ? "rejected" :
      index === 1 ? "probable_duplicate" : "retained",
    decisionRevision: 1,
    reviewedBy: "synthetic-reviewer",
    reviewedAt: NOW,
    ...(index === 0 ? {reasonCode: "outside_scope"} : {}),
    ruleIds: ["synthetic-rule@1"],
    inputRefs: [`synthetic-input:${source.candidateId}`],
  }));
  const store = await new FileOperationsStore(root).initialize();
  const workflow = new SupplyIntakeWorkflow({
    store,
    inputSnapshotLoader: async () => snapshot,
  });
  const plan = await workflow.createPlan({
    market: MARKET, through: "2026-09-28", now: NOW,
    intakeScope: "organizer",
    discoveryGatePolicy: {schemaVersion: 1, enabled: true, reviewEvery, decisions},
  });
  const engine = new OperationsEngine({store, workflow, clock: () => new Date(NOW),
    workerId: "synthetic-worker"});
  return {root, store, workflow, engine, plan, snapshot, decisions};
}

function reviewReceipt(state) {
  return {
    decision: "continue",
    reviewRevision: state.pause.reviewRevision,
    candidateFingerprint: state.pause.candidateFingerprint,
    retainedCount: state.pause.retainedCount,
    ...discoveryReviewBinding(state),
    reviewerId: "synthetic-reviewer",
    inputRefs: ["synthetic-review"],
    precisionAudit: {outcome: "checked", inputRefs: ["synthetic-precision"]},
    leaderRecallAudit: {outcome: "checked", inputRefs: ["synthetic-recall"]},
    findings: [], changes: [],
  };
}

test("real projection stops at the 25th retained candidate and resumes only after exact review", async (t) => {
  const {root, store, workflow, engine, plan} = await setup(t);
  const first = await engine.start(plan);
  assert.equal(first.run.status, "paused");
  const workItems = await store.listWorkItems({runId: first.run.runId});
  assert.equal(workItems.length, 25);
  assert.equal(workItems.some((item) => item.sourceEntity.id === "candidate-27"), false);
  assert.deepEqual(
    Object.fromEntries(Object.entries(await store.getCheckpoint(first.run.runId,
      "project-artifacts")).filter(([key]) => ["completed", "nextIndex", "itemCount"].includes(key))),
    {completed: false, nextIndex: 27, itemCount: 25}
  );
  const state = await readDiscoveryKnowledge({store, market: MARKET});
  assert.equal(state.retainedCount, 25);
  assert.equal(state.batchRetained, 25);
  const replay = await engine.resume(first.run.runId, plan);
  assert.equal(replay.run.status, "paused");
  assert.equal((await readDiscoveryKnowledge({store, market: MARKET})).retainedCount, 25);
  assert.equal((await store.listWorkItems({runId: first.run.runId})).length, 25);
  const restartedStore = await new FileOperationsStore(root).initialize();
  const restartedWorkflow = new SupplyIntakeWorkflow({
    store: restartedStore, inputSnapshotLoader: async () => plan.inputSnapshot,
  });
  await restartedWorkflow.continueDiscoveryAfterReview({
    market: MARKET, receipt: reviewReceipt(state), now: NOW,
  });
  const restartedEngine = new OperationsEngine({store: restartedStore,
    workflow: restartedWorkflow, clock: () => new Date(NOW), workerId: "restarted-worker"});
  const completed = await restartedEngine.resume(first.run.runId, plan);
  assert.equal(completed.run.status, "completed");
  assert.equal((await restartedStore.listWorkItems({runId: first.run.runId})).length, 26);
  assert.equal((await readDiscoveryKnowledge({store: restartedStore, market: MARKET})).retainedCount, 26);
  assert.equal((await restartedStore.getCheckpoint(first.run.runId, "project-artifacts")).completed, true);
});

test("ledger write before work-item failure replays without double counting", async (t) => {
  const {root, store, workflow, plan} = await setup(t, {reviewEvery: 2, count: 5});
  const interruptedStore = Object.create(store);
  let failed = false;
  interruptedStore.putWorkItem = async (...args) => {
    if (!failed && args[0].sourceEntity.id === "candidate-04") {
      failed = true;
      throw new Error("synthetic boundary crash");
    }
    return store.putWorkItem(...args);
  };
  const interrupted = new OperationsEngine({store: interruptedStore, workflow,
    clock: () => new Date(NOW), workerId: "crashing-worker"});
  const first = await interrupted.start(plan);
  assert.equal(first.run.status, "paused");
  await workflow.continueDiscoveryAfterReview({
    market: MARKET,
    receipt: reviewReceipt(await readDiscoveryKnowledge({store, market: MARKET})), now: NOW,
  });
  await assert.rejects(() => interrupted.resume(first.run.runId, plan),
    /synthetic boundary crash/);
  assert.equal((await readDiscoveryKnowledge({store, market: MARKET})).retainedCount, 3);
  assert.equal((await store.listWorkItems({runId: first.run.runId})).length, 2);
  const restartedStore = await new FileOperationsStore(root).initialize();
  const restartedWorkflow = new SupplyIntakeWorkflow({store: restartedStore,
    inputSnapshotLoader: async () => plan.inputSnapshot});
  const restarted = new OperationsEngine({store: restartedStore,
    workflow: restartedWorkflow, clock: () => new Date(NOW), workerId: "restarted-worker"});
  const replay = await restarted.resume(first.run.runId, plan);
  assert.equal(replay.run.status, "completed");
  assert.equal((await readDiscoveryKnowledge({store: restartedStore, market: MARKET})).retainedCount, 3);
  assert.equal((await restartedStore.listWorkItems({runId: first.run.runId})).length, 3);
});

test("enabled discovery requires reviewed decisions for every source candidate", async (t) => {
  const {workflow, plan, snapshot, decisions} = await setup(t, {reviewEvery: 2, count: 4});
  await assert.rejects(() => workflow.createPlan({
    market: MARKET, through: "2026-09-28", now: NOW,
    intakeScope: "organizer", inputSnapshot: snapshot,
    discoveryGatePolicy: {schemaVersion: 1, enabled: true, reviewEvery: 2,
      decisions: decisions.slice(0, -1)},
  }), {code: "INVALID_DISCOVERY_GATE"});
  await assert.rejects(() => workflow.createPlan({
    market: MARKET, through: "2026-09-28", now: NOW,
    intakeScope: "organizer", inputSnapshot: snapshot,
    discoveryGatePolicy: {schemaVersion: 1, enabled: true, reviewEvery: 2,
      decisions: decisions.map((decision, index) => index === 3 ?
        {...decision, identityKey: decisions[2].identityKey} : decision)},
  }), {code: "INVALID_DISCOVERY_GATE"});
  const changedPlan = structuredClone(plan);
  changedPlan.discoveryGate.reviewEvery = 3;
  assert.throws(() => workflow.assertPlan(changedPlan), {code: "INVALID_PLAN"});
});
