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
      },
    },
  ]);
});

test("release ownership rejects automatic Host upload without external-proof debt", () => {
  const manifest = validManifest();
  manifest.targets[5].release = {
    owner: "github-actions-temporary",
    desiredOwner: "xcode-cloud",
    githubMode: "automatic-main-temporary",
  };
  const workflowSource = `
on:
  push:
jobs:
  release:
    if: github.event_name == 'push'
    run: |
      app_role="host"
      upload_to_testflight="true"
`;

  const result = validateReleaseOwnership({manifest, workflowSource});

  assert.equal(result.findings.length, 1);
  assert.equal(result.warnings.length, 0);
});

test("release ownership keeps the Host cutover as an explicit warning while proof is pending", () => {
  const manifest = validManifest();
  manifest.targets[5].release = {
    owner: "github-actions-temporary",
    desiredOwner: "xcode-cloud",
    githubMode: "automatic-main-temporary",
  };
  manifest.transitionalDebt.push({
    id: "APP-TARGET-HOST-TESTFLIGHT-001",
    status: "blocked_external",
  });
  const workflowSource = `
on:
  push:
jobs:
  release:
    if: github.event_name == 'push'
    run: |
      app_role="host"
      upload_to_testflight="true"
`;

  const result = validateReleaseOwnership({manifest, workflowSource});

  assert.equal(result.findings.length, 0);
  assert.equal(result.warnings.length, 1);
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
