export function buildExternalEventCandidateQueue(batches, options = {}) {
  const errors = [];
  const warnings = [];
  const candidates = [];
  const reviewDecisionState = buildReviewDecisionState(
    options.reviewDecisionBatches ?? [],
    errors
  );
  const locationResolutionState = buildLocationResolutionState(
    options.locationResolutionBatches ?? [],
    errors
  );

  for (const batch of [...batches].sort((a, b) =>
    String(a.batchId).localeCompare(String(b.batchId)))) {
    validateBatch(batch, errors);
    for (const event of [...(batch.events ?? [])].sort(compareEvents)) {
      const candidate = candidateForEvent(
        batch,
        event,
        warnings,
        reviewDecisionState.byCandidateId,
        locationResolutionState.byCandidateId
      );
      if (candidate) candidates.push(candidate);
    }
  }

  const duplicateEventKeys = duplicateKeys(candidates, "normalizedEventKey");
  validateReviewDecisionReferences(
    reviewDecisionState.byCandidateId,
    candidates,
    errors
  );
  validateLocationResolutionReferences(
    locationResolutionState.byCandidateId,
    candidates,
    errors
  );
  return {
    schemaVersion: 1,
    generatedFrom: {
      batches: batches.map((batch) => batch.batchId).sort(),
      reviewDecisionBatches: reviewDecisionState.batchIds,
      locationResolutionBatches: locationResolutionState.batchIds,
    },
    policy: {
      status: "disabled",
      reason:
        "External event import is modeled for review only. No recurring crawl, " +
        "Firestore event write, or host notification is enabled by this artifact.",
      importWritesEnabled: false,
    },
    summary: {
      batches: batches.length,
      events: batches.reduce((sum, batch) => sum + (batch.events?.length ?? 0), 0),
      candidates: candidates.length,
      platforms: countBy(candidates, "platform"),
      duplicateEventKeys: duplicateEventKeys.length,
      blocked: candidates.filter((candidate) =>
        candidate.importReadiness === "blocked").length,
      reviewed: candidates.filter((candidate) => candidate.reviewDecision).length,
      approvedForImport: candidates.filter((candidate) =>
        candidate.reviewStatus === "approved_for_import").length,
      held: candidates.filter((candidate) =>
        candidate.reviewStatus === "held").length,
      rejected: candidates.filter((candidate) =>
        candidate.reviewStatus === "rejected").length,
      locationResolved: candidates.filter((candidate) =>
        candidate.locationResolution).length,
    },
    candidates,
    duplicateEventKeys,
    warnings: warnings.sort(),
    errors: errors.sort(),
    commands: {
      captureLuma:
        "node tool/organizer_intake/capture_luma_events.mjs " +
        "--entity ENTITY --surface SURFACE --raw-results LUMA_JSON --date YYYY-MM-DD",
      ingest:
        "node tool/organizer_intake/ingest_event_sources.mjs",
      review:
        "node tool/organizer_intake/event_review_decision.mjs list",
      exportReviewDecisions:
        "node tool/organizer_intake/export_event_review_decisions_from_firestore.mjs " +
        "--env dev --date YYYY-MM-DD",
      exportLocationResolutions:
        "node tool/organizer_intake/export_event_location_resolutions_from_firestore.mjs " +
        "--env dev --date YYYY-MM-DD",
    },
  };
}

function candidateForEvent(
  batch,
  event,
  warnings,
  reviewDecisions,
  locationResolutions
) {
  const label = `${batch.batchId}/${event.sourceEventId ?? "<unknown>"}`;
  if (!isIsoDateTime(event.startAt)) {
    warnings.push(`${label}: skipped event with invalid startAt.`);
    return null;
  }
  const sourceEventId = event.sourceEventId;
  const candidateId = `${batch.batchId}:${sourceEventId}`;
  const eventUrl = event.eventUrl ?? batch.sourceUrl ?? null;
  const normalizedEventKey = [
    batch.entityId,
    event.startAt,
    slugify(event.title),
  ].join(":");
  const reviewDecision = reviewDecisions.get(candidateId) ?? null;
  const reviewState = eventReviewState(reviewDecision);
  const locationResolution = locationResolutions.get(candidateId) ?? null;
  const sourceLocation = {
    name: event.locationName ?? null,
    address: event.address ?? null,
    citySlug: event.citySlug ?? batch.citySlug ?? null,
    countryCode: event.countryCode ?? batch.countryCode ?? null,
    latitude: numericOrNull(event.latitude),
    longitude: numericOrNull(event.longitude),
    placeId: event.placeId ?? null,
    notes: null,
  };
  const location = locationResolution ?
    resolvedLocation(sourceLocation, locationResolution) :
    sourceLocation;
  return {
    candidateId,
    batchId: batch.batchId,
    entityId: batch.entityId,
    surfaceId: batch.surfaceId,
    platform: batch.platform,
    sourceUrl: batch.sourceUrl ?? null,
    sourceEventId,
    sourceEventKey: `${batch.platform}:event:${sourceEventId}`,
    normalizedEventKey,
    title: event.title,
    description: event.description ?? null,
    startAt: event.startAt,
    endAt: event.endAt ?? null,
    timezone: event.timezone ?? batch.timezone ?? null,
    location,
    locationResolution: locationResolutionSummary(locationResolution),
    eventUrl,
    imageUrl: event.imageUrl ?? null,
    priceText: event.priceText ?? null,
    sourceStatus: event.status ?? "scheduled",
    reviewStatus: reviewState.reviewStatus,
    reviewDecision: reviewState.reviewDecision,
    importReadiness: reviewState.importReadiness,
    importState: reviewState.importState,
    blockers: reviewState.blockers,
    reviewAction: "review_external_event_candidate",
    diagnostics: diagnosticsFor(event, eventUrl, location),
  };
}

function buildReviewDecisionState(decisionBatches, errors) {
  const byCandidateId = new Map();
  const batchIds = [];
  const seenBatchIds = new Set();
  for (const batch of [...decisionBatches].sort((a, b) =>
    String(a.eventReviewBatchId).localeCompare(String(b.eventReviewBatchId)))) {
    const prefix = batch.file ?? batch.eventReviewBatchId ?? "<event-review>";
    if (batch.schemaVersion !== 1) errors.push(`${prefix}: schemaVersion must be 1.`);
    if (!isSlug(batch.eventReviewBatchId)) {
      errors.push(`${prefix}: invalid eventReviewBatchId.`);
    } else if (seenBatchIds.has(batch.eventReviewBatchId)) {
      errors.push(`${prefix}: duplicate eventReviewBatchId ${batch.eventReviewBatchId}.`);
    } else {
      seenBatchIds.add(batch.eventReviewBatchId);
      batchIds.push(batch.eventReviewBatchId);
    }
    if (!/^\d{4}-\d{2}-\d{2}$/.test(batch.decidedAt ?? "")) {
      errors.push(`${prefix}: decidedAt must be YYYY-MM-DD.`);
    }
    if (!batch.reviewer || typeof batch.reviewer !== "string") {
      errors.push(`${prefix}: reviewer is required.`);
    }
    if (!Array.isArray(batch.decisions)) {
      errors.push(`${prefix}: decisions must be an array.`);
      continue;
    }
    for (const [index, decision] of batch.decisions.entries()) {
      const decisionPrefix = `${prefix}/decisions[${index}]`;
      if (!decision.candidateId || typeof decision.candidateId !== "string") {
        errors.push(`${decisionPrefix}: candidateId is required.`);
      } else if (byCandidateId.has(decision.candidateId)) {
        errors.push(`${decisionPrefix}: duplicate decision for ${decision.candidateId}.`);
      }
      if (!["approve_for_import", "hold", "reject"].includes(decision.decision)) {
        errors.push(`${decisionPrefix}: invalid decision ${decision.decision}.`);
      }
      validateReviewChecklist(decision.checklist, decisionPrefix, errors);
      if (!decision.note || typeof decision.note !== "string") {
        errors.push(`${decisionPrefix}: note is required.`);
      }
      if (decision.decision === "approve_for_import" &&
        !reviewChecklistComplete(decision.checklist)) {
        errors.push(`${decisionPrefix}: approve_for_import has an incomplete checklist.`);
      }
      if (decision.candidateId) {
        byCandidateId.set(decision.candidateId, {
          checklist: decision.checklist,
          decidedAt: batch.decidedAt,
          decision: decision.decision,
          eventReviewBatchId: batch.eventReviewBatchId,
          note: decision.note,
          reviewer: batch.reviewer,
        });
      }
    }
  }
  return {batchIds: batchIds.sort(), byCandidateId};
}

function buildLocationResolutionState(resolutionBatches, errors) {
  const byCandidateId = new Map();
  const batchIds = [];
  const seenBatchIds = new Set();
  for (const batch of [...resolutionBatches].sort((a, b) =>
    String(a.locationResolutionBatchId).localeCompare(
      String(b.locationResolutionBatchId)
    ))) {
    const prefix = batch.file ??
      batch.locationResolutionBatchId ??
      "<event-location-resolution>";
    if (batch.schemaVersion !== 1) errors.push(`${prefix}: schemaVersion must be 1.`);
    if (!isSlug(batch.locationResolutionBatchId)) {
      errors.push(`${prefix}: invalid locationResolutionBatchId.`);
    } else if (seenBatchIds.has(batch.locationResolutionBatchId)) {
      errors.push(
        `${prefix}: duplicate locationResolutionBatchId ` +
          `${batch.locationResolutionBatchId}.`
      );
    } else {
      seenBatchIds.add(batch.locationResolutionBatchId);
      batchIds.push(batch.locationResolutionBatchId);
    }
    if (!/^\d{4}-\d{2}-\d{2}$/.test(batch.resolvedAt ?? "")) {
      errors.push(`${prefix}: resolvedAt must be YYYY-MM-DD.`);
    }
    if (!batch.reviewer || typeof batch.reviewer !== "string") {
      errors.push(`${prefix}: reviewer is required.`);
    }
    if (!Array.isArray(batch.resolutions)) {
      errors.push(`${prefix}: resolutions must be an array.`);
      continue;
    }
    for (const [index, resolution] of batch.resolutions.entries()) {
      const resolutionPrefix = `${prefix}/resolutions[${index}]`;
      if (!resolution.candidateId ||
        typeof resolution.candidateId !== "string") {
        errors.push(`${resolutionPrefix}: candidateId is required.`);
      } else if (byCandidateId.has(resolution.candidateId)) {
        errors.push(
          `${resolutionPrefix}: duplicate resolution for ` +
            `${resolution.candidateId}.`
        );
      }
      validateLocationResolution(resolution, resolutionPrefix, errors);
      if (resolution.candidateId) {
        byCandidateId.set(resolution.candidateId, {
          checklist: resolution.checklist,
          location: resolution.location,
          locationResolutionBatchId: batch.locationResolutionBatchId,
          note: resolution.note,
          resolvedAt: batch.resolvedAt,
          reviewer: batch.reviewer,
        });
      }
    }
  }
  return {batchIds: batchIds.sort(), byCandidateId};
}

function validateLocationResolution(resolution, prefix, errors) {
  if (!resolution.location || typeof resolution.location !== "object") {
    errors.push(`${prefix}: location is required.`);
  } else {
    if (!resolution.location.name ||
      typeof resolution.location.name !== "string") {
      errors.push(`${prefix}: location.name is required.`);
    }
    if (!isFiniteLatitude(resolution.location.latitude)) {
      errors.push(`${prefix}: location.latitude must be a number.`);
    }
    if (!isFiniteLongitude(resolution.location.longitude)) {
      errors.push(`${prefix}: location.longitude must be a number.`);
    }
  }
  validateLocationResolutionChecklist(resolution.checklist, prefix, errors);
  if (!locationResolutionChecklistComplete(resolution.checklist)) {
    errors.push(`${prefix}: resolution has an incomplete checklist.`);
  }
  if (!resolution.note || typeof resolution.note !== "string") {
    errors.push(`${prefix}: note is required.`);
  }
}

function validateLocationResolutionChecklist(checklist, prefix, errors) {
  const required = [
    "coordinatesReviewed",
    "importSafetyReviewed",
    "placeIdentityReviewed",
    "sourceLocationReviewed",
  ];
  if (!checklist || typeof checklist !== "object") {
    errors.push(`${prefix}: missing checklist object.`);
    return;
  }
  for (const field of required) {
    if (typeof checklist[field] !== "boolean") {
      errors.push(`${prefix}: checklist.${field} must be boolean.`);
    }
  }
}

function locationResolutionChecklistComplete(checklist) {
  return Boolean(
    checklist?.sourceLocationReviewed &&
      checklist?.coordinatesReviewed &&
      checklist?.placeIdentityReviewed &&
      checklist?.importSafetyReviewed
  );
}

function validateReviewChecklist(checklist, prefix, errors) {
  const required = [
    "dedupeReviewed",
    "identityReviewed",
    "importPolicyAcknowledged",
    "locationReviewed",
    "ownerSafeCopyReviewed",
    "sourceEventReviewed",
    "timeReviewed",
  ];
  if (!checklist || typeof checklist !== "object") {
    errors.push(`${prefix}: missing checklist object.`);
    return;
  }
  for (const field of required) {
    if (typeof checklist[field] !== "boolean") {
      errors.push(`${prefix}: checklist.${field} must be boolean.`);
    }
  }
}

function reviewChecklistComplete(checklist) {
  return Boolean(
    checklist?.identityReviewed &&
      checklist?.sourceEventReviewed &&
      checklist?.timeReviewed &&
      checklist?.locationReviewed &&
      checklist?.dedupeReviewed &&
      checklist?.ownerSafeCopyReviewed &&
      checklist?.importPolicyAcknowledged
  );
}

function validateLocationResolutionReferences(locationResolutions, candidates, errors) {
  const candidateIds = new Set(candidates.map((candidate) => candidate.candidateId));
  for (const candidateId of locationResolutions.keys()) {
    if (!candidateIds.has(candidateId)) {
      errors.push(`event location resolution references unknown candidate ${candidateId}.`);
    }
  }
}

function validateReviewDecisionReferences(reviewDecisions, candidates, errors) {
  const candidateIds = new Set(candidates.map((candidate) => candidate.candidateId));
  for (const candidateId of reviewDecisions.keys()) {
    if (!candidateIds.has(candidateId)) {
      errors.push(`event review decision references unknown candidate ${candidateId}.`);
    }
  }
}

function resolvedLocation(sourceLocation, resolution) {
  return {
    ...sourceLocation,
    name: resolution.location.name,
    address: resolution.location.address ?? sourceLocation.address,
    latitude: resolution.location.latitude,
    longitude: resolution.location.longitude,
    placeId: resolution.location.placeId ?? sourceLocation.placeId,
    notes: resolution.location.notes ?? null,
  };
}

function locationResolutionSummary(locationResolution) {
  if (!locationResolution) return null;
  return {
    checklist: locationResolution.checklist,
    locationResolutionBatchId: locationResolution.locationResolutionBatchId,
    note: locationResolution.note,
    resolvedAt: locationResolution.resolvedAt,
    reviewer: locationResolution.reviewer,
  };
}

function eventReviewState(reviewDecision) {
  if (!reviewDecision) {
    return {
      reviewStatus: "needs_admin_review",
      reviewDecision: null,
      importReadiness: "blocked",
      importState: "not_reviewed",
      blockers: [
        "global_external_event_import_disabled",
        "requires_admin_review",
        "requires_event_dedupe_review",
      ],
    };
  }
  const reviewSummary = {
    checklist: reviewDecision.checklist,
    decidedAt: reviewDecision.decidedAt,
    decision: reviewDecision.decision,
    eventReviewBatchId: reviewDecision.eventReviewBatchId,
    note: reviewDecision.note,
    reviewer: reviewDecision.reviewer,
  };
  if (reviewDecision.decision === "approve_for_import") {
    return {
      reviewStatus: "approved_for_import",
      reviewDecision: reviewSummary,
      importReadiness: "blocked",
      importState: "blocked_by_policy",
      blockers: ["global_external_event_import_disabled"],
    };
  }
  if (reviewDecision.decision === "hold") {
    return {
      reviewStatus: "held",
      reviewDecision: reviewSummary,
      importReadiness: "blocked",
      importState: "not_importable",
      blockers: [
        "global_external_event_import_disabled",
        "admin_hold",
      ],
    };
  }
  return {
    reviewStatus: "rejected",
    reviewDecision: reviewSummary,
    importReadiness: "rejected",
    importState: "not_importable",
    blockers: ["admin_rejected"],
  };
}

function diagnosticsFor(event, eventUrl, location) {
  const diagnostics = [];
  if (!eventUrl) diagnostics.push("missing_source_event_url");
  if (!event.endAt) diagnostics.push("missing_end_time");
  if (!location?.name && !location?.address) {
    diagnostics.push("missing_location_detail");
  }
  if (!event.imageUrl) diagnostics.push("missing_media");
  return diagnostics;
}

function validateBatch(batch, errors) {
  const label = batch.batchId ?? "<unknown>";
  if (batch.schemaVersion !== 1) errors.push(`${label}: schemaVersion must be 1.`);
  if (!isSlug(batch.batchId)) errors.push(`${label}: invalid batchId.`);
  if (!/^\d{4}-\d{2}-\d{2}$/.test(batch.createdAt ?? "")) {
    errors.push(`${label}: createdAt must be YYYY-MM-DD.`);
  }
  if (!batch.entityId) errors.push(`${label}: entityId is required.`);
  if (!batch.surfaceId) errors.push(`${label}: surfaceId is required.`);
  if (!["bookMyShow", "district", "luma", "partiful", "sortMyScene"].includes(batch.platform)) {
    errors.push(`${label}: unsupported event platform ${batch.platform}.`);
  }
  const ids = new Set();
  for (const event of batch.events ?? []) {
    if (!isSlug(event.sourceEventId)) {
      errors.push(`${label}: invalid sourceEventId ${event.sourceEventId}.`);
    }
    if (ids.has(event.sourceEventId)) {
      errors.push(`${label}: duplicate sourceEventId ${event.sourceEventId}.`);
    }
    ids.add(event.sourceEventId);
    if (!event.title || typeof event.title !== "string") {
      errors.push(`${label}/${event.sourceEventId}: title is required.`);
    }
  }
}

function compareEvents(left, right) {
  return String(left.startAt ?? "").localeCompare(String(right.startAt ?? "")) ||
    String(left.title ?? "").localeCompare(String(right.title ?? ""));
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

function duplicateKeys(items, field) {
  const groups = new Map();
  for (const item of items) {
    const value = item[field];
    if (!value) continue;
    if (!groups.has(value)) groups.set(value, []);
    groups.get(value).push(item.candidateId);
  }
  return [...groups.entries()]
    .filter(([, ids]) => ids.length > 1)
    .map(([normalizedEventKey, candidateIds]) => ({
      normalizedEventKey,
      candidateIds: candidateIds.sort(),
    }))
    .sort((a, b) => a.normalizedEventKey.localeCompare(b.normalizedEventKey));
}

function isSlug(value) {
  return /^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(String(value ?? ""));
}

function isIsoDateTime(value) {
  return typeof value === "string" &&
    !Number.isNaN(Date.parse(value)) &&
    /\d{4}-\d{2}-\d{2}T/.test(value);
}

function isFiniteLatitude(value) {
  return typeof value === "number" && Number.isFinite(value) &&
    value >= -90 && value <= 90;
}

function isFiniteLongitude(value) {
  return typeof value === "number" && Number.isFinite(value) &&
    value >= -180 && value <= 180;
}

function numericOrNull(value) {
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

function slugify(value) {
  return String(value ?? "event")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 80) || "event";
}
