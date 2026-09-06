import {execFileSync} from "node:child_process";
import fs from "node:fs";
import {pathToFileURL} from "node:url";

const SHA = /^[0-9a-f]{40}$/;
const ENVIRONMENT = "backend-review";

/** Upgrade a locally verified Functions plan only with live, exact-source review.
 * The immutable package/cursor verification remains the caller's responsibility.
 * Missing historical review evidence falls back to protected production.
 */
export async function reviewedBackendPromotion({plan, repository, sourceTreeSha, request}) {
  const original = plan.productionPromotion ?? {environment: "prod", reason: "Non-Functions stages"};
  const fallback = (reason) => ({...plan, productionPromotion: {environment: "prod", reason}});
  if (JSON.stringify(plan.stages) !== '["functions"]') return fallback("Non-Functions stages require production review");
  if (original.environment === "prod-backend" && plan.functionSelection?.mode === "no-op") return plan;
  if (original.preMergeReviewEligible !== true) return fallback(original.reason);
  if (!/^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/.test(repository) ||
      !SHA.test(plan.sourceSha) || !SHA.test(sourceTreeSha)) {
    return fallback("Invalid exact-source review inputs");
  }
  try {
    const prefix = `repos/${repository}`;
    const [repo, environment, branchRules, associated] = await Promise.all([
      request(prefix), request(`${prefix}/environments/${ENVIRONMENT}`),
      request(`${prefix}/environments/${ENVIRONMENT}/deployment-branch-policies`),
      request(`${prefix}/commits/${plan.sourceSha}/pulls?per_page=100`),
    ]);
    const rule = environment.protection_rules?.find((entry) => entry.type === "required_reviewers");
    // User reviewers are explicit; team membership expansion is intentionally
    // unsupported and therefore retains protected production.
    const reviewers = new Set((rule?.reviewers ?? []).filter((entry) => entry.type === "User")
      .map((entry) => entry.reviewer.id));
    if (environment.name !== ENVIRONMENT || !Number.isSafeInteger(environment.id) || !reviewers.size ||
        environment.can_admins_bypass !== false ||
        environment.deployment_branch_policy?.custom_branch_policies !== true ||
        environment.deployment_branch_policy?.protected_branches !== false ||
        branchRules.branch_policies?.length !== 1 ||
        branchRules.branch_policies[0].name !== "refs/pull/*/merge" ||
        branchRules.branch_policies[0].type !== "branch" || repo.full_name !== repository) {
      return fallback("Backend source review environment is not reviewer-protected");
    }
    for (const candidate of associated) {
      if (!Number.isSafeInteger(candidate.number) || candidate.merge_commit_sha !== plan.sourceSha) continue;
      const pr = await request(`${prefix}/pulls/${candidate.number}`);
      if (!pr.merged || pr.state !== "closed" || pr.merge_commit_sha !== plan.sourceSha ||
          pr.base?.ref !== "main" || pr.base.repo?.id !== repo.id || pr.head?.repo?.id !== repo.id ||
          !SHA.test(pr.head.sha) || !Number.isFinite(Date.parse(pr.merged_at))) continue;
      const commit = await request(`${prefix}/git/commits/${pr.head.sha}`);
      // Squash/merge/rebase SHA differences are allowed only when all tracked
      // bytes (including workflows/configuration) are exactly the reviewed tree.
      if (commit.sha !== pr.head.sha || commit.tree?.sha !== sourceTreeSha) continue;
      const runs = await request(`${prefix}/actions/workflows/ci.yml/runs?event=pull_request&head_sha=${pr.head.sha}&status=success&per_page=100`);
      for (const run of runs.workflow_runs ?? []) {
        if (!Number.isSafeInteger(run.id) || run.repository?.id !== repo.id || run.head_repository?.id !== repo.id ||
            run.head_sha !== pr.head.sha || run.event !== "pull_request" || run.status !== "completed" ||
            run.conclusion !== "success" || run.path !== ".github/workflows/ci.yml" ||
            !Number.isFinite(Date.parse(run.updated_at)) || Date.parse(run.updated_at) > Date.parse(pr.merged_at)) continue;
        const [history, jobs] = await Promise.all([
          request(`${prefix}/actions/runs/${run.id}/approvals`),
          request(`${prefix}/actions/runs/${run.id}/jobs?filter=latest&per_page=100`),
        ]);
        if (!(jobs.jobs ?? []).some((job) => job.name === "Backend source review" &&
            job.status === "completed" && job.conclusion === "success")) continue;
        const approvals = history.filter((entry) => entry.environments?.some((env) =>
          env.id === environment.id && env.name === ENVIRONMENT));
        // The API history has no attempt/timestamp binding. Any rejection makes
        // this run ambiguous; a fresh PR CI run is required instead of guessing
        // ordering. Reruns of an identical head cannot broaden reviewed bytes.
        if (approvals.some((entry) => entry.state !== "approved")) continue;
        const approval = approvals.find((entry) => reviewers.has(entry.user?.id));
        if (!approval) continue;
        return {...plan, productionPromotion: {
          environment: "prod-backend", reason: "Exact merged source was explicitly reviewed before merge",
          review: {pullRequest: pr.number, runId: run.id, headSha: pr.head.sha,
            treeSha: sourceTreeSha, environmentId: environment.id, reviewerId: approval.user.id},
        }};
      }
    }
    return fallback("No successful pre-merge review matches the exact packaged source tree");
  } catch (error) {
    return fallback(`Source review evidence unavailable: ${error.message}`);
  }
}

async function main() {
  const args = process.argv.slice(2);
  if (args.length !== 4 || args[0] !== "--source-root" || args[2] !== "--repository") {
    throw new Error("Usage: backend_source_review.mjs --source-root PATH --repository OWNER/REPO < verified-plan.json");
  }
  const plan = JSON.parse(fs.readFileSync(0, "utf8"));
  if (!SHA.test(plan.sourceSha)) throw new Error("Invalid source SHA");
  const sourceTreeSha = execFileSync("git", ["-C", args[1], "rev-parse", `${plan.sourceSha}^{tree}`], {encoding: "utf8"}).trim();
  const request = async (endpoint) => {
    const response = await fetch(`https://api.github.com/${endpoint}`, {
      headers: {Accept: "application/vnd.github+json", Authorization: `Bearer ${process.env.GH_TOKEN ?? ""}`,
        // Exact merge identity requires this supported response contract.
        // The 2026-03-10 API removes merge_commit_sha from all PR responses.
        "X-GitHub-Api-Version": "2022-11-28"}, signal: AbortSignal.timeout(15000),
    });
    if (!response.ok) throw new Error(`GitHub review lookup returned HTTP ${response.status}`);
    return response.json();
  };
  console.log(JSON.stringify(await reviewedBackendPromotion({plan, repository: args[3], sourceTreeSha, request})));
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((error) => { console.error(error.message); process.exitCode = 1; });
}
