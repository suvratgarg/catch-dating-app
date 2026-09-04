import assert from "node:assert/strict";
import test from "node:test";
import {reviewedBackendPromotion} from "./backend_source_review.mjs";

const source = "a".repeat(40), head = "b".repeat(40), tree = "c".repeat(40);
function fixture() {
  const prefix = "repos/owner/repo";
  const values = {
    [prefix]: {id: 42, full_name: "owner/repo"},
    [`${prefix}/environments/backend-review`]: {id: 7, name: "backend-review", can_admins_bypass: false,
      deployment_branch_policy: {custom_branch_policies: true, protected_branches: false},
      protection_rules: [{type: "required_reviewers", reviewers: [{type: "User", reviewer: {id: 9}}]}]},
    [`${prefix}/environments/backend-review/deployment-branch-policies`]: {branch_policies: [{name: "refs/pull/*/merge", type: "branch"}]},
    [`${prefix}/commits/${source}/pulls?per_page=100`]: [{number: 3, merge_commit_sha: source}],
    [`${prefix}/pulls/3`]: {number: 3, merged: true, state: "closed", merge_commit_sha: source,
      merged_at: "2026-09-05T10:00:00Z", base: {ref: "main", repo: {id: 42}}, head: {sha: head, repo: {id: 42}}},
    [`${prefix}/git/commits/${head}`]: {sha: head, tree: {sha: tree}},
    [`${prefix}/actions/workflows/ci.yml/runs?event=pull_request&head_sha=${head}&status=success&per_page=100`]: {
      workflow_runs: [{id: 11, repository: {id: 42}, head_repository: {id: 42}, head_sha: head,
        event: "pull_request", status: "completed", conclusion: "success", path: ".github/workflows/ci.yml",
        updated_at: "2026-09-05T09:59:00Z"}]},
    [`${prefix}/actions/runs/11/approvals`]: [{state: "approved", environments: [{id: 7, name: "backend-review"}], user: {id: 9}}],
    [`${prefix}/actions/runs/11/jobs?filter=latest&per_page=100`]: {jobs: [{name: "Backend source review", status: "completed", conclusion: "success"}]},
  };
  const calls = [];
  const plan = {sourceSha: source, stages: ["functions"], targets: ["functions:example"],
    functionSelection: {mode: "affected"}, productionPromotion: {environment: "prod", preMergeReviewEligible: true}};
  return {values, plan, calls, prefix, async check() {
    return reviewedBackendPromotion({plan, repository: "owner/repo", sourceTreeSha: tree, request: async (endpoint) => {
      calls.push(endpoint);
      assert.ok(Object.hasOwn(values, endpoint), `Unexpected request: ${endpoint}`);
      return values[endpoint];
    }});
  }};
}

test("a real source review admits the identical merged tree without changing immutable targets", async () => {
  const f = fixture();
  const result = await f.check();
  assert.equal(result.productionPromotion.environment, "prod-backend");
  assert.deepEqual(result.productionPromotion.review, {pullRequest: 3, runId: 11, headSha: head,
    treeSha: tree, environmentId: 7, reviewerId: 9});
  assert.deepEqual(result.targets, f.plan.targets);
  assert.equal(f.plan.productionPromotion.environment, "prod");
});

const mutations = {
  "unrestricted branches": (v, p) => { v[`${p}/environments/backend-review`].deployment_branch_policy = null; },
  "broad branch rule": (v, p) => { v[`${p}/environments/backend-review/deployment-branch-policies`].branch_policies[0].name = "*"; },
  "different reviewed bytes": (v, p) => { v[`${p}/git/commits/${head}`].tree.sha = "d".repeat(40); },
  "unmerged PR": (v, p) => { v[`${p}/pulls/3`].merged = false; },
  "different merge commit": (v, p) => { v[`${p}/pulls/3`].merge_commit_sha = head; },
  "fork source": (v, p) => { v[`${p}/pulls/3`].head.repo.id = 43; },
  "different destination": (v, p) => { v[`${p}/pulls/3`].base.ref = "dev"; },
  "missing review requirement": (v, p) => { v[`${p}/environments/backend-review`].protection_rules = []; },
  "administrator bypass enabled": (v, p) => { v[`${p}/environments/backend-review`].can_admins_bypass = true; },
  "missing approval": (v, p) => { v[`${p}/actions/runs/11/approvals`] = []; },
  "unlisted reviewer": (v, p) => { v[`${p}/actions/runs/11/approvals`][0].user.id = 10; },
  "wrong environment identity": (v, p) => { v[`${p}/actions/runs/11/approvals`][0].environments[0].id = 8; },
  "ambiguous rejected review": (v, p) => { v[`${p}/actions/runs/11/approvals`].push({state: "rejected", environments: [{id: 7, name: "backend-review"}], user: {id: 9}}); },
  "review job skipped": (v, p) => { v[`${p}/actions/runs/11/jobs?filter=latest&per_page=100`].jobs[0].conclusion = "skipped"; },
};
for (const [label, mutate] of Object.entries(mutations)) test(`${label} retains protected production`, async () => {
  const f = fixture(); mutate(f.values, f.prefix);
  assert.equal((await f.check()).productionPromotion.environment, "prod");
});

for (const [key, value] of [["head_sha", source], ["event", "push"], ["conclusion", "failure"],
  ["path", ".github/workflows/fake.yml"], ["updated_at", "2026-09-05T10:01:00Z"], ["repository", {id: 43}], ["head_repository", {id: 43}]]) {
  test(`review CI ${key} mismatch retains protected production`, async () => {
    const f = fixture();
    const runs = Object.values(f.values).find((value) => value.workflow_runs)?.workflow_runs;
    runs[0][key] = value;
    assert.equal((await f.check()).productionPromotion.environment, "prod");
  });
}

test("an unavailable GitHub API preserves the manual route", async () => {
  const f = fixture();
  const result = await reviewedBackendPromotion({plan: f.plan, repository: "owner/repo", sourceTreeSha: tree,
    request: async () => { throw new Error("HTTP 503"); }});
  assert.equal(result.productionPromotion.environment, "prod");
});

test("no-ops need no API review but cannot bypass mixed-stage or snapshot policy", async () => {
  const f = fixture(); f.plan.functionSelection.mode = "no-op";
  f.plan.productionPromotion = {environment: "prod-backend"};
  assert.equal((await f.check()).productionPromotion.environment, "prod-backend");
  assert.equal(f.calls.length, 0);
  f.plan.stages.push("storage-rules");
  assert.equal((await f.check()).productionPromotion.environment, "prod");
  f.plan.stages = ["functions"]; f.plan.productionPromotion = {environment: "prod", reason: "snapshot"};
  assert.equal((await f.check()).productionPromotion.environment, "prod");
  assert.equal(f.calls.length, 0);
});
