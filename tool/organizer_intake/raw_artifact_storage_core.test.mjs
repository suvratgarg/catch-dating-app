import assert from "node:assert/strict";
import test from "node:test";
import {buildRawArtifactStorageManifest} from
  "./lib/raw_artifact_storage_core.mjs";

test("buildRawArtifactStorageManifest blocks raw payload upload by default", () => {
  const manifest = buildRawArtifactStorageManifest({
    artifactFiles: [
      fixtureFile(
        "tool/organizer_intake/fixtures/luma_event.afterfly.raw.json",
        2048,
        "a".repeat(64)
      ),
      fixtureFile(
        "tool/organizer_intake/event_source_batches/2026-06-17-afterfly.json",
        512,
        "b".repeat(64)
      ),
    ],
  });

  assert.equal(manifest.policy.status, "disabled");
  assert.equal(manifest.summary.artifacts, 2);
  assert.equal(manifest.summary.rawProviderPayloads, 1);
  assert.equal(manifest.summary.reviewedSourceBatches, 1);
  assert.equal(manifest.summary.firestoreRawStorageAllowed, false);
  assert.equal(manifest.summary.remoteUploadReady, 0);
  assert.equal(manifest.summary.remoteUploadBlocked, 1);
  assert.equal(manifest.summary.retentionDecisionRequired, 1);

  const rawArtifact = manifest.artifacts.find((artifact) =>
    artifact.artifactKind === "raw_provider_payload"
  );
  assert.equal(rawArtifact.firestoreMode, "forbidden_raw_or_source_payload");
  assert.deepEqual(rawArtifact.storagePlan.blockedBy, [
    "remote_object_storage_disabled",
    "object_storage_bucket_missing",
    "retention_policy_missing",
  ]);
});

test("buildRawArtifactStorageManifest separates review state from raw payloads", () => {
  const manifest = buildRawArtifactStorageManifest({
    artifactFiles: [
      fixtureFile(
        "tool/organizer_intake/review_decisions/2026-06-17-afterfly.json",
        256,
        "c".repeat(64)
      ),
      fixtureFile(
        "tool/organizer_intake/policy_gap_decisions/2026-06-17-policy.json",
        256,
        "d".repeat(64)
      ),
    ],
  });

  assert.equal(manifest.summary.decisionBatches, 2);
  assert.equal(manifest.summary.rawProviderPayloads, 0);
  assert.equal(manifest.summary.remoteUploadBlocked, 0);
  assert.equal(manifest.summary.storageClasses.review_decision_state, 2);
  assert.ok(manifest.artifacts.every((artifact) =>
    artifact.firestoreMode === "allowed_low_volume_review_state_only"
  ));
});

test("buildRawArtifactStorageManifest can model future object upload readiness", () => {
  const manifest = buildRawArtifactStorageManifest({
    artifactFiles: [
      fixtureFile(
        "tool/organizer_intake/raw_artifacts/luma/afterfly-2026-06-17.json",
        4096,
        "e".repeat(64)
      ),
    ],
    storagePolicy: {
      remoteObjectStorageEnabled: true,
      provider: "gcs",
      bucket: "catch-organizer-raw-artifacts-dev",
      rawPayloadRetentionDays: 30,
      retentionPolicyApproved: true,
    },
  });

  assert.equal(manifest.policy.status, "enabled_for_future_upload");
  assert.equal(manifest.summary.remoteUploadReady, 1);
  assert.equal(manifest.summary.remoteUploadBlocked, 0);
  assert.equal(manifest.artifacts[0].storagePlan.action, "would_upload");
  assert.equal(manifest.artifacts[0].retention.retentionDays, 30);
});

function fixtureFile(path, sizeBytes, sha256) {
  return {path, sizeBytes, sha256};
}
