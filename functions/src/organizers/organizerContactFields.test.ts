import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import type {
  OrganizerContactDocument,
  OrganizerContactEventEdgeDocument,
} from "../shared/generated/firestoreAdminTypes";
import {
  organizerContactProjectedFields,
  organizerContactVisibleFields,
} from "./organizerContactFields";

type Contact = Pick<OrganizerContactDocument,
  "organizerId" | "displayName" | "displayNameOverride" |
  "phoneE164" | "email" | "linkedUid">;
type Edge = Pick<OrganizerContactEventEdgeDocument,
  "organizerId" | "attendeeId" | "sourceUpdatedAt" | "displayName" |
  "phoneE164" | "email" | "linkedUid">;

function contact(overrides: Partial<Contact> = {}): Contact {
  return {
    organizerId: "org-1", displayName: "Stored name",
    displayNameOverride: null, phoneE164: null, email: null,
    linkedUid: null, ...overrides,
  };
}

function edge(overrides: Partial<Edge> = {}): Edge {
  return {
    organizerId: "org-1", attendeeId: "attendee-1",
    sourceUpdatedAt: Timestamp.fromMillis(1), displayName: "Event name",
    phoneE164: null, email: null, linkedUid: null, ...overrides,
  };
}

test("selects newest non-null phone and email independently", () => {
  const fields = organizerContactProjectedFields({
    contact: contact({phoneE164: "+10000000000",
      email: "stored@example.test"}),
    edges: [
      edge({attendeeId: "older", sourceUpdatedAt: Timestamp.fromMillis(10),
        phoneE164: "+11111111111", email: null}),
      edge({attendeeId: "newer", sourceUpdatedAt: Timestamp.fromMillis(20),
        displayName: "Newest event", phoneE164: null,
        email: "newer@example.test"}),
    ],
    hasStandaloneOrigin: false,
  });
  assert.deepEqual(fields, {displayName: "Newest event",
    phoneE164: "+11111111111", email: "newer@example.test"});
});

test("linked UID does not give an edge endpoint precedence", () => {
  const fields = organizerContactProjectedFields({
    contact: contact(),
    edges: [
      edge({attendeeId: "linked", sourceUpdatedAt: Timestamp.fromMillis(10),
        linkedUid: "uid-1", phoneE164: "+11111111111",
        email: "linked@example.test"}),
      edge({attendeeId: "recent", sourceUpdatedAt: Timestamp.fromMillis(20),
        linkedUid: null, phoneE164: "+12222222222",
        email: "recent@example.test"}),
    ],
    hasStandaloneOrigin: false,
  });
  assert.deepEqual(fields, {displayName: "Event name",
    phoneE164: "+12222222222", email: "recent@example.test"});
});

test("standalone source retains stored fields and fills only null endpoints",
  () => {
    const source = contact({displayName: "Organizer name",
      phoneE164: "+13333333333", email: null});
    const fields = organizerContactProjectedFields({
      contact: source,
      edges: [edge({displayName: "Different event name",
        phoneE164: "+14444444444", email: "event@example.test"})],
      hasStandaloneOrigin: true,
    });
    assert.deepEqual(fields, {displayName: "Organizer name",
      phoneE164: "+13333333333", email: "event@example.test"});
  });

test("excludes edges belonging to another organizer", () => {
  const fields = organizerContactProjectedFields({
    contact: contact({phoneE164: "+15555555555"}),
    edges: [
      edge({organizerId: "other", attendeeId: "foreign",
        sourceUpdatedAt: Timestamp.fromMillis(100),
        displayName: "Foreign", phoneE164: "+19999999999",
        email: "foreign@example.test"}),
      edge({attendeeId: "local", sourceUpdatedAt: Timestamp.fromMillis(10),
        displayName: "Local", email: "local@example.test"}),
    ],
    hasStandaloneOrigin: false,
  });
  assert.deepEqual(fields, {displayName: "Local",
    phoneE164: "+15555555555", email: "local@example.test"});
});

test("same-time edges resolve by attendee id", () => {
  const fields = organizerContactProjectedFields({
    contact: contact(),
    edges: [edge({attendeeId: "z", phoneE164: "+12222222222"}),
      edge({attendeeId: "a", phoneE164: "+11111111111"})],
    hasStandaloneOrigin: false,
  });
  assert.equal(fields.phoneE164, "+11111111111");
});

test("visible read exposes the same stored fields for linked and unlinked",
  () => {
    const stored = contact({displayName: "Source name",
      displayNameOverride: "Organizer label", phoneE164: "+11111111111",
      email: "known@example.test"});
    const linkedStored: Contact = {...stored, linkedUid: "uid-1"};
    const linked = organizerContactVisibleFields(linkedStored);
    const unlinked = organizerContactVisibleFields(stored);
    const expected = {displayName: "Organizer label",
      sourceDisplayName: "Source name",
      displayNameOverride: "Organizer label",
      phoneE164: "+11111111111", email: "known@example.test"};
    assert.deepEqual(linked, expected);
    assert.deepEqual(unlinked, expected);
    assert.deepEqual(organizerContactVisibleFields(contact()), {
      displayName: "Stored name", sourceDisplayName: "Stored name",
      displayNameOverride: null, phoneE164: null, email: null,
    });
  });
