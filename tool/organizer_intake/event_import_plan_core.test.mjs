import assert from "node:assert/strict";
import test from "node:test";
import {buildExternalEventImportPlan} from
  "./lib/event_import_plan_core.mjs";

test("buildExternalEventImportPlan keeps unreviewed candidates waiting", () => {
  const plan = buildExternalEventImportPlan(sampleQueue({
    reviewStatus: "needs_admin_review",
    reviewDecision: null,
    importState: "not_reviewed",
    blockers: [
      "global_external_event_import_disabled",
      "requires_admin_review",
      "requires_event_dedupe_review",
    ],
  }));

  assert.equal(plan.summary.waitingReview, 1);
  assert.equal(plan.summary.proposedCreates, 0);
  assert.equal(plan.summary.proposedReadOnlyEvents, 0);
  assert.equal(plan.actions[0].status, "waiting_review");
  assert.equal(plan.actions[0].action, "skip");
  assert.ok(plan.actions[0].blockers.includes("requires_admin_review"));
});

test("buildExternalEventImportPlan blocks approved candidates by policy", () => {
  const plan = buildExternalEventImportPlan(sampleQueue({
    reviewStatus: "approved_for_import",
    reviewDecision: {
      checklist: {
        dedupeReviewed: true,
        identityReviewed: true,
        importPolicyAcknowledged: true,
        locationReviewed: true,
        ownerSafeCopyReviewed: true,
        sourceEventReviewed: true,
        timeReviewed: true,
      },
      decidedAt: "2026-06-17",
      decision: "approve_for_import",
      eventReviewBatchId: "firestore-fixture-2026-06-17",
      note: "Manual event QA complete.",
      reviewer: "admin",
    },
    importState: "blocked_by_policy",
    blockers: ["global_external_event_import_disabled"],
  }));

  assert.equal(plan.summary.proposedCreates, 0);
  assert.equal(plan.summary.proposedReadOnlyEvents, 1);
  assert.equal(plan.summary.blocked, 1);
  assert.equal(plan.actions[0].action, "publish_read_only_external_event");
  assert.equal(plan.actions[0].status, "blocked");
  assert.equal(
    plan.actions[0].proposedReadOnlyEventDraft.canonicalHostId,
    "afterfly"
  );
  assert.equal(
    plan.actions[0].proposedReadOnlyEventDraft.price.parsedPriceInPaise,
    0
  );
  assert.equal(
    plan.actions[0].proposedReadOnlyEventDraft.activity.activityKind,
    "socialRun"
  );
  assert.equal(
    plan.actions[0].proposedReadOnlyEventDraft.meetingLocation.latitude,
    null
  );
  assert.equal(
    plan.actions[0].proposedReadOnlyEventDraft.booking.catchBookingEnabled,
    false
  );
  assert.equal(
    plan.actions[0].proposedReadOnlyEventDraft.booking.externalLinks[0].url,
    "https://luma.com/pxgmph3b"
  );
  assert.equal(
    plan.actions[0].targetPath,
    "externalEvents/ext-afterfly-202503151800-takeoff-run-rave-e99b5e2138"
  );
  assert.equal(
    plan.actions[0].proposedExternalEventDocument.booking.catchBookingEnabled,
    false
  );
  assert.equal(
    plan.actions[0].proposedExternalEventDocument.publicationStatus,
    "public"
  );
  assert.deepEqual(
    plan.actions[0].proposedExternalEventDocument.startTime,
    {_seconds: 1742041800, _nanoseconds: 0}
  );
  assert.ok(plan.actions[0].blockers.includes("global_external_event_import_disabled"));
  assert.ok(plan.actions[0].blockers.includes("missing_exact_coordinates"));
  assert.ok(plan.actions[0].blockers.includes("requires_event_defaults_policy"));
});

test("buildExternalEventImportPlan carries resolved coordinates", () => {
  const plan = buildExternalEventImportPlan(sampleQueue({
    reviewStatus: "approved_for_import",
    reviewDecision: approvedReviewDecision(),
    importState: "blocked_by_policy",
    blockers: ["global_external_event_import_disabled"],
    location: {
      address: "Nehru Stadium, Indore, Madhya Pradesh",
      citySlug: "indore",
      countryCode: "IN",
      latitude: 22.7196,
      longitude: 75.8577,
      name: "Nehru Stadium",
      notes: "Matched to source listing and map result.",
      placeId: "ChIJ-afterfly-indore",
    },
    locationResolution: {
      locationResolutionBatchId: "2026-06-17-afterfly-location-resolution",
      resolvedAt: "2026-06-17",
      reviewer: "admin",
      note: "Manual location QA complete.",
      checklist: {
        sourceLocationReviewed: true,
        coordinatesReviewed: true,
        placeIdentityReviewed: true,
        importSafetyReviewed: true,
      },
    },
  }));

  assert.equal(
    plan.actions[0].proposedReadOnlyEventDraft.meetingPoint,
    "Nehru Stadium"
  );
  assert.equal(
    plan.actions[0].proposedReadOnlyEventDraft.meetingLocation.latitude,
    22.7196
  );
  assert.equal(
    plan.actions[0].proposedReadOnlyEventDraft.meetingLocation.longitude,
    75.8577
  );
  assert.equal(
    plan.actions[0].proposedReadOnlyEventDraft.startingPointLat,
    22.7196
  );
  assert.equal(
    plan.actions[0].proposedReadOnlyEventDraft.startingPointLng,
    75.8577
  );
  assert.equal(
    plan.actions[0].proposedReadOnlyEventDraft.meetingLocation.placeId,
    "ChIJ-afterfly-indore"
  );
  assert.equal(
    plan.actions[0].proposedExternalEventDocument.meetingLocation.latitude,
    22.7196
  );
  assert.equal(
    plan.actions[0].blockers.includes("missing_exact_coordinates"),
    false
  );
});

test("buildExternalEventImportPlan merges duplicate platform links", () => {
  const queue = sampleQueue({
    reviewStatus: "approved_for_import",
    reviewDecision: {
      checklist: {
        dedupeReviewed: true,
        identityReviewed: true,
        importPolicyAcknowledged: true,
        locationReviewed: true,
        ownerSafeCopyReviewed: true,
        sourceEventReviewed: true,
        timeReviewed: true,
      },
      decidedAt: "2026-06-17",
      decision: "approve_for_import",
      eventReviewBatchId: "fixture",
      note: "Manual event QA complete.",
      reviewer: "admin",
    },
    importState: "blocked_by_policy",
    blockers: ["global_external_event_import_disabled"],
  });
  queue.duplicateEventKeys = [{
    normalizedEventKey: queue.candidates[0].normalizedEventKey,
    candidateIds: [
      queue.candidates[0].candidateId,
      "2026-06-17-afterfly-luma-events:pxgmph3b-copy",
    ],
  }];
  queue.summary.duplicateEventKeys = 1;

  const plan = buildExternalEventImportPlan(queue);

  assert.equal(plan.summary.proposedReadOnlyEvents, 1);
  assert.equal(plan.summary.mergedSourceLinks, 0);
  assert.equal(
    plan.actions[0].blockers.includes("duplicate_normalized_event_key"),
    false
  );
  assert.deepEqual(plan.actions[0].duplicateCandidateIds, [
    "2026-06-17-afterfly-luma-events:pxgmph3b-copy",
  ]);
  assert.equal(
    plan.actions[0].proposedReadOnlyEventDraft.dedupe.conflictPolicy,
    "single_read_only_event_with_multiple_outbound_links"
  );
  assert.equal(
    plan.actions[0].proposedExternalEventDocument.dedupe.conflictPolicy,
    "single_read_only_event_with_multiple_outbound_links"
  );
  assert.equal(
    plan.actions[0].proposedReadOnlyEventDraft.booking.externalLinks.length,
    1
  );
});

test("buildExternalEventImportPlan keeps duplicate sources as non-event actions", () => {
  const queue = sampleQueue({
    reviewStatus: "approved_for_import",
    reviewDecision: approvedReviewDecision(),
    importState: "blocked_by_policy",
    blockers: ["global_external_event_import_disabled"],
  });
  queue.candidates.push({
    ...queue.candidates[0],
    candidateId: "2026-06-17-afterfly-partiful-events:run-rave",
    batchId: "2026-06-17-afterfly-partiful-events",
    platform: "partiful",
    sourceEventId: "run-rave",
    sourceEventKey: "partiful:event:run-rave",
    sourceUrl: "https://partiful.com/e/run-rave",
    eventUrl: "https://partiful.com/e/run-rave",
  });
  queue.duplicateEventKeys = [{
    normalizedEventKey: queue.candidates[0].normalizedEventKey,
    candidateIds: [
      queue.candidates[0].candidateId,
      queue.candidates[1].candidateId,
    ],
  }];
  queue.summary.duplicateEventKeys = 1;

  const plan = buildExternalEventImportPlan(queue);
  const canonical = plan.actions.find((action) =>
    action.duplicateRole === "canonical"
  );
  const merged = plan.actions.find((action) =>
    action.duplicateRole === "merged_source"
  );

  assert.equal(plan.summary.proposedReadOnlyEvents, 1);
  assert.equal(plan.summary.mergedSourceLinks, 1);
  assert.equal(canonical.action, "publish_read_only_external_event");
  assert.equal(merged.action, "merge_duplicate_source_link");
  assert.equal(merged.status, "merged_duplicate");
  assert.deepEqual(
    canonical.proposedReadOnlyEventDraft.booking.externalLinks.map((link) =>
      link.platform
    ),
    ["luma", "partiful"]
  );
  assert.deepEqual(
    canonical.proposedExternalEventDocument.booking.externalLinks.map((link) =>
      link.platform
    ),
    ["luma", "partiful"]
  );
});

function sampleQueue(overrides) {
  return {
    schemaVersion: 1,
    generatedFrom: {
      batches: ["2026-06-17-afterfly-luma-events"],
      reviewDecisionBatches: [],
    },
    summary: {
      batches: 1,
      events: 1,
      candidates: 1,
      platforms: {luma: 1},
      duplicateEventKeys: 0,
      blocked: 1,
      reviewed: overrides.reviewDecision ? 1 : 0,
      approvedForImport: overrides.reviewStatus === "approved_for_import" ? 1 : 0,
      held: overrides.reviewStatus === "held" ? 1 : 0,
      rejected: overrides.reviewStatus === "rejected" ? 1 : 0,
    },
    candidates: [
      {
        batchId: "2026-06-17-afterfly-luma-events",
        candidateId: "2026-06-17-afterfly-luma-events:pxgmph3b",
        description: "Reviewed event.",
        diagnostics: [],
        endAt: "2025-03-15T21:00:00+05:30",
        entityId: "afterfly",
        eventUrl: "https://luma.com/pxgmph3b",
        imageUrl: "https://images.lumacdn.com/event-afterfly.jpg",
        location: {
          address: "Indore, Madhya Pradesh, IN",
          citySlug: "indore",
          countryCode: "IN",
          name: "Indore",
        },
        normalizedEventKey:
          "afterfly:2025-03-15T18:00:00+05:30:takeoff-run-rave",
        platform: "luma",
        priceText: "0 INR",
        reviewAction: "review_external_event_candidate",
        sourceEventId: "pxgmph3b",
        sourceEventKey: "luma:event:pxgmph3b",
        sourceStatus: "scheduled",
        sourceUrl: "https://luma.com/pxgmph3b",
        startAt: "2025-03-15T18:00:00+05:30",
        surfaceId: "afterfly-luma-takeoff-run-rave",
        timezone: "Asia/Kolkata",
        title: "Takeoff: Run + Rave",
        importReadiness: "blocked",
        ...overrides,
      },
    ],
    duplicateEventKeys: [],
    warnings: [],
    errors: [],
    policy: {status: "disabled", importWritesEnabled: false},
    commands: {},
  };
}

function approvedReviewDecision() {
  return {
    checklist: {
      dedupeReviewed: true,
      identityReviewed: true,
      importPolicyAcknowledged: true,
      locationReviewed: true,
      ownerSafeCopyReviewed: true,
      sourceEventReviewed: true,
      timeReviewed: true,
    },
    decidedAt: "2026-06-17",
    decision: "approve_for_import",
    eventReviewBatchId: "firestore-fixture-2026-06-17",
    note: "Manual event QA complete.",
    reviewer: "admin",
  };
}
