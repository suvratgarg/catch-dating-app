import assert from "node:assert/strict";
import fs from "node:fs";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import {readSnapshot} from "../ci/host_deletion_release.mjs";
import {selectSameSourceRun} from "../ci/wait_main_marketing_validation.mjs";
import {assertSuccessfulSource} from "../../website/scripts/next/previewRelease.mjs";
import {canonicalRepository} from "../lib/canonical_repository.mjs";

// Fixed additive repair for the two collection-group queries in accountDeletion.
// No Functions, rules, TTL, IAM, provider, application-data or cursor writes.
export const fields = ["swiperId", "targetId"];
export const indexes = [
  {order: "ASCENDING", queryScope: "COLLECTION"},
  {order: "DESCENDING", queryScope: "COLLECTION"},
  {arrayConfig: "CONTAINS", queryScope: "COLLECTION"},
  {order: "ASCENDING", queryScope: "COLLECTION_GROUP"},
];
const projects = {dev: "catchdates-dev", prod: "catch-dating-app-64e51"};
const directory = "build/host-deletion-indexes";
const sorted = rows => rows.map(row => JSON.stringify(row)).sort();
function command(binary, args) {
  const result = spawnSync(binary, args, {encoding: "utf8", timeout: 30_000, maxBuffer: 32 * 1024 * 1024});
  assert.ifError(result.error);
  assert.equal(result.status, 0, `${binary} read failed`);
  return result.stdout.trim();
}
const github = endpoint => JSON.parse(command("gh", ["api", "-H", "Cache-Control: no-cache", endpoint]));
const write = (name, data) => fs.writeFileSync(`${directory}/${name}.json`, JSON.stringify(data, null, 2));
function nameFor(environment, field) {
  assert.ok(Object.hasOwn(projects, environment));
  assert.ok(fields.includes(field));
  return `projects/${projects[environment]}/databases/(default)/collectionGroups/outgoing/fields/${field}`;
}
export function assertSource(document) {
  for (const fieldPath of fields) {
    const matches = document.fieldOverrides.filter(row => row.collectionGroup === "outgoing" && row.fieldPath === fieldPath);
    assert.equal(matches.length, 1);
    assert.deepEqual(matches[0], {collectionGroup: "outgoing", fieldPath, indexes});
  }
}
export function inspectField(field, environment, fieldPath) {
  assert.equal(field.name, nameFor(environment, fieldPath));
  assert.equal(field.ttlConfig, undefined, "Unexpected TTL on selected field");
  assert.ok(!field.indexConfig?.reverting, "Field configuration is reverting");
  const observed = field.indexConfig.indexes.map(index => {
    assert.equal(index.state, "READY", "Selected index is not READY");
    assert.equal(index.fields.length, 1);
    assert.equal(index.fields[0].fieldPath, fieldPath);
    const {fieldPath: ignored, ...mode} = index.fields[0];
    return {...mode, queryScope: index.queryScope};
  });
  const complete = observed.length === indexes.length;
  assert.deepEqual(sorted(observed), sorted(complete ? indexes : indexes.slice(0, 3)),
    "Unexpected selected-field definition; no replacement is authorized");
  return complete;
}
export function patchBody(field, environment, fieldPath) {
  assert.equal(inspectField(field, environment, fieldPath), false);
  return {name: field.name, indexConfig: {indexes: indexes.map(({queryScope, ...mode}) =>
    ({queryScope, fields: [{fieldPath, ...mode}]}))}};
}
export function assertPreserved(before, after, beforeFields, afterFields, environment) {
  const omitSelected = rows => rows.filter(row => !fields.some(field => row.name === nameFor(environment, field)));
  assert.deepEqual(sorted(omitSelected(afterFields)), sorted(omitSelected(beforeFields)),
    "Unselected field index or TTL configuration changed");
  const omitFieldDigest = snapshot => {
    const copy = structuredClone(snapshot);
    delete copy.protectedResources.fields;
    return copy;
  };
  assert.deepEqual(omitFieldDigest(after), omitFieldDigest(before),
    "Functions, composite indexes, rules, IAM, providers or other protected metadata changed");
}
export function assertDevReceipt(receipt, env) {
  assert.equal(receipt.environment, "dev");
  assert.equal(receipt.sourceSha, env.GITHUB_SHA);
  assert.equal(receipt.runId, env.GITHUB_RUN_ID);
  assert.equal(receipt.runAttempt, env.GITHUB_RUN_ATTEMPT);
  assert.deepEqual(receipt.fields, fields);
  assert.equal(receipt.ready, true);
  assert.equal(receipt.preserved, true);
}
export function authorize(environment, env = process.env) {
  assert.ok(Object.hasOwn(projects, environment));
  assert.equal(env.GITHUB_EVENT_NAME, "workflow_dispatch");
  assert.equal(env.GITHUB_REF, "refs/heads/main");
  assert.equal(env.GITHUB_RUN_ATTEMPT, "1");
  const repository = canonicalRepository(env);
  assert.equal(env.GITHUB_WORKFLOW_REF, `${repository}/.github/workflows/host-deletion-indexes.yml@refs/heads/main`);
  assert.equal(command("git", ["rev-parse", "HEAD"]), env.GITHUB_SHA);
  assertSource(JSON.parse(fs.readFileSync("firestore.indexes.json", "utf8")));
  const canonical = github(`repos/${repository}/actions/workflows/ci.yml`);
  const runs = github(`repos/${repository}/actions/workflows/${canonical.id}/runs?branch=main&event=push&head_sha=${env.GITHUB_SHA}&per_page=100`).workflow_runs;
  const run = selectSameSourceRun({runs, canonical, repository, sourceSha: env.GITHUB_SHA});
  assert.ok(run, "Current-main CI is missing");
  assertSuccessfulSource({run, sourceSha: env.GITHUB_SHA, repository, mainSha: github(`repos/${repository}/git/ref/heads/main`).object.sha});
  return {environment, sourceSha: env.GITHUB_SHA, sourceCiRunId: run.id, sourceCiRunAttempt: run.run_attempt,
    runId: env.GITHUB_RUN_ID, runAttempt: env.GITHUB_RUN_ATTEMPT, fields};
}
async function apply(environment) {
  const authorization = authorize(environment);
  if (environment === "prod") assertDevReceipt(JSON.parse(fs.readFileSync(`${directory}/dev/ready.json`, "utf8")), process.env);
  fs.mkdirSync(directory, {recursive: true});
  write("authorization", authorization);
  const project = projects[environment];
  const request = async (resource, body) => {
    assert.ok(resource.startsWith(`projects/${project}/databases/(default)/`));
    if (body) assert.ok(fields.some(field => resource === `${nameFor(environment, field)}?updateMask=indexConfig`));
    const token = command("gcloud", ["auth", "print-access-token"]);
    const response = await fetch(`https://firestore.googleapis.com/v1/${resource}`, {
      method: body ? "PATCH" : "GET",
      headers: {Authorization: `Bearer ${token}`, "Content-Type": "application/json"},
      ...(body ? {body: JSON.stringify(body)} : {}), signal: AbortSignal.timeout(30_000),
    });
    assert.ok(response.ok, `Firestore metadata request failed: HTTP ${response.status}; inspect before retrying`);
    return response.json();
  };
  const listFields = async () => {
    const rows = new Map();
    for (const filter of ["indexConfig.usesAncestorConfig:false", "ttlConfig:*"]) {
      let cursor = ""; const seen = new Set();
      do {
        assert.ok(seen.size < 30 && !seen.has(cursor)); seen.add(cursor);
        const page = await request(`projects/${project}/databases/(default)/collectionGroups/-/fields?${new URLSearchParams({filter, pageSize: "0", ...(cursor ? {pageToken: cursor} : {})})}`);
        assert.ok(Array.isArray(page.fields ?? []));
        for (const field of page.fields ?? []) {
          if (rows.has(field.name)) assert.deepEqual(rows.get(field.name), field);
          rows.set(field.name, field);
        }
        cursor = page.nextPageToken ?? "";
      } while (cursor);
    }
    return [...rows.values()];
  };
  const before = await readSnapshot(environment);
  const beforeFields = await listFields();
  const selected = await Promise.all(fields.map(field => request(nameFor(environment, field))));
  selected.forEach((field, i) => inspectField(field, environment, fields[i]));
  write("before", {snapshot: before, fields: beforeFields, selected});
  assert.deepEqual(authorize(environment), authorization);
  for (const [i, fieldPath] of fields.entries()) {
    if (inspectField(selected[i], environment, fieldPath)) continue;
    const fresh = await request(nameFor(environment, fieldPath));
    assert.deepEqual(fresh, selected[i], "Selected field drifted before mutation");
    assert.deepEqual(authorize(environment), authorization);
    // One PATCH per field, never an automatic retry after an unknown outcome.
    const operation = await request(`${fresh.name}?updateMask=indexConfig`, patchBody(fresh, environment, fieldPath));
    write(`operation-${fieldPath}`, operation);
    assert.match(operation.name ?? "", new RegExp(`^projects/${project}/databases/\\(default\\)/operations/[^/]+$`));
    const deadline = Date.now() + 25 * 60_000;
    let state = operation;
    while (!state.done) {
      assert.ok(Date.now() < deadline, "Index operation timed out; inspect metadata before retry");
      await new Promise(resolve => setTimeout(resolve, 15_000));
      state = await request(operation.name);
    }
    write(`completed-${fieldPath}`, state);
    assert.equal(state.error, undefined, "Index operation failed");
    assert.equal(inspectField(await request(fresh.name), environment, fieldPath), true);
  }
  const after = await readSnapshot(environment);
  const afterFields = await listFields();
  write("after", {snapshot: after, fields: afterFields});
  assertPreserved(before, after, beforeFields, afterFields, environment);
  for (const field of fields) assert.equal(inspectField(await request(nameFor(environment, field)), environment, field), true);
  write("ready", {...authorization, ready: true, preserved: true});
}
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  if (process.argv[2] === "authorize") console.log(JSON.stringify(authorize(process.argv[3])));
  else if (process.argv[2] === "apply") await apply(process.argv[3]);
  else throw new Error("Expected authorize or apply, and dev or prod");
}
