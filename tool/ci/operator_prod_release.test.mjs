import test from "node:test";
import assert from "node:assert/strict";
import {execFileSync} from "node:child_process";
import {captureFunctionIdentities} from "./firebase_functions_checkpoint.mjs";
import {normalizeIndex} from "../firebase/wait_firestore_indexes_ready.mjs";
import {OPERATOR_PROD_RELEASE as release, prepareOperatorProdRelease,
  verifyOperatorProdBefore, completeOperatorProdRelease, readOperatorProdSnapshot} from "./operator_prod_release.mjs";

const scope = "firebase:prod:catch-dating-app-64e51";
const load = (sha) => JSON.parse(execFileSync("git", ["show", `${sha}:firestore.indexes.json`], {encoding: "utf8"}));
const baselineIndexes = load(release.baselineSha);
const candidateIndexes = load(release.candidateSha);
const targets = [...release.targets, ...Array.from({length: 574}, (_, index) => `functions:fixture${String(index).padStart(3, "0")}`)].sort();
function liveFunction(target, index, revision = "revision-1") {
  const project = "catch-dating-app-64e51";
  const name = `projects/${project}/locations/asia-south1/functions/${target.slice("functions:".length)}`;
  const service = `projects/${project}/locations/asia-south1/services/fixture-${index}`;
  return {name, state: "ACTIVE", environment: "GEN_2", updateTime: "2026-10-01T00:00:00Z",
    buildConfig: {build: `projects/${project}/locations/asia-south1/builds/build-${index}`,
      sourceProvenance: {resolvedStorageSource: {bucket: "source-bucket", object: `source-${index}`, generation: "1"}}},
    serviceConfig: {service, revision}, runService: {name: service, uid: `uid-${index}`,
      generation: "1", observedGeneration: "1", latestReadyRevision: `${service}/revisions/${revision}`,
      latestCreatedRevision: `${service}/revisions/${revision}`, terminalCondition: {state: "CONDITION_SUCCEEDED"},
      trafficStatuses: [{type: "TRAFFIC_TARGET_ALLOCATION_TYPE_REVISION", revision, percent: 100}]}};
}
const baselineLive = targets.map((target, index) => liveFunction(target, index));
const baselineDeployment = {schema: "catch.firebase-functions-deployment/v1", scope,
  provenance: {sourceSha: release.baselineSha}, targets,
  functions: captureFunctionIdentities(baselineLive, scope, targets)};
const packagePlan = {sourceSha: release.candidateSha, baseSha: release.packageBaseSha,
  sourceCiRunId: release.sourceCiRunId, sourceCiRunAttempt: release.sourceCiRunAttempt,
  stages: ["firestore-indexes", "functions"], targets: ["firestore:indexes", targets.join(",")]};
const liveIndexes = candidateIndexes.indexes.map((index) => ({...normalizeIndex(index, {desired: true}), state: "READY"}));
const liveFields = candidateIndexes.fieldOverrides.map((field) => ({
  name: `projects/catch-dating-app-64e51/databases/(default)/collectionGroups/${field.collectionGroup}/fields/${field.fieldPath}`,
  indexConfig: {usesAncestorConfig: false, indexes: field.indexes.map((index) => ({
    state: "READY", queryScope: index.queryScope,
    fields: [{...(index.order ? {order: index.order} : {arrayConfig: index.arrayConfig})}],
  }))},
  ...(field.ttl ? {ttlConfig: {state: "ACTIVE"}} : {}),
}));
const prepared = () => prepareOperatorProdRelease({packagePlan, baselineIndexes, candidateIndexes, baselineDeployment});
const error = /^Error: Invalid bounded PROD operator release evidence\.$/;

test("operator plan preserves historical package authority and selects only four names and five indexes", () => {
  const result = prepared();
  assert.equal(result.additions.length, 5);
  assert.equal(result.retainedTargetCount, 574);
  assert.deepEqual(result.executionPlan.stages, ["firestore-indexes", "functions"]);
  assert.deepEqual(result.executionPlan.targets, ["firestore:indexes", release.targets.join(",")]);
  assert.equal(result.packagePlan.targets[1].split(",").length, 578);
  assert.equal(result.packagePlan.baseSha, release.packageBaseSha);
});

test("operator rejects changed package, baseline, added index, or target scope", () => {
  for (const changed of [
    {packagePlan: {...packagePlan, baseSha: release.baselineSha}},
    {packagePlan: {...packagePlan, targets: ["firestore:indexes", "functions:other"]}},
    {baselineDeployment: {...baselineDeployment, provenance: {sourceSha: release.candidateSha}}},
    {candidateIndexes: {...candidateIndexes, indexes: candidateIndexes.indexes.slice(0, -1)}},
  ]) assert.throws(() => prepareOperatorProdRelease({packagePlan, baselineIndexes, candidateIndexes,
    baselineDeployment, ...changed}), error);
});

test("preflight rejects changed retained Function, unrelated live index, and unready index", () => {
  const {additions} = prepared();
  const input = {baselineDeployment, candidateIndexes, additions, liveFunctions: baselineLive, liveIndexes, liveFields};
  assert.equal(verifyOperatorProdBefore(input).missingAdditions, 0);
  const changed = baselineLive.map((fn, index) => index === 4 ? liveFunction(targets[index], index, "revision-2") : fn);
  assert.throws(() => verifyOperatorProdBefore({...input, liveFunctions: changed}), error);
  assert.throws(() => verifyOperatorProdBefore({...input, liveIndexes: [...liveIndexes,
    {...liveIndexes[0], collectionGroup: "unreviewed"}]}), error);
  assert.throws(() => verifyOperatorProdBefore({...input, liveIndexes: [{...liveIndexes[0], state: "CREATING"},
    ...liveIndexes.slice(1)]}), error);
  assert.throws(() => verifyOperatorProdBefore({...input, liveFields: liveFields.slice(1)}), error);
  assert.throws(() => verifyOperatorProdBefore({...input, liveFields: [...liveFields,
    {...liveFields[0], name: liveFields[0].name.replace("/fields/", "/fields/unreviewed-")}]}), error);
  assert.throws(() => verifyOperatorProdBefore({...input, liveFields: liveFields.map((field, index) =>
    index === 3 ? {...field, ttlConfig: {state: "ACTIVE", expirationOffset: "86400s"}} : field)}), error);
  assert.equal(verifyOperatorProdBefore({...input, liveFields: [...liveFields.map((field) => ({
    ...field, indexConfig: {...field.indexConfig,
      indexes: field.indexConfig.indexes.length ? [...field.indexConfig.indexes].reverse() : undefined,
      usesAncestorConfig: undefined}})),
  {name: "projects/catch-dating-app-64e51/databases/(default)/collectionGroups/__default__/fields/*",
    indexConfig: {indexes: []}}]}).missingAdditions, 0);
});

test("mixed-source receipt preserves 574 prior identities and only stamps four new deployments", () => {
  const {additions} = prepared();
  const selected = new Set(release.targets);
  const after = baselineLive.map((fn, index) => selected.has(targets[index]) ?
    liveFunction(targets[index], index, "revision-2") : fn);
  const candidateDeployment = {schema: "catch.firebase-functions-deployment/v1", scope,
    provenance: {sourceSha: release.candidateSha}, targets: [...release.targets],
    functions: captureFunctionIdentities(after, scope, release.targets)};
  const input = {baselineDeployment, candidateDeployment, candidateIndexes, additions,
    liveFunctions: after, liveIndexes, liveFields};
  const receipt = completeOperatorProdRelease(input);
  assert.equal(receipt.functions.filter((row) => row.sourceSha === release.candidateSha).length, 4);
  assert.equal(receipt.functions.filter((row) => row.sourceSha === release.baselineSha).length, 574);
  assert.equal(receipt.addedIndexCount, 5);
  assert.throws(() => completeOperatorProdRelease({...input, liveFunctions: after.map((fn, index) =>
    !selected.has(targets[index]) && index === 4 ? liveFunction(targets[index], index, "revision-3") : fn)}), error);
});

test("protected snapshot asks Google APIs only for deployment identity fields", async () => {
  const fn = liveFunction(release.targets[0], 0);
  const calls = [];
  const request = async (url, options) => {
    calls.push(url);
    assert.equal(options.headers.Authorization, "Bearer fake-workflow-token");
    const body = url.startsWith("https://cloudfunctions.googleapis.com/") ?
      {functions: [{...fn, runService: undefined}]} :
      url.startsWith("https://firestore.googleapis.com/") ? {fields: []} : fn.runService;
    return {ok: true, json: async () => body};
  };
  const snapshot = await readOperatorProdSnapshot([release.targets[0]], {
    runCommand: () => ({status: 0, stdout: "fake-workflow-token\n"}),
    request, listIndexes: () => [],
  });
  assert.equal(snapshot.functions.length, 1);
  assert.deepEqual(snapshot.fields, []);
  assert.equal(calls.length, 3);
  assert.ok(calls.every((url) => url.includes("fields=")));
  assert.ok(calls.every((url) => !url.includes("environmentVariables") && !url.includes("secret")));
});
