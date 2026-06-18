export function buildRawArtifactStorageManifest({
  artifactFiles = [],
  storagePolicy = disabledStoragePolicy(),
} = {}) {
  const policy = normalizeStoragePolicy(storagePolicy);
  const artifacts = artifactFiles
    .map((file) => artifactRecord(file, policy))
    .sort((a, b) => a.path.localeCompare(b.path));

  return {
    schemaVersion: 1,
    generatedFrom: {
      sourceRoots: [
        "tool/organizer_intake/raw_artifacts",
        "tool/organizer_intake/fixtures",
        "tool/organizer_intake/search_result_batches",
        "tool/organizer_intake/event_source_batches",
        "tool/organizer_intake/batches",
        "tool/organizer_intake/curation_decisions",
        "tool/organizer_intake/review_decisions",
        "tool/organizer_intake/event_review_decisions",
        "tool/organizer_intake/event_location_resolutions",
        "tool/organizer_intake/policy_gap_decisions",
      ],
      policy: "organizer-raw-artifact-storage-v0-disabled",
    },
    policy,
    summary: {
      artifacts: artifacts.length,
      rawProviderPayloads: artifacts.filter((artifact) =>
        artifact.artifactKind === "raw_provider_payload").length,
      reviewedSourceBatches: artifacts.filter((artifact) =>
        artifact.storageClass === "reviewed_source_batch").length,
      decisionBatches: artifacts.filter((artifact) =>
        artifact.storageClass === "review_decision_state").length,
      fixtureSupportFiles: artifacts.filter((artifact) =>
        artifact.storageClass === "fixture_support").length,
      seedIntakeBatches: artifacts.filter((artifact) =>
        artifact.artifactKind === "seed_intake_batch").length,
      totalBytes: artifacts.reduce((total, artifact) =>
        total + artifact.sizeBytes, 0),
      remoteUploadReady: artifacts.filter((artifact) =>
        artifact.storagePlan.action === "would_upload").length,
      remoteUploadBlocked: artifacts.filter((artifact) =>
        artifact.storagePlan.action === "blocked").length,
      firestoreRawStorageAllowed: false,
      retentionDecisionRequired: artifacts.filter((artifact) =>
        artifact.retention.status === "decision_required").length,
      blockers: countBlockers(artifacts),
      storageClasses: countBy(artifacts, "storageClass"),
    },
    guardrails: [
      "Raw provider payloads must not be stored in Firestore documents.",
      "Firestore is reserved for low-volume admin decisions, claim targets, and promoted public records.",
      "High-volume crawl/search/provider payloads require object storage plus retention policy before upload is enabled.",
      "Reviewed source batches can be checked into git only when they are small, redacted, and useful for deterministic replay.",
      "Generated artifacts are derived and should be regenerated instead of archived as raw evidence.",
    ],
    artifacts,
  };
}

function artifactRecord(file, policy) {
  const artifactKind = classifyArtifactKind(file.path);
  const storageClass = storageClassForKind(artifactKind);
  const retention = retentionForKind(artifactKind, policy);
  const storagePlan = storagePlanForKind(file, artifactKind, policy);

  return {
    artifactId: artifactIdFor(file.path, file.sha256),
    path: file.path,
    artifactKind,
    storageClass,
    sizeBytes: file.sizeBytes,
    sha256: file.sha256,
    containsRawProviderPayload:
      artifactKind === "raw_provider_payload" ||
      artifactKind === "future_raw_artifact",
    firestoreMode: firestoreModeForKind(artifactKind),
    retention,
    storagePlan,
  };
}

function classifyArtifactKind(filePath) {
  const normalized = normalizePath(filePath);
  const fileName = normalized.split("/").at(-1) ?? "";
  if (normalized.includes("/raw_artifacts/")) return "future_raw_artifact";
  if (fileName.endsWith(".raw.json")) return "raw_provider_payload";
  if (normalized.includes("/search_result_batches/")) {
    return "reviewed_search_result_batch";
  }
  if (normalized.includes("/event_source_batches/")) {
    return "reviewed_event_source_batch";
  }
  if (normalized.includes("/batches/")) return "seed_intake_batch";
  if (
    normalized.includes("/curation_decisions/") ||
    normalized.includes("/review_decisions/") ||
    normalized.includes("/event_review_decisions/") ||
    normalized.includes("/event_location_resolutions/") ||
    normalized.includes("/policy_gap_decisions/")
  ) {
    return "review_decision_batch";
  }
  if (normalized.includes("/fixtures/")) {
    if (fileName.endsWith(".expected.json")) return "fixture_expected_output";
    if (fileName.endsWith(".sample.json")) return "fixture_sample_input";
    return "fixture_support";
  }
  return "supporting_artifact";
}

function storageClassForKind(artifactKind) {
  if (artifactKind === "raw_provider_payload" ||
    artifactKind === "future_raw_artifact") {
    return "raw_private_payload";
  }
  if (artifactKind === "reviewed_search_result_batch" ||
    artifactKind === "reviewed_event_source_batch") {
    return "reviewed_source_batch";
  }
  if (artifactKind === "review_decision_batch") {
    return "review_decision_state";
  }
  if (artifactKind === "seed_intake_batch") return "seed_intake_state";
  if (artifactKind.startsWith("fixture_")) return "fixture_support";
  return "supporting_artifact";
}

function retentionForKind(artifactKind, policy) {
  if (artifactKind === "raw_provider_payload" ||
    artifactKind === "future_raw_artifact") {
    return {
      status: policy.retentionPolicyApproved ?
        "policy_approved" :
        "decision_required",
      retentionDays: policy.rawPayloadRetentionDays,
      deletionMode: policy.retentionPolicyApproved ?
        "object_lifecycle_rule" :
        "not_configured",
    };
  }
  if (artifactKind === "fixture_expected_output" ||
    artifactKind === "fixture_sample_input" ||
    artifactKind === "fixture_support") {
    return {
      status: "test_fixture",
      retentionDays: null,
      deletionMode: "git_reviewed",
    };
  }
  if (artifactKind === "review_decision_batch") {
    return {
      status: "repo_reviewed",
      retentionDays: null,
      deletionMode: "manual_audit_history",
    };
  }
  return {
    status: "repo_reviewed",
    retentionDays: null,
    deletionMode: "regenerate_or_git_history",
  };
}

function storagePlanForKind(file, artifactKind, policy) {
  const remoteObjectKey = remoteObjectKeyFor(file, artifactKind);
  if (artifactKind !== "raw_provider_payload" &&
    artifactKind !== "future_raw_artifact") {
    return {
      action: "not_required",
      remoteObjectKey,
      blockedBy: [],
      reason:
        "This artifact is a reviewed, fixture, decision, or seed file and is not a high-volume raw provider payload.",
    };
  }

  const blockedBy = [];
  if (!policy.remoteObjectStorageEnabled) {
    blockedBy.push("remote_object_storage_disabled");
  }
  if (!policy.bucket) blockedBy.push("object_storage_bucket_missing");
  if (!policy.retentionPolicyApproved) {
    blockedBy.push("retention_policy_missing");
  }

  return {
    action: blockedBy.length === 0 ? "would_upload" : "blocked",
    remoteObjectKey,
    blockedBy,
    reason: blockedBy.length === 0 ?
      "Raw artifact is eligible for future object-storage upload; this planner still performs no upload." :
      "Raw artifact upload is blocked until object storage and retention policy are approved.",
  };
}

function remoteObjectKeyFor(file, artifactKind) {
  const safeName = (file.path.split("/").at(-1) ?? "artifact.json")
    .replace(/[^a-zA-Z0-9._-]+/g, "-");
  const prefix = storageClassForKind(artifactKind).replaceAll("_", "-");
  return [
    "organizer-intake",
    prefix,
    `${file.sha256.slice(0, 16)}-${safeName}`,
  ].join("/");
}

function firestoreModeForKind(artifactKind) {
  if (artifactKind === "raw_provider_payload" ||
    artifactKind === "future_raw_artifact" ||
    artifactKind === "reviewed_search_result_batch" ||
    artifactKind === "reviewed_event_source_batch") {
    return "forbidden_raw_or_source_payload";
  }
  if (artifactKind === "review_decision_batch") {
    return "allowed_low_volume_review_state_only";
  }
  return "not_applicable_local_or_generated";
}

function normalizeStoragePolicy(storagePolicy) {
  return {
    status: storagePolicy.remoteObjectStorageEnabled === true &&
      storagePolicy.retentionPolicyApproved === true &&
      Boolean(storagePolicy.bucket) ?
      "enabled_for_future_upload" :
      "disabled",
    remoteObjectStorageEnabled:
      storagePolicy.remoteObjectStorageEnabled === true,
    firestoreRawPayloadStorageEnabled: false,
    provider: storagePolicy.provider ?? "gcs_or_object_storage_pending",
    bucket: storagePolicy.bucket ?? null,
    rawPayloadRetentionDays:
      Number.isInteger(storagePolicy.rawPayloadRetentionDays) ?
        storagePolicy.rawPayloadRetentionDays :
        null,
    retentionPolicyApproved:
      storagePolicy.retentionPolicyApproved === true,
    reason: storagePolicy.reason ??
      "Raw artifact storage is planned but disabled until bucket, retention, and crawl cost policy are approved.",
  };
}

function disabledStoragePolicy() {
  return {
    remoteObjectStorageEnabled: false,
    firestoreRawPayloadStorageEnabled: false,
    provider: "gcs_or_object_storage_pending",
    bucket: null,
    rawPayloadRetentionDays: null,
    retentionPolicyApproved: false,
  };
}

function artifactIdFor(filePath, sha256) {
  const base = normalizePath(filePath)
    .replace(/^tool\/organizer_intake\//, "")
    .replace(/\.json$/i, "")
    .replace(/[^a-zA-Z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .toLowerCase();
  return `${base}-${sha256.slice(0, 12)}`;
}

function countBlockers(artifacts) {
  const counts = {};
  for (const artifact of artifacts) {
    for (const blocker of artifact.storagePlan.blockedBy ?? []) {
      counts[blocker] = (counts[blocker] ?? 0) + 1;
    }
  }
  return Object.fromEntries(
    Object.entries(counts).sort(([a], [b]) => a.localeCompare(b))
  );
}

function countBy(items, field) {
  const counts = {};
  for (const item of items) {
    const key = item[field] ?? "unknown";
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return Object.fromEntries(
    Object.entries(counts).sort(([a], [b]) => a.localeCompare(b))
  );
}

function normalizePath(filePath) {
  return String(filePath).replaceAll("\\", "/");
}
