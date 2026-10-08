import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {createCheckpointState, recordStageCheckpoint, PROVENANCE_SCHEMA} from "./delivery_core.mjs";
import {FUNCTIONS_DEPLOYMENT_SCHEMA} from "./firebase_functions_checkpoint.mjs";
import {FUNCTION_FINGERPRINT_SCHEMA} from "../firebase/function_release_fingerprints.mjs";
import {additiveIndexChanges, prepareSelectiveRelease, initializeFunctionLedger, initializeMixedFunctionLedger,
  completeSelectiveRelease, verifyLedgerLiveIdentities, assessSelectiveRuntimeImpact,
  prepareMixedImpactRelease, completeMixedImpactRelease,
  prepareBaselineImpactRelease, completeBaselineImpactRelease,
  SELECTIVE_IMPACT_SCHEMA} from "./selective_backend_release.mjs";
import {SALES_PR543_RELEASE, SALES_SOURCE_CHECKPOINT, SALES_SOURCE_DELTA,
  SALES_SOURCE_GUARDED_PATHS, verifySalesSourceCompatibility, checkSalesGitCompatibility,
  runSalesPr543ReleaseCli, checkSalesCheckpointSource} from "./selective_backend_release.mjs";
import "./sales_pr543_release.test.mjs";

const salesSourceEvidence = () => ({sourceSha: SALES_PR543_RELEASE.sourceSha,
  currentSha: SALES_SOURCE_CHECKPOINT, sourceAncestor: true, checkpointAncestor: true,
  changedPaths: SALES_SOURCE_DELTA.map((row) => row.path), currentDifference: [],
  rows: SALES_SOURCE_DELTA.map((row) => ({...row, candidateMode: "100644", checkpointMode: "100644"}))});

test("Sales source compatibility accepts only exact reviewed PR575 blobs", () => {
  assert.deepEqual(verifySalesSourceCompatibility(salesSourceEvidence()), {
    sourceSha: SALES_PR543_RELEASE.sourceSha, compatibilityCheckpoint: SALES_SOURCE_CHECKPOINT,
  });
});

for (const [name, mutate] of [
  ["other immutable source", (e) => {e.sourceSha = "0".repeat(40);} ],
  ["missing source ancestry", (e) => {e.sourceAncestor = false;} ],
  ["missing checkpoint ancestry", (e) => {e.checkpointAncestor = false;} ],
  ["altered operator runtime content", (e) => {e.rows[0].mergedGitBlob = "0".repeat(40);} ],
  ["altered operator test content", (e) => {e.rows[1].mergedGitBlob = "0".repeat(40);} ],
  ["different original blob", (e) => {e.rows[0].candidateGitBlob = "0".repeat(40);} ],
  ["symlink substitution", (e) => {e.rows[0].checkpointMode = "120000";} ],
  ["duplicate row", (e) => {e.rows[1] = e.rows[0];} ],
  ["omitted exact delta", (e) => {e.changedPaths.pop();} ],
  ["extra checkpoint source change", (e) => {e.changedPaths.push("functions/src/new.ts");} ],
  ["new Sales import creating target intersection", (e) => {
    e.currentDifference.push("functions/src/admin/salesIntelligence/runtime.ts");
  } ],
  ["entrypoint initialization creating target intersection", (e) => {
    e.currentDifference.push("functions/src/index.ts");
  } ],
  ["later alteration of an admitted file", (e) => {e.currentDifference.push(SALES_SOURCE_DELTA[0].path);} ],
]) {
  test(`Sales source compatibility rejects ${name}`, () => {
    const e = salesSourceEvidence(); mutate(e);
    assert.throws(() => verifySalesSourceCompatibility(e));
  });
}

for (const guarded of SALES_SOURCE_GUARDED_PATHS) {
  test(`Sales source compatibility retains the guard for ${guarded}`, () => {
    const e = salesSourceEvidence(); e.currentDifference.push(guarded);
    assert.throws(() => verifySalesSourceCompatibility(e));
  });
}

test("Sales source compatibility reads historical Git objects and binds its CLI", async () => {
  const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), "../..");
  const expected = {sourceSha: SALES_PR543_RELEASE.sourceSha, compatibilityCheckpoint: SALES_SOURCE_CHECKPOINT};
  assert.deepEqual(checkSalesGitCompatibility(SALES_PR543_RELEASE.sourceSha, SALES_SOURCE_CHECKPOINT, root), expected);
  assert.deepEqual(await runSalesPr543ReleaseCli(["source", "--source-sha", SALES_PR543_RELEASE.sourceSha,
    "--current-main", SALES_SOURCE_CHECKPOINT, "--source-root", root]), expected);
  // Reviewed parity control plane predates PR575 and cannot borrow its allowance.
  assert.throws(() => checkSalesGitCompatibility(SALES_PR543_RELEASE.sourceSha,
    "b623f19437c1a5caa62edf97bb960c0b9f6a6686", root));
  await assert.rejects(runSalesPr543ReleaseCli(["source", "--source-sha", SALES_PR543_RELEASE.sourceSha,
    "--current-main", SALES_SOURCE_CHECKPOINT, "--source-root", root,
    "--targets", "functions:importWeddingPhoneContacts"]));
});

test("strict Sales source route pins the original run and attempt without permitting replay", () => {
  const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), "../..");
  assert.deepEqual(checkSalesCheckpointSource(SALES_PR543_RELEASE.sourceSha, SALES_SOURCE_CHECKPOINT,
    root, "37576714164", "1"), {checkpointOnly: true});
  for (const [source, run, attempt] of [
    ["0".repeat(40), "37576714164", "1"],
    [SALES_PR543_RELEASE.sourceSha, "37576714165", "1"],
    [SALES_PR543_RELEASE.sourceSha, "37576714164", "2"],
    [SALES_PR543_RELEASE.sourceSha, "", "1"],
  ]) assert.throws(() => checkSalesCheckpointSource(source, SALES_SOURCE_CHECKPOINT, root, run, attempt));
});

test("Sales Git compatibility rejects real altered blobs and new runtime intersections", () => {
  const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), "../..");
  const temporary = fs.mkdtempSync(path.join(os.tmpdir(), "sales-source-compatibility-"));
  const repo = path.join(temporary, "repo");
  const git = (args, options = {}) => {
    const result = spawnSync("git", args, {cwd: repo, encoding: "utf8", timeout: 10000,
      env: {...process.env, GIT_AUTHOR_NAME: "Synthetic test", GIT_AUTHOR_EMAIL: "test@example.invalid",
        GIT_COMMITTER_NAME: "Synthetic test", GIT_COMMITTER_EMAIL: "test@example.invalid"}, ...options});
    assert.equal(result.status, 0, result.stderr);
    return result.stdout.trim();
  };
  try {
    git(["clone", "--shared", "--no-checkout", root, repo], {cwd: temporary});
    for (const [file, appended] of [
      [SALES_SOURCE_DELTA[0].path, "\n// altered operator content\n"],
      [SALES_SOURCE_DELTA[1].path, "\n// altered operator test\n"],
      ["firestore.rules", "\n// unrelated guarded content\n"],
      ["functions/src/admin/salesIntelligence/runtime.ts",
        '\nimport "../../catchMessaging/whatsappOperatorSetup";\n'],
      ["functions/src/index.ts", '\nimport "./catchMessaging/whatsappOperatorSetup";\n'],
    ]) {
      git(["read-tree", SALES_SOURCE_CHECKPOINT]);
      const original = git(["show", `${SALES_SOURCE_CHECKPOINT}:${file}`]);
      const blob = git(["hash-object", "-w", "--stdin"], {input: original + appended});
      git(["update-index", "--add", "--cacheinfo", `100644,${blob},${file}`]);
      const tree = git(["write-tree"]);
      const current = git(["commit-tree", tree, "-p", SALES_SOURCE_CHECKPOINT], {input: "Synthetic guarded drift\n"});
      assert.throws(() => checkSalesGitCompatibility(SALES_PR543_RELEASE.sourceSha, current, repo),
        undefined, `Must reject actual guarded change: ${file}`);
      if (file === "firestore.rules") {
        assert.throws(() => checkSalesCheckpointSource(SALES_PR543_RELEASE.sourceSha, current, repo, "37576714164", "1"));
      } else {
        // Runtime source may advance only in the branch that forbids replay.
        assert.deepEqual(checkSalesCheckpointSource(SALES_PR543_RELEASE.sourceSha, current, repo, "37576714164", "1"),
          {checkpointOnly: true});
      }
    }
  } finally {
    fs.rmSync(temporary, {recursive: true, force: true});
  }
});

const hash = (value) => createHash("sha256").update(JSON.stringify(value)).digest("hex");
const clone = structuredClone;
const scope = "firebase:dev:demo-project";
const invalid = /^Error: Invalid selective backend release evidence\.$/;
function liveMetadata(row) {
  const revision = `${row.service}/revisions/${row.revision}`;
  return {name: row.name, state: "ACTIVE", environment: "GEN_2", updateTime: row.updateTime,
    buildConfig: {build: row.build, sourceProvenance: {resolvedStorageSource: clone(row.source)}},
    serviceConfig: {service: row.service, revision: row.revision},
    runService: {name: row.service, uid: row.serviceUid, generation: row.serviceGeneration,
      observedGeneration: row.serviceGeneration, latestReadyRevision: revision, latestCreatedRevision: revision,
      terminalCondition: {state: "CONDITION_SUCCEEDED"},
      trafficStatuses: [{type: "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST", percent: 100}]}};
}
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

function mixedFixture({count = 578, changes = 4} = {}) {
  const f = fixture({count, changes});
  const initial = f.initialization.deployment;
  const promoted = f.completion.deployment;
  const selected = new Map(f.changed.map((target, index) => [target, promoted.functions[index]]));
  const input = {scope, baseline: {manifest: f.initialization.manifest, deployment: initial,
    evidence: f.preparation.baselineEvidence, paramsSha256: f.initialization.expectedParamsSha256,
    baseSha: f.initialization.expectedBaseSha},
  operator: {manifest: f.completion.manifest, deployment: promoted,
    evidence: f.preparation.candidateEvidence, paramsSha256: f.completion.expectedCandidateParamsSha256,
    baseSha: f.preparation.packageBaseSha},
  receipt: {schema: "catch.operator-prod-selective-receipt/v1", scope,
    packageSha256: f.completion.manifest.artifact.sha256,
    selectedTargets: f.changed, retainedTargetCount: count - changes, addedIndexCount: 1,
    functions: f.targets.map((target, index) => ({target,
      sourceSha: selected.has(target) ? f.completion.manifest.sourceSha : f.initialization.manifest.sourceSha,
      deployment: clone(selected.get(target) ?? initial.functions[index])}))},
  allLiveIdentities: clone(f.completion.allLiveIdentities)};
  return {f, input};
}
test("operator receipt initializes four promoted rows and retains 574 prior source and params bindings", () => {
  const {f, input} = mixedFixture();
  const initial = f.initialization.deployment;
  const before = JSON.stringify(input);
  const ledger = initializeMixedFunctionLedger(input);
  assert.equal(ledger.coverageSourceSha, f.initialization.manifest.sourceSha);
  assert.equal(ledger.functions.filter((row) => row.sourceSha === f.completion.manifest.sourceSha).length, 4);
  for (let i = 4; i < ledger.functions.length; i++) {
    assert.equal(ledger.functions[i].sourceSha, f.initialization.manifest.sourceSha);
    assert.equal(ledger.functions[i].paramsSha256, f.initialization.expectedParamsSha256);
    assert.deepEqual(ledger.functions[i].deployment, initial.functions[i]);
  }
  assert.equal(JSON.stringify(input), before);
  for (const mutate of [
    (p) => {p.receipt.packageSha256 = hash("unrelated package");},
    (p) => {p.receipt.functions[0].deployment = clone(initial.functions[0]);},
    (p) => {p.receipt.functions[4].sourceSha = p.operator.manifest.sourceSha;},
    (p) => {p.operator.paramsSha256 = hash("different params");},
    (p) => {p.operator.evidence.runtimeConfigurationSha256 = hash("different runtime");},
    (p) => {p.operator.evidence.source.functions[f.targets[0]].unknown = ["index.js:dynamic-module-load"];
      p.operator.evidence.compiled = clone(p.operator.evidence.source);},
    (p) => {p.allLiveIdentities[0] = clone(initial.functions[0]);},
    (p) => {p.receipt.retainedTargetCount = 578;},
    (p) => {p.receipt.secretPayload = "FAKE_PRIVATE_SENTINEL";},
  ]) rejectsClone(input, mutate, initializeMixedFunctionLedger);
});

function mixedCompletionFixture({count = 6, changes = 2} = {}) {
  const {f, input: initialization} = mixedFixture({count, changes});
  const added = `functions:f${String(count).padStart(4, "0")}`;
  const candidateManifest = manifest("c".repeat(40), "300");
  const candidateTargets = [...f.targets, added];
  const candidateFingerprints = fingerprints(candidateTargets, new Set([...f.changed, added]));
  const candidateEvidence = {sourceSha: candidateManifest.sourceSha,
    packageSha256: candidateManifest.artifact.sha256,
    source: clone(candidateFingerprints), compiled: clone(candidateFingerprints),
    runtimeConfigurationSha256: f.preparation.baselineEvidence.runtimeConfigurationSha256};
  const selectedTargets = [...f.changed, added];
  const preparation = {initialization, impactInput: {baseline: f.preparation.baseline,
    candidate: binding(candidateManifest), baselineEvidence: f.preparation.baselineEvidence,
    candidateEvidence, baselineTargets: f.targets, candidateTargets,
    baselineLockSha256: hash("prior lock"), candidateLockSha256: hash("candidate lock"),
    selectedTargets}, candidateManifest, candidateBaseSha: "1".repeat(40),
  candidateParamsSha256: f.initialization.expectedParamsSha256,
  baselineIndexes: f.preparation.baselineIndexes, operatorIndexes: f.preparation.candidateIndexes,
  candidateIndexes: clone(f.preparation.candidateIndexes)};
  const plan = prepareMixedImpactRelease(preparation);
  const completion = {preparation, plan,
    candidateDeployment: deployment(candidateManifest, selectedTargets,
      preparation.candidateParamsSha256, preparation.candidateBaseSha, "3"),
    allLiveIdentities: candidateTargets.map((target) => identity(target, selectedTargets.includes(target) ? "3" : "1"))};
  return {f, added, candidateManifest, candidateTargets, selectedTargets, completion};
}
test("mixed ledger completion updates exact selected identities and keeps deferred rows heterogeneous", () => {
  const {f, candidateManifest, candidateTargets, selectedTargets, completion} = mixedCompletionFixture();
  assert.deepEqual(completion.plan.selectedTargets, selectedTargets);
  assert.deepEqual(completion.plan.deferredImpactedTargets, f.targets.slice(2));
  assert.deepEqual(completion.plan.retainedDeploymentTargets, f.targets.slice(2));
  // Independently calculated canonical JSON digests of this synthetic fixture.
  assert.equal(completion.plan.impactInputSha256, "d613a3cc47111ed4cf80ed1438e089408a08265301bd435500ed478be00c2ffe");
  assert.equal(completion.plan.indexContractSha256, "0c54fdec6efa089165bc60c26015818d518d3adce072d0f817457f3a2b4da2d1");
  const before = JSON.stringify(completion);
  const result = completeMixedImpactRelease(completion);
  assert.equal(result.ledger.coverageSourceSha, f.initialization.manifest.sourceSha);
  assert.deepEqual(result.coverage.selectedTargets, selectedTargets);
  assert.deepEqual(result.coverage.deferredImpactedTargets, f.targets.slice(2));
  assert.equal(result.ledger.functions.length, 7);
  for (const row of result.ledger.functions.slice(2, 6)) {
    assert.equal(row.sourceSha, f.initialization.manifest.sourceSha);
    assert.equal(row.packageSha256, f.initialization.manifest.artifact.sha256);
  }
  for (const row of [...result.ledger.functions.slice(0, 2), result.ledger.functions[6]])
    assert.equal(row.sourceSha, candidateManifest.sourceSha);
  assert.equal(JSON.stringify(completion), before);
  for (const mutate of [
    (c) => {c.plan.selectedTargets = [...candidateTargets];},
    (c) => {c.candidateDeployment.targets = [...candidateTargets];},
    (c) => {c.allLiveIdentities[2] = identity(f.targets[2], "2");},
    (c) => {c.preparation.candidateParamsSha256 = hash("other params");},
    (c) => {c.preparation.candidateIndexes.indexes.push({...index, collectionGroup: "extra"});},
    (c) => {c.preparation.initialization.receipt.addedIndexCount = 2;},
    (c) => {c.preparation.initialization.receipt.functions[2].sourceSha = candidateManifest.sourceSha;},
    (c) => {c.preparation.impactInput.selectedTargets.pop();},
    (c) => {c.preparation.impactInput.candidateEvidence.source.functions[f.targets[0]].unknown =
      ["index.js:dynamic-module-load"]; c.preparation.impactInput.candidateEvidence.compiled =
      clone(c.preparation.impactInput.candidateEvidence.source);},
  ]) rejectsClone(completion, mutate, completeMixedImpactRelease);
});

test("mixed completion rejects substituted candidate dependencies under the original approved plan", () => {
  const {f, completion} = mixedCompletionFixture();
  const before = JSON.stringify(completion);
  rejectsClone(completion, (c) => {
    const row = c.preparation.impactInput.candidateEvidence.source.functions[f.targets[0]];
    row.dependencies[0][1] = hash("different candidate evidence");
    row.sha256 = hash(row.dependencies);
    c.preparation.impactInput.candidateEvidence.compiled = clone(c.preparation.impactInput.candidateEvidence.source);
  }, completeMixedImpactRelease);
  assert.equal(JSON.stringify(completion), before);
  assert.equal(completeMixedImpactRelease(completion).ledger.functions.length, 7);
});

test("mixed completion rejects substituted index contracts even when receipt counts still match", () => {
  const {completion} = mixedCompletionFixture();
  const before = JSON.stringify(completion);
  rejectsClone(completion, (c) => {
    c.preparation.operatorIndexes.indexes[0].collectionGroup = "substituted";
    c.preparation.candidateIndexes.indexes[0].collectionGroup = "substituted";
  }, completeMixedImpactRelease);
  assert.equal(JSON.stringify(completion), before);
  assert.equal(completeMixedImpactRelease(completion).ledger.functions.length, 7);
});

test("mixed preparation rejects a deferred addition before any selected deployment", () => {
  const {completion} = mixedCompletionFixture();
  const before = JSON.stringify(completion);
  rejectsClone(completion.preparation, (p) => {p.impactInput.selectedTargets.pop();}, prepareMixedImpactRelease);
  assert.equal(JSON.stringify(completion), before);
  assert.equal(completeMixedImpactRelease(completion).ledger.functions.length, 7);
});

test("mixed 578-to-579 fixture retains 574 exact rows and normalizes index aliases in the plan", () => {
  const {completion} = mixedCompletionFixture({count: 578, changes: 4});
  const before = JSON.stringify(completion);
  const prior = initializeMixedFunctionLedger(completion.preparation.initialization);
  const result = completeMixedImpactRelease(completion);
  assert.equal(result.ledger.functions.length, 579);
  assert.equal(result.coverage.selectedTargets.length, 5);
  assert.equal(result.coverage.deferredImpactedTargets.length, 574);
  assert.equal(result.ledger.coverageSourceSha, prior.coverageSourceSha);
  assert.deepEqual(result.ledger.functions.slice(4, 578), prior.functions.slice(4));
  for (const row of [...result.ledger.functions.slice(0, 4), result.ledger.functions[578]]) {
    assert.equal(row.sourceSha, completion.preparation.candidateManifest.sourceSha);
    assert.equal(row.paramsSha256, completion.preparation.candidateParamsSha256);
  }
  const equivalent = clone(completion);
  for (const inventory of [equivalent.preparation.operatorIndexes, equivalent.preparation.candidateIndexes]) {
    const field = inventory.indexes[0].fields[0];
    field.mode = field.order; delete field.order;
  }
  assert.deepEqual(prepareMixedImpactRelease(equivalent.preparation), completion.plan);
  assert.deepEqual(completeMixedImpactRelease(equivalent), result);
  assert.equal(JSON.stringify(completion), before);
});

function baselineAdapterFixture(t, {count = 6, changes = 2} = {}) {
  const {f, completion: mixed, selectedTargets} = mixedCompletionFixture({count, changes});
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-baseline-adapter-"));
  t.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  const paramsFile = path.join(directory, ".env.demo-project");
  fs.writeFileSync(paramsFile, JSON.stringify("normalized fake public params"));
  const baseline = mixed.preparation.initialization.baseline;
  let checkpoint = createCheckpointState(baseline.manifest, scope);
  for (const stage of baseline.manifest.stages) checkpoint = recordStageCheckpoint({
    manifest: baseline.manifest, state: checkpoint, scope, stage, status: "passed"}).state;
  const entries = {"checkpoint.json": checkpoint, "functions-deployment.json": baseline.deployment};
  for (const [name, value] of Object.entries(entries)) fs.writeFileSync(path.join(directory, name), JSON.stringify(value));
  const archive = path.join(directory, "baseline.zip");
  const zipped = spawnSync("zip", ["-q", archive, ...Object.keys(entries)], {cwd: directory, encoding: "utf8"});
  assert.equal(zipped.status, 0, zipped.stderr);
  const bytes = fs.readFileSync(archive);
  const artifactDigest = `sha256:${createHash("sha256").update(bytes).digest("hex")}`;
  const run = {id: 900, run_attempt: 1, workflow_id: 88, path: ".github/workflows/backend-rebaseline.yml",
    event: "workflow_dispatch", head_branch: "main", head_sha: baseline.manifest.sourceSha,
    status: "completed", conclusion: "success", repository: {id: 42, full_name: "owner/catch"},
    head_repository: {id: 42, full_name: "owner/catch"}};
  const artifact = {id: 123, name: `firebase-checkpoint-dev-demo-project-${baseline.manifest.sourceSha}-1`,
    digest: artifactDigest, expired: false, workflow_run: {id: 900, head_branch: "main", head_sha: run.head_sha,
      repository_id: 42, head_repository_id: 42}};
  const responses = new Map([
    ["repos/owner/catch/actions/runs/900/attempts/1", run],
    ["repos/owner/catch/actions/workflows/backend-rebaseline.yml", {id: 88, path: run.path}],
    ["repos/owner/catch/actions/artifacts/123", artifact],
    ["repos/owner/catch/actions/artifacts/123/zip", bytes],
  ]);
  const candidateManifest = {...mixed.preparation.candidateManifest, stages: ["functions"]};
  const additions = Array.from({length: 5}, (_, i) => ({...clone(index), collectionGroup: `added${i}`}));
  const preparation = {baselineArchive: {repository: "owner/catch", repositoryId: 42, runId: "900",
    runAttempt: "1", artifactId: 123, artifactDigest},
    baseline: {manifest: baseline.manifest, evidence: baseline.evidence,
      paramsSha256: baseline.paramsSha256, baseSha: baseline.baseSha}, scope,
    impactInput: mixed.preparation.impactInput, candidateManifest,
    candidateBaseSha: mixed.preparation.candidateBaseSha, paramsFile,
    baselineIndexes: {indexes: [], fieldOverrides: []}, candidateIndexes: {indexes: additions, fieldOverrides: []}};
  const candidateDeployment = deployment(candidateManifest, selectedTargets, baseline.paramsSha256,
    preparation.candidateBaseSha, "3");
  const beforeFunctions = baseline.deployment.functions.map(liveMetadata);
  const afterFunctions = mixed.allLiveIdentities.map(liveMetadata);
  const liveIndexes = additions.map((entry, i) => ({...clone(entry), state: "READY",
    name: `projects/demo-project/databases/(default)/collectionGroups/${entry.collectionGroup}/indexes/i${i}`,
    fields: [...clone(entry.fields), {fieldPath: "__name__", order: "DESCENDING"}]}));
  const dependencies = {request: async (endpoint) => {
    assert.ok(responses.has(endpoint), `Unexpected GitHub read: ${endpoint}`);
    const value = responses.get(endpoint); return Buffer.isBuffer(value) ? Buffer.from(value) : clone(value);
  }, readFunctions: async (projectId, targets, options) => {
    assert.equal(projectId, "demo-project");
    if (options) {assert.deepEqual(options.absentTargets,
      preparation.impactInput.candidateTargets.filter((target) => !f.targets.includes(target))); return clone(beforeFunctions);}
    assert.deepEqual(targets, preparation.impactInput.candidateTargets); return clone(afterFunctions);
  }, readIndexes: async (query) => {
    assert.deepEqual(query, {projectId: "demo-project", database: "(default)"}); return clone(liveIndexes);
  }};
  return {f, preparation, candidateDeployment, beforeFunctions, afterFunctions, liveIndexes, dependencies, run, artifact, responses};
}

test("authenticated baseline adapter selects five, preserves 574 and keeps index readiness outside Functions authority", async (t) => {
  const f = baselineAdapterFixture(t, {count: 578, changes: 4});
  const original = JSON.stringify(f.preparation);
  const plan = await prepareBaselineImpactRelease(f.preparation, f.dependencies);
  assert.deepEqual(plan.stages, ["functions"]);
  assert.equal(plan.indexReadiness.indexes.length, 5);
  assert.equal(plan.selectedTargets.length, 5);
  assert.equal(plan.deferredImpactedTargets.length, 574);
  const result = await completeBaselineImpactRelease({preparation: f.preparation, plan,
    candidateDeployment: f.candidateDeployment}, f.dependencies);
  const prior = initializeFunctionLedger({...f.f.initialization});
  assert.equal(result.ledger.functions.length, 579);
  assert.equal(result.ledger.coverageSourceSha, prior.coverageSourceSha);
  assert.deepEqual(result.ledger.functions.slice(4, 578), prior.functions.slice(4));
  assert.equal(result.coverage.indexReadiness.readyIndexCount, 5);
  for (const row of [...result.ledger.functions.slice(0, 4), result.ledger.functions[578]])
    assert.equal(row.sourceSha, f.preparation.candidateManifest.sourceSha);
  assert.equal(JSON.stringify(f.preparation), original);
});

test("baseline adapter rejects stale serving identities, materialized params and invented operator receipts", async (t) => {
  const f = baselineAdapterFixture(t);
  for (const mutate of [
    (p) => {p.receipt = {schema: "catch.operator-prod-selective-receipt/v1"};},
    (p) => {p.baseline.operator = clone(p.baseline);},
    (p) => {p.baselineArchive.artifactDigest = `sha256:${hash("forged")}`;},
    (p) => {p.impactInput.selectedTargets.pop();},
    (p) => {p.candidateManifest.stages.push("firestore-indexes");},
    (p) => {p.candidateIndexes.fieldOverrides.push({collectionGroup: "records", fieldPath: "expiresAt", ttl: true, indexes: []});},
  ]) {const p = clone(f.preparation); mutate(p); await assert.rejects(prepareBaselineImpactRelease(p, f.dependencies), invalid);}
  for (const mutate of [
    (rows) => {rows[0].runService.generation = "2";},
    (rows) => {rows[0].runService.latestReadyRevision += "-stale";},
    (rows) => {rows.push(liveMetadata(identity(f.preparation.impactInput.candidateTargets.at(-1))));},
  ]) {
    const rows = clone(f.beforeFunctions); mutate(rows);
    await assert.rejects(prepareBaselineImpactRelease(f.preparation, {...f.dependencies,
      readFunctions: async () => rows}), invalid);
  }
  const plan = await prepareBaselineImpactRelease(f.preparation, f.dependencies);
  const completion = {preparation: f.preparation, plan, candidateDeployment: f.candidateDeployment};
  for (const mutate of [
    (rows) => {rows[2].buildConfig.build += "-drift";},
    (rows) => {rows[0] = clone(f.beforeFunctions[0]);},
    (rows) => {rows.pop();},
  ]) {
    const rows = clone(f.afterFunctions); mutate(rows);
    await assert.rejects(completeBaselineImpactRelease(completion, {...f.dependencies, readFunctions: async () => rows}), invalid);
  }
  fs.appendFileSync(f.preparation.paramsFile, "FAKE_PRIVATE_SENTINEL");
  for (const action of [() => prepareBaselineImpactRelease(f.preparation, f.dependencies),
    () => completeBaselineImpactRelease(completion, f.dependencies)]) await assert.rejects(action(), invalid);
});

test("baseline adapter detects params drift during fresh collection and refuses symlinked params", async (t) => {
  for (const completing of [false, true]) {
    const f = baselineAdapterFixture(t);
    const plan = await prepareBaselineImpactRelease(f.preparation, f.dependencies);
    const dependencies = {...f.dependencies, readFunctions: async (...args) => {
      const result = await f.dependencies.readFunctions(...args);
      fs.appendFileSync(f.preparation.paramsFile, "FAKE_PRIVATE_SENTINEL"); return result;
    }};
    await assert.rejects(completing ? completeBaselineImpactRelease({preparation: f.preparation,
      plan, candidateDeployment: f.candidateDeployment}, dependencies) :
      prepareBaselineImpactRelease(f.preparation, dependencies), invalid);
  }
  const f = baselineAdapterFixture(t);
  const original = `${f.preparation.paramsFile}.original`;
  fs.renameSync(f.preparation.paramsFile, original);
  fs.symlinkSync(original, f.preparation.paramsFile);
  await assert.rejects(prepareBaselineImpactRelease(f.preparation, f.dependencies), invalid);
});

test("baseline adapter revalidates selected and deferred evidence after asynchronous collectors", async (t) => {
  const archiveMutation = baselineAdapterFixture(t);
  await assert.rejects(prepareBaselineImpactRelease(archiveMutation.preparation,
    {...archiveMutation.dependencies, request: async (...args) => {
      const response = await archiveMutation.dependencies.request(...args);
      if (args[0].endsWith("/zip")) archiveMutation.preparation.baselineArchive.repositoryId = 99;
      return response;
    }}), invalid);
  for (const completing of [false, true]) for (const target of ["functions:f0000", "functions:f0002"]) {
    const f = baselineAdapterFixture(t);
    const plan = await prepareBaselineImpactRelease(f.preparation, f.dependencies);
    const dependencies = {...f.dependencies, readFunctions: async (...args) => {
      const result = await f.dependencies.readFunctions(...args);
      const row = f.preparation.impactInput.candidateEvidence.source.functions[target];
      row.dependencies[0][1] = hash("substitution during collector"); row.sha256 = hash(row.dependencies);
      f.preparation.impactInput.candidateEvidence.compiled = clone(f.preparation.impactInput.candidateEvidence.source);
      return result;
    }};
    await assert.rejects(completing ? completeBaselineImpactRelease({preparation: f.preparation, plan,
      candidateDeployment: f.candidateDeployment}, dependencies) : prepareBaselineImpactRelease(f.preparation, dependencies), invalid);
  }
  for (const mutate of [
    (f, plan) => {f.preparation.candidateIndexes.indexes.pop(); plan.indexReadiness.indexes.pop();},
    (f, plan) => {f.preparation.candidateManifest.stages.push("firestore-indexes"); plan.stages.push("firestore-indexes");},
    (f) => {f.preparation.baselineArchive.repositoryId = 99;},
    (f) => {f.preparation.receipt = {schema: "catch.operator-prod-selective-receipt/v1"};},
  ]) {
    const f = baselineAdapterFixture(t);
    const plan = await prepareBaselineImpactRelease(f.preparation, f.dependencies);
    await assert.rejects(completeBaselineImpactRelease({preparation: f.preparation, plan,
      candidateDeployment: f.candidateDeployment}, {...f.dependencies, readIndexes: async (...args) => {
        const rows = await f.dependencies.readIndexes(...args); mutate(f, plan); return rows;
      }}), invalid);
  }
});

test("baseline completion binds deferred fingerprints, requires the addition and rejects wrong index scope or readiness", async (t) => {
  const f = baselineAdapterFixture(t);
  const plan = await prepareBaselineImpactRelease(f.preparation, f.dependencies);
  const completion = {preparation: f.preparation, plan, candidateDeployment: f.candidateDeployment};
  for (const mutate of [
    (c) => {const row = c.preparation.impactInput.candidateEvidence.source.functions["functions:f0002"];
      row.dependencies[0][1] = hash("substituted deferred closure"); row.sha256 = hash(row.dependencies);
      c.preparation.impactInput.candidateEvidence.compiled = clone(c.preparation.impactInput.candidateEvidence.source);},
    (c) => {c.preparation.candidateIndexes.indexes[0].collectionGroup = "substitution";},
    (c) => {c.plan.stages.push("firestore-indexes");},
    (c) => {c.candidateDeployment.targets.pop(); c.candidateDeployment.functions.pop();},
  ]) {const c = clone(completion); mutate(c); await assert.rejects(completeBaselineImpactRelease(c, f.dependencies), invalid);}
  for (const mutate of [
    (rows) => {rows.pop();},
    (rows) => {rows[0].state = "CREATING";},
    (rows) => {rows[0].name = rows[0].name.replace("demo-project", "foreign-project");},
    (rows) => {rows[0].name = rows[0].name.replace("(default)", "other-database");},
    (rows) => {rows[0].name = rows[0].name.replace("collectionGroups/added0", "collectionGroups/other");},
    (rows) => {rows[0].fields[0].order = "DESCENDING";},
  ]) {
    const rows = clone(f.liveIndexes); mutate(rows);
    await assert.rejects(completeBaselineImpactRelease(completion, {...f.dependencies, readIndexes: async () => rows}), invalid);
  }
  const deferred = clone(f.preparation);
  deferred.impactInput.candidateEvidence.source.functions["functions:f0002"].unknown = ["index.js:dynamic-module-load"];
  deferred.impactInput.candidateEvidence.compiled = clone(deferred.impactInput.candidateEvidence.source);
  const deferredPlan = await prepareBaselineImpactRelease(deferred, f.dependencies);
  const result = await completeBaselineImpactRelease({...completion, preparation: deferred, plan: deferredPlan}, f.dependencies);
  assert.deepEqual(result.ledger.functions[2], initializeFunctionLedger(f.f.initialization).functions[2]);
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

test("runtime lock drift stays explicit across a bounded selector and an added export", () => {
  const f = fixture({count: 6, changes: 2, addIndex: false});
  const added = "functions:f0006";
  const input = {baseline: f.preparation.baseline, candidate: f.preparation.candidate,
    baselineEvidence: f.preparation.baselineEvidence,
    candidateEvidence: clone(f.preparation.candidateEvidence),
    baselineTargets: f.targets, candidateTargets: [...f.targets, added],
    baselineLockSha256: hash("old locked runtime"), candidateLockSha256: hash("new locked runtime"),
    selectedTargets: [f.targets[0], added]};
  const addedFingerprint = fingerprints([added]).functions[added];
  input.candidateEvidence.source.functions[added] = clone(addedFingerprint);
  input.candidateEvidence.compiled.functions[added] = clone(addedFingerprint);
  const original = JSON.stringify(input);
  const assessment = assessSelectiveRuntimeImpact(input);
  assert.equal(assessment.schema, SELECTIVE_IMPACT_SCHEMA);
  assert.equal(assessment.dependencyDrift, true);
  assert.deepEqual(assessment.codeChangedTargets, f.changed);
  assert.deepEqual(assessment.addedTargets, [added]);
  assert.deepEqual(assessment.impactedTargets, input.candidateTargets);
  assert.deepEqual(assessment.selectedTargets, input.selectedTargets);
  assert.equal(assessment.deferredImpactedTargets.length, 5);
  assert.deepEqual(assessment.retainedBaselineTargets, f.targets.slice(1));
  assert.deepEqual(assessment.deferredUnresolvedTargets, []);
  assert.equal(JSON.stringify(input), original);

  const deferredUnknown = clone(input);
  deferredUnknown.candidateEvidence.source.functions[f.targets[1]].unknown = ["index.js:dynamic-module-load"];
  deferredUnknown.candidateEvidence.compiled = clone(deferredUnknown.candidateEvidence.source);
  const deferred = assessSelectiveRuntimeImpact(deferredUnknown);
  assert.ok(deferred.impactedTargets.includes(f.targets[1]));
  assert.ok(deferred.deferredImpactedTargets.includes(f.targets[1]));
  assert.deepEqual(deferred.deferredUnresolvedTargets, [f.targets[1]]);
  assert.throws(() => assessSelectiveRuntimeImpact({...deferredUnknown, selectedTargets: [f.targets[1], added]}), invalid);

  const sameLock = clone(input); sameLock.candidateLockSha256 = sameLock.baselineLockSha256;
  const focused = assessSelectiveRuntimeImpact({...sameLock, selectedTargets: [...f.changed, added]});
  assert.deepEqual(focused.impactedTargets, [...f.changed, added]);
  assert.deepEqual(focused.deferredImpactedTargets, []);
  for (const mutate of [
    (p) => {p.candidateEvidence.runtimeConfigurationSha256 = hash("config drift");},
    (p) => {p.candidateLockSha256 = "invalid";},
    (p) => {p.selectedTargets = ["functions:unrelated"];},
    (p) => {p.selectedTargets.reverse();},
    (p) => {delete p.candidateEvidence.compiled.functions[added];},
    (p) => {p.candidateEvidence.source.functions[f.targets[0]].unknown = ["index.js:dynamic-module-load"];
      p.candidateEvidence.compiled = clone(p.candidateEvidence.source);},
    (p) => {p.candidateEvidence.source.functions[added].unknown = ["index.js:dynamic-module-load"];
      p.candidateEvidence.compiled = clone(p.candidateEvidence.source);},
    (p) => {p.candidateTargets.pop(); delete p.candidateEvidence.source.functions[added];
      delete p.candidateEvidence.compiled.functions[added];},
    (p) => {p.candidateTargets.splice(5, 1); delete p.candidateEvidence.source.functions[f.targets[5]];
      delete p.candidateEvidence.compiled.functions[f.targets[5]];},
    (p) => {p.secretPayload = "FAKE_PRIVATE_SENTINEL";},
  ]) rejectsClone(input, mutate, assessSelectiveRuntimeImpact);
  assert.throws(() => assessSelectiveRuntimeImpact({...sameLock, selectedTargets: [f.targets[5]]}), invalid);
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

import {INTAKE_PR596_RELEASE, INTAKE_SOURCE_DELTA, verifyIntakeSourceCompatibility,
  checkIntakeGitCompatibility, verifyIntakeArtifactMetadata, verifyIntakeProvenance,
  prepareIntakePr596Release, verifyIntakePreservation, readIntakeSnapshot,
  runIntakePr596ReleaseCli, verifyIntakeParams} from "./selective_backend_release.mjs";
import {functionsParamsProvenance, prepareFunctionsParamsForDeploy} from "../firebase/prepare_functions_params_for_deploy.mjs";

const intakeEvidence = () => ({sourceSha: INTAKE_PR596_RELEASE.sourceSha,
  currentSha: INTAKE_PR596_RELEASE.checkpointSha, sourceAncestor: true, checkpointAncestor: true,
  changedPaths: INTAKE_SOURCE_DELTA.map((row) => row.path), currentDifference: [],
  rows: structuredClone(INTAKE_SOURCE_DELTA)});
test("Intake PR596 accepts exactly the reviewed WhatsApp delta and real Git objects", () => {
  const expected = {sourceSha: INTAKE_PR596_RELEASE.sourceSha,
    compatibilityCheckpoint: INTAKE_PR596_RELEASE.checkpointSha};
  assert.deepEqual(verifyIntakeSourceCompatibility(intakeEvidence()), expected);
  assert.deepEqual(checkIntakeGitCompatibility(INTAKE_PR596_RELEASE.checkpointSha,
    path.resolve(path.dirname(new URL(import.meta.url).pathname), "../..")), expected);
});
for (const [name, mutate] of [
  ["another source", (v) => {v.sourceSha = "0".repeat(40);}],
  ["unreviewed runtime", (v) => {v.rows[3].checkpointGitBlob = "0".repeat(40);}],
  ["symlink", (v) => {v.rows[0].checkpointMode = "120000";}],
  ["missing delta", (v) => {v.rows.pop();}],
  ["new dependency or shared initializer", (v) => {v.currentDifference.push("functions/src/index.ts");}],
  ["missing ancestry", (v) => {v.checkpointAncestor = false;}],
]) test(`Intake PR596 source rejects ${name}`, () => {
  const evidence = intakeEvidence(); mutate(evidence); assert.throws(() => verifyIntakeSourceCompatibility(evidence));
});
const intakeArtifact = () => ({id: INTAKE_PR596_RELEASE.artifactId, expired: false,
  name: `firebase-delivery-${INTAKE_PR596_RELEASE.sourceSha}-1`,
  digest: `sha256:${INTAKE_PR596_RELEASE.artifactSha256}`,
  workflow_run: {id: Number(INTAKE_PR596_RELEASE.sourceCiRunId), head_sha: INTAKE_PR596_RELEASE.sourceSha}});
test("Intake PR596 immutable artifact rejects another ID, archive, producer and expiry", () => {
  assert.equal(verifyIntakeArtifactMetadata(intakeArtifact()).artifactId, 11551444925);
  for (const change of [
    (a) => {a.id++;}, (a) => {a.expired = true;}, (a) => {a.digest = `sha256:${"0".repeat(64)}`;},
    (a) => {a.name += "-copy";}, (a) => {a.workflow_run.id++;}, (a) => {a.workflow_run.head_sha = "0".repeat(40);},
  ]) {const value = intakeArtifact(); change(value); assert.throws(() => verifyIntakeArtifactMetadata(value));}
});
const intakePackage = () => ({manifest: {schema: PROVENANCE_SCHEMA,
  sourceSha: INTAKE_PR596_RELEASE.sourceSha, sourceCiRunId: INTAKE_PR596_RELEASE.sourceCiRunId,
  sourceCiRunAttempt: "1", stages: ["functions"],
  artifact: {name: "firebase-backend.tar.gz", sizeBytes: 10, sha256: "a".repeat(64)}},
packagePlan: {schema: "catch.firebase-delivery-plan/v2", sourceSha: INTAKE_PR596_RELEASE.sourceSha,
  baseSha: INTAKE_PR596_RELEASE.baseSha, sourceCiRunId: INTAKE_PR596_RELEASE.sourceCiRunId,
  sourceCiRunAttempt: "1", stages: ["functions"], deployGroups: ["functions"],
  targets: ["functions:adminListIntakeOperations,functions:retained"]}});
test("Intake PR596 narrows the independently verified package to one fixed target", () => {
  const input = intakePackage();
  assert.deepEqual(prepareIntakePr596Release(input).targets, [INTAKE_PR596_RELEASE.target]);
  assert.deepEqual(input.packagePlan.targets, ["functions:adminListIntakeOperations,functions:retained"]);
  // Plan selection cannot replace the separately mandatory immutable-manifest proof.
  assert.throws(() => verifyIntakeProvenance(input.manifest));
});
test("Intake PR596 refuses extra stages, absent/duplicate targets, wrong source and base", () => {
  for (const change of [
    (v) => {v.packagePlan.stages.push("firestore-rules");},
    (v) => {v.packagePlan.deployGroups.push("firestore-indexes");},
    (v) => {v.packagePlan.targets = ["functions:retained"];},
    (v) => {v.packagePlan.targets = [INTAKE_PR596_RELEASE.target + "," + INTAKE_PR596_RELEASE.target];},
    (v) => {v.packagePlan.sourceSha = "0".repeat(40);}, (v) => {v.packagePlan.baseSha = "0".repeat(40);},
    (v) => {v.manifest.sourceCiRunAttempt = "2";},
  ]) {const input = intakePackage(); change(input); assert.throws(() => prepareIntakePr596Release(input));}
});
const intakeBefore = () => ({schema: "catch.intake-pr596-metadata/v1", projectId: INTAKE_PR596_RELEASE.projectId,
  functions: [{name: "projects/catch-dating-app-64e51/locations/asia-south1/functions/retained", sha256: "b".repeat(64)}],
  protectedResources: Object.fromEntries(["extensions", "indexes", "fields", "rules", "remoteConfig", "projectIam"]
    .map((name) => [name, "c".repeat(64)])), selected: null});
const intakeCompleted = () => {
  const result = intakeBefore(), p = INTAKE_PR596_RELEASE.projectId;
  const name = `projects/${p}/locations/asia-south1/functions/adminListIntakeOperations`;
  result.functions.unshift({name, sha256: "d".repeat(64)});
  result.selected = {identity: {name, updateTime: "2026-10-08T15:00:00Z",
    build: `projects/${p}/locations/asia-south1/builds/build`,
    source: {bucket: "synthetic", object: "function-source.zip", generation: "1"},
    service: `projects/${p}/locations/asia-south1/services/adminlistintakeoperations`,
    revision: "adminlistintakeoperations-00001-synthetic", serviceUid: "synthetic", serviceGeneration: "1"},
  runtime: {runtime: "nodejs24", entryPoint: "adminListIntakeOperations",
    serviceAccount: "574779808785-compute@developer.gserviceaccount.com", memory: "512Mi", maxInstances: 50,
    secretBindings: 0, paramsSha256: "e".repeat(64)}, iamSha256: "f".repeat(64), publicInvoker: true};
  return result;
};
test("Intake PR596 completion allows only the selected addition and retains all resources", () => {
  const before = intakeBefore(); assert.equal(verifyIntakePreservation(before, structuredClone(before)).completed, false);
  const result = verifyIntakePreservation(before, intakeCompleted(), {completed: true, paramsSha256: "e".repeat(64)});
  assert.equal(result.retainedFunctions, 1); assert.equal(result.coverage, "one-selected-function-only");
});
test("Intake PR596 rejects retained metadata, Extensions, flags, rules, IAM and runtime drift", () => {
  for (const change of [
    (v) => {v.functions[1].sha256 = "0".repeat(64);},
    ...["extensions", "indexes", "fields", "rules", "remoteConfig", "projectIam"].map((name) =>
      (v) => {v.protectedResources[name] = "0".repeat(64);}),
    (v) => {v.selected.runtime.serviceAccount = "foreign@example.invalid";},
    (v) => {v.selected.runtime.paramsSha256 = "0".repeat(64);},
    (v) => {v.selected.publicInvoker = false;}, (v) => {v.functions.push(v.functions[1]);},
  ]) {
    const after = intakeCompleted(); change(after);
    assert.throws(() => verifyIntakePreservation(intakeBefore(), after, {completed: true, paramsSha256: "e".repeat(64)}));
  }
  assert.throws(() => verifyIntakePreservation(intakeBefore(), intakeCompleted()));
});
test("Intake PR596 CLI rejects target overrides before any metadata call", async () => {
  let reads = 0;
  await assert.rejects(runIntakePr596ReleaseCli(["intake-before", "--output", "unused", "--target", "functions:foreign"],
    {readSnapshot: async () => {reads++; return intakeBefore();}}));
  assert.equal(reads, 0);
});
test("Intake PR596 refuses an unchanged existing serving revision", () => {
  const snapshot = intakeCompleted();
  assert.throws(() => verifyIntakePreservation(snapshot, structuredClone(snapshot),
    {completed: true, paramsSha256: "e".repeat(64)}), /build did not change/);
});
test("Intake PR596 binds real materialized bytes and the pre-marker configuration hash separately", (t) => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "intake-params-"));
  t.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  fs.writeFileSync(path.join(directory, "package.json"), "{}");
  const projectId = INTAKE_PR596_RELEASE.projectId, sourceSha = INTAKE_PR596_RELEASE.sourceSha;
  const environment = {ALGOLIA_APPLICATION_ID: "CATCHDEV01", RAZORPAY_PUBLIC_KEY_ID: "rzp_test_example123"};
  const provenance = functionsParamsProvenance({projectId, sourceSha, environment});
  const {outputPath} = prepareFunctionsParamsForDeploy({functionsDir: directory, projectId, sourceSha,
    environment, expectedProvenance: provenance});
  const binding = verifyIntakeParams(outputPath, provenance);
  assert.notEqual(binding.materializedSha256, binding.configurationSha256);
  assert.equal(binding.configurationSha256, provenance.paramsSha256);
  assert.deepEqual(verifyIntakeParams(outputPath, provenance, binding), binding);
  const contents = fs.readFileSync(outputPath, "utf8");
  fs.writeFileSync(outputPath, contents.replace('META_WHATSAPP_ENABLED="false"', 'META_WHATSAPP_ENABLED="true"'));
  assert.throws(() => verifyIntakeParams(outputPath, provenance, binding));
  fs.writeFileSync(outputPath, contents + 'CATCH_DEPLOY_CONFIG_SHA256="duplicate"\n');
  assert.throws(() => verifyIntakeParams(outputPath, provenance, binding));
});
test("Intake PR596 inventory fails closed on unreachable regions and repeated pages", async () => {
  const deps = (body) => ({run: () => ({status: 0, stdout: "synthetic-token"}),
    request: async () => ({ok: true, json: async () => body}), listIndexes: () => []});
  await assert.rejects(readIntakeSnapshot(deps({functions: [], unreachable: ["europe-west1"]})));
  await assert.rejects(readIntakeSnapshot(deps({functions: [], nextPageToken: "repeat"})));
});

test("Intake PR596 snapshot reads wildcard fields with page size zero and retains every protected resource", async () => {
  const project = INTAKE_PR596_RELEASE.projectId;
  const root = `projects/${project}`;
  const fieldRoot = `${root}/databases/(default)/collectionGroups`;
  const shared = {name: `${fieldRoot}/retained/fields/expiry`,
    indexConfig: {usesAncestorConfig: false}, ttlConfig: {state: "ACTIVE"}};
  const override = {name: `${fieldRoot}/retained/fields/override`, indexConfig: {usesAncestorConfig: false}};
  const ttl = {name: `${fieldRoot}/retained/fields/ttl`, ttlConfig: {state: "ACTIVE"}};
  const retained = ["retainedA", "retainedB"].map((name) => ({
    name: `${root}/locations/asia-south1/functions/${name}`, environment: "GEN_1",
  }));
  const extensions = [{name: `${root}/instances/retained`}];
  const rules = [{name: `${root}/releases/cloud.firestore`}];
  const remoteConfig = {parameters: {protected: {defaultValue: {value: "synthetic"}}}};
  const iam = {version: 3, bindings: []};
  const indexes = [{name: `${fieldRoot}/retained/indexes/retained`, state: "READY"}];
  const requests = [];
  const capture = (ttlField = ttl) => readIntakeSnapshot({
    run: () => ({status: 0, stdout: "synthetic-token"}),
    listIndexes: ({projectId}) => {assert.equal(projectId, project); return indexes;},
    request: async (raw, init) => {
      const url = new URL(raw);
      requests.push({path: url.pathname, query: Object.fromEntries(url.searchParams)});
      assert.equal(init.headers.Authorization, "Bearer synthetic-token");
      const query = url.searchParams;
      let body;
      if (url.hostname === "cloudfunctions.googleapis.com" && url.pathname.endsWith("/functions")) {
        assert.equal(query.get("pageSize"), "100");
        body = query.has("pageToken") ? {functions: [retained[1]]} :
          {functions: [retained[0]], nextPageToken: "functions-second"};
        if (query.has("pageToken")) assert.equal(query.get("pageToken"), "functions-second");
      } else if (url.hostname === "cloudfunctions.googleapis.com" && url.pathname.endsWith(":getIamPolicy")) {
        assert.equal(query.get("options.requestedPolicyVersion"), "3"); body = iam;
      } else if (url.hostname === "firestore.googleapis.com") {
        assert.equal(url.pathname, `/v1/${fieldRoot}/-/fields`);
        // This is the live endpoint's failure, rather than a source-text assertion.
        if (query.get("pageSize") !== "0") return {ok: false, status: 400};
        if (query.get("filter") === "indexConfig.usesAncestorConfig:false") {
          body = query.has("pageToken") ? {fields: [override]} :
            {fields: [shared], nextPageToken: "fields-second"};
          if (query.has("pageToken")) assert.equal(query.get("pageToken"), "fields-second");
        } else {
          assert.equal(query.get("filter"), "ttlConfig:*"); body = {fields: [shared, ttlField]};
        }
      } else if (url.hostname === "firebaseextensions.googleapis.com") {
        assert.equal(query.get("pageSize"), "100"); body = {instances: extensions};
      } else if (url.hostname === "firebaserules.googleapis.com") {
        assert.equal(query.get("pageSize"), "100"); body = {releases: rules};
      } else if (url.hostname === "firebaseremoteconfig.googleapis.com") body = remoteConfig;
      else {
        assert.equal(url.hostname, "cloudresourcemanager.googleapis.com");
        assert.equal(init.method, "POST");
        assert.deepEqual(JSON.parse(init.body), {options: {requestedPolicyVersion: 3}}); body = iam;
      }
      return {ok: true, status: 200, json: async () => structuredClone(body)};
    },
  });
  const before = await capture();
  assert.equal(before.functions.length, 2);
  assert.equal(before.selected, null);
  // Independently calculated digests bind the complete synthetic metadata.
  assert.deepEqual(before.protectedResources, {
    "extensions": "e3d12be2679a4d960e544d53e3d937f3d21ff1b8faf6c21fd9dd7e5b2aaeeca8",
    "indexes": "ccc0bce4addc5bdd741c4ff805c645aa62071cde5178b08b1d2d91731f603bda",
    "fields": "7604b2446ca3323dcb3eb20a395e7086fef2311a5ebde76040480ea2f7ba1479",
    "rules": "9091cffa2b80074dbe0d8a01e86aad4e10fd3793df1650c8b7a88ab5dc9b5920",
    "remoteConfig": "125fd00530df75259c43357664959903c211b9a9feaa1df1b9299ee87d5b086b",
    "projectIam": "79e5d5b416ed277ad64b3f3f3c61ebba7b1dfaae5c1bf4a0e4bfa5fab9a57ab6"
  });
  assert.equal(requests.filter((entry) => entry.path.endsWith("/fields")).length, 3);
  const after = await capture({...ttl, ttlConfig: {state: "DISABLED"}});
  assert.throws(() => verifyIntakePreservation(before, after), /unselected cloud resource changed/);
});

function intakeEventMetadataCapture(change = () => {}) {
  const project = INTAKE_PR596_RELEASE.projectId;
  const service = `projects/${project}/locations/asia-south1/services/retained-event`;
  const fn = {name: `projects/${project}/locations/asia-south1/functions/retainedEvent`, environment: "GEN_2",
    buildConfig: {runtime: "nodejs24", entryPoint: "retainedEvent", source: {generation: "1"}},
    serviceConfig: {service, serviceAccountEmail: "retained@example.test", availableMemory: "512Mi"},
    eventTrigger: {eventType: "google.cloud.firestore.document.v1.written", eventFilters: [
      {attribute: "database", value: "(default)"},
      {attribute: "document", value: "retained/{id}", operator: "match-path-pattern"},
      {attribute: "namespace", value: "(default)"},
    ]}};
  const runService = {name: service, generation: "1", latestReadyRevision: "retained-event-00001-a",
    template: {containers: [{image: "retained-image", args: ["first", "second"],
      env: [{name: "RETAINED_CONFIG", value: "synthetic"}]}]}};
  const iam = {etag: "retained-etag", version: 3, bindings: [{role: "roles/run.invoker", members: ["allUsers"]}]};
  change(fn, runService, iam);
  return readIntakeSnapshot({run: () => ({status: 0, stdout: "synthetic-token"}), listIndexes: () => [],
    request: async (raw) => {
      const url = new URL(raw); let body;
      if (url.hostname === "cloudfunctions.googleapis.com") body = {functions: [fn]};
      else if (url.hostname === "run.googleapis.com") body = url.pathname.endsWith(":getIamPolicy") ? iam : runService;
      else if (url.hostname === "firestore.googleapis.com") body = {fields: []};
      else if (url.hostname === "firebaseextensions.googleapis.com") body = {instances: []};
      else if (url.hostname === "firebaserules.googleapis.com") body = {releases: []};
      else if (url.hostname === "firebaseremoteconfig.googleapis.com") body = {};
      else {assert.equal(url.hostname, "cloudresourcemanager.googleapis.com"); body = {version: 3, bindings: []};}
      return {ok: true, status: 200, json: async () => structuredClone(body)};
    }});
}

test("Intake PR596 snapshot accepts reordered Eventarc filters with all metadata retained", async () => {
  const before = await intakeEventMetadataCapture();
  const after = await intakeEventMetadataCapture((fn) => {fn.eventTrigger.eventFilters.reverse();});
  assert.deepEqual(after, before);
  assert.equal(verifyIntakePreservation(before, after).completed, false);
});

test("Intake PR596 snapshot rejects filter, runtime, IAM and ordered-array changes", async () => {
  const before = await intakeEventMetadataCapture();
  for (const change of [
    (fn) => {fn.eventTrigger.eventFilters[1].value = "foreign/{id}";},
    (fn) => {fn.eventTrigger.eventFilters[1].attribute = "foreign";},
    (fn) => {delete fn.eventTrigger.eventFilters[1].operator;},
    (fn) => {fn.eventTrigger.eventFilters[1].additionalMetadata = "changed";},
    (fn) => {fn.eventTrigger.eventFilters.pop();},
    (fn) => {fn.eventTrigger.eventFilters.push({...fn.eventTrigger.eventFilters[0]});},
    (fn) => {fn.eventTrigger.eventType = "foreign.event";},
    (fn) => {fn.buildConfig.source.generation = "2";},
    (fn) => {fn.serviceConfig.serviceAccountEmail = "foreign@example.test";},
    (_, runService) => {runService.latestReadyRevision = "retained-event-00002-b";},
    (_, runService) => {runService.template.containers[0].env[0].value = "changed";},
    (_, runService) => {runService.template.containers[0].args.reverse();},
    (_, __, iam) => {iam.bindings[0].members = ["user:foreign@example.test"];},
  ]) {
    const after = await intakeEventMetadataCapture(change);
    assert.throws(() => verifyIntakePreservation(before, after), /unselected Function\/Extension identity or configuration changed/);
  }
});
