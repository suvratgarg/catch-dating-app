import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import test from "node:test";
import {fileURLToPath} from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const workflow = (name) => fs.readFileSync(
  path.join(repoRoot, ".github/workflows", name),
  "utf8",
);

test("main CI serializes planning and re-covers every failed validation window", () => {
  const ci = workflow("ci.yml");
  assert.match(ci, /group: ci-\$\{\{ github\.event_name \}\}-\$\{\{[\s\S]*github\.event_name == 'push'[\s\S]*github\.run_id/);
  assert.match(ci, /cancel-in-progress: \$\{\{ github\.event_name != 'push' \}\}/);
  assert.match(ci, /permissions:[\s\S]*actions: read[\s\S]*contents: read/);
  assert.match(ci, /timeout-minutes: 180/);
  assert.match(ci, /active_pages="\$\(gh api --paginate --slurp[\s\S]*event=push&per_page=100/);
  assert.match(ci, /\.run_number < \$current_run[\s\S]*\.status != "completed"/);
  assert.match(ci, /Waiting for \$lower_active lower-numbered active main CI run/);
  assert.match(ci, /successful_pages="\$\(gh api --paginate --slurp[\s\S]*status=success[\s\S]*max_by\(\.run_number\)/);
  assert.match(ci, /base_sha="\$\(jq -er '\.head_sha' <<< "\$prior_success"\)"/);
  assert.match(ci, /No prior successful main CI run exists; using the push before SHA/);
  assert.match(ci, /git merge-base --is-ancestor "\$base_sha" "\$HEAD_SHA"/);
  assert.match(ci, /baseSha: \$baseSha,[\s\S]*sourceSha: \$sourceSha,[\s\S]*sourceCiRunId: \$sourceCiRunId,[\s\S]*sourceCiRunAttempt: \$sourceCiRunAttempt/);
});

test("a successful main CI attempt must own its exact planner and backend artifacts", () => {
  const ci = workflow("ci.yml");
  const required = ci.slice(ci.indexOf("  required:"));
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
  assert.equal((delivery.match(/control_plane_sha: \$\{\{ github\.workflow_sha \}\}/g) ?? []).length, 3);

  assert.match(promotion, /control_plane_sha:[\s\S]*required: true/);
  assert.match(promotion, /name: Checkout the immutable Delivery control plane[\s\S]*ref: \$\{\{ inputs\.control_plane_sha \}\}/);
  assert.match(promotion, /name: Checkout the exact CI-approved source as verification input[\s\S]*path: build\/delivery\/source-checkout/);
  assert.match(promotion, /test "\$control_project_id" = "\$project_id"/);
  assert.equal((promotion.match(/--source-root build\/delivery\/source-checkout/g) ?? []).length, 3);
  assert.match(promotion, /CATCH_FIREBASE_SOURCE_ROOT="\$SOURCE_CHECKOUT"/);
  assert.match(promotion, /\.\/tool\/deploy_firebase_targets\.sh/);
  assert.doesNotMatch(promotion, /build\/delivery\/source-checkout\/tool\/deploy_firebase_targets\.sh/);
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
  assert.match(delivery, /group: backend-delivery\n/);
  assert.doesNotMatch(delivery, /group: backend-delivery-\$\{\{/);
  assert.match(delivery, /It is not the queue:[\s\S]*cursor makes replacement safe/);
});

test("Delivery selects one cursor and the oldest pending authority with bounded API work", () => {
  const delivery = workflow("delivery.yml");
  assert.match(delivery, /repository_dispatch:[\s\S]*types: \[backend-delivery-drain\]/);
  assert.equal((delivery.match(/actions\/artifacts\?per_page=100/g) ?? []).length, 1);
  const cursor = delivery.slice(delivery.indexOf("      - id: cursor"), delivery.indexOf("      - id: source"));
  const source = delivery.slice(delivery.indexOf("      - id: source"), delivery.indexOf("      - name: Checkout the exact CI-approved source"));
  assert.match(cursor, /actions\/workflows\/ci\.yml/);
  assert.match(cursor, /\^backend-delivery-cursor-v4-/);
  assert.match(cursor, /actions\/artifacts\/\$cursor_artifact_id\/zip/);
  assert.match(cursor, /actions\/runs\/\$cursor_delivery_run_id\/attempts\/\$cursor_delivery_run_attempt/);
  assert.match(cursor, /catch\.backend-delivery-cursor\/v4/);
  assert.match(cursor, /sourceCiWorkflowId/);
  assert.match(cursor, /cursor_ambiguity_count/);
  assert.match(cursor, /different or legacy CI workflow generation/);
  assert.match(cursor, /sha256:\$\(sha256sum "\$cursor_dir\/cursor\.zip"/);
  assert.doesNotMatch(cursor.slice(0, cursor.indexOf("historical_delivery=")), /\.conclusion == "success"/);
  assert.doesNotMatch(cursor, /gh run download/);
  assert.match(delivery, /actions\/runs\/\$cursor_run_id\/attempts\/\$cursor_run_attempt/);
  assert.match(delivery, /\.run_attempt == \$run_attempt[\s\S]*\.run_number == \$run_number/);
  assert.match(source, /\^harness-success-v3-/);
  assert.match(source, /actions\/artifacts\/\$authority_artifact_id\/zip/);
  assert.match(source, /catch\.ci-delivery-authority\/v3/);
  assert.match(source, /source_ambiguity_count/);
  assert.match(source, /group_by\(\.sourceCiRunNumber\)[\s\S]*sourceCiRunAttempt \| tonumber[\s\S]*min_by\(\.sourceCiRunNumber\)/);
  assert.match(source, /actions\/runs\/\$source_ci_run_id\/attempts\/\$source_ci_run_attempt/);
  assert.match(source, /\.workflow_id == \$workflow_id[\s\S]*\.status == "completed"[\s\S]*\.conclusion == "success"/);
  assert.match(source, /planArtifact[\s\S]*packageArtifact[\s\S]*digest/);
  assert.doesNotMatch(cursor, /while\s/);
  assert.doesNotMatch(source.slice(0, source.indexOf('if [[ "$EVENT_NAME" == "workflow_dispatch" ]]')), /while\s/);
  assert.doesNotMatch(delivery, /actions\/workflows\/ci\.yml\/runs/);
  assert.match(delivery, /Bootstrapping from the oldest successful immutable CI authority in the current workflow generation/);
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
    cursor.indexOf("historical_delivery="),
    cursor.indexOf("cursor_source_run="),
  );

  assert.match(originAttempt, /actions\/runs\/\$cursor_delivery_run_id\/attempts\/\$cursor_delivery_run_attempt/);
  assert.match(originAttempt, /\.run_attempt == \$delivery_run_attempt/);
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

  const boundedSelection = delivery.slice(
    delivery.indexOf("      - id: cursor"),
    delivery.indexOf('            failed_delivery="$(gh api'),
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
  assert.match(delivery, /actions\/runs\/\$RESUME_DELIVERY_RUN_ID\/attempts\/\$RESUME_DELIVERY_ATTEMPT/);
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

test("promotion is ordered dev to staging to protected prod", () => {
  const delivery = workflow("delivery.yml");
  assert.match(delivery, /dev:[\s\S]*environment: dev/);
  assert.match(delivery, /staging:[\s\S]*needs: \[authorize, dev\][\s\S]*environment: staging/);
  assert.match(delivery, /prod:[\s\S]*needs: \[authorize, staging\][\s\S]*environment: prod/);

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
  assert.equal((promotion.match(/--scope "\$CHECKPOINT_SCOPE"/g) ?? []).length, 3);
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
  assert.doesNotMatch(promotion, /npm (?:--prefix \S+ )?(?:test|run lint|run build)|emulators:exec/);
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
    /Reverify every authored byte immediately before deployment[\s\S]*sanitize_firestore_indexes_for_deploy\.mjs[\s\S]*Resume ordered backend stages/,
  );
  assert.match(
    promotion,
    /--indexes build\/delivery\/deploy-tree\/firestore\.indexes\.json[\s\S]*--current-indexes firestore\.indexes\.json/,
  );
  assert.doesNotMatch(
    promotion,
    /--indexes build\/delivery\/package\/firestore\.indexes\.json/,
  );
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
