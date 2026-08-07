#!/usr/bin/env node

import {createHash} from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {
  createProvenanceManifest,
  provenanceDigest,
  validateProvenanceManifest,
  verifyDeliveryArtifact,
  writeJsonAtomic,
} from "./delivery_core.mjs";

export const MOBILE_PACKAGE_RECEIPT_SCHEMA = "catch.mobile-package-receipt/v1";
export const MOBILE_PACKAGE_UPLOAD_RECEIPT_SCHEMA =
  "catch.mobile-package-upload-receipt/v1";
export const MOBILE_ATTEMPT_COMPLETENESS_AUTHORITY_SCHEMA =
  "catch.mobile-attempt-completeness-authority/v1";
export const MOBILE_BUILD_AUTHORITY_SCHEMA = "catch.mobile-build-authority/v1";

const CI_AUTHORITY_SCHEMA = "catch.ci-delivery-authority/v3";
const SHA_RE = /^[0-9a-f]{40}$/u;
const DIGEST_RE = /^[0-9a-f]{64}$/u;
const API_DIGEST_RE = /^sha256:[0-9a-f]{64}$/u;
const DECIMAL_ID_RE = /^[1-9][0-9]*$/u;
const RELEASE_TARGETS = Object.freeze({
  "consumer-android": Object.freeze({role: "consumer", platform: "android", extension: ".aab"}),
  "consumer-ios": Object.freeze({role: "consumer", platform: "ios", extension: ".ipa"}),
  "host-android": Object.freeze({role: "host", platform: "android", extension: ".aab"}),
  "host-ios": Object.freeze({role: "host", platform: "ios", extension: ".ipa"}),
});
const PACKAGE_FILES = Object.freeze([
  "delivery-provenance.json",
  "identity-receipt.json",
  "mobile-package-receipt.json",
  "package-policy-receipt.json",
  "source-ci-delivery-authority.json",
  "source-impact-plan.json",
]);
const UPLOAD_RECEIPT_FILES = Object.freeze([
  "mobile-package-upload-receipt.json",
  "package-policy-receipt.json",
]);

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function assertObject(value, label) {
  assert(value !== null && typeof value === "object" && !Array.isArray(value),
    `${label} must be an object.`);
}

function assertExactKeys(value, keys, label) {
  assertObject(value, label);
  const actual = Object.keys(value).sort();
  const expected = [...keys].sort();
  assert(JSON.stringify(actual) === JSON.stringify(expected),
    `${label} must contain exactly: ${expected.join(", ")}.`);
}

function decimalIdentifier(value, label) {
  const normalized = typeof value === "number" && Number.isSafeInteger(value)
    ? String(value)
    : value;
  assert(typeof normalized === "string" && DECIMAL_ID_RE.test(normalized),
    `${label} must be a positive decimal identifier.`);
  return normalized;
}

function positiveInteger(value, label) {
  const normalized = typeof value === "string" && DECIMAL_ID_RE.test(value)
    ? Number(value)
    : value;
  assert(Number.isSafeInteger(normalized) && normalized > 0,
    `${label} must be a positive safe integer.`);
  return normalized;
}

function sha(value, label) {
  assert(typeof value === "string" && SHA_RE.test(value),
    `${label} must be 40 lowercase hexadecimal characters.`);
  return value;
}

function digest(value, label) {
  assert(typeof value === "string" && DIGEST_RE.test(value),
    `${label} must be 64 lowercase hexadecimal characters.`);
  return value;
}

function apiDigest(value, label) {
  assert(typeof value === "string" && API_DIGEST_RE.test(value),
    `${label} must be an API SHA-256 digest.`);
  return value;
}

function target(value) {
  const config = RELEASE_TARGETS[value];
  assert(config, `release target must be one of: ${Object.keys(RELEASE_TARGETS).join(", ")}.`);
  return {releaseTarget: value, ...config};
}

function readRegularBytes(filePath, label) {
  let stat;
  try {
    stat = fs.lstatSync(filePath);
  } catch (error) {
    throw new Error(`Cannot read ${label} '${filePath}': ${error.message}`);
  }
  assert(stat.isFile() && !stat.isSymbolicLink(),
    `${label} must be a regular non-symlink file: ${filePath}`);
  return fs.readFileSync(filePath);
}

function readJson(filePath, label) {
  const bytes = readRegularBytes(filePath, label);
  try {
    return JSON.parse(bytes.toString("utf8"));
  } catch (error) {
    throw new Error(`Cannot parse ${label} '${filePath}': ${error.message}`);
  }
}

function sha256Bytes(bytes) {
  return createHash("sha256").update(bytes).digest("hex");
}

function fileDescriptor(filePath, name = path.basename(filePath)) {
  const bytes = readRegularBytes(filePath, name);
  return {name, sizeBytes: bytes.length, sha256: sha256Bytes(bytes)};
}

function artifactDescriptor(value, label) {
  assertExactKeys(value, ["digest", "id", "name"], label);
  assert(typeof value.name === "string" && value.name.length > 0 &&
    value.name === path.basename(value.name), `${label}.name must be a basename.`);
  return {
    id: positiveInteger(value.id, `${label}.id`),
    name: value.name,
    digest: apiDigest(value.digest, `${label}.digest`),
  };
}

function validateCiAuthority(value) {
  assertExactKeys(value, [
    "deployRequired",
    "packageArtifact",
    "planArtifact",
    "schema",
    "sourceCiRunAttempt",
    "sourceCiRunId",
    "sourceCiRunNumber",
    "sourceCiWorkflowId",
    "sourceSha",
  ], "CI delivery authority");
  assert(value.schema === CI_AUTHORITY_SCHEMA,
    `CI authority schema must be ${CI_AUTHORITY_SCHEMA}.`);
  assert(typeof value.deployRequired === "boolean", "deployRequired must be boolean.");
  assert(value.packageArtifact === null || typeof value.packageArtifact === "object",
    "packageArtifact must be null or an object.");
  if (value.deployRequired) {
    const packageArtifact = artifactDescriptor(value.packageArtifact, "packageArtifact");
    assert(packageArtifact.name === `firebase-delivery-${value.sourceSha}-${value.sourceCiRunAttempt}`,
      "packageArtifact name does not match the CI source binding.");
  } else {
    assert(value.packageArtifact === null,
      "packageArtifact must be null when deployRequired is false.");
  }
  return {
    schema: CI_AUTHORITY_SCHEMA,
    sourceCiWorkflowId: positiveInteger(value.sourceCiWorkflowId, "source CI workflow id"),
    sourceCiRunNumber: positiveInteger(value.sourceCiRunNumber, "source CI run number"),
    sourceCiRunId: decimalIdentifier(value.sourceCiRunId, "source CI run id"),
    sourceCiRunAttempt: decimalIdentifier(value.sourceCiRunAttempt, "source CI run attempt"),
    sourceSha: sha(value.sourceSha, "source SHA"),
    deployRequired: value.deployRequired,
    planArtifact: artifactDescriptor(value.planArtifact, "planArtifact"),
    packageArtifact: value.packageArtifact,
  };
}

function sortedUniqueStrings(value, label) {
  assert(Array.isArray(value), `${label} must be an array.`);
  assert(value.every((entry) => typeof entry === "string"), `${label} must contain strings.`);
  const normalized = [...new Set(value)].sort();
  assert(JSON.stringify(value) === JSON.stringify(normalized),
    `${label} must be sorted and contain no duplicates.`);
  return normalized;
}

function validateImpactPlan(value, authority) {
  assertObject(value, "impact plan");
  assert(value.complete === true, "Impact plan must be complete.");
  assert(value.mode === "main", "Impact plan must use main mode.");
  assert(value.sourceSha === authority.sourceSha,
    "Impact plan source SHA does not match the CI authority.");
  assert(String(value.sourceCiRunId) === authority.sourceCiRunId,
    "Impact plan source CI run id does not match the CI authority.");
  assert(String(value.sourceCiRunAttempt) === authority.sourceCiRunAttempt,
    "Impact plan source CI run attempt does not match the CI authority.");
  assertObject(value.operations, "impact plan operations");
  const releaseTargets = sortedUniqueStrings(
    value.operations.releaseTargets,
    "impact plan releaseTargets",
  );
  assert(releaseTargets.every((entry) => RELEASE_TARGETS[entry]),
    "Impact plan contains an unsupported mobile release target.");
  const releaseRoles = sortedUniqueStrings(
    value.operations.releaseRoles,
    "impact plan releaseRoles",
  );
  const targetRoles = [...new Set(releaseTargets.map((entry) => target(entry).role))].sort();
  assert(JSON.stringify(releaseRoles) === JSON.stringify(targetRoles),
    "Impact plan releaseRoles do not exactly match releaseTargets.");
  const expectedPlanName =
    `harness-plan-${authority.sourceCiRunNumber}-${authority.sourceCiRunId}-` +
    `${authority.sourceSha}-${authority.sourceCiRunAttempt}`;
  assert(authority.planArtifact.name === expectedPlanName,
    "CI authority plan artifact name does not match its exact source binding.");
  return {releaseTargets, releaseRoles};
}

function validateProducerBinding({producerRunId, producerRunAttempt}) {
  return {
    producerRunId: decimalIdentifier(producerRunId, "producer workflow run id"),
    producerRunAttempt: decimalIdentifier(
      producerRunAttempt,
      "producer workflow run attempt",
    ),
  };
}

function validateArtifactBinding(value, artifact, label) {
  assertExactKeys(value, ["path", "sha256", "sizeBytes"], `${label} artifact binding`);
  assert(value.path === artifact.name,
    `${label} artifact binding path does not match the signed artifact.`);
  assert(value.sizeBytes === artifact.sizeBytes,
    `${label} artifact binding size does not match the signed artifact bytes.`);
  assert(value.sha256 === artifact.sha256,
    `${label} artifact binding SHA-256 does not match the signed artifact bytes.`);
  return value;
}

function validateIdentityReceipt(value, selectedTarget, artifact) {
  assertObject(value, "mobile identity receipt");
  const expectedSchema = selectedTarget.platform === "ios"
    ? "catch.ios-release-identity/v1"
    : "catch.android-release-identity/v1";
  assert(value.$schema === expectedSchema,
    `Identity receipt schema must be ${expectedSchema}.`);
  assert(value.targetId === `${selectedTarget.role}-prod`,
    "Identity receipt targetId does not match the release target.");
  assert(value.role === selectedTarget.role && value.environment === "prod",
    "Identity receipt role/environment does not match the release target.");
  if (selectedTarget.platform === "ios") {
    assert(value.artifactStage === "export",
      "iOS identity receipt must describe the exported artifact.");
    assert(value.signatureVerified === true,
      "iOS identity receipt must confirm strict deep signature verification.");
    digest(value.googleMapsApiKeySha256,
      "iOS identity receipt Google Maps API key SHA-256");
  } else {
    assert(value.bundle === artifact.name,
      "Android identity receipt bundle does not match the signed artifact.");
    assert(value.signatureVerified === true,
      "Android identity receipt must confirm signature verification.");
  }
  validateArtifactBinding(value.artifactBinding, artifact, "Identity receipt");
  return value;
}

function validatePackagePolicyReceipt(value, selectedTarget, artifact) {
  assertObject(value, "mobile package-policy receipt");
  assert(value.schemaVersion === "1.1.0", "Package-policy receipt schema must be 1.1.0.");
  assert(value.role === selectedTarget.role && value.platform === selectedTarget.platform,
    "Package-policy receipt role/platform does not match the release target.");
  assert(value.artifact === artifact.name,
    "Package-policy receipt artifact does not match the signed artifact.");
  validateArtifactBinding(value.artifactBinding, artifact, "Package-policy receipt");
  assert(Array.isArray(value.findings) && value.findings.length === 0,
    "Package-policy receipt must contain no findings.");
  return value;
}

function createFreshDirectory(sourceRoot, candidate, label) {
  const root = fs.realpathSync(path.resolve(sourceRoot));
  const buildRoot = path.join(root, "build");
  const destination = path.resolve(candidate);
  assert(destination.startsWith(`${buildRoot}${path.sep}`),
    `${label} must be a descendant of sourceRoot/build.`);
  assert(!fs.existsSync(destination), `${label} must not already exist.`);
  let cursor = path.dirname(destination);
  while (cursor !== root) {
    if (fs.existsSync(cursor)) {
      assert(!fs.lstatSync(cursor).isSymbolicLink(),
        `${label} must not traverse a symlink: ${cursor}`);
    }
    cursor = path.dirname(cursor);
  }
  fs.mkdirSync(destination, {recursive: true, mode: 0o700});
  return destination;
}

function copyRegular(source, destination, label) {
  readRegularBytes(source, label);
  fs.copyFileSync(source, destination, fs.constants.COPYFILE_EXCL);
}

function validateMobilePackageReceipt(value) {
  assertExactKeys(value, [
    "artifact",
    "ciAuthority",
    "evidence",
    "impactPlan",
    "platform",
    "producerRunAttempt",
    "producerRunId",
    "provenance",
    "releaseTarget",
    "role",
    "schema",
    "sourceCiRunAttempt",
    "sourceCiRunId",
    "sourceCiRunNumber",
    "sourceCiWorkflowId",
    "sourceSha",
  ], "mobile package receipt");
  assert(value.schema === MOBILE_PACKAGE_RECEIPT_SCHEMA,
    `Mobile package receipt schema must be ${MOBILE_PACKAGE_RECEIPT_SCHEMA}.`);
  const selectedTarget = target(value.releaseTarget);
  assert(value.role === selectedTarget.role && value.platform === selectedTarget.platform,
    "Mobile package receipt role/platform does not match releaseTarget.");
  const file = (descriptor, label) => {
    assertExactKeys(descriptor, ["name", "sha256", "sizeBytes"], label);
    assert(typeof descriptor.name === "string" && descriptor.name === path.basename(descriptor.name),
      `${label}.name must be a basename.`);
    assert(Number.isSafeInteger(descriptor.sizeBytes) && descriptor.sizeBytes >= 0,
      `${label}.sizeBytes must be a non-negative safe integer.`);
    digest(descriptor.sha256, `${label}.sha256`);
    return descriptor;
  };
  assertExactKeys(value.provenance, ["manifestSha256", "name", "sha256", "sizeBytes"],
    "provenance descriptor");
  file({
    name: value.provenance.name,
    sizeBytes: value.provenance.sizeBytes,
    sha256: value.provenance.sha256,
  }, "provenance descriptor");
  digest(value.provenance.manifestSha256, "provenance manifest SHA-256");
  assertExactKeys(value.evidence, ["identity", "packagePolicy"], "evidence descriptor");
  file(value.artifact, "artifact descriptor");
  file(value.ciAuthority, "CI authority descriptor");
  file(value.impactPlan, "impact plan descriptor");
  file(value.evidence.identity, "identity evidence descriptor");
  file(value.evidence.packagePolicy, "package-policy evidence descriptor");
  assert(value.provenance.name === "delivery-provenance.json",
    "Provenance descriptor name must be delivery-provenance.json.");
  assert(value.ciAuthority.name === "source-ci-delivery-authority.json",
    "CI authority descriptor name must be source-ci-delivery-authority.json.");
  assert(value.impactPlan.name === "source-impact-plan.json",
    "Impact plan descriptor name must be source-impact-plan.json.");
  assert(value.evidence.identity.name === "identity-receipt.json",
    "Identity evidence descriptor name must be identity-receipt.json.");
  assert(value.evidence.packagePolicy.name === "package-policy-receipt.json",
    "Package-policy evidence descriptor name must be package-policy-receipt.json.");
  positiveInteger(value.sourceCiWorkflowId, "source CI workflow id");
  positiveInteger(value.sourceCiRunNumber, "source CI run number");
  decimalIdentifier(value.sourceCiRunId, "source CI run id");
  decimalIdentifier(value.sourceCiRunAttempt, "source CI run attempt");
  sha(value.sourceSha, "source SHA");
  decimalIdentifier(value.producerRunId, "producer workflow run id");
  decimalIdentifier(value.producerRunAttempt, "producer workflow run attempt");
  return value;
}

function packageFileSet(packageDir, selectedTarget, artifactName) {
  assert(path.extname(artifactName).toLowerCase() === selectedTarget.extension &&
    artifactName === path.basename(artifactName),
  "Mobile package artifact name does not match the release target platform.");
  const expected = [...PACKAGE_FILES, artifactName].sort();
  const actual = fs.readdirSync(packageDir).sort();
  assert(JSON.stringify(actual) === JSON.stringify(expected),
    `Mobile package must contain exactly: ${expected.join(", ")}.`);
  for (const name of actual) {
    const stat = fs.lstatSync(path.join(packageDir, name));
    assert(stat.isFile() && !stat.isSymbolicLink(),
      `Mobile package entry must be a regular non-symlink file: ${name}`);
  }
  return artifactName;
}

function assertDescriptorMatches(descriptor, filePath, label) {
  assert(JSON.stringify(descriptor) === JSON.stringify(fileDescriptor(filePath, descriptor.name)),
    `${label} does not match the packaged bytes.`);
}

export async function prepareMobilePackage({
  sourceRoot,
  artifactPath,
  releaseTarget,
  impactPlanPath,
  ciAuthorityPath,
  identityReceiptPath,
  packagePolicyReceiptPath,
  packageDir,
  producerRunId,
  producerRunAttempt,
}) {
  const selectedTarget = target(releaseTarget);
  assert(path.extname(artifactPath).toLowerCase() === selectedTarget.extension,
    `Signed artifact for ${releaseTarget} must use ${selectedTarget.extension}.`);
  const authority = validateCiAuthority(readJson(ciAuthorityPath, "CI delivery authority"));
  const impactPlan = readJson(impactPlanPath, "impact plan");
  const plan = validateImpactPlan(impactPlan, authority);
  assert(plan.releaseTargets.includes(releaseTarget),
    `Impact plan does not authorize release target ${releaseTarget}.`);
  const producer = validateProducerBinding({producerRunId, producerRunAttempt});
  const originalArtifactName = path.basename(artifactPath);
  assert(!PACKAGE_FILES.includes(originalArtifactName),
    "Signed artifact basename collides with a reserved mobile package file.");
  const destination = createFreshDirectory(sourceRoot, packageDir, "packageDir");
  const packagedArtifactName = originalArtifactName;
  const packagedArtifactPath = path.join(destination, packagedArtifactName);
  copyRegular(artifactPath, packagedArtifactPath, "signed mobile artifact");
  copyRegular(identityReceiptPath, path.join(destination, "identity-receipt.json"),
    "mobile identity receipt");
  copyRegular(packagePolicyReceiptPath, path.join(destination, "package-policy-receipt.json"),
    "mobile package-policy receipt");
  copyRegular(ciAuthorityPath, path.join(destination, "source-ci-delivery-authority.json"),
    "CI delivery authority");
  copyRegular(impactPlanPath, path.join(destination, "source-impact-plan.json"), "impact plan");

  const packagedArtifact = fileDescriptor(packagedArtifactPath, packagedArtifactName);
  validateIdentityReceipt(
    readJson(path.join(destination, "identity-receipt.json"), "mobile identity receipt"),
    selectedTarget,
    packagedArtifact,
  );
  validatePackagePolicyReceipt(
    readJson(
      path.join(destination, "package-policy-receipt.json"),
      "mobile package-policy receipt",
    ),
    selectedTarget,
    packagedArtifact,
  );

  const provenance = await createProvenanceManifest({
    artifactPath: packagedArtifactPath,
    sourceSha: authority.sourceSha,
    sourceCiRunId: authority.sourceCiRunId,
    sourceCiRunAttempt: authority.sourceCiRunAttempt,
    stages: [`mobile-${releaseTarget}`],
  });
  const provenancePath = path.join(destination, "delivery-provenance.json");
  await writeJsonAtomic(provenancePath, provenance);
  const provenanceFile = fileDescriptor(provenancePath, "delivery-provenance.json");

  const receipt = validateMobilePackageReceipt({
    schema: MOBILE_PACKAGE_RECEIPT_SCHEMA,
    sourceCiWorkflowId: authority.sourceCiWorkflowId,
    sourceCiRunNumber: authority.sourceCiRunNumber,
    sourceCiRunId: authority.sourceCiRunId,
    sourceCiRunAttempt: authority.sourceCiRunAttempt,
    sourceSha: authority.sourceSha,
    producerRunId: producer.producerRunId,
    producerRunAttempt: producer.producerRunAttempt,
    releaseTarget,
    role: selectedTarget.role,
    platform: selectedTarget.platform,
    artifact: packagedArtifact,
    provenance: {...provenanceFile, manifestSha256: provenanceDigest(provenance)},
    impactPlan: fileDescriptor(path.join(destination, "source-impact-plan.json"),
      "source-impact-plan.json"),
    ciAuthority: fileDescriptor(path.join(destination, "source-ci-delivery-authority.json"),
      "source-ci-delivery-authority.json"),
    evidence: {
      identity: fileDescriptor(path.join(destination, "identity-receipt.json"),
        "identity-receipt.json"),
      packagePolicy: fileDescriptor(path.join(destination, "package-policy-receipt.json"),
        "package-policy-receipt.json"),
    },
  });
  await writeJsonAtomic(path.join(destination, "mobile-package-receipt.json"), receipt);
  await verifyMobilePackage({
    packageDir: destination,
    releaseTarget,
    expectedSourceSha: authority.sourceSha,
    expectedSourceCiRunId: authority.sourceCiRunId,
    expectedSourceCiRunAttempt: authority.sourceCiRunAttempt,
    expectedProducerRunId: producer.producerRunId,
    expectedProducerRunAttempt: producer.producerRunAttempt,
  });
  return receipt;
}

export async function verifyMobilePackage({
  packageDir,
  releaseTarget,
  expectedSourceSha,
  expectedSourceCiRunId,
  expectedSourceCiRunAttempt,
  expectedProducerRunId,
  expectedProducerRunAttempt,
}) {
  const destination = path.resolve(packageDir);
  const selectedTarget = target(releaseTarget);
  assert(fs.lstatSync(destination).isDirectory() && !fs.lstatSync(destination).isSymbolicLink(),
    "Mobile package must be a regular non-symlink directory.");
  const receipt = validateMobilePackageReceipt(readJson(
    path.join(destination, "mobile-package-receipt.json"),
    "mobile package receipt",
  ));
  const artifactName = packageFileSet(destination, selectedTarget, receipt.artifact.name);
  assert(receipt.releaseTarget === releaseTarget,
    "Mobile package receipt releaseTarget does not match the requested target.");
  for (const [actual, expected, label] of [
    [receipt.sourceSha, expectedSourceSha, "source SHA"],
    [receipt.sourceCiRunId, expectedSourceCiRunId, "source CI run id"],
    [receipt.sourceCiRunAttempt, expectedSourceCiRunAttempt, "source CI run attempt"],
    [receipt.producerRunId, expectedProducerRunId, "producer workflow run id"],
    [receipt.producerRunAttempt, expectedProducerRunAttempt, "producer workflow run attempt"],
  ]) {
    if (expected !== undefined) assert(String(actual) === String(expected),
      `Mobile package ${label} does not match the expected binding.`);
  }

  const authority = validateCiAuthority(readJson(
    path.join(destination, "source-ci-delivery-authority.json"),
    "packaged CI delivery authority",
  ));
  const impactPlan = readJson(path.join(destination, "source-impact-plan.json"),
    "packaged impact plan");
  const plan = validateImpactPlan(impactPlan, authority);
  assert(plan.releaseTargets.includes(releaseTarget),
    `Packaged impact plan does not authorize ${releaseTarget}.`);
  assert(receipt.sourceCiWorkflowId === authority.sourceCiWorkflowId &&
    receipt.sourceCiRunNumber === authority.sourceCiRunNumber &&
    receipt.sourceCiRunId === authority.sourceCiRunId &&
    receipt.sourceCiRunAttempt === authority.sourceCiRunAttempt &&
    receipt.sourceSha === authority.sourceSha,
  "Mobile package receipt does not match the packaged CI authority.");

  const artifactPath = path.join(destination, artifactName);
  assertDescriptorMatches(receipt.artifact, artifactPath, "artifact descriptor");
  assertDescriptorMatches(receipt.impactPlan, path.join(destination, "source-impact-plan.json"),
    "impact plan descriptor");
  assertDescriptorMatches(receipt.ciAuthority,
    path.join(destination, "source-ci-delivery-authority.json"),
    "CI authority descriptor");
  assertDescriptorMatches(receipt.evidence.identity,
    path.join(destination, "identity-receipt.json"), "identity evidence descriptor");
  assertDescriptorMatches(receipt.evidence.packagePolicy,
    path.join(destination, "package-policy-receipt.json"),
    "package-policy evidence descriptor");
  assertDescriptorMatches({
    name: receipt.provenance.name,
    sizeBytes: receipt.provenance.sizeBytes,
    sha256: receipt.provenance.sha256,
  }, path.join(destination, "delivery-provenance.json"), "provenance descriptor");

  validateIdentityReceipt(readJson(path.join(destination, "identity-receipt.json"),
    "packaged mobile identity receipt"), selectedTarget, receipt.artifact);
  validatePackagePolicyReceipt(readJson(
    path.join(destination, "package-policy-receipt.json"),
    "packaged mobile package-policy receipt",
  ), selectedTarget, receipt.artifact);
  const provenance = validateProvenanceManifest(readJson(
    path.join(destination, "delivery-provenance.json"),
    "packaged delivery provenance",
  ));
  assert(provenanceDigest(provenance) === receipt.provenance.manifestSha256,
    "Delivery provenance manifest digest does not match the mobile package receipt.");
  assert(JSON.stringify(provenance.stages) === JSON.stringify([`mobile-${releaseTarget}`]),
    "Delivery provenance stage does not exactly match the mobile release target.");
  await verifyDeliveryArtifact({
    manifest: provenance,
    artifactPath,
    expectedSourceSha: authority.sourceSha,
    expectedSourceCiRunId: authority.sourceCiRunId,
    expectedSourceCiRunAttempt: authority.sourceCiRunAttempt,
  });
  return receipt;
}

function validateUploadReceipt(value) {
  assertExactKeys(value, ["packageArtifact", "packageReceipt", "schema"],
    "mobile package upload receipt");
  assert(value.schema === MOBILE_PACKAGE_UPLOAD_RECEIPT_SCHEMA,
    `Upload receipt schema must be ${MOBILE_PACKAGE_UPLOAD_RECEIPT_SCHEMA}.`);
  return {
    schema: MOBILE_PACKAGE_UPLOAD_RECEIPT_SCHEMA,
    packageReceipt: validateMobilePackageReceipt(value.packageReceipt),
    packageArtifact: artifactDescriptor(value.packageArtifact, "packageArtifact"),
  };
}

export async function bindMobilePackageUpload({
  sourceRoot,
  packageDir,
  receiptDir,
  packageArtifactId,
  packageArtifactName,
  packageArtifactDigest,
}) {
  const packageReceipt = validateMobilePackageReceipt(readJson(
    path.join(packageDir, "mobile-package-receipt.json"),
    "mobile package receipt",
  ));
  await verifyMobilePackage({
    packageDir,
    releaseTarget: packageReceipt.releaseTarget,
    expectedSourceSha: packageReceipt.sourceSha,
    expectedSourceCiRunId: packageReceipt.sourceCiRunId,
    expectedSourceCiRunAttempt: packageReceipt.sourceCiRunAttempt,
    expectedProducerRunId: packageReceipt.producerRunId,
    expectedProducerRunAttempt: packageReceipt.producerRunAttempt,
  });
  const expectedName = `mobile-package-v1-${packageReceipt.releaseTarget}-` +
    `${packageReceipt.sourceCiRunId}-${packageReceipt.sourceCiRunAttempt}-` +
    `${packageReceipt.producerRunId}-${packageReceipt.producerRunAttempt}`;
  assert(packageArtifactName === expectedName,
    "Uploaded package artifact name does not match the package receipt binding.");
  const destination = createFreshDirectory(sourceRoot, receiptDir, "receiptDir");
  const value = validateUploadReceipt({
    schema: MOBILE_PACKAGE_UPLOAD_RECEIPT_SCHEMA,
    packageReceipt,
    packageArtifact: {
      id: positiveInteger(packageArtifactId, "package artifact id"),
      name: packageArtifactName,
      digest: apiDigest(packageArtifactDigest, "package artifact digest"),
    },
  });
  await writeJsonAtomic(path.join(destination, "mobile-package-upload-receipt.json"), value);
  copyRegular(path.join(packageDir, "package-policy-receipt.json"),
    path.join(destination, "package-policy-receipt.json"), "package-policy receipt");
  return value;
}

export function verifyMobilePackageUpload({
  receiptDir,
  releaseTarget,
  expectedSourceSha,
  expectedSourceCiRunId,
  expectedSourceCiRunAttempt,
  expectedProducerRunId,
  expectedProducerRunAttempt,
  expectedPackageArtifactId,
  expectedPackageArtifactName,
  expectedPackageArtifactDigest,
}) {
  const directory = path.resolve(receiptDir);
  const actual = fs.readdirSync(directory).sort();
  assert(JSON.stringify(actual) === JSON.stringify([...UPLOAD_RECEIPT_FILES].sort()),
    `Upload receipt artifact must contain exactly: ${UPLOAD_RECEIPT_FILES.join(", ")}.`);
  for (const name of actual) {
    const stat = fs.lstatSync(path.join(directory, name));
    assert(stat.isFile() && !stat.isSymbolicLink(),
      `Upload receipt entry must be a regular non-symlink file: ${name}`);
  }
  const value = validateUploadReceipt(readJson(
    path.join(directory, "mobile-package-upload-receipt.json"),
    "mobile package upload receipt",
  ));
  const receipt = value.packageReceipt;
  assert(receipt.releaseTarget === releaseTarget,
    "Upload receipt releaseTarget does not match the requested target.");
  for (const [actualValue, expected, label] of [
    [receipt.sourceSha, expectedSourceSha, "source SHA"],
    [receipt.sourceCiRunId, expectedSourceCiRunId, "source CI run id"],
    [receipt.sourceCiRunAttempt, expectedSourceCiRunAttempt, "source CI run attempt"],
    [receipt.producerRunId, expectedProducerRunId, "producer workflow run id"],
    [receipt.producerRunAttempt, expectedProducerRunAttempt, "producer workflow run attempt"],
    [value.packageArtifact.id, expectedPackageArtifactId, "package artifact id"],
    [value.packageArtifact.name, expectedPackageArtifactName, "package artifact name"],
    [value.packageArtifact.digest, expectedPackageArtifactDigest, "package artifact digest"],
  ]) {
    if (expected !== undefined) assert(String(actualValue) === String(expected),
      `Upload receipt ${label} does not match the expected binding.`);
  }
  const selectedTarget = target(releaseTarget);
  validatePackagePolicyReceipt(readJson(
    path.join(directory, "package-policy-receipt.json"),
    "upload package-policy receipt",
  ), selectedTarget, receipt.artifact);
  assertDescriptorMatches(receipt.evidence.packagePolicy,
    path.join(directory, "package-policy-receipt.json"),
    "upload package-policy evidence descriptor");
  return value;
}

export function validateMobileAttemptCompletenessAuthority(value, expected = {}) {
  assertExactKeys(value, [
    "artifacts",
    "crossRoleComparisons",
    "producerRunAttempt",
    "producerRunId",
    "releaseTargets",
    "schema",
    "sourceCiRunAttempt",
    "sourceCiRunId",
    "sourceSha",
  ], "mobile attempt completeness authority");
  assert(value.schema === MOBILE_ATTEMPT_COMPLETENESS_AUTHORITY_SCHEMA,
    `Mobile attempt authority schema must be ${MOBILE_ATTEMPT_COMPLETENESS_AUTHORITY_SCHEMA}.`);
  const binding = {
    sourceCiRunId: decimalIdentifier(value.sourceCiRunId, "source CI run id"),
    sourceCiRunAttempt: decimalIdentifier(value.sourceCiRunAttempt, "source CI run attempt"),
    sourceSha: sha(value.sourceSha, "source SHA"),
    producerRunId: decimalIdentifier(value.producerRunId, "producer workflow run id"),
    producerRunAttempt: decimalIdentifier(
      value.producerRunAttempt,
      "producer workflow run attempt",
    ),
  };
  for (const [key, label] of Object.entries({
    sourceCiRunId: "source CI run id",
    sourceCiRunAttempt: "source CI run attempt",
    sourceSha: "source SHA",
    producerRunId: "producer workflow run id",
    producerRunAttempt: "producer workflow run attempt",
  })) {
    if (expected[key] !== undefined) {
      assert(String(binding[key]) === String(expected[key]),
        `Mobile attempt authority ${label} does not match the expected binding.`);
    }
  }

  const releaseTargets = sortedUniqueStrings(
    value.releaseTargets,
    "attempt authority releaseTargets",
  );
  assert(releaseTargets.length > 0 && releaseTargets.every((entry) => RELEASE_TARGETS[entry]),
    "Mobile attempt authority must contain at least one supported release target.");
  if (expected.releaseTargets !== undefined) {
    const expectedTargets = typeof expected.releaseTargets === "string"
      ? JSON.parse(expected.releaseTargets)
      : expected.releaseTargets;
    assert(JSON.stringify(releaseTargets) === JSON.stringify(expectedTargets),
      "Mobile attempt authority releaseTargets do not match the expected targets.");
  }

  assertExactKeys(value.crossRoleComparisons, ["android", "ios"],
    "attempt authority cross-role comparisons");
  for (const platform of ["ios", "android"]) {
    const required = releaseTargets.includes(`consumer-${platform}`) &&
      releaseTargets.includes(`host-${platform}`);
    const expectedStatus = required ? "passed" : "not-required";
    assert(value.crossRoleComparisons[platform] === expectedStatus,
      `Attempt authority cross-role ${platform} comparison must be ${expectedStatus}.`);
  }

  assert(Array.isArray(value.artifacts),
    "Mobile attempt authority artifacts must be an array.");
  const suffix = `${binding.sourceCiRunId}-${binding.sourceCiRunAttempt}-` +
    `${binding.producerRunId}-${binding.producerRunAttempt}`;
  const artifacts = value.artifacts.map((entry, index) => {
    assertExactKeys(entry, ["packageArtifact", "receiptArtifact", "releaseTarget"],
      `mobile attempt artifact ${index + 1}`);
    target(entry.releaseTarget);
    const packageArtifact = artifactDescriptor(
      entry.packageArtifact,
      `mobile attempt artifact ${index + 1} packageArtifact`,
    );
    const receiptArtifact = artifactDescriptor(
      entry.receiptArtifact,
      `mobile attempt artifact ${index + 1} receiptArtifact`,
    );
    assert(packageArtifact.name === `mobile-package-v1-${entry.releaseTarget}-${suffix}`,
      `Attempt package artifact name does not match ${entry.releaseTarget}.`);
    assert(receiptArtifact.name ===
      `mobile-package-receipt-v1-${entry.releaseTarget}-${suffix}`,
    `Attempt receipt artifact name does not match ${entry.releaseTarget}.`);
    return {...entry, packageArtifact, receiptArtifact};
  });
  assert(JSON.stringify(artifacts.map((entry) => entry.releaseTarget)) ===
    JSON.stringify(releaseTargets),
  "Mobile attempt artifacts must exactly match sorted releaseTargets.");
  assert(new Set(artifacts.map((entry) => entry.packageArtifact.id)).size === artifacts.length,
    "Attempt package artifact ids must be unique.");
  assert(new Set(artifacts.map((entry) => entry.receiptArtifact.id)).size === artifacts.length,
    "Attempt receipt artifact ids must be unique.");
  return {...value, ...binding, releaseTargets, artifacts};
}

export function validateMobileBuildAuthority(value, expected = {}) {
  assertExactKeys(value, [
    "crossRoleComparisons",
    "packages",
    "producerRunAttempt",
    "producerRunId",
    "releaseTargets",
    "schema",
    "sourceCiRunAttempt",
    "sourceCiRunId",
    "sourceCiRunNumber",
    "sourceCiWorkflowId",
    "sourceSha",
  ], "mobile build authority");
  assert(value.schema === MOBILE_BUILD_AUTHORITY_SCHEMA,
    `Mobile build authority schema must be ${MOBILE_BUILD_AUTHORITY_SCHEMA}.`);
  const binding = {
    sourceCiWorkflowId: positiveInteger(value.sourceCiWorkflowId, "source CI workflow id"),
    sourceCiRunNumber: positiveInteger(value.sourceCiRunNumber, "source CI run number"),
    sourceCiRunId: decimalIdentifier(value.sourceCiRunId, "source CI run id"),
    sourceCiRunAttempt: decimalIdentifier(value.sourceCiRunAttempt, "source CI run attempt"),
    sourceSha: sha(value.sourceSha, "source SHA"),
    producerRunId: decimalIdentifier(value.producerRunId, "producer workflow run id"),
    producerRunAttempt: decimalIdentifier(
      value.producerRunAttempt,
      "producer workflow run attempt",
    ),
  };
  const expectedKeys = {
    sourceCiWorkflowId: "source CI workflow id",
    sourceCiRunNumber: "source CI run number",
    sourceCiRunId: "source CI run id",
    sourceCiRunAttempt: "source CI run attempt",
    sourceSha: "source SHA",
    producerRunId: "producer workflow run id",
    producerRunAttempt: "producer workflow run attempt",
  };
  for (const [key, label] of Object.entries(expectedKeys)) {
    if (expected[key] !== undefined) {
      assert(String(binding[key]) === String(expected[key]),
        `Mobile build authority ${label} does not match the expected binding.`);
    }
  }

  const releaseTargets = sortedUniqueStrings(value.releaseTargets, "authority releaseTargets");
  assert(releaseTargets.length > 0 && releaseTargets.every((entry) => RELEASE_TARGETS[entry]),
    "Mobile build authority must contain at least one supported release target.");
  if (expected.releaseTargets !== undefined) {
    const expectedTargets = typeof expected.releaseTargets === "string"
      ? JSON.parse(expected.releaseTargets)
      : expected.releaseTargets;
    assert(JSON.stringify(releaseTargets) === JSON.stringify(expectedTargets),
      "Mobile build authority releaseTargets do not match the expected targets.");
  }

  assertExactKeys(value.crossRoleComparisons, ["android", "ios"],
    "cross-role comparisons");
  for (const platform of ["ios", "android"]) {
    const required = releaseTargets.includes(`consumer-${platform}`) &&
      releaseTargets.includes(`host-${platform}`);
    const expectedStatus = required ? "passed" : "not-required";
    assert(value.crossRoleComparisons[platform] === expectedStatus,
      `Cross-role ${platform} comparison must be ${expectedStatus}.`);
  }

  assert(Array.isArray(value.packages), "Mobile build authority packages must be an array.");
  const packages = value.packages.map((entry, index) => {
    assertExactKeys(entry, [
      "artifactSha256",
      "packageArtifact",
      "provenanceManifestSha256",
      "receiptArtifact",
      "releaseTarget",
    ], `mobile build package ${index + 1}`);
    target(entry.releaseTarget);
    digest(entry.artifactSha256, `mobile build package ${index + 1} artifact SHA-256`);
    digest(
      entry.provenanceManifestSha256,
      `mobile build package ${index + 1} provenance manifest SHA-256`,
    );
    const packageArtifact = artifactDescriptor(
      entry.packageArtifact,
      `mobile build package ${index + 1} packageArtifact`,
    );
    const receiptArtifact = artifactDescriptor(
      entry.receiptArtifact,
      `mobile build package ${index + 1} receiptArtifact`,
    );
    const suffix = `${binding.sourceCiRunId}-${binding.sourceCiRunAttempt}-` +
      `${binding.producerRunId}-${binding.producerRunAttempt}`;
    assert(packageArtifact.name === `mobile-package-v1-${entry.releaseTarget}-${suffix}`,
      `Package artifact name does not match ${entry.releaseTarget}.`);
    assert(receiptArtifact.name === `mobile-package-receipt-v1-${entry.releaseTarget}-${suffix}`,
      `Receipt artifact name does not match ${entry.releaseTarget}.`);
    return {...entry, packageArtifact, receiptArtifact};
  });
  assert(JSON.stringify(packages.map((entry) => entry.releaseTarget)) ===
    JSON.stringify(releaseTargets),
  "Mobile build packages must exactly match sorted releaseTargets.");
  assert(new Set(packages.map((entry) => entry.packageArtifact.id)).size === packages.length,
    "Package artifact ids must be unique.");
  assert(new Set(packages.map((entry) => entry.receiptArtifact.id)).size === packages.length,
    "Receipt artifact ids must be unique.");
  return {...value, ...binding, releaseTargets, packages};
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

export async function executeMobilePackageCli(argv) {
  const {command, values} = parseArgs(argv);
  let result;
  if (command === "prepare") {
    result = await prepareMobilePackage({
      sourceRoot: path.resolve(values["source-root"] ?? "."),
      artifactPath: required(values, "artifact"),
      releaseTarget: required(values, "release-target"),
      impactPlanPath: required(values, "impact-plan"),
      ciAuthorityPath: required(values, "ci-authority"),
      identityReceiptPath: required(values, "identity-receipt"),
      packagePolicyReceiptPath: required(values, "package-policy-receipt"),
      packageDir: required(values, "package-dir"),
      producerRunId: required(values, "producer-run-id"),
      producerRunAttempt: required(values, "producer-run-attempt"),
    });
  } else if (command === "verify") {
    result = await verifyMobilePackage({
      packageDir: required(values, "package-dir"),
      releaseTarget: required(values, "release-target"),
      expectedSourceSha: required(values, "source-sha"),
      expectedSourceCiRunId: required(values, "ci-run-id"),
      expectedSourceCiRunAttempt: required(values, "ci-run-attempt"),
      expectedProducerRunId: required(values, "producer-run-id"),
      expectedProducerRunAttempt: required(values, "producer-run-attempt"),
    });
  } else if (command === "bind-upload") {
    result = await bindMobilePackageUpload({
      sourceRoot: path.resolve(values["source-root"] ?? "."),
      packageDir: required(values, "package-dir"),
      receiptDir: required(values, "receipt-dir"),
      packageArtifactId: required(values, "package-artifact-id"),
      packageArtifactName: required(values, "package-artifact-name"),
      packageArtifactDigest: required(values, "package-artifact-digest"),
    });
  } else if (command === "verify-upload") {
    result = verifyMobilePackageUpload({
      receiptDir: required(values, "receipt-dir"),
      releaseTarget: required(values, "release-target"),
      expectedSourceSha: required(values, "source-sha"),
      expectedSourceCiRunId: required(values, "ci-run-id"),
      expectedSourceCiRunAttempt: required(values, "ci-run-attempt"),
      expectedProducerRunId: required(values, "producer-run-id"),
      expectedProducerRunAttempt: required(values, "producer-run-attempt"),
      expectedPackageArtifactId: required(values, "package-artifact-id"),
      expectedPackageArtifactName: required(values, "package-artifact-name"),
      expectedPackageArtifactDigest: required(values, "package-artifact-digest"),
    });
  } else if (command === "verify-authority") {
    result = validateMobileBuildAuthority(
      readJson(required(values, "authority"), "mobile build authority"),
      {
        sourceCiWorkflowId: required(values, "ci-workflow-id"),
        sourceCiRunNumber: required(values, "ci-run-number"),
        sourceCiRunId: required(values, "ci-run-id"),
        sourceCiRunAttempt: required(values, "ci-run-attempt"),
        sourceSha: required(values, "source-sha"),
        producerRunId: required(values, "producer-run-id"),
        producerRunAttempt: required(values, "producer-run-attempt"),
        releaseTargets: required(values, "release-targets"),
      },
    );
  } else if (command === "verify-attempt") {
    result = validateMobileAttemptCompletenessAuthority(
      readJson(required(values, "authority"), "mobile attempt completeness authority"),
      {
        sourceCiRunId: required(values, "ci-run-id"),
        sourceCiRunAttempt: required(values, "ci-run-attempt"),
        sourceSha: required(values, "source-sha"),
        producerRunId: required(values, "producer-run-id"),
        producerRunAttempt: required(values, "producer-run-attempt"),
        releaseTargets: required(values, "release-targets"),
      },
    );
  } else {
    throw new Error(
      "Command must be prepare, verify, bind-upload, verify-upload, verify-attempt, " +
      "or verify-authority.",
    );
  }
  process.stdout.write(`${JSON.stringify({ok: true, result})}\n`);
  return result;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  executeMobilePackageCli(process.argv.slice(2)).catch((error) => {
    process.stderr.write(`${JSON.stringify({ok: false, message: error.message})}\n`);
    process.exitCode = 1;
  });
}
