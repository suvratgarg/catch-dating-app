import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import {fileURLToPath} from "node:url";
import {captureFunctionIdentities, validateFunctionsDeployment} from "./firebase_functions_checkpoint.mjs";
import {GUARDED_PATHS} from "./operator_source_compatibility.mjs";
import {gcloudIndexList} from "../firebase/wait_firestore_indexes_ready.mjs";

// One additive callable from one immutable CI package. No generic selector,
// full-source cursor, flag activation or credential/IAM provisioning authority.
export const WEDDING_RELEASE = Object.freeze({
  sourceSha: "f509e144579403bd3dd66fc39ae0ee821ca0ab30",
  baseSha: "f7d2605cabbef640212b88a95002f515028437a3",
  sourceCiRunId: "37349803226", sourceCiRunAttempt: "1",
  artifactId: 11362334310,
  artifactDigest: "sha256:75d8fa915af23289467f63765ac92a9719ea8f0dcd24679fb16c58f914fd7e75",
  packageSha256: "b9c6be577d1aab3d95189c104387580baa46e32c6df01b70da62fc63edf18ac9",
  target: "functions:importWeddingPhoneContacts",
  baselineSha: "647e39e4476693d6565318cb1d5c5223f3b781f7",
});
const projects = Object.freeze({dev: "catchdates-dev", prod: "catch-dating-app-64e51"});
const sorted = (value) => [...value].sort();
function canonical(value) {
  if (Array.isArray(value)) return value.map(canonical);
  if (value && typeof value === "object") return Object.fromEntries(
    Object.keys(value).sort().map((key) => [key, canonical(value[key])]));
  return value;
}
const hash = (value) => createHash("sha256").update(JSON.stringify(canonical(value))).digest("hex");
const equal = (a, b, message) => assert.equal(hash(a), hash(b), message);
const scopeOf = (environment) => {
  assert.ok(Object.hasOwn(projects, environment), "Only DEV and protected PROD are supported.");
  return `firebase:${environment}:${projects[environment]}`;
};

export function prepareWeddingRelease({packagePlan, verifiedPlan, manifest}) {
  const r = WEDDING_RELEASE;
  for (const plan of [packagePlan, verifiedPlan, manifest]) {
    assert.equal(plan.sourceSha, r.sourceSha);
    assert.equal(plan.sourceCiRunId, r.sourceCiRunId);
    assert.equal(plan.sourceCiRunAttempt, r.sourceCiRunAttempt);
    equal(plan.stages, ["functions"], "Only a Functions-only package is permitted.");
  }
  assert.equal(packagePlan.baseSha, r.baseSha);
  assert.equal(verifiedPlan.baseSha, r.baseSha);
  assert.equal(manifest.artifact?.sha256, r.packageSha256);
  equal(packagePlan.deployGroups, ["functions"], "No index, rules, provider or config stage is permitted.");
  const targets = packagePlan.targets?.length === 1 ? packagePlan.targets[0].split(",") : [];
  assert.equal(targets.length, 579);
  assert.equal(new Set(targets).size, targets.length);
  assert.ok(targets.every((target) => /^functions:[A-Za-z][A-Za-z0-9_-]*$/.test(target)));
  assert.ok(targets.includes(r.target));
  assert.ok(verifiedPlan.targets?.length === 1 && verifiedPlan.targets[0].split(",").includes(r.target),
    "Independent package verification must authorize the selected callable.");
  return {executionPlan: {...packagePlan, targets: [r.target]}, retainedTargets: sorted(targets.filter((t) => t !== r.target))};
}

export function checkWeddingSource(currentSha, cwd = process.cwd(), run = spawnSync) {
  assert.match(currentSha ?? "", /^[0-9a-f]{40}$/);
  const git = (args) => {
    const result = run("git", args, {cwd, encoding: "utf8", timeout: 10000, maxBuffer: 1024 * 1024});
    assert.ifError(result.error);
    assert.equal(result.status, 0, "Pinned callable source ancestry proof failed.");
    return result.stdout;
  };
  for (const sha of [WEDDING_RELEASE.sourceSha, currentSha]) {
    assert.equal(git(["rev-parse", "--verify", `${sha}^{commit}`]).trim(), sha);
  }
  git(["merge-base", "--is-ancestor", WEDDING_RELEASE.sourceSha, currentSha]);
  assert.equal(git(["diff", "--name-only", WEDDING_RELEASE.sourceSha, currentSha, "--", ...GUARDED_PATHS]), "",
    "Current main backend/index/dependency drift requires new source review.");
  return {sourceSha: WEDDING_RELEASE.sourceSha, currentSha};
}

function selectedName(project) {
  return `projects/${project}/locations/asia-south1/functions/importWeddingPhoneContacts`;
}
function retainedFunctions(snapshot) {
  return snapshot.functions.filter((fn) => fn.name !== selectedName(snapshot.projectId));
}
export function closedControls(template) {
  const maps = [template.parameters ?? {}, ...Object.values(template.parameterGroups ?? {}).map((g) => g.parameters ?? {})];
  for (const name of ["CATCH_WEDDING_PHONE_IMPORT_READY", "host_wedding_phone_import_enabled"]) {
    for (const map of maps) if (Object.hasOwn(map, name)) {
      const parameter = map[name];
      assert.equal(parameter.defaultValue?.value, "false", "Phone import controls must remain closed.");
      assert.ok(Object.values(parameter.conditionalValues ?? {}).every((v) => v.value === "false"),
        "Phone import conditional controls must remain closed.");
    }
  }
}

export function verifyWeddingBefore({snapshot, retainedTargets, baselineDeployment, environment}) {
  assert.equal(snapshot.projectId, projects[environment]);
  assert.equal(snapshot.selectedHttpStatus, 404, "The additive callable must be confirmed absent before mutation.");
  assert.ok(!snapshot.functions.some((fn) => fn.name === selectedName(snapshot.projectId)));
  assert.equal(retainedTargets.length, 578);
  const identities = captureFunctionIdentities(snapshot.functions, scopeOf(environment), retainedTargets);
  if (environment === "prod") {
    assert.equal(baselineDeployment?.schema, "catch.firebase-functions-deployment/v1");
    assert.equal(baselineDeployment.scope, scopeOf(environment));
    assert.equal(baselineDeployment.provenance?.sourceSha, WEDDING_RELEASE.baselineSha);
    equal(baselineDeployment.targets, retainedTargets, "Accepted 578-target baseline differs from the additive package.");
    equal(baselineDeployment.functions, identities, "Live PROD does not match its accepted baseline; reconcile first.");
  }
  assert.match(snapshot.projectNumber, /^[1-9][0-9]*$/);
  assert.equal(snapshot.runtimeServiceAccountExists, true, "Existing default runtime identity is required; no provisioning.");
  for (const key of ["indexesSha256", "fieldsSha256", "projectIamSha256", "remoteConfigSha256", "rulesSha256"]) {
    assert.match(snapshot[key] ?? "", /^[0-9a-f]{64}$/);
  }
  return {schema: "catch.wedding-phone-import-before/v1", scope: scopeOf(environment),
    packageSha256: WEDDING_RELEASE.packageSha256, retainedTargets,
    retainedFunctionsSha256: hash(retainedFunctions(snapshot)),
    projectNumber: snapshot.projectNumber,
    indexesSha256: snapshot.indexesSha256, fieldsSha256: snapshot.fieldsSha256,
    projectIamSha256: snapshot.projectIamSha256, remoteConfigSha256: snapshot.remoteConfigSha256,
    rulesSha256: snapshot.rulesSha256};
}

export function completeWeddingRelease({snapshot, before, deployment, manifest, paramsSha256, environment}) {
  assert.equal(before.schema, "catch.wedding-phone-import-before/v1");
  assert.equal(before.scope, scopeOf(environment));
  assert.equal(before.packageSha256, WEDDING_RELEASE.packageSha256);
  assert.equal(snapshot.projectId, projects[environment]);
  assert.equal(snapshot.selectedHttpStatus, 200);
  assert.equal(snapshot.projectNumber, before.projectNumber);
  assert.equal(before.retainedTargets.length, 578);
  assert.equal(hash(retainedFunctions(snapshot)), before.retainedFunctionsSha256,
    "An unselected Function, serving revision, configuration or IAM policy changed.");
  for (const key of ["indexesSha256", "fieldsSha256", "projectIamSha256", "remoteConfigSha256", "rulesSha256"]) {
    assert.equal(snapshot[key], before[key], "Unselected indexes, rules, project IAM or flags changed.");
  }
  const selected = snapshot.functions.filter((fn) => fn.name === selectedName(snapshot.projectId));
  assert.equal(selected.length, 1);
  const fn = selected[0];
  assert.equal(fn.buildConfig?.entryPoint, "importWeddingPhoneContacts");
  assert.equal(fn.buildConfig?.runtime, "nodejs24");
  assert.equal(fn.serviceConfig?.timeoutSeconds, 120);
  assert.equal(fn.serviceConfig?.maxInstanceCount, 5);
  assert.equal(fn.serviceConfig?.availableMemory, "512Mi");
  assert.equal(fn.serviceConfig?.serviceAccountEmail, `${snapshot.projectNumber}-compute@developer.gserviceaccount.com`);
  equal(fn.serviceConfig?.secretEnvironmentVariables ?? [], [], "No secret bindings are authorized.");
  equal(fn.serviceConfig?.secretVolumes ?? [], [], "No secret volumes are authorized.");
  assert.ok(fn.labels?.["deployment-callable"] === "true", "Firebase callable discovery is required.");
  const bindings = fn.runIamPolicy?.bindings ?? [];
  equal(bindings, [{role: "roles/run.invoker", members: ["allUsers"]}],
    "Only the source-declared public callable invocation policy is permitted; no additional IAM grants.");
  validateFunctionsDeployment(deployment, {manifest, scope: before.scope, baseSha: WEDDING_RELEASE.baseSha,
    selectedTargets: [WEDDING_RELEASE.target], paramsSha256});
  equal(captureFunctionIdentities(snapshot.functions, before.scope, [WEDDING_RELEASE.target]), deployment.functions,
    "Selected serving identity must match the immutable package deployment checkpoint.");
  return {schema: "catch.wedding-phone-import-receipt/v1", scope: before.scope,
    sourceSha: WEDDING_RELEASE.sourceSha, packageSha256: WEDDING_RELEASE.packageSha256,
    selectedTargets: [WEDDING_RELEASE.target], retainedTargetCount: 578,
    deployment, preservation: before, controlsClosed: true};
}

export function verifyWeddingDevReceipt(receipt, manifest) {
  assert.equal(receipt.schema, "catch.wedding-phone-import-receipt/v1");
  assert.equal(receipt.scope, scopeOf("dev"));
  assert.equal(receipt.sourceSha, WEDDING_RELEASE.sourceSha);
  assert.equal(receipt.packageSha256, WEDDING_RELEASE.packageSha256);
  equal(receipt.selectedTargets, [WEDDING_RELEASE.target], "DEV receipt target expansion.");
  assert.equal(receipt.retainedTargetCount, 578);
  assert.equal(receipt.controlsClosed, true);
  validateFunctionsDeployment(receipt.deployment, {manifest, scope: receipt.scope,
    baseSha: WEDDING_RELEASE.baseSha, selectedTargets: [WEDDING_RELEASE.target],
    paramsSha256: receipt.deployment.paramsSha256});
  return {verifiedDev: true};
}

// Read only metadata, never application records, environment values or secret
// payloads. Hash config/IAM bodies immediately; do not persist their values.
export async function readWeddingSnapshot(environment, {run = spawnSync, request = fetch, listIndexes = gcloudIndexList} = {}) {
  const projectId = projects[environment];
  scopeOf(environment);
  const tokenResult = run("gcloud", ["auth", "print-access-token"], {encoding: "utf8", timeout: 30000, maxBuffer: 1024 * 1024});
  assert.ifError(tokenResult.error);
  assert.equal(tokenResult.status, 0, "Authenticated metadata access unavailable.");
  const token = String(tokenResult.stdout ?? "").trim();
  assert.ok(token && !/[\r\n]/.test(token));
  const get = async (url, init = {}) => {
    const response = await request(url, {...init, headers: {Authorization: `Bearer ${token}`, "Content-Type": "application/json"},
      signal: AbortSignal.timeout(30000)});
    assert.ok(response.ok, `Release metadata request failed with HTTP ${response.status}.`);
    return response.json();
  };
  const project = await get(`https://cloudresourcemanager.googleapis.com/v1/projects/${projectId}`);
  assert.match(project.projectNumber ?? "", /^[1-9][0-9]*$/);
  const account = `${project.projectNumber}-compute@developer.gserviceaccount.com`;
  const serviceAccount = await get(`https://iam.googleapis.com/v1/projects/${projectId}/serviceAccounts/${account}`);
  assert.equal(serviceAccount.email, account);
  assert.notEqual(serviceAccount.disabled, true);
  const selectedResponse = await request(`https://cloudfunctions.googleapis.com/v2/${selectedName(projectId)}?fields=name`,
    {headers: {Authorization: `Bearer ${token}`}, signal: AbortSignal.timeout(30000)});
  assert.ok([200, 404].includes(selectedResponse.status), "Selected Function absence is unresolved.");
  const functions = [];
  const mask = "nextPageToken,unreachable,functions(name,state,environment,updateTime,labels,buildConfig(runtime,entryPoint,build,sourceProvenance),serviceConfig(service,revision,serviceAccountEmail,timeoutSeconds,maxInstanceCount,minInstanceCount,availableMemory,availableCpu,ingressSettings,allTrafficOnLatestRevision,secretEnvironmentVariables,secretVolumes))";
  async function pages(url, field, extra = {}) {
    const rows = [], seen = new Set();
    let cursor = "";
    do {
      assert.ok(seen.size < 30 && !seen.has(cursor), "Unbounded/repeated metadata pagination.");
      seen.add(cursor);
      const query = new URLSearchParams({...extra, pageSize: "100", ...(cursor ? {pageToken: cursor} : {})});
      const result = await get(`${url}?${query}`);
      assert.ok(Array.isArray(result.unreachable ?? []) && (result.unreachable ?? []).length === 0,
        "Incomplete metadata inventory: an API location is unreachable.");
      assert.ok(Array.isArray(result[field] ?? []));
      rows.push(...(result[field] ?? []));
      cursor = result.nextPageToken ?? "";
      assert.equal(typeof cursor, "string");
    } while (cursor);
    return rows;
  }
  functions.push(...await pages(`https://cloudfunctions.googleapis.com/v2/projects/${projectId}/locations/-/functions`, "functions", {fields: mask}));
  assert.equal(new Set(functions.map((fn) => fn.name)).size, functions.length);
  let cursor = 0;
  await Promise.all(Array.from({length: 5}, async () => {
    while (cursor < functions.length) {
      const fn = functions[cursor++];
      if (fn.environment !== "GEN_2") continue;
      const service = fn.serviceConfig?.service;
      assert.match(service ?? "", new RegExp(`^projects/${projectId}/locations/[a-z0-9-]+/services/[a-z0-9-]+$`));
      const fields = "name,uid,generation,observedGeneration,latestReadyRevision,latestCreatedRevision,terminalCondition(state),trafficStatuses(type,revision,percent,tag),reconciling";
      fn.runService = await get(`https://run.googleapis.com/v2/${service}?fields=${encodeURIComponent(fields)}`);
      const policy = await get(`https://run.googleapis.com/v2/${service}:getIamPolicy?options.requestedPolicyVersion=3`);
      fn.runIamPolicy = {version: policy.version ?? 1, bindings: (policy.bindings ?? []).map((binding) =>
        ({...binding, members: sorted(binding.members ?? [])})).sort((a, b) => JSON.stringify(canonical(a)).localeCompare(JSON.stringify(canonical(b))))};
    }
  }));
  const fieldMap = new Map();
  // ListFields documents these two supported override filters. Query each,
  // deduplicate stable names and reject changes observed between the reads.
  for (const filter of ["indexConfig.usesAncestorConfig:false", "ttlConfig:*"]) {
    const rows = await pages(`https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/collectionGroups/-/fields`,
      "fields", {filter});
    for (const field of rows) {
      assert.equal(typeof field.name, "string");
      if (fieldMap.has(field.name)) equal(fieldMap.get(field.name), field, "Field override changed during snapshot.");
      fieldMap.set(field.name, field);
    }
  }
  const fields = [...fieldMap.values()];
  const projectIam = await get(`https://cloudresourcemanager.googleapis.com/v1/projects/${projectId}:getIamPolicy`,
    {method: "POST", body: JSON.stringify({options: {requestedPolicyVersion: 3}})});
  const remoteConfig = await get(`https://firebaseremoteconfig.googleapis.com/v1/projects/${projectId}/remoteConfig`);
  closedControls(remoteConfig);
  const releases = await pages(`https://firebaserules.googleapis.com/v1/projects/${projectId}/releases`, "releases");
  return {projectId, projectNumber: project.projectNumber, selectedHttpStatus: selectedResponse.status,
    runtimeServiceAccountExists: true, functions: functions.sort((a, b) => a.name.localeCompare(b.name)),
    indexesSha256: hash(listIndexes({projectId}).sort((a, b) => String(a.name).localeCompare(String(b.name)))),
    fieldsSha256: hash(fields.sort((a, b) => String(a.name).localeCompare(String(b.name)))),
    projectIamSha256: hash(projectIam), remoteConfigSha256: hash(remoteConfig),
    rulesSha256: hash(releases.sort((a, b) => String(a.name).localeCompare(String(b.name))))};
}

function read(file) { return JSON.parse(fs.readFileSync(file, "utf8")); }
function write(file, value) { fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`, {flag: "wx", mode: 0o600}); }
export async function runWeddingReleaseCli(argv, {snapshot = readWeddingSnapshot} = {}) {
  const [command, ...rest] = argv;
  const args = {};
  for (let i = 0; i < rest.length; i += 2) {
    assert.ok(/^--[a-z-]+$/.test(rest[i] ?? "") && rest[i + 1]);
    assert.ok(["current-main", "source-root", "manifest", "package-plan", "verified-plan", "output",
      "receipt", "environment", "baseline-deployment", "before", "params-file", "deployment"].includes(rest[i].slice(2)),
    "Unknown release argument.");
    assert.ok(!Object.hasOwn(args, rest[i].slice(2)));
    args[rest[i].slice(2)] = rest[i + 1];
  }
  if (command === "source") return checkWeddingSource(args["current-main"], args["source-root"]);
  const manifest = read(args.manifest);
  const prepared = prepareWeddingRelease({packagePlan: read(args["package-plan"]), verifiedPlan: read(args["verified-plan"]), manifest});
  if (command === "prepare") { write(args.output, prepared.executionPlan); return {selectedFunctions: 1}; }
  if (command === "verify-dev") return verifyWeddingDevReceipt(read(args.receipt), manifest);
  assert.ok(["before", "unchanged", "complete"].includes(command));
  const live = await snapshot(args.environment);
  if (command === "before") {
    const proof = verifyWeddingBefore({snapshot: live, retainedTargets: prepared.retainedTargets,
      baselineDeployment: args["baseline-deployment"] && read(args["baseline-deployment"]), environment: args.environment});
    write(args.output, proof); return {selectedAbsent: true, retainedFunctions: 578};
  }
  const before = read(args.before);
  if (command === "unchanged") {
    const proof = verifyWeddingBefore({snapshot: live, retainedTargets: prepared.retainedTargets,
      baselineDeployment: args["baseline-deployment"] && read(args["baseline-deployment"]), environment: args.environment});
    equal(proof, before, "The predeploy preservation snapshot changed.");
    return {unchangedBefore: true};
  }
  const paramsSha256 = createHash("sha256").update(fs.readFileSync(args["params-file"])).digest("hex");
  const result = completeWeddingRelease({snapshot: live, before, deployment: read(args.deployment), manifest,
    paramsSha256, environment: args.environment});
  write(args.output, result); return {selectedFunctions: 1, retainedFunctions: 578, controlsClosed: true};
}
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  runWeddingReleaseCli(process.argv.slice(2)).then((result) => console.log(JSON.stringify(result))).catch(() => {
    console.error("Exact wedding phone import release proof failed; no broader fallback is authorized.");
    process.exitCode = 1;
  });
}
