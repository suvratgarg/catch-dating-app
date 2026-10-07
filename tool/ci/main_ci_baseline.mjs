#!/usr/bin/env node
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";

const shaPattern = /^[0-9a-f]{40}$/;
const positiveInteger = (value) => Number.isSafeInteger(Number(value)) && Number(value) > 0;
const workflowPath = ".github/workflows/ci.yml";

function requireCondition(condition, message) {
  if (!condition) throw new Error(message);
}

export function inspectPredecessors({current, runs, repository}) {
  const candidates = new Map();
  for (const run of runs) {
    if (run.run_number >= current.run_number || run.event !== "push" ||
        run.head_branch !== "main" || run.head_repository?.full_name !== repository ||
        run.head_repository?.id !== current.repository.id ||
        run.workflow_id !== current.workflow_id ||
        run.path?.split("@")[0] !== workflowPath) continue;
    requireCondition(positiveInteger(run.id) && positiveInteger(run.run_number) &&
      positiveInteger(run.run_attempt), "Malformed predecessor CI identity.");
    const previous = candidates.get(run.id);
    // Pagination can observe the same run twice while another run is added.
    // Prefer the latest attempt and, within it, the conservative active state.
    if (!previous || run.run_attempt > previous.run_attempt ||
        (run.run_attempt === previous.run_attempt && run.status !== "completed")) {
      candidates.set(run.id, run);
    }
  }
  const older = [...candidates.values()];
  const active = older.filter((run) => run.status !== "completed");
  const successful = older.filter((run) => run.status === "completed" && run.conclusion === "success")
    .sort((a, b) => b.run_number - a.run_number);
  return {active, previousSuccess: successful[0] ?? null};
}

export async function resolveMainBaseline({
  repository, runId, runAttempt, sourceSha, fallbackBase, minimumBaseSha, wait = false,
  request = githubRequest, ensureAncestor = gitAncestor,
  isAncestor = gitIsAncestor,
  sleep = (milliseconds) => new Promise((resolve) => setTimeout(resolve, milliseconds)),
  now = Date.now, maxWaitMs = 175 * 60 * 1000,
  onWait = (message) => process.stderr.write(`${message}\n`),
}) {
  requireCondition(/^[\w.-]+\/[\w.-]+$/.test(repository), "Invalid repository.");
  requireCondition(positiveInteger(runId) && positiveInteger(runAttempt), "Invalid current CI run or attempt.");
  requireCondition(shaPattern.test(sourceSha), "Exact source SHA required.");
  if (minimumBaseSha != null) {
    // The caller must independently verify this attempt's immutable validation
    // plan before supplying its base. Reject an unusable floor before waiting.
    requireCondition(shaPattern.test(minimumBaseSha) && !/^0+$/.test(minimumBaseSha),
      "Exact nonzero validation floor SHA required.");
    await ensureAncestor(minimumBaseSha, sourceSha);
  }
  const current = await request(`repos/${repository}/actions/runs/${runId}`);
  requireCondition(String(current.id) === String(runId) && current.run_attempt === Number(runAttempt) &&
    current.head_sha === sourceSha && current.event === "push" && current.head_branch === "main" &&
    current.name === "CI" && current.path?.split("@")[0] === workflowPath &&
    current.repository?.full_name === repository && current.head_repository?.full_name === repository &&
    current.head_repository?.id === current.repository?.id && positiveInteger(current.repository?.id) &&
    positiveInteger(current.workflow_id) && positiveInteger(current.run_number),
  "Current run is not the exact same-repository main CI source and attempt.");
  const started = now();
  let lastActive = "";
  while (true) {
    const pages = await request(
      `repos/${repository}/actions/workflows/${current.workflow_id}/runs?branch=main&event=push&per_page=100`,
      {paginate: true},
    );
    requireCondition(Array.isArray(pages) && pages.length > 0 &&
      pages.every((page) => Array.isArray(page.workflow_runs)), "Malformed main CI run pages.");
    const {active, previousSuccess} = inspectPredecessors({
      current, repository, runs: pages.flatMap((page) => page.workflow_runs),
    });
    if (wait && active.length > 0) {
      requireCondition(now() - started < maxWaitMs, "Timed out waiting for preceding main CI runs; no plan may be published.");
      const activeKey = active.map((run) => `${run.id}:${run.run_attempt}`).sort().join(",");
      if (lastActive !== activeKey) {
        onWait(`Waiting for ${active.length} lower-numbered active main CI run(s) before publication.`);
        lastActive = activeKey;
      }
      await sleep(20_000);
      continue;
    }
    let baseSha = previousSuccess?.head_sha ?? fallbackBase;
    requireCondition(shaPattern.test(baseSha) && !/^0+$/.test(baseSha), "Missing usable successful baseline or push-before SHA.");
    await ensureAncestor(baseSha, sourceSha);
    if (minimumBaseSha != null && baseSha !== minimumBaseSha &&
        !await isAncestor(minimumBaseSha, baseSha)) {
      requireCondition(await isAncestor(baseSha, minimumBaseSha),
        "Main CI baseline and validation floor have incompatible ancestry.");
      // A predecessor's rerun can remove it from the live success list. Its
      // status transition cannot broaden this attempt's validated window.
      baseSha = minimumBaseSha;
    }
    const selectedPredecessor = previousSuccess?.head_sha === baseSha ? previousSuccess : null;
    return {
      baseSha, sourceSha, sourceCiRunId: String(runId), sourceCiRunAttempt: String(runAttempt),
      previousCiRunId: selectedPredecessor ? String(selectedPredecessor.id) : null,
      previousCiRunNumber: selectedPredecessor?.run_number ?? null,
      activePredecessors: active.length,
    };
  }
}

function githubRequest(endpoint, {paginate = false} = {}) {
  const result = spawnSync("gh", ["api", ...(paginate ? ["--paginate", "--slurp"] : []), endpoint], {
    encoding: "utf8", maxBuffer: 32 * 1024 * 1024,
  });
  requireCondition(result.status === 0, result.stderr || "Cannot read main CI metadata.");
  return JSON.parse(result.stdout);
}

function gitAncestor(base, head) {
  requireCondition(gitIsAncestor(base, head), "Main CI baseline is not a reachable source ancestor.");
}

function gitIsAncestor(base, head) {
  const result = spawnSync("git", ["merge-base", "--is-ancestor", base, head], {encoding: "utf8"});
  requireCondition(result.status === 0 || result.status === 1,
    result.stderr || "Cannot prove main CI baseline ancestry.");
  return result.status === 0;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const args = process.argv.slice(2);
  if (args.includes("--help")) {
    console.log("Usage: main_ci_baseline.mjs --repository owner/repo --run-id id --run-attempt attempt --source-sha sha --fallback-base sha [--minimum-base-sha verified-validation-base] [--wait]");
  } else {
    try {
      const options = {};
      const names = {"--repository": "repository", "--run-id": "runId", "--run-attempt": "runAttempt",
        "--source-sha": "sourceSha", "--fallback-base": "fallbackBase", "--minimum-base-sha": "minimumBaseSha"};
      for (let index = 0; index < args.length; index++) {
        const flag = args[index];
        if (flag === "--wait" && options.wait == null) { options.wait = true; continue; }
        const name = names[flag];
        requireCondition(name && options[name] == null && args[index + 1] && !args[index + 1].startsWith("--"),
          `Unknown, duplicate or incomplete option: ${flag}`);
        options[name] = args[++index];
      }
      console.log(JSON.stringify(await resolveMainBaseline(options)));
    } catch (error) {
      console.error(error.message);
      process.exitCode = 1;
    }
  }
}
