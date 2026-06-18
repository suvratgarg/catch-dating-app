const MAX_EVIDENCE_REVIEW_RECORDS_PER_PACKET = 24;

export function buildPublicationReviewPackets({
  canonicalHostEntities = emptyCanonicalHostEntities(),
  canonicalEvidenceIndex = emptyCanonicalEvidenceIndex(),
  entityList = [],
  reviewQueue = emptyReviewQueue(),
  projectionPlan = emptyProjectionPlan(),
  claimTargetPlan = emptyClaimTargetPlan(),
} = {}) {
  const entityById = new Map(entityList.map((entity) => [entity.entityId, entity]));
  const reviewByEntity = new Map(
    (reviewQueue.items ?? []).map((item) => [item.entityId, item])
  );
  const projectionByEntity = new Map(
    (projectionPlan.entries ?? []).map((entry) => [entry.entityId, entry])
  );
  const claimTargetByEntity = new Map(
    (claimTargetPlan.targets ?? []).map((target) => [target.entityId, target])
  );
  const evidenceByEntity = groupBy(
    canonicalEvidenceIndex.records ?? [],
    "entityId"
  );

  const packets = (canonicalHostEntities.entries ?? [])
    .map((host) => packetForHost({
      claimTarget: claimTargetByEntity.get(host.entityId) ?? null,
      entity: entityById.get(host.entityId) ?? null,
      evidenceRecords: evidenceByEntity.get(host.entityId) ?? [],
      host,
      projection: projectionByEntity.get(host.entityId) ?? null,
      reviewItem: reviewByEntity.get(host.entityId) ?? null,
    }))
    .sort((a, b) =>
      packetRank(a) - packetRank(b) ||
      a.priority.localeCompare(b.priority) ||
      a.entityId.localeCompare(b.entityId)
    );

  return {
    schemaVersion: 1,
    generatedFrom: {
      canonicalHostEntities:
        "tool/organizer_intake/generated/canonical_host_entities.json",
      canonicalEvidenceIndex:
        "tool/organizer_intake/generated/canonical_evidence_index.json",
      adminReviewQueue:
        "tool/organizer_intake/generated/admin_review_queue.json",
      projectionPlan:
        "tool/organizer_intake/generated/public_projection_plan.json",
      claimTargetPlan:
        "tool/organizer_intake/generated/organizer_claim_targets.json",
    },
    summary: summaryForPackets(packets),
    guardrails: [
      "Publication review packets are decision support only; they do not publish pages, index pages, sync claim targets, or write Firestore.",
      "Manual admin approval remains required even when all data gates are satisfied.",
      "App discoverability, claim sync, crawl approval, and event import approval remain separate gates from website publication.",
      "Manual reports without artifacts should be reviewed as prompts, not treated as resolved source evidence.",
    ],
    packets,
  };
}

function packetForHost({
  claimTarget,
  entity,
  evidenceRecords,
  host,
  projection,
  reviewItem,
}) {
  const gates = reviewItem?.gates ?? [];
  const blockers = reviewItem?.blockers ??
    projection?.blockedBy ??
    ["manual_admin_review_required"];
  const dataBlockers = blockers.filter((blocker) =>
    blocker !== "manual_admin_review_required"
  );
  const evidenceSummary = evidenceSummaryFor(evidenceRecords);
  const evidenceReview = evidenceReviewFor(evidenceRecords);
  const evidenceBlockers = evidenceBlockersFor(evidenceSummary);
  const publicDraft = publicDraftFor(entity);
  const checklist = approvalChecklistFor({dataBlockers, evidenceBlockers, gates});
  const status = packetStatusFor({
    blockers,
    dataBlockers,
    evidenceBlockers,
    projection,
    reviewItem,
  });

  return {
    packetId: `publication-review-${host.entityId}`,
    canonicalHostId: host.canonicalHostId,
    entityId: host.entityId,
    displayName: host.displayName,
    priority: host.priority,
    taskType: reviewItem?.taskType ?? "publication_review",
    status,
    recommendedAction: recommendedActionFor({status, evidenceSummary}),
    identity: {
      entityKind: host.entityKind,
      aliases: host.aliases ?? [],
      activity: host.activity,
      geography: host.geography,
    },
    publicPresence: {
      canonicalPath:
        projection?.canonicalPath ??
        host.publicPresence?.canonicalPath ??
        null,
      legacyPaths:
        projection?.legacyPaths ??
        host.publicPresence?.legacyPaths ??
        [],
      projectionStatus:
        projection?.projectionStatus ??
        host.publicPresence?.projectionStatus ??
        "blocked",
      publishStatus:
        projection?.publishStatus ??
        host.publicPresence?.publishStatus ??
        "blocked",
      indexStatus:
        projection?.indexStatus ??
        host.publicPresence?.indexStatus ??
        "noindex",
      appVisibility:
        projection?.appVisibility ??
        host.publicPresence?.appVisibility ??
        "hidden",
      claimTargetPath: claimTarget?.path ?? host.claim?.claimTargetPath ?? null,
    },
    publicDraft,
    surfaceSummary: host.surfaceInventory,
    evidenceSummary,
    evidenceReview,
    evidenceRecordIds: evidenceRecords
      .map((record) => record.evidenceId)
      .sort(),
    curation: host.curation,
    gates,
    blockers,
    dataBlockers,
    evidenceBlockers,
    approvalChecklist: checklist,
    adminDecision: {
      currentDecision: reviewItem?.reviewDecision ?? null,
      allowedDecisions: ["approve_public", "hold", "suppress"],
      defaultAppVisibility: "hidden",
      command: publicationDecisionCommandFor(host.entityId, evidenceSummary),
    },
    nextActions: nextActionsFor({
      dataBlockers,
      evidenceBlockers,
      host,
      status,
    }),
  };
}

function publicationDecisionCommandFor(entityId, evidenceSummary) {
  const manualReportFlag =
    evidenceSummary.manualReportsWithoutArtifacts > 0 ?
      " --confirm-manual-reports-reviewed" :
      "";
  return `node tool/organizer_intake/review_decision.mjs draft ${entityId} ` +
    "--decision approve_public --app-visibility hidden --reviewer REVIEWER " +
    "--date YYYY-MM-DD --note \"Manual publication QA complete.\" " +
    `--confirm-publication-checklist${manualReportFlag}`;
}

function evidenceSummaryFor(records) {
  const allFlags = [...new Set(
    records.flatMap((record) => record.riskFlags ?? [])
  )].sort();
  return {
    records: records.length,
    resolvedArtifactRefs: records.filter((record) =>
      record.evidence?.status === "resolved_artifact").length,
    manualReportsWithoutArtifacts: records.filter((record) =>
      record.evidence?.status === "manual_report_without_artifact").length,
    unresolvedLocalRefs: records.filter((record) =>
      record.evidence?.status === "unresolved_local_reference").length,
    missingSurfaceEvidence: records.filter((record) =>
      record.evidence?.status === "missing_surface_evidence").length,
    rawProviderArtifactRefs: records.filter((record) =>
      record.riskFlags?.includes("raw_provider_payload")).length,
    firestoreForbiddenArtifactRefs: records.filter((record) =>
      record.riskFlags?.includes("firestore_forbidden_payload")).length,
    riskFlags: allFlags,
    byStatus: countBy(records.map((record) => ({
      status: record.evidence?.status ?? "unknown",
    })), "status"),
    byType: countBy(records.map((record) => ({
      type: record.evidence?.type ?? "unknown",
    })), "type"),
  };
}

function evidenceReviewFor(records) {
  const sortedRecords = [...records].sort(evidenceRecordComparator);
  const reviewRecords = sortedRecords
    .slice(0, MAX_EVIDENCE_REVIEW_RECORDS_PER_PACKET)
    .map(evidenceReviewRecordFor);

  return {
    totalRecords: sortedRecords.length,
    shownRecords: reviewRecords.length,
    truncated:
      sortedRecords.length > MAX_EVIDENCE_REVIEW_RECORDS_PER_PACKET,
    artifactBackedRecords: sortedRecords.filter((record) =>
      record.evidence?.status === "resolved_artifact").length,
    manualReportsWithoutArtifacts: sortedRecords.filter((record) =>
      record.evidence?.status === "manual_report_without_artifact").length,
    unresolvedLocalRefs: sortedRecords.filter((record) =>
      record.evidence?.status === "unresolved_local_reference").length,
    missingSurfaceEvidence: sortedRecords.filter((record) =>
      record.evidence?.status === "missing_surface_evidence").length,
    externalUrlRefs: sortedRecords.filter((record) =>
      record.evidence?.status === "external_url_reference").length,
    rawProviderArtifactRefs: sortedRecords.filter((record) =>
      record.riskFlags?.includes("raw_provider_payload")).length,
    records: reviewRecords,
  };
}

function evidenceReviewRecordFor(record) {
  return {
    evidenceId: record.evidenceId,
    surface: {
      surfaceId: record.surface?.surfaceId ?? null,
      platform: record.surface?.platform ?? "unknown",
      surfaceKind: record.surface?.surfaceKind ?? "unknown",
      role: record.surface?.role ?? "unknown",
      status: record.surface?.status ?? "unknown",
      url: record.surface?.url ?? null,
      normalizedKey: record.surface?.normalizedKey ?? null,
      supportsEventExtraction:
        record.surface?.supportsEventExtraction === true,
    },
    evidence: {
      type: record.evidence?.type ?? "unknown",
      status: record.evidence?.status ?? "unknown",
      ref: record.evidence?.ref ?? null,
      description: record.evidence?.description ?? null,
    },
    artifact: record.artifact ? {
      artifactId: record.artifact.artifactId,
      path: record.artifact.path,
      artifactKind: record.artifact.artifactKind,
      storageClass: record.artifact.storageClass,
      sizeBytes: record.artifact.sizeBytes,
      sha256: record.artifact.sha256,
      containsRawProviderPayload:
        record.artifact.containsRawProviderPayload === true,
      firestoreMode: record.artifact.firestoreMode,
      retentionStatus: record.artifact.retentionStatus ?? null,
      storageAction: record.artifact.storageAction ?? null,
    } : null,
    correlatedCandidates: {
      searchCandidateIds:
        [...(record.correlatedCandidates?.searchCandidateIds ?? [])].sort(),
      externalEventCandidateIds:
        [...(record.correlatedCandidates?.externalEventCandidateIds ?? [])]
          .sort(),
    },
    riskFlags: [...(record.riskFlags ?? [])].sort(),
    nextAction: record.nextAction ?? "review_evidence_reference",
    reviewerUse: {
      artifactAvailable: record.artifact !== null && record.artifact !== undefined,
      manualReportWithoutArtifact:
        record.evidence?.status === "manual_report_without_artifact",
      missingSurfaceEvidence:
        record.evidence?.status === "missing_surface_evidence",
      unresolvedLocalReference:
        record.evidence?.status === "unresolved_local_reference",
      sourceUrlAvailable:
        Boolean(record.surface?.url) || /^https?:\/\//i.test(record.evidence?.ref ?? ""),
    },
  };
}

function evidenceRecordComparator(a, b) {
  return String(a.surface?.platform ?? "").localeCompare(
    String(b.surface?.platform ?? "")
  ) ||
    String(a.surface?.surfaceId ?? "").localeCompare(
      String(b.surface?.surfaceId ?? "")
    ) ||
    String(a.evidence?.status ?? "").localeCompare(
      String(b.evidence?.status ?? "")
    ) ||
    String(a.evidenceId ?? "").localeCompare(String(b.evidenceId ?? ""));
}

function evidenceBlockersFor(summary) {
  const blockers = [];
  if (summary.records === 0) blockers.push("no_evidence_records");
  if (summary.missingSurfaceEvidence > 0) {
    blockers.push("surface_missing_evidence");
  }
  if (summary.unresolvedLocalRefs > 0) {
    blockers.push("unresolved_local_evidence_refs");
  }
  return blockers;
}

function approvalChecklistFor({dataBlockers, evidenceBlockers, gates}) {
  const gatePassed = (id) =>
    gates.find((gate) => gate.id === id)?.passed === true;
  return {
    identityReviewed:
      dataBlockers.length === 0 && gatePassed("identity_surface_present"),
    surfaceInventoryReviewed:
      dataBlockers.length === 0 && gatePassed("surface_inventory_reviewable"),
    ownerSafeCopyReviewed:
      dataBlockers.length === 0 && gatePassed("owner_safe_public_draft"),
    marketScopeReviewed:
      dataBlockers.length === 0 && gatePassed("market_model_present"),
    mediaRightsReviewed: evidenceBlockers.length === 0,
    crawlDisabledReviewed:
      dataBlockers.length === 0 && gatePassed("crawl_disabled_by_default"),
  };
}

function packetStatusFor({
  blockers,
  dataBlockers,
  evidenceBlockers,
  projection,
  reviewItem,
}) {
  if (projection?.publishStatus === "published") return "published";
  if (projection?.publishStatus === "suppressed") return "suppressed";
  if (reviewItem?.reviewDecision?.decision === "hold") return "held";
  if (reviewItem?.reviewDecision?.decision === "suppress") return "suppressed";
  if (dataBlockers.length > 0 || evidenceBlockers.length > 0) {
    return "blocked_by_data";
  }
  if (blockers.includes("manual_admin_review_required")) {
    return "ready_for_manual_publication_review";
  }
  return "ready_for_manual_publication_review";
}

function recommendedActionFor({status, evidenceSummary}) {
  if (status === "published") return "Already published; keep monitoring claim and source freshness.";
  if (status === "suppressed") return "Keep suppressed unless a new reviewed source changes the decision.";
  if (status === "held") return "Review the hold decision and capture missing admin input.";
  if (status === "blocked_by_data") {
    return "Resolve data or evidence blockers before publication approval.";
  }
  if (evidenceSummary.manualReportsWithoutArtifacts > 0) {
    return "Admin can approve only after reviewing manual reports as prompts, not identity proof.";
  }
  return "Admin can perform final QA and record an approve_public decision.";
}

function nextActionsFor({dataBlockers, evidenceBlockers, host, status}) {
  const actions = [];
  if (dataBlockers.length > 0) actions.push("resolve_review_gate_blockers");
  if (evidenceBlockers.length > 0) actions.push("resolve_evidence_blockers");
  if (host.surfaceInventory?.ambiguous > 0 ||
    host.surfaceInventory?.rejected > 0) {
    actions.push("review_ambiguous_or_rejected_surfaces");
  }
  if (status === "ready_for_manual_publication_review") {
    actions.push("record_manual_publication_decision");
  }
  actions.push("keep_app_hidden_until_claim_or_explicit_app_approval");
  actions.push("keep_crawls_and_event_imports_disabled");
  return [...new Set(actions)].sort();
}

function publicDraftFor(entity) {
  const draft = entity?.publicDraft ?? {};
  return {
    headline: draft.headline ?? null,
    summary: draft.summary ?? null,
    sourceSummary: draft.sourceSummary ?? null,
    formats: [...(draft.formats ?? [])].sort(),
    missingEvidence: [...(draft.missingEvidence ?? [])].sort(),
  };
}

function summaryForPackets(packets) {
  return {
    packets: packets.length,
    readyForManualPublicationReview: packets.filter((packet) =>
      packet.status === "ready_for_manual_publication_review").length,
    blockedByData: packets.filter((packet) =>
      packet.status === "blocked_by_data").length,
    published: packets.filter((packet) =>
      packet.status === "published").length,
    suppressed: packets.filter((packet) =>
      packet.status === "suppressed").length,
    held: packets.filter((packet) =>
      packet.status === "held").length,
    evidenceRecords: packets.reduce((sum, packet) =>
      sum + packet.evidenceSummary.records, 0),
    manualReportsWithoutArtifacts: packets.reduce((sum, packet) =>
      sum + packet.evidenceSummary.manualReportsWithoutArtifacts, 0),
    unresolvedEvidenceRefs: packets.reduce((sum, packet) =>
      sum + packet.evidenceSummary.unresolvedLocalRefs, 0),
    missingSurfaceEvidence: packets.reduce((sum, packet) =>
      sum + packet.evidenceSummary.missingSurfaceEvidence, 0),
    packetsByStatus: countBy(packets, "status"),
    packetsByTaskType: countBy(packets, "taskType"),
  };
}

function packetRank(packet) {
  return {
    blocked_by_data: 0,
    ready_for_manual_publication_review: 1,
    held: 2,
    published: 3,
    suppressed: 4,
  }[packet.status] ?? 9;
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

function emptyCanonicalHostEntities() {
  return {entries: []};
}

function emptyCanonicalEvidenceIndex() {
  return {records: []};
}

function emptyReviewQueue() {
  return {items: []};
}

function emptyProjectionPlan() {
  return {entries: []};
}

function emptyClaimTargetPlan() {
  return {targets: []};
}
