import assert from "node:assert/strict";
import test from "node:test";
import {
  buildAndroidReleaseReceipt,
  collectAndroidBundleFindings,
} from "./verify_android_release_bundle.mjs";

const target = {
  id: "host-prod",
  role: "host",
  environment: "prod",
  firebase: {
    projectId: "catch-prod",
    android: {appId: "firebase-host-app"},
  },
  android: {flavor: "hostProd", applicationId: "com.catchdates.host"},
  release: {owner: "github-actions"},
};

const matchingIdentity = {
  appTargetId: "host-prod",
  appRole: "host",
  firebaseAppId: "firebase-host-app",
  firebaseProjectId: "catch-prod",
  mapsKeyMatches: true,
  debuggable: "",
  signerFingerprint: "AA:BB:CC",
  expectedSignerFingerprint: "AABBCC",
};

test("Android release verifier accepts matching signed target identity", () => {
  assert.deepEqual(collectAndroidBundleFindings({
    target,
    applicationId: "com.catchdates.host",
    versionName: "1.2.3",
    versionCode: "100021",
    expectedVersion: "1.2.3",
    expectedBuild: "100021",
    signatureVerified: true,
    ...matchingIdentity,
  }), []);
});

test("Android release verifier rejects wrong role identity and unsigned bundles", () => {
  const findings = collectAndroidBundleFindings({
    target,
    applicationId: "com.catchdates.app",
    versionName: "1.2.3",
    versionCode: "100021",
    expectedVersion: "1.2.3",
    expectedBuild: "100021",
    signatureVerified: false,
    ...matchingIdentity,
    appTargetId: "consumer-prod",
    appRole: "consumer",
  });
  assert.ok(findings.some((finding) => finding.includes("application id")));
  assert.ok(findings.includes("Android App Bundle signature verification failed"));
  assert.ok(findings.some((finding) => finding.includes("compiled app-target marker")));
});

test("Android release verifier rejects Play-invalid version codes", () => {
  const findings = collectAndroidBundleFindings({
    target,
    applicationId: "com.catchdates.host",
    versionName: "1.2.3",
    versionCode: "2100000001",
    expectedVersion: "1.2.3",
    expectedBuild: "2100000001",
    signatureVerified: true,
    ...matchingIdentity,
  });
  assert.ok(findings.some((finding) => finding.includes("supported range")));
});

test("Android release verifier rejects signer, Maps, Firebase, and debug drift", () => {
  const findings = collectAndroidBundleFindings({
    target,
    applicationId: "com.catchdates.host",
    versionName: "1.2.3",
    versionCode: "100021",
    expectedVersion: "1.2.3",
    expectedBuild: "100021",
    signatureVerified: true,
    ...matchingIdentity,
    firebaseAppId: "wrong-app",
    mapsKeyMatches: false,
    debuggable: "true",
    signerFingerprint: "DEADBEEF",
  });
  for (const marker of ["Firebase app id", "Maps key", "debuggable", "certificate SHA-256"]) {
    assert.ok(
      findings.some((finding) => finding.includes(marker)),
      `missing finding for ${marker}: ${findings.join("; ")}`,
    );
  }
});

test("Android release receipt records role, flavor, and release owner", () => {
  const receipt = buildAndroidReleaseReceipt({
    target,
    bundlePath: "/tmp/app.aab",
    applicationId: "com.catchdates.host",
    versionName: "1.2.3",
    versionCode: "100021",
    appTargetId: "host-prod",
    appRole: "host",
    firebaseAppId: "firebase-host-app",
    firebaseProjectId: "catch-prod",
    signerFingerprint: "AA:BB:CC",
  });
  assert.equal(receipt.targetId, "host-prod");
  assert.equal(receipt.flavor, "hostProd");
  assert.equal(receipt.releaseOwner, "github-actions");
  assert.equal(receipt.signatureVerified, true);
  assert.equal(receipt.uploadCertificateSha256, "AABBCC");
  assert.equal(receipt.compiledIdentity.firebaseAppId, "firebase-host-app");
});
