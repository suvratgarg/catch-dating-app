import {strict as assert} from "node:assert";
import {test} from "node:test";
import {validateCommitOrganizerFormAdmissionCallablePayload as input} from
  "../shared/generated/validators/commitOrganizerFormAdmissionInput";
import {validateCommitOrganizerFormAdmissionCallableResponse as output} from
  "../shared/generated/validators/commitOrganizerFormAdmissionOutput";
import {validateOrganizerFormAdmissionDocument as ownership} from
  "../shared/generated/validators/organizerFormAdmissionDocument";

const command = {
  organizerId: "organizer-one", eventId: "event-one",
  responseId: "response-one", contactId: "contact-one", offerId: "offer-one",
  expectedOfferRevision: 2, expectedOfferGeneration: 1,
  expectedLedgerRevision: 3, requestId: "admission-request-one",
};

test("admission rejects caller-supplied authority", () => {
  assert.equal(input(command), true);
  for (const [field, value] of Object.entries({
    actorUid: "manager", managerAuthorized: true, paid: true,
    bankReceiptChecked: true, seatAlreadyOccupied: true, capacity: 200,
    canonicalSeatKey: "uid_forged", paymentSnapshot: {},
  })) {
    assert.equal(input({...command, [field]: value}), false, field);
  }
});

test("admission requires every reviewed identity and positive revision", () => {
  for (const field of Object.keys(command)) {
    const missing = {...command} as Record<string, unknown>;
    delete missing[field];
    assert.equal(input(missing), false, field);
  }
  for (const field of ["expectedOfferRevision", "expectedOfferGeneration",
    "expectedLedgerRevision"]) {
    for (const value of [0, -1, 1.5, Number.MAX_SAFE_INTEGER + 1, "1"]) {
      assert.equal(input({...command, [field]: value}), false, field);
    }
  }
  assert.equal(input({...command, responseId: "other/path"}), false);
  assert.equal(input({...command, requestId: "short"}), false);
});

test("admission result excludes private payment data", () => {
  const result = {
    receiptId: "admission-receipt-one", organizerId: command.organizerId,
    eventId: command.eventId, responseId: command.responseId,
    contactId: command.contactId, offerId: command.offerId,
    attendeeId: "attendee-one", canonicalSeatKey: "contact_one",
    requestId: command.requestId, requestHash: "a".repeat(64),
    resultingLedgerRevision: 4, admittedAtMillis: 1790000000000,
    seatAlreadyOccupied: false, replayed: false,
  };
  assert.equal(output(result), true);
  assert.equal(output({...result, replayed: true}), true);
  assert.equal(output({...result, requestHash: ""}), false);
  assert.equal(output({...result, paymentSnapshot: {}}), false);
  assert.equal(output({...result, manualPayment: {}}), false);
  const missing = {...result} as Record<string, unknown>;
  delete missing.attendeeId;
  assert.equal(output(missing), false);
});

test("source ownership binds admission independently of request IDs", () => {
  const source = {organizerId: "organizer-one", eventId: "event-one",
    responseId: "response-one", receiptId: "receipt-one",
    attendeeId: "attendee-one", canonicalSeatKey: "seat-one",
    offerId: "offer-one", offerRevision: 2, offerGeneration: 1};
  assert.equal(ownership(source), true);
  for (const field of Object.keys(source)) {
    const missing = {...source} as Record<string, unknown>;
    delete missing[field];
    assert.equal(ownership(missing), false, field);
  }
  assert.equal(ownership({...source, requestId: "new-request"}), false);
  assert.equal(ownership({...source, offerGeneration: 0}), false);
  assert.equal(ownership({...source, eventId: "foreign/path"}), false);
});
