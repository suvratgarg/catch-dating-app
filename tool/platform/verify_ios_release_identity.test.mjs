#!/usr/bin/env node

import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import test from "node:test";
import {fileURLToPath} from "node:url";
import {
  collectReleaseIdentityFindings,
  parseFlutterBuildXcconfig,
  readArchiveInfoPlist,
  resolveReleaseTarget,
} from "./verify_ios_release_identity.mjs";

const manifest = {
  targets: [
    {
      id: "consumer-prod",
      role: "consumer",
      environment: "prod",
      displayName: "Catch",
      entrypoint: "lib/main_consumer_prod.dart",
      firebase: {
        projectId: "catch-prod",
        ios: {appId: "consumer-firebase-app"},
      },
      ios: {
        scheme: "prod",
        bundleId: "com.catchdates.app",
        urlScheme: "consumer-url-scheme",
      },
    },
    {
      id: "host-prod",
      role: "host",
      environment: "prod",
      displayName: "Catch Host",
      entrypoint: "lib/main_host_prod.dart",
      firebase: {
        projectId: "catch-prod",
        ios: {appId: "host-firebase-app"},
      },
      ios: {
        scheme: "host-prod",
        bundleId: "com.catchdates.host",
        urlScheme: "host-url-scheme",
      },
    },
  ],
};

const consumerTarget = manifest.targets[0];
const hostTarget = manifest.targets[1];

const baseConsumerEntitlements = {
  "aps-environment": "$(APS_ENVIRONMENT)",
  "com.apple.developer.devicecheck.appattest-environment":
    "$(APP_ATTEST_ENVIRONMENT)",
  "com.apple.developer.associated-domains": ["applinks:catchdates.com"],
  "com.apple.developer.healthkit": true,
};

const baseSignedConsumerEntitlements = {
  "application-identifier": "TEAM123.com.catchdates.app",
  "com.apple.developer.team-identifier": "TEAM123",
  "aps-environment": "production",
  "com.apple.developer.devicecheck.appattest-environment": "production",
  "com.apple.developer.associated-domains": ["applinks:catchdates.com"],
  "com.apple.developer.healthkit": true,
  "get-task-allow": false,
};

function appInfoFor(target) {
  return {
    CFBundleIdentifier: target.ios.bundleId,
    CFBundleDisplayName: target.displayName,
    CatchAppTargetID: target.id,
    CatchFlutterTarget: `/repo/${target.entrypoint}`,
    CFBundleURLTypes: [{CFBundleURLSchemes: [target.ios.urlScheme]}],
    CFBundleShortVersionString: "1.2.3",
    CFBundleVersion: "202607101",
  };
}

function firebaseInfoFor(target) {
  return {
    BUNDLE_ID: target.ios.bundleId,
    GOOGLE_APP_ID: target.firebase.ios.appId,
    PROJECT_ID: target.firebase.projectId,
  };
}

function archiveInfoFor(target) {
  return {ApplicationProperties: appInfoFor(target)};
}

test("resolves one target from manifest selectors", () => {
  assert.equal(
    resolveReleaseTarget({manifest, role: "host", environment: "prod"}).id,
    "host-prod",
  );
  assert.equal(resolveReleaseTarget({manifest, scheme: "prod"}).id, "consumer-prod");
  assert.throws(() => resolveReleaseTarget({manifest, environment: "prod"}));
});

test("reads the expected Flutter marketing version and build", () => {
  assert.deepEqual(
    parseFlutterBuildXcconfig(
      "OTHER=value\nFLUTTER_BUILD_NAME=1.2.3\nFLUTTER_BUILD_NUMBER=202607101\n",
    ),
    {version: "1.2.3", build: "202607101"},
  );
});

test(
  "reads archive identity when the root plist contains an Xcode creation date",
  {skip: process.platform !== "darwin"},
  () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-ios-archive-plist-"));
    try {
      const plistPath = path.join(tempRoot, "Info.plist");
      fs.writeFileSync(
        plistPath,
        `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>ApplicationProperties</key>
  <dict>
    <key>CFBundleIdentifier</key>
    <string>com.catchdates.app</string>
    <key>CFBundleShortVersionString</key>
    <string>1.2.3</string>
    <key>CFBundleVersion</key>
    <string>202607101</string>
  </dict>
  <key>CreationDate</key>
  <date>2026-07-11T17:28:59Z</date>
</dict>
</plist>
`,
      );
      assert.deepEqual(readArchiveInfoPlist(plistPath), {
        ApplicationProperties: {
          CFBundleIdentifier: "com.catchdates.app",
          CFBundleShortVersionString: "1.2.3",
          CFBundleVersion: "202607101",
        },
      });
    } finally {
      fs.rmSync(tempRoot, {recursive: true, force: true});
    }
  },
);

test("accepts a matching Consumer archive identity", () => {
  assert.deepEqual(
    collectReleaseIdentityFindings({
      target: consumerTarget,
      roleEntitlements: baseConsumerEntitlements,
      appInfo: appInfoFor(consumerTarget),
      firebaseInfo: firebaseInfoFor(consumerTarget),
      archiveInfo: archiveInfoFor(consumerTarget),
      signedEntitlements: baseSignedConsumerEntitlements,
      expectedVersion: "1.2.3",
      expectedBuild: "202607101",
    }),
    [],
  );
});

test("accepts Host without Consumer-only capabilities", () => {
  const roleEntitlements = {
    "aps-environment": "$(APS_ENVIRONMENT)",
    "com.apple.developer.devicecheck.appattest-environment":
      "$(APP_ATTEST_ENVIRONMENT)",
  };
  const signedEntitlements = {
    "application-identifier": "TEAM123.com.catchdates.host",
    "com.apple.developer.team-identifier": "TEAM123",
    "aps-environment": "production",
    "com.apple.developer.devicecheck.appattest-environment": "production",
  };
  assert.deepEqual(
    collectReleaseIdentityFindings({
      target: hostTarget,
      roleEntitlements,
      appInfo: appInfoFor(hostTarget),
      firebaseInfo: firebaseInfoFor(hostTarget),
      archiveInfo: archiveInfoFor(hostTarget),
      signedEntitlements,
      expectedVersion: "1.2.3",
      expectedBuild: "202607101",
    }),
    [],
  );
});

test("rejects Host inheriting Consumer-only capabilities", () => {
  const findings = collectReleaseIdentityFindings({
    target: hostTarget,
    roleEntitlements: {
      "aps-environment": "$(APS_ENVIRONMENT)",
      "com.apple.developer.devicecheck.appattest-environment":
        "$(APP_ATTEST_ENVIRONMENT)",
    },
    appInfo: appInfoFor(hostTarget),
    firebaseInfo: firebaseInfoFor(hostTarget),
    archiveInfo: archiveInfoFor(hostTarget),
    signedEntitlements: {
      ...baseSignedConsumerEntitlements,
      "application-identifier": "TEAM123.com.catchdates.host",
    },
    expectedVersion: "1.2.3",
    expectedBuild: "202607101",
  });
  assert.ok(findings.some((finding) => finding.includes("forbidden entitlement")));
});

test("rejects a Host archive compiled from the Consumer entrypoint", () => {
  const findings = collectReleaseIdentityFindings({
    target: hostTarget,
    roleEntitlements: {
      "aps-environment": "$(APS_ENVIRONMENT)",
      "com.apple.developer.devicecheck.appattest-environment":
        "$(APP_ATTEST_ENVIRONMENT)",
    },
    appInfo: {
      ...appInfoFor(hostTarget),
      CatchAppTargetID: "consumer-prod",
      CatchFlutterTarget: "/repo/lib/main_consumer_prod.dart",
    },
    firebaseInfo: firebaseInfoFor(hostTarget),
    archiveInfo: archiveInfoFor(hostTarget),
    signedEntitlements: {
      "application-identifier": "TEAM123.com.catchdates.host",
      "com.apple.developer.team-identifier": "TEAM123",
      "aps-environment": "production",
      "com.apple.developer.devicecheck.appattest-environment": "production",
    },
    expectedVersion: "1.2.3",
    expectedBuild: "202607101",
  });
  assert.ok(findings.some((finding) => finding.includes("app target marker")));
  assert.ok(findings.some((finding) => finding.includes("Flutter target")));
});

test("rejects Host Firebase and OAuth URL identity drift", () => {
  const findings = collectReleaseIdentityFindings({
    target: hostTarget,
    roleEntitlements: {
      "aps-environment": "$(APS_ENVIRONMENT)",
      "com.apple.developer.devicecheck.appattest-environment":
        "$(APP_ATTEST_ENVIRONMENT)",
    },
    appInfo: {
      ...appInfoFor(hostTarget),
      CFBundleURLTypes: [{CFBundleURLSchemes: [consumerTarget.ios.urlScheme]}],
    },
    firebaseInfo: firebaseInfoFor(consumerTarget),
    archiveInfo: archiveInfoFor(hostTarget),
    signedEntitlements: {
      "application-identifier": "TEAM123.com.catchdates.host",
      "com.apple.developer.team-identifier": "TEAM123",
      "aps-environment": "production",
      "com.apple.developer.devicecheck.appattest-environment": "production",
    },
    expectedVersion: "1.2.3",
    expectedBuild: "202607101",
  });
  for (const marker of [
    "URL schemes",
    "Firebase bundle identifier",
    "Firebase app id",
  ]) {
    assert.ok(
      findings.some((finding) => finding.includes(marker)),
      `missing finding for ${marker}: ${findings.join("; ")}`,
    );
  }
});

test("rejects bundle, version, build, archive metadata, and signing drift", () => {
  const findings = collectReleaseIdentityFindings({
    target: consumerTarget,
    roleEntitlements: baseConsumerEntitlements,
    appInfo: {
      ...appInfoFor(consumerTarget),
      CFBundleIdentifier: "com.catchdates.host",
      CFBundleShortVersionString: "1.2.4",
      CFBundleVersion: "2",
    },
    firebaseInfo: firebaseInfoFor(consumerTarget),
    archiveInfo: archiveInfoFor(consumerTarget),
    signedEntitlements: {
      ...baseSignedConsumerEntitlements,
      "application-identifier": "TEAM123.com.catchdates.host",
      "aps-environment": "development",
      "get-task-allow": true,
    },
    expectedVersion: "1.2.3",
    expectedBuild: "202607101",
  });
  for (const marker of [
    "bundle identifier",
    "marketing version",
    "build number",
    "application-identifier",
    "must be 'production'",
    "get-task-allow=true",
  ]) {
    assert.ok(
      findings.some((finding) => finding.includes(marker)),
      `missing finding for ${marker}: ${findings.join("; ")}`,
    );
  }
});

test("CLI verifies a synthetic Host archive and writes a receipt", () => {
  const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-ios-release-"));
  try {
    const archivePath = path.join(tempRoot, "Host.xcarchive");
    const appPath = path.join(
      archivePath,
      "Products",
      "Applications",
      "Catch Host.app",
    );
    fs.mkdirSync(appPath, {recursive: true});
    const infoPath = path.join(appPath, "Info.plist");
    const firebaseInfoPath = path.join(appPath, "GoogleService-Info.plist");
    const archiveInfoPath = path.join(archivePath, "Info.plist");
    const entitlementsPath = path.join(tempRoot, "entitlements.plist");
    const receiptPath = path.join(tempRoot, "receipt.json");
    writeXmlPlist(infoPath, {
      ...appInfoFor(hostTarget),
      CFBundleURLTypes: [
        {
          CFBundleURLSchemes: [
            "app-1-574779808785-ios-dafe636b607e071f8ea5b0",
          ],
        },
      ],
    });
    writeXmlPlist(firebaseInfoPath, {
      BUNDLE_ID: "com.catchdates.host",
      GOOGLE_APP_ID: "1:574779808785:ios:dafe636b607e071f8ea5b0",
      PROJECT_ID: "catch-dating-app-64e51",
    });
    writeXmlPlist(archiveInfoPath, archiveInfoFor(hostTarget));
    writeXmlPlist(entitlementsPath, {
      "application-identifier": "TEAM123.com.catchdates.host",
      "com.apple.developer.team-identifier": "TEAM123",
      "aps-environment": "production",
      "com.apple.developer.devicecheck.appattest-environment": "production",
    });

    const scriptPath = fileURLToPath(
      new URL("./verify_ios_release_identity.mjs", import.meta.url),
    );
    const result = spawnSync(
      process.execPath,
      [
        scriptPath,
        "--archive",
        archivePath,
        "--role",
        "host",
        "--environment",
        "prod",
        "--expected-version",
        "1.2.3",
        "--expected-build",
        "202607101",
        "--entitlements-plist",
        entitlementsPath,
        "--receipt",
        receiptPath,
      ],
      {encoding: "utf8"},
    );
    assert.equal(result.status, 0, result.stderr);
    const receipt = JSON.parse(fs.readFileSync(receiptPath, "utf8"));
    assert.equal(receipt.targetId, "host-prod");
    assert.equal(receipt.bundleIdentifier, "com.catchdates.host");
  } finally {
    fs.rmSync(tempRoot, {recursive: true, force: true});
  }
});

function writeXmlPlist(targetPath, value) {
  fs.writeFileSync(targetPath, `${JSON.stringify(value)}\n`);
}
