import crypto from "node:crypto";

const defaultPolicy = {
  status: "disabled",
  providerLookupEnabled: false,
  provider: "googlePlaces",
  reason:
    "External event location resolution is queue-only. No Places API, " +
    "geocoding provider, Firestore write, or event import mutation is enabled.",
};

export function buildExternalEventLocationResolutionQueue(
  candidateQueue,
  options = {}
) {
  const policy = {
    ...defaultPolicy,
    ...(options.policy ?? {}),
    providerLookupEnabled: options.providerLookupEnabled === true,
  };
  const candidates = candidateQueue.candidates ?? [];
  const tasks = candidates
    .filter((candidate) => needsLocationResolution(candidate))
    .sort(compareCandidates)
    .map((candidate) => locationResolutionTask(candidate, policy));

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
      candidates: candidates.length,
      tasks: tasks.length,
      missingExactCoordinates: tasks.filter((task) =>
        task.blockers.includes("missing_exact_coordinates")).length,
      missingLocationText: tasks.filter((task) =>
        task.blockers.includes("missing_location_text")).length,
      providerDisabled: tasks.filter((task) =>
        task.blockers.includes("location_resolution_provider_disabled")).length,
      tasksByPlatform: countBy(tasks, "platform"),
      tasksByCountry: countBy(tasks, "countryCode"),
    },
    guardrails: [
      "location_resolution_queue_never_calls_external_providers",
      "exact_coordinates_required_before_event_import_write",
      "admin_or_provider_resolution_must_preserve_source_location_text",
      "resolved_coordinates_must_be_revalidated_before_read_only_event_import",
    ],
    tasks,
    commands: {
      ingest:
        "node tool/organizer_intake/ingest_event_sources.mjs",
      planLocations:
        "node tool/organizer_intake/plan_event_location_resolution.mjs",
      resolveLocation:
        "node tool/organizer_intake/event_location_resolution.mjs list",
      planImports:
        "node tool/organizer_intake/plan_external_event_imports.mjs",
    },
  };
}

function locationResolutionTask(candidate, policy) {
  const blockers = blockersForCandidate(candidate, policy);
  return {
    taskId: taskIdForCandidate(candidate),
    candidateId: candidate.candidateId,
    entityId: candidate.entityId,
    platform: candidate.platform,
    sourceEventKey: candidate.sourceEventKey,
    eventUrl: candidate.eventUrl ?? null,
    sourceUrl: candidate.sourceUrl ?? null,
    title: candidate.title,
    startAt: candidate.startAt,
    citySlug: candidate.location?.citySlug ?? null,
    countryCode: candidate.location?.countryCode ?? "unknown",
    sourceLocation: {
      name: candidate.location?.name ?? null,
      address: candidate.location?.address ?? null,
      latitude: numericOrNull(candidate.location?.latitude),
      longitude: numericOrNull(candidate.location?.longitude),
      placeId: candidate.location?.placeId ?? null,
    },
    locationResolution: candidate.locationResolution ?? null,
    resolutionQuery: resolutionQueryForCandidate(candidate),
    resolutionState: blockers.length === 0 ? "ready_for_lookup" : "blocked",
    blockers,
    expectedOutput: {
      name: "string",
      address: "string_or_null",
      placeId: "string_or_null",
      latitude: "number",
      longitude: "number",
      reviewedBy: "admin_or_provider",
    },
  };
}

function blockersForCandidate(candidate, policy) {
  const blockers = new Set();
  if (policy.providerLookupEnabled !== true) {
    blockers.add("location_resolution_provider_disabled");
  }
  if (!locationTextForCandidate(candidate)) {
    blockers.add("missing_location_text");
  }
  if (!hasExactCoordinates(candidate)) {
    blockers.add("missing_exact_coordinates");
  }
  return [...blockers].sort();
}

function needsLocationResolution(candidate) {
  return !hasExactCoordinates(candidate);
}

function hasExactCoordinates(candidate) {
  return typeof candidate.location?.latitude === "number" &&
    typeof candidate.location?.longitude === "number";
}

function resolutionQueryForCandidate(candidate) {
  const pieces = [
    locationTextForCandidate(candidate),
    candidate.location?.citySlug,
    candidate.location?.countryCode,
  ].filter(Boolean);
  return pieces.join(", ");
}

function locationTextForCandidate(candidate) {
  return [
    candidate.location?.name,
    candidate.location?.address,
  ].filter(Boolean).join(", ") || null;
}

function taskIdForCandidate(candidate) {
  const slug = String(candidate.candidateId ?? "candidate")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 120) || "candidate";
  const hash = crypto
    .createHash("sha256")
    .update(String(candidate.candidateId ?? "candidate"))
    .digest("hex")
    .slice(0, 10);
  return `loc-${slug}-${hash}`;
}

function compareCandidates(left, right) {
  return String(left.startAt ?? "").localeCompare(String(right.startAt ?? "")) ||
    String(left.candidateId ?? "").localeCompare(String(right.candidateId ?? ""));
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

function numericOrNull(value) {
  return typeof value === "number" ? value : null;
}
