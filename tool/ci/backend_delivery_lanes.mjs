#!/usr/bin/env node
import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";

export const DEV_COMPLETION_SCHEMA = "catch.backend-dev-completion/v1";
export const DEV_COMPLETION_FILE = "backend-dev-completion.json";
export const DEV_PROMOTION_JOB = "Promote backend to dev / Firebase dev";
export const AUTHORIZATION_JOB = "Select and authorize the next CI artifact";
const prefix = "backend-dev-completion-v1-";
const receiptNamePattern = /^backend-dev-completion-v1-([1-9][0-9]*)-([1-9][0-9]*)-([1-9][0-9]*)-([1-9][0-9]*)-([0-9a-f]{40})-([1-9][0-9]*)-([1-9][0-9]*)-(bootstrap|incremental)$/;
const shaPattern = /^[0-9a-f]{40}$/;
const hashPattern = /^[0-9a-f]{64}$/;
const githubDigestPattern = /^sha256:[0-9a-f]{64}$/;
const sourceKeys = ["sourceCiWorkflowId", "sourceCiRunNumber", "sourceCiRunId", "sourceCiRunAttempt", "sourceSha"];
const completionKeys = ["schema", "environment", "projectId", "bootstrap", ...sourceKeys, "baseSha", "authorityArtifact",
  "planArtifact", "packageArtifact", "packageSha256", "provenanceSha256", "deliveryRunId", "deliveryRunAttempt"];
const hash = (bytes) => createHash("sha256").update(bytes).digest("hex");
const read = (file) => JSON.parse(fs.readFileSync(file, "utf8"));
const object = (value, label) => assert.ok(value && typeof value === "object" && !Array.isArray(value), `${label} must be an object.`);
function keys(value, expected, label) {
  object(value, label);
  assert.deepEqual(Object.keys(value).sort(), [...expected].sort(), `Unexpected ${label} fields.`);
}
function id(value, label) {
  assert.ok(typeof value === "string" && /^[1-9][0-9]*$/.test(value), `${label} must be a positive decimal string.`);
  return value;
}
function number(value, label) {
  assert.ok(Number.isSafeInteger(value) && value > 0, `${label} must be a positive safe integer.`);
  return value;
}
function sourceIdentity(value) {
  object(value, "source identity");
  number(value.sourceCiWorkflowId, "CI workflow id");
  number(value.sourceCiRunNumber, "CI run number");
  id(value.sourceCiRunId, "CI run id");
  id(value.sourceCiRunAttempt, "CI run attempt");
  assert.match(value.sourceSha ?? "", shaPattern, "Exact source SHA required.");
  return Object.fromEntries(sourceKeys.map((key) => [key, value[key]]));
}
function artifactBinding(value, label) {
  keys(value, ["id", "name", "digest"], label);
  number(value.id, `${label} id`);
  assert.ok(typeof value.name === "string" && value.name.length > 0, `${label} name required.`);
  assert.match(value.digest ?? "", githubDigestPattern, `${label} GitHub digest required.`);
  return value;
}
export function validateContext(value, {activeRun = false} = {}) {
  object(value, "context");
  assert.match(value.repository ?? "", /^[\w.-]+\/[\w.-]+$/, "Exact repository required.");
  number(value.repositoryId, "repository id");
  number(value.sourceCiWorkflowId, "CI workflow id");
  if (activeRun) {
    assert.ok(["dev", "prod"].includes(value.environment), "Delivery lane must be dev or prod.");
    number(value.deliveryWorkflowId, "Delivery workflow id");
    number(value.deliveryRunNumber, "Delivery run number");
    id(value.deliveryRunId, "Delivery run id");
    id(value.deliveryRunAttempt, "Delivery run attempt");
    assert.equal(value.deliveryRunAttempt, "1", "Partial Delivery reruns cannot select or publish lane progress.");
  }
  return value;
}
export function completionArtifactName(value) {
  sourceIdentity(value);
  id(value.deliveryRunId, "Delivery run id");
  id(value.deliveryRunAttempt, "Delivery run attempt");
  assert.equal(typeof value.bootstrap, "boolean");
  return `${prefix}${value.sourceCiWorkflowId}-${value.sourceCiRunNumber}-${value.sourceCiRunId}-${value.sourceCiRunAttempt}-${value.sourceSha}-${value.deliveryRunId}-${value.deliveryRunAttempt}-${value.bootstrap ? "bootstrap" : "incremental"}`;
}
export function validateDevCompletion(value) {
  keys(value, completionKeys, "dev completion");
  assert.equal(value.schema, DEV_COMPLETION_SCHEMA);
  assert.equal(value.environment, "dev");
  assert.equal(value.projectId, "catchdates-dev");
  assert.equal(typeof value.bootstrap, "boolean");
  sourceIdentity(value);
  assert.match(value.baseSha ?? "", shaPattern);
  id(value.deliveryRunId, "Delivery run id");
  assert.equal(value.deliveryRunAttempt, "1", "Partial Delivery reruns cannot publish completion.");
  artifactBinding(value.authorityArtifact, "authority artifact");
  artifactBinding(value.planArtifact, "plan artifact");
  assert.equal(value.authorityArtifact.name, `harness-success-v3-${value.sourceCiWorkflowId}-${value.sourceCiRunNumber}-${value.sourceCiRunId}-${value.sourceSha}-${value.sourceCiRunAttempt}`);
  assert.equal(value.planArtifact.name, `harness-plan-${value.sourceCiRunNumber}-${value.sourceCiRunId}-${value.sourceSha}-${value.sourceCiRunAttempt}`);
  if (value.packageArtifact === null) {
    assert.equal(value.bootstrap, false, "A true no-op cannot establish the backend bootstrap.");
    assert.equal(value.packageSha256, null);
    assert.equal(value.provenanceSha256, null);
  } else {
    artifactBinding(value.packageArtifact, "package artifact");
    assert.equal(value.packageArtifact.name, `firebase-delivery-${value.sourceSha}-${value.sourceCiRunAttempt}`);
    assert.match(value.packageSha256 ?? "", hashPattern);
    assert.match(value.provenanceSha256 ?? "", hashPattern);
  }
  return value;
}
export function artifactCatalogue(value) {
  const pages = Array.isArray(value) ? value : [value];
  assert.ok(pages.length > 0 && pages.every((page) => Array.isArray(page?.artifacts)), "Expected complete artifact catalogue pages.");
  const artifacts = new Map();
  for (const artifact of pages.flatMap((page) => page.artifacts)) {
    const previous = artifacts.get(artifact.id);
    if (previous) assert.deepEqual(previous, artifact, "Artifact catalogue changed during pagination.");
    artifacts.set(artifact.id, artifact);
  }
  return [...artifacts.values()];
}
function sameRepository(run, context) {
  return run?.repository_id === context.repositoryId && run?.head_repository_id === context.repositoryId;
}
function assertArtifactMetadata(artifact, binding, context, {runId, sourceSha} = {}) {
  artifactBinding(binding, "expected artifact");
  assert.equal(artifact.id, binding.id, "Artifact id mismatch.");
  assert.equal(artifact.name, binding.name, "Artifact name mismatch.");
  assert.equal(artifact.digest, binding.digest, "Artifact GitHub digest mismatch.");
  assert.equal(artifact.expired, false, "Artifact expired.");
  assert.ok(sameRepository(artifact.workflow_run, context), "Artifact belongs to another repository.");
  assert.equal(artifact.workflow_run.head_branch, "main", "Artifact was not produced on main.");
  if (runId) assert.equal(String(artifact.workflow_run.id), runId, "Artifact producer mismatch.");
  if (sourceSha) assert.equal(artifact.workflow_run.head_sha, sourceSha, "Artifact source SHA mismatch.");
}
function decodedCandidate(artifact) {
  const match = receiptNamePattern.exec(artifact.name ?? "");
  if (!match) return null;
  return {artifactId: artifact.id, artifactName: artifact.name, artifactDigest: artifact.digest,
    sourceCiWorkflowId: Number(match[1]), sourceCiRunNumber: Number(match[2]), sourceCiRunId: match[3],
    sourceCiRunAttempt: match[4], sourceSha: match[5], deliveryRunId: match[6], deliveryRunAttempt: match[7], bootstrap: match[8] === "bootstrap"};
}
export function completionCandidates(catalogue, context) {
  validateContext(context);
  const eligible = artifactCatalogue(catalogue).filter((artifact) => artifact.expired === false &&
    sameRepository(artifact.workflow_run, context) && artifact.workflow_run.head_branch === "main" &&
    artifact.name?.startsWith("backend-dev-completion-") && githubDigestPattern.test(artifact.digest ?? ""));
  const current = eligible.map(decodedCandidate).filter((candidate) => candidate && candidate.sourceCiWorkflowId === context.sourceCiWorkflowId);
  if (eligible.length > 0 && current.length === 0) throw new Error("Dev completion artifacts belong to a different or legacy CI workflow generation; explicit migration required.");
  for (const candidate of current) {
    sourceIdentity(candidate);
    assert.equal(candidate.deliveryRunAttempt, "1");
    const metadata = eligible.find((artifact) => artifact.id === candidate.artifactId);
    assert.equal(String(metadata.workflow_run.id), candidate.deliveryRunId, "Dev completion producer binding mismatch.");
  }
  for (const runNumber of new Set(current.map((item) => item.sourceCiRunNumber))) {
    assert.equal(new Set(current.filter((item) => item.sourceCiRunNumber === runNumber)
      .map((item) => `${item.sourceCiRunId}:${item.sourceSha}`)).size, 1, "Ambiguous dev source ordering.");
  }
  return current;
}

// Inspect the central directory before reading allowlisted JSON entries. No archive
// entry is extracted, and symlinks, directories, duplicate entries and ZIP64 are
// rejected. unzip independently checks compressed data and CRC while streaming.
export function readJsonArchive(bytes, requiredNames, optionalNames = []) {
  const allowed = [...requiredNames, ...optionalNames];
  assert.ok(requiredNames.length > 0 && allowed.length <= 2 && new Set(allowed).size === allowed.length &&
    allowed.every((name) => /^[a-z][a-z0-9-]*\.json$/.test(name)), "Expected one or two explicit JSON basenames.");
  assert.ok(Buffer.isBuffer(bytes) && bytes.length >= 22 && bytes.length <= 2 * 1024 * 1024, "Invalid JSON archive size.");
  let end = -1;
  for (let offset = bytes.length - 22; offset >= Math.max(0, bytes.length - 65557); offset--) {
    if (bytes.readUInt32LE(offset) === 0x06054b50 && offset + 22 + bytes.readUInt16LE(offset + 20) === bytes.length) { end = offset; break; }
  }
  assert.ok(end >= 0, "ZIP end record missing.");
  assert.equal(bytes.readUInt16LE(end + 4), 0, "Multidisk ZIP refused.");
  assert.equal(bytes.readUInt16LE(end + 6), 0, "Multidisk ZIP refused.");
  const count = bytes.readUInt16LE(end + 8);
  assert.equal(bytes.readUInt16LE(end + 10), count, "Split ZIP refused.");
  assert.ok(count >= requiredNames.length && count <= allowed.length, "Unexpected JSON archive entry count.");
  const centralSize = bytes.readUInt32LE(end + 12);
  const central = bytes.readUInt32LE(end + 16);
  assert.ok(central + centralSize === end && centralSize >= 46, "Invalid ZIP central directory.");
  let position = central;
  const names = new Set();
  const localEntries = [];
  for (let index = 0; index < count; index++) {
    assert.ok(position + 46 <= end, "Truncated ZIP central entry.");
    assert.equal(bytes.readUInt32LE(position), 0x02014b50);
    const nameLength = bytes.readUInt16LE(position + 28);
    const extraLength = bytes.readUInt16LE(position + 30);
    const commentLength = bytes.readUInt16LE(position + 32);
    const next = position + 46 + nameLength + extraLength + commentLength;
    assert.ok(next <= end, "Truncated ZIP metadata.");
    const name = bytes.subarray(position + 46, position + 46 + nameLength).toString("utf8");
    assert.ok(allowed.includes(name) && !names.has(name), "Unexpected or duplicate JSON archive entry.");
    names.add(name);
    const attributes = bytes.readUInt32LE(position + 38);
    const unixType = (attributes >>> 16) & 0o170000;
    assert.ok(unixType === 0 || unixType === 0o100000, "Non-regular ZIP entry refused.");
    assert.equal(attributes & 0x10, 0, "ZIP directory refused.");
    assert.equal(bytes.readUInt16LE(position + 8) & 1, 0, "Encrypted ZIP refused.");
    assert.ok(bytes.readUInt32LE(position + 24) <= 1024 * 1024, "JSON entry too large.");
    const local = bytes.readUInt32LE(position + 42);
    assert.ok(local + 30 <= central, "Invalid ZIP local offset.");
    assert.equal(bytes.readUInt32LE(local), 0x04034b50);
    const localNameLength = bytes.readUInt16LE(local + 26);
    const localExtraLength = bytes.readUInt16LE(local + 28);
    assert.equal(bytes.subarray(local + 30, local + 30 + localNameLength).toString("utf8"), name, "ZIP local entry name mismatch.");
    const dataEnd = local + 30 + localNameLength + localExtraLength + bytes.readUInt32LE(position + 20);
    assert.ok(dataEnd <= central, "ZIP compressed entry extends into metadata.");
    localEntries.push({start: local, end: dataEnd});
    position = next;
  }
  assert.equal(position, end, "Unexpected extra ZIP entries.");
  assert.ok(requiredNames.every((name) => names.has(name)), "Required JSON archive entry missing.");
  localEntries.sort((a, b) => a.start - b.start);
  assert.equal(localEntries[0].start, 0, "Prefixed or split ZIP refused.");
  for (let index = 1; index < localEntries.length; index++) {
    assert.ok(localEntries[index - 1].end <= localEntries[index].start, "Overlapping ZIP entries refused.");
  }
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-delivery-json-"));
  try {
    const archive = path.join(directory, "input.zip");
    fs.writeFileSync(archive, bytes, {mode: 0o600});
    return Object.fromEntries([...names].map((name) => {
      const result = spawnSync("unzip", ["-p", archive, name], {encoding: "utf8", maxBuffer: 1024 * 1024});
      assert.equal(result.status, 0, result.stderr || "Cannot verify JSON archive.");
      return [name, JSON.parse(result.stdout)];
    }));
  } finally {
    fs.rmSync(directory, {recursive: true, force: true});
  }
}
export function readSingleJsonArchive(bytes, expectedName) {
  return readJsonArchive(bytes, [expectedName])[expectedName];
}
export function githubRequest(endpoint, {paginate = false, binary = false} = {}) {
  const result = spawnSync("gh", ["api", ...(paginate ? ["--paginate", "--slurp"] : []), endpoint],
    {encoding: binary ? null : "utf8", maxBuffer: binary ? 2 * 1024 * 1024 : 32 * 1024 * 1024});
  assert.equal(result.status, 0, String(result.stderr || "Cannot read GitHub delivery evidence."));
  return binary ? result.stdout : JSON.parse(result.stdout);
}
function runIdentity(run, context, expected, workflowId, workflowPath) {
  number(workflowId, "Expected workflow id");
  assert.equal(run.workflow_id, workflowId, "Unexpected workflow generation.");
  assert.equal(run.path?.split("@")[0], workflowPath);
  assert.equal(run.repository?.id, context.repositoryId);
  assert.equal(run.repository?.full_name, context.repository);
  assert.equal(run.head_repository?.id, context.repositoryId);
  assert.equal(run.head_repository?.full_name, context.repository);
  assert.equal(run.head_branch, "main");
  assert.equal(String(run.id), expected.runId);
  assert.equal(run.run_attempt, Number(expected.attempt));
}
export async function verifyWorkflowRun({repository, repositoryId, runId, runAttempt, role, request = githubRequest}) {
  assert.match(repository ?? "", /^[\w.-]+\/[\w.-]+$/, "Exact repository required.");
  number(repositoryId, "Repository id");
  id(runId, "Run id");
  id(runAttempt, "Run attempt");
  assert.ok(["delivery", "cursor"].includes(role), "Unknown workflow identity role.");
  const root = `repos/${repository}/actions`;
  const run = await request(`${root}/runs/${runId}/attempts/${runAttempt}`);
  const workflowPath = run.path?.split("@")[0];
  const allowed = role === "cursor" ? ["delivery.yml", "backend-rebaseline.yml"] : ["delivery.yml"];
  assert.ok(allowed.some((file) => workflowPath === `.github/workflows/${file}`), "Unexpected producer workflow path.");
  // API run.name is the custom run-name, not the workflow's name. Resolve the
  // allowed path to its current numeric workflow generation instead.
  const workflow = await request(`${root}/workflows/${path.posix.basename(workflowPath)}`);
  assert.equal(workflow.path, workflowPath, "Workflow metadata path mismatch.");
  runIdentity(run, {repository, repositoryId}, {runId, attempt: runAttempt}, workflow.id, workflowPath);
  return run;
}
function validateAuthority(authority, receipt) {
  keys(authority, ["schema", ...sourceKeys, "deployRequired", "planArtifact", "packageArtifact"], "CI authority");
  assert.equal(authority.schema, "catch.ci-delivery-authority/v3");
  assert.deepEqual(sourceIdentity(authority), sourceIdentity(receipt));
  assert.deepEqual(authority.planArtifact, receipt.planArtifact);
  assert.deepEqual(authority.packageArtifact, receipt.packageArtifact);
  assert.equal(authority.deployRequired, receipt.packageArtifact !== null);
}
function validatePlan(plan, receipt) {
  assert.equal(plan.complete, true);
  assert.equal(plan.mode, "main");
  assert.equal(plan.validationOnly, undefined, "A validation-only plan is not delivery authority.");
  assert.equal(plan.sourceSha, receipt.sourceSha);
  assert.equal(plan.sourceCiRunId, receipt.sourceCiRunId);
  assert.equal(plan.sourceCiRunAttempt, receipt.sourceCiRunAttempt);
  assert.equal(plan.baseSha, receipt.baseSha);
  const groups = plan.operations?.deployGroups;
  assert.ok(Array.isArray(groups) && groups.length === new Set(groups).size &&
    groups.every((group) => ["functions", "firestore-indexes", "firestore-rules", "storage-rules"].includes(group)), "Invalid backend plan groups.");
  assert.equal(groups.length > 0, receipt.packageArtifact !== null, "No-op/package plan mismatch.");
}
function validateProvenance(provenance, receipt) {
  keys(provenance, ["schema", "sourceSha", "sourceCiRunId", "sourceCiRunAttempt", "artifact", "stages"], "package provenance");
  assert.equal(provenance.schema, "catch.delivery-provenance/v2");
  for (const key of ["sourceSha", "sourceCiRunId", "sourceCiRunAttempt"]) assert.equal(provenance[key], receipt[key]);
  keys(provenance.artifact, ["name", "sha256", "sizeBytes"], "package byte identity");
  assert.equal(provenance.artifact.name, "firebase-backend.tar.gz");
  assert.equal(provenance.artifact.sha256, receipt.packageSha256);
  assert.ok(Number.isSafeInteger(provenance.artifact.sizeBytes) && provenance.artifact.sizeBytes > 0);
  assert.ok(Array.isArray(provenance.stages) && provenance.stages.length > 0 &&
    provenance.stages.length === new Set(provenance.stages).size &&
    provenance.stages.every((stage) => ["firestore-indexes", "functions", "firestore-rules", "storage-rules"].includes(stage)));
}
export async function verifyDevCompletionArtifact({context, artifactId, artifactDigest, request = githubRequest, decodeArchive = readSingleJsonArchive}) {
  validateContext(context);
  number(context.deliveryWorkflowId, "Delivery workflow id");
  number(artifactId, "dev completion artifact id");
  assert.match(artifactDigest ?? "", githubDigestPattern);
  const root = `repos/${context.repository}`;
  const artifact = await request(`${root}/actions/artifacts/${artifactId}`);
  const candidate = decodedCandidate(artifact);
  assert.ok(candidate, "Invalid dev completion artifact name.");
  assert.equal(candidate.sourceCiWorkflowId, context.sourceCiWorkflowId, "Dev proof belongs to a different CI workflow generation.");
  assertArtifactMetadata(artifact, {id: artifactId, name: artifact.name, digest: artifactDigest}, context, {runId: candidate.deliveryRunId});
  const bytes = await request(`${root}/actions/artifacts/${artifactId}/zip`, {binary: true});
  assert.equal(`sha256:${hash(bytes)}`, artifactDigest, "Dev completion archive digest mismatch.");
  const completion = validateDevCompletion(decodeArchive(bytes, DEV_COMPLETION_FILE));
  assert.equal(completionArtifactName(completion), artifact.name, "Dev completion content/name binding mismatch.");
  const [producer, source, jobPages, authorityMetadata, authorityBytes] = await Promise.all([
    request(`${root}/actions/runs/${completion.deliveryRunId}/attempts/${completion.deliveryRunAttempt}`),
    request(`${root}/actions/runs/${completion.sourceCiRunId}/attempts/${completion.sourceCiRunAttempt}`),
    request(`${root}/actions/runs/${completion.deliveryRunId}/attempts/${completion.deliveryRunAttempt}/jobs?per_page=100`, {paginate: true}),
    request(`${root}/actions/artifacts/${completion.authorityArtifact.id}`),
    request(`${root}/actions/artifacts/${completion.authorityArtifact.id}/zip`, {binary: true}),
  ]);
  runIdentity(producer, context, {runId: completion.deliveryRunId, attempt: completion.deliveryRunAttempt}, context.deliveryWorkflowId, ".github/workflows/delivery.yml");
  assert.ok(["workflow_run", "repository_dispatch", "workflow_dispatch"].includes(producer.event), "Untrusted Delivery producer event.");
  runIdentity(source, context, {runId: completion.sourceCiRunId, attempt: completion.sourceCiRunAttempt}, completion.sourceCiWorkflowId, ".github/workflows/ci.yml");
  assert.equal(source.run_number, completion.sourceCiRunNumber);
  assert.equal(source.head_sha, completion.sourceSha);
  assert.equal(source.event, "push");
  assert.equal(source.status, "completed");
  assert.equal(source.conclusion, "success");
  assert.ok(Array.isArray(jobPages) && jobPages.length > 0 && jobPages.every((page) => Array.isArray(page.jobs)), "Missing producer job pages.");
  const jobs = jobPages.flatMap((page) => page.jobs);
  const authorizers = jobs.filter((job) => job.name === AUTHORIZATION_JOB);
  assert.equal(authorizers.length, 1, "Exact dev authorizer job required.");
  assert.equal(authorizers[0].status, "completed");
  assert.equal(authorizers[0].conclusion, "success");
  const devJobs = jobs.filter((job) => job.name === DEV_PROMOTION_JOB);
  if (completion.packageArtifact !== null) {
    assert.equal(devJobs.length, 1, "Exact dev promotion job required.");
    assert.equal(devJobs[0].status, "completed");
    assert.equal(devJobs[0].conclusion, "success", "Dev promotion did not succeed.");
  } else {
    assert.ok(devJobs.length <= 1 && devJobs.every((job) => job.status === "completed" && job.conclusion === "skipped"), "True no-op cannot hide an attempted dev promotion.");
  }
  for (const job of [...authorizers, ...devJobs]) {
    assert.equal(String(job.run_id), completion.deliveryRunId, "Dev job producer mismatch.");
    assert.equal(job.run_attempt, Number(completion.deliveryRunAttempt), "Dev job attempt mismatch.");
  }
  assertArtifactMetadata(authorityMetadata, completion.authorityArtifact, context, {runId: completion.sourceCiRunId, sourceSha: completion.sourceSha});
  assert.equal(`sha256:${hash(authorityBytes)}`, completion.authorityArtifact.digest, "CI authority archive digest mismatch.");
  validateAuthority(decodeArchive(authorityBytes, "ci-delivery-authority.json"), completion);
  return {completion, artifact: {id: artifact.id, name: artifact.name, digest: artifact.digest}};
}
export function validateProductionCursor(cursor, context) {
  if (cursor === null) return null;
  keys(cursor, ["schema", ...sourceKeys, "deliveryRunId", "deliveryRunAttempt"], "verified production cursor");
  assert.equal(cursor.schema, "catch.backend-delivery-cursor/v4");
  sourceIdentity(cursor);
  assert.equal(cursor.sourceCiWorkflowId, context.sourceCiWorkflowId);
  id(cursor.deliveryRunId, "production Delivery run id");
  id(cursor.deliveryRunAttempt, "production Delivery attempt");
  return cursor;
}
export function cutoverBlockers({context, deliveryRuns, rebaselineRuns, modernProductionRunIds = new Set()}) {
  validateContext(context, {activeRun: true});
  const blockers = [];
  for (const [kind, runs] of [["Delivery", deliveryRuns], ["Backend Rebaseline", rebaselineRuns]]) {
    assert.ok(Array.isArray(runs));
    for (const run of runs) {
      if (run.status === "completed" || run.head_branch !== "main" || run.head_repository?.id !== context.repositoryId) continue;
      if (kind === "Delivery") {
        assert.equal(run.workflow_id, context.deliveryWorkflowId, "Unexpected Delivery workflow generation in cutover fence.");
        number(run.run_number, "historical Delivery run number");
        if (run.run_number >= context.deliveryRunNumber || modernProductionRunIds.has(String(run.id))) continue;
      }
      blockers.push({kind, runId: String(run.id), runAttempt: run.run_attempt, status: run.status});
    }
  }
  return blockers;
}
export async function verifiedModernProductionRuns({context, runs, request = githubRequest}) {
  const verified = new Set();
  const definitions = new Map();
  for (const run of runs) {
    if (run.status === "completed" || run.run_number >= context.deliveryRunNumber ||
        run.head_branch !== "main" || run.head_repository?.id !== context.repositoryId ||
        run.display_title !== "Delivery lane v1 prod") continue;
    const exact = await request(`repos/${context.repository}/actions/runs/${run.id}/attempts/${run.run_attempt}`);
    runIdentity(exact, context, {runId: String(run.id), attempt: String(run.run_attempt)}, context.deliveryWorkflowId, ".github/workflows/delivery.yml");
    assert.equal(exact.run_number, run.run_number);
    if (exact.status === "completed") { verified.add(String(run.id)); continue; }
    if (exact.display_title !== "Delivery lane v1 prod") continue;
    const references = (exact.referenced_workflows ?? []).filter((item) =>
      shaPattern.test(item.sha ?? "") && item.ref === "refs/heads/main" &&
      item.path === `${context.repository}/.github/workflows/_firebase-promote.yml@${item.sha}`);
    if (references.length !== 1) continue;
    const revision = references[0].sha;
    if (!definitions.has(revision)) {
      const file = await request(`repos/${context.repository}/contents/.github/workflows/delivery.yml?ref=${revision}`);
      assert.equal(file.path, ".github/workflows/delivery.yml");
      assert.equal(file.encoding, "base64");
      const definition = Buffer.from(file.content, "base64").toString("utf8");
      definitions.set(revision, definition.includes("# catch.backend-delivery-lanes/v1\n") &&
        definition.includes("run-name: Delivery lane v1 ") &&
        definition.includes("'dev' && 'backend-delivery-dev' || 'backend-delivery'") &&
        definition.includes("backend_delivery_lanes.mjs select-prod"));
    }
    if (definitions.get(revision)) verified.add(String(run.id));
  }
  return verified;
}

function runsFromPages(pages) {
  assert.ok(Array.isArray(pages) && pages.length > 0 && pages.every((page) => Array.isArray(page.workflow_runs)), "Missing workflow run catalogue.");
  return pages.flatMap((page) => page.workflow_runs);
}
function productionCursorCatalogue(catalogue, context) {
  return artifactCatalogue(catalogue).filter((artifact) => artifact.expired === false &&
    sameRepository(artifact.workflow_run, context) && artifact.workflow_run.head_branch === "main" &&
    artifact.name?.startsWith("backend-delivery-cursor-"))
    .map(({id, name, digest, workflow_run}) => ({id, name, digest, producerRunId: workflow_run.id})).sort((a, b) => a.id - b.id);
}
export async function resolveLaneCursor({context, catalogue, productionCursor, request = githubRequest, verify = verifyDevCompletionArtifact}) {
  validateContext(context, {activeRun: true});
  const prod = validateProductionCursor(productionCursor, context);
  if (context.environment === "prod") return {cursor: prod, waiting: false, blockers: []};
  const candidates = completionCandidates(catalogue, context).sort((a, b) => b.sourceCiRunNumber - a.sourceCiRunNumber ||
    Number(b.sourceCiRunAttempt) - Number(a.sourceCiRunAttempt) || Number(b.deliveryRunId) - Number(a.deliveryRunId));
  let dev = null;
  if (candidates.length) {
    const candidate = candidates[0];
    dev = (await verify({context, artifactId: candidate.artifactId, artifactDigest: candidate.artifactDigest, request})).completion;
  }
  let blockers = [];
  if (dev === null) {
    const root = `repos/${context.repository}/actions/workflows`;
    const [delivery, rebaseline] = await Promise.all([
      request(`${root}/${context.deliveryWorkflowId}/runs?branch=main&per_page=100`, {paginate: true}),
      request(`${root}/backend-rebaseline.yml/runs?branch=main&per_page=100`, {paginate: true}),
    ]);
    const deliveryRuns = runsFromPages(delivery);
    const modernProductionRunIds = await verifiedModernProductionRuns({context, runs: deliveryRuns, request});
    blockers = cutoverBlockers({context, deliveryRuns, rebaselineRuns: runsFromPages(rebaseline), modernProductionRunIds});
    if (blockers.length === 0) {
      // A legacy snapshot may have finalized between the original cursor read
      // and the now-clear fence. Start a new independently verified selection;
      // never deploy from the stale base or trust the new catalogue as proof.
      const fresh = await request(`repos/${context.repository}/actions/artifacts?per_page=100`, {paginate: true});
      if (JSON.stringify(productionCursorCatalogue(fresh, context)) !== JSON.stringify(productionCursorCatalogue(catalogue, context))) {
        return {cursor: prod, waiting: true, refreshRequired: true, blockers: []};
      }
    }
  }
  if (dev && prod && dev.sourceCiRunNumber === prod.sourceCiRunNumber) {
    assert.equal(dev.sourceCiRunId, prod.sourceCiRunId, "Dev/prod source ordering conflict.");
    assert.equal(dev.sourceSha, prod.sourceSha, "Dev/prod source SHA conflict.");
  }
  const cursor = dev && (!prod || dev.sourceCiRunNumber > prod.sourceCiRunNumber) ?
    {schema: "catch.backend-delivery-cursor/v4", ...sourceIdentity(dev), deliveryRunId: dev.deliveryRunId, deliveryRunAttempt: dev.deliveryRunAttempt} : prod;
  return {cursor, waiting: blockers.length > 0, blockers};
}
export async function selectProductionSource({context, catalogue, sourceCandidates, productionCursor, request = githubRequest, verify = verifyDevCompletionArtifact}) {
  validateContext(context, {activeRun: true});
  assert.equal(context.environment, "prod");
  const prod = validateProductionCursor(productionCursor, context);
  assert.ok(Array.isArray(sourceCandidates));
  const pending = sourceCandidates.filter((candidate) => {
    sourceIdentity(candidate);
    assert.equal(candidate.sourceCiWorkflowId, context.sourceCiWorkflowId);
    return candidate.sourceCiRunNumber > (prod?.sourceCiRunNumber ?? 0);
  });
  const empty = {sourceCandidate: null, devCompletion: null, devCompletionArtifact: null, waiting: false};
  if (!pending.length) return empty;
  // Bootstrap is selected by dev's current-main proof. Until a shared baseline
  // exists, its first receipt identifies the only source production may select.
  const receipts = completionCandidates(catalogue, context);
  const bootstraps = receipts.filter((receipt) => receipt.bootstrap);
  if (!prod && receipts.length > 0) {
    assert.ok(bootstraps.length > 0, "Original dev bootstrap receipt missing or expired; refusing to invent a new production baseline.");
    assert.equal(new Set(bootstraps.map((receipt) => `${receipt.sourceCiRunId}:${receipt.sourceCiRunAttempt}:${receipt.sourceSha}`)).size, 1, "Ambiguous dev bootstrap authorities.");
  }
  const oldest = prod ? Math.min(...pending.map((candidate) => candidate.sourceCiRunNumber)) : bootstraps[0]?.sourceCiRunNumber ?? null;
  if (oldest === null) return {...empty, waiting: true};
  const candidates = pending.filter((candidate) => candidate.sourceCiRunNumber === oldest);
  assert.ok(candidates.length > 0, "CI authority for the oldest dev completion is missing or expired.");
  assert.equal(new Set(candidates.map((candidate) => `${candidate.sourceCiRunId}:${candidate.sourceSha}`)).size, 1, "Ambiguous oldest CI authority.");
  const matching = receipts.filter((receipt) => receipt.sourceCiRunNumber === oldest &&
    receipt.sourceCiRunId === candidates[0].sourceCiRunId && receipt.sourceSha === candidates[0].sourceSha);
  if (!matching.length) {
    const later = receipts.filter((receipt) => receipt.sourceCiRunNumber >= oldest)
      .sort((a, b) => b.sourceCiRunNumber - a.sourceCiRunNumber)[0];
    if (later) {
      await verify({context, artifactId: later.artifactId, artifactDigest: later.artifactDigest, request});
      throw new Error("Dev has reached this source or later but its exact completion receipt is missing or expired; refusing to skip or dispatch an endless retry.");
    }
    return {...empty, waiting: true};
  }
  assert.equal(new Set(matching.map((receipt) => receipt.sourceCiRunAttempt)).size, 1, "Multiple dev-completed CI attempts claim one source; explicit review required.");
  const candidate = matching.sort((a, b) => Number(b.deliveryRunId) - Number(a.deliveryRunId))[0];
  const source = candidates.find((item) => item.sourceCiRunAttempt === candidate.sourceCiRunAttempt);
  assert.ok(source, "Exact dev-completed CI attempt authority is missing or expired.");
  const proof = await verify({context, artifactId: candidate.artifactId, artifactDigest: candidate.artifactDigest, request});
  assert.deepEqual(sourceIdentity(source), sourceIdentity(proof.completion));
  assert.deepEqual({id: source.artifactId, name: source.artifactName, digest: source.artifactDigest}, proof.completion.authorityArtifact, "Selected authority differs from completed dev authority.");
  if (prod) assert.equal(proof.completion.baseSha, prod.sourceSha, "Dev completion does not continue the production cursor; refusing to skip a release.");
  return {sourceCandidate: source, devCompletion: proof.completion, devCompletionArtifact: proof.artifact, waiting: false};
}
export function prepareDevCompletion({context, source, authority, plan, provenanceBytes = null, verifiedPackageSha256 = null, devResult, bootstrap}) {
  validateContext(context, {activeRun: true});
  assert.equal(context.environment, "dev");
  assert.equal(source.sourceCiWorkflowId, context.sourceCiWorkflowId);
  const completion = {schema: DEV_COMPLETION_SCHEMA, environment: "dev", projectId: "catchdates-dev", bootstrap, ...sourceIdentity(source),
    baseSha: plan.baseSha, authorityArtifact: {id: source.artifactId, name: source.artifactName, digest: source.artifactDigest},
    planArtifact: authority.planArtifact, packageArtifact: authority.packageArtifact,
    packageSha256: verifiedPackageSha256, provenanceSha256: provenanceBytes === null ? null : hash(provenanceBytes),
    deliveryRunId: context.deliveryRunId, deliveryRunAttempt: context.deliveryRunAttempt};
  validateDevCompletion(completion);
  validateAuthority(authority, completion);
  validatePlan(plan, completion);
  assert.equal(devResult, completion.packageArtifact === null ? "skipped" : "success", "Dev completion requires successful promotion or a true skipped no-op.");
  if (completion.packageArtifact !== null) {
    assert.ok(Buffer.isBuffer(provenanceBytes), "Exact verified provenance bytes required.");
    const provenance = JSON.parse(provenanceBytes.toString("utf8"));
    validateProvenance(provenance, completion);
    assert.deepEqual(provenance.stages, ["firestore-indexes", "functions", "firestore-rules", "storage-rules"].filter((stage) => plan.operations.deployGroups.includes(stage)), "Package stages differ from the exact plan.");
  }
  return completion;
}
export function verifyCompletedPackage({completion, sourceSha, sourceCiRunId, sourceCiRunAttempt, baseSha, packageBytes, provenanceBytes}) {
  validateDevCompletion(completion);
  assert.ok(completion.packageArtifact !== null, "A no-op dev completion cannot authorize package deployment.");
  for (const [key, value] of Object.entries({sourceSha, sourceCiRunId, sourceCiRunAttempt, baseSha})) assert.equal(completion[key], value, `Completed dev ${key} mismatch.`);
  assert.ok(Buffer.isBuffer(packageBytes) && Buffer.isBuffer(provenanceBytes));
  assert.equal(hash(packageBytes), completion.packageSha256, "Production package bytes differ from completed dev.");
  assert.equal(hash(provenanceBytes), completion.provenanceSha256, "Production provenance bytes differ from completed dev.");
  const provenance = JSON.parse(provenanceBytes.toString("utf8"));
  validateProvenance(provenance, completion);
  assert.equal(packageBytes.length, provenance.artifact.sizeBytes, "Production package size mismatch.");
  return {ok: true, sourceSha, sourceCiRunId, sourceCiRunAttempt, packageSha256: completion.packageSha256};
}
function writeResult(file, value) {
  assert.ok(file, "--output is required.");
  fs.mkdirSync(path.dirname(path.resolve(file)), {recursive: true});
  const temporary = `${file}.${process.pid}.tmp`;
  try { fs.writeFileSync(temporary, `${JSON.stringify(value, null, 2)}\n`, {mode: 0o600, flag: "wx"}); fs.renameSync(temporary, file); }
  finally { fs.rmSync(temporary, {force: true}); }
}
function writeOutputs(file, values) {
  if (!file) return;
  for (const [key, value] of Object.entries(values)) {
    assert.match(key, /^[a-z][a-z0-9_]*$/);
    assert.ok(!/[\r\n]/.test(String(value)), "Unsafe GitHub output.");
  }
  fs.appendFileSync(file, Object.entries(values).map(([key, value]) => `${key}=${value}\n`).join(""));
}
export async function executeCli(argv, {request = githubRequest} = {}) {
  const [command, ...args] = argv;
  if (command === "--help") {
    console.log("Usage: backend_delivery_lanes.mjs resolve|select-prod|prepare-receipt|verify-artifact|verify-package|verify-run --output FILE [--context FILE --catalog FILE --prod-cursor FILE --candidates FILE --source FILE --authority FILE --plan FILE --provenance FILE --package FILE --verified-package-sha256 HEX --dev-result success|skipped --bootstrap true|false --artifact-id ID --artifact-digest sha256:HEX --receipt FILE --source-sha SHA --ci-run-id ID --ci-run-attempt N --base-sha SHA --github-output FILE --repository OWNER/REPO --repository-id ID --run-id ID --run-attempt N --role delivery|cursor]");
    return;
  }
  assert.ok(["resolve", "select-prod", "prepare-receipt", "verify-artifact", "verify-package", "verify-run"].includes(command), "Unknown lane command.");
  const allowed = new Set(["context", "catalog", "prod-cursor", "output", "github-output", "candidates", "source", "authority", "plan", "package", "provenance", "verified-package-sha256", "dev-result", "bootstrap", "artifact-id", "artifact-digest", "receipt", "source-sha", "ci-run-id", "ci-run-attempt", "base-sha", "repository", "repository-id", "run-id", "run-attempt", "role"]);
  const options = {};
  for (let index = 0; index < args.length; index += 2) {
    const key = args[index]?.replace(/^--/, "");
    assert.ok(args[index]?.startsWith("--") && allowed.has(key) && !Object.hasOwn(options, key) && args[index + 1] && !args[index + 1].startsWith("--"), "Unknown, duplicate or incomplete lane option.");
    options[key] = args[index + 1];
  }
  assert.ok(options.output, "--output is required.");
  for (const [key, file] of Object.entries(options)) {
    if (["context", "catalog", "prod-cursor", "candidates", "source", "authority", "plan", "package", "provenance", "receipt"].includes(key))
      assert.notEqual(path.resolve(file), path.resolve(options.output), "Output cannot overwrite input evidence.");
  }
  const context = options.context ? read(options.context) : null;
  let result, outputs = {};
  if (command === "verify-run") {
    result = await verifyWorkflowRun({repository: options.repository, repositoryId: Number(options["repository-id"]),
      runId: options["run-id"], runAttempt: options["run-attempt"], role: options.role, request});
  } else if (command === "resolve") {
    result = await resolveLaneCursor({context, catalogue: read(options.catalog), productionCursor: read(options["prod-cursor"]), request});
    outputs = {has_cursor: result.cursor !== null, source_ci_run_number: result.cursor?.sourceCiRunNumber ?? "", source_sha: result.cursor?.sourceSha ?? "", source_ci_workflow_id: context.sourceCiWorkflowId, waiting: result.waiting, refresh_required: result.refreshRequired === true};
  } else if (command === "select-prod") {
    result = await selectProductionSource({context, catalogue: read(options.catalog), sourceCandidates: read(options.candidates), productionCursor: read(options["prod-cursor"]), request});
    outputs = {waiting: result.waiting, dev_completion_artifact_id: result.devCompletionArtifact?.id ?? "", dev_completion_artifact_digest: result.devCompletionArtifact?.digest ?? ""};
  } else if (command === "verify-artifact") {
    const proof = await verifyDevCompletionArtifact({context, artifactId: Number(options["artifact-id"]), artifactDigest: options["artifact-digest"], request});
    result = proof.completion;
  } else if (command === "prepare-receipt") {
    assert.ok(["true", "false"].includes(options.bootstrap), "Explicit --bootstrap true|false required.");
    result = prepareDevCompletion({context, source: read(options.source), authority: read(options.authority), plan: read(options.plan),
      provenanceBytes: options.provenance ? fs.readFileSync(options.provenance) : null,
      verifiedPackageSha256: options.package ? hash(fs.readFileSync(options.package)) : options["verified-package-sha256"] ?? null, devResult: options["dev-result"], bootstrap: options.bootstrap === "true"});
    outputs = {artifact_name: completionArtifactName(result), dev_completion_artifact_name: completionArtifactName(result)};
  } else {
    result = verifyCompletedPackage({completion: read(options.receipt), sourceSha: options["source-sha"], sourceCiRunId: options["ci-run-id"],
      sourceCiRunAttempt: options["ci-run-attempt"], baseSha: options["base-sha"], packageBytes: fs.readFileSync(options.package), provenanceBytes: fs.readFileSync(options.provenance)});
  }
  writeResult(options.output, result);
  writeOutputs(options["github-output"], outputs);
  return result;
}
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  executeCli(process.argv.slice(2)).catch((error) => { console.error(error.message); process.exitCode = 1; });
}
