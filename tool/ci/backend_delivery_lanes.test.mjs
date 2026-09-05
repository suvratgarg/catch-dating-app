import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  AUTHORIZATION_JOB, DEV_COMPLETION_FILE, DEV_PROMOTION_JOB,
  artifactCatalogue, completionArtifactName, completionCandidates, cutoverBlockers,
  executeCli, prepareDevCompletion, readSingleJsonArchive, resolveLaneCursor,
  selectProductionSource, validateDevCompletion, verifyCompletedPackage, verifyDevCompletionArtifact, verifiedModernProductionRuns, verifyWorkflowRun,
} from "./backend_delivery_lanes.mjs";

const sha = (letter) => letter.repeat(40);
const hash = (bytes) => createHash("sha256").update(bytes).digest("hex");
const digest = (bytes) => `sha256:${hash(bytes)}`;
const context = {environment: "dev", repository: "owner/catch", repositoryId: 42,
  sourceCiWorkflowId: 77, deliveryWorkflowId: 88, deliveryRunId: "900", deliveryRunAttempt: "1", deliveryRunNumber: 100};
const prodContext = {...context, environment: "prod", deliveryRunId: "901", deliveryRunNumber: 101};
const prodCursor = {schema: "catch.backend-delivery-cursor/v4", sourceCiWorkflowId: 77, sourceCiRunNumber: 19,
  sourceCiRunId: "119", sourceCiRunAttempt: "1", sourceSha: sha("a"), deliveryRunId: "899", deliveryRunAttempt: "1"};
function crc32(bytes) {
  let crc = 0xffffffff;
  for (const byte of bytes) {
    crc ^= byte;
    for (let index = 0; index < 8; index++) crc = (crc >>> 1) ^ (0xedb88320 & -(crc & 1));
  }
  return (crc ^ 0xffffffff) >>> 0;
}
function zip(entries) {
  const locals = [], centrals = [];
  let offset = 0;
  for (const entry of entries) {
    const name = Buffer.from(entry.name), localName = Buffer.from(entry.localName ?? entry.name);
    const bytes = Buffer.from(entry.text);
    const local = Buffer.alloc(30);
    local.writeUInt32LE(0x04034b50); local.writeUInt16LE(20, 4);
    local.writeUInt32LE(crc32(bytes), 14); local.writeUInt32LE(bytes.length, 18); local.writeUInt32LE(bytes.length, 22);
    local.writeUInt16LE(localName.length, 26);
    const central = Buffer.alloc(46);
    central.writeUInt32LE(0x02014b50); central.writeUInt16LE((3 << 8) | 20, 4); central.writeUInt16LE(20, 6);
    central.writeUInt32LE(crc32(bytes), 16); central.writeUInt32LE(bytes.length, 20); central.writeUInt32LE(bytes.length, 24);
    central.writeUInt16LE(name.length, 28); central.writeUInt32LE(((entry.mode ?? 0o100600) << 16) >>> 0, 38);
    central.writeUInt32LE(offset, 42);
    locals.push(local, localName, bytes); centrals.push(central, name);
    offset += local.length + localName.length + bytes.length;
  }
  const centralBytes = Buffer.concat(centrals), end = Buffer.alloc(22);
  end.writeUInt32LE(0x06054b50); end.writeUInt16LE(entries.length, 8); end.writeUInt16LE(entries.length, 10);
  end.writeUInt32LE(centralBytes.length, 12); end.writeUInt32LE(offset, 16);
  return Buffer.concat([...locals, centralBytes, end]);
}
const jsonZip = (name, value) => zip([{name, text: JSON.stringify(value)}]);
function fixture({noop = false, bootstrap = false, runNumber = 20, attempt = "1", sourceSha = sha("b"), baseSha = sha("a"), deliveryId = "900", artifactStart = 40} = {}) {
  const sourceRunId = String(100 + runNumber);
  const ctx = {...context, deliveryRunId: deliveryId};
  const planArtifact = {id: artifactStart + 2, name: `harness-plan-${runNumber}-${sourceRunId}-${sourceSha}-${attempt}`, digest: `sha256:${"1".repeat(64)}`};
  const packageArtifact = noop ? null : {id: artifactStart + 3, name: `firebase-delivery-${sourceSha}-${attempt}`, digest: `sha256:${"2".repeat(64)}`};
  const identity = {sourceCiWorkflowId: 77, sourceCiRunNumber: runNumber, sourceCiRunId: sourceRunId, sourceCiRunAttempt: attempt, sourceSha};
  const authority = {schema: "catch.ci-delivery-authority/v3", ...identity, deployRequired: !noop, planArtifact, packageArtifact};
  const authorityBytes = jsonZip("ci-delivery-authority.json", authority);
  const source = {...identity, artifactId: artifactStart + 1,
    artifactName: `harness-success-v3-77-${runNumber}-${sourceRunId}-${sourceSha}-${attempt}`, artifactDigest: digest(authorityBytes)};
  const plan = {mode: "main", complete: true, baseSha, sourceSha, sourceCiRunId: sourceRunId, sourceCiRunAttempt: attempt,
    operations: {deployGroups: noop ? [] : ["functions"]}};
  const packageBytes = Buffer.from("exact verified package");
  const provenance = {schema: "catch.delivery-provenance/v2", sourceSha, sourceCiRunId: sourceRunId, sourceCiRunAttempt: attempt,
    artifact: {name: "firebase-backend.tar.gz", sha256: hash(packageBytes), sizeBytes: packageBytes.length}, stages: ["functions"]};
  const provenanceBytes = noop ? null : Buffer.from(`${JSON.stringify(provenance)}\n`);
  const input = {context: ctx, source, authority, plan, provenanceBytes, verifiedPackageSha256: noop ? null : hash(packageBytes), devResult: noop ? "skipped" : "success", bootstrap};
  const completion = prepareDevCompletion(input);
  const completionBytes = jsonZip(DEV_COMPLETION_FILE, completion);
  const repo = {id: 42, full_name: "owner/catch"};
  const metadata = (binding, producer, headSha) => ({...binding, expired: false,
    workflow_run: {id: Number(producer), head_sha: headSha, head_branch: "main", repository_id: 42, head_repository_id: 42}});
  const artifact = metadata({id: artifactStart + 4, name: completionArtifactName(completion), digest: digest(completionBytes)}, deliveryId, sha("d"));
  const producer = {id: Number(deliveryId), name: "Delivery lane v1 dev", display_title: "Delivery lane v1 dev", workflow_id: 88, path: ".github/workflows/delivery.yml", run_attempt: 1,
    repository: repo, head_repository: repo, head_branch: "main", event: "repository_dispatch", status: "in_progress", conclusion: null};
  const sourceRun = {id: Number(sourceRunId), name: "CI", workflow_id: 77, run_number: runNumber, run_attempt: Number(attempt),
    path: ".github/workflows/ci.yml", repository: repo, head_repository: repo, head_branch: "main", head_sha: sourceSha,
    event: "push", status: "completed", conclusion: "success"};
  const jobs = [AUTHORIZATION_JOB, DEV_PROMOTION_JOB].map((name) => ({name, run_id: Number(deliveryId), run_attempt: 1,
    status: "completed", conclusion: noop && name === DEV_PROMOTION_JOB ? "skipped" : "success"}));
  const root = "repos/owner/catch";
  const answers = new Map([
    [`${root}/actions/artifacts/${artifact.id}`, artifact], [`${root}/actions/artifacts/${artifact.id}/zip`, completionBytes],
    [`${root}/actions/artifacts/${source.artifactId}`, metadata(completion.authorityArtifact, sourceRunId, sourceSha)],
    [`${root}/actions/artifacts/${source.artifactId}/zip`, authorityBytes],
    [`${root}/actions/runs/${deliveryId}/attempts/1`, producer],
    [`${root}/actions/runs/${deliveryId}/attempts/1/jobs?per_page=100`, [{jobs}]],
    [`${root}/actions/runs/${sourceRunId}/attempts/${attempt}`, sourceRun],
    [`${root}/actions/artifacts?per_page=100`, [{artifacts: []}]],
    [`${root}/actions/workflows/88/runs?branch=main&per_page=100`, [{workflow_runs: []}]],
    [`${root}/actions/workflows/backend-rebaseline.yml/runs?branch=main&per_page=100`, [{workflow_runs: []}]],
  ]);
  const calls = [];
  const request = async (endpoint) => {
    calls.push(endpoint);
    assert.ok(answers.has(endpoint), `Unexpected request: ${endpoint}`);
    const value = answers.get(endpoint);
    return Buffer.isBuffer(value) ? Buffer.from(value) : structuredClone(value);
  };
  const verifyArgs = {context, artifactId: artifact.id, artifactDigest: artifact.digest, request};
  return {ctx, input, completion, completionBytes, source, sourceRun, authority, producer, plan, packageBytes, provenanceBytes,
    artifact, catalogue: [{artifacts: [artifact]}], answers, calls, request, verifyArgs, jobs};
}

test("strict dev completion records successful exact package or true no-op only", () => {
  const f = fixture();
  assert.equal(validateDevCompletion(f.completion), f.completion);
  assert.match(completionArtifactName(f.completion), /-incremental$/);
  assert.match(completionArtifactName(fixture({bootstrap: true}).completion), /-bootstrap$/);
  for (const devResult of ["skipped", "failure", "cancelled", "", undefined]) assert.throws(() => prepareDevCompletion({...f.input, devResult}));
  assert.equal(fixture({noop: true}).completion.packageSha256, null);
  assert.throws(() => fixture({noop: true, bootstrap: true}));
  for (const patch of [{environment: "prod"}, {projectId: "catch-dating-app-64e51"}, {bootstrap: undefined},
    {sourceCiRunAttempt: "2"}, {deliveryRunAttempt: "2"}, {extra: "untrusted"}, {packageSha256: "bad"}]) {
    assert.throws(() => validateDevCompletion({...f.completion, ...patch}));
  }
});

test("preparation rejects altered authority, unbound source, validation-only plans and stage mismatch", () => {
  const f = fixture();
  for (const plan of [{...f.plan, baseSha: "bad"}, {...f.plan, sourceSha: sha("c")}, {...f.plan, validationOnly: true},
    {...f.plan, operations: {deployGroups: []}}, {...f.plan, operations: {deployGroups: ["storage-rules"]}}]) {
    assert.throws(() => prepareDevCompletion({...f.input, plan}));
  }
  assert.throws(() => prepareDevCompletion({...f.input, authority: {...f.authority, sourceCiRunAttempt: "2"}}));
  assert.throws(() => prepareDevCompletion({...f.input, verifiedPackageSha256: "c".repeat(64)}));
  assert.throws(() => prepareDevCompletion({...f.input, context: {...context, deliveryRunAttempt: "2"}}));
});

test("archive verifier reads one regular JSON entry without extracting, rejects ambiguity and tampering", () => {
  assert.deepEqual(readSingleJsonArchive(jsonZip(DEV_COMPLETION_FILE, {ok: true}), DEV_COMPLETION_FILE), {ok: true});
  for (const entries of [[], [{name: "../backend-dev-completion.json", text: "{}"}],
    [{name: DEV_COMPLETION_FILE, text: "{}", mode: 0o120777}], [{name: DEV_COMPLETION_FILE, text: "{}", mode: 0o40755}],
    [{name: DEV_COMPLETION_FILE, localName: "other.json", text: "{}"}],
    [{name: DEV_COMPLETION_FILE, text: "{}"}, {name: DEV_COMPLETION_FILE, text: "{}"}]]) {
    assert.throws(() => readSingleJsonArchive(zip(entries), DEV_COMPLETION_FILE));
  }
  const corrupted = jsonZip(DEV_COMPLETION_FILE, {ok: true});
  corrupted[30 + Buffer.byteLength(DEV_COMPLETION_FILE)] ^= 1;
  assert.throws(() => readSingleJsonArchive(corrupted, DEV_COMPLETION_FILE));
  assert.throws(() => readSingleJsonArchive(Buffer.concat([jsonZip(DEV_COMPLETION_FILE, {}), Buffer.from("trailing")]), DEV_COMPLETION_FILE));
});

test("dev proof independently verifies archive, historical CI attempt, authority and successful dev job", async () => {
  const f = fixture();
  const verified = await verifyDevCompletionArtifact(f.verifyArgs);
  assert.deepEqual(verified.completion, f.completion);
  assert.deepEqual(verified.artifact, {id: f.artifact.id, name: f.artifact.name, digest: f.artifact.digest});
  assert.equal(f.calls.length, 7);
  assert.ok(f.calls.every((endpoint) => endpoint.startsWith("repos/owner/catch/actions/")));
});

test("later dispatch failure and producer nonterminal status do not erase completed dev proof", async () => {
  const f = fixture();
  for (const patch of [{status: "in_progress", conclusion: null}, {status: "completed", conclusion: "failure"}]) {
    Object.assign(f.producer, patch);
    assert.deepEqual((await verifyDevCompletionArtifact(f.verifyArgs)).completion, f.completion);
  }
});

test("no-op proof needs successful authorization and cannot hide attempted or failed promotion", async () => {
  const f = fixture({noop: true});
  await verifyDevCompletionArtifact(f.verifyArgs);
  for (const conclusion of ["success", "failure", "cancelled"]) {
    f.jobs[1].conclusion = conclusion;
    await assert.rejects(verifyDevCompletionArtifact(f.verifyArgs));
  }
  f.jobs.splice(1);
  await verifyDevCompletionArtifact(f.verifyArgs);
});

test("foreign metadata, SHA/attempt changes, failed/missing dev and expired evidence fail closed", async () => {
  const mutations = [
    (f) => { f.artifact.workflow_run.repository_id = 99; },
    (f) => { f.artifact.workflow_run.head_branch = "feature"; },
    (f) => { f.artifact.workflow_run.id = 899; },
    (f) => { f.artifact.expired = true; },
    (f) => { f.artifact.digest = `sha256:${"a".repeat(64)}`; },
    (f) => { f.sourceRun.head_sha = sha("c"); },
    (f) => { f.sourceRun.run_attempt = 2; },
    (f) => { f.sourceRun.workflow_id = 78; },
    (f) => { f.sourceRun.conclusion = "failure"; },
    (f) => { f.producer.path = ".github/workflows/untrusted.yml"; },
    (f) => { f.producer.run_attempt = 2; },
    (f) => { f.jobs[1].conclusion = "failure"; },
    (f) => { f.jobs[1].status = "in_progress"; },
    (f) => { f.jobs[1].run_attempt = 2; },
    (f) => { f.jobs[1].run_id = 899; },
    (f) => { f.jobs.splice(1); },
    (f) => { f.jobs[0].conclusion = "skipped"; },
    (f) => { f.answers.get(`repos/owner/catch/actions/artifacts/${f.source.artifactId}`).workflow_run.head_sha = sha("c"); },
  ];
  for (const mutate of mutations) {
    const f = fixture(); mutate(f);
    await assert.rejects(verifyDevCompletionArtifact(f.verifyArgs));
  }
});

test("completion catalogue rejects workflow generations, ambiguous source order and changed pagination", () => {
  const f = fixture();
  assert.equal(completionCandidates(f.catalogue, context).length, 1);
  assert.equal(artifactCatalogue([f.catalogue[0], f.catalogue[0]]).length, 1);
  const changed = {...f.artifact, digest: `sha256:${"f".repeat(64)}`};
  assert.throws(() => artifactCatalogue([{artifacts: [f.artifact]}, {artifacts: [changed]}]));
  const wrongGeneration = {...f.artifact, name: f.artifact.name.replace("v1-77-", "v1-78-")};
  assert.throws(() => completionCandidates([{artifacts: [wrongGeneration]}], context), /generation/);
  const conflict = {...f.artifact, id: 99, name: f.artifact.name.replace(sha("b"), sha("c"))};
  assert.throws(() => completionCandidates([{artifacts: [f.artifact, conflict]}], context), /Ambiguous/);
});

test("first dev cutover waits for earlier queued/waiting workers and rebaseline, excluding current/newer workers", () => {
  const run = (run_number, status) => ({id: 700 + run_number, run_number, run_attempt: 1, workflow_id: 88,
    head_branch: "main", head_repository: {id: 42}, status});
  const result = cutoverBlockers({context,
    deliveryRuns: [run(95, "completed"), run(96, "queued"), run(97, "waiting"), run(98, "pending"), run(99, "requested"), run(100, "in_progress"), run(101, "queued")],
    rebaselineRuns: [run(50, "in_progress")]});
  assert.equal(result.length, 5);
  assert.deepEqual(result.map((item) => item.status), ["queued", "waiting", "pending", "requested", "in_progress"]);
});

test("effective dev cursor uses latest verified completion or later verified production rebaseline", async () => {
  const f = fixture();
  const resolved = await resolveLaneCursor({context, catalogue: f.catalogue, productionCursor: prodCursor, request: f.request});
  assert.equal(resolved.cursor.sourceCiRunNumber, 20);
  assert.equal(resolved.waiting, false);
  assert.ok(!f.calls.some((endpoint) => endpoint.includes("/actions/workflows/")), "Established dev receipt removes legacy startup fence.");
  const later = {...prodCursor, sourceCiRunNumber: 21, sourceCiRunId: "121", sourceSha: sha("c")};
  assert.deepEqual((await resolveLaneCursor({context, catalogue: f.catalogue, productionCursor: later, request: f.request})).cursor, later);
  assert.deepEqual((await resolveLaneCursor({context: prodContext, catalogue: f.catalogue, productionCursor: prodCursor, request: f.request})).cursor, prodCursor);
});

test("initial dev fence defers without replacing production baseline and fails on missing run pages", async () => {
  const f = fixture();
  f.answers.set("repos/owner/catch/actions/workflows/88/runs?branch=main&per_page=100", [{workflow_runs: [{id: 899,
    workflow_id: 88, run_number: 99, run_attempt: 1, head_branch: "main", head_repository: {id: 42}, status: "waiting"}]}]);
  const options = {context, catalogue: [{artifacts: []}], productionCursor: prodCursor, request: f.request};
  const result = await resolveLaneCursor(options);
  assert.equal(result.waiting, true);
  assert.deepEqual(result.cursor, prodCursor);
  f.answers.set("repos/owner/catch/actions/workflows/88/runs?branch=main&per_page=100", []);
  await assert.rejects(resolveLaneCursor(options));
});

test("production pins the completed dev attempt when a newer successful CI attempt exists", async () => {
  const f = fixture();
  const newer = {...f.source, sourceCiRunAttempt: "2", artifactId: 80,
    artifactName: f.source.artifactName.replace(/-1$/, "-2"), artifactDigest: `sha256:${"8".repeat(64)}`};
  const options = {context: prodContext, catalogue: f.catalogue, productionCursor: prodCursor,
    sourceCandidates: [newer, f.source], request: f.request};
  const result = await selectProductionSource(options);
  assert.deepEqual(result.sourceCandidate, f.source);
  assert.equal(result.devCompletion.sourceCiRunAttempt, "1");
  await assert.rejects(selectProductionSource({...options, sourceCandidates: [newer]}), /Exact dev-completed CI attempt/);
});

test("production waits only while dev is behind and rejects missing intermediate completion evidence", async () => {
  const f = fixture({runNumber: 21, sourceSha: sha("c"), baseSha: sha("b")});
  const earlier = fixture().source;
  const options = {context: prodContext, catalogue: f.catalogue, productionCursor: prodCursor,
    sourceCandidates: [f.source, earlier], request: f.request};
  const waiting = await selectProductionSource({...options, catalogue: [{artifacts: []}]});
  assert.equal(waiting.waiting, true);
  assert.equal(waiting.sourceCandidate, null);
  assert.equal(f.calls.length, 0);
  await assert.rejects(selectProductionSource(options), /exact completion receipt is missing or expired/);
  assert.ok(f.calls.includes(`repos/owner/catch/actions/artifacts/${f.artifact.id}/zip`), "Later proof is verified before declaring missing history.");
  await assert.rejects(selectProductionSource({...options, sourceCandidates: [f.source]}), /does not continue/);
});

test("a modern production waiter releases initial dev only after verifying its pinned control plane", async () => {
  const f = fixture();
  const row = {...f.producer, id: 899, run_number: 99, display_title: "Delivery lane v1 prod"};
  const revision = sha("e");
  const reference = {path: `owner/catch/.github/workflows/_firebase-promote.yml@${revision}`, sha: revision, ref: "refs/heads/main"};
  const exact = {...row, referenced_workflows: [reference]};
  const endpoint = "repos/owner/catch/actions/runs/899/attempts/1";
  const fileEndpoint = `repos/owner/catch/contents/.github/workflows/delivery.yml?ref=${revision}`;
  const actualWorkflow = fs.readFileSync(new URL("../../.github/workflows/delivery.yml", import.meta.url), "utf8");
  const definition = (content) => ({path: ".github/workflows/delivery.yml", encoding: "base64", content: Buffer.from(content).toString("base64")});
  f.answers.set(endpoint, exact);
  f.answers.set(fileEndpoint, definition(actualWorkflow));
  const options = {context, runs: [row], request: f.request};
  assert.deepEqual(await verifiedModernProductionRuns(options), new Set(["899"]));
  f.answers.set("repos/owner/catch/actions/workflows/88/runs?branch=main&per_page=100", [{workflow_runs: [row]}]);
  const resolution = await resolveLaneCursor({context, catalogue: [{artifacts: []}], productionCursor: prodCursor, request: f.request});
  assert.equal(resolution.waiting, false, "A production worker waiting for first dev proof cannot strand the dev worker it wakes.");
  for (const patch of [{referenced_workflows: []}, {referenced_workflows: [{...reference, ref: "refs/heads/feature"}]},
    {referenced_workflows: [{...reference, path: `other/catch/.github/workflows/_firebase-promote.yml@${revision}`}]},
    {display_title: "Delivery"}]) {
    f.answers.set(endpoint, {...exact, ...patch});
    assert.deepEqual(await verifiedModernProductionRuns(options), new Set());
  }
  f.answers.set(endpoint, exact);
  for (const content of ["name: Delivery", actualWorkflow.replace("# catch.backend-delivery-lanes/v1", "# old lane"),
    actualWorkflow.replaceAll("backend-delivery-dev", "backend-delivery")]) {
    f.answers.set(fileEndpoint, definition(content));
    assert.deepEqual(await verifiedModernProductionRuns(options), new Set());
  }
  f.answers.set(endpoint, {...exact, status: "completed"});
  assert.deepEqual(await verifiedModernProductionRuns(options), new Set(["899"]));
  f.answers.set(endpoint, {...exact, workflow_id: 89});
  await assert.rejects(verifiedModernProductionRuns(options));
});

test("dev receipt from a recreated Delivery workflow cannot authorize production", async () => {
  const f = fixture();
  f.answers.set("repos/owner/catch/actions/runs/900/attempts/1", {...f.producer, workflow_id: 89});
  await assert.rejects(verifyDevCompletionArtifact(f.verifyArgs), /Unexpected workflow generation/);
});

test("production bootstrap follows its original dev receipt despite old authorities and newer dev progress", async () => {
  const a = fixture({bootstrap: true});
  const b = fixture({runNumber: 21, sourceSha: sha("c"), baseSha: sha("b"), deliveryId: "901", artifactStart: 50});
  const old = fixture({runNumber: 18, sourceSha: sha("a"), baseSha: sha("9"), artifactStart: 60});
  const options = {context: prodContext, catalogue: [{artifacts: [b.artifact, a.artifact]}], productionCursor: null,
    sourceCandidates: [old.source, b.source, a.source], request: a.request};
  const result = await selectProductionSource(options);
  assert.equal(result.sourceCandidate.sourceCiRunNumber, 20);
  assert.equal(result.devCompletion.bootstrap, true);
  await assert.rejects(selectProductionSource({...options, catalogue: b.catalogue}), /bootstrap receipt missing/);
  const waiting = await selectProductionSource({...options, catalogue: [{artifacts: []}]});
  assert.equal(waiting.waiting, true);
});

test("no-op receipts keep source continuity without permitting package or environment substitution", async () => {
  const f = fixture({noop: true});
  const result = await selectProductionSource({context: prodContext, catalogue: f.catalogue, productionCursor: prodCursor,
    sourceCandidates: [f.source], request: f.request});
  assert.equal(result.devCompletion.packageArtifact, null);
  assert.throws(() => verifyCompletedPackage({completion: f.completion}));
});

test("production package proof binds source, base, bytes and raw provenance independently", () => {
  const f = fixture();
  const options = {completion: f.completion, sourceSha: f.completion.sourceSha, sourceCiRunId: f.completion.sourceCiRunId,
    sourceCiRunAttempt: "1", baseSha: f.completion.baseSha, packageBytes: f.packageBytes, provenanceBytes: f.provenanceBytes};
  assert.equal(verifyCompletedPackage(options).ok, true);
  for (const patch of [{sourceSha: sha("c")}, {sourceCiRunId: "121"}, {sourceCiRunAttempt: "2"}, {baseSha: sha("9")},
    {packageBytes: Buffer.from("different bytes")}, {provenanceBytes: Buffer.from(f.provenanceBytes.toString().trim())}]) {
    assert.throws(() => verifyCompletedPackage({...options, ...patch}));
  }
});

test("CLI produces strict receipt and stable workflow outputs without downloading package twice", async (t) => {
  const f = fixture();
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-lane-cli-"));
  t.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  const file = (name, value) => {
    const target = path.join(directory, name);
    fs.writeFileSync(target, Buffer.isBuffer(value) ? value : JSON.stringify(value));
    return target;
  };
  const output = path.join(directory, DEV_COMPLETION_FILE), githubOutput = path.join(directory, "github-output");
  const args = ["prepare-receipt", "--context", file("context.json", context), "--source", file("source.json", f.source),
    "--authority", file("authority.json", f.authority), "--plan", file("plan.json", f.plan), "--provenance", file("provenance.json", f.provenanceBytes),
    "--verified-package-sha256", hash(f.packageBytes), "--dev-result", "success", "--bootstrap", "false", "--output", output, "--github-output", githubOutput];
  await executeCli(args);
  assert.deepEqual(JSON.parse(fs.readFileSync(output)), f.completion);
  assert.match(fs.readFileSync(githubOutput, "utf8"), /dev_completion_artifact_name=backend-dev-completion-v1-/);
  const resolved = path.join(directory, "resolved.json");
  await executeCli(["resolve", "--context", file("prod-context.json", prodContext), "--catalog", file("catalog.json", f.catalogue),
    "--prod-cursor", file("prod.json", prodCursor), "--output", resolved, "--github-output", githubOutput], {request: f.request});
  assert.match(fs.readFileSync(githubOutput, "utf8"), /has_cursor=true\nsource_ci_run_number=19\nsource_sha=a{40}\nsource_ci_workflow_id=77\nwaiting=false/);
  await assert.rejects(executeCli(["prepare-receipt", "--output", output, "--source", output]), /overwrite/);
  await assert.rejects(executeCli(["resolve", "--unknown", "x", "--output", resolved]));
});

test("an uploaded dev input without completion cannot block recovery or masquerade as progress", async () => {
  const f = fixture();
  const input = {...f.artifact, name: "backend-dev-input-1"};
  const catalogue = [{artifacts: [input]}];
  assert.deepEqual(completionCandidates(catalogue, context), []);
  const result = await resolveLaneCursor({context, catalogue, productionCursor: prodCursor, request: f.request});
  assert.equal(result.waiting, false);
  assert.deepEqual(result.cursor, prodCursor);
  const production = await selectProductionSource({context: prodContext, catalogue, productionCursor: prodCursor,
    sourceCandidates: [f.source], request: f.request});
  assert.equal(production.waiting, true);
});

test("a legacy snapshot finalized during the initial fence forces fresh independently verified selection", async () => {
  const f = fixture();
  const newerCursor = {...f.artifact, id: 90, name: "backend-delivery-cursor-v4-77-21-121-1-" + sha("c") + "-899-1"};
  f.answers.set("repos/owner/catch/actions/artifacts?per_page=100", [{artifacts: [newerCursor]}]);
  const options = {context, catalogue: [{artifacts: []}], productionCursor: prodCursor, request: f.request};
  const stale = await resolveLaneCursor(options);
  assert.equal(stale.waiting, true);
  assert.equal(stale.refreshRequired, true);
  assert.deepEqual(stale.cursor, prodCursor, "Catalogue changes are a reason to reverify, not authority for a new base.");
  const fresh = await resolveLaneCursor({...options, catalogue: [{artifacts: [newerCursor]}],
    productionCursor: {...prodCursor, sourceCiRunNumber: 21, sourceCiRunId: "121", sourceSha: sha("c")}});
  assert.equal(fresh.waiting, false);
  assert.equal(fresh.refreshRequired, undefined, "A stable new snapshot does not dispatch endlessly.");
});


test("dev receipt accepts custom and legacy run titles without weakening workflow identity", async () => {
  for (const name of ["Delivery", "backend-delivery-drain", "Delivery lane v1 dev"]) {
    const f = fixture();
    f.producer.name = name;
    f.producer.display_title = name;
    f.sourceRun.name = "CI for an arbitrary commit title";
    assert.deepEqual((await verifyDevCompletionArtifact(f.verifyArgs)).completion, f.completion);
  }
});

test("historical run identity uses an allowed workflow path and numeric generation, never its title", async () => {
  const repo = {id: 42, full_name: "owner/catch"};
  for (const [filename, workflowId, names] of [
    ["delivery.yml", 88, ["Delivery", "backend-delivery-drain", "Delivery lane v1 dev", "Delivery lane v1 prod"]],
    ["backend-rebaseline.yml", 89, ["Backend Rebaseline", "Reviewed baseline for main"]],
  ]) {
    for (const name of names) {
      const run = {id: 900, run_attempt: 1, workflow_id: workflowId, path: `.github/workflows/${filename}@refs/heads/main`,
        name, display_title: name, repository: repo, head_repository: repo, head_branch: "main", status: "in_progress"};
      const metadata = {id: workflowId, path: `.github/workflows/${filename}`, name: "Renamed workflow", state: "disabled_manually"};
      const calls = [];
      const request = async (endpoint) => {
        calls.push(endpoint);
        if (endpoint === "repos/owner/catch/actions/runs/900/attempts/1") return run;
        assert.equal(endpoint, `repos/owner/catch/actions/workflows/${filename}`);
        return metadata;
      };
      const args = {repository: "owner/catch", repositoryId: 42, runId: "900", runAttempt: "1", role: "cursor", request};
      assert.deepEqual(await verifyWorkflowRun(args), run);
      assert.equal(calls.length, 2);
      if (filename === "delivery.yml") assert.deepEqual(await verifyWorkflowRun({...args, role: "delivery"}), run);
      else await assert.rejects(verifyWorkflowRun({...args, role: "delivery"}), /workflow path/);
      for (const patch of [{id: 901}, {run_attempt: 2}, {workflow_id: 99}, {head_branch: "feature"},
        {repository: {...repo, id: 99}}, {repository: {...repo, full_name: "foreign/catch"}},
        {head_repository: {...repo, id: 99}}, {head_repository: {...repo, full_name: "foreign/catch"}},
        {path: ".github/workflows/untrusted.yml"}, {path: null}]) {
        const original = {...run};
        Object.assign(run, patch);
        await assert.rejects(verifyWorkflowRun(args));
        Object.assign(run, original);
      }
      for (const patch of [{id: 0}, {id: "88"}, {id: 1.5}, {id: 99}, {path: ".github/workflows/untrusted.yml"}]) {
        const original = {...metadata};
        Object.assign(metadata, patch);
        await assert.rejects(verifyWorkflowRun(args));
        Object.assign(metadata, original);
      }
      await assert.rejects(verifyWorkflowRun({...args, role: "untrusted"}));
    }
  }
});
