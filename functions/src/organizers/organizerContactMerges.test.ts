import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import type {OrganizerContactDocument} from
  "../shared/generated/firestoreAdminTypes";
import {mergeConflicts, mergeEvidence} from "./organizerContactMerges";

test("merge conflicts keep each contradictory identity route explicit", () => {
  const survivor = contact({
    linkedUid: "user-1",
    phoneE164: "+919876543210",
    email: "asha@example.com",
  });
  const source = contact({
    linkedUid: "user-2",
    phoneE164: "+919999999999",
    email: "other@example.com",
  });

  assert.deepEqual(mergeConflicts(survivor, source), [
    "linkedUid",
    "phoneE164",
    "email",
  ]);
});

test("verified identity evidence outranks an imported phone match", () => {
  const verified = mergeEvidence(
    contact({linkedUid: "user-1", phoneE164: "+919876543210"}),
    contact({linkedUid: "user-1", phoneE164: "+919876543210"})
  );
  assert.deepEqual(verified, [
    "managerConfirmed",
    "sameVerifiedUid",
    "sameVerifiedPhone",
  ]);

  const proposed = mergeEvidence(
    contact({linkedUid: null, phoneE164: "+919876543210"}),
    contact({linkedUid: null, phoneE164: "+919876543210"})
  );
  assert.deepEqual(proposed, ["managerConfirmed", "sameImportedPhone"]);
});

test("matching email never silently removes manager review", () => {
  assert.deepEqual(
    mergeEvidence(
      contact({email: "asha@example.com"}),
      contact({email: "asha@example.com"})
    ),
    ["managerConfirmed", "sameEmail"]
  );
});

function contact(
  overrides: Partial<OrganizerContactDocument> = {}
): OrganizerContactDocument {
  const timestamp = admin.firestore.Timestamp.fromMillis(1_000);
  return {
    organizerId: "organizer-1",
    displayName: "Asha",
    searchName: "asha",
    linkedUid: null,
    phoneE164: null,
    email: null,
    identityState: "unlinked",
    identityConfidence: "proposed",
    primarySource: "hostImport",
    ambiguousCandidateContactIds: [],
    firstSeenAt: timestamp,
    lastSeenAt: timestamp,
    sourceCount: 1,
    whatsappStatus: "unknown",
    smsStatus: "unknown",
    revision: 1,
    mergedIntoContactId: null,
    createdAt: timestamp,
    updatedAt: timestamp,
    deletedAt: null,
    ...overrides,
  };
}
