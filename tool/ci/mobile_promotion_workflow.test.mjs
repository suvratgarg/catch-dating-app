import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import {fileURLToPath} from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const workflow = fs.readFileSync(
  path.join(repoRoot, ".github/workflows/mobile-internal-promote.yml"),
  "utf8",
);
const core = fs.readFileSync(
  path.join(repoRoot, "tool/ci/mobile_promotion_core.mjs"),
  "utf8",
);

function currentSuccessfulProducer(candidate, requested) {
  return candidate.id === requested.id &&
    candidate.runAttempt === requested.attempt &&
    candidate.currentRunAttempt === requested.attempt &&
    candidate.workflowPath === ".github/workflows/mobile-internal-release.yml" &&
    candidate.event === "workflow_run" &&
    candidate.branch === "main" &&
    candidate.repository === requested.repository &&
    candidate.status === "completed" &&
    candidate.conclusion === "success";
}

function currentSuccessfulSource(candidate, authority) {
  return candidate.id === authority.id &&
    candidate.runAttempt === authority.attempt &&
    candidate.currentRunAttempt === authority.attempt &&
    candidate.workflowPath === ".github/workflows/ci.yml" &&
    candidate.event === "push" &&
    candidate.branch === "main" &&
    candidate.repository === authority.repository &&
    candidate.headSha === authority.sourceSha &&
    candidate.status === "completed" &&
    candidate.conclusion === "success";
}

function artifactMatchesAuthority(metadata, selected) {
  return metadata.id === selected.id &&
    metadata.name === selected.name &&
    metadata.digest === selected.digest &&
    metadata.runId === selected.producerRunId &&
    metadata.producerHeadSha === selected.producerHeadSha &&
    metadata.expired === false;
}

test("promotion is a confirmed manual-only operation with one queue per exact target", () => {
  const trigger = workflow.slice(0, workflow.indexOf("permissions:"));
  assert.match(trigger, /on:\n\s+workflow_dispatch:/u);
  assert.doesNotMatch(trigger, /\n\s+(?:push|pull_request|workflow_run|schedule):/u);
  for (const input of [
    "release_target",
    "producer_run_id",
    "producer_run_attempt",
    "authority_artifact_id",
    "authority_artifact_sha256",
    "reason",
    "confirm",
  ]) assert.match(trigger, new RegExp(`\\n\\s+${input}:`));
  for (const target of [
    "consumer-android", "consumer-ios", "host-android", "host-ios",
  ]) assert.match(trigger, new RegExp(`- ${target}`));
  assert.match(trigger, /confirm:[\s\S]*default: false[\s\S]*type: boolean/u);
  assert.match(workflow, /test "\$CONFIRM" = "true"/u);
  assert.ok(workflow.includes("REASON//[[:space:]]/"));
  assert.match(workflow, /runs-on:.*macos-26.*ubuntu-24\.04/u);
  assert.match(workflow, new RegExp(
    String.raw`concurrency:\n\s+group: mobile-internal-promotion-` +
      String.raw`\$\{\{ inputs\.release_target \}\}\n\s+cancel-in-progress: false\n` +
      String.raw`\s+queue: max`,
    "u",
  ));
  assert.match(workflow, /timeout-minutes: 90/u);
  assert.match(workflow, /test "\$GITHUB_RUN_ATTEMPT" = "1"/u);
});

test("producer attempt and current promoter implementation are fail-closed", () => {
  for (const binding of [
    "actions/workflows/mobile-internal-release.yml",
    "actions/runs/$PRODUCER_RUN_ID",
    "actions/runs/$PRODUCER_RUN_ID/attempts/$PRODUCER_RUN_ATTEMPT",
    ".run_attempt == $run_attempt",
    ".github/workflows/mobile-internal-release.yml",
    ".head_repository.full_name == $repository",
    ".head_branch == \"main\"",
    ".event == \"workflow_run\"",
    ".status == \"completed\"",
    ".conclusion == \"success\"",
    "ref: ${{ github.sha }}",
    "test \"$GITHUB_SHA\" = \"$(git rev-parse refs/remotes/origin/main)\"",
  ]) assert.ok(workflow.includes(binding), `missing producer/promoter binding: ${binding}`);

  const requested = {id: "7001", attempt: 3, repository: "catch/repo"};
  const valid = {
    id: "7001", runAttempt: 3, currentRunAttempt: 3,
    workflowPath: ".github/workflows/mobile-internal-release.yml",
    event: "workflow_run", branch: "main", repository: "catch/repo",
    status: "completed", conclusion: "success",
  };
  assert.equal(currentSuccessfulProducer(valid, requested), true);
  assert.equal(currentSuccessfulProducer({...valid, currentRunAttempt: 4}, requested), false);
  assert.equal(currentSuccessfulProducer({...valid, repository: "fork/repo"}, requested), false);
});

test("authority selects the package id, name, and digest and metadata cannot be substituted", () => {
  assert.match(workflow, new RegExp(
    String.raw`mobile_promotion_core\.mjs select[\s\S]*--authority` +
      String.raw`[\s\S]*--release-target[\s\S]*--producer-run-id` +
      String.raw`[\s\S]*--producer-run-attempt`,
    "u",
  ));
  assert.match(workflow, /echo "source_sha=\$\(jq -er '\.result\.sourceSha'/u);
  for (const output of [
    "package_artifact_id=$(jq -er '.result.packageArtifact.id'",
    "package_artifact_name=$(jq -er '.result.packageArtifact.name'",
    "package_artifact_digest=$(jq -er '.result.packageArtifact.digest'",
  ]) assert.ok(workflow.includes(output), `missing authority-derived output: ${output}`);
  assert.match(workflow, new RegExp(
    String.raw`actions\/artifacts\/\$AUTHORITY_ARTIFACT_ID[\s\S]*` +
      String.raw`\.digest == \$digest[\s\S]*` +
      String.raw`\.workflow_run\.head_sha == \$producer_head_sha`,
    "u",
  ));
  assert.match(workflow,
    /actions\/artifacts\/\$PACKAGE_ARTIFACT_ID[\s\S]*\.name == \$name[\s\S]*\.digest == \$digest/u);
  assert.match(workflow,
    /sha256:\$\(shasum -a 256 build\/mobile-promotion\/package\.zip/u);

  const selected = {
    id: 501,
    name: "mobile-package-v1-host-ios-9001-2-7001-3",
    digest: `sha256:${"a".repeat(64)}`,
    producerRunId: "7001",
    producerHeadSha: "2".repeat(40),
  };
  const metadata = {...selected, runId: "7001", expired: false};
  assert.equal(artifactMatchesAuthority(metadata, selected), true);
  assert.equal(artifactMatchesAuthority({...metadata, id: 502}, selected), false);
  assert.equal(artifactMatchesAuthority({...metadata, producerHeadSha: "1".repeat(40)}, selected), false);
});

test("producer head S2 is separate from authority source S1 and superseded source attempts reject", () => {
  assert.ok(workflow.includes(`producer_head_sha="$(jq -er '.producerHeadSha'`));
  assert.match(workflow, /SOURCE_SHA: \$\{\{ steps\.authority\.outputs\.source_sha \}\}/u);
  assert.match(workflow, /git merge-base --is-ancestor "\$SOURCE_SHA" refs\/remotes\/origin\/main/u);
  assert.ok((workflow.match(/actions\/runs\/\$SOURCE_CI_RUN_ID\/attempts\/\$SOURCE_CI_RUN_ATTEMPT/gu) ?? []).length >= 2);
  assert.match(workflow, /source_current=[\s\S]*actions\/runs\/\$SOURCE_CI_RUN_ID/u);

  const authority = {
    id: "9001", attempt: 1, repository: "catch/repo", sourceSha: "1".repeat(40),
  };
  const valid = {
    id: "9001", runAttempt: 1, currentRunAttempt: 1,
    workflowPath: ".github/workflows/ci.yml", event: "push", branch: "main",
    repository: "catch/repo", headSha: "1".repeat(40),
    status: "completed", conclusion: "success",
  };
  assert.equal(currentSuccessfulSource(valid, authority), true,
    "source S1 remains valid even when producer workflow head is S2");
  assert.equal(currentSuccessfulSource({...valid, currentRunAttempt: 2}, authority), false,
    "authority attempt 1 is stale after source CI attempt 2 exists");
});

test("all archive layers reject paths, links, duplicate entries, and unexpected inventory", () => {
  assert.ok((workflow.match(/verify_zip_paths\(\)/gu) ?? []).length >= 4);
  assert.ok((workflow.match(/index\(\$0, "\\\\"\) > 0/gu) ?? []).length >= 4);
  assert.ok((workflow.match(/part\[segment\] == "\.\."/gu) ?? []).length >= 4);
  assert.ok((workflow.match(/sort \| uniq -d/gu) ?? []).length >= 4);
  assert.ok((workflow.match(/zipinfo -s "\$archive"/gu) ?? []).length >= 4);
  assert.match(workflow, /entries="\$\(unzip -Z1 build\/mobile-promotion\/prior-claim\.zip\)"/u);
  assert.match(workflow, /test "\$entries" = "mobile-promotion-receipt\.json"/u);
  assert.match(workflow, /mobile_promotion_core\.mjs verify-package/u);
});

test("prior claims are exact, attempt-bound, and ambiguous Apple identity fails closed", () => {
  for (const binding of [
    "mobile-promotion-claim-v1-${RELEASE_TARGET}-${PACKAGE_ARTIFACT_ID}-${SIGNED_ARTIFACT_SHA256}",
    "mobile_promotion_core.mjs verify-receipt",
    ".result.evidenceLevel == \"exact-artifact\"",
    ".result.store.result == \"uploaded\"",
    ".result.promotionRunId",
    ".result.promotionRunAttempt",
    "actions/runs/$prior_run_id/attempts/$receipt_run_attempt",
    "Existing App Store build has no matching exact-artifact receipt.",
    "The prior upload result is ambiguous; exact promotion fails closed.",
  ]) assert.ok(workflow.includes(binding), `missing exact replay binding: ${binding}`);
  assert.doesNotMatch(workflow, /operator-reconciled-identity/u);
  assert.match(workflow, /existing-valid\|existing-processing[\s\S]*PRIOR_RECEIPT[\s\S]*PRIOR_REMOTE_ID/u);
});

test("fresh source, artifact, and package verification immediately precedes credentials", () => {
  const finalVerification = workflow.indexOf(
    "Re-extract and reverify exact bytes immediately before credentials",
  );
  const claim = workflow.indexOf("Resolve an immutable prior exact-promotion claim");
  const iosAuth = workflow.indexOf("Materialize App Store Connect credentials");
  const playAuth = workflow.indexOf("Authenticate the Play publisher");
  assert.ok(claim >= 0 && claim < finalVerification);
  assert.ok(finalVerification < iosAuth && finalVerification < playAuth);
  const finalSlice = workflow.slice(finalVerification, iosAuth);
  for (const binding of [
    "source_current=", "source_exact=", "producer=", "GITHUB_SHA",
    "rm -rf build/mobile-promotion/authority build/mobile-promotion/package",
    "unzip -q build/mobile-promotion/authority.zip",
    "unzip -q build/mobile-promotion/package.zip",
    "mobile_promotion_core.mjs verify-package",
    "EXPECTED_ARTIFACT_SHA256",
  ]) assert.ok(finalSlice.includes(binding), `missing immediate final binding: ${binding}`);
});

test("promotion uses one exact Play authority and never rebuilds, archives, or signs", () => {
  assert.match(workflow,
    /xcrun altool[\s\S]*--upload-package "\$IPA_PATH"[\s\S]*--bundle-id "\$BUNDLE_IDENTIFIER"/u);
  assert.match(workflow, new RegExp(
    String.raw`upload_google_play_bundle\.mjs[\s\S]*--bundle "\$AAB_PATH"` +
      String.raw`[\s\S]*--expected-version-code "\$VERSION_CODE"` +
      String.raw`[\s\S]*--expected-sha256 "\$SIGNED_ARTIFACT_SHA256"` +
      String.raw`[\s\S]*--track qa[\s\S]*--apply[\s\S]*--allow-prod`,
    "u",
  ));
  assert.match(workflow, /GOOGLE_PLAY_UPLOAD_ENABLED[\s\S]*!= "true"/u);
  assert.doesNotMatch(core, /androidpublisher\.googleapis\.com|promoteGooglePlay|preflightGooglePlay/u);
  assert.doesNotMatch(workflow, new RegExp(
    String.raw`^\s*(?:\.\/tool\/flutter_with_env\.sh|flutter|gradle|` +
      String.raw`\.\/gradlew|xcodebuild|codesign|jarsigner)\b`,
    "mu",
  ));
  assert.doesNotMatch(workflow, /actions\/setup-java|ANDROID_UPLOAD_KEYSTORE|build appbundle|build ios/u);
});

test("credentials are removed before one immutable 90-day claim is persisted", () => {
  const iosCleanup = workflow.indexOf("Remove App Store Connect credentials");
  const playCleanup = workflow.indexOf("Remove Play credentials");
  const receipt = workflow.indexOf("Create the immutable exact-promotion receipt");
  const upload = workflow.indexOf("uses: actions/upload-artifact@v7");
  const postconditions = workflow.indexOf("Record credential-free exact promotion postconditions");
  assert.ok(iosCleanup < receipt && playCleanup < receipt && receipt < postconditions);
  assert.ok(postconditions < upload,
    "claim publication must be the final substantive step for unambiguous reuse");
  assert.equal((workflow.match(/uses: actions\/upload-artifact@v7/gu) ?? []).length, 1);
  assert.match(workflow, /name: \$\{\{ steps\.claim\.outputs\.claim_artifact_name \}\}/u);
  assert.match(workflow, /retention-days: 90/u);
  assert.match(workflow, /--evidence-level exact-artifact/u);
});
