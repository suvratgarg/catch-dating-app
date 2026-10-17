import assert from "node:assert/strict";
import test from "node:test";
import {inspectMarketingValidation, selectCaptureBinding, selectSameSourceRun, waitMainMarketingValidation} from "./wait_main_marketing_validation.mjs";
const repository = "owner/repo", sourceSha = "a".repeat(40);
const canonical = {id: 7, path: ".github/workflows/ci.yml"};
const run = {id: 10, run_number: 9, run_attempt: 2, workflow_id: 7,
  name: "CI", path: canonical.path, event: "push", head_branch: "main", head_sha: sourceSha,
  repository: {id: 1, full_name: repository}, head_repository: {id: 1, full_name: repository},
  status: "in_progress", conclusion: null, run_started_at: "2026-10-17T01:00:00Z"};
const job = (id, name, conclusion = "success") => ({id, name, conclusion,
  run_id: run.id, run_attempt: run.run_attempt, head_sha: sourceSha, status: "completed", started_at: "2026-10-17T01:01:00Z", completed_at: "2026-10-17T01:02:00Z"});
const jobs = [job(20, "marketing / Validate marketing website"),
  job(21, "capture-freshness / Render and validate 12 canonical iPhone captures")];

const artifact = {id: 40, expired: false, name: `canonical-marketing-${sourceSha}-${run.id}-${run.run_attempt}`,
  digest: `sha256:${"d".repeat(64)}`, workflow_run: {id: run.id, repository_id: 1, head_repository_id: 1, head_sha: sourceSha}};

function fixture({artifacts = [artifact], runs = [run], results = jobs, canonicalResult = canonical, listings, sleep} = {}) {
  let listingIndex = 0;
  return {repository, sourceSha, onWait: () => {}, maxWaitMs: 1,
    now: (() => {let time = 0; return () => time++;})(), sleep: sleep ?? (async () => {}),
    request: async (endpoint, options) => {
      if (endpoint.endsWith("workflows/ci.yml")) return canonicalResult;
      if (/\/attempts\/\d+$/u.test(endpoint)) return run;
      if (endpoint.includes("/artifacts?")) { assert.equal(options.paginate, true); return [{artifacts}]; }
      if (endpoint.includes("/jobs?")) { assert.equal(options.paginate, true); return [{jobs: results}]; }
      assert.ok(endpoint.includes(`head_sha=${sourceSha}`));
      return {workflow_runs: listings ? listings[Math.min(listingIndex++, listings.length - 1)] : runs};
    }};
}

test("same-source Marketing and capture jobs are reused before unrelated CI finishes", async () => {
  const result = await waitMainMarketingValidation(fixture());
  assert.equal(result.validated, true);
  assert.deepEqual(result.jobIds, [20, 21]);
  assert.equal(result.captureBinding.artifactId, "40");
  assert.equal(result.captureBinding.artifactDigest, artifact.digest);
  assert.equal(result.sourceCiRunAttempt, 2); assert.equal(result.sourceSha, sourceSha);
});

test("an explicitly skipped Marketing lane requests standalone validation, never reuse", async () => {
  const result = await waitMainMarketingValidation(fixture({results: [job(22, "marketing", "skipped"), job(23, "capture-freshness", "skipped")]}));
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

for (const [label, artifacts] of [
  ["missing", []], ["duplicate", [artifact, artifact]],
  ["expired", [{...artifact, expired: true}]],
  ["previous-attempt", [{...artifact, name: `canonical-marketing-${sourceSha}-${run.id}-1`}]],
  ["wrong-source", [{...artifact, workflow_run: {...artifact.workflow_run, head_sha: "b".repeat(40)}}]],
  ["wrong-run", [{...artifact, workflow_run: {...artifact.workflow_run, id: 99}}]],
  ["foreign-repository", [{...artifact, workflow_run: {...artifact.workflow_run, repository_id: 2}}]],
  ["invalid-digest", [{...artifact, digest: "sha256:bad"}]],
]) test(`${label} capture artifact cannot authorize a successful job-only reuse`, async () => {
  await assert.rejects(() => waitMainMarketingValidation(fixture({artifacts})));
});

test("artifact selection ignores unrelated names instead of selecting a floating latest", () => {
  const binding = selectCaptureBinding({artifacts: [{...artifact, id: 999, name: "newest unrelated"}, artifact],
    run, canonical, repository, sourceSha});
  assert.equal(binding.artifactId, "40");
  assert.equal(binding.workflowRef, `${repository}/.github/workflows/ci.yml@refs/heads/main`);
  assert.equal(binding.workflowDefinitionSha, sourceSha);
});

test("rehydrated old successful jobs with new IDs and run_attempt cannot authorize reuse", async () => {
  const reused = jobs.map(entry => ({...entry, id: entry.id + 100,
    started_at: "2026-10-17T00:01:00Z", completed_at: "2026-10-17T00:02:00Z"}));
  await assert.rejects(() => waitMainMarketingValidation(fixture({results: reused})), /not executed in this CI attempt/);
});

test("a native-only CI change reuses its captures while requiring standalone React validation", async () => {
  const result = await waitMainMarketingValidation(fixture({results: [job(22, "marketing", "skipped"), jobs[1]]}));
  assert.equal(result.validated, false);
  assert.equal(result.captureProduced, true);
  assert.deepEqual(result.jobIds, [21]);
  assert.equal(result.captureBinding.artifactId, "40");
});

test("a skipped Marketing job waits for the existing capture producer instead of duplicating it", async () => {
  await assert.rejects(() => waitMainMarketingValidation(fixture({results: [job(22, "marketing", "skipped"),
    {...jobs[1], status: "in_progress", conclusion: null}]})), /Timed out/);
});
