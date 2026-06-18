export function buildCanonicalEvidenceIndex({
  canonicalHostEntities = emptyCanonicalHostEntities(),
  rawArtifactStorageManifest = emptyRawArtifactStorageManifest(),
  referencedArtifactFiles = [],
  curationState = emptyCurationState(),
  reviewQueue = emptyReviewQueue(),
  searchResultCandidateQueue = emptySearchResultCandidateQueue(),
  externalEventCandidateQueue = emptyExternalEventCandidateQueue(),
} = {}) {
  const artifactMap = buildArtifactMap({
    rawArtifacts: rawArtifactStorageManifest.artifacts ?? [],
    referencedArtifactFiles,
  });
  const curationBySurface = curationSummaryBySurface(curationState);
  const reviewByEntity = new Map(
    (reviewQueue.items ?? []).map((item) => [item.entityId, item])
  );
  const searchCandidatesByKey = groupBy(
    searchResultCandidateQueue.candidates ?? [],
    "normalizedKey"
  );
  const eventCandidatesByEntity = groupBy(
    externalEventCandidateQueue.candidates ?? [],
    "entityId"
  );

  const records = [];
  for (const host of canonicalHostEntities.entries ?? []) {
    for (const surface of host.surfaces ?? []) {
      const evidenceRefs = surface.evidenceRefs?.length ?
        surface.evidenceRefs :
        [missingEvidenceRef()];
      for (const [index, evidence] of evidenceRefs.entries()) {
        records.push(evidenceRecord({
          artifactMap,
          curation: curationBySurface.get(surfaceKey(host.entityId, surface.surfaceId)) ?? null,
          evidence,
          eventCandidates: eventCandidatesByEntity.get(host.entityId) ?? [],
          host,
          index,
          reviewItem: reviewByEntity.get(host.entityId) ?? null,
          searchCandidates: surface.normalizedKey ?
            searchCandidatesByKey.get(surface.normalizedKey) ?? [] :
            [],
          surface,
        }));
      }
    }
  }

  const artifactCoverage = artifactCoverageRows({
    artifactMap,
    records,
  });

  return {
    schemaVersion: 1,
    generatedFrom: {
      canonicalHostEntities:
        "tool/organizer_intake/generated/canonical_host_entities.json",
      rawArtifactStorageManifest:
        "tool/organizer_intake/generated/raw_artifact_storage_manifest.json",
      curationState:
        "tool/organizer_intake/generated/organizer_curation_state.json",
      adminReviewQueue:
        "tool/organizer_intake/generated/admin_review_queue.json",
      searchResultCandidateQueue:
        "tool/organizer_intake/generated/search_result_candidate_queue.json",
      externalEventCandidateQueue:
        "tool/organizer_intake/generated/external_event_candidate_queue.json",
    },
    summary: summaryFor({artifactCoverage, records}),
    guardrails: [
      "Evidence records are provenance only; they never publish pages, call providers, enable crawls, upload objects, or write Firestore.",
      "Raw provider payloads are retained as object-storage candidates and remain forbidden from Firestore.",
      "Manual reports without artifacts are review prompts, not identity proof.",
      "Published host pages, claim targets, crawl plans, and event imports should reference canonicalHostId plus evidence record ids.",
    ],
    records,
    artifactCoverage,
  };
}

function evidenceRecord({
  artifactMap,
  curation,
  evidence,
  eventCandidates,
  host,
  index,
  reviewItem,
  searchCandidates,
  surface,
}) {
  const artifact = artifactForEvidence(artifactMap, evidence);
  const evidenceStatus = evidenceStatusFor(evidence, artifact);
  const riskFlags = riskFlagsFor({artifact, evidence, evidenceStatus, surface});

  return {
    evidenceId: evidenceIdFor(host.entityId, surface.surfaceId, evidence, index),
    canonicalHostId: host.canonicalHostId,
    entityId: host.entityId,
    displayName: host.displayName,
    surface: {
      surfaceId: surface.surfaceId,
      platform: surface.platform,
      surfaceKind: surface.surfaceKind,
      url: surface.url ?? null,
      normalizedKey: surface.normalizedKey ?? null,
      role: surface.role,
      status: surface.status,
      confidence: surface.confidence,
      supportsEventExtraction:
        surface.crawl?.supportsEventExtraction === true,
    },
    evidence: {
      type: evidence.type,
      ref: evidence.ref ?? null,
      description: evidence.description ?? null,
      status: evidenceStatus,
    },
    artifact: artifact ? artifactSummary(artifact) : null,
    reviewState: {
      entityReviewStatus: host.publicPresence?.reviewStatus ?? null,
      publishStatus: host.publicPresence?.publishStatus ?? null,
      indexStatus: host.publicPresence?.indexStatus ?? null,
      claimState: host.claim?.claimState ?? null,
      appVisibility: host.publicPresence?.appVisibility ?? null,
      reviewTaskType: reviewItem?.taskType ?? null,
      reviewBlockers: reviewItem?.blockers ?? [],
      curation,
    },
    correlatedCandidates: {
      searchCandidateIds: searchCandidates
        .map((candidate) => candidate.candidateId)
        .sort(),
      externalEventCandidateIds: eventCandidates
        .filter((candidate) =>
          candidate.sourceSurfaceId === surface.surfaceId ||
          candidate.platform === surface.platform
        )
        .map((candidate) => candidate.candidateId)
        .sort(),
    },
    riskFlags,
    nextAction: nextActionFor({
      artifact,
      evidenceStatus,
      riskFlags,
      surface,
    }),
  };
}

function buildArtifactMap({rawArtifacts, referencedArtifactFiles}) {
  const artifacts = new Map();
  for (const artifact of rawArtifacts) {
    artifacts.set(normalizePath(artifact.path), {
      ...artifact,
      source: "raw_artifact_storage_manifest",
    });
  }
  for (const file of referencedArtifactFiles) {
    const path = normalizePath(file.path);
    if (artifacts.has(path)) continue;
    artifacts.set(path, {
      artifactId: artifactIdFor(path, file.sha256),
      path,
      artifactKind: "referenced_evidence_file",
      storageClass: "reviewed_source_reference",
      sizeBytes: file.sizeBytes,
      sha256: file.sha256,
      containsRawProviderPayload: false,
      firestoreMode: "not_applicable_local_source_reference",
      retention: {
        status: "repo_reviewed",
        retentionDays: null,
        deletionMode: "git_reviewed",
      },
      storagePlan: {
        action: "not_required",
        remoteObjectKey: null,
        blockedBy: [],
        reason:
          "Referenced evidence file is a reviewed local source reference; it is not a raw provider payload upload candidate.",
      },
      source: "evidence_ref_file",
    });
  }
  return artifacts;
}

function artifactForEvidence(artifactMap, evidence) {
  if (!evidence.ref) return null;
  return artifactMap.get(normalizePath(evidence.ref)) ?? null;
}

function evidenceStatusFor(evidence, artifact) {
  if (evidence.type === "missingEvidence") return "missing_surface_evidence";
  if (!evidence.ref) return "manual_report_without_artifact";
  if (artifact) return "resolved_artifact";
  if (/^https?:\/\//i.test(evidence.ref)) return "external_url_reference";
  return "unresolved_local_reference";
}

function riskFlagsFor({artifact, evidence, evidenceStatus, surface}) {
  const flags = [];
  if (evidenceStatus === "missing_surface_evidence") {
    flags.push("surface_has_no_evidence_refs");
  }
  if (evidenceStatus === "manual_report_without_artifact") {
    flags.push("manual_report_without_artifact");
  }
  if (evidenceStatus === "unresolved_local_reference") {
    flags.push("unresolved_local_reference");
  }
  if (surface.status !== "active") flags.push(`surface_${surface.status}`);
  if (surface.role === "rejected") flags.push("surface_rejected");
  if (!surface.url) flags.push("surface_url_missing");
  if (artifact?.containsRawProviderPayload) {
    flags.push("raw_provider_payload");
  }
  if (artifact?.firestoreMode === "forbidden_raw_or_source_payload") {
    flags.push("firestore_forbidden_payload");
  }
  if (artifact?.storagePlan?.action === "blocked") {
    flags.push("remote_upload_blocked");
  }
  if (evidence.type === "userReportedSearchResult") {
    flags.push("user_reported_evidence");
  }
  return [...new Set(flags)].sort();
}

function nextActionFor({artifact, evidenceStatus, riskFlags, surface}) {
  if (riskFlags.includes("surface_has_no_evidence_refs")) {
    return "attach_reviewed_source_evidence_before_publication";
  }
  if (riskFlags.includes("unresolved_local_reference")) {
    return "restore_or_correct_referenced_evidence_file";
  }
  if (riskFlags.includes("manual_report_without_artifact")) {
    return "capture_or_attach_reviewed_artifact_for_manual_report";
  }
  if (surface.status !== "active") {
    return "curate_surface_state_before_using_for_public_or_crawl_outputs";
  }
  if (artifact?.containsRawProviderPayload) {
    return "keep_raw_payload_out_of_firestore_and_review_retention_policy";
  }
  return evidenceStatus === "resolved_artifact" ?
    "evidence_available_for_admin_review" :
    "review_evidence_reference";
}

function artifactSummary(artifact) {
  return {
    artifactId: artifact.artifactId,
    path: artifact.path,
    artifactKind: artifact.artifactKind,
    storageClass: artifact.storageClass,
    sizeBytes: artifact.sizeBytes,
    sha256: artifact.sha256,
    source: artifact.source,
    containsRawProviderPayload: artifact.containsRawProviderPayload === true,
    firestoreMode: artifact.firestoreMode,
    retentionStatus: artifact.retention?.status ?? null,
    storageAction: artifact.storagePlan?.action ?? null,
    remoteObjectKey: artifact.storagePlan?.remoteObjectKey ?? null,
  };
}

function artifactCoverageRows({artifactMap, records}) {
  const recordsByArtifact = new Map();
  for (const record of records) {
    const artifactPath = record.artifact?.path;
    if (!artifactPath) continue;
    if (!recordsByArtifact.has(artifactPath)) recordsByArtifact.set(artifactPath, []);
    recordsByArtifact.get(artifactPath).push(record.evidenceId);
  }

  return [...artifactMap.values()]
    .map((artifact) => ({
      ...artifactSummary(artifact),
      referencedByEvidenceIds:
        recordsByArtifact.get(artifact.path)?.sort() ?? [],
    }))
    .sort((a, b) => a.path.localeCompare(b.path));
}

function summaryFor({artifactCoverage, records}) {
  const rawArtifacts = artifactCoverage.filter((artifact) =>
    artifact.containsRawProviderPayload
  );
  return {
    records: records.length,
    hosts: new Set(records.map((record) => record.canonicalHostId)).size,
    surfaces: new Set(records.map((record) =>
      `${record.entityId}:${record.surface.surfaceId}`
    )).size,
    surfacesWithoutEvidence: records.filter((record) =>
      record.evidence.status === "missing_surface_evidence").length,
    resolvedArtifactRefs: records.filter((record) =>
      record.evidence.status === "resolved_artifact").length,
    unresolvedLocalRefs: records.filter((record) =>
      record.evidence.status === "unresolved_local_reference").length,
    manualReportsWithoutArtifacts: records.filter((record) =>
      record.evidence.status === "manual_report_without_artifact").length,
    externalUrlRefs: records.filter((record) =>
      record.evidence.status === "external_url_reference").length,
    rawProviderArtifacts: rawArtifacts.length,
    rawProviderArtifactsReferenced: rawArtifacts.filter((artifact) =>
      artifact.referencedByEvidenceIds.length > 0).length,
    rawPayloadBytes: rawArtifacts.reduce((sum, artifact) =>
      sum + artifact.sizeBytes, 0),
    firestoreForbiddenArtifactRefs: records.filter((record) =>
      record.riskFlags.includes("firestore_forbidden_payload")).length,
    remoteUploadBlockedArtifactRefs: records.filter((record) =>
      record.riskFlags.includes("remote_upload_blocked")).length,
    evidenceByStatus: countBy(records.map((record) => ({
      status: record.evidence.status,
    })), "status"),
    evidenceByType: countBy(records.map((record) => ({
      type: record.evidence.type,
    })), "type"),
    surfaceStatuses: countBy(records.map((record) => ({
      status: record.surface.status,
    })), "status"),
    publishStatuses: countBy(records.map((record) => ({
      status: record.reviewState.publishStatus,
    })), "status"),
    artifactKinds: countBy(artifactCoverage, "artifactKind"),
  };
}

function curationSummaryBySurface(curationState) {
  const bySurface = new Map();
  for (const operation of curationState.attachedSurfaces ?? []) {
    const id = operation.surface?.surfaceId ?? operation.surfaceId;
    if (!operation.entityId || !id) continue;
    bySurface.set(surfaceKey(operation.entityId, id), {
      operation: "attach_surface",
      reason: operation.reason,
      sourceCandidateId: operation.sourceCandidateId ?? null,
    });
  }
  for (const operation of curationState.surfaceDecisions ?? []) {
    bySurface.set(surfaceKey(operation.entityId, operation.surfaceId), {
      operation: "surface_decision",
      decision: operation.decision,
      reason: operation.reason,
    });
  }
  for (const operation of curationState.splitSurfaces ?? []) {
    bySurface.set(surfaceKey(operation.entityId, operation.surfaceId), {
      operation: "split_surface",
      newEntityId: operation.newEntityId,
      reason: operation.reason,
    });
  }
  return bySurface;
}

function groupBy(items, field) {
  const groups = new Map();
  for (const item of items) {
    const key = item[field];
    if (!key) continue;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(item);
  }
  for (const [key, values] of groups.entries()) {
    groups.set(key, [...values].sort((a, b) =>
      JSON.stringify(a).localeCompare(JSON.stringify(b))
    ));
  }
  return groups;
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

function missingEvidenceRef() {
  return {
    type: "missingEvidence",
    ref: null,
    description: "Surface has no evidence refs attached.",
  };
}

function evidenceIdFor(entityId, surfaceId, evidence, index) {
  return [
    "evidence",
    slugPart(entityId),
    slugPart(surfaceId),
    slugPart(evidence.type),
    slugPart(evidence.ref ?? `missing-${index + 1}`),
  ].join("-");
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

function surfaceKey(entityId, surfaceId) {
  return `${entityId}:${surfaceId}`;
}

function slugPart(value) {
  return String(value ?? "unknown")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "") || "unknown";
}

function normalizePath(value) {
  return String(value ?? "").replaceAll("\\", "/");
}

function emptyCanonicalHostEntities() {
  return {entries: []};
}

function emptyRawArtifactStorageManifest() {
  return {artifacts: []};
}

function emptyCurationState() {
  return {
    attachedSurfaces: [],
    surfaceDecisions: [],
    splitSurfaces: [],
  };
}

function emptyReviewQueue() {
  return {items: []};
}

function emptySearchResultCandidateQueue() {
  return {candidates: []};
}

function emptyExternalEventCandidateQueue() {
  return {candidates: []};
}
