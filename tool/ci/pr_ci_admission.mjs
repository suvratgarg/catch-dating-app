import fs from "node:fs";
import {execFileSync} from "node:child_process";
import {pathToFileURL} from "node:url";

export const ADMISSION_LABEL = "ci:admitted";
const SHA = /^[0-9a-f]{40}$/u;

export function isAdmissionEvent(event) {
  return ["opened", "synchronize", "reopened", "ready_for_review", "converted_to_draft"].includes(event.action) ||
    (["labeled", "unlabeled"].includes(event.action) && event.label?.name === ADMISSION_LABEL);
}

/** Scheduling authority only. Branch protection and exact-source review still apply. */
export async function resolveAdmission({repository, number, headSha, baseSha, runId, request,
  observe = () => {}}) {
  if (!/^[A-Za-z0-9][A-Za-z0-9-]*\/[A-Za-z0-9_.-]+$/u.test(repository ?? "") ||
      !Number.isSafeInteger(number) || number < 1 || !SHA.test(headSha ?? "") ||
      !SHA.test(baseSha ?? "") || !Number.isSafeInteger(runId) || runId < 1) {
    return {admitted: false, code: "invalid_identity", reason: "Invalid PR or tested source identity"};
  }
  const prefix = `repos/${repository}`;
  // A labeled current PR can disagree with the issues listing. Re-evaluate
  // that inconsistency once, rechecking every authority read.
  for (let evaluation = 1; evaluation <= 2; evaluation += 1) {
    const fresh = evaluation === 2;
    const read = (endpoint) => request(endpoint, {fresh});
    const admitted = new Set();
    let pageCount = 0;
    let listComplete = false;
    let code = "read_error";
    let retry = false;
    const deny = (reasonCode, reason) => {
      code = reasonCode;
      return {admitted: false, code, reason};
    };
    try {
      const [pr, main] = await Promise.all([
        read(`${prefix}/pulls/${number}`), read(`${prefix}/branches/main`),
      ]);
      if (pr.number !== number || pr.state !== "open" ||
          pr.base?.ref !== "main" || pr.base?.repo?.full_name !== repository ||
          pr.head?.repo?.full_name !== repository) {
        return deny("ineligible_pr", "Requires an open, same-repository PR into main");
      }
      if (pr.draft !== false) return deny("draft_pr", "Draft PR awaits readiness for review");
      if (pr.head.sha !== headSha) return deny("stale_head", "PR head changed; validate its new source");
      if (main.commit?.sha !== baseSha) return deny("stale_main", "Main changed; reconcile before full validation");
      if (!Array.isArray(pr.labels)) throw new Error("Missing current PR labels");
      if (!pr.labels.some((label) => label.name === ADMISSION_LABEL)) {
        return deny("awaiting_label", "Awaiting ci:admitted label");
      }
      for (let page = 1; page <= 100; page += 1) {
        pageCount = page;
        const rows = await read(`${prefix}/issues?state=open&labels=${encodeURIComponent(ADMISSION_LABEL)}&per_page=100&page=${page}`);
        if (!Array.isArray(rows)) throw new Error("Invalid admission list response");
        for (const row of rows) {
          if (!Number.isSafeInteger(row?.number) || row.number < 1 || !Array.isArray(row.labels)) {
            throw new Error("Invalid admission list entry");
          }
          if (row.pull_request && row.labels.some((label) => label.name === ADMISSION_LABEL)) admitted.add(row.number);
        }
        if (rows.length < 100) {
          listComplete = true;
          break;
        }
      }
      if (!listComplete) throw new Error("Admission pagination exceeded its bound");
      if (admitted.size !== 1 || !admitted.has(number)) {
        code = admitted.size === 0 ? "admission_list_empty" :
          !admitted.has(number) ? "admission_current_missing" : "admission_conflict";
        if (evaluation === 1) {
          retry = true;
          continue;
        }
        return deny(code, code === "admission_list_empty" ? "Admission list is empty despite the current PR label" :
          code === "admission_current_missing" ? "Current PR is absent from the admission list" :
            "Exactly one open PR must hold ci:admitted");
      }
      const runs = await read(`${prefix}/actions/workflows/ci.yml/runs?event=pull_request&head_sha=${headSha}&per_page=100`);
      if (!Array.isArray(runs.workflow_runs)) throw new Error("Missing validation run list");
      // Only admission-relevant events use this stable run name. Unrelated label
      // notifications cannot obsolete a valid run or start another full suite.
      const candidates = runs.workflow_runs.filter((run) => run.event === "pull_request" &&
        run.head_sha === headSha && run.path === ".github/workflows/ci.yml" &&
        run.display_title === `CI PR #${number}`);
      if (candidates.some((run) => !Number.isSafeInteger(run.id) || run.id < 1)) {
        return deny("invalid_run_identity", "Eligible validation list contains an invalid run identity");
      }
      if (candidates.some((run) => run.id > runId)) {
        return deny("superseded_run", "A newer admission event supersedes this queued validation");
      }
      // Actions returns newest runs first. The current run must be present in
      // this bounded window, otherwise deny rather than guessing old authority.
      if (!candidates.some((run) => run.id === runId)) {
        return deny("unverified_run", `Current admission run ${runId} is absent from the workflow-scoped window ` +
          `(${runs.workflow_runs.length} returned, ${candidates.length} eligible); freshness is unverified`);
      }
      code = "admitted";
      return {admitted: true, code,
        reason: "Sole admitted PR and latest eligible run match tested head and current main"};
    } finally {
      observe({repository, number, headSha, baseSha, runId, evaluation, fresh,
        pageCount, listComplete, observedPRNumbers: [...admitted].sort((a, b) => a - b), code, retry});
    }
  }
}

async function main() {
  const event = JSON.parse(fs.readFileSync(process.env.GITHUB_EVENT_PATH, "utf8"));
  if (!isAdmissionEvent(event)) {
    const result = {admitted: false, code: "unrelated_event",
      reason: "Unrelated event does not admit full validation"};
    publish(result);
    if (process.argv.includes("--require")) process.exitCode = 1;
    return;
  }
  const repository = process.env.GITHUB_REPOSITORY;
  const testedSha = process.env.GITHUB_SHA;
  if (process.env.GITHUB_EVENT_NAME !== "pull_request" || !SHA.test(testedSha ?? "")) {
    throw new Error("Admission requires a pull_request tested merge");
  }
  const parents = execFileSync("git", ["show", "-s", "--format=%P", testedSha], {encoding: "utf8"}).trim().split(" ");
  if (parents.length !== 2 || parents[1] !== event.pull_request?.head?.sha) {
    throw new Error("Tested merge parents do not match the event PR head");
  }
  const request = async (endpoint, {fresh = false} = {}) => {
    const response = await fetch(`https://api.github.com/${endpoint}`, {
      ...(fresh ? {cache: "no-store"} : {}),
      headers: {Accept: "application/vnd.github+json", Authorization: `Bearer ${process.env.GH_TOKEN ?? ""}`,
        "X-GitHub-Api-Version": "2022-11-28", ...(fresh ? {"Cache-Control": "no-cache", Pragma: "no-cache"} : {})},
      signal: AbortSignal.timeout(15000),
    });
    if (!response.ok) throw new Error(`GitHub admission read failed: HTTP ${response.status}`);
    return response.json();
  };
  const result = await resolveAdmission({repository, number: event.number,
    headSha: parents[1], baseSha: parents[0], runId: Number(process.env.GITHUB_RUN_ID),
    request, observe: publishObservation});
  publish(result);
  if (process.argv.includes("--require") && !result.admitted) process.exitCode = 1;
}

function publishObservation(observation) {
  const line = `PR CI admission observation: ${JSON.stringify(observation)}`;
  console.log(line);
  if (process.env.GITHUB_STEP_SUMMARY) fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY, `${line}\n`);
}

function publish(result) {
  console.log(`PR CI admission [${result.code}]: ${result.reason}`);
  if (process.env.GITHUB_OUTPUT) {
    fs.appendFileSync(process.env.GITHUB_OUTPUT,
      `admitted=${result.admitted}\nreason_code=${result.code}\n`);
  }
  if (process.env.GITHUB_STEP_SUMMARY) {
    fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY,
      `PR CI admission [${result.code}]: ${result.reason}.\n`);
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((error) => {console.error(error.message); process.exitCode = 1;});
}
