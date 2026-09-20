import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";
import {runInNewContext} from "node:vm";

const producer = fs.readFileSync(
  new URL("../../.github/workflows/mobile-internal-release.yml", import.meta.url),
  "utf8",
);
const platformWorkflow = fs.readFileSync(
  new URL("../../.github/workflows/_mobile-platform-authority.yml", import.meta.url),
  "utf8",
);
const dispatchIndex = producer.indexOf("  dispatch-promotions:");
const source = producer.slice(0, dispatchIndex) + platformWorkflow + producer.slice(dispatchIndex);
const consumerGradleWrapper = fs.readFileSync(
  new URL("../../android/gradle/wrapper/gradle-wrapper.properties", import.meta.url),
  "utf8",
);
const hostGradleWrapper = fs.readFileSync(
  new URL("../../apps/host/android/gradle/wrapper/gradle-wrapper.properties", import.meta.url),
  "utf8",
);

test("mobile producer skips successful nightly and manual CI before allocating a runner", () => {
  const authorizeHeader = source.slice(source.indexOf("  authorize:"), source.indexOf("    runs-on:"));
  const expression = authorizeHeader.match(/if: \$\{\{ (.+) \}\}/u)?.[1];
  assert.ok(expression, "the authorization job must filter the triggering CI event");
  // These string comparisons and boolean operators have the same semantics
  // in JavaScript and GitHub expressions for the event values below.
  for (const event of ["push", "schedule", "workflow_dispatch", "pull_request"]) {
    for (const conclusion of ["success", "failure", "cancelled"]) {
      assert.equal(
        runInNewContext(expression, {github: {event: {workflow_run: {event, conclusion}}}}),
        event === "push" && conclusion === "success",
        `${event}/${conclusion}`,
      );
    }
  }
});

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
    /ref: \$\{\{ (?:needs\.authorize\.outputs|inputs)\.source_sha \}\}/gu,
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
  assert.match(source, /publish-authority:[\s\S]*?needs: compare-role-packages/u);

  assert.match(source, /schema: "catch\.mobile-build-authority\/v2"/u);
  assert.match(source, /package_mobile_release\.mjs verify-authority/u);
  assert.match(source, /Upload post-comparison mobile build authority/u);
  const compareIndex = source.indexOf("  compare-role-packages:");
  const authorityIndex = source.indexOf("  publish-authority:");
  assert.ok(compareIndex >= 0 && authorityIndex > compareIndex);
});

test("verified authority automatically dispatches every authorized iOS target", () => {
  const publish = source.indexOf("Upload post-comparison mobile build authority");
  const dispatch = source.indexOf("Dispatch one exact promoter for each authorized iOS target");
  const verify = source.indexOf("Require every authorized iOS target to reach the promoter");
  assert.ok(publish >= 0 && dispatch > publish && verify > dispatch);
  const section = source.slice(dispatch, verify);
  for (const marker of [
    "permissions:\n      actions: write",
    "mobile-internal-promote.yml/dispatches",
    'ref: "main"',
    "producer_run_id: $producer_run_id",
    "producer_run_attempt: $producer_run_attempt",
    "authority_artifact_id: $authority_artifact_id",
    "authority_artifact_sha256: $authority_artifact_sha256",
    "confirm: \"true\"",
  ]) assert.ok(source.includes(marker), `missing automatic promotion binding: ${marker}`);
  assert.match(section, /if \[\[ "\$release_target" != \*-ios \]\]; then continue; fi/u);
});

test("finalizer downloads and re-verifies exact package bytes before authority", () => {
  const publish = source.slice(source.indexOf("  publish-authority:"));
  assert.match(publish, /actions\/artifacts\/\$package_id\/zip/u);
  assert.match(publish, /sha256sum "\$package_root\/package\.zip"/u);
  assert.match(publish, /package_mobile_release\.mjs verify [\s\S]*?--package-dir "\$package_root\/content"/u);
  assert.match(publish, /cmp "\$package_root\/package-receipt\.sorted\.json"/u);
  const packageDownload = publish.indexOf("actions/artifacts/$package_id/zip");
  const packageVerify = publish.indexOf("package_mobile_release.mjs verify \\");
  const authority = publish.indexOf('schema: "catch.mobile-build-authority/v2"');
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

test("Android Maps authority reaches the compiled identity verifier step", () => {
  const verifyStart = source.indexOf("- name: Verify signed Android release identity");
  const verifyEnd = source.indexOf(
    "- name: Enforce Android package size and payload policy",
    verifyStart,
  );
  assert.ok(verifyStart >= 0 && verifyEnd > verifyStart);
  const verifyStep = source.slice(verifyStart, verifyEnd);
  assert.match(verifyStep,
    /GOOGLE_MAPS_ANDROID_API_KEY_PROD: \$\{\{ secrets\.GOOGLE_MAPS_ANDROID_API_KEY_PROD \}\}/u);
  assert.match(verifyStep, /verify_android_release_bundle\.mjs/u);
});

test("Android release jobs use the same checksummed Gradle distribution with bounded recovery", () => {
  assert.equal(hostGradleWrapper, consumerGradleWrapper);
  assert.match(
    consumerGradleWrapper,
    /distributionUrl=https\\:\/\/github\.com\/gradle\/gradle-distributions\/releases\/download\/v8\.14\.0\/gradle-8\.14-bin\.zip/u,
  );
  assert.match(
    consumerGradleWrapper,
    /distributionSha256Sum=61ad310d3c7d3e5da131b76bbf22b5a4c0786e9d892dae8c1658d4b484de3caa/u,
  );
  const androidBuild = source.slice(
    source.indexOf("- name: Build signed prod Android App Bundle"),
    source.indexOf("- name: Verify signed Android release identity"),
  );
  assert.match(androidBuild, /CATCH_GRADLE_WRAPPER_MAX_ATTEMPTS: 5/u);
  assert.match(androidBuild, /CATCH_GRADLE_WRAPPER_RETRY_DELAY_SECONDS: 20/u);
});

test("producer performs no App Store, Play, or legacy-owner mutation", () => {
  for (const forbidden of [
    /xcrun altool/u,
    /upload_google_play_bundle/u,
    /probe_google_play_access/u,
    /set_xcode_cloud_workflow_state/u,
    /--wait-processed/u,
    /google-github-actions\/auth/u,
  ]) {
    assert.doesNotMatch(source, forbidden);
  }
});

test("Android failures cannot skip iOS authority or promotion, and vice versa", () => {
  const job = (name) => producer.match(new RegExp(`^  ${name}:\\n[\\s\\S]*?(?=^  [a-z][a-z-]*:|(?![\\s\\S]))`, "mu"))?.[0];
  for (const platform of ["ios", "android"]) {
    const authority = job(`${platform}-authority`);
    assert.ok(authority);
    assert.ok(authority.includes(`needs: [authorize, prod-${platform}]`));
    assert.ok(authority.includes("release_targets: ${{ needs.authorize.outputs." + platform + "_targets }}"));
    const expression = authority.match(/if: >-\n([\s\S]*?)    uses:/u)[1].trim();
    for (const result of ["success", "failure", "cancelled", "skipped"]) {
      const needs = {
        authorize: {result: "success", outputs: {[`has_${platform}_targets`]: "true"}},
        [`prod-${platform}`]: {result},
        [`prod-${platform === "ios" ? "android" : "ios"}`]: {result: "failure"},
      };
      assert.equal(runInNewContext(expression.replaceAll(`needs.prod-${platform}`, `needs["prod-${platform}"]`),
        {needs, always: () => true}), result === "success");
    }
  }
  const dispatch = job("dispatch-promotions");
  assert.match(dispatch, /needs: \[authorize, ios-authority\]/u);
  assert.match(dispatch, /always\(\)/u);
  assert.doesNotMatch(dispatch, /prod-android|android-authority/u);
  assert.match(platformWorkflow, /pattern: mobile-package-receipt-v1-\*-\$\{\{ inputs.platform \}\}-/u);
  assert.match(platformWorkflow, /--arg suffix "-\$\{\{ inputs.platform \}\}-\$suffix"/u);
});

test("queued producer verifies both selected packages but rejects incomplete or stale evidence", async () => {
  const {spawnSync} = await import("node:child_process");
  const {tmpdir} = await import("node:os");
  const path = await import("node:path");
  const root = fs.mkdtempSync(path.join(tmpdir(), "mobile-producer-guard-"));
  const section = platformWorkflow.slice(
    platformWorkflow.indexOf("Require a complete current producer attempt"),
    platformWorkflow.indexOf("      - name: Download exact package receipt artifacts"),
  );
  const script = section.slice(section.indexOf("        run: |\n") + "        run: |\n".length)
    .split("\n").map((line) => line.replace(/^ {10}/u, "")).join("\n");
  const targets = ["consumer-ios", "host-ios"];
  const suffix = "42-1-7001-3";
  const sourceName = `mobile-source-v1-${suffix}`;
  const run = {id: 7001, run_attempt: 3, name: "Mobile Internal Release",
    path: ".github/workflows/mobile-internal-release.yml", event: "workflow_run",
    repository: {full_name: "catch/repo"}, status: "queued", conclusion: null};
  const jobs = targets.map((target) => ({name: `Build signed package (${target})`,
    run_id: 7001, run_attempt: 3, status: "completed", conclusion: "success"}));
  // The failed sibling must not participate in the selected iOS proof.
  jobs.push({name: "Build signed package (host-android)", run_id: 7001,
    run_attempt: 3, status: "completed", conclusion: "failure"});
  const names = [sourceName, ...targets.flatMap((target) => [
    `mobile-package-v1-${target}-${suffix}`, `mobile-package-receipt-v1-${target}-${suffix}`])];
  const artifacts = names.map((name, index) => ({id: index + 10, name,
    expired: false, digest: `sha256:${"a".repeat(64)}`}));
  try {
    fs.writeFileSync(path.join(root, "gh"), `#!${process.execPath}\n` +
      'const f=JSON.parse(process.env.GUARD_FIXTURE); const endpoint=process.argv.at(-1);\n' +
      'if(endpoint.endsWith("/attempts/3/jobs?per_page=100")) console.log(JSON.stringify([{jobs:f.jobs}]));\n' +
      'else if(endpoint.endsWith("/artifacts?per_page=100")) console.log(JSON.stringify([{artifacts:f.artifacts}]));\n' +
      'else if(endpoint.endsWith("/runs/7001")) console.log(JSON.stringify(f.run));\n' +
      'else process.exit(99);\n', {mode: 0o755});
    const cases = [
      {label: "queued with both role jobs and receipts", allowed: true},
      {label: "in progress", run: {...run, status: "in_progress"}, allowed: true},
      ...["completed", "waiting", "pending", "requested", "cancelled"].map((status) =>
        ({label: `unsupported ${status}`, run: {...run, status}, reason: "Producer identity"})),
      {label: "cancelled conclusion", run: {...run, conclusion: "cancelled"}, reason: "Producer identity"},
      {label: "new attempt", run: {...run, run_attempt: 4}, reason: "Producer identity"},
      {label: "foreign repository", run: {...run, repository: {full_name: "fork/repo"}}, reason: "Producer identity"},
      {label: "wrong workflow", run: {...run, path: ".github/workflows/other.yml"}, reason: "Producer identity"},
      {label: "missing role job", jobs: jobs.slice(1), reason: "Selected platform package jobs"},
      {label: "duplicate role job", jobs: [...jobs, jobs[0]], reason: "Selected platform package jobs"},
      ...[{run_attempt: 2}, {run_id: 7002}, {conclusion: "failure"}, {status: "in_progress"}]
        .map((change) => ({label: `invalid job ${JSON.stringify(change)}`,
          jobs: [{...jobs[0], ...change}, ...jobs.slice(1)], reason: "Selected platform package jobs"})),
      {label: "missing receipt", artifacts: artifacts.slice(0, -1), reason: "Artifact completeness"},
      {label: "duplicate receipt", artifacts: [...artifacts, artifacts.at(-1)], reason: "Artifact completeness"},
      {label: "old receipt attempt", artifacts: artifacts.map((a, i) => i === 4 ? {...a, name: a.name.replace(/-3$/u, "-2")} : a), reason: "Artifact completeness"},
      {label: "expired package", artifacts: artifacts.map((a, i) => i === 1 ? {...a, expired: true} : a), reason: "Artifact completeness"},
      {label: "invalid digest", artifacts: artifacts.map((a, i) => i === 1 ? {...a, digest: "invalid"} : a), reason: "Artifact completeness"},
    ];
    for (const fixture of cases) {
      fs.rmSync(path.join(root, "build"), {recursive: true, force: true});
      const result = spawnSync("bash", ["-c", script], {cwd: root, encoding: "utf8", env: {
        ...process.env, PATH: `${root}:${process.env.PATH}`,
        GUARD_FIXTURE: JSON.stringify({run, jobs, artifacts, ...fixture}),
        GITHUB_REPOSITORY: "catch/repo", PRODUCER_RUN_ID: "7001", PRODUCER_RUN_ATTEMPT: "3",
        SOURCE_CI_RUN_ID: "42", SOURCE_CI_RUN_ATTEMPT: "1", SOURCE_SHA: "b".repeat(40),
        EXPECTED_SOURCE_BUNDLE_NAME: sourceName, RELEASE_TARGETS: JSON.stringify(targets),
      }});
      assert.equal(result.status, fixture.allowed ? 0 : 64, `${fixture.label}: ${result.stdout}\n${result.stderr}`);
      if (fixture.allowed) {
        assert.deepEqual(fs.readdirSync(path.join(root, "build/mobile/attempt/entries")).sort(),
          targets.map((target) => `${target}.json`));
      } else assert.ok(result.stdout.includes(fixture.reason), fixture.label);
    }
  } finally { fs.rmSync(root, {recursive: true, force: true}); }
});

test("publication and handoff use the same bounded active producer status", async () => {
  const {spawnSync} = await import("node:child_process");
  const queries = [...(platformWorkflow + producer).matchAll(/'\n(\s+[^']+?)\n\s+' <<< "\$current_run"/gu)]
    .map((match) => match[1]).filter((query) => query.includes('.status == "queued"'));
  assert.equal(queries.length, 3, "compare, publish, and automatic dispatch");
  const packageProofs = [...platformWorkflow.matchAll(/'\n(\s+\[\.\[\]\.jobs\[\]\] as \$jobs[^']+?)\n\s+' <<< "\$jobs"/gu)]
    .map((match) => match[1]);
  assert.equal(packageProofs.length, 2, "compare and publish both prove selected package jobs");
  assert.equal(packageProofs[0], packageProofs[1]);
  const valid = {id: 7001, run_attempt: 3, name: "Mobile Internal Release",
    path: ".github/workflows/mobile-internal-release.yml", event: "workflow_run",
    repository: {full_name: "catch/repo"}, head_repository: {full_name: "catch/repo"},
    head_branch: "main", status: "queued", conclusion: null};
  for (const query of queries) {
    for (const [change, allowed] of [[{}, true], [{status: "in_progress"}, true],
      [{status: "completed", conclusion: "cancelled"}, false], [{run_attempt: 4}, false],
      [{status: "queued", conclusion: "cancelled"}, false], [{status: "waiting"}, false]]) {
      const result = spawnSync("jq", ["-e", "--arg", "repository", "catch/repo",
        "--arg", "run_id", "7001", "--argjson", "run_attempt", "3", query],
      {input: JSON.stringify({...valid, ...change}), encoding: "utf8"});
      assert.equal(result.status === 0, allowed, result.stderr);
    }
  }
});
