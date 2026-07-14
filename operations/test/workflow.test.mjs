import assert from "node:assert/strict";
import fs from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import {OperationsEngine} from "../src/platform/engine.mjs";
import {buildAdminProjection} from "../src/platform/read-models.mjs";
import {FileOperationsStore} from "../src/platform/storage/file-store.mjs";
import {SupplyIntakeLearner} from "../src/workflows/supply-intake/learning.mjs";
import {SupplyIntakeWorkflow} from "../src/workflows/supply-intake/workflow.mjs";
import {createFixtureRepository, temporaryDirectory} from "./helpers.mjs";

const NOW = "2026-07-14T12:00:00.000Z";

test("supply-intake runs end to end in shadow mode with one exclusive stage per item", async () => {
  const repoRoot = await createFixtureRepository(await temporaryDirectory("catch-ops-repo-"));
  const store = await new FileOperationsStore(await temporaryDirectory("catch-ops-state-")).initialize();
  const workflow = new SupplyIntakeWorkflow({repoRoot});
  const plan = await workflow.createPlan({market: "mumbai", through: "2026-07-28", now: NOW});
  const replayPlan = await workflow.createPlan({market: "mumbai", through: "2026-07-28", now: "2026-07-14T13:00:00.000Z"});
  assert.equal(plan.planId, replayPlan.planId);
  assert.equal(plan.planContentHash, replayPlan.planContentHash);
  assert.deepEqual(plan.capabilities, {network: false, modelCalls: false, publicWrites: false, ruleDeployment: false});

  const engine = new OperationsEngine({store, workflow, clock: () => new Date(NOW), workerId: "test-worker"});
  const first = await engine.start(plan);
  const replay = await engine.start(plan);
  assert.equal(first.run.status, "completed");
  assert.equal(replay.idempotentReplay, true);
  assert.equal(replay.run.runId, first.run.runId);

  const items = await store.listWorkItems({runId: first.run.runId});
  assert.equal(items.length, 8);
  assert.ok(items.every((item) => ["incoming", "verify", "resolve", "ready"].includes(item.primaryStage)));
  assert.deepEqual(new Set(items.map((item) => item.entityKind)), new Set(["event", "organizer", "source_result", "source_profile"]));
  assert.equal(items.find((item) => item.sourceEntity.id === "event-ready").primaryStage, "ready");
  assert.equal(items.find((item) => item.sourceEntity.id === "event-resolve").primaryStage, "resolve");
  assert.equal(items.find((item) => item.sourceEntity.id === "event-expired").lifecycleStatus, "expired");

  const receipt = await engine.promotionReceipt(first.run.runId);
  assert.equal(receipt.applyAllowed, false);
  assert.ok(receipt.blockedBy.includes("shadow_mode"));
  assert.ok(receipt.itemBindings.length >= 1);

  const actions = await store.listActions(first.run.runId);
  const checkpoints = await store.listCheckpoints(first.run.runId);
  const projection = buildAdminProjection(await store.requireRun(first.run.runId), items, actions, checkpoints);
  assert.deepEqual(projection.stageOrder, ["incoming", "verify", "resolve", "ready"]);
  assert.equal(projection.items.length, items.length);
  assert.ok(projection.items.every((item) => !Object.hasOwn(item, "raw")));
  assert.deepEqual(Object.keys(projection.run).sort(), [
    "budgets", "checkpoint", "counters", "createdAt", "failure", "finishedAt", "inputHash", "metadata",
    "mode", "policyVersion", "revision", "rulesetVersion", "runId", "schemaVersion", "scope", "startedAt",
    "status", "updatedAt", "workflowId",
  ].sort());
  assert.deepEqual(Object.keys(projection.items[0]).sort(), [
    "attemptCount", "blockerCodes", "candidateHash", "createdAt", "decisionId", "entityKind", "evidenceRefs",
    "expiresAt", "externalKey", "fieldProvenance", "lifecycleStatus", "normalizedPayload", "outcome", "primaryStage",
    "priority", "publicationPlanId", "revision", "runId", "schemaVersion", "staleAt", "taskFlags", "updatedAt",
    "warningCodes", "workflowId", "workItemId",
  ].sort());
  const humanReview = projection.items.find((item) => item.externalKey === "event-resolve");
  assert.ok(humanReview.taskFlags.includes("human_review_required"));
  assert.equal(humanReview.normalizedPayload.title, "Needs a source");
  assert.equal(humanReview.normalizedPayload.market, "mumbai");
  assert.equal(Object.values(projection.summary.stageCounts).reduce((sum, value) => sum + value, 0), projection.summary.activeItems);

  const exported = await store.putAdminProjection(first.run.runId, projection);
  assert.deepEqual(JSON.parse(await fs.readFile(exported.path, "utf8")), projection);
});

test("plan snapshots fail closed when a legacy artifact changes before execution", async () => {
  const repoRoot = await createFixtureRepository(await temporaryDirectory("catch-ops-drift-"));
  const store = await new FileOperationsStore(await temporaryDirectory()).initialize();
  const workflow = new SupplyIntakeWorkflow({repoRoot});
  const plan = await workflow.createPlan({market: "mumbai", through: "2026-07-28", now: NOW});
  const bridge = path.join(repoRoot, plan.artifactSnapshot.artifacts.eventIntakeBridge.relativePath);
  const current = JSON.parse(await fs.readFile(bridge, "utf8"));
  current.sourceResults.push({id: "drift", title: "Drift"});
  await fs.writeFile(bridge, JSON.stringify(current));
  const engine = new OperationsEngine({store, workflow, clock: () => new Date(NOW), workerId: "test-worker"});
  await assert.rejects(engine.start(plan), {code: "ARTIFACT_DRIFT"});
});

test("rule lifecycle evaluates fixtures and stops at a non-deploying shadow canary", async () => {
  const store = await new FileOperationsStore(await temporaryDirectory()).initialize();
  const learner = new SupplyIntakeLearner({store, clock: () => new Date(NOW)});
  const proposal = await learner.propose("cntraveller");
  const evaluation = await learner.evaluate(proposal.proposalId);
  assert.equal(evaluation.status, "passed");
  assert.equal(evaluation.metrics.precision, 1);
  assert.equal(evaluation.metrics.recall, 1);
  const canary = await learner.canary(proposal.proposalId);
  assert.equal(canary.status, "shadow_canary");
  assert.equal(canary.activationAllowed, false);
  assert.equal(canary.deploymentAllowed, false);
});
