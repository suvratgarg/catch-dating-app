import assert from "node:assert/strict";
import test from "node:test";
import {buildExternalEventImportExecutionPlan} from
  "./lib/event_import_execution_core.mjs";

test("execution preflight skips non-create import actions", () => {
  const plan = buildExternalEventImportExecutionPlan(importPlanWithAction({
    action: "skip",
    status: "waiting_review",
    blockers: ["requires_admin_review"],
  }));

  assert.equal(plan.summary.skipped, 1);
  assert.equal(plan.summary.createActions, 0);
  assert.equal(plan.actions[0].status, "skipped");
  assert.ok(plan.actions[0].blockers.includes("requires_admin_review"));
  assert.ok(plan.actions[0].blockers.includes(
    "not_a_read_only_external_event_action"
  ));
});

test("execution preflight reports invalid read-only projections", () => {
  const plan = buildExternalEventImportExecutionPlan(importPlanWithAction({
    action: "publish_read_only_external_event",
    status: "blocked",
    blockers: ["global_external_event_import_disabled"],
  }));

  assert.equal(plan.summary.projectionInvalid, 1);
  assert.equal(plan.summary.projectionInvalidCount, 1);
  assert.equal(plan.summary.payloadInvalid, 0);
  assert.equal(plan.actions[0].status, "projection_invalid");
  assert.ok(plan.actions[0].blockers.includes(
    "read_only_external_event_projection_invalid"
  ));
  assert.ok(plan.actions[0].projectionValidation.errors.some((error) =>
    error.path === "/booking/externalLinks"));
});

test("execution preflight blocks valid payloads while execution is disabled", () => {
  const plan = buildExternalEventImportExecutionPlan(importPlanWithAction({
    action: "publish_read_only_external_event",
    status: "write_ready",
    blockers: [],
    proposedReadOnlyEventDraft: validReadOnlyDraft(),
    proposedExternalEventDocument: validExternalEventDocument(),
  }));

  assert.equal(plan.summary.projectionValid, 1);
  assert.equal(plan.summary.blocked, 1);
  assert.equal(plan.actions[0].status, "blocked");
  assert.ok(plan.actions[0].blockers.includes(
    "external_event_import_execution_disabled"
  ));
  assert.ok(plan.actions[0].blockers.includes(
    "requires_import_authority_policy"
  ));
});

test("execution preflight can model a would-publish action for future policy", () => {
  const plan = buildExternalEventImportExecutionPlan(importPlanWithAction({
    action: "publish_read_only_external_event",
    status: "write_ready",
    blockers: [],
    proposedReadOnlyEventDraft: validReadOnlyDraft(),
    proposedExternalEventDocument: validExternalEventDocument(),
  }), {
    writeEnabled: true,
    policy: {
      status: "approved_for_test",
      authorityModel: "admin_import_service",
      reason: "Unit test only.",
    },
  });

  assert.equal(plan.summary.wouldCreate, 0);
  assert.equal(plan.summary.wouldPublishReadOnly, 1);
  assert.equal(plan.actions[0].status, "would_publish_read_only");
  assert.equal(plan.actions[0].projectionValidation.valid, true);
  assert.equal(plan.actions[0].targetCallable, null);
  assert.equal(
    plan.actions[0].readOnlyEventProjection.canonicalHostId,
    "afterfly"
  );
  assert.equal(
    plan.actions[0].readOnlyEventProjection.booking.catchBookingEnabled,
    false
  );
  assert.equal(
    plan.actions[0].externalEventDocument.booking.catchBookingEnabled,
    false
  );
});

function importPlanWithAction(overrides) {
  return {
    schemaVersion: 1,
    generatedFrom: {
      externalEventCandidateQueue:
        "tool/organizer_intake/generated/external_event_candidate_queue.json",
      batches: ["2026-06-17-afterfly-luma-events"],
      reviewDecisionBatches: [],
    },
    policy: {
      status: "disabled",
      writeEnabled: false,
      reason: "Fixture import plan.",
    },
    summary: {},
    guardrails: [],
    actions: [
      {
        actionId: "import-ext-afterfly-202503151800-takeoff-run-rave-e99b5e2138",
        action: "publish_read_only_external_event",
        status: "blocked",
        candidateId: "2026-06-17-afterfly-luma-events:pxgmph3b",
        entityId: "afterfly",
        platform: "luma",
        sourceEventKey: "luma:event:pxgmph3b",
        normalizedEventKey:
          "afterfly:2025-03-15T18:00:00+05:30:takeoff-run-rave",
        targetPath:
          "externalEvents/ext-afterfly-202503151800-takeoff-run-rave-e99b5e2138",
        reviewStatus: "approved_for_import",
        importState: "blocked_by_policy",
        blockers: ["global_external_event_import_disabled"],
        duplicateCandidateIds: [],
        source: {
          eventUrl: "https://luma.com/pxgmph3b",
          sourceUrl: "https://luma.com/pxgmph3b",
          sourceStatus: "scheduled",
          batchId: "2026-06-17-afterfly-luma-events",
          surfaceId: "afterfly-luma-takeoff-run-rave",
        },
        proposedReadOnlyEventDraft: invalidReadOnlyDraft(),
        proposedExternalEventDocument: invalidExternalEventDocument(),
        ...overrides,
      },
    ],
    commands: {},
  };
}

function invalidReadOnlyDraft() {
  return {
    ...validReadOnlyDraft(),
    booking: {
      ...validReadOnlyDraft().booking,
      externalLinks: [],
    },
  };
}

function invalidExternalEventDocument() {
  return {
    ...validExternalEventDocument(),
    booking: {
      ...validExternalEventDocument().booking,
      externalLinks: [],
    },
  };
}

function validReadOnlyDraft() {
  return {
    eventId: "ext-afterfly-202503151800-takeoff-run-rave-e99b5e2138",
    canonicalHostId: "afterfly",
    compatibilityClubId: "afterfly",
    title: "Takeoff: Run + Rave",
    description: "Reviewed event.",
    startTime: "2025-03-15T18:00:00+05:30",
    endTime: "2025-03-15T21:00:00+05:30",
    timezone: "Asia/Kolkata",
    meetingPoint: "Nehru Stadium",
    meetingLocation: {
      name: "Nehru Stadium",
      latitude: 22.7161,
      longitude: 75.8552,
      placeId: "test-place-id",
      address: "Nehru Stadium, Indore, Madhya Pradesh, IN",
      notes: "Fixture location.",
    },
    startingPointLat: 22.7161,
    startingPointLng: 75.8552,
    locationDetails: "Nehru Stadium, Indore, Madhya Pradesh, IN",
    photoUrl: "https://images.lumacdn.com/event-afterfly.jpg",
    activity: {
      version: 1,
      activityKind: "socialRun",
      interactionModel: "openFormat",
      source: "heuristic",
    },
    distanceKm: 5,
    pace: "moderate",
    capacityLimit: 80,
    price: {
      displayText: "0 INR",
      parsedPriceInPaise: 0,
      currency: "INR",
    },
    status: "active",
    booking: {
      mode: "external_outbound_only",
      catchBookingEnabled: false,
      catchPaymentsEnabled: false,
      catchReservationsEnabled: false,
      catchWaitlistEnabled: false,
      externalLinks: [
        {
          platform: "luma",
          url: "https://luma.com/pxgmph3b",
          linkType: "booking_or_event_page",
          sourceEventKey: "luma:event:pxgmph3b",
          candidateId: "2026-06-17-afterfly-luma-events:pxgmph3b",
          primary: true,
        },
      ],
    },
    discovery: {
      citySlug: "indore",
      countryCode: "IN",
      availability: "read_only_external",
      manualApprovalRequired: true,
    },
    dedupe: {
      normalizedEventKey:
        "afterfly:2025-03-15T18:00:00+05:30:takeoff-run-rave",
      primaryCandidateId: "2026-06-17-afterfly-luma-events:pxgmph3b",
      duplicateCandidateIds: [],
      conflictPolicy: "single_read_only_event_with_multiple_outbound_links",
    },
  };
}

function validExternalEventDocument() {
  return {
    schemaVersion: 1,
    eventId: "ext-afterfly-202503151800-takeoff-run-rave-e99b5e2138",
    canonicalHostId: "afterfly",
    compatibilityClubId: "afterfly",
    title: "Takeoff: Run + Rave",
    description: "Reviewed event.",
    startTime: {_seconds: 1742041800, _nanoseconds: 0},
    endTime: {_seconds: 1742052600, _nanoseconds: 0},
    timezone: "Asia/Kolkata",
    meetingPoint: "Nehru Stadium",
    meetingLocation: {
      name: "Nehru Stadium",
      latitude: 22.7161,
      longitude: 75.8552,
      placeId: "test-place-id",
      address: "Nehru Stadium, Indore, Madhya Pradesh, IN",
      notes: "Fixture location.",
    },
    locationDetails: "Nehru Stadium, Indore, Madhya Pradesh, IN",
    photoUrl: "https://images.lumacdn.com/event-afterfly.jpg",
    activity: {
      version: 1,
      activityKind: "socialRun",
      interactionModel: "openFormat",
      source: "heuristic",
    },
    price: {
      displayText: "0 INR",
      parsedPriceInPaise: 0,
      currency: "INR",
    },
    status: "active",
    publicationStatus: "public",
    booking: validReadOnlyDraft().booking,
    discovery: validReadOnlyDraft().discovery,
    dedupe: validReadOnlyDraft().dedupe,
    externalSource: {
      candidateId: "2026-06-17-afterfly-luma-events:pxgmph3b",
      sourceEventKey: "luma:event:pxgmph3b",
      sourceEventId: "pxgmph3b",
      platform: "luma",
      eventUrl: "https://luma.com/pxgmph3b",
      sourceUrl: "https://luma.com/pxgmph3b",
    },
    review: {
      eventReviewBatchId: "firestore-fixture-2026-06-17",
      reviewer: "admin",
      decidedAt: "2026-06-17",
      note: "Manual event QA complete.",
      importPolicyAcknowledged: true,
      ownerSafeCopyReviewed: true,
    },
    createdAt: {_seconds: 1781654400, _nanoseconds: 0},
    updatedAt: {_seconds: 1781654400, _nanoseconds: 0},
  };
}
