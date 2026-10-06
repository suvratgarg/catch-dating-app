#!/usr/bin/env node
import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {validateProvenanceManifest} from "./delivery_core.mjs";
import {captureFunctionIdentities, liveFunctions, validateFunctionIdentity,
  validateFunctionsDeployment} from "./firebase_functions_checkpoint.mjs";

// This is one protected, exact-target code deployment. The historical package
// plan remains immutable; no source cursor or retained-Function ledger is
// published from a selected-only physical receipt.
export const WHATSAPP_FIVE_RELEASE = Object.freeze({
  sourceSha: "4dcd759a261f096bcf37d5f69e19eb625b0199b2",
  baseSha: "5c10b958da8d1774a29990d568a52bc2987b936e",
  sourceCiRunId: "37511803512",
  sourceCiRunAttempt: "1",
  packageSha256: "8081e1b83a091286b9d34c78f682b3bc985f3fcd4c19cf7c119d7e5238970a88",
  scope: "firebase:prod:catch-dating-app-64e51",
  projectId: "catch-dating-app-64e51",
  targets: Object.freeze([
    "functions:adminReviewCatchWhatsappInbound",
    "functions:adminSendCatchWhatsappReply",
    "functions:catchWhatsappWebhook",
    "functions:onCatchWhatsappReplyOperationWritten",
    "functions:onCatchWhatsappWebhookEventCreated",
  ]),
});
const digest = (bytes) => createHash("sha256").update(bytes).digest("hex");
const fail = () => { throw new Error("Invalid exact-five WhatsApp release evidence."); };
const safe = (action) => { try { return action(); } catch { return fail(); } };
const same = (a, b) => assert.deepEqual(a, b);
const exactKeys = (value, names) => {
  assert.ok(value && typeof value === "object" && !Array.isArray(value));
  same(Object.keys(value).sort(), [...names].sort());
};
const manifestForRelease = (raw) => {
  const manifest = validateProvenanceManifest(raw);
  assert.equal(manifest.sourceSha, WHATSAPP_FIVE_RELEASE.sourceSha);
  assert.equal(manifest.sourceCiRunId, WHATSAPP_FIVE_RELEASE.sourceCiRunId);
  assert.equal(manifest.sourceCiRunAttempt, WHATSAPP_FIVE_RELEASE.sourceCiRunAttempt);
  same(manifest.stages, ["functions"]);
  assert.equal(manifest.artifact.name, "firebase-backend.tar.gz");
  assert.equal(manifest.artifact.sizeBytes, 7957113);
  assert.equal(manifest.artifact.sha256, WHATSAPP_FIVE_RELEASE.packageSha256);
  return manifest;
};
export function prepareWhatsappFiveRelease({packagePlan, manifest: rawManifest}) {
  return safe(() => {
    manifestForRelease(rawManifest);
    const release = WHATSAPP_FIVE_RELEASE;
    assert.equal(packagePlan.sourceSha, release.sourceSha);
    assert.equal(packagePlan.baseSha, release.baseSha);
    assert.equal(packagePlan.sourceCiRunId, release.sourceCiRunId);
    assert.equal(packagePlan.sourceCiRunAttempt, release.sourceCiRunAttempt);
    assert.equal(packagePlan.schema, "catch.firebase-delivery-plan/v2");
    same(packagePlan.deployGroups, ["functions"]);
    same(packagePlan.stages, ["functions"]);
    assert.equal(packagePlan.targets?.length, 1);
    const historical = packagePlan.targets?.[0]?.split(",");
    assert.equal(historical?.length, 580);
    assert.equal(new Set(historical).size, 580);
    assert.ok(historical.every((target) => /^functions:[A-Za-z][A-Za-z0-9_-]*$/u.test(target)));
    same(historical, [...historical].sort());
    assert.ok(release.targets.every((target) => historical.includes(target)));
    return {...structuredClone(packagePlan), targets: [release.targets.join(",")]};
  });
}
export function verifyWhatsappFiveParams(file) {
  return safe(() => {
    assert.equal(path.basename(file), `.env.${WHATSAPP_FIVE_RELEASE.projectId}`);
    const stat = fs.lstatSync(file);
    assert.ok(stat.isFile() && !stat.isSymbolicLink() && stat.size < 1024 * 1024);
    const bytes = fs.readFileSync(file);
    const lines = bytes.toString("utf8").split(/\r?\n/u);
    for (const name of ["CATCH_WHATSAPP_WEBHOOK_ENABLED", "CATCH_WHATSAPP_RECEIPT_CONSUMERS_ENABLED",
      "CATCH_WHATSAPP_REPLIES_ENABLED", "CATCH_WHATSAPP_ATOMIC_STOP_INGRESS_READY"]) {
      assert.equal(lines.filter((line) => line === `${name}="false"`).length, 1);
      assert.equal(lines.filter((line) => line.startsWith(`${name}=`)).length, 1);
    }
    return {paramsSha256: digest(bytes), catchGatesClosed: true};
  });
}
export function captureWhatsappFiveBefore({manifest: rawManifest, packagePlan, functions}) {
  return safe(() => {
    prepareWhatsappFiveRelease({packagePlan, manifest: rawManifest});
    return {schema: "catch.whatsapp-five-before/v1", scope: WHATSAPP_FIVE_RELEASE.scope,
      sourceSha: WHATSAPP_FIVE_RELEASE.sourceSha, packageSha256: WHATSAPP_FIVE_RELEASE.packageSha256,
      selectedTargets: [...WHATSAPP_FIVE_RELEASE.targets],
      functions: captureFunctionIdentities(functions, WHATSAPP_FIVE_RELEASE.scope, WHATSAPP_FIVE_RELEASE.targets)};
  });
}
export function completeWhatsappFiveRelease({manifest: rawManifest, packagePlan, before, deployment,
  expectedParamsSha256, functions}) {
  return safe(() => {
    const manifest = manifestForRelease(rawManifest);
    prepareWhatsappFiveRelease({packagePlan, manifest});
    exactKeys(before, ["schema", "scope", "sourceSha", "packageSha256", "selectedTargets", "functions"]);
    assert.equal(before.schema, "catch.whatsapp-five-before/v1");
    assert.equal(before.scope, WHATSAPP_FIVE_RELEASE.scope);
    assert.equal(before.sourceSha, WHATSAPP_FIVE_RELEASE.sourceSha);
    assert.equal(before.packageSha256, WHATSAPP_FIVE_RELEASE.packageSha256);
    same(before.selectedTargets, WHATSAPP_FIVE_RELEASE.targets);
    assert.ok(Array.isArray(before.functions) && before.functions.length === 5);
    before.functions.forEach((identity, index) => validateFunctionIdentity(identity,
      {scope: WHATSAPP_FIVE_RELEASE.scope, target: WHATSAPP_FIVE_RELEASE.targets[index]}));
    assert.match(expectedParamsSha256 ?? "", /^[0-9a-f]{64}$/u);
    validateFunctionsDeployment(deployment, {manifest, scope: WHATSAPP_FIVE_RELEASE.scope,
      baseSha: WHATSAPP_FIVE_RELEASE.baseSha, selectedTargets: WHATSAPP_FIVE_RELEASE.targets,
      paramsSha256: expectedParamsSha256});
    const actual = captureFunctionIdentities(functions, WHATSAPP_FIVE_RELEASE.scope, WHATSAPP_FIVE_RELEASE.targets);
    same(actual, deployment.functions);
    for (let index = 0; index < 5; index++) {
      assert.notEqual(actual[index].revision, before.functions[index].revision);
      assert.notEqual(actual[index].build, before.functions[index].build);
    }
    return {schema: "catch.whatsapp-five-selected-receipt/v1", scope: WHATSAPP_FIVE_RELEASE.scope,
      sourceSha: WHATSAPP_FIVE_RELEASE.sourceSha, packageSha256: WHATSAPP_FIVE_RELEASE.packageSha256,
      selectedTargets: [...WHATSAPP_FIVE_RELEASE.targets], paramsSha256: expectedParamsSha256,
      beforeSha256: digest(JSON.stringify(before)), functions: actual,
      coverage: "selected-physical-identities-only"};
  });
}
const read = (file) => JSON.parse(fs.readFileSync(file, "utf8"));
const write = (file, value) => fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`, {flag: "wx", mode: 0o600});
const options = (args) => {
  const result = {};
  for (let index = 0; index < args.length; index += 2) {
    assert.ok(args[index]?.startsWith("--") && args[index + 1]);
    const key = args[index].slice(2);
    assert.ok(!Object.hasOwn(result, key));
    result[key] = args[index + 1];
  }
  return result;
};
export async function runWhatsappFiveReleaseCli(argv, {readLive = liveFunctions} = {}) {
  try {
    const [command, ...rest] = argv;
    assert.ok(["prepare", "params", "before", "complete"].includes(command));
    const args = options(rest);
    if (command === "params") return verifyWhatsappFiveParams(args["params-file"]);
    const manifest = read(args.manifest);
    const packagePlan = read(args["package-plan"]);
    if (command === "prepare") {
      write(args.output, prepareWhatsappFiveRelease({packagePlan, manifest}));
      return {prepared: true, selectedFunctions: 5};
    }
    const functions = await readLive(WHATSAPP_FIVE_RELEASE.projectId, WHATSAPP_FIVE_RELEASE.targets);
    if (command === "before") {
      write(args.output, captureWhatsappFiveBefore({manifest, packagePlan, functions}));
      return {verifiedBefore: true, selectedFunctions: 5};
    }
    const result = completeWhatsappFiveRelease({manifest, packagePlan, functions,
      before: read(args.before), deployment: read(args.deployment),
      expectedParamsSha256: args["params-sha256"]});
    write(args.output, result);
    return {verifiedComplete: true, selectedFunctions: 5};
  } catch { return fail(); }
}
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  runWhatsappFiveReleaseCli(process.argv.slice(2)).then((result) => console.log(JSON.stringify(result))).catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
  });
}
