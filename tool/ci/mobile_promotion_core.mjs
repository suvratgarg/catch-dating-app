#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {
  validateMobileBuildAuthority,
  verifyMobilePackage,
} from "./package_mobile_release.mjs";

export const MOBILE_PROMOTION_RECEIPT_SCHEMA = "catch.mobile-promotion-receipt/v1";
// Xcode preserves product display names in exported IPA filenames (for example,
// `Catch Host.ipa`). Spaces are safe because the package verifier already
// requires a basename-only regular file and every workflow use is quoted. Keep
// shell metacharacters, path separators, leading dots, and trailing spaces out.
const SAFE_ARTIFACT_RE =
  /^[A-Za-z0-9](?:[A-Za-z0-9 ._-]*[A-Za-z0-9_-])?\.(?:aab|ipa)$/u;
const IOS_VERSION_RE = /^\d+(?:\.\d+){0,2}$/u;
const ANDROID_VERSION_NAME_RE = /^[A-Za-z0-9][A-Za-z0-9._+-]*$/u;
const SHA_RE = /^[0-9a-f]{40}$/u;
const DIGEST_RE = /^[0-9a-f]{64}$/u;
const API_DIGEST_RE = /^sha256:[0-9a-f]{64}$/u;
const DECIMAL_ID_RE = /^[1-9][0-9]*$/u;

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function readRegularJson(filePath, label) {
  const resolved = path.resolve(filePath);
  const stat = fs.lstatSync(resolved);
  assert(stat.isFile() && !stat.isSymbolicLink(),
    `${label} must be a regular non-symlink file.`);
  try {
    return JSON.parse(fs.readFileSync(resolved, "utf8"));
  } catch (error) {
    throw new Error(`Cannot parse ${label}: ${error.message}`);
  }
}

function requestedTarget(value) {
  const match = /^(consumer|host)-(android|ios)$/u.exec(value ?? "");
  assert(match,
    "release target must be consumer-android, consumer-ios, host-android, or host-ios.");
  return {releaseTarget: value, role: match[1], platform: match[2]};
}

function decimalIdentifier(value, label) {
  const normalized = typeof value === "number" && Number.isSafeInteger(value)
    ? String(value)
    : value;
  assert(typeof normalized === "string" && DECIMAL_ID_RE.test(normalized),
    `${label} must be a positive decimal identifier.`);
  return normalized;
}

function digest(value, label, pattern = DIGEST_RE) {
  assert(typeof value === "string" && pattern.test(value), `${label} is invalid.`);
  return value;
}

function safeText(value, label) {
  assert(typeof value === "string" && value.length > 0 && value.length <= 300 &&
    !/[\r\n\0]/u.test(value), `${label} must be a short single-line string.`);
  return value;
}

export function selectMobilePromotion({
  authority,
  releaseTarget,
  expectedProducerRunId,
  expectedProducerRunAttempt,
  expectedSourceSha,
}) {
  const requested = requestedTarget(releaseTarget);
  const validated = validateMobileBuildAuthority(authority, {
    producerRunId: expectedProducerRunId,
    producerRunAttempt: expectedProducerRunAttempt,
    sourceSha: expectedSourceSha,
  });
  assert(validated.releaseTargets.includes(releaseTarget),
    `Mobile build authority does not authorize ${releaseTarget}.`);
  const matches = validated.packages.filter(
    (entry) => entry.releaseTarget === releaseTarget,
  );
  assert(matches.length === 1,
    `Mobile build authority must contain exactly one package for ${releaseTarget}.`);
  const selected = matches[0];
  const authorityArtifactName =
    `mobile-build-authority-v1-${validated.sourceCiWorkflowId}-` +
    `${validated.sourceCiRunNumber}-${validated.sourceCiRunId}-` +
    `${validated.sourceCiRunAttempt}-${validated.sourceSha}-` +
    `${validated.producerRunId}-${validated.producerRunAttempt}`;
  return {
    authorityArtifactName,
    sourceCiWorkflowId: validated.sourceCiWorkflowId,
    sourceCiRunNumber: validated.sourceCiRunNumber,
    sourceCiRunId: validated.sourceCiRunId,
    sourceCiRunAttempt: validated.sourceCiRunAttempt,
    sourceSha: validated.sourceSha,
    producerRunId: validated.producerRunId,
    producerRunAttempt: validated.producerRunAttempt,
    releaseTarget,
    role: requested.role,
    platform: requested.platform,
    artifactSha256: selected.artifactSha256,
    provenanceManifestSha256: selected.provenanceManifestSha256,
    packageArtifact: selected.packageArtifact,
  };
}

export async function verifyMobilePromotionPackage({
  authority,
  packageDir,
  releaseTarget,
  expectedProducerRunId,
  expectedProducerRunAttempt,
  expectedSourceSha,
}) {
  const selection = selectMobilePromotion({
    authority,
    releaseTarget,
    expectedProducerRunId,
    expectedProducerRunAttempt,
    expectedSourceSha,
  });
  const receipt = await verifyMobilePackage({
    packageDir,
    releaseTarget,
    expectedSourceSha: selection.sourceSha,
    expectedSourceCiRunId: selection.sourceCiRunId,
    expectedSourceCiRunAttempt: selection.sourceCiRunAttempt,
    expectedProducerRunId: selection.producerRunId,
    expectedProducerRunAttempt: selection.producerRunAttempt,
  });
  assert(receipt.artifact.sha256 === selection.artifactSha256,
    "Signed artifact digest does not match the mobile build authority.");
  assert(receipt.provenance.manifestSha256 === selection.provenanceManifestSha256,
    "Provenance manifest digest does not match the mobile build authority.");
  assert(SAFE_ARTIFACT_RE.test(receipt.artifact.name),
    "Signed artifact name is not safe for exact promotion.");

  const identity = readRegularJson(
    path.join(packageDir, "identity-receipt.json"),
    "mobile identity receipt",
  );
  let storeIdentity;
  if (selection.platform === "ios") {
    assert(typeof identity.bundleIdentifier === "string" &&
      /^[A-Za-z0-9][A-Za-z0-9.-]*$/u.test(identity.bundleIdentifier),
    "iOS identity receipt has an invalid bundle identifier.");
    assert(IOS_VERSION_RE.test(identity.version),
      "iOS identity receipt has an invalid marketing version.");
    assert(IOS_VERSION_RE.test(identity.build),
      "iOS identity receipt has an invalid build number.");
    storeIdentity = {
      bundleIdentifier: identity.bundleIdentifier,
      version: identity.version,
      build: identity.build,
    };
  } else {
    assert(typeof identity.applicationId === "string" &&
      /^[A-Za-z0-9][A-Za-z0-9._]*$/u.test(identity.applicationId),
    "Android identity receipt has an invalid application id.");
    assert(ANDROID_VERSION_NAME_RE.test(identity.versionName),
      "Android identity receipt has an invalid version name.");
    assert(Number.isSafeInteger(identity.versionCode) &&
      identity.versionCode > 0 && identity.versionCode <= 2_100_000_000,
    "Android identity receipt has an invalid version code.");
    storeIdentity = {
      applicationId: identity.applicationId,
      versionName: identity.versionName,
      versionCode: identity.versionCode,
    };
  }
  return {
    ...selection,
    artifactName: receipt.artifact.name,
    artifactSizeBytes: receipt.artifact.sizeBytes,
    storeIdentity,
  };
}

export function createMobilePromotionReceipt({
  releaseTarget,
  sourceSha,
  sourceCiRunId,
  sourceCiRunAttempt,
  producerRunId,
  producerRunAttempt,
  authorityArtifact,
  packageArtifact,
  signedArtifactSha256,
  promotionRunId,
  promotionRunAttempt,
  reasonSha256,
  storeChannel,
  storeTarget,
  storeVersion,
  storeBuild,
  storeResult,
  storeRemoteId,
  evidenceLevel,
}) {
  const selected = requestedTarget(releaseTarget);
  const descriptor = (value, label) => {
    assert(value && typeof value === "object" && !Array.isArray(value),
      `${label} must be an object.`);
    const keys = Object.keys(value).sort();
    assert(JSON.stringify(keys) === JSON.stringify(["digest", "id", "name"]),
      `${label} must contain exactly digest, id, and name.`);
    return {
      id: decimalIdentifier(value.id, `${label} id`),
      name: safeText(value.name, `${label} name`),
      digest: digest(value.digest, `${label} digest`, API_DIGEST_RE),
    };
  };
  assert(SHA_RE.test(sourceSha), "Promotion receipt source SHA is invalid.");
  digest(signedArtifactSha256, "signed artifact SHA-256");
  digest(reasonSha256, "reason SHA-256");
  assert(["uploaded", "already-promoted", "reconciled"].includes(storeResult),
    "Store result must be uploaded, already-promoted, or reconciled.");
  assert(evidenceLevel === "exact-artifact",
    "Exact promotion receipts require exact-artifact evidence.");
  if (selected.platform === "ios") {
    assert(storeResult === "uploaded",
      "iOS exact-artifact receipts must be rooted in this workflow's fresh upload.");
  }
  const expectedChannel = selected.platform === "ios" ? "testflight" : "play-qa";
  assert(storeChannel === expectedChannel,
    `Store channel for ${releaseTarget} must be ${expectedChannel}.`);
  const normalizedPackageArtifact = descriptor(packageArtifact, "package artifact");
  const claimArtifactName =
    `mobile-promotion-claim-v1-${releaseTarget}-` +
    `${normalizedPackageArtifact.id}-${signedArtifactSha256}`;
  return {
    schema: MOBILE_PROMOTION_RECEIPT_SCHEMA,
    claimArtifactName,
    releaseTarget,
    role: selected.role,
    platform: selected.platform,
    sourceSha,
    sourceCiRunId: decimalIdentifier(sourceCiRunId, "source CI run id"),
    sourceCiRunAttempt: decimalIdentifier(sourceCiRunAttempt, "source CI run attempt"),
    producerRunId: decimalIdentifier(producerRunId, "producer run id"),
    producerRunAttempt: decimalIdentifier(producerRunAttempt, "producer run attempt"),
    authorityArtifact: descriptor(authorityArtifact, "authority artifact"),
    packageArtifact: normalizedPackageArtifact,
    signedArtifactSha256,
    promotionRunId: decimalIdentifier(promotionRunId, "promotion run id"),
    promotionRunAttempt: decimalIdentifier(promotionRunAttempt, "promotion run attempt"),
    reasonSha256,
    evidenceLevel,
    store: {
      channel: storeChannel,
      target: safeText(storeTarget, "store target"),
      version: safeText(storeVersion, "store version"),
      build: safeText(storeBuild, "store build"),
      result: storeResult,
      remoteId: safeText(storeRemoteId, "store remote id"),
    },
  };
}

export function validateMobilePromotionReceipt(receipt, expected = {}) {
  assert(receipt && typeof receipt === "object" && !Array.isArray(receipt),
    "Promotion receipt must be an object.");
  assert(receipt.schema === MOBILE_PROMOTION_RECEIPT_SCHEMA,
    "Promotion receipt schema is invalid.");
  const canonical = createMobilePromotionReceipt({
    releaseTarget: receipt.releaseTarget,
    sourceSha: receipt.sourceSha,
    sourceCiRunId: receipt.sourceCiRunId,
    sourceCiRunAttempt: receipt.sourceCiRunAttempt,
    producerRunId: receipt.producerRunId,
    producerRunAttempt: receipt.producerRunAttempt,
    authorityArtifact: receipt.authorityArtifact,
    packageArtifact: receipt.packageArtifact,
    signedArtifactSha256: receipt.signedArtifactSha256,
    promotionRunId: receipt.promotionRunId,
    promotionRunAttempt: receipt.promotionRunAttempt,
    reasonSha256: receipt.reasonSha256,
    storeChannel: receipt.store?.channel,
    storeTarget: receipt.store?.target,
    storeVersion: receipt.store?.version,
    storeBuild: receipt.store?.build,
    storeResult: receipt.store?.result,
    storeRemoteId: receipt.store?.remoteId,
    evidenceLevel: receipt.evidenceLevel,
  });
  assert(JSON.stringify(receipt) === JSON.stringify(canonical),
    "Promotion receipt contains non-canonical or unexpected fields.");

  const bindings = {
    releaseTarget: canonical.releaseTarget,
    sourceSha: canonical.sourceSha,
    sourceCiRunId: canonical.sourceCiRunId,
    sourceCiRunAttempt: canonical.sourceCiRunAttempt,
    producerRunId: canonical.producerRunId,
    producerRunAttempt: canonical.producerRunAttempt,
    signedArtifactSha256: canonical.signedArtifactSha256,
    authorityArtifact: canonical.authorityArtifact,
    packageArtifact: canonical.packageArtifact,
    storeChannel: canonical.store.channel,
    storeTarget: canonical.store.target,
    storeVersion: canonical.store.version,
    storeBuild: canonical.store.build,
  };
  for (const [key, value] of Object.entries(expected)) {
    assert(JSON.stringify(bindings[key]) === JSON.stringify(value),
      `Promotion receipt ${key} does not match the requested exact package.`);
  }
  return canonical;
}

function parseArgs(argv) {
  const [command, ...rest] = argv;
  const values = {};
  for (let index = 0; index < rest.length; index += 2) {
    const flag = rest[index];
    const value = rest[index + 1];
    assert(flag?.startsWith("--") && value !== undefined && !value.startsWith("--"),
      "Arguments must be supplied as --name value pairs.");
    const name = flag.slice(2);
    assert(values[name] === undefined, `Duplicate option ${flag}.`);
    values[name] = value;
  }
  return {command, values};
}

function required(values, name) {
  assert(values[name], `Missing required option --${name}.`);
  return values[name];
}

export async function executeMobilePromotionCli(argv) {
  const {command, values} = parseArgs(argv);
  let result;
  if (command === "select" || command === "verify-package") {
    const common = {
      authority: readRegularJson(
        required(values, "authority"),
        "mobile build authority",
      ),
      releaseTarget: required(values, "release-target"),
      expectedProducerRunId: required(values, "producer-run-id"),
      expectedProducerRunAttempt: required(values, "producer-run-attempt"),
      expectedSourceSha: command === "select"
        ? values["source-sha"]
        : required(values, "source-sha"),
    };
    result = command === "select"
      ? selectMobilePromotion(common)
      : await verifyMobilePromotionPackage({
          ...common,
          packageDir: required(values, "package-dir"),
        });
  } else if (command === "receipt") {
    result = createMobilePromotionReceipt({
      releaseTarget: required(values, "release-target"),
      sourceSha: required(values, "source-sha"),
      sourceCiRunId: required(values, "ci-run-id"),
      sourceCiRunAttempt: required(values, "ci-run-attempt"),
      producerRunId: required(values, "producer-run-id"),
      producerRunAttempt: required(values, "producer-run-attempt"),
      authorityArtifact: {
        id: required(values, "authority-artifact-id"),
        name: required(values, "authority-artifact-name"),
        digest: required(values, "authority-artifact-digest"),
      },
      packageArtifact: {
        id: required(values, "package-artifact-id"),
        name: required(values, "package-artifact-name"),
        digest: required(values, "package-artifact-digest"),
      },
      signedArtifactSha256: required(values, "signed-artifact-sha256"),
      promotionRunId: required(values, "promotion-run-id"),
      promotionRunAttempt: required(values, "promotion-run-attempt"),
      reasonSha256: required(values, "reason-sha256"),
      storeChannel: required(values, "store-channel"),
      storeTarget: required(values, "store-target"),
      storeVersion: required(values, "store-version"),
      storeBuild: required(values, "store-build"),
      storeResult: required(values, "store-result"),
      storeRemoteId: required(values, "store-remote-id"),
      evidenceLevel: required(values, "evidence-level"),
    });
    const output = path.resolve(required(values, "output"));
    assert(!fs.existsSync(output), "Promotion receipt output must not already exist.");
    fs.mkdirSync(path.dirname(output), {recursive: true, mode: 0o700});
    fs.writeFileSync(output, `${JSON.stringify(result, null, 2)}\n`, {
      encoding: "utf8",
      flag: "wx",
      mode: 0o600,
    });
  } else if (command === "verify-receipt") {
    result = validateMobilePromotionReceipt(
      readRegularJson(required(values, "receipt"), "mobile promotion receipt"),
      {
        releaseTarget: required(values, "release-target"),
        sourceSha: required(values, "source-sha"),
        sourceCiRunId: required(values, "ci-run-id"),
        sourceCiRunAttempt: required(values, "ci-run-attempt"),
        producerRunId: required(values, "producer-run-id"),
        producerRunAttempt: required(values, "producer-run-attempt"),
        authorityArtifact: {
          id: required(values, "authority-artifact-id"),
          name: required(values, "authority-artifact-name"),
          digest: required(values, "authority-artifact-digest"),
        },
        packageArtifact: {
          id: required(values, "package-artifact-id"),
          name: required(values, "package-artifact-name"),
          digest: required(values, "package-artifact-digest"),
        },
        signedArtifactSha256: required(values, "signed-artifact-sha256"),
        storeChannel: required(values, "store-channel"),
        storeTarget: required(values, "store-target"),
        storeVersion: required(values, "store-version"),
        storeBuild: required(values, "store-build"),
      },
    );
  } else {
    throw new Error(
      "Command must be select, verify-package, receipt, or verify-receipt.",
    );
  }
  process.stdout.write(`${JSON.stringify({ok: true, result})}\n`);
  return result;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  executeMobilePromotionCli(process.argv.slice(2)).catch((error) => {
    process.stderr.write(`${JSON.stringify({ok: false, message: error.message})}\n`);
    process.exitCode = 1;
  });
}
