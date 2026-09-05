import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {fileURLToPath} from "node:url";
import test from "node:test";
import {
  createCheckpointState, createProvenanceManifest, recordStageCheckpoint, writeJsonAtomic,
} from "./delivery_core.mjs";
import {
  FUNCTIONS_DEPLOYMENT_FILE, captureFunctionIdentities, executeFunctionsCheckpointCli,
  liveFunctions, prepareFunctionsDeployment, restoreCheckpointArchive, validateFunctionsDeployment, verifyFunctionsDeployment,
} from "./firebase_functions_checkpoint.mjs";

const root = fileURLToPath(new URL("../../", import.meta.url));
const sha = "a".repeat(40);
const baseSha = "b".repeat(40);
const scope = "firebase:dev:demo-project";
const selectedTargets = ["functions:alpha", "functions:beta"];
const hash = (bytes) => createHash("sha256").update(bytes).digest("hex");
function liveFunction(name) {
  const service = `projects/demo-project/locations/asia-south1/services/${name}`;
  const revision = `${service}/revisions/${name}-00001-abc`;
  return {name: `projects/demo-project/locations/asia-south1/functions/${name}`,
    environment: "GEN_2", state: "ACTIVE", updateTime: "2026-09-06T12:00:00.123456789Z",
    buildConfig: {build: `projects/42/locations/asia-south1/builds/build-${name}`,
      sourceProvenance: {resolvedStorageSource: {bucket: "source-bucket", object: "functions.zip", generation: "123"}}},
    serviceConfig: {service, revision: `${name}-00001-abc`},
    runService: {name: service, uid: `${name}-unique-service-id`, generation: "1", observedGeneration: "1",
      latestReadyRevision: revision, latestCreatedRevision: revision,
      terminalCondition: {state: "CONDITION_SUCCEEDED"},
      // Cloud Run's real LATEST response omits revision and reconciling=false.
      trafficStatuses: [{type: "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST", percent: 100}]}};
}
async function fixture(t, stages = ["functions", "firestore-rules"]) {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-functions-checkpoint-"));
  t.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  const artifactPath = path.join(directory, "firebase-backend.tar.gz");
  fs.writeFileSync(artifactPath, "immutable package bytes");
  const manifest = await createProvenanceManifest({artifactPath, sourceSha: sha,
    sourceCiRunId: "700", sourceCiRunAttempt: "1", stages});
  const manifestPath = path.join(directory, "firebase-provenance.json");
  const paramsFile = path.join(directory, ".env.demo-project");
  const checkpointPath = path.join(directory, "checkpoint", "checkpoint.json");
  fs.writeFileSync(paramsFile, 'PUBLIC_CONFIGURATION="original"\n');
  await writeJsonAtomic(manifestPath, manifest);
  const expected = {manifest, scope, baseSha, selectedTargets, paramsSha256: hash(fs.readFileSync(paramsFile))};
  const functions = selectedTargets.map((target) => liveFunction(target.slice("functions:".length)));
  const proof = prepareFunctionsDeployment({...expected, functions});
  const cliArgs = ["--manifest", manifestPath, "--artifact", artifactPath, "--source-sha", sha,
    "--ci-run-id", "700", "--ci-run-attempt", "1", "--scope", scope, "--checkpoint", checkpointPath,
    "--base-sha", baseSha, "--targets", selectedTargets.join(","), "--params-file", paramsFile];
  return {directory, artifactPath, manifest, manifestPath, paramsFile, checkpointPath, expected, functions, proof, cliArgs};
}
function zipFiles(directory, entries) {
  const source = fs.mkdtempSync(path.join(directory, "zip-"));
  for (const [name, value] of Object.entries(entries)) fs.writeFileSync(path.join(source, name), JSON.stringify(value));
  const zip = path.join(source, "archive.zip");
  const result = spawnSync("zip", ["-q", zip, ...Object.keys(entries)], {cwd: source, encoding: "utf8"});
  assert.equal(result.status, 0, result.stderr);
  return fs.readFileSync(zip);
}
function githubFixture(f, entries) {
  const bytes = zipFiles(f.directory, entries);
  const run = {id: 900, run_attempt: 1, name: "Delivery lane v1 dev", workflow_id: 88,
    path: ".github/workflows/delivery.yml", head_branch: "main", head_sha: "c".repeat(40),
    status: "completed", conclusion: "failure", repository: {id: 42, full_name: "owner/catch"},
    head_repository: {id: 42, full_name: "owner/catch"}};
  const metadata = {id: 123, name: `firebase-checkpoint-dev-demo-project-${sha}-1`,
    digest: `sha256:${hash(bytes)}`, expired: false,
    workflow_run: {id: 900, head_branch: "main", head_sha: run.head_sha, repository_id: 42, head_repository_id: 42}};
  const responses = new Map([
    ["repos/owner/catch/actions/runs/900/attempts/1", run],
    ["repos/owner/catch/actions/workflows/delivery.yml", {id: 88, path: ".github/workflows/delivery.yml"}],
    ["repos/owner/catch/actions/artifacts/123", metadata],
    ["repos/owner/catch/actions/artifacts/123/zip", bytes],
  ]);
  const args = {repository: "owner/catch", repositoryId: 42, runId: "900", runAttempt: "1",
    artifactId: 123, artifactDigest: metadata.digest, scope, manifest: f.manifest,
    request: async (endpoint) => {
      assert.ok(responses.has(endpoint), `Unexpected GitHub read: ${endpoint}`);
      const value = responses.get(endpoint);
      return Buffer.isBuffer(value) ? Buffer.from(value) : structuredClone(value);
    }};
  return {args, run, metadata, responses};
}

test("Functions proof requires the complete ACTIVE deployment identity for every exact target", async (t) => {
  const f = await fixture(t);
  assert.deepEqual(verifyFunctionsDeployment(f.proof, {...f.expected, functions: [...f.functions].reverse()}),
    {postconditionsOnly: true});
  for (const functions of [f.functions.slice(1), [...f.functions, f.functions[0]],
    [f.functions[0], {...f.functions[1], state: "DEPLOYING"}],
    [f.functions[0], {...f.functions[1], environment: "GEN_1"}],
    [f.functions[0], {...f.functions[1], buildConfig: {}}]]) {
    assert.throws(() => captureFunctionIdentities(functions, scope, selectedTargets));
  }
});

test("serving proof accepts explicit current revision traffic but rejects foreign services and stale revision traffic", async (t) => {
  const f = await fixture(t);
  for (const fn of f.functions) {
    fn.runService.reconciling = false;
    fn.runService.trafficStatuses = [{type: "TRAFFIC_TARGET_ALLOCATION_TYPE_REVISION", percent: 100,
      revision: fn.serviceConfig.revision}];
  }
  assert.deepEqual(verifyFunctionsDeployment(f.proof, {...f.expected, functions: f.functions}), {postconditionsOnly: true});
  f.functions[0].runService.trafficStatuses[0].revision = "alpha-00000-old";
  assert.throws(() => captureFunctionIdentities(f.functions, scope, selectedTargets));
  const foreign = liveFunction("alpha");
  for (const value of [foreign.serviceConfig, foreign.runService]) {
    for (const key of ["service", "name", "latestReadyRevision", "latestCreatedRevision"]) {
      if (value[key]) value[key] = value[key].replace("demo-project", "foreign-project");
    }
  }
  assert.throws(() => captureFunctionIdentities([foreign], scope, ["functions:alpha"]), /approved Function project/);
});

test("metadata reader paginates Functions and independently reads only selected Cloud Run services without exposing credentials", async () => {
  const inventory = [liveFunction("alpha"), liveFunction("beta"), liveFunction("unselected")];
  let requested = [];
  const dependencies = {
    runCommand: (command, args) => {
      assert.equal(command, "gcloud");
      assert.deepEqual(args, ["auth", "print-access-token"]);
      return {status: 0, stdout: "fixture-private-token\n"};
    },
    request: async (url, options) => {
      assert.equal(options.headers.Authorization, "Bearer fixture-private-token");
      requested.push(url);
      if (url.includes("cloudfunctions.googleapis.com")) {
        const second = new URL(url).searchParams.get("pageToken") === "next";
        const functions = (second ? inventory.slice(1) : inventory.slice(0, 1)).map(({runService, ...fn}) => fn);
        return {ok: true, json: async () => ({functions, ...(second ? {} : {nextPageToken: "next"})})};
      }
      const fn = inventory.find((candidate) => url === `https://run.googleapis.com/v2/${candidate.serviceConfig.service}`);
      assert.ok(fn, `Unexpected service read: ${url}`);
      return {ok: true, json: async () => structuredClone(fn.runService)};
    },
  };
  assert.deepEqual(await liveFunctions("demo-project", selectedTargets, dependencies), inventory.slice(0, 2));
  assert.equal(requested.length, 4);
  assert.ok(requested.every((url) => !url.includes("unselected") && !url.includes("fixture-private-token")));
  requested = [];
  await assert.rejects(liveFunctions("foreign/project", selectedTargets, dependencies));
  assert.equal(requested.length, 0);
  await assert.rejects(liveFunctions("demo-project", selectedTargets, {...dependencies,
    request: async (url, options) => url.includes("run.googleapis.com") ? {ok: false, status: 403} : dependencies.request(url, options),
  }), (error) => error.message.includes("HTTP 403") && !error.message.includes("fixture-private-token"));
  await assert.rejects(liveFunctions("demo-project", selectedTargets, {...dependencies,
    request: async () => ({ok: true, json: async () => ({functions: [inventory[0], inventory[0]]})}),
  }), /missing or duplicated/);
});

test("changed source, attempt, project, base, targets, params or live revision cannot skip deployment", async (t) => {
  const f = await fixture(t);
  for (const expected of [
    {...f.expected, manifest: {...f.manifest, sourceSha: "d".repeat(40)}},
    {...f.expected, manifest: {...f.manifest, sourceCiRunAttempt: "2"}},
    {...f.expected, manifest: {...f.manifest, artifact: {...f.manifest.artifact, sha256: "e".repeat(64)}}},
    {...f.expected, scope: "firebase:prod:demo-project"},
    {...f.expected, scope: "firebase:dev:another-project"},
    {...f.expected, baseSha: "f".repeat(40)},
    {...f.expected, selectedTargets: ["functions:alpha"]},
    {...f.expected, paramsSha256: "f".repeat(64)},
  ]) assert.throws(() => validateFunctionsDeployment(f.proof, expected));
  for (const mutate of [
    (fn) => { fn.serviceConfig.revision = "alpha-00002-def"; },
    (fn) => { fn.buildConfig.build += "-other"; },
    (fn) => { fn.buildConfig.sourceProvenance.resolvedStorageSource.generation = "124"; },
    (fn) => { fn.updateTime = "2026-09-06T13:00:00Z"; },
    (fn) => { fn.serviceConfig.service += "-other"; },
    (fn) => { fn.state = "FAILED"; },
    (fn) => { fn.runService.uid += "-recreated"; },
    (fn) => { fn.runService.generation = fn.runService.observedGeneration = "2"; },
    (fn) => { fn.runService.latestCreatedRevision += "-out-of-band"; },
    (fn) => { fn.runService.latestReadyRevision += "-out-of-band"; },
    (fn) => { fn.runService.observedGeneration = "0"; },
    (fn) => { fn.runService.reconciling = true; },
    (fn) => { fn.runService.terminalCondition.state = "CONDITION_FAILED"; },
    (fn) => { fn.runService.trafficStatuses[0].percent = 50; },
    (fn) => { fn.runService.trafficStatuses.push({...fn.runService.trafficStatuses[0]}); },
    (fn) => { fn.runService.trafficStatuses[0].tag = "other-revision"; },
    (fn) => { fn.runService.trafficStatuses[0].revision = "alpha-00000-old"; },
    (fn) => { fn.runService.trafficStatuses[0].type = "TRAFFIC_TARGET_ALLOCATION_TYPE_UNSPECIFIED"; },
    (fn) => { delete fn.runService; },
  ]) {
    const functions = structuredClone(f.functions);
    mutate(functions[0]);
    assert.throws(() => verifyFunctionsDeployment(f.proof, {...f.expected, functions}));
  }
  for (const proof of [null, false, {...f.proof, other: true}, {...f.proof, targets: [...selectedTargets].reverse()},
    {...f.proof, functions: [f.proof.functions[0], f.proof.functions[0]]}]) {
    assert.throws(() => validateFunctionsDeployment(proof, f.expected));
  }
});

test("legacy v2 or missing proof replays; a recorded deployment survives repeated failed postconditions", async (t) => {
  const f = await fixture(t);
  let reads = 0;
  const dependencies = {readFunctions: async () => { reads++; return f.functions; }};
  assert.deepEqual(await executeFunctionsCheckpointCli(["verify", ...f.cliArgs], dependencies), {postconditionsOnly: false});
  assert.equal(reads, 0);
  assert.equal(fs.existsSync(f.checkpointPath), false, "Missing-proof selection is read-only.");
  const state = recordStageCheckpoint({manifest: f.manifest, state: createCheckpointState(f.manifest, scope),
    scope, stage: "functions", status: "failed", detail: "old worker failed after a partial deploy"}).state;
  await writeJsonAtomic(f.checkpointPath, state);
  assert.deepEqual(await executeFunctionsCheckpointCli(["verify", ...f.cliArgs], dependencies), {postconditionsOnly: false});
  await executeFunctionsCheckpointCli(["record", ...f.cliArgs], dependencies);
  const original = fs.readFileSync(path.join(path.dirname(f.checkpointPath), FUNCTIONS_DEPLOYMENT_FILE), "utf8");
  assert.ok(!original.includes("PUBLIC_CONFIGURATION"), "Params values must never enter proof.");
  for (let attempt = 0; attempt < 2; attempt++) {
    await writeJsonAtomic(f.checkpointPath, state);
    assert.deepEqual(await executeFunctionsCheckpointCli(["verify", ...f.cliArgs], dependencies), {postconditionsOnly: true});
  }
  assert.equal(fs.readFileSync(path.join(path.dirname(f.checkpointPath), FUNCTIONS_DEPLOYMENT_FILE), "utf8"), original);
  fs.appendFileSync(f.paramsFile, "CHANGED=true\n");
  const before = reads;
  await assert.rejects(executeFunctionsCheckpointCli(["verify", ...f.cliArgs], dependencies), /params changed/);
  assert.equal(reads, before, "Input drift rejects before cloud metadata or permissions.");
});

test("recording cannot bypass an earlier stage or turn a partially deployed batch into proof", async (t) => {
  const f = await fixture(t, ["firestore-indexes", "functions"]);
  await assert.rejects(executeFunctionsCheckpointCli(["record", ...f.cliArgs], {
    readFunctions: async () => { throw new Error("must not reach cloud"); },
  }), /first incomplete Functions stage/);
  const state = recordStageCheckpoint({manifest: f.manifest, state: createCheckpointState(f.manifest, scope),
    scope, stage: "firestore-indexes", status: "passed"}).state;
  await writeJsonAtomic(f.checkpointPath, state);
  await assert.rejects(executeFunctionsCheckpointCli(["record", ...f.cliArgs], {
    readFunctions: async () => f.functions.slice(0, 1),
  }), /Exactly one live Function/);
  assert.equal(fs.existsSync(path.join(path.dirname(f.checkpointPath), FUNCTIONS_DEPLOYMENT_FILE)), false);
  assert.deepEqual(JSON.parse(fs.readFileSync(f.checkpointPath)), state);
});

test("the real verifier rejects source drift and serving drift without changing checkpoint or permitting postconditions", async (t) => {
  const f = await fixture(t);
  await executeFunctionsCheckpointCli(["record", ...f.cliArgs], {readFunctions: async () => f.functions});
  const proofPath = path.join(path.dirname(f.checkpointPath), FUNCTIONS_DEPLOYMENT_FILE);
  const originalCheckpoint = fs.readFileSync(f.checkpointPath, "utf8");
  const originalProof = fs.readFileSync(proofPath, "utf8");
  const sourceArgs = [...f.cliArgs];
  sourceArgs[sourceArgs.indexOf("--source-sha") + 1] = "e".repeat(40);
  await assert.rejects(executeFunctionsCheckpointCli(["verify", ...sourceArgs], {
    readFunctions: async () => { throw new Error("must not read cloud for wrong source"); },
  }), /source SHA/);
  const drifted = structuredClone(f.functions);
  drifted[0].runService.latestReadyRevision += "-out-of-band";
  await assert.rejects(executeFunctionsCheckpointCli(["verify", ...f.cliArgs], {readFunctions: async () => drifted}), /different revision/);
  assert.equal(fs.readFileSync(f.checkpointPath, "utf8"), originalCheckpoint);
  assert.equal(fs.readFileSync(proofPath, "utf8"), originalProof);
});

test("restore verifies the complete archive and historical producer before accepting either file", async (t) => {
  const f = await fixture(t);
  const checkpoint = createCheckpointState(f.manifest, scope);
  for (const entries of [{"checkpoint.json": checkpoint},
    {"checkpoint.json": checkpoint, [FUNCTIONS_DEPLOYMENT_FILE]: f.proof}]) {
    const gh = githubFixture(f, entries);
    assert.deepEqual(await restoreCheckpointArchive(gh.args), entries);
  }
  const mutations = [
    (gh) => { gh.run.workflow_id++; }, (gh) => { gh.run.run_attempt++; },
    (gh) => { gh.run.status = "in_progress"; }, (gh) => { gh.run.conclusion = "success"; },
    (gh) => { gh.run.head_repository.id++; }, (gh) => { gh.metadata.id++; },
    (gh) => { gh.metadata.name += "-other"; }, (gh) => { gh.metadata.expired = true; },
    (gh) => { gh.metadata.workflow_run.id++; }, (gh) => { gh.metadata.workflow_run.repository_id++; },
    (gh) => { gh.metadata.workflow_run.head_repository_id++; }, (gh) => { gh.metadata.workflow_run.head_branch = "other"; },
    (gh) => { gh.metadata.workflow_run.head_sha = sha; },
    (gh) => { gh.responses.get("repos/owner/catch/actions/artifacts/123/zip")[35] ^= 1; },
  ];
  for (const mutate of mutations) {
    const gh = githubFixture(f, {"checkpoint.json": checkpoint, [FUNCTIONS_DEPLOYMENT_FILE]: f.proof});
    mutate(gh);
    await assert.rejects(restoreCheckpointArchive(gh.args));
  }
  for (const proof of [null, false, {}, {...f.proof, scope: "firebase:prod:demo-project"}]) {
    const gh = githubFixture(f, {"checkpoint.json": checkpoint, [FUNCTIONS_DEPLOYMENT_FILE]: proof});
    await assert.rejects(restoreCheckpointArchive(gh.args));
  }
  const mismatched = {...f.proof, provenance: {...f.proof.provenance, sourceSha: "e".repeat(40)}};
  const gh = githubFixture(f, {"checkpoint.json": checkpoint, [FUNCTIONS_DEPLOYMENT_FILE]: mismatched});
  const restoreArgs = ["restore", ...f.cliArgs, "--repository", "owner/catch", "--repository-id", "42",
    "--run-id", "900", "--run-attempt", "1", "--artifact-id", "123", "--artifact-digest", gh.args.artifactDigest];
  await assert.rejects(executeFunctionsCheckpointCli(restoreArgs, {request: gh.args.request}), /package\/source mismatch/);
  assert.equal(fs.existsSync(f.checkpointPath), false, "Invalid companion must not publish even the valid portable checkpoint.");
  assert.equal(fs.existsSync(path.join(path.dirname(f.checkpointPath), FUNCTIONS_DEPLOYMENT_FILE)), false);
});

test("unchanged v2 core and actual legacy Delivery reader ignore a valid companion and replay the failed stage", async (t) => {
  const f = await fixture(t);
  const state = recordStageCheckpoint({manifest: f.manifest, state: createCheckpointState(f.manifest, scope),
    scope, stage: "functions", status: "failed"}).state;
  const artifactDirectory = path.join(f.directory, "build/delivery/resume-validation", "firebase-checkpoint-demo");
  await writeJsonAtomic(path.join(artifactDirectory, "checkpoint.json"), state);
  await writeJsonAtomic(path.join(artifactDirectory, FUNCTIONS_DEPLOYMENT_FILE), f.proof);
  const delivery = fs.readFileSync(path.join(root, ".github/workflows/delivery.yml"), "utf8");
  const start = delivery.indexOf("              validated_count=0");
  const end = delivery.indexOf('              test "$validated_count" = "$checkpoint_count"', start);
  assert.ok(start >= 0 && end > start);
  const fragment = delivery.slice(start, end) + 'test "$validated_count" = "$checkpoint_count"';
  const result = spawnSync("bash", ["-euo", "pipefail", "-c", fragment], {cwd: f.directory, encoding: "utf8",
    env: {...process.env, source_sha: sha, source_ci_run_id: "700", source_ci_run_attempt: "1", checkpoint_count: "1"}});
  assert.equal(result.status, 0, result.stderr);
  const core = spawnSync(process.execPath, [path.join(root, "tool/ci/delivery_core.mjs"), "next",
    "--manifest", f.manifestPath, "--artifact", f.artifactPath, "--source-sha", sha,
    "--ci-run-id", "700", "--ci-run-attempt", "1", "--scope", scope,
    "--checkpoint", path.join(artifactDirectory, "checkpoint.json")], {encoding: "utf8"});
  assert.equal(core.status, 0, core.stderr);
  assert.deepEqual(JSON.parse(core.stdout).next, {complete: false, index: 0, stage: "functions", status: "failed"});
});
