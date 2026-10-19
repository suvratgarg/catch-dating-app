import assert from "node:assert/strict";
import fs from "node:fs";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import {indexSignature, gcloudIndexList, inspectIndexReadiness, waitForIndexes} from "../../../tool/firebase/wait_firestore_indexes_ready.mjs";
import {assertSuccessfulSource, preview} from "./previewRelease.mjs";
import {waitMainMarketingValidation} from "../../../tool/ci/wait_main_marketing_validation.mjs";
export const reviewIndex = Object.freeze({collectionGroup: "reviews", queryScope: "COLLECTION", fields: [
  {fieldPath: "organizerId", mode: "ASCENDING"}, {fieldPath: "createdAt", mode: "DESCENDING"},
]});
const desiredDocument = {indexes: [reviewIndex]};
const directory = "build/website-review-index";
const repository = "suvratgarg/catch-dating-app";
function github(endpoint) {
  const result = spawnSync("gh", ["api", "-H", "Cache-Control: no-cache", endpoint], {encoding: "utf8", timeout: 30_000});
  assert.equal(result.status, 0, result.stderr); return JSON.parse(result.stdout);
}
export function assertIndexSource(document) {
  assert.ok(Array.isArray(document.indexes));
  const matches = document.indexes.filter(index => indexSignature(index, {desired: true}) === indexSignature(reviewIndex, {desired: true}));
  assert.equal(matches.length, 1, "Source must own exactly one reviewed organiser-review index");
  assert.deepEqual(matches[0], reviewIndex, "Index definition differs from bounded release scope");
}
export function assertReviewIndexReady(liveIndexes) {
  assert.equal(inspectIndexReadiness(desiredDocument, liveIndexes).complete, true, "Organiser-review index must be READY before website promotion");
}
export function indexNeedsCreation(liveIndexes) {
  const report = inspectIndexReadiness(desiredDocument, liveIndexes);
  assert.equal(report.failed.length, 0, "Existing index requires investigation, not recreation");
  return report.pending.some(item => item.state === "MISSING");
}
export function assertUnselectedIndexesPreserved(before, after) {
  const target = indexSignature(reviewIndex, {desired: true});
  for (const prior of before.filter(index => indexSignature(index) !== target)) {
    const current = after.find(index => index.name === prior.name);
    assert.ok(current, "An unselected index disappeared during release");
    assert.equal(indexSignature(current), indexSignature(prior), "An unselected index definition changed during release");
  }
}
async function authorize() {
  assert.equal(process.env.GITHUB_EVENT_NAME, "workflow_dispatch");
  assert.equal(process.env.GITHUB_REF, "refs/heads/main"); assert.equal(process.env.GITHUB_RUN_ATTEMPT, "1");
  assert.equal(process.env.GITHUB_REPOSITORY, repository);
  assert.equal(process.env.GITHUB_WORKFLOW_REF, `${repository}/.github/workflows/website-review-index.yml@refs/heads/main`);
  assertIndexSource(JSON.parse(fs.readFileSync("firestore.indexes.json", "utf8")));
  const sourceSha = process.env.GITHUB_SHA;
  const validation = await waitMainMarketingValidation({repository, sourceSha, maxWaitMs: 0});
  assert.equal(validation.validated, true);
  const run = github(`repos/${repository}/actions/runs/${validation.sourceCiRunId}`);
  assert.equal(run.run_attempt, validation.sourceCiRunAttempt);
  assertSuccessfulSource({run, sourceSha, repository, mainSha: github(`repos/${repository}/git/ref/heads/main`).object.sha});
  return {sourceSha, sourceCiRunId: run.id, sourceCiRunAttempt: run.run_attempt, project: preview.project, index: reviewIndex};
}
async function apply() {
  const authorization = await authorize();
  fs.mkdirSync(directory, {recursive: true});
  fs.writeFileSync(`${directory}/authorization.json`, JSON.stringify(authorization), {flag: "wx"});
  const before = gcloudIndexList({projectId: preview.project});
  fs.writeFileSync(`${directory}/before.json`, JSON.stringify(before));
  if (indexNeedsCreation(before)) {
    assert.deepEqual(await authorize(), authorization);
    const result = spawnSync("gcloud", ["firestore", "indexes", "composite", "create", `--project=${preview.project}`, "--database=(default)",
      "--collection-group=reviews", "--query-scope=collection", "--field-config=field-path=organizerId,order=ascending",
      "--field-config=field-path=createdAt,order=descending", "--async", "--quiet", "--format=json"], {encoding: "utf8", timeout: 120_000});
    fs.writeFileSync(`${directory}/create-result.json`, JSON.stringify({status: result.status, stdout: result.stdout, stderr: result.stderr}));
    assert.equal(result.status, 0, "Index creation did not complete cleanly; inspect metadata before a new dispatch");
  }
  const report = await waitForIndexes({desiredDocument, projectId: preview.project, timeoutMs: 30 * 60_000, pollMs: 20_000,
    onProgress: current => console.log(JSON.stringify(current))});
  const after = gcloudIndexList({projectId: preview.project});
  fs.writeFileSync(`${directory}/after.json`, JSON.stringify(after));
  assertUnselectedIndexesPreserved(before, after);
  fs.writeFileSync(`${directory}/ready.json`, JSON.stringify({...authorization, report}));
}
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  if (process.argv[2] === "authorize") console.log(JSON.stringify(await authorize(), null, 2));
  else if (process.argv[2] === "apply") await apply();
  else throw new Error("Expected authorize or apply");
}
