import assert from "node:assert/strict";
import test from "node:test";
import {
  androidClientFor,
  parseAppleBuildConfigurations,
  validateAndroidBuildSource,
  validateManifestShape,
  validateReleaseOwnership,
  validateSharedAndroidManifestSource,
} from "./check_app_targets.mjs";
import {resolveAppTarget, valueAtPath} from "./resolve_app_target.mjs";

function validManifest() {
  const roles = {
    consumer: {storeProduct: {appStoreConnectAppId: "consumer-app"}},
    host: {storeProduct: {appStoreConnectAppId: "host-app"}},
  };
  const environments = {
    dev: {},
    staging: {},
    prod: {},
  };
  const targets = [];
  for (const role of Object.keys(roles)) {
    for (const environment of Object.keys(environments)) {
      targets.push({
        id: `${role}-${environment}`,
        role,
        environment,
        entrypoint: `lib/main_${role}_${environment}.dart`,
        ios: {bundleId: `com.catch.${role}.${environment}`},
        android: {applicationId: `com.catch.${role}.${environment}`},
      });
    }
  }
  return {
    schemaVersion: 1,
    logicalName: "catch-installable-app-targets",
    roles,
    environments,
    targets,
    transitionalDebt: [],
  };
}

test("validateManifestShape rejects a duplicate role/environment target", () => {
  const manifest = validManifest();
  manifest.targets[5] = {
    ...manifest.targets[5],
    id: "host-prod-copy",
    role: "consumer",
    environment: "prod",
  };

  assert.ok(
    validateManifestShape(manifest).includes("duplicate target pair consumer/prod"),
  );
});

test("androidClientFor selects the Host client instead of client zero", () => {
  const config = {
    client: [
      {
        client_info: {
          mobilesdk_app_id: "consumer-id",
          android_client_info: {package_name: "com.catch.consumer"},
        },
      },
      {
        client_info: {
          mobilesdk_app_id: "host-id",
          android_client_info: {package_name: "com.catch.host"},
        },
      },
    ],
  };

  assert.equal(
    androidClientFor(config, "com.catch.host").client_info.mobilesdk_app_id,
    "host-id",
  );
});

test("Android build guard rejects aggregate tasks without one app target", () => {
  const guardedSource = `
    app_targets.json
    installableAppTargets
    requestedAppTarget
    target = requestedAppTarget
    for (prefix in listOf("assemble", "bundle", "build", "check", "test", "lint")) {}
  `;
  assert.deepEqual(validateAndroidBuildSource(guardedSource), []);

  assert.ok(
    validateAndroidBuildSource(guardedSource.replace('"build", ', "")).includes(
      "Android app-target guard does not cover aggregate 'build' tasks",
    ),
  );
});

test("Android shared manifest rejects Consumer-only capabilities", () => {
  assert.deepEqual(validateSharedAndroidManifestSource("<manifest />"), []);
  const findings = validateSharedAndroidManifestSource(`
    <uses-permission android:name="android.permission.health.READ_EXERCISE" />
    <intent-filter android:autoVerify="true" />
  `);
  assert.equal(findings.length, 2);
});

test("Apple build configuration parser keeps target identity bound to its configuration", () => {
  const configurations = parseAppleBuildConfigurations(`
    buildSettings = {
      CATCH_APP_TARGET_ID = host-prod;
      FLUTTER_TARGET = "$(SRCROOT)/../lib/main_host_prod.dart";
      PRODUCT_BUNDLE_IDENTIFIER = com.catchdates.host;
      "CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "Apple Distribution";
    };
    name = Release-host-prod;
  `);

  assert.deepEqual(configurations, [
    {
      name: "Release-host-prod",
      settings: {
        CATCH_APP_TARGET_ID: "host-prod",
        FLUTTER_TARGET: "$(SRCROOT)/../lib/main_host_prod.dart",
        PRODUCT_BUNDLE_IDENTIFIER: "com.catchdates.host",
        "CODE_SIGN_IDENTITY[sdk=iphoneos*]": "Apple Distribution",
      },
    },
  ]);
});

function unifiedReleaseManifest() {
  const manifest = validManifest();
  manifest.releasePolicy = {
    owner: "github-actions",
    workflow: ".github/workflows/mobile-internal-release.yml",
    trigger: "app-relevant-main-push",
    environment: "prod-mobile",
    approvalMode: "none-after-main-merge",
    branchPolicy: "main-only",
    roles: ["consumer", "host"],
    ios: {
      channel: "testflight",
      uploadMode: "automatic-main",
      archiveSigningIdentity: "Apple Distribution",
    },
    android: {
      channel: "play-internal",
      track: "qa",
      uploadMode: "gated-until-play-ready",
      publisherAuth: "github-oidc",
      publisherServiceAccount: "github-actions-play-publisher@catch-dating-app-64e51.iam.gserviceaccount.com",
      uploadCertificateSha256: "A".repeat(64),
    },
  };
  for (const target of manifest.targets.filter((candidate) => candidate.environment === "prod")) {
    target.release = {
      owner: "github-actions",
      githubMode: "automatic-main",
      githubWorkflow: ".github/workflows/mobile-internal-release.yml",
      googlePlayPackageName: target.android.applicationId,
      legacyXcodeCloudWorkflow: `${target.role} legacy`,
    };
  }
  manifest.transitionalDebt.push(
    {id: "APP-TARGET-IOS-GITHUB-CUTOVER-001", status: "blocked_external"},
    {id: "APP-TARGET-ANDROID-PLAY-001", status: "blocked_external"},
  );
  return manifest;
}

const unifiedWorkflow = `
on:
  push:
    branches:
      - main
concurrency:
  cancel-in-progress: false
jobs:
  resolve:
    run: echo refs/heads/main; roles='["consumer","host"]'
  prod-ios:
    environment: prod-mobile
    strategy:
      matrix:
        app_role: roles
    steps:
      - name: Upload to TestFlight
      - run: echo 'CODE_SIGN_IDENTITY=Apple Distribution'
      - run: node tool/platform/verify_app_store_build.mjs
  prod-android:
    environment: prod-mobile
    strategy:
      matrix:
        app_role: roles
    steps:
      - run: echo BUNDLETOOL_SHA256
      - run: node tool/platform/verify_android_release_bundle.mjs --track qa
      - run: node tool/platform/upload_google_play_bundle.mjs --track qa
  probe-play:
    run: node tool/platform/probe_google_play_access.mjs --track qa
  retire:
    run: node tool/platform/verify_ios_processing_receipts.mjs consumer_processed_ios_build_number; node tool/platform/set_xcode_cloud_workflow_state.mjs
`;

test("release ownership accepts one GitHub matrix for both roles and platforms", () => {
  const manifest = unifiedReleaseManifest();
  const result = validateReleaseOwnership({manifest, workflowSource: unifiedWorkflow});
  assert.deepEqual(result.findings, []);
  assert.equal(result.warnings.length, 2);
});

test("release ownership rejects split or incomplete workflow ownership", () => {
  const manifest = unifiedReleaseManifest();
  manifest.targets.find((target) => target.id === "consumer-prod").release.owner = "xcode-cloud";
  const workflowSource = `
on:
  push:
jobs:
  prod-ios:
    environment: prod-mobile
`;

  const result = validateReleaseOwnership({manifest, workflowSource});
  assert.ok(result.findings.some((finding) => finding.includes("consumer-prod")));
  assert.ok(result.findings.some((finding) => finding.includes("Android role matrix")));
});

test("resolveAppTarget returns explicit target fields", () => {
  const manifest = validManifest();
  const target = resolveAppTarget({
    manifest,
    role: "host",
    environment: "staging",
  });

  assert.equal(target.id, "host-staging");
  assert.equal(valueAtPath(target, "ios.bundleId"), "com.catch.host.staging");
});
