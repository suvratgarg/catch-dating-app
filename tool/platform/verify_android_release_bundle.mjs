#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {X509Certificate} from "node:crypto";
import {fileURLToPath} from "node:url";
import {
  defaultRepoRoot,
  loadAppTargets,
  resolveAppTarget,
} from "./resolve_app_target.mjs";

export function collectAndroidBundleFindings({
  target,
  applicationId,
  versionName,
  versionCode,
  appTargetId,
  appRole,
  firebaseAppId,
  firebaseProjectId,
  mapsKeyMatches,
  debuggable,
  signerFingerprint,
  expectedSignerFingerprint,
  expectedVersion,
  expectedBuild,
  signatureVerified,
}) {
  const findings = [];
  expectEqual(findings, "application id", applicationId, target.android.applicationId);
  expectEqual(findings, "version name", versionName, expectedVersion);
  expectEqual(findings, "version code", String(versionCode), String(expectedBuild));
  expectEqual(findings, "compiled app-target marker", appTargetId, target.id);
  expectEqual(findings, "compiled app-role marker", appRole, target.role);
  expectEqual(findings, "compiled Firebase app id", firebaseAppId, target.firebase.android.appId);
  expectEqual(findings, "compiled Firebase project id", firebaseProjectId, target.firebase.projectId);
  if (!mapsKeyMatches) findings.push("compiled Google Maps key did not match the protected prod key");
  if (String(debuggable).toLowerCase() === "true") findings.push("prod Android bundle is debuggable");
  if (!signatureVerified) findings.push("Android App Bundle signature verification failed");
  expectEqual(
    findings,
    "upload certificate SHA-256",
    normalizeFingerprint(signerFingerprint),
    normalizeFingerprint(expectedSignerFingerprint),
  );
  if (!/^\d+$/u.test(String(versionCode))) {
    findings.push(`version code '${versionCode}' is not a positive integer`);
  } else if (Number(versionCode) <= 0 || Number(versionCode) > 2100000000) {
    findings.push(`version code '${versionCode}' is outside Google Play's supported range`);
  }
  return findings;
}

export function buildAndroidReleaseReceipt({
  target,
  bundlePath,
  applicationId,
  versionName,
  versionCode,
  appTargetId,
  appRole,
  firebaseAppId,
  firebaseProjectId,
  signerFingerprint,
}) {
  return {
    $schema: "catch.android-release-identity/v1",
    targetId: target.id,
    role: target.role,
    environment: target.environment,
    flavor: target.android.flavor,
    applicationId,
    versionName,
    versionCode: Number(versionCode),
    compiledIdentity: {
      appTargetId,
      appRole,
      firebaseAppId,
      firebaseProjectId,
      mapsKeyVerified: true,
      debuggable: false,
    },
    bundle: path.basename(bundlePath),
    signatureVerified: true,
    uploadCertificateSha256: normalizeFingerprint(signerFingerprint),
    releaseOwner: target.release?.owner ?? null,
  };
}

export function verifyAndroidReleaseBundle({
  root = defaultRepoRoot,
  bundlePath,
  role,
  environment,
  expectedVersion,
  expectedBuild,
  bundletoolPath,
  expectedMapsKey = process.env.GOOGLE_MAPS_ANDROID_API_KEY_PROD,
  receiptPath,
}) {
  const manifest = loadAppTargets({root});
  const target = resolveAppTarget({manifest, role, environment});
  const resolvedBundle = path.resolve(root, bundlePath);
  if (!fs.existsSync(resolvedBundle)) {
    throw new Error(`Android App Bundle does not exist: ${resolvedBundle}`);
  }

  const bundletool = path.resolve(bundletoolPath || process.env.BUNDLETOOL_JAR || "");
  if (!bundletoolPath && !process.env.BUNDLETOOL_JAR) {
    throw new Error("Pass --bundletool or set BUNDLETOOL_JAR to a pinned bundletool jar");
  }
  if (!fs.existsSync(bundletool)) throw new Error(`bundletool jar does not exist: ${bundletool}`);
  const resolvedMapsKey = resolveExpectedMapsKey(root, expectedMapsKey);
  if (!resolvedMapsKey) {
    throw new Error("GOOGLE_MAPS_ANDROID_API_KEY_PROD is required for compiled Maps verification");
  }

  const signature = run("jarsigner", ["-verify", resolvedBundle], {allowFailure: true});
  const signerFingerprint = readSignerFingerprint(resolvedBundle);
  const applicationId = dumpManifestValue(bundletool, resolvedBundle, "/manifest/@package");
  const versionName = dumpManifestValue(bundletool, resolvedBundle, "/manifest/@android:versionName");
  const versionCode = dumpManifestValue(bundletool, resolvedBundle, "/manifest/@android:versionCode");
  const appTargetId = dumpManifestValue(
    bundletool,
    resolvedBundle,
    "/manifest/application/meta-data[@android:name='com.catchdates.app.APP_TARGET_ID']/@android:value",
  );
  const appRole = dumpManifestValue(
    bundletool,
    resolvedBundle,
    "/manifest/application/meta-data[@android:name='com.catchdates.app.APP_ROLE']/@android:value",
  );
  const firebaseAppId = dumpManifestValue(
    bundletool,
    resolvedBundle,
    "/manifest/application/meta-data[@android:name='com.catchdates.app.FIREBASE_APP_ID']/@android:value",
  );
  const firebaseProjectId = dumpManifestValue(
    bundletool,
    resolvedBundle,
    "/manifest/application/meta-data[@android:name='com.catchdates.app.FIREBASE_PROJECT_ID']/@android:value",
  );
  const mapsKey = dumpManifestValue(
    bundletool,
    resolvedBundle,
    "/manifest/application/meta-data[@android:name='com.google.android.geo.API_KEY']/@android:value",
  );
  const debuggable = dumpManifestValue(
    bundletool,
    resolvedBundle,
    "/manifest/application/@android:debuggable",
  );
  const expectedSignerFingerprint = manifest.releasePolicy?.android?.uploadCertificateSha256;
  const findings = collectAndroidBundleFindings({
    target,
    applicationId,
    versionName,
    versionCode,
    appTargetId,
    appRole,
    firebaseAppId,
    firebaseProjectId,
    mapsKeyMatches: mapsKey === resolvedMapsKey,
    debuggable,
    signerFingerprint,
    expectedSignerFingerprint,
    expectedVersion,
    expectedBuild,
    signatureVerified: signature.status === 0,
  });
  if (findings.length > 0) {
    throw new Error(`Android release identity verification failed:\n- ${findings.join("\n- ")}`);
  }

  const receipt = buildAndroidReleaseReceipt({
    target,
    bundlePath: resolvedBundle,
    applicationId,
    versionName,
    versionCode,
    appTargetId,
    appRole,
    firebaseAppId,
    firebaseProjectId,
    signerFingerprint,
  });
  if (receiptPath) {
    const resolvedReceipt = path.resolve(root, receiptPath);
    fs.mkdirSync(path.dirname(resolvedReceipt), {recursive: true});
    fs.writeFileSync(resolvedReceipt, `${JSON.stringify(receipt, null, 2)}\n`);
  }
  return receipt;
}

function dumpManifestValue(bundletoolPath, bundlePath, xpath) {
  return run("java", [
    "-jar",
    bundletoolPath,
    "dump",
    "manifest",
    `--bundle=${bundlePath}`,
    "--module=base",
    `--xpath=${xpath}`,
  ]).trim();
}

function readSignerFingerprint(bundlePath) {
  const certificateOutput = run("keytool", [
    "-printcert",
    "-jarfile",
    bundlePath,
    "-rfc",
  ]);
  const certificate = certificateOutput.match(
    /-----BEGIN CERTIFICATE-----[\s\S]+?-----END CERTIFICATE-----/u,
  )?.[0];
  if (!certificate) throw new Error("Could not read the Android App Bundle signer certificate");
  return normalizeFingerprint(new X509Certificate(certificate).fingerprint256);
}

function normalizeFingerprint(value) {
  return String(value ?? "").replaceAll(":", "").replaceAll(/\s/gu, "").toUpperCase();
}

function resolveExpectedMapsKey(root, provided) {
  if (provided?.trim()) return provided.trim();
  const localPropertiesPath = path.join(root, "android", "local.properties");
  if (!fs.existsSync(localPropertiesPath)) return "";
  const match = fs
    .readFileSync(localPropertiesPath, "utf8")
    .match(/^GOOGLE_MAPS_ANDROID_API_KEY_PROD=(.+)$/mu);
  return match?.[1]?.trim() ?? "";
}

function run(command, args, {allowFailure = false} = {}) {
  const result = spawnSync(command, args, {encoding: "utf8"});
  if (result.error) throw result.error;
  if (!allowFailure && result.status !== 0) {
    throw new Error(`${command} ${args.join(" ")} failed: ${(result.stderr || result.stdout).trim()}`);
  }
  return allowFailure ? result : result.stdout;
}

function expectEqual(findings, label, actual, expected) {
  if (String(actual) !== String(expected)) {
    findings.push(`${label} was '${actual}'; expected '${expected}'`);
  }
}

function parseArgs(argv) {
  const options = {};
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    const value = argv[index + 1];
    if (["--bundle", "--role", "--environment", "--expected-version", "--expected-build", "--bundletool", "--receipt"].includes(arg)) {
      if (!value) throw new Error(`${arg} requires a value`);
      options[arg.slice(2).replaceAll("-", "_")] = value;
      index += 1;
    } else if (arg === "--help" || arg === "-h") {
      options.help = true;
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return options;
}

function printHelp() {
  console.log(`Usage: node tool/platform/verify_android_release_bundle.mjs \\
  --bundle <app.aab> --role <consumer|host> --environment prod \\
  --expected-version <version> --expected-build <integer> \\
  --bundletool <bundletool.jar> [--receipt <path>]`);
}

const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  try {
    const args = parseArgs(process.argv.slice(2));
    if (args.help) {
      printHelp();
      process.exit(0);
    }
    for (const required of ["bundle", "role", "environment", "expected_version", "expected_build"]) {
      if (!args[required]) throw new Error(`--${required.replaceAll("_", "-")} is required`);
    }
    const receipt = verifyAndroidReleaseBundle({
      bundlePath: args.bundle,
      role: args.role,
      environment: args.environment,
      expectedVersion: args.expected_version,
      expectedBuild: args.expected_build,
      bundletoolPath: args.bundletool,
      receiptPath: args.receipt,
    });
    console.log(`Verified ${receipt.targetId} Android App Bundle ${receipt.versionName} (${receipt.versionCode}).`);
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}
