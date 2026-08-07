import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  bindMobilePackageUpload,
  MOBILE_BUILD_AUTHORITY_SCHEMA,
  MOBILE_ATTEMPT_COMPLETENESS_AUTHORITY_SCHEMA,
  MOBILE_PACKAGE_RECEIPT_SCHEMA,
  MOBILE_PACKAGE_UPLOAD_RECEIPT_SCHEMA,
  prepareMobilePackage,
  validateMobileAttemptCompletenessAuthority,
  validateMobileBuildAuthority,
  verifyMobilePackage,
  verifyMobilePackageUpload,
} from "./package_mobile_release.mjs";

const SOURCE_SHA = "a".repeat(40);
const API_DIGEST = `sha256:${"b".repeat(64)}`;

function writeJson(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), {recursive: true});
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

function artifactBinding(filePath) {
  const bytes = fs.readFileSync(filePath);
  return {
    path: path.basename(filePath),
    sizeBytes: bytes.length,
    sha256: createHash("sha256").update(bytes).digest("hex"),
  };
}

function fixture(t, releaseTarget = "host-ios") {
  const root = fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), "catch-mobile-package-")));
  t.after(() => fs.rmSync(root, {recursive: true, force: true}));
  const [role, platform] = releaseTarget.split("-");
  const extension = platform === "ios" ? ".ipa" : ".aab";
  const artifactPath = path.join(root, "signed", `Catch-${role}${extension}`);
  fs.mkdirSync(path.dirname(artifactPath), {recursive: true});
  fs.writeFileSync(artifactPath, `signed-${releaseTarget}`);

  const authorityPath = path.join(root, "source", "ci-delivery-authority.json");
  const impactPlanPath = path.join(root, "source", "impact-plan.json");
  const identityReceiptPath = path.join(root, "evidence", "identity.json");
  const packagePolicyReceiptPath = path.join(root, "evidence", "package.json");
  const planName = `harness-plan-91-9001-${SOURCE_SHA}-2`;
  writeJson(authorityPath, {
    schema: "catch.ci-delivery-authority/v3",
    sourceCiWorkflowId: 77,
    sourceCiRunNumber: 91,
    sourceCiRunId: "9001",
    sourceCiRunAttempt: "2",
    sourceSha: SOURCE_SHA,
    deployRequired: false,
    planArtifact: {id: 123, name: planName, digest: API_DIGEST},
    packageArtifact: null,
  });
  writeJson(impactPlanPath, {
    schemaVersion: "0.2.0",
    graphStatus: "required",
    mode: "main",
    complete: true,
    sourceSha: SOURCE_SHA,
    sourceCiRunId: "9001",
    sourceCiRunAttempt: "2",
    operations: {
      releaseTargets: [releaseTarget],
      releaseRoles: [role],
    },
  });
  writeJson(identityReceiptPath, platform === "ios"
    ? {
        $schema: "catch.ios-release-identity/v1",
        targetId: `${role}-prod`,
        role,
        environment: "prod",
        artifactStage: "export",
        signatureVerified: true,
        googleMapsApiKeySha256: "f".repeat(64),
        artifactBinding: artifactBinding(artifactPath),
      }
    : {
        $schema: "catch.android-release-identity/v1",
        targetId: `${role}-prod`,
        role,
        environment: "prod",
        bundle: path.basename(artifactPath),
        signatureVerified: true,
        artifactBinding: artifactBinding(artifactPath),
      });
  writeJson(packagePolicyReceiptPath, {
    schemaVersion: "1.1.0",
    role,
    platform,
    artifact: path.basename(artifactPath),
    artifactBinding: artifactBinding(artifactPath),
    findings: [],
  });
  return {
    root,
    role,
    platform,
    releaseTarget,
    artifactPath,
    authorityPath,
    impactPlanPath,
    identityReceiptPath,
    packagePolicyReceiptPath,
    packageDir: path.join(root, "build", "mobile", releaseTarget),
    receiptDir: path.join(root, "build", "receipts", releaseTarget),
  };
}

async function prepare(work) {
  return prepareMobilePackage({
    sourceRoot: work.root,
    artifactPath: work.artifactPath,
    releaseTarget: work.releaseTarget,
    impactPlanPath: work.impactPlanPath,
    ciAuthorityPath: work.authorityPath,
    identityReceiptPath: work.identityReceiptPath,
    packagePolicyReceiptPath: work.packagePolicyReceiptPath,
    packageDir: work.packageDir,
    producerRunId: "7001",
    producerRunAttempt: "3",
  });
}

test("packages exact iOS and Android targets with delivery provenance v2", async (t) => {
  for (const releaseTarget of ["host-ios", "consumer-android"]) {
    await t.test(releaseTarget, async (subtest) => {
      const work = fixture(subtest, releaseTarget);
      const receipt = await prepare(work);
      assert.equal(receipt.schema, MOBILE_PACKAGE_RECEIPT_SCHEMA);
      assert.equal(receipt.releaseTarget, releaseTarget);
      assert.equal(receipt.sourceCiWorkflowId, 77);
      assert.equal(receipt.producerRunId, "7001");
      const provenance = JSON.parse(fs.readFileSync(
        path.join(work.packageDir, "delivery-provenance.json"),
      ));
      assert.equal(provenance.schema, "catch.delivery-provenance/v2");
      assert.deepEqual(provenance.stages, [`mobile-${releaseTarget}`]);
      assert.equal(provenance.sourceSha, SOURCE_SHA);
      assert.deepEqual(
        await verifyMobilePackage({
          packageDir: work.packageDir,
          releaseTarget,
          expectedSourceSha: SOURCE_SHA,
          expectedSourceCiRunId: "9001",
          expectedSourceCiRunAttempt: "2",
          expectedProducerRunId: "7001",
          expectedProducerRunAttempt: "3",
        }),
        receipt,
      );
    });
  }
});

test("refuses a target that the exact CI plan did not authorize", async (t) => {
  const work = fixture(t, "host-ios");
  const plan = JSON.parse(fs.readFileSync(work.impactPlanPath));
  plan.operations.releaseTargets = ["consumer-android"];
  writeJson(work.impactPlanPath, plan);
  await assert.rejects(prepare(work), /releaseRoles do not exactly match releaseTargets/);

  plan.operations.releaseRoles = ["consumer"];
  writeJson(work.impactPlanPath, plan);
  await assert.rejects(prepare(work), /does not authorize release target host-ios/);
});

test("identity and package-policy evidence reject same-name byte substitution", async (t) => {
  const work = fixture(t, "host-ios");
  const original = fs.readFileSync(work.artifactPath, "utf8");
  const replacement = original.replaceAll("host-ios", "evil-ios");
  assert.equal(Buffer.byteLength(replacement), Buffer.byteLength(original));
  fs.writeFileSync(work.artifactPath, replacement);
  await assert.rejects(prepare(work), /Identity receipt artifact binding SHA-256/);
  fs.rmSync(work.packageDir, {recursive: true, force: true});

  const rebound = artifactBinding(work.artifactPath);
  const identity = JSON.parse(fs.readFileSync(work.identityReceiptPath));
  identity.artifactBinding = rebound;
  writeJson(work.identityReceiptPath, identity);
  await assert.rejects(prepare(work), /Package-policy receipt artifact binding SHA-256/);
});

test("iOS package evidence requires strict signature and Maps proofs", async (t) => {
  const cases = [
    ["false signature", (identity) => { identity.signatureVerified = false; }, /strict deep signature/],
    ["missing Maps digest", (identity) => { delete identity.googleMapsApiKeySha256; }, /Google Maps API key/],
    ["malformed Maps digest", (identity) => { identity.googleMapsApiKeySha256 = "bad"; }, /Google Maps API key/],
  ];
  for (const [label, mutate, pattern] of cases) {
    await t.test(label, async (subtest) => {
      const work = fixture(subtest, "host-ios");
      const identity = JSON.parse(fs.readFileSync(work.identityReceiptPath));
      mutate(identity);
      writeJson(work.identityReceiptPath, identity);
      await assert.rejects(prepare(work), pattern);
    });
  }
});

test("verification rejects artifact, provenance, and source-binding tampering", async (t) => {
  const cases = [
    ["artifact bytes", (work) => fs.appendFileSync(
      path.join(work.packageDir, path.basename(work.artifactPath)),
      "tamper",
    ), /artifact descriptor does not match/],
    ["provenance", (work) => {
      const filePath = path.join(work.packageDir, "delivery-provenance.json");
      const value = JSON.parse(fs.readFileSync(filePath));
      value.sourceSha = "c".repeat(40);
      writeJson(filePath, value);
    }, /provenance descriptor does not match/],
    ["plan", (work) => {
      const filePath = path.join(work.packageDir, "source-impact-plan.json");
      const value = JSON.parse(fs.readFileSync(filePath));
      value.operations.releaseTargets = [];
      value.operations.releaseRoles = [];
      writeJson(filePath, value);
    }, /does not authorize host-ios/],
  ];
  for (const [label, tamper, pattern] of cases) {
    await t.test(label, async (subtest) => {
      const work = fixture(subtest);
      await prepare(work);
      tamper(work);
      await assert.rejects(verifyMobilePackage({
        packageDir: work.packageDir,
        releaseTarget: work.releaseTarget,
        expectedSourceSha: SOURCE_SHA,
        expectedSourceCiRunId: "9001",
        expectedSourceCiRunAttempt: "2",
        expectedProducerRunId: "7001",
        expectedProducerRunAttempt: "3",
      }), pattern);
    });
  }
});

test("binds immutable upload id and digest into a small strict receipt artifact", async (t) => {
  const work = fixture(t, "consumer-android");
  const packageReceipt = await prepare(work);
  const packageArtifactName =
    "mobile-package-v1-consumer-android-9001-2-7001-3";
  const upload = await bindMobilePackageUpload({
    sourceRoot: work.root,
    packageDir: work.packageDir,
    receiptDir: work.receiptDir,
    packageArtifactId: "501",
    packageArtifactName,
    packageArtifactDigest: API_DIGEST,
  });
  assert.equal(upload.schema, MOBILE_PACKAGE_UPLOAD_RECEIPT_SCHEMA);
  assert.deepEqual(upload.packageReceipt, packageReceipt);
  assert.deepEqual(upload.packageArtifact, {
    id: 501,
    name: packageArtifactName,
    digest: API_DIGEST,
  });
  assert.deepEqual(verifyMobilePackageUpload({
    receiptDir: work.receiptDir,
    releaseTarget: work.releaseTarget,
    expectedSourceSha: SOURCE_SHA,
    expectedSourceCiRunId: "9001",
    expectedSourceCiRunAttempt: "2",
    expectedProducerRunId: "7001",
    expectedProducerRunAttempt: "3",
    expectedPackageArtifactId: "501",
    expectedPackageArtifactName: packageArtifactName,
    expectedPackageArtifactDigest: API_DIGEST,
  }), upload);
});

test("upload receipt verification rejects metadata substitution and extra files", async (t) => {
  const work = fixture(t);
  await prepare(work);
  const packageArtifactName = "mobile-package-v1-host-ios-9001-2-7001-3";
  await bindMobilePackageUpload({
    sourceRoot: work.root,
    packageDir: work.packageDir,
    receiptDir: work.receiptDir,
    packageArtifactId: "501",
    packageArtifactName,
    packageArtifactDigest: API_DIGEST,
  });
  assert.throws(() => verifyMobilePackageUpload({
    receiptDir: work.receiptDir,
    releaseTarget: work.releaseTarget,
    expectedPackageArtifactId: "502",
  }), /package artifact id does not match/);
  fs.writeFileSync(path.join(work.receiptDir, "unexpected.txt"), "no");
  assert.throws(() => verifyMobilePackageUpload({
    receiptDir: work.receiptDir,
    releaseTarget: work.releaseTarget,
  }), /must contain exactly/);
});

test("aggregate authority strictly binds the post-comparison target and artifacts", () => {
  const authority = {
    schema: MOBILE_BUILD_AUTHORITY_SCHEMA,
    sourceCiWorkflowId: 77,
    sourceCiRunNumber: 91,
    sourceCiRunId: "9001",
    sourceCiRunAttempt: "2",
    sourceSha: SOURCE_SHA,
    producerRunId: "7001",
    producerRunAttempt: "3",
    releaseTargets: ["host-ios"],
    crossRoleComparisons: {ios: "not-required", android: "not-required"},
    packages: [{
      releaseTarget: "host-ios",
      artifactSha256: "c".repeat(64),
      provenanceManifestSha256: "d".repeat(64),
      packageArtifact: {
        id: 501,
        name: "mobile-package-v1-host-ios-9001-2-7001-3",
        digest: API_DIGEST,
      },
      receiptArtifact: {
        id: 601,
        name: "mobile-package-receipt-v1-host-ios-9001-2-7001-3",
        digest: `sha256:${"e".repeat(64)}`,
      },
    }],
  };
  assert.deepEqual(validateMobileBuildAuthority(authority, {
    sourceCiWorkflowId: "77",
    sourceCiRunNumber: "91",
    sourceCiRunId: "9001",
    sourceCiRunAttempt: "2",
    sourceSha: SOURCE_SHA,
    producerRunId: "7001",
    producerRunAttempt: "3",
    releaseTargets: '["host-ios"]',
  }), authority);

  const wrongComparison = structuredClone(authority);
  wrongComparison.crossRoleComparisons.ios = "passed";
  assert.throws(
    () => validateMobileBuildAuthority(wrongComparison),
    /comparison must be not-required/,
  );
  const substitutedName = structuredClone(authority);
  substitutedName.packages[0].packageArtifact.name =
    "mobile-package-v1-consumer-ios-9001-2-7001-3";
  assert.throws(
    () => validateMobileBuildAuthority(substitutedName),
    /Package artifact name does not match host-ios/,
  );
});

test("attempt completeness authority binds only one producer attempt", () => {
  const authority = {
    schema: MOBILE_ATTEMPT_COMPLETENESS_AUTHORITY_SCHEMA,
    sourceCiRunId: "9001",
    sourceCiRunAttempt: "2",
    sourceSha: SOURCE_SHA,
    producerRunId: "7001",
    producerRunAttempt: "3",
    releaseTargets: ["host-ios"],
    crossRoleComparisons: {ios: "not-required", android: "not-required"},
    artifacts: [{
      releaseTarget: "host-ios",
      packageArtifact: {
        id: 501,
        name: "mobile-package-v1-host-ios-9001-2-7001-3",
        digest: API_DIGEST,
      },
      receiptArtifact: {
        id: 601,
        name: "mobile-package-receipt-v1-host-ios-9001-2-7001-3",
        digest: `sha256:${"e".repeat(64)}`,
      },
    }],
  };
  assert.deepEqual(validateMobileAttemptCompletenessAuthority(authority, {
    sourceCiRunId: "9001",
    sourceCiRunAttempt: "2",
    sourceSha: SOURCE_SHA,
    producerRunId: "7001",
    producerRunAttempt: "3",
    releaseTargets: '["host-ios"]',
  }), authority);

  const priorAttempt = structuredClone(authority);
  priorAttempt.producerRunAttempt = "2";
  assert.throws(
    () => validateMobileAttemptCompletenessAuthority(priorAttempt, {
      producerRunAttempt: "3",
    }),
    /producer workflow run attempt does not match/,
  );
});
