import crypto from "node:crypto";

const defaultPolicy = {
  status: "disabled",
  writeEnabled: false,
  reason:
    "External event import is planned for read-only review only. No Catch " +
    "booking, payment, reservation, waitlist, notification, or recurring crawl " +
    "is enabled by this artifact.",
};

export function buildExternalEventImportPlan(candidateQueue, options = {}) {
  const policy = {
    ...defaultPolicy,
    ...(options.policy ?? {}),
    writeEnabled: options.writeEnabled === true,
  };
  const duplicateKeys = new Map(
    (candidateQueue.duplicateEventKeys ?? []).map((entry) => [
      entry.normalizedEventKey,
      new Set(entry.candidateIds ?? []),
    ])
  );
  const candidateById = new Map(
    (candidateQueue.candidates ?? []).map((candidate) => [
      candidate.candidateId,
      candidate,
    ])
  );
  const actions = [...(candidateQueue.candidates ?? [])]
    .sort(compareCandidates)
    .map((candidate) => actionForCandidate(candidate, {
      candidateById,
      duplicateKeys,
      policy,
    }));
  const actionsByStatus = countBy(actions, "status");
  const actionsByPlatform = countBy(actions, "platform");

  return {
    schemaVersion: 1,
    generatedFrom: {
      externalEventCandidateQueue:
        "tool/organizer_intake/generated/external_event_candidate_queue.json",
      batches: candidateQueue.generatedFrom?.batches ?? [],
      reviewDecisionBatches:
        candidateQueue.generatedFrom?.reviewDecisionBatches ?? [],
      locationResolutionBatches:
        candidateQueue.generatedFrom?.locationResolutionBatches ?? [],
    },
    policy,
    summary: {
      candidates: actions.length,
      proposedReadOnlyEvents: actions.filter((action) =>
        action.action === "publish_read_only_external_event").length,
      proposedCreates: 0,
      mergedSourceLinks: actions.filter((action) =>
        action.action === "merge_duplicate_source_link").length,
      writeReady: actions.filter((action) =>
        action.status === "write_ready").length,
      blocked: actions.filter((action) => action.status === "blocked").length,
      waitingReview: actions.filter((action) =>
        action.status === "waiting_review").length,
      rejected: actions.filter((action) =>
        action.status === "rejected").length,
      duplicateEventKeys: candidateQueue.summary?.duplicateEventKeys ?? 0,
      actionsByStatus,
      actionsByPlatform,
    },
    guardrails: [
      "event_import_writes_disabled_by_default",
      "approved_event_candidates_project_to_read_only_external_events",
      "catch_booking_payments_reservations_and_waitlists_remain_disabled",
      "duplicate_platform_listings_merge_as_outbound_links",
      "missing_coordinates_defaults_or_copy_policy_blocks_event_writes",
      "plan_outputs_are_review_artifacts_not_firestore_mutations",
    ],
    actions,
    commands: {
      ingest:
        "node tool/organizer_intake/ingest_event_sources.mjs",
      plan:
        "node tool/organizer_intake/plan_external_event_imports.mjs",
      exportReviewDecisions:
        "node tool/organizer_intake/export_event_review_decisions_from_firestore.mjs " +
        "--env dev --date YYYY-MM-DD",
    },
  };
}

function actionForCandidate(candidate, {candidateById, duplicateKeys, policy}) {
  const duplicateSet = duplicateKeys.get(candidate.normalizedEventKey);
  const duplicateGroupCandidateIds = duplicateSet ?
    [...duplicateSet].sort() :
    [];
  const canonicalCandidateId = duplicateGroupCandidateIds[0] ??
    candidate.candidateId;
  const duplicateCandidateIds = duplicateGroupCandidateIds
    .filter((candidateId) => candidateId !== candidate.candidateId);
  const duplicateCandidates = duplicateCandidateIds
    .map((candidateId) => candidateById.get(candidateId))
    .filter(Boolean);
  const duplicateRole = duplicateGroupCandidateIds.length > 0 ?
    candidate.candidateId === canonicalCandidateId ?
      "canonical" :
      "merged_source" :
    "none";
  const blockers = blockersForCandidate(candidate, {
    duplicateCandidateIds,
    duplicateRole,
    policy,
  });
  const eventId = eventIdForCandidate(candidate);
  const action = actionNameForCandidate(candidate, duplicateRole);
  const status = statusForCandidate(candidate, action, blockers);

  return {
    actionId: `import-${eventId}`,
    action,
    status,
    candidateId: candidate.candidateId,
    entityId: candidate.entityId,
    platform: candidate.platform,
    sourceEventKey: candidate.sourceEventKey,
    normalizedEventKey: candidate.normalizedEventKey,
    targetPath: `externalEvents/${eventId}`,
    reviewStatus: candidate.reviewStatus,
    importState: candidate.importState,
    blockers,
    duplicateRole,
    canonicalCandidateId,
    duplicateCandidateIds,
    source: {
      eventUrl: candidate.eventUrl,
      sourceUrl: candidate.sourceUrl,
      sourceStatus: candidate.sourceStatus,
      batchId: candidate.batchId,
      surfaceId: candidate.surfaceId,
    },
    proposedReadOnlyEventDraft: proposedReadOnlyEventDraft(candidate, eventId, {
      duplicateCandidateIds,
      duplicateCandidates,
    }),
    proposedExternalEventDocument: proposedExternalEventDocument(
      candidate,
      eventId,
      {duplicateCandidateIds, duplicateCandidates}
    ),
  };
}

function actionNameForCandidate(candidate, duplicateRole) {
  if (candidate.reviewStatus !== "approved_for_import") return "skip";
  if (duplicateRole === "merged_source") return "merge_duplicate_source_link";
  return "publish_read_only_external_event";
}

function blockersForCandidate(candidate, {
  duplicateCandidateIds,
  duplicateRole,
  policy,
}) {
  const blockers = new Set(candidate.blockers ?? []);
  if (policy.writeEnabled !== true) {
    blockers.add("global_external_event_import_disabled");
  }
  if (candidate.reviewStatus === "needs_admin_review") {
    blockers.add("requires_admin_review");
  } else if (candidate.reviewStatus === "held") {
    blockers.add("admin_hold");
  } else if (candidate.reviewStatus === "rejected") {
    blockers.add("admin_rejected");
  }
  if (candidate.reviewStatus === "approved_for_import") {
    blockers.delete("requires_admin_review");
    blockers.delete("requires_event_dedupe_review");
  }
  if (!candidate.endAt) blockers.add("missing_end_time");
  if (!candidate.location?.name && !candidate.location?.address) {
    blockers.add("missing_location_detail");
  }
  if (duplicateCandidateIds.length > 0 &&
    candidate.reviewDecision?.checklist?.dedupeReviewed !== true) {
    blockers.add("duplicate_normalized_event_key");
  }
  if (!hasExactCoordinates(candidate)) {
    blockers.add("missing_exact_coordinates");
  }
  blockers.add("requires_event_defaults_policy");
  if (duplicateRole === "merged_source") {
    blockers.delete("global_external_event_import_disabled");
    blockers.delete("missing_exact_coordinates");
    blockers.delete("missing_location_detail");
    blockers.delete("missing_end_time");
    blockers.delete("requires_event_defaults_policy");
    blockers.delete("requires_owner_safe_copy_review");
  }
  if (candidate.reviewDecision?.checklist?.ownerSafeCopyReviewed !== true) {
    blockers.add("requires_owner_safe_copy_review");
  }
  if (duplicateRole === "merged_source") {
    blockers.delete("requires_owner_safe_copy_review");
  }
  return [...blockers].sort();
}

function statusForCandidate(candidate, action, blockers) {
  if (candidate.reviewStatus === "rejected") return "rejected";
  if (action === "merge_duplicate_source_link") return "merged_duplicate";
  if (candidate.reviewStatus === "needs_admin_review") return "waiting_review";
  if (blockers.length > 0) return "blocked";
  return "write_ready";
}

function proposedReadOnlyEventDraft(candidate, eventId, {
  duplicateCandidateIds = [],
  duplicateCandidates = [],
} = {}) {
  const priceInPaise = priceInPaiseFromText(candidate.priceText);
  const locationName = candidate.location?.name ??
    candidate.location?.address ??
    "External event location";
  const locationDetails = [
    candidate.location?.address,
    candidate.location?.notes,
    candidate.eventUrl,
  ].filter(Boolean).join("\n") || null;
  const latitude = numericOrNull(candidate.location?.latitude);
  const longitude = numericOrNull(candidate.location?.longitude);
  return {
    eventId,
    canonicalHostId: candidate.entityId,
    compatibilityClubId: candidate.entityId,
    title: candidate.title,
    description: candidate.description ?? candidate.title,
    startTime: candidate.startAt,
    endTime: candidate.endAt,
    timezone: candidate.timezone ?? null,
    meetingPoint: locationName,
    meetingLocation: {
      name: locationName,
      latitude,
      longitude,
      placeId: candidate.location?.placeId ?? null,
      address: candidate.location?.address ?? null,
      notes: locationDetails,
    },
    startingPointLat: latitude,
    startingPointLng: longitude,
    locationDetails,
    photoUrl: candidate.imageUrl ?? null,
    activity: {
      version: 1,
      activityKind: activityKindForCandidate(candidate),
      interactionModel: "openFormat",
      source: "heuristic",
    },
    distanceKm: null,
    pace: null,
    capacityLimit: null,
    price: {
      displayText: candidate.priceText ?? null,
      parsedPriceInPaise: priceInPaise,
      currency: currencyFromPriceText(candidate.priceText) ?? "INR",
    },
    status: candidate.sourceStatus === "cancelled" ? "cancelled" : "active",
    booking: {
      mode: "external_outbound_only",
      catchBookingEnabled: false,
      catchPaymentsEnabled: false,
      catchReservationsEnabled: false,
      catchWaitlistEnabled: false,
      externalLinks: outboundLinksForCandidates([candidate, ...duplicateCandidates]),
    },
    discovery: {
      citySlug: candidate.location?.citySlug ?? null,
      countryCode: candidate.location?.countryCode ?? null,
      availability: "read_only_external",
      manualApprovalRequired: true,
    },
    dedupe: {
      normalizedEventKey: candidate.normalizedEventKey,
      primaryCandidateId: candidate.candidateId,
      duplicateCandidateIds,
      conflictPolicy: "single_read_only_event_with_multiple_outbound_links",
    },
    externalSource: {
      candidateId: candidate.candidateId,
      sourceEventKey: candidate.sourceEventKey,
      sourceEventId: candidate.sourceEventId,
      platform: candidate.platform,
      eventUrl: candidate.eventUrl,
      sourceUrl: candidate.sourceUrl,
    },
  };
}

function proposedExternalEventDocument(candidate, eventId, {
  duplicateCandidateIds = [],
  duplicateCandidates = [],
} = {}) {
  const draft = proposedReadOnlyEventDraft(candidate, eventId, {
    duplicateCandidateIds,
    duplicateCandidates,
  });
  const reviewedAt = timestampFromDateOrIso(
    candidate.reviewDecision?.decidedAt ?? candidate.startAt
  );
  return {
    schemaVersion: 1,
    eventId,
    canonicalHostId: draft.canonicalHostId,
    compatibilityClubId: draft.compatibilityClubId,
    title: draft.title,
    description: draft.description,
    startTime: timestampFromDateOrIso(draft.startTime),
    endTime: timestampFromDateOrIso(draft.endTime),
    timezone: draft.timezone,
    meetingPoint: draft.meetingPoint,
    meetingLocation: draft.meetingLocation,
    locationDetails: draft.locationDetails,
    photoUrl: draft.photoUrl,
    activity: draft.activity,
    price: draft.price,
    status: draft.status,
    publicationStatus:
      candidate.reviewStatus === "approved_for_import" ? "public" : "draft",
    booking: draft.booking,
    discovery: draft.discovery,
    dedupe: draft.dedupe,
    externalSource: draft.externalSource,
    review: {
      eventReviewBatchId:
        candidate.reviewDecision?.eventReviewBatchId ?? null,
      reviewer: candidate.reviewDecision?.reviewer ?? null,
      decidedAt: candidate.reviewDecision?.decidedAt ?? null,
      note: candidate.reviewDecision?.note ?? null,
      importPolicyAcknowledged:
        candidate.reviewDecision?.checklist?.importPolicyAcknowledged === true,
      ownerSafeCopyReviewed:
        candidate.reviewDecision?.checklist?.ownerSafeCopyReviewed === true,
    },
    createdAt: reviewedAt,
    updatedAt: reviewedAt,
  };
}

function outboundLinksForCandidates(candidates) {
  const links = [];
  const seen = new Set();
  for (const candidate of candidates) {
    for (const link of outboundLinksForCandidate(candidate)) {
      const key = `${link.platform}:${link.url}`;
      if (seen.has(key)) continue;
      seen.add(key);
      links.push(link);
    }
  }
  return links.sort((left, right) =>
    Number(right.primary) - Number(left.primary) ||
      left.platform.localeCompare(right.platform) ||
      left.url.localeCompare(right.url)
  );
}

function outboundLinksForCandidate(candidate) {
  const urls = [
    {
      url: candidate.eventUrl,
      linkType: "booking_or_event_page",
      primary: true,
    },
    {
      url: candidate.sourceUrl,
      linkType: "source_surface",
      primary: false,
    },
  ];
  return urls
    .filter((entry) => isHttpUrl(entry.url))
    .map((entry) => ({
      platform: candidate.platform,
      url: entry.url,
      linkType: entry.linkType,
      sourceEventKey: candidate.sourceEventKey,
      candidateId: candidate.candidateId,
      primary: entry.primary,
    }));
}

function compareCandidates(left, right) {
  return String(left.startAt ?? "").localeCompare(String(right.startAt ?? "")) ||
    String(left.candidateId ?? "").localeCompare(String(right.candidateId ?? ""));
}

function eventIdForCandidate(candidate) {
  const start = String(candidate.startAt ?? "")
    .replace(/[^0-9]/g, "")
    .slice(0, 12) || "undated";
  const slug = slugify([
    "ext",
    candidate.entityId,
    start,
    candidate.title,
  ].join("-"));
  const hash = crypto
    .createHash("sha256")
    .update(candidate.candidateId)
    .digest("hex")
    .slice(0, 10);
  const base = `${slug}-${hash}`;
  if (base.length <= 180) return base;
  return `${base.slice(0, 169).replace(/-+$/g, "")}-${hash}`;
}

function activityKindForCandidate(candidate) {
  const text = `${candidate.title ?? ""} ${candidate.description ?? ""}`
    .toLowerCase();
  if (/\brun|running|runners?\b/.test(text)) return "socialRun";
  if (/\bdinner|supper\b/.test(text)) return "dinner";
  if (/\bquiz|trivia\b/.test(text)) return "pubQuiz";
  if (/\byoga\b/.test(text)) return "yoga";
  if (/\bpadel\b/.test(text)) return "padel";
  if (/\bpickleball\b/.test(text)) return "pickleball";
  if (/\btennis\b/.test(text)) return "tennis";
  if (/\bcycling|cycle\b/.test(text)) return "cycling";
  return "openActivity";
}

function hasExactCoordinates(candidate) {
  return typeof candidate.location?.latitude === "number" &&
    typeof candidate.location?.longitude === "number";
}

function numericOrNull(value) {
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

function timestampFromDateOrIso(value) {
  if (typeof value !== "string" || value.trim() === "") return null;
  const normalized = /^\d{4}-\d{2}-\d{2}$/.test(value) ?
    `${value}T00:00:00.000Z` :
    value;
  const millis = Date.parse(normalized);
  if (!Number.isFinite(millis)) return null;
  const seconds = Math.floor(millis / 1000);
  const nanoseconds = Math.floor((millis - seconds * 1000) * 1000000);
  return {_seconds: seconds, _nanoseconds: nanoseconds};
}

function isHttpUrl(value) {
  if (typeof value !== "string" || value.trim() === "") return false;
  try {
    const url = new URL(value);
    return url.protocol === "http:" || url.protocol === "https:";
  } catch {
    return false;
  }
}

function priceInPaiseFromText(priceText) {
  if (priceText == null || String(priceText).trim() === "") return null;
  const normalized = String(priceText).trim().toLowerCase();
  if (/\bfree\b/.test(normalized)) return 0;
  const amount = normalized.match(/(?:inr|rs\.?|₹)?\s*([0-9]+(?:\.[0-9]{1,2})?)/);
  if (!amount) return null;
  const value = Number(amount[1]);
  if (!Number.isFinite(value)) return null;
  return Math.round(value * 100);
}

function currencyFromPriceText(priceText) {
  if (priceText == null) return null;
  const normalized = String(priceText).toLowerCase();
  if (normalized.includes("inr") || normalized.includes("₹") ||
    normalized.includes("rs")) {
    return "INR";
  }
  return null;
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

function slugify(value) {
  return String(value ?? "event")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 150) || "event";
}
