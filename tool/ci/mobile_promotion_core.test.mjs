import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {prepareMobilePackage} from "./package_mobile_release.mjs";
import {
  createMobilePromotionReceipt,
  MOBILE_PROMOTION_RECEIPT_SCHEMA,
  selectMobilePromotion,
  validateMobilePromotionReceipt,
  verifyMobilePromotionPackage,
} from "./mobile_promotion_core.mjs";

const SOURCE_SHA = "a".repeat(40);
const API_DIGEST = `sha256:${"b".repeat(64)}`;

function buildAuthority({
  releaseTarget = "host-ios",
  artifactSha256 = "c".repeat(64),
  provenanceManifestSha256 = "d".repeat(64),
} = {}) {
  return {
    schema: "catch.mobile-build-authority/v1",
    sourceCiWorkflowId: 77,
    sourceCiRunNumber: 91,
    sourceCiRunId: "9001",
    sourceCiRunAttempt: "2",
    sourceSha: SOURCE_SHA,
    producerRunId: "7001",
    producerRunAttempt: "3",
    releaseTargets: [releaseTarget],
    crossRoleComparisons: {ios: "not-required", android: "not-required"},
    packages: [{
      releaseTarget,
      artifactSha256,
      provenanceManifestSha256,
      packageArtifact: {
        id: 501,
        name: `mobile-package-v1-${releaseTarget}-9001-2-7001-3`,
        digest: API_DIGEST,
      },
      receiptArtifact: {
        id: 601,
        name: `mobile-package-receipt-v1-${releaseTarget}-9001-2-7001-3`,
        digest: `sha256:${"e".repeat(64)}`,
      },
    }],
  };
}

function select(authority = buildAuthority(), releaseTarget = "host-ios") {
  return selectMobilePromotion({
    authority,
    releaseTarget,
    expectedProducerRunId: "7001",
    expectedProducerRunAttempt: "3",
    expectedSourceSha: SOURCE_SHA,
  });
}

function writeJson(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), {recursive: true});
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

async function packageFixture(t, {artifactName = "Catch Host.ipa"} = {}) {
  const root = fs.realpathSync(fs.mkdtempSync(
    path.join(os.tmpdir(), "catch-mobile-promotion-"),
  ));
  t.after(() => fs.rmSync(root, {recursive: true, force: true}));
  const artifactPath = path.join(root, "signed", artifactName);
  fs.mkdirSync(path.dirname(artifactPath), {recursive: true});
  fs.writeFileSync(artifactPath, "exact-signed-host-ipa");
  const artifactBytes = fs.readFileSync(artifactPath);
  const artifactBinding = {
    path: artifactName,
    sizeBytes: artifactBytes.length,
    sha256: createHash("sha256").update(artifactBytes).digest("hex"),
  };

  const authorityPath = path.join(root, "source", "ci-delivery-authority.json");
  const planPath = path.join(root, "source", "impact-plan.json");
  const identityPath = path.join(root, "evidence", "identity.json");
  const policyPath = path.join(root, "evidence", "policy.json");
  writeJson(authorityPath, {
    schema: "catch.ci-delivery-authority/v3",
    sourceCiWorkflowId: 77,
    sourceCiRunNumber: 91,
    sourceCiRunId: "9001",
    sourceCiRunAttempt: "2",
    sourceSha: SOURCE_SHA,
    deployRequired: false,
    planArtifact: {
      id: 123,
      name: `harness-plan-91-9001-${SOURCE_SHA}-2`,
      digest: API_DIGEST,
    },
    packageArtifact: null,
  });
  writeJson(planPath, {
    schemaVersion: "0.2.0",
    graphStatus: "required",
    mode: "main",
    complete: true,
    sourceSha: SOURCE_SHA,
    sourceCiRunId: "9001",
    sourceCiRunAttempt: "2",
    operations: {
      releaseTargets: ["host-ios"],
      releaseRoles: ["host"],
    },
  });
  writeJson(identityPath, {
    $schema: "catch.ios-release-identity/v1",
    targetId: "host-prod",
    role: "host",
    environment: "prod",
    bundleIdentifier: "com.catchdates.host",
    version: "1.2.3",
    build: "2026080701",
    artifactStage: "export",
    signatureVerified: true,
    googleMapsApiKeySha256: "f".repeat(64),
    artifactBinding,
  });
  writeJson(policyPath, {
    schemaVersion: "1.1.0",
    role: "host",
    platform: "ios",
    artifact: artifactName,
    artifactBinding,
    findings: [],
  });
  const packageDir = path.join(root, "build", "mobile", "host-ios");
  const receipt = await prepareMobilePackage({
    sourceRoot: root,
    artifactPath,
    releaseTarget: "host-ios",
    impactPlanPath: planPath,
    ciAuthorityPath: authorityPath,
    identityReceiptPath: identityPath,
    packagePolicyReceiptPath: policyPath,
    packageDir,
    producerRunId: "7001",
    producerRunAttempt: "3",
  });
  return {packageDir, receipt};
}

test("selects the exact current target package only from build authority", () => {
  const selected = select();
  assert.equal(selected.authorityArtifactName,
    `mobile-build-authority-v1-77-91-9001-2-${SOURCE_SHA}-7001-3`);
  assert.equal(selected.releaseTarget, "host-ios");
  assert.equal(selected.role, "host");
  assert.equal(selected.platform, "ios");
  assert.deepEqual(selected.packageArtifact, {
    id: 501,
    name: "mobile-package-v1-host-ios-9001-2-7001-3",
    digest: API_DIGEST,
  });
});

test("authority source SHA is independent from the producer workflow head", () => {
  const selected = selectMobilePromotion({
    authority: buildAuthority(),
    releaseTarget: "host-ios",
    expectedProducerRunId: "7001",
    expectedProducerRunAttempt: "3",
  });
  assert.equal(selected.sourceSha, SOURCE_SHA);
  assert.throws(() => selectMobilePromotion({
    authority: buildAuthority(),
    releaseTarget: "host-ios",
    expectedProducerRunId: "7001",
    expectedProducerRunAttempt: "3",
    expectedSourceSha: "f".repeat(40),
  }), /source SHA does not match/);
});

test("rejects stale attempts, wrong targets, and substituted artifact names", () => {
  assert.throws(() => selectMobilePromotion({
    authority: buildAuthority(),
    releaseTarget: "host-ios",
    expectedProducerRunId: "7001",
    expectedProducerRunAttempt: "2",
    expectedSourceSha: SOURCE_SHA,
  }), /producer workflow run attempt does not match/);
  assert.throws(() => select(buildAuthority(), "consumer-ios"),
    /does not authorize consumer-ios/);

  const substituted = buildAuthority();
  substituted.packages[0].packageArtifact.name =
    "mobile-package-v1-consumer-ios-9001-2-7001-3";
  assert.throws(() => select(substituted),
    /Package artifact name does not match host-ios/);
});

test("reverifies packaged bytes against the aggregate authority", async (t) => {
  const {packageDir, receipt} = await packageFixture(t);
  const authority = buildAuthority({
    artifactSha256: receipt.artifact.sha256,
    provenanceManifestSha256: receipt.provenance.manifestSha256,
  });
  const verified = await verifyMobilePromotionPackage({
    authority,
    packageDir,
    releaseTarget: "host-ios",
    expectedProducerRunId: "7001",
    expectedProducerRunAttempt: "3",
    expectedSourceSha: SOURCE_SHA,
  });
  assert.equal(verified.artifactName, "Catch Host.ipa");
  assert.deepEqual(verified.storeIdentity, {
    bundleIdentifier: "com.catchdates.host",
    version: "1.2.3",
    build: "2026080701",
  });

  const substituted = structuredClone(authority);
  substituted.packages[0].artifactSha256 = "f".repeat(64);
  await assert.rejects(verifyMobilePromotionPackage({
    authority: substituted,
    packageDir,
    releaseTarget: "host-ios",
    expectedProducerRunId: "7001",
    expectedProducerRunAttempt: "3",
    expectedSourceSha: SOURCE_SHA,
  }), /Signed artifact digest does not match/);
});

test("rejects shell metacharacters in an otherwise valid IPA basename", async (t) => {
  const {packageDir, receipt} = await packageFixture(t, {
    artifactName: "Catch;Host.ipa",
  });
  const authority = buildAuthority({
    artifactSha256: receipt.artifact.sha256,
    provenanceManifestSha256: receipt.provenance.manifestSha256,
  });
  await assert.rejects(verifyMobilePromotionPackage({
    authority,
    packageDir,
    releaseTarget: "host-ios",
    expectedProducerRunId: "7001",
    expectedProducerRunAttempt: "3",
    expectedSourceSha: SOURCE_SHA,
  }), /Signed artifact name is not safe/);
});

test("promotion receipt binds immutable exact package and uploaded store result", () => {
  const receipt = createMobilePromotionReceipt({
    releaseTarget: "host-ios",
    sourceSha: SOURCE_SHA,
    sourceCiRunId: "9001",
    sourceCiRunAttempt: "2",
    producerRunId: "7001",
    producerRunAttempt: "3",
    authorityArtifact: {
      id: "801",
      name: `mobile-build-authority-v1-77-91-9001-2-${SOURCE_SHA}-7001-3`,
      digest: API_DIGEST,
    },
    packageArtifact: {
      id: "501",
      name: "mobile-package-v1-host-ios-9001-2-7001-3",
      digest: API_DIGEST,
    },
    signedArtifactSha256: "c".repeat(64),
    promotionRunId: "9901",
    promotionRunAttempt: "1",
    reasonSha256: "d".repeat(64),
    storeChannel: "testflight",
    storeTarget: "6778927317",
    storeVersion: "1.2.3",
    storeBuild: "2026080701",
    storeResult: "uploaded",
    storeRemoteId: "apple-build-1",
    evidenceLevel: "exact-artifact",
  });
  assert.equal(receipt.schema, MOBILE_PROMOTION_RECEIPT_SCHEMA);
  assert.equal(receipt.packageArtifact.id, "501");
  assert.equal(receipt.store.result, "uploaded");
  assert.equal(receipt.evidenceLevel, "exact-artifact");
  assert.match(receipt.claimArtifactName,
    /^mobile-promotion-claim-v1-host-ios-501-[0-9a-f]{64}$/u);
  assert.deepEqual(validateMobilePromotionReceipt(receipt, {
    releaseTarget: "host-ios",
    packageArtifact: receipt.packageArtifact,
    signedArtifactSha256: "c".repeat(64),
  }), receipt);
  assert.throws(() => validateMobilePromotionReceipt(receipt, {
    signedArtifactSha256: "f".repeat(64),
  }), /does not match the requested exact package/u);
  const identityOnly = structuredClone(receipt);
  identityOnly.evidenceLevel = "operator-reconciled-identity";
  assert.throws(() => validateMobilePromotionReceipt(identityOnly),
    /exact-artifact evidence/u);
  const circular = structuredClone(receipt);
  circular.store.result = "already-promoted";
  assert.throws(() => validateMobilePromotionReceipt(circular),
    /fresh upload/u);
});
