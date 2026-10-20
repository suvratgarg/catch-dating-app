import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import {execFileSync} from "node:child_process";
import {RELEASE, verifyAuthority, verifyApproval, verifyPlan, verifyLive,
  verifyCurrentRules, rulesRequestHeaders} from "./host_store_rules_release.mjs";

test("service identity uses its default quota project; local user opt-in is fixed", () => {
  assert.deepEqual(rulesRequestHeaders("synthetic-token"), {
    Authorization: "Bearer synthetic-token",
  });
  assert.deepEqual(rulesRequestHeaders("synthetic-token", RELEASE.project), {
    Authorization: "Bearer synthetic-token", "X-Goog-User-Project": RELEASE.project,
  });
  assert.throws(() => rulesRequestHeaders("synthetic-token", "another-project"));
  assert.throws(() => rulesRequestHeaders("synthetic-token", ""));
  assert.throws(() => rulesRequestHeaders("bad\r\ntoken"));
});

const source = () => execFileSync("git", ["show", `${RELEASE.sourceSha}:firestore.rules`]);
const run = () => ({id: RELEASE.runId, run_attempt: 1, workflow_id: 320377139,
  event: "push", head_branch: "main", head_sha: RELEASE.sourceSha,
  head_repository: {full_name: "suvratgarg/catch-dating-app"},
  status: "completed", conclusion: "success"});
const artifact = () => ({id: RELEASE.artifactId, expired: false,
  name: `firebase-delivery-${RELEASE.sourceSha}-1`, digest: `sha256:${RELEASE.archiveHash}`,
  workflow_run: {id: RELEASE.runId, head_sha: RELEASE.sourceSha}});
const plan = () => ({sourceSha: RELEASE.sourceSha, baseSha: RELEASE.baseSha,
  sourceCiRunId: String(RELEASE.runId), sourceCiRunAttempt: "1",
  stages: ["functions", "firestore-rules"], targets: ["functions:unrelated", "firestore:rules"]});
test("fixed authority rejects foreign, failed, rerun, expired or substituted artifacts", () => {
  verifyAuthority(run(), artifact());
  for (const patch of [{id: 1}, {run_attempt: 2}, {workflow_id: 1}, {event: "pull_request"},
    {head_branch: "feature"}, {head_sha: "a".repeat(40)}, {conclusion: "failure"},
    {head_repository: {full_name: "other/repo"}}]) {
    assert.throws(() => verifyAuthority({...run(), ...patch}, artifact()));
  }
  for (const patch of [{expired: true}, {id: 1}, {digest: "sha256:" + "0".repeat(64)},
    {workflow_run: {id: 1, head_sha: RELEASE.sourceSha}}]) {
    assert.throws(() => verifyAuthority(run(), {...artifact(), ...patch}));
  }
});
test("only a recorded configured human approval admits protected production", () => {
  const env = {id: 10, name: "prod", protection_rules: [{type: "required_reviewers",
    reviewers: [{type: "User", reviewer: {id: 20}}]}]};
  const approved = {environments: [{id: 10, name: "prod"}], user: {id: 20}, state: "approved"};
  verifyApproval(env, [approved]);
  for (const history of [[], [{...approved, state: "rejected"}],
    [{...approved, user: {id: 99}}], [{...approved, environments: [{id: 11, name: "prod"}]}]]) {
    assert.throws(() => verifyApproval(env, history));
  }
  assert.throws(() => verifyApproval({...env, protection_rules: []}, [approved]));
});
test("package narrowing preserves exact rules bytes and cannot authorize any other target", () => {
  assert.deepEqual(verifyPlan(plan(), source()), {firestore: {rules: "firestore.rules"}});
  assert.throws(() => verifyPlan(plan(), Buffer.concat([source(), Buffer.from("// changed")])));
  for (const patch of [{sourceSha: "0".repeat(40)}, {baseSha: "0".repeat(40)},
    {sourceCiRunId: "1"}, {sourceCiRunAttempt: "2"}, {stages: ["functions"]},
    {targets: ["functions:unrelated", "firestore"]}]) {
    assert.throws(() => verifyPlan({...plan(), ...patch}, source()));
  }
});
test("current Host policy must still match the historical reviewed block", () => {
  const current = fs.readFileSync("firestore.rules", "utf8");
  verifyCurrentRules(source().toString(), current);
  assert.throws(() => verifyCurrentRules(source().toString(),
    current.replace("allow get: if isHostSummaryManager(organizerId);", "allow get: if true;")));
  assert.throws(() => verifyCurrentRules(source().toString(), ""));
});
test("live drift and changes to unselected releases fail closed", () => {
  const before = {project: RELEASE.project, rulesHash: RELEASE.beforeHash,
    otherReleases: [{name: "storage", rulesetName: "retained"}]};
  const after = {...before, rulesHash: RELEASE.rulesHash};
  verifyLive(before, "before");
  verifyLive(after, "after", before);
  assert.throws(() => verifyLive(after, "before"));
  assert.throws(() => verifyLive(before, "after", before));
  assert.throws(() => verifyLive({...before, project: "different"}, "before"));
  assert.throws(() => verifyLive({...after, otherReleases: []}, "after", before));
});
test("workflow holds the shared locks, preserves human protection and has one exact deploy", () => {
  const workflow = fs.readFileSync(".github/workflows/host-store-rules-release.yml", "utf8");
  assert.match(workflow, /group: backend-delivery/);
  assert.match(workflow, /group: firebase-prod/);
  assert.match(workflow, /environment: prod/);
  assert.match(workflow, /host_store_rules_release\.mjs approval/);
  assert.match(workflow, /host_store_rules_release\.mjs verify-before/);
  assert.match(workflow, /host_store_rules_release\.mjs after/);
  const deploys = workflow.split("\n").filter(line => /deploy_firebase_targets\.sh/.test(line));
  assert.deepEqual(deploys.map(line => line.trim()), [
    "./tool/deploy_firebase_targets.sh prod firestore:rules --config build/host-rules-only/firebase.json",
  ]);
  assert.doesNotMatch(workflow, /--force|CATCH_DEPLOY_ALLOW_BEHIND|cursor.*publish|firebase deploy/);
});
