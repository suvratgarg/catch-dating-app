import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {EventAttendeeDocument} from "./generated/firestoreAdminTypes";
import {
  attendeeOrganizerContactOrigin,
  manualOrganizerContactOrigin,
  organizerContactOriginId,
} from "./organizerContactOrigins";

const now = admin.firestore.Timestamp.fromMillis(2_000);

test("manual contact origin names its manager and original identity", () => {
  const origin = manualOrganizerContactOrigin({
    organizerId: "organizer-1",
    contactId: "contact-1",
    actorUid: "manager-1",
    now,
  });
  assert.equal(origin.currentContactId, "contact-1");
  assert.equal(origin.originContactId, "contact-1");
  assert.equal(origin.actorClass, "organizerManager");
  assert.equal(origin.actorUid, "manager-1");
});

test("attendee origin preserves source identity after a merge", () => {
  const attendee = {
    organizerId: "organizer-1",
    eventId: "event-1",
    source: "webOtp",
    linkedUid: "user-1",
    createdAt: now,
  } as EventAttendeeDocument;
  const origin = attendeeOrganizerContactOrigin({
    attendeeId: "attendee-1",
    attendee,
    contactId: "contact-survivor",
    originContactId: "contact-source",
    now,
  });
  assert.equal(origin.currentContactId, "contact-survivor");
  assert.equal(origin.originContactId, "contact-source");
  assert.equal(origin.actorClass, "participant");
  assert.equal(origin.actorUid, "user-1");
  assert.equal(
    organizerContactOriginId({
      organizerId: origin.organizerId,
      sourceKind: origin.sourceKind,
      sourceEntityKind: origin.sourceEntityKind,
      sourceEntityId: origin.sourceEntityId,
    }),
    organizerContactOriginId({
      organizerId: origin.organizerId,
      sourceKind: origin.sourceKind,
      sourceEntityKind: origin.sourceEntityKind,
      sourceEntityId: origin.sourceEntityId,
    })
  );
});
