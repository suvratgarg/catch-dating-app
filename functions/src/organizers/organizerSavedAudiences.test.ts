import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import type {
  OrganizerCommunicationPreferenceDocument,
  OrganizerContactDocument,
  OrganizerContactTraitDocument,
  OrganizerSavedAudienceDocument,
} from "../shared/generated/firestoreAdminTypes";
import {
  canonicalSavedAudienceDefinition,
  isReachableForOrganizerWhatsappCampaign,
  savedAudienceReachSummary,
  savedAudienceDefinitionMatches,
  SavedAudienceEvaluationRow,
} from "./organizerSavedAudiences";

const now = admin.firestore.Timestamp.fromMillis(
  Date.UTC(2026, 7, 30, 12),
);

function row(): SavedAudienceEvaluationRow {
  return {
    contactId: "contact-1",
    contact: {
      organizerId: "organizer-1",
      displayName: "Maya",
      displayNameOverride: null,
      linkedUid: "user-1",
      phoneE164: "+919876543210",
      manualTagIds: ["a".repeat(32)],
      identityState: "verified",
      identityConfidence: "verified",
      ambiguousCandidateContactIds: [],
      whatsappStatus: "optedIn",
      deletedAt: null,
      hiddenAt: null,
    } as unknown as OrganizerContactDocument,
    trait: {
      organizerId: "organizer-1",
      attendedEventCount: 4,
      lastSeenAt: admin.firestore.Timestamp.fromMillis(
        now.toMillis() - 5 * 24 * 60 * 60 * 1000,
      ),
      segmentIds: ["repeat_attendee", "regular"],
    } as OrganizerContactTraitDocument,
    preference: {
      organizerId: "organizer-1",
      uid: "user-1",
      whatsapp: {
        status: "optedIn",
        evidenceStatus: "complete",
        currentReceiptId: "receipt-1",
      },
    } as OrganizerCommunicationPreferenceDocument,
    channelState: null,
  };
}

test("saved audiences combine only reviewed typed predicates", () => {
  const definition: OrganizerSavedAudienceDocument["definition"] = {
    join: "all",
    predicates: [
      {kind: "computedSegment", segmentId: "regular"},
      {kind: "manualTag", manualTagId: "a".repeat(32)},
      {kind: "attendanceCount", operator: "atLeast", eventCount: 3},
      {kind: "lastSeenWithinDays", days: 30},
      {
        kind: "reachableForIntent",
        intent: "organizerWhatsappCampaign",
      },
    ],
  };
  assert.equal(savedAudienceDefinitionMatches(row(), definition, now), true);
  assert.equal(
    savedAudienceDefinitionMatches(row(), {
      ...definition,
      predicates: [
        ...definition.predicates,
        {kind: "attendanceCount", operator: "atMost", eventCount: 2},
      ],
    }, now),
    false,
  );
});

test("any audiences match one predicate without weakening its type", () => {
  assert.equal(savedAudienceDefinitionMatches(row(), {
    join: "any",
    predicates: [
      {kind: "computedSegment", segmentId: "advocate"},
      {kind: "attendanceCount", operator: "atLeast", eventCount: 4},
    ],
  }, now), true);
});

test(
  "named-intent reach fails closed on incomplete evidence or suppression",
  () => {
    const candidate = row();
    assert.equal(isReachableForOrganizerWhatsappCampaign(candidate), true);
    candidate.preference!.whatsapp.evidenceStatus = "incomplete";
    assert.equal(isReachableForOrganizerWhatsappCampaign(candidate), false);
    candidate.preference!.whatsapp.evidenceStatus = "complete";
    candidate.channelState = {
      suppressionStatus: "adminSuppressed",
      adminSuppressed: true,
    } as SavedAudienceEvaluationRow["channelState"];
    assert.equal(isReachableForOrganizerWhatsappCampaign(candidate), false);
  },
);

test("canonical definitions reject duplicate predicates", () => {
  assert.throws(
    () => canonicalSavedAudienceDefinition({
      join: "all",
      predicates: [
        {kind: "computedSegment", segmentId: "regular"},
        {kind: "computedSegment", segmentId: "regular"},
      ],
    }),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "invalid-argument",
  );
});

test("saved audience reach summaries reuse the shared route plan", () => {
  const inCatch = row();
  const byHand = row();
  byHand.contact = {
    ...byHand.contact,
    linkedUid: null,
    identityState: "unlinked",
    identityConfidence: "proposed",
  };
  const unavailable = row();
  unavailable.contact = {
    ...unavailable.contact,
    linkedUid: null,
    phoneE164: null,
    identityState: "unlinked",
    identityConfidence: "proposed",
  };
  assert.deepEqual(savedAudienceReachSummary([inCatch, byHand, unavailable]), {
    inCatch: 1,
    automatic: 0,
    byHand: 1,
    unavailable: 1,
  });
});
