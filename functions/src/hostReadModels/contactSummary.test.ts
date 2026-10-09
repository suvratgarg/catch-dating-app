import assert from "node:assert/strict";
import test from "node:test";
import type {OrganizerContactDocument, OrganizerContactTraitDocument,
  OrganizerContactChannelStateDocument} from
  "../shared/generated/firestoreAdminTypes";
import {projectContactSummary} from "./contactSummary";

function inputs() {
  return {contactId: "person", tags: new Map(),
    contact: {organizerId: "org", displayName: "Original",
      displayNameOverride: "Host label", searchName: "host label",
      phoneE164: "+919999999999", email: null, linkedUid: "private-account",
      identityState: "verified", identityConfidence: "verified",
      ambiguousCandidateContactIds: ["candidate"],
      lastSeenAt: {toMillis: () => 123}, deletedAt: null,
      hiddenAt: null, hiddenTraitSnapshot: {private: "not-a-view"},
      revision: 2} as unknown as OrganizerContactDocument,
    traits: {organizerId: "org", contactId: "person",
      expectedEventCount: 3, attendedEventCount: 2, segmentIds: [],
      linkedAccount: true, importedEventCount: 0,
      whatsappStatus: "unknown", smsStatus: "unknown", sourceCoverage: "exact",
    } as unknown as OrganizerContactTraitDocument,
    channel: undefined as OrganizerContactChannelStateDocument | undefined};
}

test("view keeps host facts and omits account and merge evidence", () => {
  const view = projectContactSummary(inputs())!;
  assert.equal(view.row.displayName, "Host label");
  assert.equal(view.row.attendedEventCount, 2);
  assert.equal(view.row.ambiguousCandidateCount, 1);
  const serialized = JSON.stringify(view);
  for (const privateValue of ["private-account", "candidate", "not-a-view"]) {
    assert.equal(serialized.includes(privateValue), false);
  }
  assert.deepEqual(Object.keys(view).sort(), ["contactId",
    "importedContact", "lastSeenAtMillis",
    "linkedAccount", "manualTagIds", "organizerId", "row",
    "searchName", "version"]);
});

test("invalid or unavailable sources fail closed", () => {
  const base = inputs();
  assert.equal(projectContactSummary({...base, contact: undefined}), null);
  assert.equal(projectContactSummary({...base, traits: undefined}), null);
  for (const patch of [{hiddenAt: {}}, {deletedAt: {}},
    {identityState: "merged"}]) {
    assert.equal(projectContactSummary({...base,
      contact: {...base.contact, ...patch} as OrganizerContactDocument}), null);
  }
  for (const patch of [{organizerId: "foreign"}, {contactId: "another"}]) {
    assert.equal(projectContactSummary({...base,
      traits: {...base.traits, ...patch}}), null);
  }
});

test("another contact or organizer cannot supply suppression state", () => {
  for (const patch of [{organizerId: "foreign"}, {contactId: "another"}]) {
    const view = projectContactSummary({...inputs(), channel: {
      organizerId: "org", contactId: "person", adminSuppressed: true, ...patch,
    } as OrganizerContactChannelStateDocument});
    assert.equal(view!.row.whatsappAdminSuppressed, false);
  }
});
