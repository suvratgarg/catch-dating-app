import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {prepareFunctionsDeployment} from "./firebase_functions_checkpoint.mjs";
import {WHATSAPP_FIVE_RELEASE as r, prepareWhatsappFiveRelease, verifyWhatsappFiveParams,
  captureWhatsappFiveBefore, completeWhatsappFiveRelease, runWhatsappFiveReleaseCli} from "./whatsapp_five_release.mjs";

const copy = structuredClone;
const manifest = {schema: "catch.delivery-provenance/v2", sourceSha: r.sourceSha,
  sourceCiRunId: r.sourceCiRunId, sourceCiRunAttempt: r.sourceCiRunAttempt, stages: ["functions"],
  artifact: {name: "firebase-backend.tar.gz", sizeBytes: 7957113, sha256: r.packageSha256}};
const deferred = ["functions:importWeddingPhoneContacts", "functions:manageHostRosterIntake"];
const historical = [...Array.from({length: 573}, (_, i) => `functions:other${i}`),
  ...deferred, ...r.targets].sort();
const packagePlan = {schema: "catch.firebase-delivery-plan/v2", sourceSha: r.sourceSha, baseSha: r.baseSha,
  sourceCiRunId: r.sourceCiRunId, sourceCiRunAttempt: r.sourceCiRunAttempt,
  stages: ["functions"], deployGroups: ["functions"], targets: [historical.join(",")]};
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
  const beforeFunctions = r.targets.map((target) => liveFunction(target));
  const functions = r.targets.map((target) => liveFunction(target, 2));
  const before = captureWhatsappFiveBefore({manifest, packagePlan, functions: beforeFunctions});
  const paramsSha256 = "a".repeat(64);
  const deployment = prepareFunctionsDeployment({manifest, scope: r.scope, baseSha: r.baseSha,
    selectedTargets: r.targets, paramsSha256, functions});
  return {manifest, packagePlan, before, deployment, expectedParamsSha256: paramsSha256, functions};
}

test("immutable 580-export package selects exactly the authorized five", () => {
  const selected = prepareWhatsappFiveRelease({manifest, packagePlan});
  assert.deepEqual(selected.targets, [r.targets.join(",")]);
  assert.equal(packagePlan.targets[0], historical.join(","));
  assert.equal(selected.deployGroups.join(), "functions");
  for (const target of deferred) {
    assert.ok(packagePlan.targets[0].includes(target));
    assert.equal(selected.targets[0].includes(target), false);
  }
  for (const mutate of [
    (v) => {v.manifest.artifact.sha256 = "0".repeat(64);},
    (v) => {v.packagePlan.sourceSha = "0".repeat(40);},
    (v) => {v.packagePlan.baseSha = "0".repeat(40);},
    (v) => {v.packagePlan.sourceCiRunId = "1";},
    (v) => {v.packagePlan.deployGroups.push("firestore-rules");},
    (v) => {v.packagePlan.stages.push("firestore-rules");},
    (v) => {v.packagePlan.targets[0] = historical.filter((t) => t !== r.targets[0]).join(",");},
    (v) => {v.packagePlan.targets.push("functions:extra");},
  ]) {
    const bad = copy({manifest, packagePlan});
    mutate(bad);
    assert.throws(() => prepareWhatsappFiveRelease(bad), /Invalid exact-five WhatsApp release evidence/);
  }
});

test("four Catch gates must be explicitly false in the generated deploy params, without reporting values", (t) => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "catch-wa-five-"));
  t.after(() => fs.rmSync(dir, {recursive: true, force: true}));
  const file = path.join(dir, `.env.${r.projectId}`);
  const closed = ["CATCH_WHATSAPP_WEBHOOK_ENABLED", "CATCH_WHATSAPP_RECEIPT_CONSUMERS_ENABLED",
    "CATCH_WHATSAPP_REPLIES_ENABLED", "CATCH_WHATSAPP_ATOMIC_STOP_INGRESS_READY"];
  const body = `${closed.map((name) => `${name}="false"`).join("\n")}\nOTHER_NON_SECRET="some value"\n`;
  fs.writeFileSync(file, body, {mode: 0o600});
  assert.deepEqual(verifyWhatsappFiveParams(file), {paramsSha256: sha256(body), catchGatesClosed: true});
  for (const changed of [body.replace('CATCH_WHATSAPP_WEBHOOK_ENABLED="false"',
    'CATCH_WHATSAPP_WEBHOOK_ENABLED="true"'), body.replace('CATCH_WHATSAPP_REPLIES_ENABLED="false"\n', ""),
  `${body}CATCH_WHATSAPP_WEBHOOK_ENABLED="false"\n`]) {
    fs.writeFileSync(file, changed);
    assert.throws(() => verifyWhatsappFiveParams(file), /Invalid exact-five WhatsApp release evidence/);
  }
});

test("selected-only completion binds all five fresh serving revisions and exact params", () => {
  const good = fixture();
  const receipt = completeWhatsappFiveRelease(good);
  assert.deepEqual(receipt.selectedTargets, r.targets);
  assert.equal(receipt.coverage, "selected-physical-identities-only");
  assert.equal(receipt.functions.length, 5);
  for (const mutate of [
    (v) => {v.before.functions[0].name = "projects/other/locations/asia-south1/functions/foreign";},
    (v) => {v.before.functions[0].revision = v.functions[0].serviceConfig.revision;},
    (v) => {v.before.functions[0].build = v.deployment.functions[0].build;},
    (v) => {v.deployment.paramsSha256 = "b".repeat(64);},
    (v) => {v.expectedParamsSha256 = "b".repeat(64);},
    (v) => {v.functions[0].serviceConfig.revision = "stale-revision";},
    (v) => {v.functions[0].runService.trafficStatuses[0].percent = 90;},
    (v) => {v.functions[0].name = "projects/other/locations/asia-south1/functions/foreign";},
    (v) => {v.deployment.targets.push("functions:unselected");},
  ]) {
    const bad = copy(good);
    mutate(bad);
    assert.throws(() => completeWhatsappFiveRelease(bad), /Invalid exact-five WhatsApp release evidence/);
  }
});

test("CLI validates fixed paths and writes names-only evidence with private mode", async (t) => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "catch-wa-five-cli-"));
  t.after(() => fs.rmSync(dir, {recursive: true, force: true}));
  const manifestFile = path.join(dir, "manifest.json");
  const planFile = path.join(dir, "plan.json");
  const output = path.join(dir, "selected.json");
  fs.writeFileSync(manifestFile, JSON.stringify(manifest));
  fs.writeFileSync(planFile, JSON.stringify(packagePlan));
  assert.deepEqual(await runWhatsappFiveReleaseCli(["prepare", "--manifest", manifestFile,
    "--package-plan", planFile, "--output", output]), {prepared: true, selectedFunctions: 5});
  assert.equal(fs.statSync(output).mode & 0o777, 0o600);
  assert.deepEqual(JSON.parse(fs.readFileSync(output, "utf8")).targets, [r.targets.join(",")]);
  await assert.rejects(runWhatsappFiveReleaseCli(["prepare", "--manifest", manifestFile,
    "--package-plan", planFile, "--output", output]), /Invalid exact-five WhatsApp release evidence/);
  await assert.rejects(runWhatsappFiveReleaseCli(["prepare", "--secret-payload", "anything"]),
    /Invalid exact-five WhatsApp release evidence/);
  await assert.rejects(runWhatsappFiveReleaseCli(["prepare", "--manifest", manifestFile,
    "--package-plan", planFile, "--output", path.join(dir, "unexpected.json"),
    "--unapproved-target", "functions:extra"]), /Invalid exact-five WhatsApp release evidence/);
});

test("CLI captures and completes only selected live metadata, never a provider payload", async (t) => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "catch-wa-five-live-"));
  t.after(() => fs.rmSync(dir, {recursive: true, force: true}));
  const good = fixture();
  const manifestFile = path.join(dir, "manifest.json");
  const planFile = path.join(dir, "plan.json");
  const beforeFile = path.join(dir, "before.json");
  const deploymentFile = path.join(dir, "deployment.json");
  const receiptFile = path.join(dir, "receipt.json");
  fs.writeFileSync(manifestFile, JSON.stringify(manifest));
  fs.writeFileSync(planFile, JSON.stringify(packagePlan));
  fs.writeFileSync(deploymentFile, JSON.stringify(good.deployment));
  const beforeLive = async (project, targets) => {
    assert.equal(project, r.projectId);
    assert.deepEqual(targets, r.targets);
    return r.targets.map((target) => liveFunction(target));
  };
  await runWhatsappFiveReleaseCli(["before", "--manifest", manifestFile,
    "--package-plan", planFile, "--output", beforeFile], {readLive: beforeLive});
  const afterLive = async (project, targets) => {
    assert.equal(project, r.projectId);
    assert.deepEqual(targets, r.targets);
    return good.functions;
  };
  await runWhatsappFiveReleaseCli(["complete", "--manifest", manifestFile,
    "--package-plan", planFile, "--before", beforeFile,
    "--deployment", deploymentFile, "--params-sha256", good.expectedParamsSha256,
    "--output", receiptFile], {readLive: afterLive});
  const receipt = JSON.parse(fs.readFileSync(receiptFile, "utf8"));
  assert.equal(receipt.coverage, "selected-physical-identities-only");
  assert.equal(receipt.functions.length, 5);
  assert.equal(fs.statSync(receiptFile).mode & 0o777, 0o600);
});
