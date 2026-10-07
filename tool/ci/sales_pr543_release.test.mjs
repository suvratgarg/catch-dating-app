import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {prepareFunctionsDeployment} from "./firebase_functions_checkpoint.mjs";
import {SALES_PR543_RELEASE as r, SALES_PR543_RETAINED_TARGETS as retained,
  prepareSalesPr543Release, verifySalesPr543Params, captureSalesPr543Before,
  completeSalesPr543Release, runSalesPr543ReleaseCli} from "./selective_backend_release.mjs";

const copy = structuredClone;
const approvedTargets = [
  "functions:adminApplySalesPrivacyBatch",
  "functions:adminAssignSalesPartner",
  "functions:adminBuildSalesOutreachInput",
  "functions:adminCopySalesOutreachDraft",
  "functions:adminGenerateSalesOutreachDraft",
  "functions:adminGetSalesDemoPartnerReview",
  "functions:adminGetSalesIntelligenceCatalog",
  "functions:adminGetSalesIntelligenceScore",
  "functions:adminGetSalesOutreachDraft",
  "functions:adminGetSalesOutreachDraftJob",
  "functions:adminGetSalesPrivacyCase",
  "functions:adminLinkSalesInboundIntent",
  "functions:adminListSalesInboundIntents",
  "functions:adminListSalesOutreachDrafts",
  "functions:adminPreviewSalesPrivacyPlan",
  "functions:adminRestrictSalesOrganizer",
  "functions:adminReviewSalesIntelligenceClause",
  "functions:adminReviewSalesOutreachDraft",
  "functions:adminReviewSalesPrivacyPlan",
  "functions:adminReviewSalesPrivacyPolicy",
  "functions:adminRevokeSalesPartnerAccess",
  "functions:adminSaveSalesFactorAssessment",
  "functions:adminSaveSalesIntelligenceClause",
  "functions:adminSaveSalesIntelligencePolicy",
  "functions:adminSaveSalesScoreSnapshot",
  "functions:adminShareSalesDemoPartnerReview",
  "functions:copySalesPartnerOutreachDraft",
  "functions:createSalesDemoContinuation",
  "functions:decideSalesPartnerAssignment",
  "functions:expireSalesDemos",
  "functions:generateSalesPartnerOutreach",
  "functions:getSalesDemoContinuation",
  "functions:getSalesPartnerDemoReviews",
  "functions:getSalesPartnerOutreachDraft",
  "functions:getSalesPartnerOutreachJob",
  "functions:getSalesPartnerPreparation",
  "functions:getSalesPartnerWorkspace",
  "functions:nominateSalesOrganizer",
  "functions:prepareSalesDemoContinuationForm",
  "functions:proposeSalesPartnerDemoWording",
  "functions:recordSalesPartnerManualSend",
  "functions:registerSalesPartner",
  "functions:reviewSalesPartnerOutreachDraft",
  "functions:updateSalesPartnerAssignment",
];
const approvedAddedTargets = [
  "functions:adminAssignSalesPartner",
  "functions:adminGetSalesDemoPartnerReview",
  "functions:adminRevokeSalesPartnerAccess",
  "functions:adminShareSalesDemoPartnerReview",
  "functions:copySalesPartnerOutreachDraft",
  "functions:createSalesDemoContinuation",
  "functions:decideSalesPartnerAssignment",
  "functions:generateSalesPartnerOutreach",
  "functions:getSalesDemoContinuation",
  "functions:getSalesPartnerDemoReviews",
  "functions:getSalesPartnerOutreachDraft",
  "functions:getSalesPartnerOutreachJob",
  "functions:getSalesPartnerPreparation",
  "functions:getSalesPartnerWorkspace",
  "functions:nominateSalesOrganizer",
  "functions:prepareSalesDemoContinuationForm",
  "functions:proposeSalesPartnerDemoWording",
  "functions:recordSalesPartnerManualSend",
  "functions:registerSalesPartner",
  "functions:reviewSalesPartnerOutreachDraft",
  "functions:updateSalesPartnerAssignment",
];
const manifest = {schema: "catch.delivery-provenance/v2", sourceSha: r.sourceSha,
  sourceCiRunId: r.sourceCiRunId, sourceCiRunAttempt: r.sourceCiRunAttempt,
  stages: ["functions", "firestore-rules"],
  artifact: {name: "firebase-backend.tar.gz", sizeBytes: 8095760, sha256: r.packageSha256}};
const deferred = Array.from({length: 557}, (_, index) => `functions:other${index}`);
const historical = [...deferred, ...r.targets].sort();
const packagePlan = {schema: "catch.firebase-delivery-plan/v2", sourceSha: r.sourceSha, baseSha: r.baseSha,
  sourceCiRunId: r.sourceCiRunId, sourceCiRunAttempt: r.sourceCiRunAttempt,
  impactPlanSha256: "f".repeat(64), deployGroups: ["firestore-rules", "functions"],
  stages: ["functions", "firestore-rules"], targets: [historical.join(","), "firestore:rules"]};
const sha256 = (bytes) => createHash("sha256").update(bytes).digest("hex");

function liveFunction(target, generation = 1, project = r.projectId) {
  const name = target.slice("functions:".length);
  const service = `projects/${project}/locations/asia-south1/services/${name.toLowerCase()}`;
  const revision = `${name.toLowerCase()}-${String(generation).padStart(5, "0")}-abc`;
  return {name: `projects/${project}/locations/asia-south1/functions/${name}`,
    environment: "GEN_2", state: "ACTIVE", updateTime: `2026-10-0${generation}T12:00:00Z`,
    buildConfig: {build: `projects/42/locations/asia-south1/builds/build-${name}-${generation}`,
      sourceProvenance: {resolvedStorageSource: {bucket: "source-bucket", object: "functions.zip",
        generation: String(generation)}}},
    serviceConfig: {service, revision},
    runService: {name: service, uid: `${name}-uid`, generation: String(generation),
      observedGeneration: String(generation), latestReadyRevision: `${service}/revisions/${revision}`,
      latestCreatedRevision: `${service}/revisions/${revision}`,
      terminalCondition: {state: "CONDITION_SUCCEEDED"},
      trafficStatuses: [{type: "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST", percent: 100}]}};
}

function fixture() {
  const beforeFunctions = retained.map((target) => liveFunction(target));
  const functions = r.targets.map((target) => liveFunction(target, 2));
  const before = captureSalesPr543Before({manifest, packagePlan, functions: beforeFunctions});
  const paramsSha256 = "a".repeat(64);
  const deployment = prepareFunctionsDeployment({manifest, scope: r.scope, baseSha: r.baseSha,
    selectedTargets: r.targets, paramsSha256, functions});
  return {manifest, packagePlan, before, deployment, expectedParamsSha256: paramsSha256, functions};
}

test("immutable 601-export package selects exactly 44 Sales Functions and Firestore rules", () => {
  assert.deepEqual(r.targets, approvedTargets);
  assert.deepEqual(r.addedTargets, approvedAddedTargets);
  const selected = prepareSalesPr543Release({manifest, packagePlan});
  assert.deepEqual(selected.targets, [r.targets.join(","), "firestore:rules"]);
  assert.equal(packagePlan.targets[0], historical.join(","));
  assert.deepEqual(selected.deployGroups, ["firestore-rules", "functions"]);
  assert.equal(r.targets.length, 44);
  assert.equal(r.addedTargets.length, 21);
  assert.equal(retained.length, 23);
  assert.ok(deferred.every((target) => !selected.targets[0].includes(`${target},`) &&
    !selected.targets[0].endsWith(target)));
  for (const mutate of [
    (v) => {v.manifest.artifact.sha256 = "0".repeat(64);},
    (v) => {v.manifest.artifact.sizeBytes += 1;},
    (v) => {v.packagePlan.sourceSha = "0".repeat(40);},
    (v) => {v.packagePlan.baseSha = "0".repeat(40);},
    (v) => {v.packagePlan.sourceCiRunId = "1";},
    (v) => {v.packagePlan.deployGroups.reverse();},
    (v) => {v.packagePlan.stages.reverse();},
    (v) => {v.packagePlan.targets[0] = historical.filter((target) => target !== r.targets[0]).join(",");},
    (v) => {v.packagePlan.targets[1] = "firestore:indexes";},
    (v) => {v.packagePlan.targets.push("storage:rules");},
  ]) {
    const bad = copy({manifest, packagePlan});
    mutate(bad);
    assert.throws(() => prepareSalesPr543Release(bad), /Invalid Sales PR543 selective release evidence/);
  }
});

test("generated params are bound by digest without exposing values", (t) => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "catch-sales-pr543-"));
  t.after(() => fs.rmSync(dir, {recursive: true, force: true}));
  const file = path.join(dir, `.env.${r.projectId}`);
  const body = 'PRIVATE_NAME="opaque value"\n';
  fs.writeFileSync(file, body, {mode: 0o600});
  assert.deepEqual(verifySalesPr543Params(file), {paramsSha256: sha256(body)});
  assert.equal(JSON.stringify(verifySalesPr543Params(file)).includes("opaque value"), false);
  fs.chmodSync(file, 0o644);
  assert.throws(() => verifySalesPr543Params(file), /Invalid Sales PR543 selective release evidence/);
});

test("completion binds 21 absent additions and fresh identities for all 44 selected Functions", () => {
  const good = fixture();
  const receipt = completeSalesPr543Release(good);
  assert.deepEqual(receipt.selectedTargets, r.targets);
  assert.deepEqual(receipt.addedTargets, r.addedTargets);
  assert.equal(receipt.coverage, "selected-physical-identities-and-exact-rules-only");
  assert.equal(receipt.rulesTarget, "firestore:rules");
  assert.equal(receipt.functions.length, 44);
  for (const mutate of [
    (v) => {v.before.absentTargets.pop();},
    (v) => {v.before.functions[0].name = "projects/other/locations/asia-south1/functions/foreign";},
    (v) => {v.before.functions[0].revision = v.deployment.functions[0].revision;},
    (v) => {v.deployment.paramsSha256 = "b".repeat(64);},
    (v) => {v.expectedParamsSha256 = "b".repeat(64);},
    (v) => {v.functions[0].serviceConfig.revision = "stale-revision";},
    (v) => {v.functions[0].runService.trafficStatuses[0].percent = 90;},
    (v) => {v.functions[0].name = "projects/other/locations/asia-south1/functions/foreign";},
    (v) => {v.deployment.targets.push("functions:unselected");},
  ]) {
    const bad = copy(good);
    mutate(bad);
    assert.throws(() => completeSalesPr543Release(bad), /Invalid Sales PR543 selective release evidence/);
  }
});

test("CLI proves 21 additions absent, snapshots 23 existing Functions and writes private receipts", async (t) => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "catch-sales-pr543-cli-"));
  t.after(() => fs.rmSync(dir, {recursive: true, force: true}));
  const good = fixture();
  const manifestFile = path.join(dir, "manifest.json");
  const planFile = path.join(dir, "plan.json");
  const selectedFile = path.join(dir, "selected.json");
  const beforeFile = path.join(dir, "before.json");
  const deploymentFile = path.join(dir, "deployment.json");
  const receiptFile = path.join(dir, "receipt.json");
  fs.writeFileSync(manifestFile, JSON.stringify(manifest));
  fs.writeFileSync(planFile, JSON.stringify(packagePlan));
  fs.writeFileSync(deploymentFile, JSON.stringify(good.deployment));
  assert.deepEqual(await runSalesPr543ReleaseCli(["prepare", "--manifest", manifestFile,
    "--package-plan", planFile, "--output", selectedFile]),
  {prepared: true, selectedFunctions: 44, selectedRules: 1});
  assert.equal(fs.statSync(selectedFile).mode & 0o777, 0o600);
  assert.deepEqual(await runSalesPr543ReleaseCli(["stage", "--stage", "functions",
    "--target", r.targets.join(",")]), {authorizedStage: "functions"});
  assert.deepEqual(await runSalesPr543ReleaseCli(["stage", "--stage", "firestore-rules",
    "--target", "firestore:rules"]), {authorizedStage: "firestore-rules"});
  await assert.rejects(runSalesPr543ReleaseCli(["stage", "--stage", "functions",
    "--target", `${r.targets.join(",")},functions:extra`]), /Invalid Sales PR543 selective release evidence/);
  const beforeLive = async (project, targets, options) => {
    assert.equal(project, r.projectId);
    assert.deepEqual(targets, retained);
    assert.deepEqual(options, {absentTargets: r.addedTargets});
    return retained.map((target) => liveFunction(target));
  };
  assert.deepEqual(await runSalesPr543ReleaseCli(["before", "--manifest", manifestFile,
    "--package-plan", planFile, "--output", beforeFile], {readLive: beforeLive}),
  {verifiedBefore: true, existingFunctions: 23, absentFunctions: 21});
  assert.deepEqual(await runSalesPr543ReleaseCli(["verify-before", "--manifest", manifestFile,
    "--package-plan", planFile, "--before", beforeFile]),
  {verifiedBefore: true, existingFunctions: 23, absentFunctions: 21});
  const afterLive = async (project, targets) => {
    assert.equal(project, r.projectId);
    assert.deepEqual(targets, r.targets);
    return good.functions;
  };
  await runSalesPr543ReleaseCli(["complete", "--manifest", manifestFile,
    "--package-plan", planFile, "--before", beforeFile, "--deployment", deploymentFile,
    "--params-sha256", good.expectedParamsSha256, "--output", receiptFile], {readLive: afterLive});
  const receipt = JSON.parse(fs.readFileSync(receiptFile, "utf8"));
  assert.equal(receipt.functions.length, 44);
  assert.equal(fs.statSync(receiptFile).mode & 0o777, 0o600);
  await assert.rejects(runSalesPr543ReleaseCli(["prepare", "--secret-payload", "anything"]),
    /Invalid Sales PR543 selective release evidence/);
  await assert.rejects(runSalesPr543ReleaseCli(["prepare", "--manifest", manifestFile,
    "--package-plan", planFile, "--output", path.join(dir, "unexpected.json"),
    "--unapproved-target", "functions:extra"]), /Invalid Sales PR543 selective release evidence/);
});
