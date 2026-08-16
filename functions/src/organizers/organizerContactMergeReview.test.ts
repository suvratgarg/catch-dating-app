import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {
  OrganizerContactIdentityClaimDocument,
  OrganizerContactIdentityLinkDocument,
} from
  "../shared/generated/firestoreAdminTypes";
import {
  nextMergeReviewDecision,
  organizerContactMergeCandidateId,
  proposedCandidateSeeds,
  verifiedCandidateSeeds,
} from "./organizerContactMergeReview";

test("verified candidates come from conflicted UID and phone claims", () => {
  const seeds = verifiedCandidateSeeds("organizer-1", [
    claim("uid", "hash-uid", ["contact-2"], 2_000),
    claim("phone", "hash-phone", ["contact-2"], 3_000),
    claim("phone", "ignored-resolved", [], 4_000, "verified"),
    claim("phone", "ignored-organizer", ["contact-3"], 5_000,
      "conflicted", "organizer-2"),
  ]);

  assert.equal(seeds.length, 1);
  assert.deepEqual(seeds[0].contactIds, ["contact-1", "contact-2"]);
  assert.deepEqual([...seeds[0].matchKinds].sort(), [
    "sameVerifiedPhone",
    "sameVerifiedUid",
  ]);
  assert.deepEqual([...seeds[0].identityHashes].sort(), [
    "hash-phone",
    "hash-uid",
  ]);
  assert.equal(seeds[0].updatedAtMillis, 3_000);
});

test("verified candidates never infer a duplicate from a matching name", () => {
  assert.deepEqual(verifiedCandidateSeeds("organizer-1", []), []);
});

test("proposed candidates require an exact phone or email hash", () => {
  const seeds = proposedCandidateSeeds("organizer-1", [
    link("phone", "hash-phone", "contact-1", 1_000),
    link("phone", "hash-phone", "contact-2", 2_000),
    link("email", "hash-email", "contact-1", 3_000),
    link("email", "hash-email", "contact-2", 4_000),
    link("provider", "hash-provider", "contact-1", 5_000),
    link("provider", "hash-provider", "contact-2", 6_000),
  ]);

  assert.equal(seeds.length, 1);
  assert.deepEqual([...seeds[0].matchKinds].sort(), [
    "sameEmail",
    "sameImportedPhone",
  ]);
  assert.equal(seeds[0].confidence, "proposed");
  assert.equal(seeds[0].updatedAtMillis, 4_000);
});

test("candidate ids are stable regardless of contact order", () => {
  assert.equal(
    organizerContactMergeCandidateId(
      "organizer-1",
      ["contact-1", "contact-2"]
    ),
    organizerContactMergeCandidateId(
      "organizer-1",
      ["contact-2", "contact-1"]
    )
  );
});

test("different-people decisions are same-manager reversible", () => {
  const reviewedAt = admin.firestore.Timestamp.fromMillis(10_000);
  const decision = nextMergeReviewDecision({
    candidateId: "ocmc_test",
    organizerId: "organizer-1",
    contactIds: ["contact-1", "contact-2"],
    actorUid: "manager-1",
    requestedState: "differentPeople",
    expectedRevision: null,
    existing: undefined,
    now: reviewedAt,
  });
  assert.equal(decision.state, "differentPeople");
  assert.equal(decision.reviewedByUid, "manager-1");

  assert.throws(
    () => nextMergeReviewDecision({
      candidateId: "ocmc_test",
      organizerId: "organizer-1",
      contactIds: ["contact-1", "contact-2"],
      actorUid: "manager-2",
      requestedState: "reopen",
      expectedRevision: decision.revision,
      existing: decision,
      now: admin.firestore.Timestamp.fromMillis(11_000),
    }),
    (error: unknown) => error instanceof Error &&
      "code" in error && error.code === "permission-denied"
  );

  const reopened = nextMergeReviewDecision({
    candidateId: "ocmc_test",
    organizerId: "organizer-1",
    contactIds: ["contact-1", "contact-2"],
    actorUid: "manager-1",
    requestedState: "reopen",
    expectedRevision: decision.revision,
    existing: decision,
    now: admin.firestore.Timestamp.fromMillis(12_000),
  });
  assert.equal(reopened.state, "reopened");
  assert.equal(reopened.reopenedByUid, "manager-1");
  assert.ok(reopened.revision > decision.revision);
});

function claim(
  kind: OrganizerContactIdentityClaimDocument["kind"],
  identityHash: string,
  conflictingContactIds: string[],
  updatedAtMillis: number,
  state: OrganizerContactIdentityClaimDocument["state"] = "conflicted",
  organizerId = "organizer-1"
): {id: string; data: OrganizerContactIdentityClaimDocument} {
  const timestamp = admin.firestore.Timestamp.fromMillis(updatedAtMillis);
  return {
    id: identityHash,
    data: {
      organizerId,
      kind,
      identityHash,
      hashVersion: "hmac-sha256-v1",
      state,
      verifiedContactId: "contact-1",
      originVerifiedContactId: "contact-1",
      conflictingContactIds,
      revision: updatedAtMillis,
      createdAt: timestamp,
      updatedAt: timestamp,
    },
  };
}

function link(
  kind: OrganizerContactIdentityLinkDocument["kind"],
  identityHash: string,
  contactId: string,
  updatedAtMillis: number
): {id: string; data: OrganizerContactIdentityLinkDocument} {
  const timestamp = admin.firestore.Timestamp.fromMillis(updatedAtMillis);
  return {
    id: `${kind}-${contactId}`,
    data: {
      organizerId: "organizer-1",
      contactId,
      originContactId: contactId,
      attendeeId: `${contactId}-attendee`,
      kind,
      identityHash,
      hashVersion: "hmac-sha256-v1",
      confidence: "proposed",
      source: "hostImport",
      createdAt: timestamp,
      updatedAt: timestamp,
    },
  };
}
