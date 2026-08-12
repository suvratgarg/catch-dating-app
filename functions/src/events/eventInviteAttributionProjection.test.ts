import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {OrganizerContactEventEdgeDocument} from
  "../shared/generated/firestoreAdminTypes";
import {
  attributionTransitions,
  isReferralCredit,
} from "./eventInviteAttributionProjection";

test("registration and check-in transitions credit and reverse once", () => {
  assert.deepEqual(attributionTransitions(undefined, edge({
    registered: true,
    checkedIn: false,
  })), [{factKind: "registration", operation: "credit"}]);
  assert.deepEqual(attributionTransitions(edge({
    registered: true,
    checkedIn: false,
  }), edge({registered: true, checkedIn: true})), [
    {factKind: "checkIn", operation: "credit"},
  ]);
  assert.deepEqual(attributionTransitions(edge({
    registered: true,
    checkedIn: true,
  }), edge({registered: false, cancelled: true, checkedIn: false})), [
    {factKind: "registration", operation: "reversal"},
    {factKind: "checkIn", operation: "reversal"},
  ]);
});

test("a direct recipient is not credited for their own registration", () => {
  assert.equal(isReferralCredit({
    linkKind: "directRecipient",
    ownerContactId: null,
    intendedRecipientContactId: "contact-1",
    subjectContactId: "contact-1",
  }), false);
  assert.equal(isReferralCredit({
    linkKind: "directRecipient",
    ownerContactId: null,
    intendedRecipientContactId: "contact-1",
    subjectContactId: "contact-2",
  }), true);
});

test("attendee referral credit requires a different verified contact", () => {
  assert.equal(isReferralCredit({
    linkKind: "attendeeReferrer",
    ownerContactId: "contact-1",
    intendedRecipientContactId: null,
    subjectContactId: "contact-2",
  }), true);
  assert.equal(isReferralCredit({
    linkKind: "hostChannel",
    ownerContactId: null,
    intendedRecipientContactId: null,
    subjectContactId: "contact-2",
  }), false);
});

function edge(
  overrides: Partial<OrganizerContactEventEdgeDocument>
): OrganizerContactEventEdgeDocument {
  const time = admin.firestore.Timestamp.fromMillis(1_000);
  return {
    organizerId: "organizer-1",
    contactId: "contact-1",
    originContactId: "contact-1",
    eventId: "event-1",
    attendeeId: "attendee-1",
    displayName: "Asha",
    linkedUid: "user-1",
    phoneE164: "+919876543210",
    email: null,
    source: "webOtp",
    status: "registered",
    expected: true,
    registered: true,
    cancelled: false,
    checkedIn: false,
    eventStartAt: time,
    eventEndAt: time,
    registeredAt: time,
    cancelledAt: null,
    checkedInAt: null,
    inviteLinkId: "link-1",
    inviteCapturedAt: time,
    sourceCreatedAt: time,
    sourceUpdatedAt: time,
    revision: 1,
    createdAt: time,
    updatedAt: time,
    ...overrides,
  };
}
