import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";
import {
  androidClientFor,
  parseAppleBuildConfigurations,
  validateAutomaticAppleSigningSettings,
  validateAndroidBuildSource,
  validateManifestShape,
  validateReleaseOwnership,
  validateSharedAndroidManifestSource,
} from "./check_app_targets.mjs";
import {resolveAppTarget, valueAtPath} from "./resolve_app_target.mjs";

function validManifest() {
  const roles = {
    consumer: {
      projectRoot: "apps/consumer",
      entrypoint: "apps/consumer/lib/main.dart",
      packageEntrypoint: "lib/main.dart",
      storeProduct: {appStoreConnectAppId: "consumer-app"},
    },
    host: {
      projectRoot: "apps/host",
      entrypoint: "apps/host/lib/main.dart",
      packageEntrypoint: "lib/main.dart",
      storeProduct: {appStoreConnectAppId: "host-app"},
    },
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
        projectRoot: `apps/${role}`,
        entrypoint: `apps/${role}/lib/main_${environment}.dart`,
        packageEntrypoint: `lib/main_${environment}.dart`,
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

test("Apple signing settings require automatic signing without an identity override", () => {
  assert.deepEqual(
    validateAutomaticAppleSigningSettings({
      targetId: "host-prod",
      configurationName: "Release-host-prod",
      settings: {CODE_SIGN_STYLE: "Automatic"},
    }),
    [],
  );

  const findings = validateAutomaticAppleSigningSettings({
    targetId: "host-prod",
    configurationName: "Release-host-prod",
    settings: {
      CODE_SIGN_STYLE: "Manual",
      "CODE_SIGN_IDENTITY[sdk=iphoneos*]": "Apple Distribution",
    },
  });
  assert.ok(findings.some((finding) => finding.includes("CODE_SIGN_STYLE")));
  assert.ok(findings.some((finding) => finding.includes("defer CODE_SIGN_IDENTITY")));
});

function unifiedReleaseManifest() {
  const manifest = validManifest();
  manifest.releasePolicy = {
    owner: "github-actions",
    workflow: ".github/workflows/mobile-internal-release.yml",
    promotionWorkflow: ".github/workflows/mobile-internal-promote.yml",
    trigger: "successful-main-ci-exact-artifact-authority",
    environment: "prod-mobile",
    approvalMode: "build-only-no-store-mutation",
    branchPolicy: "main-only",
    roles: ["consumer", "host"],
    ios: {
      channel: "testflight",
      uploadMode: "separate-promotion-workflow",
      automaticRoles: [],
      signingStyle: "automatic",
      developmentIdentitySource: "reusable-ci-p12",
      distributionSigningStage: "export",
      uploadArtifact: "verified-ipa",
      uploadTool: "altool",
    },
    android: {
      channel: "play-internal",
      track: "qa",
      uploadMode: "separate-promotion-workflow",
      publisherAuth: "github-oidc",
      publisherServiceAccount: "github-actions-play-publisher@catch-dating-app-64e51.iam.gserviceaccount.com",
      uploadCertificateSha256: "A".repeat(64),
    },
  };
  for (const target of manifest.targets.filter((candidate) => candidate.environment === "prod")) {
    target.release = {
      owner: "github-actions",
      githubMode: "automatic-exact-artifact",
      githubWorkflow: ".github/workflows/mobile-internal-release.yml",
      automaticTestFlightOnMain: false,
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

const unifiedWorkflow = fs.readFileSync(
  new URL("../../.github/workflows/mobile-internal-release.yml", import.meta.url),
  "utf8",
);

test("release ownership accepts the exact-target producer and separate promoter", () => {
  const manifest = unifiedReleaseManifest();
  const result = validateReleaseOwnership({manifest, workflowSource: unifiedWorkflow});
  assert.deepEqual(result.findings, []);
  assert.equal(result.warnings.length, 2);
});

test("release ownership rejects reintroducing store mutation in the package producer", () => {
  const manifest = unifiedReleaseManifest();
  const workflowSource = `${unifiedWorkflow}\nxcrun altool --upload-package "$IPA_PATH"\n`;

  const result = validateReleaseOwnership({manifest, workflowSource});
  assert.ok(
    result.findings.some((finding) =>
      finding.includes("must not contain TestFlight upload"),
    ),
  );
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
  assert.ok(result.findings.some((finding) => finding.includes("Android target matrix")));
});

test("release ownership rejects an explicit iOS archive signing identity", () => {
  const manifest = unifiedReleaseManifest();
  const workflowSource = `${unifiedWorkflow}\nCODE_SIGN_IDENTITY=Apple Distribution\n`;

  const result = validateReleaseOwnership({manifest, workflowSource});
  assert.ok(
    result.findings.some((finding) =>
      finding.includes("defer CODE_SIGN_IDENTITY to Xcode automatic signing"),
    ),
  );
});

test("release ownership rejects a missing reusable iOS CI identity import", () => {
  const manifest = unifiedReleaseManifest();
  const workflowSource = unifiedWorkflow.replace(
    '          security import "$p12_path" \\\n',
    "          echo missing-identity-import \\\n",
  );

  const result = validateReleaseOwnership({manifest, workflowSource});
  assert.ok(
    result.findings.some((finding) =>
      finding.includes("non-extractable reusable iOS identity import"),
    ),
  );
});

test("release ownership rejects missing reusable iOS identity cleanup", () => {
  const manifest = unifiedReleaseManifest();
  const workflowSource = unifiedWorkflow.replace(
    '            security delete-keychain "$IOS_CI_KEYCHAIN_PATH" 2>/dev/null || true\n',
    "            echo cleanup-missing\n",
  );

  const result = validateReleaseOwnership({manifest, workflowSource});
  assert.ok(
    result.findings.some((finding) =>
      finding.includes("always-run reusable iOS identity cleanup"),
    ),
  );
});

test("release ownership rejects incomplete reusable iOS identity verification", () => {
  const manifest = unifiedReleaseManifest();
  const workflowSource = unifiedWorkflow
    .replace("-fingerprint -sha256", "-serial")
    .replace(
      '          if [[ "$actual_expiry_epoch" != "$configured_expiry_epoch" ]]; then\n',
      "          if false; then\n",
    )
    .replace("-checkend 2592000", "-noout");

  const result = validateReleaseOwnership({manifest, workflowSource});
  assert.ok(
    result.findings.some((finding) =>
      finding.includes("reusable iOS identity fingerprint derivation"),
    ),
  );
  assert.ok(
    result.findings.some((finding) =>
      finding.includes("reusable iOS identity validity floor"),
    ),
  );
  assert.ok(
    result.findings.some((finding) =>
      finding.includes("reusable iOS identity expiry metadata validation"),
    ),
  );
});

test("release ownership rejects re-exporting after IPA verification", () => {
  const manifest = unifiedReleaseManifest();
  const workflowSource = `${unifiedWorkflow}\nxcodebuild \\\n  -exportArchive\n`;

  const result = validateReleaseOwnership({manifest, workflowSource});
  assert.ok(
    result.findings.some((finding) =>
      finding.includes("must export exactly one IPA before verification and packaging"),
    ),
  );
});

test("release ownership rejects an unbound immutable package upload", () => {
  const manifest = unifiedReleaseManifest();
  const workflowSource = unifiedWorkflow.replaceAll(
    "package_mobile_release.mjs bind-upload",
    "package_mobile_release.mjs missing-upload-binding",
  );

  const result = validateReleaseOwnership({manifest, workflowSource});
  assert.ok(
    result.findings.some((finding) =>
      finding.includes("immutable package upload binding"),
    ),
  );
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
