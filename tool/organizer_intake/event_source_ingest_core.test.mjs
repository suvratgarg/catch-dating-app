import assert from "node:assert/strict";
import test from "node:test";
import {buildExternalEventCandidateQueue} from
  "./lib/event_source_ingest_core.mjs";

test("buildExternalEventCandidateQueue blocks reviewed events by policy", () => {
  const queue = buildExternalEventCandidateQueue([sampleBatch()]);

  assert.equal(queue.summary.candidates, 1);
  assert.equal(queue.summary.blocked, 1);
  assert.equal(queue.policy.importWritesEnabled, false);
  assert.deepEqual(queue.candidates[0].blockers, [
    "global_external_event_import_disabled",
    "requires_admin_review",
    "requires_event_dedupe_review",
  ]);
  assert.equal(
    queue.candidates[0].normalizedEventKey,
    "afterfly:2025-03-15T18:00:00+05:30:takeoff-run-rave"
  );
});

test("buildExternalEventCandidateQueue reports duplicate normalized event keys", () => {
  const batch = sampleBatch();
  batch.events.push({...batch.events[0], sourceEventId: "pxgmph3b-copy"});

  const queue = buildExternalEventCandidateQueue([batch]);

  assert.equal(queue.summary.duplicateEventKeys, 1);
  assert.deepEqual(queue.duplicateEventKeys[0].candidateIds, [
    "2026-06-17-afterfly-luma-events:pxgmph3b",
    "2026-06-17-afterfly-luma-events:pxgmph3b-copy",
  ]);
});

test("buildExternalEventCandidateQueue applies event review decisions", () => {
  const queue = buildExternalEventCandidateQueue([sampleBatch()], {
    reviewDecisionBatches: [sampleReviewDecisionBatch()],
  });

  assert.equal(queue.summary.reviewed, 1);
  assert.equal(queue.summary.approvedForImport, 1);
  assert.equal(queue.summary.blocked, 1);
  assert.equal(queue.candidates[0].reviewStatus, "approved_for_import");
  assert.equal(queue.candidates[0].importState, "blocked_by_policy");
  assert.deepEqual(queue.candidates[0].blockers, [
    "global_external_event_import_disabled",
  ]);
  assert.equal(
    queue.candidates[0].reviewDecision.eventReviewBatchId,
    "2026-06-17-afterfly-event-review"
  );
});

test("buildExternalEventCandidateQueue applies location resolutions", () => {
  const queue = buildExternalEventCandidateQueue([sampleBatch()], {
    locationResolutionBatches: [sampleLocationResolutionBatch()],
  });

  assert.equal(queue.summary.locationResolved, 1);
  assert.deepEqual(queue.generatedFrom.locationResolutionBatches, [
    "2026-06-17-afterfly-location-resolution",
  ]);
  assert.equal(queue.candidates[0].location.name, "Nehru Stadium");
  assert.equal(queue.candidates[0].location.latitude, 22.7196);
  assert.equal(queue.candidates[0].location.longitude, 75.8577);
  assert.equal(queue.candidates[0].location.placeId, "ChIJ-afterfly-indore");
  assert.equal(
    queue.candidates[0].locationResolution.locationResolutionBatchId,
    "2026-06-17-afterfly-location-resolution"
  );
});

test("buildExternalEventCandidateQueue rejects unknown location resolutions", () => {
  const resolutionBatch = sampleLocationResolutionBatch();
  resolutionBatch.resolutions[0].candidateId = "unknown-candidate";

  const queue = buildExternalEventCandidateQueue([sampleBatch()], {
    locationResolutionBatches: [resolutionBatch],
  });

  assert.match(
    queue.errors.join("\n"),
    /event location resolution references unknown candidate unknown-candidate/
  );
});

test("buildExternalEventCandidateQueue rejects incomplete import approvals", () => {
  const reviewBatch = sampleReviewDecisionBatch();
  reviewBatch.decisions[0].checklist.locationReviewed = false;

  const queue = buildExternalEventCandidateQueue([sampleBatch()], {
    reviewDecisionBatches: [reviewBatch],
  });

  assert.match(
    queue.errors.join("\n"),
    /approve_for_import has an incomplete checklist/
  );
});

test("orphan events stay blocked and seed an organizer lead", () => {
  const batch = sampleBatch();
  batch.attributionState = "orphan";
  batch.entityId = null;
  batch.organizerEvidence = {
    name: "Courtside",
    url: "https://courtside.club/",
  };

  const queue = buildExternalEventCandidateQueue([batch]);
  const candidate = queue.candidates[0];

  assert.equal(queue.summary.orphanEvents, 1);
  assert.equal(queue.summary.organizerLeads, 1);
  assert.equal(candidate.entityId, null);
  assert.equal(candidate.attribution.state, "orphan");
  assert.equal(candidate.publicationEligibility, "blocked_orphan");
  assert.ok(candidate.blockers.includes("organizer_not_in_inventory"));
  assert.deepEqual(queue.organizerLeads[0], {
    leadId: "event-organizer-lead:courtside:indore:https://courtside.club/",
    recordType: "organizer_event_lead",
    organizerName: "Courtside",
    organizerUrl: "https://courtside.club/",
    marketSlug: "indore",
    sourcePlatform: "luma",
    eventCandidateIds: [
      "2026-06-17-afterfly-luma-events:pxgmph3b",
    ],
    eventUrls: ["https://luma.com/pxgmph3b"],
    observedAt: "2025-03-15T18:00:00+05:30",
    reviewAction: "create_or_match_organizer_before_event_publication",
    blocker: "organizer_not_in_inventory",
  });
});

test("orphan events auto-attribute with a reviewable scorecard", () => {
  const batch = sampleBatch();
  batch.attributionState = "orphan";
  batch.entityId = null;
  batch.organizerEvidence = {
    name: "Courtside",
    url: "https://courtside.club/",
  };

  const queue = buildExternalEventCandidateQueue([batch], {
    organizerInventory: [{
      entityId: "courtside",
      displayName: "Courtside",
      citySlug: "indore",
      surfaces: [{url: "https://courtside.club/"}],
    }],
  });
  const candidate = queue.candidates[0];

  assert.equal(queue.summary.autoAttributedEvents, 1);
  assert.equal(queue.summary.orphanEvents, 0);
  assert.equal(queue.summary.organizerLeads, 0);
  assert.equal(candidate.entityId, "courtside");
  assert.equal(candidate.attribution.state, "attributed");
  assert.equal(candidate.attribution.match.decision, "auto_attach");
  assert.equal(candidate.attribution.match.matchedEntityId, "courtside");
  assert.ok(candidate.attribution.match.score >=
    candidate.attribution.match.threshold);
  assert.ok(candidate.attribution.match.matchingSignals.includes(
    "same_canonical_url"
  ));
  assert.equal(
    candidate.blockers.includes("organizer_not_in_inventory"),
    false
  );
});

function sampleBatch() {
  return {
    schemaVersion: 1,
    batchId: "2026-06-17-afterfly-luma-events",
    createdAt: "2026-06-17",
    source: "reviewed_luma_payload",
    entityId: "afterfly",
    surfaceId: "afterfly-luma-takeoff-run-rave",
    platform: "luma",
    sourceUrl: "https://luma.com/pxgmph3b",
    timezone: "Asia/Kolkata",
    citySlug: "indore",
    countryCode: "IN",
    events: [
      {
        sourceEventId: "pxgmph3b",
        title: "Takeoff: Run + Rave",
        description: "Reviewed event.",
        startAt: "2025-03-15T18:00:00+05:30",
        endAt: "2025-03-15T21:00:00+05:30",
        timezone: "Asia/Kolkata",
        locationName: "Indore",
        address: "Indore, Madhya Pradesh, IN",
        citySlug: "indore",
        countryCode: "IN",
        eventUrl: "https://luma.com/pxgmph3b",
        imageUrl: "https://images.lumacdn.com/event-afterfly.jpg",
        priceText: "0 INR",
        status: "scheduled",
      },
    ],
  };
}

function sampleLocationResolutionBatch() {
  return {
    schemaVersion: 1,
    locationResolutionBatchId: "2026-06-17-afterfly-location-resolution",
    resolvedAt: "2026-06-17",
    reviewer: "admin@example.com",
    resolutions: [
      {
        candidateId: "2026-06-17-afterfly-luma-events:pxgmph3b",
        location: {
          name: "Nehru Stadium",
          address: "Nehru Stadium, Indore, Madhya Pradesh",
          placeId: "ChIJ-afterfly-indore",
          latitude: 22.7196,
          longitude: 75.8577,
          notes: "Matched to source listing and map result.",
        },
        checklist: {
          sourceLocationReviewed: true,
          coordinatesReviewed: true,
          placeIdentityReviewed: true,
          importSafetyReviewed: true,
        },
        note: "Manual location QA complete.",
      },
    ],
  };
}

function sampleReviewDecisionBatch() {
  return {
    schemaVersion: 1,
    eventReviewBatchId: "2026-06-17-afterfly-event-review",
    decidedAt: "2026-06-17",
    reviewer: "admin@example.com",
    decisions: [
      {
        candidateId: "2026-06-17-afterfly-luma-events:pxgmph3b",
        decision: "approve_for_import",
        checklist: {
          identityReviewed: true,
          sourceEventReviewed: true,
          timeReviewed: true,
          locationReviewed: true,
          dedupeReviewed: true,
          ownerSafeCopyReviewed: true,
          importPolicyAcknowledged: true,
        },
        note: "Reviewed for future import.",
      },
    ],
  };
}
