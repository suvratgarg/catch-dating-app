#!/usr/bin/env node
import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import * as lanes from "./backend_delivery_lanes.mjs";
import {
  createCheckpointState, readJsonFile, resolveFirstIncompleteStage,
  validateCheckpointState, validateProvenanceManifest, verifyDeliveryArtifact, writeJsonAtomic,
} from "./delivery_core.mjs";

export const FUNCTIONS_DEPLOYMENT_SCHEMA = "catch.firebase-functions-deployment/v1";
export const FUNCTIONS_DEPLOYMENT_FILE = "functions-deployment.json";
const checkpointFile = "checkpoint.json";
const hash = (bytes) => createHash("sha256").update(bytes).digest("hex");
const hashPattern = /^[0-9a-f]{64}$/;
const shaPattern = /^[0-9a-f]{40}$/;
const projectPattern = /^[a-z][a-z0-9-]{4,28}[a-z0-9]$/;
const region = "asia-south1";
function keys(value, expected, label) {
  assert.ok(value && typeof value === "object" && !Array.isArray(value), `${label} must be an object.`);
  assert.deepEqual(Object.keys(value).sort(), [...expected].sort(), `Unexpected ${label} fields.`);
}
function string(value, label) {
  assert.ok(typeof value === "string" && value.length > 0 && !/[\0\r\n]/.test(value), `Invalid ${label}.`);
  return value;
}
function targets(value) {
  assert.ok(Array.isArray(value) && value.length > 0 && new Set(value).size === value.length &&
    value.every((target) => /^functions:[A-Za-z][A-Za-z0-9_-]*$/.test(target)), "Exact unique Function targets required.");
  return [...value].sort();
}
function projectFromScope(scope) {
  const parts = typeof scope === "string" ? scope.split(":") : [];
  assert.ok(parts.length === 3 && parts[0] === "firebase" && ["dev", "staging", "prod"].includes(parts[1]) &&
    projectPattern.test(parts[2]), "Exact Firebase environment/project scope required.");
  return parts[2];
}
function paramsDigest(file, projectId) {
  assert.equal(path.basename(file), `.env.${projectId}`, "Expected materialized project params file.");
  const stat = fs.lstatSync(file);
  assert.ok(stat.isFile() && !stat.isSymbolicLink(), "Params must be a regular file.");
  return hash(fs.readFileSync(file));
}
function sourceLocation(value) {
  keys(value, ["bucket", "object", "generation"], "resolved source");
  string(value.bucket, "source bucket");
  string(value.object, "source object");
  assert.match(value.generation ?? "", /^[1-9][0-9]*$/, "Resolved source generation required.");
  return {...value};
}
function deploymentIdentity(value, projectId, target) {
  keys(value, ["name", "updateTime", "build", "source", "service", "revision", "serviceUid", "serviceGeneration"], "Function deployment identity");
  assert.equal(value.name, `projects/${projectId}/locations/${region}/functions/${target.slice("functions:".length)}`);
  assert.match(value.updateTime ?? "", /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,9})?Z$/, "Deployment update time required.");
  assert.match(value.build ?? "", /^projects\/[^/]+\/locations\/[^/]+\/builds\/[^/]+$/, "Latest successful build required.");
  sourceLocation(value.source);
  assert.match(value.service ?? "", new RegExp(`^projects/${projectId}/locations/${region}/services/[a-z][a-z0-9-]*$`),
    "Cloud Run service must remain in the approved Function project/region.");
  string(value.revision, "Cloud Run revision");
  string(value.serviceUid, "Cloud Run service uid");
  assert.match(value.serviceGeneration ?? "", /^[1-9][0-9]*$/, "Cloud Run generation required.");
  return structuredClone(value);
}
function revisionResource(service, revision) {
  string(revision, "Cloud Run revision");
  if (revision.startsWith(`${service}/revisions/`)) return revision;
  assert.match(revision, /^[a-z][a-z0-9-]*$/, "Invalid Cloud Run revision name.");
  return `${service}/revisions/${revision}`;
}
function servingIdentity(fn) {
  const service = fn.serviceConfig?.service;
  assert.match(service ?? "", /^projects\/[^/]+\/locations\/asia-south1\/services\/[^/]+$/);
  const actual = fn.runService;
  assert.ok(actual && typeof actual === "object", "Independent Cloud Run service metadata required.");
  assert.equal(actual.name, service, "Cloud Run service does not match the selected Function.");
  assert.ok(actual.reconciling === undefined || actual.reconciling === false, "Cloud Run service is still reconciling.");
  assert.equal(actual.terminalCondition?.state, "CONDITION_SUCCEEDED", "Cloud Run service is not ready.");
  assert.match(actual.generation ?? "", /^[1-9][0-9]*$/);
  assert.equal(actual.observedGeneration, actual.generation, "Cloud Run generation is not fully observed.");
  const revision = revisionResource(service, fn.serviceConfig.revision);
  assert.equal(actual.latestReadyRevision, revision, "Cloud Run serves a different revision than the Function deployment.");
  assert.equal(actual.latestCreatedRevision, revision, "Cloud Run has a newer revision than the Function deployment.");
  assert.ok(Array.isArray(actual.trafficStatuses) && actual.trafficStatuses.length === 1, "Cloud Run traffic is split or unknown.");
  const traffic = actual.trafficStatuses[0];
  assert.equal(traffic.percent, 100, "The Function revision must receive all Cloud Run traffic.");
  assert.ok(traffic.tag === undefined || traffic.tag === "", "Tagged Cloud Run traffic cannot prove ordinary serving state.");
  if (traffic.type === "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST") {
    if (traffic.revision !== undefined) assert.equal(revisionResource(service, traffic.revision), revision);
  } else {
    assert.equal(traffic.type, "TRAFFIC_TARGET_ALLOCATION_TYPE_REVISION");
    assert.equal(revisionResource(service, traffic.revision), revision);
  }
  return {serviceUid: string(actual.uid, "Cloud Run service uid"), serviceGeneration: actual.generation};
}
export function captureFunctionIdentities(functions, scope, selectedTargets) {
  const projectId = projectFromScope(scope);
  const selected = targets(selectedTargets);
  assert.ok(Array.isArray(functions), "Function inventory must be an array.");
  const identities = new Map();
  for (const target of selected) {
    const expectedName = `projects/${projectId}/locations/${region}/functions/${target.slice("functions:".length)}`;
    const matching = functions.filter((fn) => fn?.name === expectedName);
    assert.equal(matching.length, 1, `Exactly one live Function required: ${target}`);
    const fn = matching[0];
    assert.equal(fn.state, "ACTIVE", `Function is not ACTIVE: ${target}`);
    assert.equal(fn.environment, "GEN_2", `Only verified second-generation deployment identity is supported: ${target}`);
    const resolved = fn.buildConfig?.sourceProvenance?.resolvedStorageSource;
    identities.set(target, deploymentIdentity({
      name: fn.name, updateTime: fn.updateTime, build: fn.buildConfig?.build,
      source: resolved && {bucket: resolved.bucket, object: resolved.object, generation: resolved.generation},
      service: fn.serviceConfig?.service, revision: fn.serviceConfig?.revision,
      ...servingIdentity(fn),
    }, projectId, target));
  }
  return selected.map((target) => identities.get(target));
}
export function validateFunctionsDeployment(value, {manifest, scope, baseSha, selectedTargets, paramsSha256}) {
  keys(value, ["schema", "scope", "provenance", "baseSha", "targets", "paramsSha256", "functions"], "Functions deployment proof");
  assert.equal(value.schema, FUNCTIONS_DEPLOYMENT_SCHEMA);
  const projectId = projectFromScope(scope);
  assert.equal(value.scope, scope, "Functions deployment environment/project mismatch.");
  assert.deepEqual(value.provenance, createCheckpointState(manifest, scope).provenance, "Functions deployment package/source mismatch.");
  assert.match(value.baseSha ?? "", shaPattern);
  assert.equal(value.baseSha, baseSha, "Functions deployment base mismatch.");
  assert.deepEqual(value.targets, targets(selectedTargets), "Functions deployment target set changed.");
  assert.match(value.paramsSha256 ?? "", hashPattern);
  assert.equal(value.paramsSha256, paramsSha256, "Materialized Functions params changed.");
  assert.ok(Array.isArray(value.functions) && value.functions.length === value.targets.length, "Incomplete Functions deployment proof.");
  value.functions.forEach((fn, index) => deploymentIdentity(fn, projectId, value.targets[index]));
  return value;
}
export function prepareFunctionsDeployment({manifest, scope, baseSha, selectedTargets, paramsSha256, functions}) {
  const value = {
    schema: FUNCTIONS_DEPLOYMENT_SCHEMA, scope,
    provenance: createCheckpointState(manifest, scope).provenance,
    baseSha, targets: targets(selectedTargets), paramsSha256,
    functions: captureFunctionIdentities(functions, scope, selectedTargets),
  };
  return validateFunctionsDeployment(value, {manifest, scope, baseSha, selectedTargets, paramsSha256});
}
export function verifyFunctionsDeployment(value, {functions, ...expected}) {
  validateFunctionsDeployment(value, expected);
  assert.deepEqual(captureFunctionIdentities(functions, expected.scope, expected.selectedTargets), value.functions,
    "Live Functions changed since the verified deployment; postconditions-only recovery refused.");
  return {postconditionsOnly: true};
}

export async function liveFunctions(projectId, selectedTargets, {runCommand = spawnSync, request = fetch} = {}) {
  assert.match(projectId, projectPattern);
  const expectedNames = new Set(targets(selectedTargets).map((target) =>
    `projects/${projectId}/locations/${region}/functions/${target.slice("functions:".length)}`));
  const tokenResult = runCommand("gcloud", ["auth", "print-access-token"], {encoding: "utf8", maxBuffer: 1024 * 1024});
  assert.equal(tokenResult.status, 0, "Cannot obtain authenticated metadata access.");
  const token = tokenResult.stdout.trim();
  assert.ok(token && !/[\r\n]/.test(token), "Invalid metadata access token.");
  const functions = [];
  const seenPages = new Set();
  let pageToken = "";
  do {
    assert.ok(!seenPages.has(pageToken), "Repeated Function inventory page.");
    seenPages.add(pageToken);
    const query = new URLSearchParams({pageSize: "100"});
    if (pageToken) query.set("pageToken", pageToken);
    const response = await request(`https://cloudfunctions.googleapis.com/v2/projects/${projectId}/locations/${region}/functions?${query}`,
      {headers: {Authorization: `Bearer ${token}`}, signal: AbortSignal.timeout(30_000)});
    assert.ok(response.ok, `Function deployment inventory failed with HTTP ${response.status}.`);
    const page = await response.json();
    assert.ok(Array.isArray(page.functions ?? []), "Invalid Function deployment inventory.");
    functions.push(...(page.functions ?? []));
    pageToken = page.nextPageToken ?? "";
    assert.equal(typeof pageToken, "string");
  } while (pageToken);
  const selected = functions.filter((fn) => expectedNames.has(fn?.name));
  assert.ok(selected.length === expectedNames.size && new Set(selected.map((fn) => fn.name)).size === expectedNames.size,
    "Selected Function inventory is missing or duplicated.");
  let index = 0;
  await Promise.all(Array.from({length: Math.min(5, selected.length)}, async () => {
    while (index < selected.length) {
      const fn = selected[index++];
      const service = fn.serviceConfig?.service;
      assert.match(service ?? "", new RegExp(`^projects/${projectId}/locations/${region}/services/[a-z][a-z0-9-]*$`),
        "Cloud Run service must remain in the approved Function project/region.");
      const response = await request(`https://run.googleapis.com/v2/${service}`,
        {headers: {Authorization: `Bearer ${token}`}, signal: AbortSignal.timeout(30_000)});
      assert.ok(response.ok, `Cloud Run serving inventory failed with HTTP ${response.status}.`);
      fn.runService = await response.json();
    }
  }));
  return selected;
}

export async function restoreCheckpointArchive({
  repository, repositoryId, runId, runAttempt, artifactId, artifactDigest, scope, manifest,
  request = lanes.githubRequest, verifyProducer = lanes.verifyWorkflowRun,
}) {
  assert.equal(typeof verifyProducer, "function", "Stable workflow identity verifier required for recovery.");
  const producer = await verifyProducer({repository, repositoryId, runId, runAttempt, role: "delivery", request});
  assert.equal(producer.status, "completed", "Recovery producer must be terminal.");
  assert.ok(["failure", "cancelled", "timed_out", "stale", "action_required", "startup_failure"].includes(producer.conclusion),
    "Recovery producer must be non-success.");
  assert.ok(Number.isSafeInteger(artifactId) && artifactId > 0);
  assert.match(artifactDigest ?? "", /^sha256:[0-9a-f]{64}$/);
  const [_, environment, projectId] = scope.split(":");
  projectFromScope(scope);
  const expectedName = `firebase-checkpoint-${environment}-${projectId}-${manifest.sourceSha}-${runAttempt}`;
  const root = `repos/${repository}/actions/artifacts/${artifactId}`;
  const metadata = await request(root);
  assert.equal(metadata.id, artifactId);
  assert.equal(metadata.name, expectedName);
  assert.equal(metadata.digest, artifactDigest);
  assert.equal(metadata.expired, false);
  assert.equal(metadata.workflow_run?.repository_id, repositoryId);
  assert.equal(metadata.workflow_run?.head_repository_id, repositoryId);
  assert.equal(metadata.workflow_run?.head_branch, "main");
  assert.equal(String(metadata.workflow_run?.id), runId);
  assert.equal(metadata.workflow_run?.head_sha, producer.head_sha, "Checkpoint archive control-plane identity mismatch.");
  const bytes = await request(`${root}/zip`, {binary: true});
  assert.equal(`sha256:${hash(bytes)}`, artifactDigest, "Checkpoint archive SHA-256 mismatch.");
  const entries = lanes.readJsonArchive(bytes, [checkpointFile], [FUNCTIONS_DEPLOYMENT_FILE]);
  const state = validateCheckpointState(manifest, entries[checkpointFile], scope);
  const proof = entries[FUNCTIONS_DEPLOYMENT_FILE];
  if (Object.hasOwn(entries, FUNCTIONS_DEPLOYMENT_FILE)) {
    validateFunctionsDeployment(proof, {manifest, scope, baseSha: proof.baseSha,
      selectedTargets: proof.targets, paramsSha256: proof.paramsSha256});
    const next = resolveFirstIncompleteStage(manifest, state, scope);
    const functionsIndex = manifest.stages.indexOf("functions");
    assert.ok(functionsIndex >= 0 && (next.complete || next.index >= functionsIndex),
      "Functions deployment proof cannot precede earlier checkpoint stages.");
  }
  // Exact current target/params and live identity comparison follows after the
  // deploy tree is materialized, before Functions permissions can mutate.
  return entries;
}

function options(args) {
  const result = {};
  for (let index = 0; index < args.length; index += 2) {
    assert.ok(/^--[a-z-]+$/.test(args[index] ?? "") && args[index + 1] && !args[index + 1].startsWith("--"), "Expected --name value pairs.");
    const key = args[index].slice(2);
    assert.ok(["manifest", "artifact", "source-sha", "ci-run-id", "ci-run-attempt", "scope", "checkpoint",
      "base-sha", "targets", "params-file", "repository", "repository-id", "run-id", "run-attempt", "artifact-id", "artifact-digest"].includes(key),
    `Unknown option: ${key}`);
    assert.equal(result[key], undefined, `Duplicate option: ${key}`);
    result[key] = args[index + 1];
  }
  return result;
}
function required(args, name) {
  return string(args[name], `--${name}`);
}
async function verifiedInputs(args) {
  const manifest = validateProvenanceManifest(await readJsonFile(required(args, "manifest")));
  await verifyDeliveryArtifact({manifest, artifactPath: required(args, "artifact"),
    expectedSourceSha: required(args, "source-sha"), expectedSourceCiRunId: required(args, "ci-run-id"),
    expectedSourceCiRunAttempt: required(args, "ci-run-attempt")});
  const scope = required(args, "scope");
  projectFromScope(scope);
  return {manifest, scope};
}
export async function executeFunctionsCheckpointCli(argv, {readFunctions = liveFunctions, request, verifyProducer} = {}) {
  const [command, ...rest] = argv;
  const args = options(rest);
  const {manifest, scope} = await verifiedInputs(args);
  const checkpointPath = path.resolve(required(args, "checkpoint"));
  assert.equal(path.basename(checkpointPath), checkpointFile);
  const proofPath = path.join(path.dirname(checkpointPath), FUNCTIONS_DEPLOYMENT_FILE);
  for (const input of [required(args, "manifest"), required(args, "artifact"), args["params-file"]].filter(Boolean)) {
    assert.ok(![checkpointPath, proofPath].includes(path.resolve(input)), "Checkpoint output must not overwrite a verified input.");
  }
  if (command === "restore") {
    assert.ok(!fs.existsSync(checkpointPath) && !fs.existsSync(proofPath), "Checkpoint restore paths already exist.");
    const entries = await restoreCheckpointArchive({repository: required(args, "repository"),
      repositoryId: Number(required(args, "repository-id")), runId: required(args, "run-id"),
      runAttempt: required(args, "run-attempt"), artifactId: Number(required(args, "artifact-id")),
      artifactDigest: required(args, "artifact-digest"), scope, manifest, request, verifyProducer});
    // Write only validated allowlisted JSON, never extract archive paths.
    await writeJsonAtomic(checkpointPath, entries[checkpointFile]);
    if (Object.hasOwn(entries, FUNCTIONS_DEPLOYMENT_FILE)) await writeJsonAtomic(proofPath, entries[FUNCTIONS_DEPLOYMENT_FILE]);
    return {restored: true, hasFunctionsDeployment: Object.hasOwn(entries, FUNCTIONS_DEPLOYMENT_FILE)};
  }
  assert.ok(["record", "verify"].includes(command), "Expected record, verify or restore.");
  const state = fs.existsSync(checkpointPath) ?
    validateCheckpointState(manifest, await readJsonFile(checkpointPath), scope) : createCheckpointState(manifest, scope);
  assert.equal(resolveFirstIncompleteStage(manifest, state, scope).stage, "functions",
    "Functions deployment proof is only usable at the first incomplete Functions stage.");
  const expected = {manifest, scope, baseSha: required(args, "base-sha"),
    selectedTargets: required(args, "targets").split(","),
    paramsSha256: paramsDigest(required(args, "params-file"), projectFromScope(scope))};
  assert.match(expected.baseSha, shaPattern);
  targets(expected.selectedTargets);
  if (command === "verify" && !fs.existsSync(proofPath)) return {postconditionsOnly: false};
  const proof = command === "verify" ? await readJsonFile(proofPath) : undefined;
  if (command === "verify") validateFunctionsDeployment(proof, expected);
  const functions = await readFunctions(projectFromScope(scope), expected.selectedTargets);
  if (command === "verify") return verifyFunctionsDeployment(proof, {...expected, functions});
  const result = prepareFunctionsDeployment({...expected, functions});
  // A Functions-only plan may not have written a checkpoint yet. Persist the
  // unchanged portable empty prefix before its optional deployment companion.
  if (!fs.existsSync(checkpointPath)) await writeJsonAtomic(checkpointPath, state);
  await writeJsonAtomic(proofPath, result);
  return {recorded: true};
}
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  executeFunctionsCheckpointCli(process.argv.slice(2)).then((result) => console.log(JSON.stringify(result))).catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
  });
}
