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
export async function resolveAdmission({repository, number, headSha, baseSha, runId, request}) {
  const deny = (reason) => ({admitted: false, reason});
  if (!/^[A-Za-z0-9][A-Za-z0-9-]*\/[A-Za-z0-9_.-]+$/u.test(repository ?? "") ||
      !Number.isSafeInteger(number) || number < 1 || !SHA.test(headSha ?? "") ||
      !SHA.test(baseSha ?? "") || !Number.isSafeInteger(runId) || runId < 1) return deny("Invalid PR or tested source identity");
  const prefix = `repos/${repository}`;
  const [pr, main] = await Promise.all([
    request(`${prefix}/pulls/${number}`), request(`${prefix}/branches/main`),
  ]);
  if (pr.number !== number || pr.state !== "open" || pr.draft !== false ||
      pr.base?.ref !== "main" || pr.base?.repo?.full_name !== repository ||
      pr.head?.repo?.full_name !== repository) return deny("Requires an open, ready, same-repository PR into main");
  if (pr.head.sha !== headSha) return deny("PR head changed; validate its new source");
  if (main.commit?.sha !== baseSha) return deny("Main changed; reconcile before full validation");
  if (!Array.isArray(pr.labels)) throw new Error("Missing current PR labels");
  if (!pr.labels.some((label) => label.name === ADMISSION_LABEL)) return deny("Awaiting ci:admitted label");
  const admitted = new Set();
  for (let page = 1; page <= 100; page += 1) {
    const rows = await request(`${prefix}/issues?state=open&labels=${encodeURIComponent(ADMISSION_LABEL)}&per_page=100&page=${page}`);
    if (!Array.isArray(rows)) throw new Error("Invalid admission list response");
    for (const row of rows) {
      if (!Number.isSafeInteger(row.number) || !Array.isArray(row.labels)) throw new Error("Invalid admission list entry");
      if (row.pull_request && row.labels.some((label) => label.name === ADMISSION_LABEL)) admitted.add(row.number);
    }
    if (rows.length < 100) {
      if (admitted.size !== 1 || !admitted.has(number)) return deny("Exactly one open PR must hold ci:admitted");
      const runs = await request(`${prefix}/actions/workflows/ci.yml/runs?event=pull_request&head_sha=${headSha}&per_page=100`);
      if (!Array.isArray(runs.workflow_runs)) throw new Error("Missing validation run list");
      // Only admission-relevant events use this stable run name. Unrelated label
      // notifications cannot obsolete a valid run or start another full suite.
      const candidates = runs.workflow_runs.filter((run) => run.event === "pull_request" &&
        run.head_sha === headSha && run.path === ".github/workflows/ci.yml" &&
        run.display_title === `CI PR #${number}`);
      if (!candidates.some((run) => run.id === runId) ||
          candidates.some((run) => !Number.isSafeInteger(run.id) || run.id > runId)) {
        return deny("A newer admission event supersedes this queued validation");
      }
      // Actions returns newest runs first. The current run must be present in
      // this bounded window, otherwise deny rather than guessing old authority.
      return {admitted: true, reason: "Sole admitted PR and latest eligible run match tested head and current main"};
    }
  }
  throw new Error("Admission pagination exceeded its bound");
}

async function main() {
  const event = JSON.parse(fs.readFileSync(process.env.GITHUB_EVENT_PATH, "utf8"));
  if (!isAdmissionEvent(event)) {
    if (process.env.GITHUB_OUTPUT) fs.appendFileSync(process.env.GITHUB_OUTPUT, "admitted=false\n");
    console.log("Unrelated event does not admit full validation");
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
  const request = async (endpoint) => {
    const response = await fetch(`https://api.github.com/${endpoint}`, {
      headers: {Accept: "application/vnd.github+json", Authorization: `Bearer ${process.env.GH_TOKEN ?? ""}`,
        "X-GitHub-Api-Version": "2022-11-28"}, signal: AbortSignal.timeout(15000),
    });
    if (!response.ok) throw new Error(`GitHub admission read failed: HTTP ${response.status}`);
    return response.json();
  };
  const result = await resolveAdmission({repository, number: event.number,
    headSha: parents[1], baseSha: parents[0], runId: Number(process.env.GITHUB_RUN_ID), request});
  console.log(result.reason);
  if (process.env.GITHUB_OUTPUT) fs.appendFileSync(process.env.GITHUB_OUTPUT, `admitted=${result.admitted}\n`);
  if (process.env.GITHUB_STEP_SUMMARY) fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY, `PR CI admission: ${result.reason}.\n`);
  if (process.argv.includes("--require") && !result.admitted) process.exitCode = 1;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((error) => {console.error(error.message); process.exitCode = 1;});
}
