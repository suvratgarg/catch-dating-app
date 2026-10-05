import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import {fileURLToPath} from "node:url";
import {captureFunctionIdentities} from "./firebase_functions_checkpoint.mjs";
import {gcloudIndexList, indexSignature} from "../firebase/wait_firestore_indexes_ready.mjs";

// One reviewed release, pinned to the immutable CI package. This module does
// not authorize a general manual target selector or rewrite the package plan.
export const OPERATOR_PROD_RELEASE = Object.freeze({
  baselineSha: "647e39e4476693d6565318cb1d5c5223f3b781f7",
  candidateSha: "656f093d1910afdbe4d93d31565d1782c39aab63",
  packageBaseSha: "ea518ad0576829dbc505293d4edbd9f6710a2b8f",
  sourceCiRunId: "37247348530",
  sourceCiRunAttempt: "1",
  packageSha256: "8d96961ceca63f4959b25097168ebddf01cb5280568f1b09829421c0ef089af1",
  baselineCheckpointArtifactId: 11311489270,
  baselineCheckpointDigest: "sha256:fd120a9874da4c2fb3e0016e7bbdfbef3a8c818bc873f69f403c3575eaa853ff",
  indexAdditionsSha256: "3f217fe07f72d743129deaa5e4b5c85be9df7df538a87f06044331c3b723ccb7",
  targets: Object.freeze([
    "functions:getOrganizerFormResponseDetail",
    "functions:listOrganizerAttentionItems",
    "functions:listOrganizerFormResponses",
    "functions:submitOrganizerFormResponse",
  ]),
});

const scope = "firebase:prod:catch-dating-app-64e51";
const hash = (value) => createHash("sha256").update(JSON.stringify(value)).digest("hex");
const ordered = (value) => [...value].sort();
const eq = (a, b) => JSON.stringify(a) === JSON.stringify(b);
const fail = () => { throw new Error("Invalid bounded PROD operator release evidence."); };
const safe = (action) => { try { return action(); } catch { return fail(); } };

function indexDelta(baseline, candidate) {
  assert.ok(Array.isArray(baseline?.indexes) && Array.isArray(candidate?.indexes));
  assert.deepEqual(candidate.fieldOverrides, baseline.fieldOverrides);
  const prior = new Set(baseline.indexes.map((index) => JSON.stringify(index)));
  const next = new Set(candidate.indexes.map((index) => JSON.stringify(index)));
  assert.equal(prior.size, baseline.indexes.length);
  assert.equal(next.size, candidate.indexes.length);
  assert.ok([...prior].every((entry) => next.has(entry)));
  const additions = candidate.indexes.filter((index) => !prior.has(JSON.stringify(index)));
  assert.equal(additions.length, 5);
  assert.equal(hash(additions), OPERATOR_PROD_RELEASE.indexAdditionsSha256);
  return additions;
}

function baselineReceipt(proof) {
  assert.equal(proof.schema, "catch.firebase-functions-deployment/v1");
  assert.equal(proof.scope, scope);
  assert.equal(proof.provenance?.sourceSha, OPERATOR_PROD_RELEASE.baselineSha);
  assert.equal(proof.targets?.length, 578);
  assert.deepEqual(proof.targets, ordered(proof.targets));
  assert.equal(new Set(proof.targets).size, proof.targets.length);
  assert.equal(proof.functions?.length, proof.targets.length);
  assert.ok(OPERATOR_PROD_RELEASE.targets.every((target) => proof.targets.includes(target)));
  proof.functions.forEach((identity, index) => assert.equal(identity?.name,
    `projects/catch-dating-app-64e51/locations/asia-south1/functions/${proof.targets[index].slice(10)}`));
  return proof;
}

export function prepareOperatorProdRelease({packagePlan, baselineIndexes, candidateIndexes, baselineDeployment}) {
  return safe(() => {
    const release = OPERATOR_PROD_RELEASE;
    assert.equal(packagePlan.sourceSha, release.candidateSha);
    assert.equal(packagePlan.baseSha, release.packageBaseSha);
    assert.equal(packagePlan.sourceCiRunId, release.sourceCiRunId);
    assert.equal(packagePlan.sourceCiRunAttempt, release.sourceCiRunAttempt);
    assert.deepEqual(packagePlan.stages, ["firestore-indexes", "functions"]);
    assert.equal(packagePlan.targets?.[0], "firestore:indexes");
    const packageTargets = packagePlan.targets?.[1]?.split(",");
    assert.equal(packageTargets?.length, 578);
    assert.equal(new Set(packageTargets).size, packageTargets.length);
    assert.ok(release.targets.every((target) => packageTargets.includes(target)));
    const prior = baselineReceipt(baselineDeployment);
    assert.deepEqual(ordered(packageTargets), prior.targets);
    const additions = indexDelta(baselineIndexes, candidateIndexes);
    return {
      packagePlan,
      executionPlan: {...packagePlan, targets: ["firestore:indexes", release.targets.join(",")]},
      additions,
      retainedTargetCount: prior.targets.length - release.targets.length,
    };
  });
}

function liveIndexState(candidateIndexes, additions, liveIndexes) {
  assert.ok(Array.isArray(liveIndexes));
  const expected = new Set(candidateIndexes.indexes.map((index) => indexSignature(index, {desired: true})));
  const added = new Set(additions.map((index) => indexSignature(index, {desired: true})));
  const live = new Map();
  for (const index of liveIndexes) {
    const signature = indexSignature(index);
    assert.ok(expected.has(signature), "Unexpected live composite index would be removed.");
    assert.ok(!live.has(signature), "Duplicate live composite index.");
    live.set(signature, String(index.state ?? "UNKNOWN").toUpperCase());
  }
  for (const signature of expected) {
    if (!live.has(signature)) assert.ok(added.has(signature), "Existing index is missing.");
    else assert.equal(live.get(signature), "READY", "Existing index is not ready.");
  }
  return {readyAdditions: [...added].filter((signature) => live.get(signature) === "READY").length,
    missingAdditions: [...added].filter((signature) => !live.has(signature)).length};
}

function fieldOverrideState(candidateIndexes, liveFields) {
  assert.ok(Array.isArray(candidateIndexes.fieldOverrides));
  assert.ok(Array.isArray(liveFields?.indexes) && Array.isArray(liveFields?.ttls));
  const prefix = "projects/catch-dating-app-64e51/databases/(default)/collectionGroups/";
  const nameOf = (field) => {
    assert.ok(typeof field.name === "string" && field.name.startsWith(prefix));
    const match = /^([^/]+)\/fields\/([^/]+)$/.exec(field.name.slice(prefix.length));
    assert.ok(match && match[1] !== "__default__");
    return `${decodeURIComponent(match[1])}/${decodeURIComponent(match[2])}`;
  };
  const actual = new Map();
  for (const field of liveFields.indexes) {
    const name = nameOf(field);
    assert.ok(!actual.has(name) && field.indexConfig?.usesAncestorConfig === false &&
      field.indexConfig.reverting !== true);
    const indexes = field.indexConfig.indexes;
    assert.ok(Array.isArray(indexes));
    const normalized = indexes.map((index) => {
      assert.equal(index.state, "READY");
      assert.equal(index.fields?.length, 1);
      const entry = {queryScope: index.queryScope};
      if (index.fields[0].order) entry.order = index.fields[0].order;
      if (index.fields[0].arrayConfig) entry.arrayConfig = index.fields[0].arrayConfig;
      assert.ok(entry.order || entry.arrayConfig);
      return entry;
    });
    actual.set(name, {indexes: normalized});
  }
  for (const field of liveFields.ttls) {
    const name = nameOf(field);
    assert.equal(field.ttlConfig?.state, "ACTIVE");
    const entry = actual.get(name) ?? {indexes: []};
    assert.ok(entry.ttl !== true);
    entry.ttl = true;
    actual.set(name, entry);
  }
  const expected = new Map(candidateIndexes.fieldOverrides.map((field) =>
    [`${field.collectionGroup}/${field.fieldPath}`, {indexes: field.indexes, ...(field.ttl ? {ttl: true} : {})}]));
  assert.equal(expected.size, candidateIndexes.fieldOverrides.length);
  assert.deepEqual([...actual.entries()].sort(), [...expected.entries()].sort());
}

export function verifyOperatorProdBefore({baselineDeployment, candidateIndexes, additions, liveFunctions, liveIndexes, liveFields}) {
  return safe(() => {
    const prior = baselineReceipt(baselineDeployment);
    const current = captureFunctionIdentities(liveFunctions, scope, prior.targets);
    assert.deepEqual(current, prior.functions);
    fieldOverrideState(candidateIndexes, liveFields);
    return liveIndexState(candidateIndexes, additions, liveIndexes);
  });
}

export function completeOperatorProdRelease({baselineDeployment, candidateDeployment, candidateIndexes,
  additions, liveFunctions, liveIndexes, liveFields}) {
  return safe(() => {
    const prior = baselineReceipt(baselineDeployment);
    assert.equal(candidateDeployment?.schema, "catch.firebase-functions-deployment/v1");
    assert.equal(candidateDeployment.scope, scope);
    assert.equal(candidateDeployment.provenance?.sourceSha, OPERATOR_PROD_RELEASE.candidateSha);
    assert.deepEqual(candidateDeployment.targets, OPERATOR_PROD_RELEASE.targets);
    assert.equal(candidateDeployment.functions?.length, OPERATOR_PROD_RELEASE.targets.length);
    const state = liveIndexState(candidateIndexes, additions, liveIndexes);
    fieldOverrideState(candidateIndexes, liveFields);
    assert.equal(state.missingAdditions, 0);
    const current = captureFunctionIdentities(liveFunctions, scope, prior.targets);
    const selected = new Map(OPERATOR_PROD_RELEASE.targets.map((target, index) => [target, candidateDeployment.functions[index]]));
    const functions = prior.targets.map((target, index) => {
      const identity = current[index];
      if (selected.has(target)) {
        assert.equal(selected.get(target)?.name,
          `projects/catch-dating-app-64e51/locations/asia-south1/functions/${target.slice(10)}`);
        assert.deepEqual(identity, selected.get(target));
        assert.ok(!eq(identity, prior.functions[index]));
        return {target, sourceSha: OPERATOR_PROD_RELEASE.candidateSha, deployment: identity};
      }
      assert.deepEqual(identity, prior.functions[index]);
      return {target, sourceSha: OPERATOR_PROD_RELEASE.baselineSha, deployment: identity};
    });
    return {schema: "catch.operator-prod-selective-receipt/v1", scope,
      packageSha256: OPERATOR_PROD_RELEASE.packageSha256,
      selectedTargets: [...OPERATOR_PROD_RELEASE.targets], retainedTargetCount: 574,
      addedIndexCount: additions.length, functions};
  });
}

// Google partial-response masks keep runtime environment variables and secret
// payloads out of this verifier's response bodies. The fresh token comes from
// the protected GitHub OIDC job; it is never written or logged.
export async function readOperatorProdSnapshot(targets, {runCommand = spawnSync, request = fetch,
  listIndexes = gcloudIndexList, listFields = listOperatorProdFields} = {}) {
  const projectId = "catch-dating-app-64e51";
  assert.deepEqual(targets, [...targets].sort());
  const tokenResult = runCommand("gcloud", ["auth", "print-access-token"],
    {encoding: "utf8", timeout: 30_000, maxBuffer: 1024 * 1024});
  assert.equal(tokenResult.status, 0, "Cannot obtain protected workflow metadata access.");
  const token = String(tokenResult.stdout ?? "").trim();
  assert.ok(token && !/[\r\n]/.test(token), "Invalid protected workflow metadata token.");
  const get = async (url) => {
    const response = await request(url, {headers: {Authorization: `Bearer ${token}`},
      signal: AbortSignal.timeout(30_000)});
    assert.ok(response.ok, `Protected metadata read failed with HTTP ${response.status}.`);
    return response.json();
  };
  const fieldMask = "nextPageToken,functions(name,state,environment,updateTime,buildConfig(build,sourceProvenance(resolvedStorageSource(bucket,object,generation))),serviceConfig(service,revision))";
  const functions = [];
  const seenPages = new Set();
  let page = "";
  do {
    assert.ok(!seenPages.has(page) && seenPages.size < 20, "Invalid Function inventory pagination.");
    seenPages.add(page);
    const query = new URLSearchParams({pageSize: "100", fields: fieldMask});
    if (page) query.set("pageToken", page);
    const result = await get(`https://cloudfunctions.googleapis.com/v2/projects/${projectId}/locations/asia-south1/functions?${query}`);
    assert.ok(Array.isArray(result.functions ?? []), "Invalid Function metadata inventory.");
    functions.push(...(result.functions ?? []));
    page = result.nextPageToken ?? "";
    assert.equal(typeof page, "string");
  } while (page);
  const expectedNames = new Set(targets.map((target) =>
    `projects/${projectId}/locations/asia-south1/functions/${target.slice(10)}`));
  const selected = functions.filter((fn) => expectedNames.has(fn.name));
  assert.equal(selected.length, expectedNames.size, "Selected Function metadata is incomplete.");
  assert.equal(new Set(selected.map((fn) => fn.name)).size, selected.length);
  const serviceFields = "name,uid,generation,observedGeneration,latestReadyRevision,latestCreatedRevision,terminalCondition(state),trafficStatuses(type,revision,percent,tag),reconciling";
  let cursor = 0;
  await Promise.all(Array.from({length: 5}, async () => {
    while (cursor < selected.length) {
      const fn = selected[cursor++];
      assert.match(fn.serviceConfig?.service ?? "", /^projects\/catch-dating-app-64e51\/locations\/asia-south1\/services\/[a-z][a-z0-9-]*$/);
      fn.runService = await get(`https://run.googleapis.com/v2/${fn.serviceConfig.service}?fields=${encodeURIComponent(serviceFields)}`);
    }
  }));
  return {functions: selected, indexes: listIndexes({projectId}), fields: listFields({projectId})};
}

function listOperatorProdFields({projectId}, runCommand = spawnSync) {
  const list = (type) => {
    const result = runCommand("gcloud", ["firestore", ...type, "list", `--project=${projectId}`,
      "--database=(default)", "--format=json", "--quiet"],
    {encoding: "utf8", timeout: 60_000, maxBuffer: 16 * 1024 * 1024});
    assert.equal(result.status, 0, "Cannot list protected Firestore field metadata.");
    const fields = JSON.parse(result.stdout);
    assert.ok(Array.isArray(fields));
    return fields;
  };
  return {indexes: list(["indexes", "fields"]), ttls: list(["fields", "ttls"])};
}

function read(file) { return JSON.parse(fs.readFileSync(file, "utf8")); }
function write(file, value) { fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`, {flag: "wx", mode: 0o600}); }
const options = (args) => {
  const result = {};
  for (let index = 0; index < args.length; index += 2) {
    assert.ok(args[index]?.startsWith("--") && args[index + 1], "Expected --name value pairs.");
    const key = args[index].slice(2);
    assert.ok(!Object.hasOwn(result, key), "Duplicate operator release argument.");
    result[key] = args[index + 1];
  }
  return result;
};
export async function runOperatorProdReleaseCli(argv, {snapshot = readOperatorProdSnapshot} = {}) {
  const [command, ...rest] = argv;
  assert.ok(["prepare", "before", "complete"].includes(command));
  const args = options(rest);
  const baselineDeployment = read(args["baseline-deployment"]);
  const candidateIndexes = read(args["candidate-indexes"]);
  const prepared = prepareOperatorProdRelease({packagePlan: read(args["package-plan"]),
    baselineIndexes: read(args["baseline-indexes"]), candidateIndexes, baselineDeployment});
  if (command === "prepare") {
    write(args["output-plan"], prepared.executionPlan);
    write(args["output-preparation"], {schema: "catch.operator-prod-preparation/v1",
      additions: prepared.additions, retainedTargetCount: prepared.retainedTargetCount});
    return {prepared: true, selectedFunctions: 4, addedIndexes: 5};
  }
  const live = await snapshot(baselineDeployment.targets);
  if (command === "before") return {verifiedBefore: true,
    ...verifyOperatorProdBefore({baselineDeployment, candidateIndexes,
      additions: prepared.additions, liveFunctions: live.functions, liveIndexes: live.indexes,
      liveFields: live.fields})};
  const result = completeOperatorProdRelease({baselineDeployment,
    candidateDeployment: read(args["candidate-deployment"]), candidateIndexes,
    additions: prepared.additions, liveFunctions: live.functions, liveIndexes: live.indexes,
    liveFields: live.fields});
  write(args.output, result);
  return {verifiedComplete: true, selectedFunctions: 4, retainedFunctions: 574, addedIndexes: 5};
}
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  runOperatorProdReleaseCli(process.argv.slice(2)).then((result) => console.log(JSON.stringify(result))).catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
  });
}
