import assert from "node:assert/strict";
import test from "node:test";
import {eventAttendeeId} from "../events/eventAttendees";
import type {EventAttendeeDocument} from
  "../shared/generated/firestoreAdminTypes";
import {organizerContactOriginId} from
  "../shared/organizerContactOrigins";
import {formAdmissionContactId, formConversionReceiptId} from
  "./organizerFormAdmissionIdentity";

type Row = Record<string, unknown>;

class FakeStore {
  constructor(readonly rows: Record<string, Row>) {}

  collection(path: string) {
    return {doc: (id: string) => ({
      get: async () => ({data: () => this.rows[`${path}/${id}`]}),
    })};
  }
}

const organizerId = "org1";
const eventId = "event1";
const responseId = "response1";
const contactId = "contact1";
const phone = "+919876543210";

function attendee(): EventAttendeeDocument {
  return {organizerId, eventId, externalReference: responseId,
    sourceRowId: responseId, source: "hostManual", phoneE164: phone,
    email: null} as EventAttendeeDocument;
}

function rows(resultId: string | null, status: "pending" | "completed") {
  return {
    ["organizerFormConversionReceipts/" + formConversionReceiptId(
      responseId, "eventAttendeeProposal", eventId)]: {
      organizerId, formId: "form1", responseId,
      kind: "eventAttendeeProposal", status, resultId,
      fields: [{destinationField: "eventId", value: eventId}],
    },
    ["organizerContactOrigins/" + organizerContactOriginId({organizerId,
      sourceKind: "hostForm", sourceEntityKind: "hostFormResponse",
      sourceEntityId: responseId})]: {
      organizerId, formId: "form1", sourceEntityId: responseId,
      currentContactId: contactId,
    },
    [`organizerContacts/${contactId}`]: {organizerId, deletedAt: null,
      hiddenAt: null, mergedIntoContactId: null},
  };
}

test("completed receipt proves a legacy phone-key admission", async () => {
  const legacyId = eventAttendeeId(eventId, `phone:${phone}`);
  const db = new FakeStore(rows(legacyId, "completed"));
  assert.equal(await formAdmissionContactId({
    db: db as unknown as FirebaseFirestore.Firestore,
    attendeeId: legacyId,
    attendee: attendee(),
  }), contactId);
});

test("pending receipt accepts only the current response-key admission",
  async () => {
    const currentId = eventAttendeeId(eventId,
      `external:${responseId.toLowerCase()}`);
    const db = new FakeStore(rows(null, "pending"));
    assert.equal(await formAdmissionContactId({
      db: db as unknown as FirebaseFirestore.Firestore,
      attendeeId: currentId,
      attendee: attendee(),
    }), contactId);
    assert.equal(await formAdmissionContactId({
      db: db as unknown as FirebaseFirestore.Firestore,
      attendeeId: eventAttendeeId(eventId, `phone:${phone}`),
      attendee: attendee(),
    }), null);
  });
