#!/usr/bin/env node
import assert from "node:assert/strict";
import fs from "node:fs";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";

const workflowPath = ".github/workflows/ci.yml";
const positive = value => Number.isSafeInteger(value) && value > 0;
const terminalFailures = new Set(["failure", "cancelled", "timed_out", "action_required", "stale", "neutral"]);

export function selectSameSourceRun({runs, canonical, repository, sourceSha}) {
  assert.ok(positive(canonical?.id) && canonical.path === workflowPath, "Canonical CI workflow identity is invalid.");
  assert.ok(Array.isArray(runs), "Missing canonical CI run list.");
  const candidates = runs.filter(run => run.head_sha === sourceSha && run.event === "push" && run.head_branch === "main");
  for (const run of candidates) {
    assert.ok(positive(run.id) && positive(run.run_attempt) && positive(run.run_number) &&
      run.workflow_id === canonical.id && run.path?.split("@")[0] === workflowPath && run.name === "CI" &&
      run.repository?.full_name === repository && run.head_repository?.full_name === repository &&
      positive(run.repository?.id) && run.head_repository?.id === run.repository.id,
    "Same-source CI run has an invalid workflow, repository, or attempt identity.");
  }
  return candidates.sort((a, b) => b.run_number - a.run_number || b.id - a.id)[0] ?? null;
}

export function inspectMarketingValidation({run, jobs, sourceSha}) {
  assert.ok(Array.isArray(jobs), "Missing same-attempt jobs.");
  const named = name => {
    const matches = jobs.filter(job => job.name === name);
    assert.ok(matches.length <= 1, `Ambiguous ${name} jobs in one attempt.`);
    const job = matches[0];
    if (!job) return null;
    assert.ok(positive(job.id) && job.run_id === run.id && job.run_attempt === run.run_attempt &&
      job.head_sha === sourceSha, `Wrong source or attempt for ${name}.`);
    if (job.status === "completed" && terminalFailures.has(job.conclusion)) {
      throw new Error(`${name} did not succeed (${job.conclusion}); repair CI before packaging.`);
    }
    return job;
  };
  const marketing = named("marketing / Validate marketing website");
  const skipped = named("marketing");
  assert.ok(!(marketing && skipped), "Marketing has conflicting executed and skipped job records.");
  if (marketing?.status === "completed") {
    assert.equal(marketing.conclusion, "success", "Marketing validation did not execute successfully.");
    // The CI caller omits capture checks only because this same-run lane owns
    // them. Preserve both validations before replacing the standalone caller.
    const capture = named("capture-freshness / Check app capture provenance and website copies");
    if (capture?.status === "completed") {
      assert.equal(capture.conclusion, "success", "Capture validation did not execute successfully.");
      return {validated: true, jobIds: [marketing.id, capture.id]};
    }
  }
  if (skipped?.status === "completed") {
    assert.equal(skipped.conclusion, "skipped", "Unexpected standalone Marketing job result.");
    // A skipped lane is never reused as evidence; run standalone validation.
    return {validated: false, jobIds: []};
  }
  return null;
}

export async function waitMainMarketingValidation({repository, sourceSha, request = githubRequest,
  sleep = ms => new Promise(resolve => setTimeout(resolve, ms)), now = Date.now,
  maxWaitMs = 35 * 60 * 1000, onWait = message => process.stderr.write(`${message}\n`)}) {
  assert.match(repository ?? "", /^[\w.-]+\/[\w.-]+$/u);
  assert.match(sourceSha ?? "", /^[0-9a-f]{40}$/u);
  const canonical = await request(`repos/${repository}/actions/workflows/ci.yml`);
  const endpoint = `repos/${repository}/actions/workflows/${canonical.id}/runs?branch=main&event=push&head_sha=${sourceSha}&per_page=100`;
  const started = now(); let previous = "";
  while (true) {
    const listing = await request(endpoint);
    const run = selectSameSourceRun({runs: listing.workflow_runs, canonical, repository, sourceSha});
    if (run) {
      assert.ok(!terminalFailures.has(run.conclusion), `Canonical same-source CI ended ${run.conclusion}; no validation reuse.`);
      const pages = await request(`repos/${repository}/actions/runs/${run.id}/attempts/${run.run_attempt}/jobs?per_page=100`, {paginate: true});
      assert.ok(Array.isArray(pages) && pages.length > 0 && pages.every(page => Array.isArray(page.jobs)), "Malformed same-attempt job pages.");
      const decision = inspectMarketingValidation({run, jobs: pages.flatMap(page => page.jobs), sourceSha});
      if (decision) {
        const latest = await request(endpoint);
        const current = selectSameSourceRun({runs: latest.workflow_runs, canonical, repository, sourceSha});
        if (current?.id === run.id && current.run_attempt === run.run_attempt) {
          assert.ok(!terminalFailures.has(current.conclusion), "Validation attempt failed or was cancelled during inspection.");
          return {...decision, sourceSha, sourceCiWorkflowId: canonical.id,
            sourceCiRunId: run.id, sourceCiRunAttempt: run.run_attempt,
            authority: decision.validated ? "same-source-marketing-and-capture-jobs" : "standalone-validation-required", node: process.version};
        }
      }
      assert.ok(run.status !== "completed" || decision,
        "Completed CI has no usable Marketing/capture execution; no fallback for missing evidence.");
    }
    assert.ok(now() - started < maxWaitMs, "Timed out awaiting exact-source Marketing validation; no package is authorized.");
    const message = `Waiting for same-source CI ${run ? `${run.id}/${run.run_attempt}` : "run"} Marketing/capture results.`;
    if (message !== previous) { onWait(message); previous = message; }
    await sleep(20_000);
  }
}

function githubRequest(endpoint, {paginate = false} = {}) {
  const result = spawnSync("gh", ["api", "-H", "Cache-Control: no-cache",
    ...(paginate ? ["--paginate", "--slurp"] : []), endpoint],
  {encoding: "utf8", timeout: 30_000, maxBuffer: 32 * 1024 * 1024});
  assert.equal(result.status, 0, result.stderr || "Cannot read same-source CI validation.");
  return JSON.parse(result.stdout);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  try {
    const result = await waitMainMarketingValidation({repository: process.env.GITHUB_REPOSITORY,
      sourceSha: process.env.GITHUB_SHA});
    if (process.env.GITHUB_OUTPUT) fs.appendFileSync(process.env.GITHUB_OUTPUT, `validated=${result.validated}\n`);
    console.log(JSON.stringify(result, null, 2));
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
