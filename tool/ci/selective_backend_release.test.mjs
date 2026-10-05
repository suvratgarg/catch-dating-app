import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import test from "node:test";
import {createCheckpointState, PROVENANCE_SCHEMA} from "./delivery_core.mjs";
import {FUNCTIONS_DEPLOYMENT_SCHEMA} from "./firebase_functions_checkpoint.mjs";
import {FUNCTION_FINGERPRINT_SCHEMA} from "../firebase/function_release_fingerprints.mjs";
import {additiveIndexChanges, prepareSelectiveRelease, initializeFunctionLedger,
  completeSelectiveRelease, verifyLedgerLiveIdentities} from "./selective_backend_release.mjs";

const hash = (value) => createHash("sha256").update(JSON.stringify(value)).digest("hex");
const clone = structuredClone;
const scope = "firebase:dev:demo-project";
const invalid = /^Error: Invalid selective backend release evidence\.$/;
function manifest(sha, run) {
  return {schema: PROVENANCE_SCHEMA, sourceSha: sha, sourceCiRunId: run, sourceCiRunAttempt: "2",
    artifact: {name: "firebase-backend.tar.gz", sizeBytes: 123, sha256: hash([sha, run])},
    stages: ["firestore-indexes", "functions", "firestore-rules"]};
}
const binding = (m) => ({sourceSha: m.sourceSha, sourceCiRunId: m.sourceCiRunId,
  sourceCiRunAttempt: m.sourceCiRunAttempt, packageSha256: m.artifact.sha256});
function fingerprints(targets, changes = new Set()) {
  return {schema: FUNCTION_FINGERPRINT_SCHEMA, functions: Object.fromEntries(targets.map((target) => {
    const dependencies = [[`index.js#${target.slice(10)}`, hash([target, changes.has(target) ? "changed" : "baseline"])]];
    return [target, {sha256: hash(dependencies), dependencies, unknown: []}];
  }))};
}
function identity(target, generation = "1") {
  const name = target.slice(10);
  return {name: `projects/demo-project/locations/asia-south1/functions/${name}`,
    updateTime: `2026-10-0${generation}T12:00:00.123Z`,
    build: `projects/42/locations/asia-south1/builds/build-${name}-${generation}`,
    source: {bucket: "source-bucket", object: `functions-${generation}.zip`, generation},
    service: `projects/demo-project/locations/asia-south1/services/${name}`,
    revision: `${name}-0000${generation}-abc`, serviceUid: `${name}-uid`, serviceGeneration: generation};
}
function deployment(m, targets, params, baseSha, generation = "1") {
  return {schema: FUNCTIONS_DEPLOYMENT_SCHEMA, scope, provenance: createCheckpointState(m, scope).provenance,
    baseSha, targets, paramsSha256: params, functions: targets.map((target) => identity(target, generation))};
}
const index = {collectionGroup: "records", queryScope: "COLLECTION", fields: [
  {fieldPath: "owner", order: "ASCENDING"}, {fieldPath: "createdAt", order: "DESCENDING"}]};
function fixture({count = 578, changes = 4, addIndex = true} = {}) {
  const targets = Array.from({length: count}, (_, i) => `functions:f${String(i).padStart(4, "0")}`);
  const changed = targets.slice(0, changes);
  const baselineManifest = manifest("f".repeat(40), "100");
  const candidateManifest = manifest("a".repeat(40), "200");
  const baselineFingerprints = fingerprints(targets);
  const candidateFingerprints = fingerprints(targets, new Set(changed));
  const params = hash("normalized fake public params");
  const config = hash("fake runtime and public configuration contract");
  const evidence = (m, f) => ({sourceSha: m.sourceSha, packageSha256: m.artifact.sha256,
    source: clone(f), compiled: clone(f), runtimeConfigurationSha256: config});
  const preparation = {baseline: binding(baselineManifest), candidate: binding(candidateManifest),
    packageBaseSha: "0".repeat(40), baselineEvidence: evidence(baselineManifest, baselineFingerprints),
    candidateEvidence: evidence(candidateManifest, candidateFingerprints), authorizedTargets: targets,
    baselineIndexes: {indexes: [], fieldOverrides: []},
    candidateIndexes: {indexes: addIndex ? [clone(index)] : [], fieldOverrides: []},
    coveredSources: ["e".repeat(40), candidateManifest.sourceSha],
    baselineParamsSha256: params, candidateParamsSha256: params};
  const initialization = {deployment: deployment(baselineManifest, targets, params, "9".repeat(40)),
    manifest: baselineManifest, scope, fingerprints: baselineFingerprints, configSha256: config,
    expectedParamsSha256: params, expectedBaseSha: "9".repeat(40)};
  const ledger = initializeFunctionLedger(initialization);
  const plan = prepareSelectiveRelease(preparation);
  const completion = {plan, preparation, ledger, baselineManifest, manifest: candidateManifest,
    candidateFingerprints, expectedCandidateParamsSha256: params,
    deployment: changed.length ? deployment(candidateManifest, changed, params, preparation.packageBaseSha, "2") : null,
    allLiveIdentities: targets.map((target) => identity(target, changed.includes(target) ? "2" : "1")),
    readyIndexContracts: addIndex ? [clone(index)] : []};
  return {targets, changed, preparation, initialization, completion};
}
function rejectsClone(value, mutate, action) {
  const changed = clone(value); mutate(changed);
  assert.throws(() => action(changed), invalid);
}

test("four changed Functions get candidate provenance while 574 real baseline rows remain byte-identical", () => {
  const f = fixture(); const original = JSON.stringify(f.completion);
  f.completion.allLiveIdentities.reverse();
  const result = completeSelectiveRelease(f.completion);
  assert.deepEqual(result.coverage.deployedTargets, f.changed);
  assert.equal(result.coverage.retainedTargets.length, 574);
  assert.equal(result.ledger.coverageSourceSha, f.completion.manifest.sourceSha);
  for (let i = 0; i < f.targets.length; i++) {
    const row = result.ledger.functions[i]; const before = f.completion.ledger.functions[i];
    if (i >= 4) assert.equal(JSON.stringify(row), JSON.stringify(before));
    else {
      assert.equal(row.sourceSha, f.completion.manifest.sourceSha);
      assert.equal(row.sourceCiRunId, "200"); assert.equal(row.sourceCiRunAttempt, "2");
      assert.equal(row.packageSha256, f.completion.manifest.artifact.sha256);
      assert.notDeepEqual(row.deployment, before.deployment);
    }
  }
  assert.equal(result.coverage.coveredSources.at(-1), f.completion.manifest.sourceSha);
  f.completion.allLiveIdentities.reverse();
  assert.equal(JSON.stringify(f.completion), original);
  result.ledger.functions[4].deployment.source.object = "changed-result-only";
  result.coverage.candidate.sourceCiRunId = "999";
  assert.equal(JSON.stringify(f.completion), original);
});

test("source and compiled evidence, dependency digests and full inventories must agree", () => {
  const {preparation} = fixture({count: 6});
  for (const mutate of [
    (p) => {p.candidateEvidence.compiled.functions["functions:f0000"].sha256 = hash("forged");},
    (p) => {p.baselineEvidence.source.functions["functions:f0000"].dependencies[0][1] = hash("changed");},
    (p) => {p.candidateEvidence.sourceSha = "b".repeat(40);},
    (p) => {p.candidateEvidence.packageSha256 = hash("wrong package");},
    (p) => {p.baselineEvidence.runtimeConfigurationSha256 = hash("runtime drift");},
    (p) => {p.candidateParamsSha256 = hash("changed configuration");},
    (p) => {p.authorizedTargets.reverse();},
    (p) => {p.authorizedTargets.push(p.authorizedTargets[0]);},
    (p) => {delete p.candidateEvidence.compiled.functions["functions:f0005"];},
    (p) => {p.candidateEvidence.source.functions["functions:f0000"].unknown = ["index.js:dynamic-module-load"];
      p.candidateEvidence.compiled = clone(p.candidateEvidence.source);},
  ]) rejectsClone(preparation, mutate, prepareSelectiveRelease);
});

test("source coverage is the exact unique chronological interval ending at candidate", () => {
  const {preparation} = fixture({count: 6});
  // Deliberately not lexical SHA order: only trusted Git ancestry determines order.
  assert.deepEqual(prepareSelectiveRelease(preparation).coveredSources, preparation.coveredSources);
  for (const coveredSources of [[], ["bad"], [preparation.candidate.sourceSha, "e".repeat(40)],
    [preparation.baseline.sourceSha, preparation.candidate.sourceSha],
    [preparation.candidate.sourceSha, preparation.candidate.sourceSha]]) {
    assert.throws(() => prepareSelectiveRelease({...preparation, coveredSources}), invalid);
  }
});

test("completion rederives every plan field and exact evidence digest from independent preparation", () => {
  const {completion} = fixture({count: 6});
  for (const mutate of [
    (c) => {c.plan.fingerprintEvidenceSha256 = hash("forged digest");},
    (c) => {c.plan.targets.pop();},
    (c) => {c.plan.unchangedTargets.reverse();},
    (c) => {c.plan.stages = ["functions"];},
    (c) => {c.plan.indexes = [];},
    (c) => {c.plan.indexContractSha256 = hash("forged index contract");},
    (c) => {c.plan.packageBaseSha = "d".repeat(40);},
    (c) => {c.plan.coveredSources = [c.plan.candidate.sourceSha];},
    (c) => {c.preparation.coveredSources = [c.plan.candidate.sourceSha];},
    (c) => {c.plan.candidate.sourceCiRunAttempt = "3";},
    (c) => {c.plan.baseline.sourceCiRunId = "999";},
    (c) => {c.candidateFingerprints.functions["functions:f0000"] = clone(c.candidateFingerprints.functions["functions:f0001"]);},
  ]) rejectsClone(completion, mutate, completeSelectiveRelease);
});

test("both complete provenance manifests are mandatory including CI run and attempt on no-op", () => {
  for (const changes of [0, 4]) {
    const {completion} = fixture({count: 6, changes, addIndex: false});
    assert.equal(completeSelectiveRelease(completion).coverage.deployedTargets.length, changes);
    for (const field of ["manifest", "baselineManifest"]) {
      for (const mutateManifest of [
        (m) => {m.schema = "unknown";}, (m) => {m.sourceCiRunId = "999";},
        (m) => {m.sourceCiRunAttempt = "3";}, (m) => {m.sourceSha = "b".repeat(40);},
        (m) => {m.artifact.sha256 = hash("wrong");}, (m) => {m.artifact.sizeBytes = -1;},
        (m) => {m.stages = [];}, (m) => {delete m.schema;},
      ]) rejectsClone(completion, (c) => mutateManifest(c[field]), completeSelectiveRelease);
    }
  }
});

test("candidate params and baseline initialization compare independent hashes and bases", () => {
  const {initialization, completion} = fixture({count: 6});
  for (const mutate of [
    (i) => {delete i.expectedParamsSha256;}, (i) => {i.deployment.paramsSha256 = hash("different params");},
    (i) => {i.expectedParamsSha256 = hash("different expected params");},
    (i) => {i.deployment.baseSha = "b".repeat(40);}, (i) => {i.expectedBaseSha = "b".repeat(40);},
  ]) rejectsClone(initialization, mutate, initializeFunctionLedger);
  for (const mutate of [
    (c) => {delete c.expectedCandidateParamsSha256;},
    (c) => {c.expectedCandidateParamsSha256 = hash("different expected params");},
    (c) => {c.deployment.paramsSha256 = hash("different params");},
    (c) => {c.ledger.functions[5].paramsSha256 = hash("different baseline params");},
    (c) => {c.deployment.provenance.sourceCiRunAttempt = "3";},
  ]) rejectsClone(completion, mutate, completeSelectiveRelease);
});

test("all unchanged and selected live identities must match; no drift becomes coverage", () => {
  const {completion} = fixture({count: 6});
  for (const mutate of [
    (c) => {c.allLiveIdentities[5].revision = "unexpected-revision";},
    (c) => {c.allLiveIdentities[0].source.generation = "999";},
    (c) => {c.allLiveIdentities.pop();}, (c) => {c.allLiveIdentities.push(c.allLiveIdentities[0]);},
    (c) => {c.ledger.functions[5].fingerprintSha256 = hash("forged baseline");},
    (c) => {c.deployment.functions[0] = clone(c.ledger.functions[0].deployment);
      c.allLiveIdentities[0] = clone(c.ledger.functions[0].deployment);},
    (c) => {c.deployment.functions[0].service = c.deployment.functions[0].service.replace("demo-project", "foreign-project");},
  ]) rejectsClone(completion, mutate, completeSelectiveRelease);
  assert.equal(verifyLedgerLiveIdentities(completion.ledger, completion.ledger.functions.map((r) => r.deployment)), true);
});

test("indexes allow additions only and all new contracts need independent READY evidence", () => {
  const {completion} = fixture({count: 6});
  assert.deepEqual(additiveIndexChanges({indexes: [], fieldOverrides: []}, {indexes: [index], fieldOverrides: []}), [index]);
  assert.throws(() => additiveIndexChanges({indexes: [index], fieldOverrides: []}, {indexes: [], fieldOverrides: []}), invalid);
  assert.throws(() => additiveIndexChanges({indexes: [], fieldOverrides: []}, {indexes: [],
    fieldOverrides: [{collectionGroup: "records", fieldPath: "expiresAt", ttl: true, indexes: []}]}), invalid);
  for (const mutate of [
    (c) => {c.readyIndexContracts = [];}, (c) => {c.readyIndexContracts.push(clone(index));},
    (c) => {c.readyIndexContracts[0].fields[1].order = "ASCENDING";},
    (c) => {c.readyIndexContracts[0].fields[1].arrayConfig = "CONTAINS";},
  ]) rejectsClone(completion, mutate, completeSelectiveRelease);
});

test("mixed source ledger remains valid as the baseline of another selective release", () => {
  const f = fixture({count: 6, changes: 2});
  const first = completeSelectiveRelease(f.completion);
  const nextManifest = manifest("c".repeat(40), "300");
  const snapshot = fingerprints(f.targets, new Set(f.targets.slice(0, 3)));
  const p = clone(f.preparation);
  p.baseline = binding(f.completion.manifest); p.candidate = binding(nextManifest);
  p.baselineEvidence = clone(p.candidateEvidence);
  p.candidateEvidence = {...clone(p.candidateEvidence), sourceSha: nextManifest.sourceSha,
    packageSha256: nextManifest.artifact.sha256, source: clone(snapshot), compiled: clone(snapshot)};
  p.baselineIndexes = clone(p.candidateIndexes); p.coveredSources = [nextManifest.sourceSha];
  const plan = prepareSelectiveRelease(p);
  assert.deepEqual(plan.targets, [f.targets[2]]);
  const next = completeSelectiveRelease({plan, preparation: p, ledger: first.ledger,
    manifest: nextManifest, baselineManifest: f.completion.manifest, candidateFingerprints: snapshot,
    expectedCandidateParamsSha256: p.candidateParamsSha256, readyIndexContracts: [],
    deployment: deployment(nextManifest, plan.targets, p.candidateParamsSha256, p.packageBaseSha, "3"),
    allLiveIdentities: f.targets.map((target, i) => identity(target, i < 2 ? "2" : i === 2 ? "3" : "1"))});
  for (const i of [0, 1, 3, 4, 5]) assert.deepEqual(next.ledger.functions[i], first.ledger.functions[i]);
  assert.equal(next.ledger.functions[2].sourceCiRunId, "300");
});

test("metadata contracts reject extra payloads and failures never serialize values", () => {
  const {completion, initialization, preparation} = fixture({count: 6});
  const sentinel = "FAKE_PRIVATE_SENTINEL";
  for (const [input, action, mutate] of [
    [preparation, prepareSelectiveRelease, (p) => {p.secretPayload = sentinel;}],
    [preparation, prepareSelectiveRelease, (p) => {p.baselineEvidence.compiled.functions["functions:f0000"].payload = sentinel;}],
    [completion, completeSelectiveRelease, (c) => {c.plan.candidate.payload = sentinel;}],
    [completion, completeSelectiveRelease, (c) => {c.ledger.functions[0].deployment.source.payload = sentinel;}],
    [completion, completeSelectiveRelease, (c) => {c.manifest.artifact.payload = sentinel;}],
    [initialization, initializeFunctionLedger, (i) => {i.fingerprints.payload = sentinel;}],
  ]) {
    const changed = clone(input); mutate(changed);
    assert.throws(() => action(changed), (error) => {
      assert.match(String(error), invalid);
      assert.equal(JSON.stringify(error).includes(sentinel), false);
      assert.equal(error.stack.includes(sentinel), false);
      assert.equal(Object.hasOwn(error, "actual"), false);
      return true;
    });
  }
  const result = completeSelectiveRelease(completion);
  assert.deepEqual(Object.keys(result), ["ledger", "coverage"]);
  assert.equal(JSON.stringify(result).includes("dependencies"), false);
});

test("true no-op retains every physical deployment and does not accept stale deployment proof", () => {
  const {completion} = fixture({count: 6, changes: 0, addIndex: false});
  const result = completeSelectiveRelease(completion);
  assert.deepEqual(result.ledger.functions, completion.ledger.functions);
  assert.deepEqual(result.coverage.deployedTargets, []);
  assert.deepEqual(completion.plan.stages, []);
  assert.throws(() => completeSelectiveRelease({...completion, deployment: {}}), invalid);
});
