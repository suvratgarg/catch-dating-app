import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const source = fs.readFileSync(
  new URL("../../.github/workflows/mobile-internal-release.yml", import.meta.url),
  "utf8",
);

test("mobile producer consumes only a successful same-repository main CI attempt", () => {
  assert.match(source, /workflow_run:\s*\n\s+workflows: \["CI"\]/u);
  assert.match(source, /types: \[completed\]/u);
  assert.match(source, /branches: \[main\]/u);
  assert.doesNotMatch(source, /^\s{2}(?:push|workflow_dispatch):/mu);
  assert.match(source, /EVENT_CONCLUSION[\s\S]*?EVENT_HEAD_REPOSITORY_ID/u);
  assert.match(source, /EVENT_HEAD_REPOSITORY_ID" != "\$REPOSITORY_ID"/u);
  assert.match(source, /EVENT_NAME" != "push"/u);
  assert.match(source, /EVENT_HEAD_BRANCH" != "main"/u);
  assert.match(source, /actions\/runs\/\$EVENT_RUN_ID\/attempts\/\$EVENT_RUN_ATTEMPT/u);
  assert.match(source, /latest_run="\$\(gh api "repos\/\$GITHUB_REPOSITORY\/actions\/runs\/\$EVENT_RUN_ID"\)"/u);
  assert.match(source, /\.run_attempt == \$run_attempt[\s\S]*?historical_attempt=/u);
  assert.match(source, /\.path \| split\("@"\)\[0\][\s\S]*?\.github\/workflows\/ci\.yml/u);
  assert.match(source, /\.status == "completed"[\s\S]*?\.conclusion == "success"/u);
});

test("source CI attempt must still be latest immediately before authority upload", () => {
  const finalCheck = source.indexOf("Reconfirm source CI attempt is still current");
  const upload = source.indexOf("Upload post-comparison mobile build authority");
  assert.ok(finalCheck > 0 && upload > finalCheck);
  const section = source.slice(finalCheck, upload);
  assert.match(section, /actions\/runs\/\$SOURCE_CI_RUN_ID/u);
  assert.match(section, /\.run_attempt == \$run_attempt/u);
  assert.match(section, /\.status == "completed"[\s\S]*?\.conclusion == "success"/u);
});

test("mobile producer downloads the CI authority and plan by immutable id and digest", () => {
  assert.match(source, /catch\.ci-delivery-authority\/v3/u);
  assert.match(source, /harness-success-v3-/u);
  assert.match(source, /harness-plan-/u);
  assert.match(source, /actions\/artifacts\/\$authority_id\/zip/u);
  assert.match(source, /actions\/artifacts\/\$plan_id\/zip/u);
  assert.match(source, /sha256sum build\/mobile\/source\/authority\.zip/u);
  assert.match(source, /sha256sum build\/mobile\/source\/plan\.zip/u);
  assert.match(source, /\.planArtifact\.id == \$plan_id/u);
  assert.match(source, /\.planArtifact\.digest == \$plan_digest/u);
  assert.match(source, /find build\/mobile\/source\/authority -type l/u);
  assert.match(source, /find build\/mobile\/source\/plan -type l/u);
});

test("exact releaseTargets select role-platform builds without Cartesian widening", () => {
  assert.match(source, /release_targets="\$\(jq -c '\.operations\.releaseTargets'/u);
  assert.match(source, /ios_targets="\$\(jq -c '\[\.operations\.releaseTargets\[\]/u);
  assert.match(source, /android_targets="\$\(jq -c/u);
  assert.match(source, /matrix:\s*\n\s+release_target: \$\{\{ fromJSON\(needs\.authorize\.outputs\.ios_targets\) \}\}/u);
  assert.match(source, /matrix:\s*\n\s+release_target: \$\{\{ fromJSON\(needs\.authorize\.outputs\.android_targets\) \}\}/u);
  assert.match(source, /consumer-ios\) app_role=consumer/u);
  assert.match(source, /host-ios\) app_role=host/u);
  assert.match(source, /consumer-android\) app_role=consumer/u);
  assert.match(source, /host-android\) app_role=host/u);
  assert.doesNotMatch(source, /node tool\/harness\.mjs plan/u);
  assert.doesNotMatch(source, /matrix\.app_role/u);
});

test("each signed artifact is source-bound, packaged, and retained for promotion", () => {
  const exactCheckouts = source.match(
    /ref: \$\{\{ needs\.authorize\.outputs\.source_sha \}\}/gu,
  ) ?? [];
  assert.ok(exactCheckouts.length >= 4);
  assert.match(source, /package_mobile_release\.mjs prepare[\s\S]*?--ci-authority/u);
  assert.match(source, /--impact-plan build\/mobile\/source\/impact-plan\.json/u);
  assert.match(source, /package_mobile_release\.mjs bind-upload/u);
  assert.match(source, /format\('sha256:\{0\}', steps\.upload-package\.outputs\.artifact-digest\)/u);
  assert.match(source, /mobile-package-v1-\$\{\{ matrix\.release_target \}\}/u);
  assert.match(source, /mobile-package-receipt-v1-\$\{\{ matrix\.release_target \}\}/u);
  assert.match(source, /verify_ios_release_identity\.mjs [\s\S]*?--ipa "\$ipa_path"/u);
  const exportIdentity = source.slice(
    source.indexOf("Verify exported release identity"),
    source.indexOf("Enforce iOS package size and payload policy"),
  );
  assert.doesNotMatch(exportIdentity, /ditto|exported_app|--ios-built-plist/u);
  const longRetention = source.match(/retention-days: 90/gu) ?? [];
  assert.ok(longRetention.length >= 5);
});

test("partial producer reruns fail closed with a current-attempt completeness authority", () => {
  assert.match(source, /Partial job reruns cannot mix evidence across attempts/u);
  assert.match(source, /Use Re-run all jobs for Mobile Internal Release/u);
  assert.match(source, /mobile-source-v1-\$\{SOURCE_CI_RUN_ID\}-\$\{SOURCE_CI_RUN_ATTEMPT\}-\$\{PRODUCER_RUN_ID\}-\$\{PRODUCER_RUN_ATTEMPT\}/u);
  assert.match(source, /catch\.mobile-attempt-completeness-authority\/v1/u);
  assert.match(source, /package_mobile_release\.mjs verify-attempt/u);
  assert.match(source, /mobile-attempt-completeness-v1-/u);
  assert.match(source, /\.run_attempt == \$run_attempt[\s\S]*?\.status == "in_progress"/u);
  const compareGate = source.slice(
    source.indexOf("Require a complete current producer attempt"),
    source.indexOf("Download exact package receipt artifacts"),
  );
  const publishGate = source.slice(
    source.indexOf("Verify exact package and receipt artifact metadata"),
    source.indexOf("artifact_pages=", source.indexOf("Verify exact package and receipt artifact metadata")),
  );
  assert.doesNotMatch(compareGate, /\.head_sha/u);
  assert.doesNotMatch(publishGate, /\.head_sha/u);
});

test("cross-role comparison passes before the aggregate build authority is published", () => {
  assert.match(source, /compare-role-packages:[\s\S]*?check_mobile_package\.mjs --compare/u);
  assert.match(source, /publish-authority:[\s\S]*?needs: \[authorize, compare-role-packages\]/u);
  assert.match(source, /needs\.compare-role-packages\.result == 'success'/u);
  assert.match(source, /schema: "catch\.mobile-build-authority\/v1"/u);
  assert.match(source, /package_mobile_release\.mjs verify-authority/u);
  assert.match(source, /Upload post-comparison mobile build authority/u);
  const compareIndex = source.indexOf("  compare-role-packages:");
  const authorityIndex = source.indexOf("  publish-authority:");
  assert.ok(compareIndex >= 0 && authorityIndex > compareIndex);
});

test("finalizer downloads and re-verifies exact package bytes before authority", () => {
  const publish = source.slice(source.indexOf("  publish-authority:"));
  assert.match(publish, /actions\/artifacts\/\$package_id\/zip/u);
  assert.match(publish, /sha256sum "\$package_root\/package\.zip"/u);
  assert.match(publish, /package_mobile_release\.mjs verify [\s\S]*?--package-dir "\$package_root\/content"/u);
  assert.match(publish, /cmp "\$package_root\/package-receipt\.sorted\.json"/u);
  const packageDownload = publish.indexOf("actions/artifacts/$package_id/zip");
  const packageVerify = publish.indexOf("package_mobile_release.mjs verify \\");
  const authority = publish.indexOf('schema: "catch.mobile-build-authority/v1"');
  assert.ok(packageDownload >= 0 && packageVerify > packageDownload && authority > packageVerify);
});

test("publisher-capable and signing secrets are not job-wide", () => {
  const iosHeader = source.slice(
    source.indexOf("  prod-ios:"),
    source.indexOf("    steps:", source.indexOf("  prod-ios:")),
  );
  const androidHeader = source.slice(
    source.indexOf("  prod-android:"),
    source.indexOf("    steps:", source.indexOf("  prod-android:")),
  );
  assert.doesNotMatch(iosHeader, /APP_STORE_CONNECT_API_KEY/u);
  assert.doesNotMatch(androidHeader, /ANDROID_UPLOAD_|GOOGLE_MAPS_ANDROID_API_KEY_PROD/u);
  assert.doesNotMatch(source, /GOOGLE_PLAY_SERVICE_ACCOUNT|PLAY_PUBLISHER/u);
});

test("producer performs no App Store, Play, or legacy-owner mutation", () => {
  for (const forbidden of [
    /xcrun altool/u,
    /upload_google_play_bundle/u,
    /probe_google_play_access/u,
    /set_xcode_cloud_workflow_state/u,
    /--wait-processed/u,
    /--apply/u,
    /--allow-prod/u,
    /google-github-actions\/auth/u,
  ]) {
    assert.doesNotMatch(source, forbidden);
  }
});
