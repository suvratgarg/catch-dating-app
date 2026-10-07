import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import os from "node:os";
import {spawnSync} from "node:child_process";
import test from "node:test";
import {fileURLToPath} from "node:url";
import {extractSteps} from "../harness/lib/workflow_steps.mjs";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const workflow = (name) => fs.readFileSync(
  path.join(repoRoot, ".github/workflows", name),
  "utf8",
);

function ciJob(source, name) {
  const start = source.indexOf(`\n  ${name}:\n`);
  assert.ok(start >= 0, `Missing CI job ${name}`);
  const remaining = source.slice(start + 1);
  const end = remaining.search(/\n  [a-z][a-z-]*:\n/);
  return end < 0 ? remaining : remaining.slice(0, end);
}

test("staging refresh is monthly or manual, validates its exact snapshot, and cannot advance production", () => {
  const staging = workflow("backend-staging.yml");
  assert.match(staging, /schedule:\s+- cron: '17 2 1 \* \*'/);
  assert.match(staging, /workflow_dispatch:/);
  assert.doesNotMatch(staging, /workflow_run:|\n  push:|\n  pull_request:/);
  assert.match(staging, /if: github\.ref == 'refs\/heads\/main'/);
  assert.match(staging, /group: backend-staging\n  cancel-in-progress: false/);
  assert.match(staging, /test "\$CONTROL_PLANE_SHA" = "\$SOURCE_SHA"/);
  assert.match(staging, /test "\$GITHUB_RUN_ATTEMPT" = "1"/);
  assert.match(staging, /baseSha: \$sourceSha/);
  assert.match(staging, /snapshot: \{[\s\S]*cumulativeSnapshot: true/);
  for (const lane of ["functions", "contracts", "firestore-rules"]) {
    assert.ok(staging.includes(`uses: ./.github/workflows/${lane}-ci.yml`));
    assert.ok(staging.includes(`needs.${lane}.result == 'success'`));
  }
  assert.match(staging, /name: functions-lib-\$\{\{ needs\.authorize\.outputs\.source_sha \}\}-\$\{\{ github\.run_attempt \}\}/);
  assert.match(staging, /--functions-lib-dir build\/staging\/tested-functions-lib/);
  assert.match(staging, /name: firebase-delivery-\$\{\{ needs\.authorize\.outputs\.source_sha \}\}-\$\{\{ github\.run_attempt \}\}/);
  assert.match(staging, /environment: staging/);
  assert.doesNotMatch(staging, /environment: (?:dev|prod)|backend-delivery-cursor|backend-delivery-drain|contents: write/);
  assert.equal((staging.match(/uses: \.\/\.github\/workflows\/_firebase-promote.yml/g) ?? []).length, 1);
});

test("main CI starts validation immediately and serializes only proven publication", () => {
  const ci = workflow("ci.yml");
  const plan = ciJob(ci, "plan");
  const finalizer = ciJob(ci, "finalize-plan");
  assert.match(ci, /group: ci-\$\{\{ github\.event_name \}\}-\$\{\{[\s\S]*github\.event_name == 'push'[\s\S]*github\.run_id/);
  assert.match(ci, /queue: max\n  cancel-in-progress: false/);
  assert.match(ci, /github\.event_name == 'pull_request' && 'admitted'/);
  assert.match(plan, /main_ci_baseline\.mjs/);
  assert.doesNotMatch(plan, /--wait|while true|sleep 20/);
  assert.match(plan, /window_flag=\(--commit-window\)/);
  assert.match(plan, /"\$\{full_flag\[@\]\}" "\$\{window_flag\[@\]\}"/);
  assert.match(finalizer, /timeout-minutes: 180/);
  assert.match(finalizer, /--fallback-base "\$BEFORE_SHA" --wait/);
  assert.ok(finalizer.indexOf('finalize_ci_plan.mjs validate') < finalizer.indexOf('main_ci_baseline.mjs'));
  assert.ok(finalizer.indexOf('main_ci_baseline.mjs') < finalizer.indexOf('finalize_ci_plan.mjs finalize'));
  assert.match(finalizer, /name: harness-validation-plan-/);
  assert.match(finalizer, /name: harness-plan-/);
  assert.match(finalizer, /check_doc_metadata\.mjs --base "\$base_sha"/);
  assert.match(finalizer, /check_new_widget_inventory\.mjs --base "\$base_sha" --check --no-write/);
  assert.match(finalizer, /fetch-depth: 0/);
  assert.doesNotMatch(finalizer, /continue-on-error|npm --prefix functions|run build/);
  const packaging = ciJob(ci, "package-firebase");
  assert.match(packaging, /needs\.finalize-plan\.result == 'success'/);
  assert.match(packaging, /BASE_SHA: \$\{\{ needs\.finalize-plan\.outputs\.base_sha \}\}/);
  assert.match(packaging, /DEPLOY_GROUPS: \$\{\{ needs\.finalize-plan\.outputs\.deploy_groups \}\}/);
  assert.doesNotMatch(packaging, /needs\.plan\.outputs\.(?:deploy_groups|base_sha|deploy_required)/);
  const required = ciJob(ci, "required");
  assert.match(required, /'\.\["finalize-plan"\]\.result'/);
  assert.match(required, /needs\.finalize-plan\.outputs\.deploy_required/);
  assert.match(required, /^      - finalize-plan$/m);
});

test("a successful main CI attempt must own its exact planner and backend artifacts", () => {
  const ci = workflow("ci.yml");
  for (const name of ["backend-rebaseline.yml", "backend-staging.yml"]) {
    assert.match(workflow(name), /pull-requests: read/);
  }
  const required = ciJob(ci, "required");
  assert.match(required, /actions\/runs\/\$GITHUB_RUN_ID\/artifacts\?per_page=100/);
  assert.match(required, /harness-plan-\$\{GITHUB_RUN_NUMBER\}-\$\{GITHUB_RUN_ID\}-\$\{SOURCE_SHA\}-\$\{GITHUB_RUN_ATTEMPT\}/);
  assert.match(required, /firebase-delivery-\$\{SOURCE_SHA\}-\$\{GITHUB_RUN_ATTEMPT\}/);
  assert.match(required, /GitHub reused successful jobs from an older attempt; use Re-run all jobs/);
  assert.match(required, /plan_count" != "1"/);
  assert.match(required, /package_count" != "1"/);
  assert.match(required, /plan_artifact_id=.*\.id/);
  assert.match(required, /plan_artifact_digest=.*\.digest/);
  assert.match(required, /package_artifact_id=.*\.id/);
  assert.match(required, /package_artifact_digest=.*\.digest/);
  assert.match(required, /actions\/runs\/\$GITHUB_RUN_ID\/attempts\/\$GITHUB_RUN_ATTEMPT/);
  assert.match(required, /catch\.ci-delivery-authority\/v3/);
  assert.match(required, /sourceCiWorkflowId: \$sourceCiWorkflowId/);
  assert.match(required, /planArtifact: \{[\s\S]*id: \$planArtifactId[\s\S]*digest: \$planArtifactDigest/);
  assert.match(required, /name: harness-success-v3-/);
});

test("CI packages one immutable backend from its exact plan and tested Functions", () => {
  const ci = workflow("ci.yml");
  const functions = workflow("functions-ci.yml");
  assert.match(ci, /deploy_groups: \$\{\{ steps\.plan\.outputs\.deploy_groups \}\}/);
  assert.match(ci, /source_sha: \$\{\{ steps\.plan\.outputs\.source_sha \}\}/);
  assert.match(ci, /name: Download the exact CI impact plan/);
  assert.match(functions, /npm --prefix functions test[\s\S]*name: Upload the exact tested Functions build/);
  assert.match(functions, /name: functions-lib-\$\{\{ github\.sha \}\}-\$\{\{ github\.run_attempt \}\}/);
  assert.match(functions, /path: functions\/lib/);
  assert.match(ci, /name: Download the exact tested Functions build/);
  assert.match(ci, /name: functions-lib-\$\{\{ needs\.plan\.outputs\.source_sha \}\}-\$\{\{ github\.run_attempt \}\}/);
  assert.match(ci, /--functions-lib-dir build\/ci\/tested-functions-lib/);
  assert.match(ci, /package_args=\([\s\S]*prepare[\s\S]*package_firebase_delivery\.mjs "\$\{package_args\[@\]\}"/);
  assert.match(ci, /delivery_core\.mjs manifest/);
  assert.match(ci, /--ci-run-attempt "\$CI_RUN_ATTEMPT"/);
  assert.match(ci, /name: firebase-delivery-\$\{\{ needs\.plan\.outputs\.source_sha \}\}-\$\{\{ github\.run_attempt \}\}/);
  assert.match(ci, /name: harness-plan-[\s\S]*retention-days: 90/);
  assert.match(ci, /name: firebase-delivery-[\s\S]*retention-days: 90/);
  assert.doesNotMatch(ci, /npm --prefix functions (?:ci|test|run build)/);
});

test("each deploy group requires its mandatory validation lane to succeed", () => {
  const ci = workflow("ci.yml");
  for (const mapping of [
    /"functions" then \[\. , "functions"\]/,
    /"firestore-indexes" then \[\. , "contracts"\]/,
    /"firestore-rules" or \. == "storage-rules" then \[\. , "firestore-rules"\]/,
    /if \[\[ "\$result" != "success" \]\]/,
  ]) assert.match(ci, mapping);
  assert.match(ci, /Backend delivery was authorized but package-firebase=\$package_result/);
});

test("Delivery treats every completed CI trigger as a queue wakeup and trusts only exact artifacts", () => {
  const delivery = workflow("delivery.yml");
  for (const trustPredicate of [
    '.name == "CI"',
    '(.path | split("@")[0]) == ".github/workflows/ci.yml"',
    ".workflow_id == $workflow_id",
    '.event == "push"',
    '.head_branch == "main"',
    '.head_sha == $source_sha',
    '.head_repository.full_name == $repository',
    '.conclusion == "success"',
    ".run_attempt",
  ]) assert.match(delivery, new RegExp(escapeRegex(trustPredicate)));
  const authorizeIf = delivery.slice(
    delivery.indexOf("    if: >-"),
    delivery.indexOf("    runs-on: ubuntu-latest"),
  );
  assert.match(authorizeIf, /github\.event_name == 'workflow_run'/);
  assert.doesNotMatch(authorizeIf, /workflow_run\.conclusion|workflow_run\.event/);
  assert.match(delivery, /github\.ref == 'refs\/heads\/main'/);
  assert.match(delivery, /id-token: write/);
  assert.match(delivery, /actions\/artifacts\/\$PLAN_ARTIFACT_ID\/zip/);
  assert.match(delivery, /actions\/artifacts\/\$PACKAGE_ARTIFACT_ID\/zip/);
  assert.match(delivery, /sha256:\$\(sha256sum build\/delivery\/plan\.zip/);
  assert.match(delivery, /sha256:\$\(sha256sum build\/delivery\/source\.zip/);
  assert.match(delivery, /delivery_core\.mjs verify[\s\S]*package_firebase_delivery\.mjs verify/);
  assert.match(delivery, /source_ci_run_attempt/);
  assert.match(delivery, /--ci-run-attempt "\$SOURCE_CI_RUN_ATTEMPT"/);
  assert.match(delivery, /git -C "\$SOURCE_CHECKOUT" merge-base --is-ancestor "\$SOURCE_SHA" refs\/remotes\/origin\/main/);
  assert.doesNotMatch(delivery, /HEAD\^|github\.sha|remoteconfig|extensions:/);
  assert.equal(fs.existsSync(path.join(repoRoot, ".github/workflows/firebase-dev-deploy.yml")), false);
  assert.equal(fs.existsSync(path.join(repoRoot, ".github/workflows/firebase-deploy.yml")), false);
});

test("Delivery keeps the current immutable control plane separate from an older source payload", () => {
  const delivery = workflow("delivery.yml");
  const promotion = workflow("_firebase-promote.yml");

  assert.match(delivery, /name: Checkout the immutable Delivery control plane[\s\S]*ref: \$\{\{ github\.workflow_sha \}\}/);
  assert.match(delivery, /name: Checkout the exact CI-approved source as verification input[\s\S]*path: build\/delivery\/source-checkout/);
  assert.match(delivery, /test "\$\(git rev-parse HEAD\)" = "\$CONTROL_PLANE_SHA"/);
  assert.match(delivery, /git -C "\$SOURCE_CHECKOUT" merge-base --is-ancestor "\$SOURCE_SHA" refs\/remotes\/origin\/main/);
  assert.match(delivery, /package_firebase_delivery\.mjs verify[\s\S]*--source-root build\/delivery\/source-checkout/);
  assert.equal((delivery.match(/control_plane_sha: \$\{\{ github\.workflow_sha \}\}/g) ?? []).length, 2);

  assert.match(promotion, /control_plane_sha:[\s\S]*required: true/);
  assert.match(promotion, /timeout-minutes: 240/);
  assert.match(promotion, /name: Checkout the immutable Delivery control plane[\s\S]*ref: \$\{\{ inputs\.control_plane_sha \}\}/);
  assert.match(promotion, /name: Checkout the exact CI-approved source as verification input[\s\S]*path: build\/delivery\/source-checkout/);
  assert.match(promotion, /test "\$control_project_id" = "\$project_id"/);
  assert.equal((promotion.match(/--source-root build\/delivery\/source-checkout/g) ?? []).length, 6);
  assert.match(promotion, /CATCH_FIREBASE_SOURCE_ROOT="\$SOURCE_CHECKOUT"/);
  assert.match(promotion, /\.\/tool\/deploy_firebase_targets\.sh/);
  assert.doesNotMatch(promotion, /build\/delivery\/source-checkout\/tool\/deploy_firebase_targets\.sh/);
  const exactFunctionGuard = promotion.indexOf(
    '[[ ! "$function_target" =~ ^functions:[A-Za-z][A-Za-z0-9_-]*$ ]]',
  );
  const forceAcknowledgement = promotion.indexOf('deploy_args+=(--force)');
  assert.ok(
    exactFunctionGuard >= 0 &&
      exactFunctionGuard < forceAcknowledgement,
    "retry-policy acknowledgement must follow the exact Function selector guard",
  );
  assert.match(
    promotion,
    /"\$DEPLOY_ENVIRONMENT" "\$target" \\\n+\s+"\$\{deploy_args\[@\]\}"/u,
  );
  const executor = fs.readFileSync(
    path.join(repoRoot, "tool/deploy_firebase_targets.sh"),
    "utf8",
  );
  assert.match(
    executor,
    /CATCH_DELIVERY_FUNCTIONS_DIR[\s\S]*CATCH_FIREBASE_SOURCE_ROOT[\s\S]*planner_policy_args\+=\(--filter-dormant-exact-targets\)/u,
  );
  assert.equal(
    (executor.match(/"\$\{planner_policy_args\[@\]\}"/gu) ?? []).length,
    2,
  );
  assert.match(executor, /--function-batches/);
  assert.match(executor, /sleep 10/);
  assert.match(executor, /sleep 60/);
});

test("Functions deployment checks live parity against the exact source checkout", () => {
  const executor = fs.readFileSync(
    path.join(repoRoot, "tool/deploy_firebase_targets.sh"),
    "utf8",
  );
  const batchesComplete = executor.indexOf('done <<< "$function_batches"');
  const invokersComplete = executor.indexOf(
    "sync_callable_invokers",
    batchesComplete,
  );
  const parityCheck = executor.indexOf(
    "check_deploy_parity.mjs",
    invokersComplete,
  );

  assert.ok(
    batchesComplete >= 0 &&
      batchesComplete < invokersComplete &&
      invokersComplete < parityCheck,
  );
  assert.match(
    executor,
    /check_deploy_parity\.mjs" \\\n+\s+--env "\$environment" \\\n+\s+--repo-root "\$\{CATCH_FIREBASE_SOURCE_ROOT:-\$repo_root\}" \\\n+\s+--targets "\$deploy_only"/u,
  );
});

test("whole-plan Functions preflight is bound to verified inputs before the first ordered stage", (t) => {
  const promotion = workflow("_firebase-promote.yml");
  const preflight = extractSteps(promotion).find((step) =>
    step.name === "Preflight the whole backend plan before any deployment");
  assert.ok(preflight?.run, "Missing executable preflight boundary.");
  const offset = promotion.indexOf("Preflight the whole backend plan before any deployment");
  assert.ok(promotion.indexOf("Materialize non-secret Functions params") < offset);
  assert.ok(offset < promotion.indexOf("Resume ordered backend stages"));
  const wiring = promotion.slice(offset, promotion.indexOf("      - id: promote", offset));
  assert.match(wiring, /if: \$\{\{ steps\.verify\.outputs\.has_functions == 'true' \}\}/);
  assert.match(wiring, /CATCH_DEPLOY_ALLOW_BEHIND: \$\{\{ inputs\.require_current_main && '0' \|\| '1' \}\}/);
  assert.match(wiring, /CATCH_DELIVERY_FUNCTIONS_DIR: build\/delivery\/deploy-tree\/functions/);
  assert.match(wiring, /CATCH_FIREBASE_SOURCE_ROOT: build\/delivery\/source-checkout/);
  assert.match(wiring, /DEPLOY_TARGETS: \$\{\{ steps\.verify\.outputs\.targets \}\}/);
  assert.doesNotMatch(wiring, /continue-on-error|\|\| true/);
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-workflow-preflight-"));
  t.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  fs.mkdirSync(path.join(directory, "tool"));
  fs.writeFileSync(path.join(directory, "tool/deploy_firebase_targets.sh"),
    '#!/bin/sh\nprintf "%s\\n" "$@" > "$PREFLIGHT_ARGS"\nexit "$PREFLIGHT_STATUS"\n', {mode: 0o755});
  for (const status of [0, 64]) {
    const result = spawnSync("bash", ["-euo", "pipefail", "-c", preflight.run], {
      cwd: directory, encoding: "utf8", env: {...process.env,
        DEPLOY_ENVIRONMENT: "prod", DEPLOY_TARGETS: "firestore:indexes,functions:alpha",
        PREFLIGHT_ARGS: path.join(directory, "args"), PREFLIGHT_STATUS: String(status)},
    });
    assert.equal(result.status, status, result.stderr);
    assert.deepEqual(fs.readFileSync(path.join(directory, "args"), "utf8").trim().split("\n"),
      ["--preflight", "prod", "firestore:indexes,functions:alpha"]);
  }
});

test("actual Functions recovery branch records only completed deployments and never deploys for verified postconditions", (t) => {
  const promotion = workflow("_firebase-promote.yml");
  const start = promotion.indexOf("              proof_args=(");
  const end = promotion.indexOf('            else\n              CATCH_DELIVERY_FUNCTIONS_DIR=', start);
  assert.ok(start > 0 && end > start);
  const body = promotion.slice(start, end);
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-functions-recovery-branch-"));
  t.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  fs.mkdirSync(path.join(directory, "bin"));
  fs.mkdirSync(path.join(directory, "tool"));
  fs.writeFileSync(path.join(directory, "bin/node"), '#!/bin/sh\n' +
    'if [ "$1" = tool/firebase/check_environment_readiness.mjs ]; then echo binding-check >> "$RECOVERY_EVENTS"; exit "$READINESS_STATUS"; fi\n' +
    'printf \'%s\\n\' "$2" >> "$RECOVERY_EVENTS"\n' +
    'if [ "$2" = verify ]; then printf \'%s\\n\' "$VERIFY_RESULT"; exit "$VERIFY_STATUS"; fi\n' +
    'exit "$RECORD_STATUS"\n', {mode: 0o755});
  fs.writeFileSync(path.join(directory, "tool/deploy_firebase_targets.sh"), '#!/bin/sh\n' +
    'printf \'%s\\n\' "$1" >> "$RECOVERY_EVENTS"\n' +
    'if [ "$1" = --functions-deploy-only ]; then exit "$DEPLOY_STATUS"; fi\n' +
    'exit "$POSTCONDITIONS_STATUS"\n', {mode: 0o755});
  const scenarios = [
    {label: "no prior proof", expected: ["verify", "--functions-deploy-only", "record", "--functions-postconditions-only", "binding-check"]},
    {label: "verified prior deployment", proof: true, expected: ["verify", "--functions-postconditions-only", "binding-check"]},
    {label: "binding drift", readiness: 5, expected: ["verify", "--functions-deploy-only", "record", "--functions-postconditions-only", "binding-check"]},
    {label: "partial batch failed", deploy: 9, expected: ["verify", "--functions-deploy-only"]},
    {label: "recording deployment failed", record: 8, expected: ["verify", "--functions-deploy-only", "record"]},
    {label: "postcondition failed", postconditions: 7, expected: ["verify", "--functions-deploy-only", "record", "--functions-postconditions-only"]},
    {label: "live identity changed", verify: 6, expected: ["verify"]},
    {label: "malformed recovery result", result: "{}", invalid: true, expected: ["verify"]},
  ];
  for (const scenario of scenarios) {
    const events = path.join(directory, "events");
    fs.rmSync(events, {force: true});
    const command = 'stage_status=0\ntarget=functions:alpha\ndeploy_args=(--config package/firebase.json --force)\n' +
      body + '\nexit "$stage_status"\n';
    const result = spawnSync("bash", ["-euo", "pipefail", "-c", command], {cwd: directory, encoding: "utf8", env: {
      ...process.env, PATH: `${path.join(directory, "bin")}${path.delimiter}${process.env.PATH}`,
      RECOVERY_EVENTS: events, VERIFY_RESULT: scenario.result ?? JSON.stringify({postconditionsOnly: Boolean(scenario.proof)}),
      VERIFY_STATUS: String(scenario.verify ?? 0), RECORD_STATUS: String(scenario.record ?? 0),
      READINESS_STATUS: String(scenario.readiness ?? 0),
      DEPLOY_STATUS: String(scenario.deploy ?? 0), POSTCONDITIONS_STATUS: String(scenario.postconditions ?? 0),
      SOURCE_SHA: "a".repeat(40), BASE_SHA: "b".repeat(40), SOURCE_CI_RUN_ID: "700", SOURCE_CI_RUN_ATTEMPT: "1",
      CHECKPOINT_SCOPE: "firebase:dev:demo-project", CHECKPOINT: "checkpoint.json", PROJECT_ID: "demo-project",
      DELIVERY_FUNCTIONS_DIR: "package/functions", SOURCE_CHECKOUT: "source", DEPLOY_ENVIRONMENT: "dev",
    }});
    if (scenario.invalid) assert.notEqual(result.status, 0, scenario.label);
    else assert.equal(result.status, scenario.verify ?? scenario.deploy ?? scenario.record ?? scenario.postconditions ?? scenario.readiness ?? 0,
      `${scenario.label}: ${result.stderr}`);
    assert.deepEqual(fs.readFileSync(events, "utf8").trim().split("\n"), scenario.expected, scenario.label);
  }
});

test("Delivery consumes the always-present plan before deciding package or no-op", () => {
  const delivery = workflow("delivery.yml");
  const planOffset = delivery.indexOf("Download the exact CI impact plan first");
  const packageOffset = delivery.indexOf("Download only the backend artifact");
  assert.ok(planOffset >= 0 && planOffset < packageOffset);
  assert.match(delivery, /deploy_required: \$\{\{ steps\.plan\.outputs\.deploy_required \}\}/);
  assert.match(delivery, /if: \$\{\{ steps\.plan\.outputs\.deploy_required == 'true' \}\}[\s\S]*PACKAGE_ARTIFACT_ID/);
  assert.match(delivery, /needs\.authorize\.outputs\.deploy_required == 'true'/);
  assert.match(delivery, /resume_delivery_run_id:[\s\S]*required: true/);
  assert.match(delivery, /group: .*'dev' && 'backend-delivery-dev' \|\| 'backend-delivery'/);
  assert.match(delivery, /cancel-in-progress: false/);
  assert.match(delivery, /immutable source authorities establish release order/);
});

test("Delivery selects the oldest pending authority after a cursor and current main for bootstrap", () => {
  const delivery = workflow("delivery.yml");
  assert.match(delivery, /repository_dispatch:[\s\S]*types: \[backend-delivery-drain\]/);
  assert.equal((delivery.match(/actions\/artifacts\?per_page=100/g) ?? []).length, 1);
  const cursor = delivery.slice(delivery.indexOf("      - id: cursor"), delivery.indexOf("      - id: source"));
  const source = delivery.slice(delivery.indexOf("      - id: source"), delivery.indexOf("      - name: Checkout the exact CI-approved source"));
  assert.match(cursor, /actions\/workflows\/ci\.yml/);
  assert.match(cursor, /\^backend-delivery-cursor-v4-/);
  assert.match(cursor, /actions\/artifacts\/\$cursor_artifact_id\/zip/);
  assert.match(cursor, /--run-id "\$cursor_delivery_run_id" --run-attempt "\$cursor_delivery_run_attempt"/);
  assert.match(cursor, /catch\.backend-delivery-cursor\/v4/);
  assert.match(cursor, /sourceCiWorkflowId/);
  assert.match(cursor, /cursor_ambiguity_count/);
  assert.match(cursor, /different or legacy CI workflow generation/);
  assert.match(cursor, /sha256:\$\(sha256sum "\$cursor_dir\/cursor\.zip"/);
  assert.doesNotMatch(cursor.slice(0, cursor.indexOf("node tool/ci/backend_delivery_lanes.mjs verify-run")), /\.conclusion == "success"/);
  assert.doesNotMatch(cursor, /gh run download/);
  assert.match(delivery, /actions\/runs\/\$cursor_run_id\/attempts\/\$cursor_run_attempt/);
  assert.match(delivery, /\.run_attempt == \$run_attempt[\s\S]*\.run_number == \$run_number/);
  assert.match(source, /\^harness-success-v3-/);
  assert.match(source, /actions\/artifacts\/\$authority_artifact_id\/zip/);
  assert.match(source, /catch\.ci-delivery-authority\/v3/);
  assert.match(source, /source_ambiguity_count/);
  assert.match(source, /group_by\(\.sourceCiRunNumber\)[\s\S]*sourceCiRunAttempt \| tonumber[\s\S]*min_by\(\.sourceCiRunNumber\)/);
  assert.match(source, /bootstrap-source-winner-begin[\s\S]*max_by\(\.sourceCiRunNumber\)/);
  assert.match(source, /actions\/runs\/\$source_ci_run_id\/attempts\/\$source_ci_run_attempt/);
  assert.match(source, /\.workflow_id == \$workflow_id[\s\S]*\.status == "completed"[\s\S]*\.conclusion == "success"/);
  assert.match(source, /planArtifact[\s\S]*packageArtifact[\s\S]*digest/);
  assert.doesNotMatch(cursor, /while\s/);
  assert.doesNotMatch(source.slice(0, source.indexOf('if [[ "$EVENT_NAME" == "workflow_dispatch" ]]')), /while\s/);
  assert.doesNotMatch(delivery, /actions\/workflows\/ci\.yml\/runs/);
  assert.match(delivery, /source_sha" != "\$current_main_sha"/);
  assert.match(delivery, /No-cursor bootstrap requires the exact current main head/);
  assert.match(delivery, /No-cursor bootstrap requires a current-main backend package/);
  assert.match(delivery, /Bootstrapping the delivery cursor from the exact backend package for current main/);
  assert.match(delivery, /base_sha" != "\$CURSOR_SOURCE_SHA"[\s\S]*refusing to skip that release window/);
  assert.doesNotMatch(delivery, /EVENT_RUN_ID|first cursor may bootstrap/);
  assert.match(delivery, /work_required=false/);
});

test("a final cursor is authoritative before its Delivery run reaches completed status", () => {
  const delivery = workflow("delivery.yml");
  const cursor = delivery.slice(
    delivery.indexOf("      - id: cursor"),
    delivery.indexOf("      - id: source"),
  );
  const originAttempt = cursor.slice(
    cursor.indexOf("node tool/ci/backend_delivery_lanes.mjs verify-run"),
    cursor.indexOf("cursor_source_run="),
  );

  assert.match(originAttempt, /--run-id "\$cursor_delivery_run_id" --run-attempt "\$cursor_delivery_run_attempt"/);
  assert.match(originAttempt, /--role cursor/);
  assert.doesNotMatch(originAttempt, /\.status ==|\.conclusion ==/);
});

test("high-cardinality queue metadata still resolves one cursor and one oldest authority", () => {
  const delivery = workflow("delivery.yml");
  const digest = `sha256:${"a".repeat(64)}`;
  const artifacts = [];
  for (let runNumber = 1; runNumber <= 2500; runNumber += 1) {
    const sourceSha = runNumber.toString(16).padStart(40, "0");
    const deliveryRunId = 100000 + runNumber;
    artifacts.push({
      id: 200000 + runNumber,
      name: `backend-delivery-cursor-v4-77-${runNumber}-${300000 + runNumber}-1-${sourceSha}-${deliveryRunId}-1`,
      digest,
      expired: false,
      workflow_run: {
        id: deliveryRunId,
        repository_id: 7,
        head_repository_id: 7,
        head_branch: "main",
        head_sha: sourceSha,
      },
    });
  }
  const oldestPendingSha = (2501).toString(16).padStart(40, "0");
  for (const attempt of [9, 10]) {
    artifacts.push({
      id: 500000 + attempt,
      name: `harness-success-v3-77-2501-600001-${oldestPendingSha}-${attempt}`,
      digest,
      expired: false,
      workflow_run: {
        id: 600001,
        repository_id: 7,
        head_repository_id: 7,
        head_branch: "main",
        head_sha: oldestPendingSha,
      },
    });
  }
  for (let runNumber = 2502; runNumber <= 5000; runNumber += 1) {
    const sourceSha = runNumber.toString(16).padStart(40, "0");
    artifacts.push({
      id: 700000 + runNumber,
      name: `harness-success-v3-77-${runNumber}-${800000 + runNumber}-${sourceSha}-1`,
      digest,
      expired: false,
      workflow_run: {
        id: 800000 + runNumber,
        repository_id: 7,
        head_repository_id: 7,
        head_branch: "main",
        head_sha: sourceSha,
      },
    });
    artifacts.push({
      id: 900000 + runNumber,
      name: `harness-success-v3-88-${runNumber}-${950000 + runNumber}-${sourceSha}-1`,
      digest,
      expired: false,
      workflow_run: {
        id: 950000 + runNumber,
        repository_id: 7,
        head_repository_id: 7,
        head_branch: "main",
        head_sha: sourceSha,
      },
    });
  }
  const pages = [{artifacts}];

  const cursorCandidates = runJq(
    queueSelector(delivery, "cursor-candidates"),
    pages,
    ["--argjson", "repository_id", "7", "--argjson", "workflow_id", "77"],
  );
  const cursorWinner = runJq(
    queueSelector(delivery, "cursor-winner"),
    cursorCandidates,
  );
  assert.equal(cursorWinner.sourceCiRunNumber, 2500);

  const sourceCandidates = runJq(
    queueSelector(delivery, "source-candidates"),
    pages,
    [
      "--argjson", "cursor_run", "2500",
      "--argjson", "repository_id", "7",
      "--argjson", "workflow_id", "77",
    ],
  );
  const sourceWinner = runJq(
    queueSelector(delivery, "source-winner"),
    sourceCandidates,
  );
  assert.equal(sourceWinner.sourceCiRunNumber, 2501);
  assert.equal(sourceWinner.sourceCiRunAttempt, "10");

  const bootstrapWinner = runJq(
    queueSelector(delivery, "bootstrap-source-winner"),
    sourceCandidates,
  );
  assert.equal(bootstrapWinner.sourceCiRunNumber, 5000);
  assert.equal(bootstrapWinner.sourceCiRunAttempt, "1");

  const boundedSelection = delivery.slice(
    delivery.indexOf("      - id: cursor"),
    delivery.indexOf('            [[ "$RESUME_DELIVERY_RUN_ID" =~'),
  );
  assert.equal((boundedSelection.match(/actions\/artifacts\/\$[a-z_]+\/zip/g) ?? []).length, 2);
  assert.doesNotMatch(boundedSelection, /while\s/);
});

test("a cursor from another CI workflow generation fails closed instead of skipping new runs", () => {
  const delivery = workflow("delivery.yml");
  const sourceSha = "1".padStart(40, "0");
  const pages = [{
    artifacts: [{
      id: 1,
      name: `backend-delivery-cursor-v4-66-158-700-1-${sourceSha}-800-1`,
      digest: `sha256:${"b".repeat(64)}`,
      expired: false,
      workflow_run: {
        id: 800,
        repository_id: 7,
        head_repository_id: 7,
        head_branch: "main",
        head_sha: sourceSha,
      },
    }],
  }];
  const candidates = runJq(
    queueSelector(delivery, "cursor-candidates"),
    pages,
    ["--argjson", "repository_id", "7", "--argjson", "workflow_id", "77"],
  );
  assert.deepEqual(candidates, []);
  const cursor = delivery.slice(delivery.indexOf("      - id: cursor"), delivery.indexOf("      - id: source"));
  assert.match(cursor, /cursor_artifact_count > 0[\s\S]*different or legacy CI workflow generation[\s\S]*exit 64/);
  assert.doesNotMatch(cursor, /cursor_artifact_count > 0[\s\S]*work_required=false/);
});

test("manual resume is pinned to the oldest pending CI item and a source-bound terminal Delivery state", () => {
  const delivery = workflow("delivery.yml");
  const promotion = workflow("_firebase-promote.yml");
  assert.match(delivery, /test "\$INPUT_RUN_ID" = "\$source_ci_run_id"/);
  assert.match(delivery, /test "\$INPUT_SOURCE_SHA" = "\$source_sha"/);
  assert.match(delivery, /--run-id "\$RESUME_DELIVERY_RUN_ID" --run-attempt "\$RESUME_DELIVERY_ATTEMPT"/);
  for (const recoverable of [
    "failure",
    "cancelled",
    "timed_out",
    "stale",
    "action_required",
    "startup_failure",
  ]) {
    assert.match(delivery, new RegExp(`\\.conclusion == "${recoverable}"`));
    assert.match(promotion, new RegExp(`\\.conclusion == "${recoverable}"`));
  }
  assert.match(delivery, /\.status == "completed"/);
  assert.match(promotion, /\.status == "completed"/);
  assert.doesNotMatch(delivery, /\.conclusion == "success" or|\.conclusion == "neutral"|\.conclusion == "skipped"/);
  assert.doesNotMatch(promotion, /\.conclusion == "success" or|\.conclusion == "neutral"|\.conclusion == "skipped"/);
  assert.match(delivery, /backend-delivery-authorization-\$\{CURRENT_CI_WORKFLOW_ID\}-\$\{source_sha\}-\$\{source_ci_run_attempt\}-\$\{RESUME_DELIVERY_ATTEMPT\}/);
  assert.match(delivery, /catch\.backend-delivery-authorization\/v2/);
  assert.match(delivery, /\.deliveryRunId == \$delivery_run_id[\s\S]*\.sourceCiRunId == \$source_run_id[\s\S]*\.sourceCiRunAttempt == \$source_attempt[\s\S]*\.sourceCiWorkflowId == \$source_workflow_id/);
  assert.match(delivery, /\.packageSha256[\s\S]*\.provenanceSha256/);
  assert.match(delivery, /RESUME_PACKAGE_SHA256[\s\S]*RESUME_PROVENANCE_SHA256[\s\S]*sha256sum build\/delivery\/source\/firebase-provenance\.json/);
  assert.match(delivery, /does not contain exactly one source-bound recovery authorization/);
  assert.match(delivery, /endswith\("-" \+ \$source_sha \+ "-" \+ \$attempt\)/);
  assert.match(delivery, /stopped before publishing a checkpoint; the selected CI item will restart at its first stage/);
  assert.match(delivery, /--pattern "firebase-checkpoint-\*-\$\{source_sha\}-\$\{RESUME_DELIVERY_ATTEMPT\}"/);
  assert.match(delivery, /catch\.delivery-checkpoints\/v2/);
  assert.match(delivery, /\.scope \| type == "string" and startswith\("firebase:"\)/);
  assert.match(delivery, /\.provenance\.sourceCiRunId == \$run_id[\s\S]*\.provenance\.sourceCiRunAttempt == \$run_attempt/);
  assert.match(promotion, /delivery_core\.mjs restore-decision[\s\S]*--artifact-count "\$count"/);
  assert.match(promotion, /should_restore="\$\(jq -r '\.shouldRestore'/);
  assert.match(promotion, /jq -r '\.restartFromFirstStage'/);
  assert.doesNotMatch(promotion, /jq -er '\.(?:shouldRestore|restartFromFirstStage)'/);
  assert.match(promotion, /No exact checkpoint exists for \$DEPLOY_ENVIRONMENT; restarting its same verified package at the first stage/);
  assert.doesNotMatch(promotion, /prior_jobs|reached_count|was never reached/);
});

test("GitHub partial reruns fail closed before promotion or cursor mutation", () => {
  const delivery = workflow("delivery.yml");
  const promotion = workflow("_firebase-promote.yml");
  const refusal = /GITHUB_RUN_ATTEMPT > 1[\s\S]*partial reruns may reuse stale authorize outputs/;
  assert.match(promotion, refusal);
  assert.match(delivery.slice(delivery.indexOf("  finalize:")), refusal);
  assert.doesNotMatch(promotion, /GITHUB_RUN_ATTEMPT - 1/);
});

test("only the successful finalizer advances and drains the cursor", () => {
  const delivery = workflow("delivery.yml");
  const finalizer = delivery.slice(delivery.indexOf("  finalize:"));
  assert.match(finalizer, /needs\.authorize\.outputs\.deploy_required == 'false'/);
  assert.match(finalizer, /needs\.authorize\.outputs\.deploy_required == 'true'[\s\S]*needs\.prod\.result == 'success'/);
  assert.match(finalizer, /name: backend-delivery-cursor-v4-/);
  assert.doesNotMatch(finalizer, /overwrite: true/);
  assert.match(finalizer, /retention-days: 90/);
  assert.match(finalizer, /catch\.backend-delivery-cursor\/v4/);
  assert.match(finalizer, /deliveryRunAttempt: \$deliveryRunAttempt[\s\S]*deliveryRunId: \$deliveryRunId/);
  assert.match(finalizer, /sourceCiRunAttempt: \$sourceCiRunAttempt/);
  assert.match(finalizer, /sourceCiWorkflowId: \$sourceCiWorkflowId/);
  assert.match(finalizer, /event_type=backend-delivery-drain/);
  assert.match(finalizer, /Dispatch the next cursor-driven worker[\s\S]*gh api --method POST/);
  assert.doesNotMatch(finalizer, /actions\/workflows\/ci\.yml\/runs|remaining=/);
  assert.equal((delivery.match(/name: backend-delivery-cursor-v4-/g) ?? []).length, 1);
});

test("promotion is ordered dev to protected prod", () => {
  const delivery = workflow("delivery.yml");
  assert.match(delivery, /dev:[\s\S]*environment: dev/);
  assert.doesNotMatch(delivery, /\n  staging:|environment: staging|needs\.staging/);
  const dev = ciJob(delivery, "dev");
  const prod = ciJob(delivery, "prod");
  assert.match(dev, /needs: authorize/);
  assert.match(dev, /outputs\.environment == 'dev'/);
  assert.match(prod, /needs: authorize/);
  assert.doesNotMatch(prod, /needs\.dev/);
  assert.match(prod, /outputs\.environment == 'prod'/);
  assert.match(prod, /outputs\.dev_completion_artifact_id != ''/);
  assert.match(prod, /dev_completion_artifact_digest: \$\{\{ needs\.authorize\.outputs\.dev_completion_artifact_digest \}\}/);
  assert.match(delivery, /backend_delivery_lanes\.mjs select-prod/);

  const promotion = workflow("_firebase-promote.yml");
  const verifyOffset = promotion.indexOf("Verify artifact provenance");
  const authOffset = promotion.indexOf("Authenticate to Google Cloud");
  const gcloudOffset = promotion.indexOf("google-github-actions/setup-gcloud@v3");
  const reverifyOffset = promotion.indexOf("Reverify every authored byte immediately before deployment");
  const deployOffset = promotion.indexOf("./tool/deploy_firebase_targets.sh");
  assert.ok(
    verifyOffset >= 0 &&
      verifyOffset < authOffset &&
      authOffset < gcloudOffset &&
      gcloudOffset < reverifyOffset &&
      reverifyOffset < deployOffset,
  );
  assert.match(promotion, /delivery_core\.mjs next/);
  assert.match(promotion, /delivery_core\.mjs checkpoint/);
  assert.match(promotion, /source_ci_run_attempt:/);
  assert.ok(
    (promotion.match(/--ci-run-attempt "\$SOURCE_CI_RUN_ATTEMPT"/g) ?? []).length >= 7,
  );
  assert.equal((promotion.match(/--scope "\$CHECKPOINT_SCOPE"/g) ?? []).length, 6);
  assert.match(promotion, /firebase_functions_checkpoint\.mjs verify-completed/);
  assert.ok(promotion.indexOf("Verify deployed configuration including restored completed Functions") >
    promotion.indexOf("--status passed"));
  assert.match(promotion, /wait_firestore_indexes_ready\.mjs/);
  assert.ok(
    promotion.indexOf("wait_firestore_indexes_ready.mjs") <
      promotion.indexOf("--status passed"),
    "index readiness must succeed before the stage checkpoint passes",
  );
  assert.match(promotion, /firebase-checkpoint-/);
  assert.match(promotion, /name: firebase-checkpoint-[\s\S]*retention-days: 90/);
  assert.match(promotion, /checkpoint_scope=firebase:\$\{DEPLOY_ENVIRONMENT\}:\$\{project_id\}/);
  assert.match(promotion, /--config "\$PACKAGE_DIR\/firebase\.json"/);
  assert.match(
    promotion,
    /Resume ordered backend stages[\s\S]*Verify active rules match the exact approved source[\s\S]*check_rules_deployment_drift\.mjs[\s\S]*--project "\$PROJECT_ID"[\s\S]*--repo-root build\/delivery\/source-checkout/,
  );
  assert.doesNotMatch(promotion, /npm (?:--prefix \S+ )?(?:test|run lint|run build)|emulators:exec/);
});

test("promotion executes the reverified subset and handles empty Functions as a checkpointed no-op", () => {
  const promotion = workflow("_firebase-promote.yml");
  assert.match(promotion, /npm ci --ignore-scripts --workspaces=false/);
  assert.equal((promotion.match(/--affected-functions true/g) ?? []).length, 3);
  assert.equal((promotion.match(/cmp build\/delivery\/package-plan.json build\/delivery\/reverified-plan.json/g) ?? []).length, 2);
  assert.match(promotion, /cmp build\/delivery\/execution-plan.json build\/delivery\/reverified-plan.json/);
  assert.match(promotion, /cmp build\/delivery\/execution-plan.json build\/delivery\/operator-reverified-execution.json/);
  assert.match(promotion, /' build\/delivery\/execution-plan.json\)"/);
  assert.doesNotMatch(promotion, /' "\$PACKAGE_DIR\/delivery-plan.json"\)"/);
  assert.match(promotion, /if \[\[ "\$stage" == "functions" && -z "\$target" \]\]; then[\s\S]*verified no-op stage[\s\S]*else[\s\S]*\.\/tool\/deploy_firebase_targets.sh/);
  assert.match(promotion, /if: \$\{\{ steps.verify.outputs.has_targets == 'true' \}\}/);
  assert.match(promotion, /\.targets \| any\(startswith\("functions:"\)\)/);
});

test("one-time PROD operator caller retains protected review and cannot borrow a DEV receipt", () => {
  const caller = workflow("selective-backend-release.yml");
  const promotion = workflow("_firebase-promote.yml");
  assert.match(caller, /workflow_dispatch:/);
  assert.match(caller, /group: backend-delivery/);
  assert.match(caller, /source_sha: 656f093d1910afdbe4d93d31565d1782c39aab63/);
  assert.match(caller, /base_sha: ea518ad0576829dbc505293d4edbd9f6710a2b8f/);
  assert.match(caller, /operator_release: true/);
  assert.doesNotMatch(caller, /dev_completion_artifact_id:|prod-backend|backend-delivery-cursor\.json/);
  assert.match(promotion, /environment: \$\{\{ inputs\.approval_environment \|\| inputs\.environment \}\}/);
  assert.match(promotion, /Require recorded human PROD environment approval for operator release/);
  assert.match(promotion, /8d96961ceca63f4959b25097168ebddf01cb5280568f1b09829421c0ef089af1[\s\S]*firebase-backend\.tar\.gz \| sha256sum --check --status/);
  assert.match(promotion, /test "\$APPROVAL_ENVIRONMENT" = prod[\s\S]*test "\$GITHUB_WORKFLOW_REF" = "\$GITHUB_REPOSITORY\/\.github\/workflows\/selective-backend-release\.yml@refs\/heads\/main"/);
  assert.match(promotion, /Prove the accepted PROD baseline is still serving/);
  assert.match(promotion, /Prove mixed-source PROD serving state without restamping retained Functions/);
  assert.match(promotion, /operator-prod-selective-\$\{\{ inputs\.source_sha \}\}/);
  assert.doesNotMatch(caller, /firebase deploy|deploy_firebase_targets\.sh/);
});

test("five-Function caller pins the historical CI artifact and excludes wider backend mutation", () => {
  const caller = workflow("selective-backend-release.yml");
  const promotion = workflow("_firebase-promote.yml");
  assert.match(caller, /release_kind:[\s\S]*- whatsapp-five[\s\S]*- legacy/);
  assert.match(caller, /authorize:\s+name:[^\n]+\n    if: \$\{\{ inputs\.release_kind == 'legacy' \}\}/);
  assert.match(caller, /authorize-whatsapp:[\s\S]*if: \$\{\{ inputs\.release_kind == 'whatsapp-five' \}\}/);
  assert.match(caller, /confirm_whatsapp_five/);
  assert.match(caller, /source_sha: 4dcd759a261f096bcf37d5f69e19eb625b0199b2/);
  assert.match(caller, /base_sha: 5c10b958da8d1774a29990d568a52bc2987b936e/);
  assert.match(caller, /source_ci_run_id: '37511803512'/);
  assert.match(caller, /11435902710[\s\S]*sha256:f9dad63d1753188f57f50f74bcdbd771e9e11c6aff09642d43cfcbf0438d2a49/);
  assert.match(caller, /prod-whatsapp:[\s\S]*needs: authorize-whatsapp[\s\S]*whatsapp_five_release: true/);
  assert.match(promotion, /WHATSAPP_FIVE_RELEASE:[\s\S]*test "\$DEPLOY_ENVIRONMENT" = prod[\s\S]*test "\$APPROVAL_ENVIRONMENT" = prod/);
  assert.match(promotion, /Require recorded human PROD environment approval for operator release\n        if: \$\{\{[^\n]*inputs\.whatsapp_five_release/);
  assert.match(promotion, /8081e1b83a091286b9d34c78f682b3bc985f3fcd4c19cf7c119d7e5238970a88/);
  assert.match(promotion, /whatsapp_five_release\.mjs prepare[\s\S]*--output build\/delivery\/execution-plan\.json/);
  assert.match(promotion, /cmp build\/delivery\/execution-plan\.json build\/delivery\/whatsapp-reverified-execution\.json/);
  assert.match(promotion, /test "\$target" = 'functions:adminReviewCatchWhatsappInbound,functions:adminSendCatchWhatsappReply,functions:catchWhatsappWebhook,functions:onCatchWhatsappReplyOperationWritten,functions:onCatchWhatsappWebhookEventCreated'/);
  assert.match(promotion, /whatsapp_five_release\.mjs params[\s\S]*catchGatesClosed/);
  assert.match(promotion, /WHATSAPP_FIVE_RELEASE:-false}" != true/);
  assert.match(promotion, /Require existing public invocation on three WhatsApp HTTP entrypoints[\s\S]*get-iam-policy "\$service"/);
  assert.match(promotion, /gcloud run services get-iam-policy "\$service"/);
  assert.match(promotion, /test "\$policy_hash" = "\$expected_hash"/);
  assert.doesNotMatch(promotion, /gcloud run services (?:add-iam-policy-binding|set-iam-policy)/);
  assert.doesNotMatch(promotion, /(?:gcloud )?secrets versions access|setIamPolicy|firebase deploy --only functions(?!:)/);
  assert.match(promotion, /whatsapp_five_release\.mjs complete[\s\S]*whatsapp-five-selected-receipt\.json/);
  assert.match(promotion, /coverage: "selected-physical-identities-only"|whatsapp-five-selected-prod-/);
  assert.doesNotMatch(caller, /firebase deploy|deploy_firebase_targets\.sh|prod-backend|contents: write/);
});

test("PR543 Sales caller pins 44 Functions plus rules behind existing protected PROD review", () => {
  const caller = workflow("selective-backend-release.yml");
  const promotion = workflow("_firebase-promote.yml");
  assert.match(caller, /release_kind:[\s\S]*- sales-pr543[\s\S]*- whatsapp-five[\s\S]*- legacy/);
  assert.match(caller, /confirm_sales_pr543/);
  assert.match(caller, /authorize-sales-pr543:[\s\S]*if: \$\{\{ inputs\.release_kind == 'sales-pr543' \}\}/);
  assert.match(caller, /test "\$LEGACY_CONFIRM" = false[\s\S]*test "\$WHATSAPP_CONFIRM" = false/);
  assert.match(caller, /source_sha: c0a213bd9663f69ed1f8df3b5bad9284930e5339/);
  assert.match(caller, /base_sha: 63f13abe6fbc6051771ea6eeab1d147a956f0be5/);
  assert.match(caller, /source_ci_run_id: '37560236235'/);
  assert.match(caller, /11456928387[\s\S]*sha256:ad986512f9bf8d7dc8277475cf5b3dc0687c00ca372e3241a613c8639d8976ca/);
  assert.match(caller, /prod-sales-pr543:[\s\S]*needs: authorize-sales-pr543[\s\S]*sales_pr543_release: true/);
  assert.match(caller, /resume_delivery_run_id:[\s\S]*resume_delivery_attempt:/);
  assert.match(caller, /prod-sales-pr543:[\s\S]*resume_delivery_run_id: \$\{\{ inputs\.resume_delivery_run_id \}\}[\s\S]*resume_delivery_attempt: \$\{\{ inputs\.resume_delivery_attempt \}\}/);
  assert.match(caller, /git diff --quiet "\$REQUESTED_SHA" "\$GITHUB_SHA" --[\s\S]*firestore\.rules/);
  assert.doesNotMatch(caller, /dev_completion_artifact_id:|prod-backend|backend-delivery-cursor\.json/);
  assert.match(promotion, /SALES_PR543_RELEASE:[\s\S]*test "\$DEPLOY_ENVIRONMENT" = prod[\s\S]*test "\$APPROVAL_ENVIRONMENT" = prod/);
  assert.match(promotion, /Require recorded human PROD environment approval for operator release\n        if: \$\{\{[^\n]*inputs\.sales_pr543_release/);
  assert.match(promotion, /594dcd96b724a1a81c0545a015c6099277e35475d30aa0969e4540b1dee319e5/);
  assert.match(promotion, /selective_backend_release\.mjs prepare[\s\S]*--output build\/delivery\/execution-plan\.json/);
  assert.match(promotion, /cmp build\/delivery\/execution-plan\.json build\/delivery\/sales-pr543-reverified-execution\.json/);
  assert.match(promotion, /selective_backend_release\.mjs before[\s\S]*sales-pr543-before\.json/);
  assert.match(promotion, /sales-pr543-before-\$\{\{ inputs\.source_sha \}\}-\$\{\{ github\.run_attempt \}\}/);
  assert.match(promotion, /artifact_prefix=sales-pr543-firebase-checkpoint[\s\S]*--role selective/);
  assert.match(promotion, /--producer-role "\$PRODUCER_ROLE"/);
  assert.match(promotion, /selective_backend_release\.mjs verify-before[\s\S]*sales-pr543-restore\/sales-pr543-before\.json/);
  assert.match(promotion, /selective_backend_release\.mjs params[\s\S]*sales_pr543_params\.outputs\.sha256/);
  assert.match(promotion, /selective_backend_release\.mjs stage --stage "\$stage" --target "\$target"/);
  assert.match(promotion, /selective_backend_release\.mjs complete[\s\S]*sales-pr543-selected-receipt\.json/);
  assert.match(promotion, /sales-pr543-selected-prod-\$\{\{ inputs\.source_sha \}\}/);
  assert.match(promotion, /Verify active rules match the exact approved source[\s\S]*check_rules_deployment_drift\.mjs/);
  assert.ok(promotion.indexOf("Verify active rules match the exact approved source") <
    promotion.indexOf("Prove exact Sales serving revisions and rules completion"));
  assert.ok(promotion.indexOf("Prove exact Sales serving revisions and rules completion") <
    promotion.indexOf("Upload exact Sales and rules completion receipt"));
  assert.ok(promotion.indexOf("Preserve exact Sales before proof for bounded recovery") <
    promotion.indexOf("Resume ordered backend stages"));
  assert.doesNotMatch(caller, /firebase deploy|deploy_firebase_targets\.sh|contents: write/);
  assert.doesNotMatch(promotion, /secrets versions access/);
});

test("one-time PROD approval rejects admin bypass and non-reviewer approvals", () => {
  const step = extractSteps(workflow("_firebase-promote.yml")).find((entry) =>
    entry.name === "Require recorded human PROD environment approval for operator release");
  assert.ok(step?.run);
  const filter = /--argjson history "\$history" '([\s\S]*?)' > \/dev\/null/.exec(step.run)?.[1];
  assert.ok(filter);
  const environment = {id: 123, protection_rules: [{type: "required_reviewers",
    reviewers: [{type: "User", reviewer: {id: 42}}]}]};
  const approval = {state: "approved", user: {id: 42, login: "human-reviewer"},
    environments: [{id: 123, name: "prod"}]};
  const accepted = (history, settings = environment) => {
    const result = spawnSync("jq", ["-en", "--argjson", "environment", JSON.stringify(settings),
      "--argjson", "history", JSON.stringify(history), filter],
    {encoding: "utf8"});
    assert.equal(result.status === 0 || result.status === 1, true, result.stderr);
    return result.status === 0;
  };
  assert.equal(accepted([approval]), true);
  assert.equal(accepted([]), false);
  // The sole configured reviewer may also be the dispatcher when prod permits self-review.
  assert.equal(accepted([{...approval, user: {id: 42, login: "operator"}}]), true);
  assert.equal(accepted([{...approval, user: {id: 99, login: "admin"}}]), false);
  assert.equal(accepted([approval, {...approval, state: "rejected"}]), false);
  assert.equal(accepted([approval], {...environment, protection_rules: []}), false);
});

test("live approval metadata does not change the package comparison and changed targets still fail", (t) => {
  const steps = extractSteps(workflow("_firebase-promote.yml"));
  const script = (name) => {
    const step = steps.find((entry) => entry.name === name);
    assert.ok(step?.run, `missing workflow shell step: ${name}`);
    return step.run;
  };
  for (const environment of ["prod", "prod-backend"]) {
    const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-promotion-review-"));
    t.after(() => fs.rmSync(root, {recursive: true, force: true}));
    const plan = {sourceSha: "a".repeat(40), stages: ["functions"], targets: ["functions:example"],
      productionPromotion: {environment: "prod", preMergeReviewEligible: true, reason: "Review required"}};
    const approval = {environment, reason: "Live review result differs from deterministic verification"};
    fs.mkdirSync(path.join(root, "bin"));
    fs.mkdirSync(path.join(root, "build/delivery/source"), {recursive: true});
    fs.mkdirSync(path.join(root, "fixture-package"));
    const aliases = JSON.stringify({projects: {dev: "fixture-dev"}});
    fs.writeFileSync(path.join(root, ".firebaserc"), aliases);
    fs.writeFileSync(path.join(root, "fixture-package/.firebaserc"), aliases);
    fs.writeFileSync(path.join(root, "verified-plan.json"), JSON.stringify(plan));
    // Exercise the actual shell composition with controlled verifier outputs;
    // package byte validation and live review provenance have separate tests.
    fs.writeFileSync(path.join(root, "bin/node"), `#!${process.execPath}
const fs = require("node:fs");
const args = process.argv.slice(2);
if (args[0] === "tool/ci/delivery_core.mjs") console.log('{"ok":true}');
else if (args[0] === "tool/ci/package_firebase_delivery.mjs") console.log(fs.readFileSync("verified-plan.json", "utf8"));
else if (args[0] === "tool/ci/backend_source_review.mjs") {
  const plan = JSON.parse(fs.readFileSync(0, "utf8"));
  console.log(JSON.stringify({...plan, productionPromotion: JSON.parse(process.env.REVIEW_DECISION)}));
} else throw new Error("Unexpected workflow command: " + args.join(" "));
`, {mode: 0o755});
    const packed = spawnSync("tar", ["-czf", "build/delivery/source/firebase-backend.tar.gz", "-C", "fixture-package", "."], {cwd: root, encoding: "utf8"});
    assert.equal(packed.status, 0, packed.stderr);
    const run = (name) => spawnSync("bash", ["-e", "-o", "pipefail", "-c", script(name)], {
      cwd: root, encoding: "utf8", env: {...process.env,
        PATH: `${path.join(root, "bin")}${path.delimiter}${process.env.PATH}`,
        BASE_SHA: "b".repeat(40), SOURCE_SHA: plan.sourceSha, SOURCE_CI_RUN_ID: "1",
        SOURCE_CI_RUN_ATTEMPT: "1", DEPLOY_ENVIRONMENT: "dev",
        GITHUB_REPOSITORY: "owner/repo", GITHUB_OUTPUT: path.join(root, "outputs"),
        REVIEW_DECISION: JSON.stringify(approval)},
    });
    const verified = run("Verify artifact provenance and packaged CI plan before mutation");
    assert.equal(verified.status, 0, verified.stderr);
    const copied = run("Create a separate deploy tree");
    assert.equal(copied.status, 0, copied.stderr);
    const reverified = run("Reverify every authored byte immediately before deployment");
    assert.equal(reverified.status, 0, reverified.stdout + reverified.stderr);
    assert.deepEqual(JSON.parse(fs.readFileSync(path.join(root, "build/delivery/execution-plan.json"), "utf8")), plan);
    assert.deepEqual(JSON.parse(fs.readFileSync(path.join(root, "build/delivery/production-approval.json"), "utf8")), approval);
    const eligible = run("Recompute automatic production eligibility before authentication");
    assert.equal(eligible.status, environment === "prod-backend" ? 0 : 1, eligible.stderr);
    fs.writeFileSync(path.join(root, "build/delivery/execution-plan.json"), JSON.stringify({...plan, stages: ["functions", "storage"]}));
    assert.notEqual(run("Recompute automatic production eligibility before authentication").status, 0,
      "live Functions approval must not authorize a mixed-stage package");
    fs.writeFileSync(path.join(root, "build/delivery/execution-plan.json"), `${JSON.stringify(plan)}\n`);
    fs.writeFileSync(path.join(root, "verified-plan.json"), JSON.stringify({...plan, targets: ["functions:unexpected"]}));
    const changed = run("Reverify every authored byte immediately before deployment");
    assert.notEqual(changed.status, 0, "changed deployment targets must still fail comparison");
    assert.match(changed.stdout, /differ/);
  }
});

test("ordered artifacts survive main advancing but preserve exact-source and snapshot guards at every stage", () => {
  const promotion = workflow("_firebase-promote.yml");
  const loop = promotion.slice(promotion.indexOf("          while true; do"));
  const boundary = loop.slice(0, loop.indexOf('            deploy_args='));
  for (const assertion of [
    'test "$(git rev-parse HEAD)" = "$CONTROL_PLANE_SHA"',
    'test "$(git -C "$SOURCE_CHECKOUT" rev-parse HEAD)" = "$SOURCE_SHA"',
    'git -C "$SOURCE_CHECKOUT" fetch origin refs/heads/main:refs/remotes/origin/main --no-tags',
    'git -C "$SOURCE_CHECKOUT" merge-base --is-ancestor "$CONTROL_PLANE_SHA" refs/remotes/origin/main',
    'git -C "$SOURCE_CHECKOUT" merge-base --is-ancestor "$SOURCE_SHA" refs/remotes/origin/main',
  ]) assert.ok(boundary.includes(assertion), assertion);
  assert.match(boundary, /if \[\[ "\$REQUIRE_CURRENT_MAIN" == "true" \]\]; then[\s\S]*test "\$\(git -C "\$SOURCE_CHECKOUT" rev-parse refs\/remotes\/origin\/main\)" = "\$SOURCE_SHA"[\s\S]*export CATCH_DEPLOY_ALLOW_BEHIND=0[\s\S]*else\s+export CATCH_DEPLOY_ALLOW_BEHIND=1/);
  assert.match(promotion, /REQUIRE_CURRENT_MAIN: \$\{\{ inputs.require_current_main \}\}/);
  const executor = fs.readFileSync(path.join(repoRoot, "tool/deploy_firebase_targets.sh"), "utf8");
  assert.match(executor, /CATCH_DEPLOY_ALLOW_BEHIND:-0/);
  assert.match(executor, /check_deploy_ref.mjs/);
});

test("the stage guard accepts an advancing main and rejects changed pins or a stale rebaseline", (t) => {
  const directory = fs.mkdtempSync(path.join(fs.realpathSync(os.tmpdir()), "delivery-stage-guard-"));
  t.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  const control = path.join(directory, "control");
  const source = path.join(directory, "source");
  const remote = path.join(directory, "remote.git");
  const git = (cwd, ...args) => {
    const result = spawnSync("git", args, {cwd, encoding: "utf8"});
    assert.equal(result.status, 0, result.stderr);
    return result.stdout.trim();
  };
  fs.mkdirSync(control);
  git(control, "init", "-q", "-b", "main");
  git(control, "config", "user.name", "Delivery test");
  git(control, "config", "user.email", "delivery-test@example.invalid");
  fs.writeFileSync(path.join(control, "README"), "approved\n");
  git(control, "add", ".");
  git(control, "commit", "-qm", "approved", "--no-verify");
  const approved = git(control, "rev-parse", "HEAD");
  git(directory, "clone", "--bare", control, remote);
  git(control, "remote", "add", "origin", remote);
  git(directory, "clone", remote, source);
  git(source, "config", "fetch.prune", "true");
  const promotion = workflow("_firebase-promote.yml");
  const loop = promotion.slice(promotion.indexOf("          while true; do"));
  const guard = loop.slice(
    loop.indexOf('            test "$(git rev-parse HEAD)"'),
    loop.indexOf('            deploy_args='),
  );
  assert.ok(guard.includes("merge-base --is-ancestor"));
  const run = (overrides = {}) => spawnSync("bash", ["-c",
    'set -euo pipefail\n' + guard + '\nprintf "%s" "$CATCH_DEPLOY_ALLOW_BEHIND"\n',
  ], {
    cwd: control, encoding: "utf8",
    env: {...process.env, CONTROL_PLANE_SHA: approved, SOURCE_SHA: approved,
      SOURCE_CHECKOUT: source, REQUIRE_CURRENT_MAIN: "true", ...overrides},
  });
  const initial = run();
  assert.equal(initial.status, 0, initial.stderr);
  assert.equal(initial.stdout, "0");
  fs.writeFileSync(path.join(control, "README"), "unrelated newer UI\n");
  git(control, "add", ".");
  git(control, "commit", "-qm", "new UI", "--no-verify");
  const newer = git(control, "rev-parse", "HEAD");
  git(control, "push", "origin", "main");
  git(control, "checkout", "--detach", approved);
  const ordered = run({REQUIRE_CURRENT_MAIN: "false"});
  assert.equal(ordered.status, 0, ordered.stderr);
  assert.equal(ordered.stdout, "1");
  assert.notEqual(run().status, 0, "rebaseline must remain exactly current main");
  assert.notEqual(run({REQUIRE_CURRENT_MAIN: "false", CONTROL_PLANE_SHA: newer}).status, 0);
  assert.notEqual(run({REQUIRE_CURRENT_MAIN: "false", SOURCE_SHA: newer}).status, 0);
  fs.writeFileSync(path.join(control, "README"), "unmerged workflow\n");
  git(control, "add", ".");
  git(control, "commit", "-qm", "unmerged", "--no-verify");
  const unmerged = git(control, "rev-parse", "HEAD");
  assert.notEqual(run({REQUIRE_CURRENT_MAIN: "false", CONTROL_PLANE_SHA: unmerged}).status, 0,
    "a matching checkout pin outside main history must still fail");
});

test("promotion keeps the verified package immutable and reverifies its deploy copy", () => {
  const promotion = workflow("_firebase-promote.yml");
  assert.match(promotion, /cp -a build\/delivery\/package build\/delivery\/deploy-tree/);
  assert.match(promotion, /npm --prefix build\/delivery\/deploy-tree\/functions ci[\s\S]*--omit=dev --ignore-scripts/);
  assert.doesNotMatch(promotion, /npm --prefix build\/delivery\/package\/functions ci/);
  assert.match(promotion, /name: Reverify every authored byte immediately before deployment/);
  assert.ok(
    (promotion.match(/--package-dir build\/delivery\/package/g) ?? []).length >= 2,
    "the pristine package must be verified both after extraction and before authentication",
  );
  assert.match(promotion, /--package-dir build\/delivery\/deploy-tree[\s\S]*--allow-runtime-dependencies true[\s\S]*--trusted-package-dir build\/delivery\/package/);
  assert.ok(
    promotion.indexOf("Reverify every authored byte immediately before deployment") <
      promotion.indexOf("Resume ordered backend stages"),
  );
  assert.match(promotion, /restarting its same verified package at the first stage/);
  assert.match(promotion, /\.conclusion == "failure"[\s\S]*\.conclusion == "cancelled"[\s\S]*\.conclusion == "timed_out"/);
  assert.match(promotion, /git -C "\$SOURCE_CHECKOUT" merge-base --is-ancestor "\$SOURCE_SHA" refs\/remotes\/origin\/main/);
  assert.match(
    promotion,
    /Reverify every authored byte immediately before deployment[\s\S]*sanitize_firestore_indexes_for_deploy\.mjs[\s\S]*prepare_functions_params_for_deploy\.mjs[\s\S]*Resume ordered backend stages/,
  );
  assert.match(
    promotion,
    /indexes=build\/delivery\/deploy-tree\/firestore\.indexes\.json[\s\S]*if \[\[ -f "\$indexes" \]\][\s\S]*--indexes "\$indexes"[\s\S]*--current-indexes firestore\.indexes\.json/,
  );
  assert.doesNotMatch(
    promotion,
    /--indexes build\/delivery\/package\/firestore\.indexes\.json/,
  );
  const promoteStep = promotion.slice(
    promotion.indexOf("- id: promote"),
    promotion.indexOf("- name: Upload resumable checkpoint"),
  );
  const paramsStep = promotion.slice(
    promotion.indexOf("Materialize non-secret Functions params"),
    promotion.indexOf("- id: promote"),
  );
  assert.match(paramsStep, /prepare_functions_params_for_deploy\.mjs/);
  assert.match(paramsStep, /ALGOLIA_APPLICATION_ID: \$\{\{ vars\.ALGOLIA_APPLICATION_ID \}\}/);
  assert.match(paramsStep, /RAZORPAY_PUBLIC_KEY_ID: \$\{\{ vars\.RAZORPAY_PUBLIC_KEY_ID \}\}/);
  assert.doesNotMatch(paramsStep, /ALGOLIA_APP_ID:|RAZORPAY_KEY_ID:|RAZORPAY_KEY_SECRET:/);
  assert.match(
    paramsStep,
    /functions_dir=build\/delivery\/deploy-tree\/functions[\s\S]*if \[\[ -d "\$functions_dir" \]\][\s\S]*--functions-dir "\$functions_dir"/,
  );
  assert.match(paramsStep, /--project "\$\{\{ steps\.verify\.outputs\.project_id \}\}"/);
  assert.match(paramsStep, /META_WHATSAPP_APP_ID: \$\{\{ vars\.META_WHATSAPP_APP_ID \}\}/);
  assert.match(
    paramsStep,
    /META_WHATSAPP_EMBEDDED_SIGNUP_CONFIG_ID: \$\{\{ vars\.META_WHATSAPP_EMBEDDED_SIGNUP_CONFIG_ID \}\}/,
  );
  assert.match(paramsStep, /META_WHATSAPP_GRAPH_VERSION: \$\{\{ vars\.META_WHATSAPP_GRAPH_VERSION \}\}/);
  assert.match(paramsStep, /META_WHATSAPP_ENABLED: \$\{\{ vars\.META_WHATSAPP_ENABLED \}\}/);
  assert.doesNotMatch(paramsStep, /META_WHATSAPP_APP_SECRET:/);
  assert.doesNotMatch(promoteStep, /META_WHATSAPP_/);
});

test("promotion guards optional deploy-group payloads", () => {
  const promotion = workflow("_firebase-promote.yml");
  assert.match(
    promotion,
    /Verified package has no Firestore index payload; skipping index sanitization\./,
  );
  assert.match(
    promotion,
    /Verified package has no Functions payload; skipping Functions parameter materialization\./,
  );
});

test("Backend Rebaseline authorizes one exact all-backend snapshot", () => {
  const rebaseline = workflow("backend-rebaseline.yml") + "\n" + workflow("_backend-rebaseline.yml");
  assert.match(rebaseline, /^name: Backend Rebaseline/m);
  assert.match(rebaseline, /workflow_dispatch:[\s\S]*source_sha:[\s\S]*reason:[\s\S]*confirm_full_backend_rebaseline:/);
  assert.doesNotMatch(rebaseline, /workflow_run:|repository_dispatch:|schedule:/);
  assert.match(rebaseline, /group: backend-delivery\n/);
  assert.match(rebaseline, /test "\$GITHUB_REF" = "refs\/heads\/main"/);
  assert.match(rebaseline, /test "\$CONFIRM_FULL_BACKEND_REBASELINE" = "true"/);
  assert.match(rebaseline, /test "\$\(git rev-parse refs\/remotes\/origin\/main\)" = "\$SOURCE_SHA"/);
  assert.match(rebaseline, /test "\$GITHUB_WORKFLOW_SHA" = "\$SOURCE_SHA"/);
  assert.match(rebaseline, /A verified v4 delivery cursor is required before a backend rebaseline/);
  assert.match(rebaseline, /--run-id "\$delivery_run_id" --run-attempt "\$delivery_run_attempt"/);
  assert.match(rebaseline, /backend_delivery_lanes\.mjs verify-run[\s\S]*--role cursor/);
  assert.match(rebaseline, /node tool\/harness\.mjs plan[\s\S]*--paths functions\/src\/index\.ts,firestore\.indexes\.json,firestore\.rules,storage\.rules[\s\S]*--mode main/);
  for (const group of [
    "firestore-indexes",
    "firestore-rules",
    "functions",
    "storage-rules",
  ]) assert.match(rebaseline, new RegExp(`"${group}"`));
  for (const workflowName of [
    "functions-ci.yml",
    "contracts-ci.yml",
    "firestore-rules-ci.yml",
  ]) assert.match(rebaseline, new RegExp(escapeRegex(workflowName)));
  assert.match(rebaseline, /functions-lib-\$\{\{ needs\.authorize\.outputs\.source_sha \}\}-\$\{\{ github\.run_attempt \}\}/);
  assert.match(rebaseline, /package_firebase_delivery\.mjs prepare[\s\S]*--functions-lib-dir build\/rebaseline\/tested-functions-lib/);
  assert.match(rebaseline, /test "\$stages" = "firestore-indexes,functions,firestore-rules,storage-rules"/);
  assert.match(rebaseline, /name: firebase-delivery-\$\{\{ needs\.authorize\.outputs\.source_sha \}\}-\$\{\{ github\.run_attempt \}\}/);
  assert.doesNotMatch(rebaseline, /functions:delete|firestore:delete|storage:delete|--force|firebase deploy --only extensions/);
});

test("rebaseline authority discovery requires canonical current-attempt proof and bounded recovery", async (t) => {
  const worker = workflow("_backend-rebaseline.yml");
  const block = worker.split("      - id: authority\n")[1].split("\n      - name:")[0];
  const script = block.split("        run: |\n")[1].split("\n").map((line) => line.slice(10)).join("\n");
  const sha = "a".repeat(40);
  const run = {id: 123, name: "CI", path: ".github/workflows/ci.yml", workflow_id: 77,
    event: "push", head_branch: "main", head_repository: {full_name: "owner/catch"},
    head_sha: sha, status: "completed", conclusion: "success", run_number: 99, run_attempt: 1};
  const pages = (runs) => [{workflow_runs: runs}];
  const cases = [
    {name: "complete listing", lists: [pages([run])], ok: true},
    {name: "partial listing fields are discovery only", lists: [pages([{id: 123, workflow_id: 77,
      head_sha: sha, run_number: 99, run_attempt: 1}])], ok: true},
    {name: "stale list status is not authority", lists: [pages([{...run, status: "in_progress", conclusion: null}])], ok: true},
    {name: "stale listing recovers", lists: [pages([{...run, head_sha: "b".repeat(40)}]), pages([run])], ok: true, reads: 2},
    {name: "omitted run recovers", lists: [pages([]), pages([run])], ok: true, reads: 2},
    {name: "paginated run is discovered", lists: [[{workflow_runs: []}, {workflow_runs: [run]}]], ok: true},
    {name: "transient list API error recovers", lists: [null, pages([run])], ok: true, reads: 2},
    {name: "permanent list API error", lists: [null], reads: 3},
    {name: "permanent omission", lists: [pages([])], reads: 3},
    {name: "malformed listing", lists: [[{unexpected: []}]], reads: 3},
    {name: "malformed candidate", lists: [pages(["invalid"])], reads: 3},
    {name: "foreign workflow listing", lists: [pages([{...run, workflow_id: 78}])], reads: 3},
    {name: "foreign source listing", lists: [pages([{...run, head_sha: "b".repeat(40)}])], reads: 3},
    {name: "invalid numeric identity", lists: [pages([{...run, run_attempt: 1.5}])], reads: 3},
    {name: "canonical API error", lists: [pages([run])], canonical: null, reads: 3},
    {name: "attempt API error", lists: [pages([run])], attempt: null, reads: 3},
    {name: "new attempt cannot reuse stale listing", lists: [pages([run])], canonical: {...run, run_attempt: 2}},
    {name: "fresh new attempt binds exact proof", lists: [pages([{...run, run_attempt: 2}])],
      canonical: {...run, run_attempt: 2}, attempt: {...run, run_attempt: 2}, ok: true, expectedAttempt: 2},
    {name: "new attempt discovered on retry", lists: [pages([run]), pages([{...run, run_attempt: 2}])],
      canonical: {...run, run_attempt: 2}, attempt: {...run, run_attempt: 2}, ok: true, reads: 2, expectedAttempt: 2},
    {name: "canonical attempt advances during proof", lists: [pages([run])], canonicalFinal: {...run, run_attempt: 2}},
    {name: "attempt proof belongs to another attempt", lists: [pages([run])], attempt: {...run, run_attempt: 2}},
  ];
  for (const [field, value] of [
    ["id", 124], ["run_number", 100], ["name", "Other"], ["path", ".github/workflows/other.yml"],
    ["workflow_id", 78], ["event", "pull_request"], ["head_branch", "feature"],
    ["head_repository", {full_name: "foreign/catch"}], ["head_sha", "b".repeat(40)],
    ["status", "in_progress"], ["conclusion", "failure"],
  ]) {
    cases.push({name: `canonical rejects ${field}`, lists: [pages([run])], canonical: {...run, [field]: value}});
    cases.push({name: `attempt rejects ${field}`, lists: [pages([run])], attempt: {...run, [field]: value}});
  }
  for (const fixture of cases) await t.test(fixture.name, () => {
    const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-rebaseline-authority-"));
    try {
      const output = path.join(directory, "output");
      const log = path.join(directory, "calls.jsonl");
      const fixturePath = path.join(directory, "fixture.json");
      fs.writeFileSync(fixturePath, JSON.stringify({canonical: run, attempt: run, ...fixture}));
      fs.writeFileSync(output, "");
      fs.writeFileSync(path.join(directory, "gh"), `#!${process.execPath}
const fs = require("node:fs");
const fixture = JSON.parse(fs.readFileSync(process.env.AUTHORITY_FIXTURE, "utf8"));
const endpoint = process.argv.at(-1);
const log = process.env.AUTHORITY_LOG;
const calls = fs.existsSync(log) ? fs.readFileSync(log, "utf8").trim().split("\\n").map(JSON.parse) : [];
const isList = endpoint.includes("/runs?") || endpoint.includes("/ci.yml/runs?");
const kind = isList ? "list" : endpoint.includes("/attempts/") ? "attempt" : "canonical";
fs.appendFileSync(log, JSON.stringify({kind, endpoint, args: process.argv.slice(2)}) + "\\n");
let value;
if (isList) value = fixture.lists[Math.min(calls.filter((x) => x.kind === "list").length, fixture.lists.length - 1)];
else if (kind === "attempt") {
  if (endpoint !== "repos/owner/catch/actions/runs/123/attempts/" + (fixture.expectedAttempt ?? 1)) process.exit(65);
  value = fixture.attempt;
} else {
  if (endpoint !== "repos/owner/catch/actions/runs/123") process.exit(65);
  value = calls.at(-1)?.kind === "attempt" && Object.hasOwn(fixture, "canonicalFinal") ? fixture.canonicalFinal : fixture.canonical;
}
if (value === null) process.exit(1);
process.stdout.write(JSON.stringify(value));
`, {mode: 0o755});
      fs.writeFileSync(path.join(directory, "sleep"), "#!/bin/sh\nexit 0\n", {mode: 0o755});
      const result = spawnSync("bash", ["-c", script], {encoding: "utf8", timeout: 15000, env: {
        ...process.env, PATH: `${directory}${path.delimiter}${process.env.PATH}`,
        AUTHORITY_FIXTURE: fixturePath, AUTHORITY_LOG: log, GITHUB_OUTPUT: output,
        GITHUB_REPOSITORY: "owner/catch", SOURCE_SHA: sha, SOURCE_CI_WORKFLOW_ID: "77",
      }});
      assert.equal(result.status, fixture.ok ? 0 : 64, result.stdout + result.stderr);
      const calls = fs.readFileSync(log, "utf8").trim().split("\n").map(JSON.parse);
      assert.equal(calls.filter((x) => x.kind === "list").length, fixture.reads ?? (fixture.ok ? 1 : 3));
      assert.ok(calls.length <= 12, "API retries must be bounded");
      assert.ok(calls.every((x) => x.args.includes("Cache-Control: no-cache")));
      assert.ok(calls.filter((x) => x.kind === "list").every((x) =>
        x.args.includes("--paginate") && x.args.includes("--slurp")));
      if (fixture.ok) {
        assert.equal(fs.readFileSync(output, "utf8"), `source_ci_run_id=123\nsource_ci_run_attempt=${fixture.expectedAttempt ?? 1}\nsource_ci_run_number=99\n`);
        assert.ok(calls.some((x) => x.kind === "list" && x.endpoint ===
          `repos/owner/catch/actions/runs?branch=main&event=push&head_sha=${sha}&per_page=100`));
        assert.deepEqual(calls.slice(-3).map((x) => x.kind), ["canonical", "attempt", "canonical"]);
      } else assert.equal(fs.readFileSync(output, "utf8"), "", "failed proof cannot publish authority outputs");
    } finally {
      fs.rmSync(directory, {recursive: true, force: true});
    }
  });
});

test("rebaseline defaults to DEV and validates the target before authorizing source", (t) => {
  const caller = workflow("backend-rebaseline.yml");
  const worker = workflow("_backend-rebaseline.yml");
  assert.match(caller, /target_environment:\n(?:        [^\n]*\n)*        default: dev\n(?:        [^\n]*\n)*        options: \[dev, prod\]/);
  assert.match(worker, /target_environment:\n(?:        [^\n]*\n)*        default: dev/);
  assert.ok(ciJob(caller, "snapshot").includes("target_environment: ${{ inputs.target_environment }}"));
  const authorize = ciJob(worker, "authorize");
  assert.ok(authorize.includes("target_environment: ${{ steps.inputs.outputs.target_environment }}"));
  assert.ok(authorize.includes("TARGET_ENVIRONMENT: ${{ inputs.target_environment }}"));
  const script = extractSteps(authorize).find((step) => step.name === "Require an explicit exact-current-main authorization").run;
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-rebaseline-target-"));
  t.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  fs.writeFileSync(path.join(directory, "git"), '#!/bin/sh\ntouch "$GIT_CALLED"\nif [ "$1" = rev-parse ]; then printf "%s\\n" "$SOURCE_SHA"; fi\n', {mode: 0o755});
  const output = path.join(directory, "output");
  const called = path.join(directory, "git-called");
  for (const target of ["dev", "prod", "", "staging", "DEV", "prod\ndev", "true"]) {
    fs.writeFileSync(output, "");
    fs.rmSync(called, {force: true});
    const sha = "a".repeat(40);
    const result = spawnSync("bash", ["-c", script], {encoding: "utf8", env: {
      ...process.env, PATH: `${directory}${path.delimiter}${process.env.PATH}`,
      GIT_CALLED: called, GITHUB_OUTPUT: output, TARGET_ENVIRONMENT: target,
      SOURCE_SHA: sha, GITHUB_SHA: sha, GITHUB_WORKFLOW_SHA: sha, GITHUB_REF: "refs/heads/main",
      CONFIRM_FULL_BACKEND_REBASELINE: "true", REASON: "Approved bounded snapshot",
    }});
    if (["dev", "prod"].includes(target)) {
      assert.equal(result.status, 0, result.stderr);
      assert.match(fs.readFileSync(output, "utf8"), new RegExp(`^target_environment=${target}$`, "m"));
    } else {
      assert.notEqual(result.status, 0, `Accepted invalid target ${JSON.stringify(target)}`);
      assert.equal(fs.readFileSync(output, "utf8"), "");
      assert.equal(fs.existsSync(called), false, "Invalid scope must fail before consulting source state");
    }
  }
});

test("DEV rebaseline cannot schedule production or finalization even without environment protection", () => {
  const worker = workflow("_backend-rebaseline.yml");
  const condition = (source, job) => {
    const expression = ciJob(source, job).match(/^    if: \$\{\{ (.+) \}\}$/m)?.[1];
    assert.ok(expression, `Missing explicit ${job} job condition`);
    return new Function("needs", "always", `return Boolean(${expression});`);
  };
  const assertScope = (source, job) => {
    const evaluate = condition(source, job);
    for (const target of [undefined, "", "dev", "prod", "staging"]) {
      for (const authorize of ["success", "failure", "skipped"]) {
        for (const dev of ["success", "failure", "cancelled", "skipped"]) {
          for (const prod of ["success", "failure", "skipped"]) {
            const needs = {authorize: {result: authorize, outputs: {target_environment: target}},
              dev: {result: dev}, prod: {result: prod}};
            const expected = target === "prod" && authorize === "success" && dev === "success" &&
              (job === "prod" || prod === "success");
            assert.equal(evaluate(needs, () => true), expected,
              `${job}: target=${target}, authorize=${authorize}, dev=${dev}, prod=${prod}`);
          }
        }
      }
    }
  };
  for (const job of ["prod", "finalize"]) {
    assertScope(worker, job);
    const original = ciJob(worker, job);
    const unsafe = original.replace("needs.authorize.outputs.target_environment == 'prod' && ", "");
    assert.notEqual(unsafe, original, `Missing ${job} scope guard`);
    assert.throws(() => assertScope(worker.replace(original, unsafe), job), /target=/,
      `Removing ${job}'s scope guard must fail the safety test`);
  }
  const finalizer = ciJob(worker, "finalize");
  const beforeFinalizer = worker.slice(0, worker.indexOf(finalizer));
  assert.doesNotMatch(beforeFinalizer, /gh api --method POST|event_type=backend-delivery-drain/);
  assert.match(finalizer, /name: backend-delivery-cursor-v4-/);
  assert.match(finalizer, /event_type=backend-delivery-drain/);
});

test("rebaseline impact plan binds the validated environment without changing backend stages", (t) => {
  const authorize = ciJob(workflow("_backend-rebaseline.yml"), "authorize");
  assert.ok(authorize.includes("TARGET_ENVIRONMENT: ${{ steps.inputs.outputs.target_environment }}"));
  const script = extractSteps(authorize).find((step) => step.name === "Create the graph-authorized all-backend impact plan").run;
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-rebaseline-plan-target-"));
  t.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  fs.writeFileSync(path.join(directory, "git"), "#!/bin/sh\nexit 0\n", {mode: 0o755});
  const plan = {complete: true, graphStatus: "required", mode: "main", operations: {
    deployGroups: ["functions", "firestore-indexes", "firestore-rules", "storage-rules"],
    ciTargets: ["functions", "contracts", "firestore_rules"],
  }};
  fs.writeFileSync(path.join(directory, "node"), `#!/bin/sh\nprintf '%s\\n' '${JSON.stringify(plan)}'\n`, {mode: 0o755});
  for (const target of ["dev", "prod"]) {
    const result = spawnSync("bash", ["-c", script], {cwd: directory, encoding: "utf8", env: {
      ...process.env, PATH: `${directory}${path.delimiter}${process.env.PATH}`,
      BASE_SHA: "b".repeat(40), SOURCE_SHA: "a".repeat(40), TARGET_ENVIRONMENT: target,
      GITHUB_RUN_ID: "123", GITHUB_RUN_ATTEMPT: "1", REBASELINE_REASON: "Approved bounded snapshot",
    }});
    assert.equal(result.status, 0, result.stderr);
    const bound = JSON.parse(fs.readFileSync(path.join(directory, "build/rebaseline/impact-plan.json"), "utf8"));
    assert.equal(bound.rebaseline.targetEnvironment, target);
    assert.equal(bound.sourceSha, "a".repeat(40));
    assert.equal(bound.sourceCiRunId, "123");
    assert.equal(bound.sourceCiRunAttempt, "1");
    assert.deepEqual(bound.operations, plan.operations);
  }
});

test("Backend Rebaseline promotes in order and advances only a successful current-main prod", () => {
  const rebaseline = workflow("backend-rebaseline.yml") + "\n" + workflow("_backend-rebaseline.yml");
  assert.match(rebaseline, /dev:[\s\S]*needs: \[authorize, package\][\s\S]*environment: dev/);
  assert.doesNotMatch(rebaseline, /\n  staging:|environment: staging|needs\.staging/);
  assert.match(rebaseline, /prod:[\s\S]*needs: \[authorize, dev\][\s\S]*environment: prod/);
  assert.equal((rebaseline.match(/require_current_main: true/g) ?? []).length, 2);
  const finalizer = rebaseline.slice(rebaseline.indexOf("  finalize:"));
  assert.match(finalizer, /needs\.prod\.result == 'success'/);
  assert.match(finalizer, /test "\$GITHUB_RUN_ATTEMPT" = "1"/);
  assert.match(finalizer, /test "\$\(git rev-parse refs\/remotes\/origin\/main\)" = "\$SOURCE_SHA"/);
  assert.match(finalizer, /catch\.backend-delivery-cursor\/v4/);
  assert.match(finalizer, /sourceCiRunId: \$sourceCiRunId/);
  assert.match(finalizer, /name: backend-delivery-cursor-v4-/);
  assert.match(finalizer, /event_type=backend-delivery-drain/);

  const promotion = workflow("_firebase-promote.yml");
  assert.match(promotion, /require_current_main:[\s\S]*default: false[\s\S]*type: boolean/);
  assert.match(promotion, /\[\[ "\$REQUIRE_CURRENT_MAIN" =~ \^\(true\|false\)\$ \]\]/);
  assert.match(promotion, /if \[\[ "\$REQUIRE_CURRENT_MAIN" == "true" \]\]; then[\s\S]*rev-parse refs\/remotes\/origin\/main\)" = "\$SOURCE_SHA"/);

  const delivery = workflow("delivery.yml");
  const cursorOrigin = delivery.slice(
    delivery.indexOf("node tool/ci/backend_delivery_lanes.mjs verify-run"),
    delivery.indexOf("cursor_source_run="),
  );
  assert.match(cursorOrigin, /backend_delivery_lanes\.mjs verify-run/);
  assert.match(cursorOrigin, /--role cursor/);
});

test("automatic target planning rejects broad and unrelated Firebase products", () => {
  const planner = fs.readFileSync(
    path.join(repoRoot, "tool/firebase/plan_firebase_deploy_targets.mjs"),
    "utf8",
  );
  assert.match(planner, /firestore:indexes[\s\S]*functions[\s\S]*firestore:rules[\s\S]*storage/);
  assert.doesNotMatch(planner.match(/const safeOrder = \[[\s\S]*?\];/)[0], /hosting|remoteconfig|extensions/);
  assert.match(planner, /not allowed in automatic delivery/);
});

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function queueSelector(delivery, name) {
  const begin = `# queue-selector: ${name}-begin`;
  const end = `# queue-selector: ${name}-end`;
  const startOffset = delivery.indexOf(begin);
  const endOffset = delivery.indexOf(end, startOffset);
  assert.ok(startOffset >= 0 && endOffset > startOffset, `missing ${name} selector markers`);
  const segment = delivery.slice(startOffset, endOffset);
  const match = segment.match(/'\n([\s\S]*?)\n\s*'\s*(?:<<<|"\$artifact_pages_file")/);
  assert.ok(match, `unable to extract ${name} jq program`);
  return match[1];
}

function runJq(program, input, args = []) {
  const result = spawnSync("jq", ["-c", ...args, program], {
    encoding: "utf8",
    input: JSON.stringify(input),
    maxBuffer: 64 * 1024 * 1024,
  });
  assert.equal(result.status, 0, result.error?.message ?? result.stderr);
  return JSON.parse(result.stdout);
}


test("automatic production is recomputed before credentials and cannot be used for recovery", () => {
  const delivery = workflow("delivery.yml");
  assert.match(delivery, /production_environment: \$\{\{ steps\.package\.outputs\.production_environment \}\}/);
  assert.match(delivery, /approval_environment: \$\{\{ needs\.authorize\.outputs\.production_environment \}\}/);
  assert.match(delivery, /GITHUB_EVENT_NAME.*workflow_dispatch.*production_environment=prod/);
  const promotion = workflow("_firebase-promote.yml");
  assert.match(promotion, /environment: \$\{\{ inputs\.approval_environment \|\| inputs\.environment \}\}/);
  assert.match(promotion, /group: firebase-\$\{\{ inputs\.environment \}\}/);
  for (const guard of ['test "$DEPLOY_ENVIRONMENT" = prod', 'test "$APPROVAL_ENVIRONMENT" = prod-backend',
    'test "$GITHUB_REF" = refs/heads/main', 'test -z "$RESUME_RUN_ID"',
    'test "$REQUIRE_CURRENT_MAIN" = false', 'workflow_run|repository_dispatch',
    'delivery.yml@refs/heads/main']) assert.ok(promotion.includes(guard));
  assert.ok(promotion.indexOf("Recompute automatic production eligibility") < promotion.indexOf("Authenticate to Google Cloud"));
  assert.match(promotion, /jq -e '\.environment == "prod-backend"'[\s\S]*build\/delivery\/production-approval.json/);
  assert.match(promotion, /jq -e '\.stages == \["functions"\]'[\s\S]*build\/delivery\/execution-plan.json/);
});

test("deployment-image retention has one bounded seven-day policy without indefinite keep exceptions", () => {
  const policy = JSON.parse(fs.readFileSync(path.join(repoRoot, "tool/firebase/artifact_registry_cleanup_policy.json"), "utf8"));
  assert.deepEqual(policy, [{name: "delete-deployment-images-after-7-days", action: {type: "Delete"}, condition: {tagState: "any", olderThan: "7d"}}]);
});


test("automated PR CI preserves independently verified historical production review", () => {
  const ci = workflow("ci.yml");
  assert.doesNotMatch(ci, /backend-review|Backend source review|BACKEND_REVIEW_REQUIRED/u);
  for (const name of ["backend-rebaseline.yml", "backend-staging.yml"]) {
    assert.match(workflow(name), /pull-requests: read/);
  }
  for (const name of ["delivery.yml", "_firebase-promote.yml"]) {
    const text = workflow(name);
    assert.match(text, /pull-requests: read/);
    assert.ok(text.includes('node tool/ci/backend_source_review.mjs'));
    const auth = text.indexOf("Authenticate to Google Cloud");
    if (auth >= 0) assert.ok(text.indexOf("node tool/ci/backend_source_review.mjs") < auth);
  }
});

test("Required CI cannot succeed when main publication is skipped or absent", (context) => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-required-finalization-"));
  context.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  fs.writeFileSync(path.join(directory, "gh"), '#!/bin/sh\ntouch "$GH_CALLED"\nexit 1\n', {mode: 0o755});
  const command = extractSteps(ciJob(workflow("ci.yml"), "required"))
    .find((step) => step.name === "Require every selected lane").run;
  for (const result of [undefined, "skipped", "failure", "cancelled"]) {
    const needs = {plan: {result: "success"}, "package-firebase": {result: "skipped"},
      ...(result == null ? {} : {"finalize-plan": {result}})};
    const execution = spawnSync("bash", ["-c", command], {encoding: "utf8", env: {
      ...process.env, PATH: `${directory}${path.delimiter}${process.env.PATH}`,
      GH_CALLED: path.join(directory, "called"), GITHUB_REF: "refs/heads/main",
      EVENT_NAME: "push", NEEDS_JSON: JSON.stringify(needs), DEPLOY_REQUIRED: "false",
    }});
    assert.notEqual(execution.status, 0, `Unexpected main success with finalize-plan=${result}`);
    assert.equal(fs.existsSync(path.join(directory, "called")), false, "Missing finalization must reject before consulting artifacts.");
  }
});

test("callable permission sync supports CI-relative paths and historical package compatibility", (context) => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-callable-scope-"));
  context.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  fs.mkdirSync(path.join(directory, "bin"));
  fs.writeFileSync(path.join(directory, ".firebaserc"), JSON.stringify({projects: {dev: "demo-project"}}));
  const receipt = path.join(directory, "npm-args");
  fs.writeFileSync(path.join(directory, "bin/npm"), '#!/bin/sh\nprintf "%s\\n" "$@" > "$NPM_ARGS"\n', {mode: 0o755});
  const executor = fs.readFileSync(path.join(repoRoot, "tool/deploy_firebase_targets.sh"), "utf8");
  const sync = executor.slice(executor.indexOf("sync_callable_invokers() {"), executor.indexOf('\nplan_output="'));
  assert.match(executor, /sync_callable_invokers "\$deploy_only"/);
  for (const functionsDir of [
    "build/delivery/deploy-tree/functions",
    "./build/delivery/deploy-tree/functions",
    path.join(directory, "build/delivery/deploy-tree/functions"),
    "build/delivery/deploy tree/functions",
  ]) {
    const helper = path.resolve(directory, functionsDir, "scripts/set-callable-invokers-public.cjs");
    fs.mkdirSync(path.dirname(helper), {recursive: true});
    for (const version of [1, undefined, 2]) {
      fs.writeFileSync(helper,
        `module.exports = ${JSON.stringify(version === undefined ? {} : {functionTargetScopeVersion: version})};\n`);
      if (fs.existsSync(receipt)) fs.unlinkSync(receipt);
      const result = spawnSync("bash", ["-eu", "-c", sync + '\nsync_callable_invokers "functions:alpha,functions:beta"'], {
        cwd: directory, encoding: "utf8", env: {...process.env, repo_root: directory, environment: "dev",
          CATCH_DELIVERY_FUNCTIONS_DIR: functionsDir, NPM_ARGS: receipt,
          PATH: `${path.join(directory, "bin")}${path.delimiter}${process.env.PATH}`},
      });
      if (version === 2) {
        assert.notEqual(result.status, 0);
        assert.match(result.stderr, /Unsupported packaged callable scope protocol/);
        assert.equal(fs.existsSync(receipt), false);
      } else {
        assert.equal(result.status, 0, `${functionsDir}: ${result.stderr}`);
        assert.deepEqual(fs.readFileSync(receipt, "utf8").trim().split("\n"), [
          "--prefix", functionsDir, "run", "sync:callable-invokers", "--", "demo-project",
          ...(version === 1 ? ["--targets", "functions:alpha,functions:beta"] : []),
        ]);
      }
    }
  }
});


test("dev completion is published after the whole promoter and never advances the production cursor", () => {
  const delivery = workflow("delivery.yml");
  const finalizer = ciJob(delivery, "finalize-dev");
  assert.match(finalizer, /needs: \[authorize, dev\]/);
  assert.match(finalizer, /needs\.authorize\.result == 'success'/);
  assert.match(finalizer, /outputs\.environment == 'dev'/);
  assert.match(finalizer, /outputs\.deploy_required == 'false' \|\| needs\.dev\.result == 'success'/);
  assert.match(finalizer, /test "\$GITHUB_RUN_ATTEMPT" = "1"/);
  assert.match(finalizer, /\.deliveryRunId == \$run and \.deliveryRunAttempt == \$attempt/);
  assert.match(finalizer, /\.sourceSha == \$sha and \.sourceCiRunId == \$run and \.sourceCiRunAttempt == \$attempt/);
  assert.match(finalizer, /backend_delivery_lanes\.mjs prepare-receipt/);
  assert.match(finalizer, /--dev-result "\$DEV_RESULT"/);
  assert.match(finalizer, /--bootstrap "\$BOOTSTRAP"/);
  assert.match(finalizer, /name: \$\{\{ steps\.completion\.outputs\.dev_completion_artifact_name \}\}/);
  assert.doesNotMatch(finalizer, /backend-delivery-cursor-v4-|overwrite: true|continue-on-error/);
  assert.ok(finalizer.indexOf("Upload the immutable completed dev receipt") < finalizer.indexOf("Wake both ordered delivery lanes"));
  assert.match(finalizer, /for environment in dev prod/);
  assert.match(ciJob(delivery, "finalize"), /outputs\.environment == 'prod'/);
});

test("production independently rejects absent or different dev proof before cloud credentials", () => {
  const promotion = workflow("_firebase-promote.yml");
  const proof = promotion.slice(
    promotion.indexOf("      - name: Independently verify exact dev completion"),
    promotion.indexOf("      - name: Recompute automatic production eligibility"),
  );
  assert.match(proof, /inputs\.environment == 'prod'/);
  assert.match(proof, /delivery\.yml@refs\/heads\/main/);
  assert.match(proof, /DEV_COMPLETION_ARTIFACT_ID.*\^\[1-9\]/);
  assert.match(proof, /backend_delivery_lanes\.mjs verify-artifact/);
  assert.match(proof, /backend_delivery_lanes\.mjs verify-package/);
  for (const flag of ["artifact-id", "artifact-digest", "source-sha", "ci-run-id", "ci-run-attempt", "base-sha", "package", "provenance"]) {
    assert.ok(proof.includes(`--${flag} `), flag);
  }
  assert.ok(promotion.indexOf(proof) < promotion.indexOf("      - name: Authenticate to Google Cloud"));
  assert.doesNotMatch(proof, /continue-on-error|\|\| true/);
});

test("rebaseline structurally excludes both lane selectors through snapshot completion", () => {
  const caller = workflow("backend-rebaseline.yml");
  const worker = workflow("_backend-rebaseline.yml");
  assert.match(caller, /concurrency:\n  group: backend-delivery\n/);
  const snapshot = ciJob(caller, "snapshot");
  assert.match(snapshot, /concurrency:\n      group: backend-delivery-dev\n/);
  assert.match(snapshot, /uses: \.\/\.github\/workflows\/_backend-rebaseline\.yml/);
  assert.match(snapshot, /secrets: inherit/);
  for (const input of ["source_sha", "reason", "confirm_full_backend_rebaseline"]) {
    assert.ok(snapshot.includes(`${input}: \${{ inputs.${input} }}`));
  }
  assert.match(worker, /workflow_call:/);
  assert.doesNotMatch(worker, /workflow_dispatch:|repository_dispatch:|workflow_run:|group: backend-delivery/);
});

test("rebaseline caller permits the finalizer's existing repository dispatch", () => {
  const caller = workflow("backend-rebaseline.yml");
  const worker = workflow("_backend-rebaseline.yml");
  const snapshot = ciJob(caller, "snapshot");
  const finalizer = ciJob(worker, "finalize");
  const permissions = (source, indent) => {
    const block = source.match(new RegExp(`^${" ".repeat(indent)}permissions:\\n((?:${" ".repeat(indent + 2)}[^\\n]+\\n)+)`, "m"));
    return Object.fromEntries([...(block?.[1] ?? "").matchAll(/([a-z-]+): (none|read|write)/g)]
      .map(([, name, level]) => [name, {none: 0, read: 1, write: 2}[level]]));
  };
  const allowed = /\n    permissions:\n/.test(snapshot)
    ? permissions(snapshot, 4) : permissions(caller, 0);
  for (const [scope, level] of Object.entries(permissions(finalizer, 4))) {
    assert.ok((allowed[scope] ?? 0) >= level, `Caller denies finalizer ${scope}`);
  }
  assert.match(finalizer, /gh api --method POST[\s\S]*dispatches/);
  assert.equal(permissions(worker, 0).contents, 1, "Other worker jobs remain read-only by default");
});

test("cutover refresh and peer wakeups are bounded and manual recovery cannot silently disappear", () => {
  const delivery = workflow("delivery.yml");
  const authorize = ciJob(delivery, "authorize");
  const wake = ciJob(delivery, "wake-peer");
  assert.match(authorize, /lane_refresh_required: \$\{\{ steps\.lane\.outputs\.refresh_required \}\}/);
  assert.match(authorize, /client_payload\.wakeup_reason[\s\S]*== "refresh"[\s\S]*production cursor changed again[\s\S]*exit 1/);
  assert.match(authorize, /GITHUB_EVENT_NAME.*workflow_dispatch.*\.waiting[\s\S]*Manual recovery is blocked[\s\S]*exit 1/);
  assert.match(authorize, /Production recovery requires.*dev|dev completion.*recover/i);
  assert.match(wake, /github\.event\.client_payload\.wakeup_reason != 'peer'/);
  assert.match(wake, /lane_refresh_required == 'true' && 'dev'/);
  assert.match(wake, /lane_refresh_required == 'true' && 'refresh' \|\| 'peer'/);
  assert.match(wake, /wakeup_reason: \$reason/);
  assert.match(authorize, /name: backend-dev-input-/);
  assert.doesNotMatch(authorize, /name: backend-dev-completion-input-/);
});


test("real cursor and recovery identity commands accept custom titles and reject foreign producers", () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-workflow-identity-"));
  try {
    fs.mkdirSync(path.join(directory, "tool/ci"), {recursive: true});
    fs.copyFileSync(path.join(repoRoot, "tool/ci/backend_delivery_lanes.mjs"), path.join(directory, "tool/ci/backend_delivery_lanes.mjs"));
    const bin = path.join(directory, "bin");
    fs.mkdirSync(bin);
    fs.writeFileSync(path.join(bin, "gh"), `#!${process.execPath}
const fs = require("node:fs");
const endpoint = process.argv.at(-1);
const input = JSON.parse(fs.readFileSync(process.env.IDENTITY_FIXTURE, "utf8"));
if (process.argv[2] !== "api" || !Object.hasOwn(input, endpoint)) process.exit(64);
process.stdout.write(JSON.stringify(input[endpoint]));
`, {mode: 0o755});
    const scripts = ["delivery.yml", "_backend-rebaseline.yml", "_firebase-promote.yml"].flatMap((file) => {
      const source = workflow(file);
      return [...source.matchAll(/node tool\/ci\/backend_delivery_lanes\.mjs verify-run \\\n[\s\S]*?--role (cursor|delivery|selective) --output ([^\n]+)/g)].map((match) => {
        let script = match[0];
        if (match[1] === "delivery" || match[1] === "selective") {
          const following = source.slice(match.index + match[0].length);
          const jqStart = following.indexOf("jq -e '");
          script += `\n${following.slice(jqStart, following.indexOf("> /dev/null", jqStart) + "> /dev/null".length)}`;
        }
        return {file, role: match[1], output: match[2], script};
      });
    });
    assert.equal(scripts.length, 5);
    const rebaseline = workflow("_backend-rebaseline.yml");
    const authorize = ciJob(rebaseline, "authorize");
    assert.ok(authorize.indexOf("actions/setup-node@v6") < authorize.indexOf("      - id: cursor"));
    assert.match(authorize, /node-version: \$\{\{ steps\.authorization-toolchain\.outputs\.node-version \}\}/);

    const repo = {id: 42, full_name: "owner/catch"};
    for (const {file, role, output, script} of scripts) {
      const producerWorkflow = role === "selective" ? "selective-backend-release.yml" : "delivery.yml";
      const producerWorkflowId = role === "selective" ? 90 : 88;
      const run = {id: 900, run_attempt: 1, workflow_id: producerWorkflowId, path: `.github/workflows/${producerWorkflow}`,
        name: "Delivery lane v1 dev", repository: repo, head_repository: repo, head_branch: "main",
        event: role === "selective" ? "workflow_dispatch" : "workflow_run",
        status: "completed", conclusion: "failure"};
      const execute = (patch = {}, workflowPatch = {}) => {
        fs.rmSync(path.join(directory, output), {force: true});
        const current = {...run, ...patch};
        const fixture = {
          "repos/owner/catch/actions/runs/900/attempts/1": current,
          "repos/owner/catch/actions/workflows/delivery.yml": {id: 88, path: ".github/workflows/delivery.yml",
            ...(role === "selective" ? {} : workflowPatch)},
          "repos/owner/catch/actions/workflows/selective-backend-release.yml": {id: 90,
            path: ".github/workflows/selective-backend-release.yml", ...(role === "selective" ? workflowPatch : {})},
          "repos/owner/catch/actions/workflows/backend-rebaseline.yml": {id: 89, path: ".github/workflows/backend-rebaseline.yml"},
        };
        const fixtureFile = path.join(directory, "fixture.json");
        fs.writeFileSync(fixtureFile, JSON.stringify(fixture));
        return spawnSync("bash", ["-euo", "pipefail", "-c", script], {cwd: directory, encoding: "utf8", env: {...process.env,
          PATH: `${bin}${path.delimiter}${process.env.PATH}`, IDENTITY_FIXTURE: fixtureFile,
          GITHUB_REPOSITORY: "owner/catch", REPOSITORY_ID: "42", cursor_delivery_run_id: "900", cursor_delivery_run_attempt: "1",
          delivery_run_id: "900", delivery_run_attempt: "1", RESUME_DELIVERY_RUN_ID: "900", RESUME_DELIVERY_ATTEMPT: "1",
          restore_run_id: "900", restore_attempt: "1"}});
      };
      for (const name of ["Delivery", "backend-delivery-drain", "Delivery lane v1 dev", "Delivery lane v1 prod"]) {
        const result = execute({name, display_title: name});
        assert.equal(result.status, 0, `${file}/${name}: ${result.stderr}`);
      }
      for (const patch of [{workflow_id: 99}, {id: 901}, {run_attempt: 2}, {head_branch: "feature"},
        {head_repository: {...repo, id: 99}}, {repository: {...repo, full_name: "foreign/catch"}}, {path: ".github/workflows/other.yml"}]) {
        const result = execute(patch);
        assert.notEqual(result.status, 0, `${file}: rejected identity ${JSON.stringify(patch)}`);
        assert.equal(fs.existsSync(path.join(directory, output)), false, "Failed identity must not publish verified output.");
      }
      assert.notEqual(execute({}, {id: 99}).status, 0);
      if (role === "selective") assert.notEqual(execute({event: "workflow_run"}).status, 0);
      assert.equal(execute({path: ".github/workflows/backend-rebaseline.yml", workflow_id: 89}).status, role === "cursor" ? 0 : 1);
      assert.equal(execute({status: "in_progress", conclusion: null}).status === 0, role === "cursor");
      assert.equal(execute({status: "completed", conclusion: "success"}).status === 0, role === "cursor");
    }
  } finally {
    fs.rmSync(directory, {recursive: true, force: true});
  }
});


test("Functions param coverage checks the approved source and deploy copy before any mutation", (t) => {
  const promotion = workflow("_firebase-promote.yml");
  const name = "Gate Functions param coverage before any deploy mutation";
  const gate = extractSteps(promotion).find((step) => step.name === name);
  assert.ok(gate?.run);
  const offset = promotion.indexOf(name);
  assert.ok(promotion.indexOf("Materialize non-secret Functions params") < offset);
  assert.ok(offset < promotion.indexOf("Preflight the whole backend plan"));
  assert.ok(offset < promotion.indexOf("Resume ordered backend stages"));
  assert.match(gate.run, /--functions-dir build\/delivery\/source-checkout\/functions/);
  assert.match(gate.run, /--env-file "\$functions_dir\/\.env\.\$PROJECT_ID"/);
  assert.match(workflow("functions-ci.yml"), /node tool\/run\.mjs check firebase:params-coverage/);
  for (const flag of ["EVENT_ASSISTANCE_RCS_ENABLED", "EVENT_ASSISTANCE_RCS_WEBHOOK_ENABLED", "EVENT_ASSISTANCE_SMS_REPORTS_ENABLED"]) {
    assert.ok(promotion.includes(`${flag}: \${{ vars.${flag} }}`));
  }
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-param-workflow-"));
  t.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  fs.mkdirSync(path.join(directory, "tool/firebase"), {recursive: true});
  fs.symlinkSync(path.join(repoRoot, "tool/lib"), path.join(directory, "tool/lib"));
  fs.symlinkSync(path.join(repoRoot, "tool/firebase/prepare_functions_params_for_deploy.mjs"),
    path.join(directory, "tool/firebase/prepare_functions_params_for_deploy.mjs"));
  fs.copyFileSync(path.join(repoRoot, "tool/firebase/check_functions_params_coverage.mjs"),
    path.join(directory, "tool/firebase/check_functions_params_coverage.mjs"));
  const sourceDir = path.join(directory, "build/delivery/source-checkout/functions/src");
  const deployDir = path.join(directory, "build/delivery/deploy-tree/functions");
  fs.mkdirSync(sourceDir, {recursive: true});
  fs.mkdirSync(deployDir, {recursive: true});
  fs.writeFileSync(path.join(sourceDir, "params.ts"),
    'const flag = defineBoolean("EVENT_ASSISTANCE_RCS_ENABLED", {default: false});\n');
  const sentinel = path.join(directory, "mutation");
  for (const [value, success] of [[null, false], ["", false], ['EVENT_ASSISTANCE_RCS_ENABLED="false"\n', true]]) {
    fs.rmSync(sentinel, {force: true});
    const envFile = path.join(deployDir, ".env.demo-project");
    if (value === null) fs.rmSync(envFile, {force: true});
    else fs.writeFileSync(envFile, value);
    const result = spawnSync("bash", ["-euo", "pipefail", "-c", gate.run + '\ntouch "$SENTINEL"'], {
      cwd: directory, encoding: "utf8", env: {...process.env, PROJECT_ID: "demo-project", SENTINEL: sentinel},
    });
    assert.equal(result.status === 0, success, result.stderr);
    assert.equal(fs.existsSync(sentinel), success);
  }
  fs.rmSync(deployDir, {recursive: true});
  const absent = spawnSync("bash", ["-euo", "pipefail", "-c", gate.run], {
    cwd: directory, encoding: "utf8", env: {...process.env, PROJECT_ID: "demo-project"},
  });
  assert.equal(absent.status, 0, absent.stderr);
  assert.match(absent.stdout, /no Functions payload/);
});

test("Functions retries stop on missing params or secrets and retain transient retries", (t) => {
  const executor = fs.readFileSync(path.join(repoRoot, "tool/deploy_firebase_targets.sh"), "utf8");
  const body = executor.slice(executor.lastIndexOf("while IFS=$'\\t' read -r phase deploy_only; do"));
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-param-retry-"));
  t.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  const calls = path.join(directory, "calls");
  const sleepCalls = path.join(directory, "sleeps");
  const prelude = `
    deploy_target() { echo called >> "$CALLS"; echo "$DEPLOY_ERROR"; return "$DEPLOY_STATUS"; }
    sleep() { echo "$1" >> "$SLEEPS"; }
    plan_output=$'functions\\tfunctions:alpha'
    function_batches=functions:alpha
    functions_mode=deploy
  `;
  const cases = [
    ["In non-interactive mode but have no value for the following environment variables: MISSING", "1", 1, 0],
    ["In non-interactive mode but have no value for the secret: MISSING", "1", 1, 0],
    ["Temporary quota limit", "1", 3, 2],
    ["Deployed", "0", 1, 1],
  ];
  for (const [message, status, attempts, sleeps] of cases) {
    fs.rmSync(calls, {force: true});
    fs.rmSync(sleepCalls, {force: true});
    const result = spawnSync("bash", ["-euo", "pipefail", "-c", prelude + body], {
      encoding: "utf8", env: {...process.env, TMPDIR: directory, CALLS: calls, SLEEPS: sleepCalls,
        DEPLOY_ERROR: message, DEPLOY_STATUS: status},
    });
    assert.equal(result.status, Number(status), result.stderr);
    assert.equal(fs.readFileSync(calls, "utf8").trim().split("\n").length, attempts);
    assert.equal(fs.existsSync(sleepCalls) ? fs.readFileSync(sleepCalls, "utf8").trim().split("\n").length : 0, sleeps);
    assert.match(result.stdout, new RegExp(message));
    assert.deepEqual(fs.readdirSync(directory).filter((name) => name.startsWith("catch-functions-deploy.")), []);
  }
});
