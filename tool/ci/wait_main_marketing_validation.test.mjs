import assert from "node:assert/strict";
import test from "node:test";
import {inspectMarketingValidation, selectSameSourceRun, waitMainMarketingValidation} from "./wait_main_marketing_validation.mjs";
const repository = "owner/repo", sourceSha = "a".repeat(40);
const canonical = {id: 7, path: ".github/workflows/ci.yml"};
const run = {id: 10, run_number: 9, run_attempt: 2, workflow_id: 7,
  name: "CI", path: canonical.path, event: "push", head_branch: "main", head_sha: sourceSha,
  repository: {id: 1, full_name: repository}, head_repository: {id: 1, full_name: repository},
  status: "in_progress", conclusion: null};
const job = (id, name, conclusion = "success") => ({id, name, conclusion,
  run_id: run.id, run_attempt: run.run_attempt, head_sha: sourceSha, status: "completed"});
const jobs = [job(20, "marketing / Validate marketing website"),
  job(21, "capture-freshness / Check app capture provenance and website copies")];

function fixture({runs = [run], results = jobs, canonicalResult = canonical, listings, sleep} = {}) {
  let listingIndex = 0;
  return {repository, sourceSha, onWait: () => {}, maxWaitMs: 1,
    now: (() => {let time = 0; return () => time++;})(), sleep: sleep ?? (async () => {}),
    request: async (endpoint, options) => {
      if (endpoint.endsWith("workflows/ci.yml")) return canonicalResult;
      if (endpoint.includes("/jobs?")) { assert.equal(options.paginate, true); return [{jobs: results}]; }
      assert.ok(endpoint.includes(`head_sha=${sourceSha}`));
      return {workflow_runs: listings ? listings[Math.min(listingIndex++, listings.length - 1)] : runs};
    }};
}

test("same-source Marketing and capture jobs are reused before unrelated CI finishes", async () => {
  const result = await waitMainMarketingValidation(fixture());
  assert.equal(result.validated, true);
  assert.deepEqual(result.jobIds, [20, 21]);
  assert.equal(result.sourceCiRunAttempt, 2); assert.equal(result.sourceSha, sourceSha);
});

test("an explicitly skipped Marketing lane requests standalone validation, never reuse", async () => {
  const result = await waitMainMarketingValidation(fixture({results: [job(22, "marketing", "skipped")]}));
  assert.equal(result.validated, false); assert.deepEqual(result.jobIds, []);
});

for (const conclusion of ["failure", "cancelled", "timed_out", "neutral", "skipped"]) {
  for (const index of [0, 1]) test(`${jobs[index].name}=${conclusion} cannot authorize packaging`, async () => {
    const bad = structuredClone(jobs); bad[index].conclusion = conclusion;
    await assert.rejects(() => waitMainMarketingValidation(fixture({results: bad})), /did not succeed|did not execute successfully/);
  });
}

test("missing jobs and a completed run without evidence fail closed", async () => {
  await assert.rejects(() => waitMainMarketingValidation(fixture({results: []})), /Timed out/);
  await assert.rejects(() => waitMainMarketingValidation(fixture({runs: [{...run, status: "completed", conclusion: "success"}], results: [jobs[0]]})), /no usable Marketing/);
});

for (const [field, value] of [["run_attempt", 1], ["run_id", 99], ["head_sha", "b".repeat(40)], ["id", 0]]) {
  test(`job ${field} mismatch cannot reuse another execution`, () => {
    const wrong = structuredClone(jobs); wrong[0][field] = value;
    assert.throws(() => inspectMarketingValidation({run, jobs: wrong, sourceSha}), /Wrong source or attempt/);
  });
}

for (const [field, value] of [["workflow_id", 8], ["path", ".github/workflows/other.yml"], ["name", "Other"], ["run_attempt", 0], ["repository", {id: 1, full_name: "foreign/repo"}], ["head_repository", {id: 2, full_name: repository}]]) {
  test(`run ${field} mismatch cannot reuse foreign validation`, () => {
    assert.throws(() => selectSameSourceRun({runs: [{...run, [field]: value}], canonical, repository, sourceSha}), /invalid workflow, repository, or attempt/);
  });
}

for (const change of [{head_sha: "b".repeat(40)}, {event: "pull_request"}, {head_branch: "feature"}]) {
  test(`unrelated run ${JSON.stringify(change)} is never reused`, async () => {
    await assert.rejects(() => waitMainMarketingValidation(fixture({runs: [{...run, ...change}]})), /Timed out/);
  });
}

test("cancellation during the final identity recheck revokes reuse", async () => {
  await assert.rejects(() => waitMainMarketingValidation(fixture({listings: [[run], [{...run, status: "completed", conclusion: "cancelled"}]]})), /failed or was cancelled/);
});

test("a newer attempt cannot reuse successful jobs from the previous attempt", async () => {
  await assert.rejects(() => waitMainMarketingValidation(fixture({listings: [[run], [{...run, run_attempt: 3}]]})), /Timed out/);
});

test("ambiguous job records and canonical workflow mismatch fail closed", async () => {
  assert.throws(() => inspectMarketingValidation({run, jobs: [...jobs, jobs[0]], sourceSha}), /Ambiguous/);
  await assert.rejects(() => waitMainMarketingValidation(fixture({canonicalResult: {...canonical, path: "other"}})), /Canonical CI workflow identity/);
});
