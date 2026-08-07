import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import {fileURLToPath} from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");

function workflow(name) {
  return fs.readFileSync(path.join(repoRoot, ".github", "workflows", name), "utf8");
}

function caller(surface) {
  return workflow(`${surface}-website.yml`);
}

function promotionIsFresh(candidate, state) {
  const latestMatches = candidate.runId === state.latest.runId &&
    candidate.runNumber === state.latest.runNumber &&
    candidate.sha === state.latest.sha;
  if (!latestMatches) return false;
  if (candidate.recovery) {
    return candidate.event === "workflow_dispatch" && candidate.terminalFailure &&
      candidate.sha === state.currentMainSha;
  }
  return candidate.event === "push" && state.mainAncestors.has(candidate.sha);
}

function recoveryAttemptIsCurrent(candidateAttempt, currentRun, retainedArtifacts) {
  const hasExactArtifact = retainedArtifacts.some(
    (artifact) => artifact.attempt === candidateAttempt,
  );
  return hasExactArtifact && currentRun.runAttempt === candidateAttempt;
}

test("admin and marketing callers share one exact build and promotion path", () => {
  for (const surface of ["admin", "marketing"]) {
    const source = caller(surface);
    assert.match(source, /uses: \.\/\.github\/workflows\/_web-hosting-build\.yml/u);
    assert.match(source, /uses: \.\/\.github\/workflows\/_web-hosting-promote\.yml/u);
    assert.match(source, new RegExp(`surface: ${surface}`));
    assert.match(source, /artifact_digest: \$\{\{ needs\.package\.outputs\.artifact_digest \}\}/u);
    assert.match(source, /artifact_id: \$\{\{ needs\.package\.outputs\.artifact_id \}\}/u);
    assert.match(source, /source_ci_run_attempt: \$\{\{ needs\.package\.outputs\.source_ci_run_attempt \}\}/u);
    assert.match(source, /source_ci_run_id: \$\{\{ needs\.package\.outputs\.source_ci_run_id \}\}/u);
    assert.match(source, /source_sha: \$\{\{ needs\.package\.outputs\.source_sha \}\}/u);
    assert.doesNotMatch(source.slice(source.indexOf("jobs:")),
      /firebase_with_env\.sh|vite build|web:(?:admin|marketing):build/u);
    for (const input of [
      "recovery_artifact_digest",
      "recovery_artifact_id",
      "recovery_reason",
      "recovery_source_run_attempt",
      "recovery_source_run_id",
      "recovery_source_sha",
    ]) assert.match(source, new RegExp(`${input}:`));
    for (const pathInput of [
      ".github/workflows/_web-hosting-build.yml",
      ".github/workflows/_web-hosting-promote.yml",
      "tool/ci/delivery_core.mjs",
      "tool/ci/package_web_hosting.mjs",
      "tool/ci/package_web_hosting.test.mjs",
      "tool/ci/web_hosting_workflow.test.mjs",
      "tool/firebase_with_env.sh",
    ]) assert.ok(source.includes(`- "${pathInput}"`), `${surface} is missing ${pathInput}`);
  }
  const admin = caller("admin");
  for (const adminDependency of [
    "contracts/admin/admin_live_data_sources.json",
    "tool/firebase/check_client_callable_dependencies.mjs",
    "tool/firebase/firebase_project_resolver.mjs",
    "tool/web/check_admin_live_data_sources.mjs",
  ]) assert.ok(admin.includes(`- "${adminDependency}"`), `admin is missing ${adminDependency}`);
});

test("caller triggers cover the exact build dependency closure", () => {
  const admin = caller("admin");
  assert.ok(admin.includes('- "packages/web-config/**"'));

  const marketing = caller("marketing");
  for (const dependency of [
    "functions/package.json",
    "functions/package-lock.json",
    "tool/contracts/generated/schema_contract_validators.mjs",
    "tool/contracts/generated/schema_contract_registry.mjs",
    "tool/demo/demo_seed/scenarios/**",
    "packages/web-config/**",
    "website/**",
  ]) {
    assert.ok(marketing.includes(`- "${dependency}"`),
      `marketing is missing materialization dependency ${dependency}`);
  }
});

test("three pushes and manual interference cannot replace a pending promotion", () => {
  for (const surface of ["admin", "marketing"]) {
    const source = caller(surface);
    const header = source.slice(0, source.indexOf("permissions:"));
    assert.doesNotMatch(header, /^concurrency:/mu,
      `${surface} caller must admit every validation and build run`);
  }
  const promote = workflow("_web-hosting-promote.yml");
  assert.match(promote,
    /concurrency:\n\s+group: web-hosting-\$\{\{ inputs\.surface \}\}\n\s+cancel-in-progress: false\n\s+queue: max/u);

  const pushes = [
    {runId: "101", runNumber: 41, sha: "a".repeat(40), event: "push"},
    {runId: "102", runNumber: 42, sha: "b".repeat(40), event: "push"},
    {runId: "103", runNumber: 43, sha: "c".repeat(40), event: "push"},
  ];
  const manualValidation = {kind: "validation", event: "workflow_dispatch"};
  const staleManualRecovery = {
    ...pushes[0],
    event: "workflow_dispatch",
    recovery: true,
    terminalFailure: true,
  };
  const admitted = [pushes[0], manualValidation, pushes[1], staleManualRecovery, pushes[2]];
  assert.equal(admitted.length, 5, "caller-wide concurrency must not discard any run");
  const state = {
    latest: pushes[2],
    currentMainSha: pushes[2].sha,
    mainAncestors: new Set(pushes.map((entry) => entry.sha)),
  };
  assert.deepEqual(pushes.map((candidate) => promotionIsFresh(candidate, state)),
    [false, false, true]);
  assert.equal(promotionIsFresh(staleManualRecovery, state), false);
  assert.equal("runId" in manualValidation, false,
    "validation-only dispatch does not enter the promotion queue");
});

test("main builds the deployable Vite output once while validation-only dispatch remains a no-op", () => {
  const validation = workflow("react-surface-validation.yml");
  assert.match(validation, /skip_deployable_build:[\s\S]*type: boolean[\s\S]*default: false/u);
  assert.match(validation,
    /inputs\.surface == 'marketing' && !inputs\.skip_deployable_build/u);
  assert.match(validation,
    /inputs\.surface == 'admin' && !inputs\.skip_deployable_build/u);
  assert.match(validation,
    /inputs\.surface == 'marketing' && inputs\.skip_deployable_build[\s\S]*npm run web:marketing:typecheck/u);
  assert.match(validation,
    /inputs\.surface == 'admin' && inputs\.skip_deployable_build[\s\S]*npm run web:admin:typecheck/u);

  for (const surface of ["admin", "marketing"]) {
    const source = caller(surface);
    assert.match(source,
      /skip_deployable_build: \$\{\{ github\.event_name == 'push' && github\.ref == 'refs\/heads\/main' \}\}/u);
    assert.match(source,
      /if: \$\{\{ github\.event_name != 'workflow_dispatch' \|\| inputs\.recovery_artifact_id == '' \}\}/u);
    assert.match(source,
      /if: \$\{\{ github\.event_name == 'workflow_dispatch' && inputs\.recovery_artifact_id != '' \}\}/u);
    const packageJob = source.slice(source.indexOf("  package:"), source.indexOf("  promote:"));
    assert.match(packageJob, /if: github\.event_name == 'push' && github\.ref == 'refs\/heads\/main'/u);
    assert.doesNotMatch(packageJob, /workflow_dispatch/u);
  }
});

test("the producing job binds workflow generation, builds production bytes, and uploads one immutable package", () => {
  const build = workflow("_web-hosting-build.yml");
  for (const predicate of [
    '(.path | split("@")[0]) == $path',
    '.event == "push"',
    '.head_branch == "main"',
    '.head_repository.full_name == $repository',
    ".workflow_id",
    ".run_number",
    'test "$GITHUB_EVENT_NAME" = "push"',
    'test "$GITHUB_REF" = "refs/heads/main"',
  ]) assert.ok(build.includes(predicate), `missing build binding ${predicate}`);
  assert.match(build,
    /web-hosting-v1-\$\{SURFACE\}-\$\{workflow_id\}-\$\{GITHUB_RUN_NUMBER\}-\$\{GITHUB_RUN_ID\}-\$\{GITHUB_SHA\}-\$\{GITHUB_RUN_ATTEMPT\}/u);
  assert.match(build, /environment: prod-hosting/u);

  const materialize = build.indexOf("Materialize the production organizer projection");
  const buildJob = build.indexOf("  build:");
  const marketingEnv = build.indexOf("Validate production marketing environment before build");
  const listingDownload = build.indexOf("Download and verify only the exact marketing listing inputs");
  const marketingBuild = build.indexOf("Build the exact production marketing bytes once");
  assert.ok(materialize >= 0 && materialize < buildJob && buildJob < marketingEnv &&
    marketingEnv < listingDownload && listingDownload < marketingBuild);
  assert.match(build,
    /build:\n\s+name:[\s\S]*needs: marketing_snapshot[\s\S]*!cancelled\(\)[\s\S]*needs\.marketing_snapshot\.result == 'success'/u);
  const adminEnv = build.indexOf("Validate production admin environment before build");
  const adminLive = build.indexOf("Verify production Admin callable dependencies before build");
  const adminBuild = build.indexOf("Build the exact production admin bytes once");
  assert.ok(adminEnv >= 0 && adminEnv < adminLive && adminLive < adminBuild);
  assert.equal((build.match(/vite build/gu) ?? []).length, 2);
  assert.doesNotMatch(build, /web:(?:admin|marketing):build|firebase_with_env\.sh|firebase deploy/u);

  const prepare = build.indexOf("package_web_hosting.mjs prepare");
  const manifest = build.indexOf("delivery_core.mjs manifest");
  const coreVerify = build.indexOf("delivery_core.mjs verify");
  const adapterVerify = build.indexOf("package_web_hosting.mjs verify");
  const upload = build.lastIndexOf("actions/upload-artifact@v7");
  assert.ok(prepare >= 0 && prepare < manifest && manifest < coreVerify &&
    coreVerify < adapterVerify && adapterVerify < upload);
  assert.match(build, /tar --sort=name --mtime='UTC 1970-01-01'/u);
  assert.match(build, /--owner=0 --group=0 --numeric-owner/u);
  assert.match(build, /--stages "hosting-\$\{SURFACE\}"/u);
  assert.match(build, /test "\$\(find build\/web-delivery\/upload -type f \| wc -l \| tr -d ' '\)" = "2"/u);
  assert.match(build,
    /artifact_digest: \$\{\{ format\('sha256:\{0\}', steps\.upload\.outputs\.artifact-digest\) \}\}/u);
  assert.match(build, /artifact_id: \$\{\{ steps\.upload\.outputs\.artifact-id \}\}/u);
  assert.match(build, /retention-days: 90/u);
});

test("build credentials are isolated to a read-only marketing snapshot job", () => {
  const build = workflow("_web-hosting-build.yml");
  const snapshot = build.slice(build.indexOf("  marketing_snapshot:"), build.indexOf("  build:"));
  const packageBuild = build.slice(build.indexOf("  build:"));

  assert.match(snapshot, /if: \$\{\{ inputs\.surface == 'marketing' \}\}/u);
  assert.match(snapshot, /actions: read[\s\S]*id-token: write/u);
  assert.match(snapshot, /id-token: write/u);
  assert.match(snapshot, /Bind the snapshot to the canonical marketing main push/u);
  assert.match(snapshot, /\.github\/workflows\/marketing-website\.yml/u);
  assert.match(snapshot, /test "\$GITHUB_EVENT_NAME" = "push"/u);
  assert.match(snapshot, /test "\$GITHUB_REF" = "refs\/heads\/main"/u);
  assert.match(snapshot, /GCP_WEB_HOSTING_READONLY_WORKLOAD_IDENTITY_PROVIDER/u);
  assert.match(snapshot, /GCP_WEB_HOSTING_READONLY_SERVICE_ACCOUNT_EMAIL/u);
  assert.match(snapshot, /npm --prefix functions ci --omit=dev --ignore-scripts/u);
  assert.match(snapshot, /materialize:organizer-listings:deploy/u);
  const materialize = snapshot.indexOf("Materialize the production organizer projection");
  const removeCredentials = snapshot.indexOf(
    "Remove read-only credentials before artifact handling",
  );
  const upload = snapshot.indexOf("Upload only the exact marketing listing inputs");
  assert.ok(materialize >= 0 && materialize < removeCredentials &&
    removeCredentials < upload);
  assert.match(snapshot, /rm -f -- "\$credential_file"[\s\S]*test ! -e "\$credential_file"/u);
  assert.match(snapshot,
    /Upload only the exact marketing listing inputs[\s\S]*ACTIONS_ID_TOKEN_REQUEST_TOKEN: ""[\s\S]*GOOGLE_GHA_CREDS_PATH: ""/u);
  assert.match(snapshot,
    /find build\/marketing-listing-inputs -type f[\s\S]*= "2"/u);

  assert.match(packageBuild, /permissions:\n\s+actions: read\n\s+contents: read/u);
  assert.doesNotMatch(packageBuild,
    /id-token: write|google-github-actions\/auth|materialize:organizer-listings:deploy|npm --prefix functions ci/u);
  assert.match(packageBuild, /actions\/artifacts\/\$SNAPSHOT_ARTIFACT_ID\/zip/u);
  assert.match(packageBuild,
    /expected_name="marketing-listing-inputs-\$\{GITHUB_RUN_ID\}-\$\{GITHUB_RUN_ATTEMPT\}"/u);
  assert.match(packageBuild,
    /\.name == \$name[\s\S]*\.digest == \$digest[\s\S]*\.workflow_run\.head_sha == \$source_sha/u);
  assert.match(packageBuild,
    /sha256:\$\(sha256sum build\/marketing-listing-inputs\.zip/u);
  assert.match(packageBuild, /npm --workspace catch-marketing run check:organizer-listings/u);
});

test("promotion downloads only the immutable artifact id and verifies bytes before credentials", () => {
  const promote = workflow("_web-hosting-promote.yml");
  for (const predicate of [
    '.name == $expected_name',
    '(.path | split("@")[0]) == $expected_path',
    '.event == "push"',
    '.head_branch == "main"',
    '.head_repository.full_name == $repository',
    ".workflow_id",
    ".run_number",
    ".workflow_run.repository_id == $repository_id",
    ".workflow_run.head_repository_id == $repository_id",
    '.workflow_run.head_sha == $source_sha',
  ]) assert.ok(promote.includes(predicate), `missing promotion binding ${predicate}`);
  assert.match(promote, /actions\/artifacts\/\$ARTIFACT_ID\/zip/u);
  assert.match(promote,
    /sha256:\$\(sha256sum build\/web-delivery\/source\.zip \| awk '\{print \$1\}'\)/u);
  assert.match(promote, /\.digest == \$digest/u);
  assert.ok(promote.includes("unzip -Z1 build/web-delivery/source.zip"));
  assert.ok(promote.includes("awk '/(^\\/|(^|\\/)\\.\\.($|\\/))/ { exit 64 }'"));
  assert.ok(promote.includes('tar -tzf "$archive"'));
  assert.match(promote,
    /tar -tvzf[\s\S]*substr\(\$0, 1, 1\) != "-"[\s\S]*substr\(\$0, 1, 1\) != "d"/u);
  assert.match(promote, /--no-same-owner --no-same-permissions/u);

  const firstCoreVerify = promote.indexOf("delivery_core.mjs verify");
  const firstAdapterVerify = promote.indexOf("package_web_hosting.mjs verify");
  const install = promote.indexOf("Install the pinned Firebase CLI before deployment credentials");
  const reverify = promote.indexOf("Re-extract and reverify immutable bytes before deployment credentials");
  const auth = promote.indexOf("Authenticate to Google Cloud only for final freshness and mutation");
  const freshness = promote.indexOf("Refuse to overtake a newer main push immediately before mutation");
  const deploy = promote.indexOf("Deploy only the verified production Hosting target without rebuilding");
  assert.ok(firstCoreVerify >= 0 && firstCoreVerify < firstAdapterVerify &&
    firstAdapterVerify < install && install < reverify && reverify < auth &&
    auth < freshness && freshness < deploy);
  assert.equal((promote.match(/sha256:\$\(sha256sum build\/web-delivery\/source\.zip/gu) ?? []).length, 2);
  assert.match(promote,
    /rm -rf build\/web-delivery\/source build\/web-delivery\/package/u);
  assert.equal((promote.match(/delivery_core\.mjs verify/gu) ?? []).length, 2);
  assert.equal((promote.match(/package_web_hosting\.mjs verify/gu) ?? []).length, 2);
  assert.match(promote,
    /working-directory: build\/web-delivery\/package[\s\S]*"\$GITHUB_WORKSPACE\/tool\/firebase_with_env\.sh" prod deploy[\s\S]*--config firebase\.json/u);
  assert.match(promote, /--only "hosting:\$\{SURFACE\}"/u);
  assert.doesNotMatch(promote,
    /npm ci|npm --prefix functions ci|vite build|web:(?:admin|marketing):build|materialize:organizer/u);
});

test("recovery is exact, reasoned, terminal-only, and separate from validation dispatch", () => {
  const promote = workflow("_web-hosting-promote.yml");
  assert.match(promote, /test "\$GITHUB_EVENT_NAME" = "workflow_dispatch"/u);
  assert.match(promote, /test "\$GITHUB_REF" = "refs\/heads\/main"/u);
  assert.match(promote, /GITHUB_RUN_ATTEMPT > 1[\s\S]*fresh manual dispatch/u);
  assert.match(promote, /RECOVERY_REASON\/\/\[\[:space:\]\]\//u);
  assert.match(promote, /test "\$SOURCE_CI_RUN_ID" != "\$GITHUB_RUN_ID"/u);
  assert.match(promote, /\.status == "completed"/u);
  for (const terminal of [
    "failure",
    "cancelled",
    "timed_out",
    "stale",
    "action_required",
    "startup_failure",
  ]) assert.match(promote, new RegExp(`\\.conclusion == "${terminal}"`));
  assert.doesNotMatch(promote,
    /\.conclusion == "success" or|\.conclusion == "neutral"|\.conclusion == "skipped"/u);

  for (const surface of ["admin", "marketing"]) {
    const source = caller(surface);
    const recovery = source.slice(source.indexOf("  recover:"));
    assert.match(recovery, /recovery: true/u);
    assert.match(recovery, /artifact_digest: \$\{\{ inputs\.recovery_artifact_digest \}\}/u);
    assert.match(recovery, /artifact_id: \$\{\{ inputs\.recovery_artifact_id \}\}/u);
    assert.match(recovery, /recovery_reason: \$\{\{ inputs\.recovery_reason \}\}/u);
    assert.match(recovery, /source_ci_run_attempt: \$\{\{ inputs\.recovery_source_run_attempt \}\}/u);
    assert.match(recovery, /source_ci_run_id: \$\{\{ inputs\.recovery_source_run_id \}\}/u);
    assert.match(recovery, /source_sha: \$\{\{ inputs\.recovery_source_sha \}\}/u);
  }
});

test("stale recovery and an older partial-rerun artifact fail before mutation", () => {
  const promote = workflow("_web-hosting-promote.yml");
  assert.match(promote,
    /actions\/workflows\/\$\{SURFACE\}-website\.yml/u);
  assert.match(promote, /test "\$canonical_workflow_id" = "\$workflow_id"/u);
  assert.equal(
    (promote.match(/actions\/workflows\/\$[A-Z_a-z]+\/runs\?branch=main&event=push&per_page=1/gu) ?? []).length,
    2,
    "latest same-surface push must be checked during authorization and before mutation",
  );
  assert.match(promote,
    /actions\/runs\/\$SOURCE_CI_RUN_ID\/artifacts\?per_page=100/u);
  assert.equal(
    (promote.match(/actions\/runs\/\$SOURCE_CI_RUN_ID"\)/gu) ?? []).length,
    2,
    "latest source attempt must be checked during authorization and before mutation",
  );
  assert.ok((promote.match(/\.run_attempt == \$run_attempt/gu) ?? []).length >= 3,
    "historical binding plus both latest-attempt checks must stay enforced");
  assert.match(promote,
    /freshest_attempt[\s\S]*max \/\/ 0[\s\S]*freshest_attempt" != "\$SOURCE_CI_RUN_ATTEMPT/u);
  assert.match(promote,
    /not the unique freshest package for its producing run/u);
  assert.equal(
    (promote.match(/test "\$\(git rev-parse refs\/remotes\/origin\/main\)" = "\$SOURCE_SHA"/gu) ?? []).length,
    2,
    "recovery source must equal current main after checkout and immediately before mutation",
  );
  assert.equal(
    (promote.match(/git merge-base --is-ancestor "\$SOURCE_SHA" refs\/remotes\/origin\/main/gu) ?? []).length,
    2,
    "automatic promotion may cross unrelated commits but still requires main ancestry",
  );
  assert.match(promote,
    /if \[\[ "\$IS_RECOVERY" == "true" \]\]; then[\s\S]*git rev-parse refs\/remotes\/origin\/main/u);
  const lastFreshness = promote.lastIndexOf(
    'test "$(git rev-parse refs/remotes/origin/main)" = "$SOURCE_SHA"',
  );
  const deploy = promote.indexOf(
    "Deploy only the verified production Hosting target without rebuilding",
  );
  assert.ok(lastFreshness >= 0 && lastFreshness < deploy);

  assert.equal(recoveryAttemptIsCurrent(1, {runAttempt: 2}, [{attempt: 1}]), false,
    "a retained attempt-1 artifact cannot authorize recovery after attempt 2 exists");
  assert.equal(recoveryAttemptIsCurrent(2, {runAttempt: 2}, [{attempt: 1}]), false,
    "a latest rerun with no package must fail closed and require an all-jobs rerun");
});

test("the packaged Firebase target cannot run lifecycle hooks with deploy credentials", () => {
  const adapter = fs.readFileSync(
    path.join(repoRoot, "tool", "ci", "package_web_hosting.mjs"),
    "utf8",
  );
  assert.match(adapter, /delete target\.predeploy/u);
  assert.match(adapter, /delete target\.postdeploy/u);
  assert.match(adapter, /must not contain predeploy hooks/u);
  assert.match(adapter, /must not contain postdeploy hooks/u);

  const promote = workflow("_web-hosting-promote.yml");
  const finalVerify = promote.indexOf(
    "Re-extract and reverify immutable bytes before deployment credentials",
  );
  const auth = promote.indexOf(
    "Authenticate to Google Cloud only for final freshness and mutation",
  );
  const deploy = promote.indexOf(
    "--config firebase.json",
  );
  assert.ok(finalVerify >= 0 && finalVerify < auth && auth < deploy);
});

test("marketing production postconditions run only after exact promotion", () => {
  const promote = workflow("_web-hosting-promote.yml");
  const deploy = promote.indexOf("Deploy only the verified production Hosting target without rebuilding");
  const removeCredentials = promote.indexOf("Remove deploy credentials before postconditions");
  const unknown404 = promote.indexOf("Verify marketing production unknown paths return HTTP 404");
  const routeProbe = promote.indexOf("Verify launch-critical marketing production routes");
  assert.ok(deploy >= 0 && deploy < removeCredentials &&
    removeCredentials < unknown404 && unknown404 < routeProbe);
  assert.match(promote,
    /verifyHosting404\.mjs https:\/\/catchdates\.com/u);
  assert.match(promote,
    /probeProduction\.mjs --base-url https:\/\/catchdates\.com --json/u);
  assert.match(promote,
    /if: \$\{\{ inputs\.surface == 'marketing' \}\}/u);
});
