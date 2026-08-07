import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import test from "node:test";
import {
  buildAndroidReleaseReceipt,
  collectAndroidBundleFindings,
  verifyJarSignature,
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

test("strict bundle signature verification rejects an added unsigned entry", (t) => {
  const required = ["jar", "jarsigner", "keytool"];
  if (required.some((command) => spawnSync(command, ["-help"]).error?.code === "ENOENT")) {
    t.skip("JDK signing tools are unavailable");
    return;
  }
  const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-android-signature-"));
  try {
    const content = path.join(tempRoot, "content");
    const bundle = path.join(tempRoot, "synthetic.aab");
    const keyStore = path.join(tempRoot, "test.jks");
    fs.mkdirSync(content);
    fs.writeFileSync(path.join(content, "signed.txt"), "signed");
    let result = spawnSync(
      "jar",
      ["--create", "--file", bundle, "-C", content, "signed.txt"],
      {encoding: "utf8"},
    );
    assert.equal(result.status, 0, result.stderr);
    result = spawnSync("keytool", [
      "-genkeypair", "-noprompt", "-alias", "test", "-keyalg", "RSA",
      "-dname", "CN=Catch Test", "-validity", "1", "-keystore", keyStore,
      "-storepass", "changeit", "-keypass", "changeit",
    ], {encoding: "utf8"});
    assert.equal(result.status, 0, result.stderr);
    result = spawnSync("jarsigner", [
      "-keystore", keyStore, "-storepass", "changeit", "-keypass", "changeit",
      bundle, "test",
    ], {encoding: "utf8"});
    assert.equal(result.status, 0, result.stderr);
    assert.equal(verifyJarSignature(bundle, {allowFailure: true}).status, 0);

    fs.writeFileSync(path.join(content, "unsigned.txt"), "unsigned");
    result = spawnSync(
      "jar",
      ["--update", "--file", bundle, "-C", content, "unsigned.txt"],
      {encoding: "utf8"},
    );
    assert.equal(result.status, 0, result.stderr);
    assert.notEqual(verifyJarSignature(bundle, {allowFailure: true}).status, 0);
  } finally {
    fs.rmSync(tempRoot, {recursive: true, force: true});
  }
});
