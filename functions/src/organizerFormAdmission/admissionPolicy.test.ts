import assert from "node:assert/strict";
import test from "node:test";
import {
  AdmissionCommand, AdmissionFacts, AdmissionPolicyError,
  admissionRequestHash, decideFormAdmission,
} from "./admissionPolicy";

function fixture(): {command: AdmissionCommand; facts: AdmissionFacts} {
  const command: AdmissionCommand = {actorUid: "host1", organizerId: "org1",
    eventId: "event1", responseId: "response1", contactId: "contact1",
    offerId: "offer1", requestId: "request1",
    expectedOfferRevision: 2, expectedOfferGeneration: 1,
    expectedLedgerRevision: 3};
  const facts: AdmissionFacts = {
    manager: {organizerId: "org1", actorUid: "host1", authorized: true,
      accountDeleted: false, organizerActive: true},
    source: {organizerId: "org1", responseId: "response1",
      formId: "form1", versionId: "version1", status: "submitted",
      withdrawn: false, submittedVersionValid: true,
      purpose: "registration",
      targetKind: "event", targetId: "event1",
      crmReceiptCompleted: true, crmReceiptContactId: "contact1"},
    origin: {organizerId: "org1", responseId: "response1",
      formId: "form1", originContactId: "contact1",
      currentContactId: "contact1"},
    contact: {organizerId: "org1", contactId: "contact1",
      available: true, ambiguous: false},
    event: {organizerId: "org1", eventId: "event1", active: true,
      startsAtMillis: 5_000_000, sourceRevision: 4},
    offer: {offerId: "offer1", organizerId: "org1", eventId: "event1",
      contactId: "contact1", responseId: "response1",
      sourceKind: "formResponse", status: "offered", generation: 1,
      revision: 2, expiresAtMillis: 4_000_000,
      payment: {eventPaymentRevision: 1,
        eventPaymentHash: "a".repeat(64), expectedAmountMinor: 0,
        currency: "INR", collectionMode: null,
        reusablePaymentPageUrl: null, personalPaymentLink: null,
        paymentInstructions: null, expiresAtMillis: 4_000_000},
      manual: {status: "none", evidenceRecordedAtMillis: null,
        bankReceiptChecked: false, reviewedByUid: null,
        reviewedAtMillis: null, reviewNote: null,
        attestedAmountMinor: null, attestedCurrency: null,
        attestedEventPaymentRevision: null,
        attestedEventPaymentHash: null}},
    seat: {ready: true, ledgerRevision: 3, capacityRevision: 1,
      migrationRevision: 1, canonicalKey: "guest1",
      identityRevision: 1, occupancySource: "none",
      seatAlreadyOccupied: false, sourceAttendeeId: null,
      rosterTarget: "absent", catchParticipation: null},
    receipt: null, sourceAdmission: null, nowMillis: 2_000_000,
  };
  return {command, facts};
}

function denied(command: AdmissionCommand, facts: AdmissionFacts,
  code: AdmissionPolicyError["code"]) {
  assert.throws(() => decideFormAdmission(command, facts), (error) =>
    error instanceof AdmissionPolicyError && error.code === code);
}

test("explicit zero-price offer prepares one seat and roster write", () => {
  const {command, facts} = fixture();
  assert.deepEqual(decideFormAdmission(command, facts), {
    kind: "commit", requestHash: admissionRequestHash(command),
    seatAction: "reserve", rosterAction: "create",
    sourceAttendeeId: null, paymentAuthority: "explicitFree",
  });
  facts.offer.payment.expectedAmountMinor = null;
  denied(command, facts, "unavailable");
});

test("paid external offer requires exact reviewed historical attestation",
  () => {
    const {command, facts} = fixture();
    facts.offer.payment.expectedAmountMinor = 150000;
    facts.offer.payment.collectionMode = "personalRequest";
    facts.offer.payment.personalPaymentLink = "https://pay.example/request";
    denied(command, facts, "unavailable");
    facts.offer.manual = {...facts.offer.manual,
      status: "hostAttestedReceived", evidenceRecordedAtMillis: 1_800_000,
      bankReceiptChecked: true, reviewedByUid: "host1",
      reviewedAtMillis: 1_900_000, reviewNote: "Bank receipt checked",
      attestedAmountMinor: 150000, attestedCurrency: "INR",
      attestedEventPaymentRevision: 1,
      attestedEventPaymentHash: "a".repeat(64)};
    assert.equal(decideFormAdmission(command, facts).kind, "commit");
    facts.offer.manual.evidenceRecordedAtMillis = 1_950_000;
    denied(command, facts, "unavailable");
    facts.offer.manual.evidenceRecordedAtMillis = 1_800_000;
    facts.offer.manual.attestedEventPaymentHash = "b".repeat(64);
    denied(command, facts, "unavailable");
    facts.offer.manual.attestedEventPaymentHash = "a".repeat(64);
    facts.offer.payment.personalPaymentLink = null;
    denied(command, facts, "unavailable");
    facts.offer.payment.personalPaymentLink = "https://pay.example/request";
    facts.offer.payment.collectionMode = "catchCheckout";
    denied(command, facts, "unavailable");
  });

test("current manager, source, CRM and event authority fail closed", () => {
  const cases: Array<(facts: AdmissionFacts) => void> = [
    (facts) => {
      facts.manager.authorized = false;
    },
    (facts) => {
      facts.manager.accountDeleted = true;
    },
    (facts) => {
      facts.source.withdrawn = true;
    },
    (facts) => {
      facts.source.submittedVersionValid = false;
    },
    (facts) => {
      facts.source.targetId = "anotherEvent";
    },
    (facts) => {
      facts.source.crmReceiptCompleted = false;
    },
    (facts) => {
facts.origin!.currentContactId = "mergedContact";
    },
    (facts) => {
facts.contact!.ambiguous = true;
    },
    (facts) => {
      facts.event.active = false;
    },
    (facts) => {
      facts.event.startsAtMillis = 1_000_000;
    },
  ];
  for (const mutate of cases) {
    const {command, facts} = fixture();
    mutate(facts);
    denied(command, facts, facts.manager.authorized === false ||
      facts.manager.accountDeleted ? "denied" : "unavailable");
  }
});

test("offer and ledger revisions fence stale review", () => {
  const {command, facts} = fixture();
  facts.offer.revision++;
  denied(command, facts, "stale");
  facts.offer.revision--;
  facts.offer.generation++;
  denied(command, facts, "stale");
  facts.offer.generation--;
  facts.seat.ledgerRevision++;
  denied(command, facts, "stale");
  facts.seat.ledgerRevision--;
  facts.offer.status = "withdrawn";
  denied(command, facts, "unavailable");
});

test("linked imported seat is retained only with its proven attendee", () => {
  const {command, facts} = fixture();
  facts.seat.seatAlreadyOccupied = true;
  facts.seat.occupancySource = "imported";
  facts.seat.sourceAttendeeId = "attendee1";
  facts.seat.rosterTarget = "sameImported";
  assert.deepEqual(decideFormAdmission(command, facts), {
    kind: "commit", requestHash: admissionRequestHash(command),
    seatAction: "retain", rosterAction: "linkExisting",
    sourceAttendeeId: "attendee1", paymentAuthority: "explicitFree",
  });
  facts.seat.sourceAttendeeId = null;
  denied(command, facts, "conflict");
  facts.seat.sourceAttendeeId = "attendee1";
  facts.seat.rosterTarget = "foreign";
  denied(command, facts, "conflict");
});

test("verified active Catch seat is retained without inventing an import",
  () => {
    const {command, facts} = fixture();
    facts.seat.occupancySource = "catch";
    facts.seat.seatAlreadyOccupied = true;
    facts.seat.rosterTarget = "absent";
    facts.seat.catchParticipation = {eventId: "event1", uid: "runner1",
      status: "signedUp", canonicalKey: "guest1",
      verifiedResponseUid: "runner1"};
    assert.deepEqual(decideFormAdmission(command, facts), {
      kind: "commit", requestHash: admissionRequestHash(command),
      seatAction: "retain", rosterAction: "preserveCatch",
      sourceAttendeeId: null, paymentAuthority: "explicitFree",
    });
    facts.seat.catchParticipation.verifiedResponseUid = "anotherUid";
    denied(command, facts, "conflict");
    facts.seat.catchParticipation.verifiedResponseUid = "runner1";
    facts.seat.catchParticipation.canonicalKey = "otherSeat";
    denied(command, facts, "conflict");
    facts.seat.catchParticipation.canonicalKey = "guest1";
    Object.assign(facts.seat.catchParticipation, {status: "cancelled"});
    denied(command, facts, "conflict");
  });

test("exact receipt replays historically after source withdrawal, not mutation",
  () => {
    const {command, facts} = fixture();
    const receipt = {organizerId: "org1", eventId: "event1",
      responseId: "response1", contactId: "contact1", offerId: "offer1",
      requestId: "request1", receiptId: "receipt1",
      requestHash: admissionRequestHash(command),
      expectedOfferRevision: 2, expectedOfferGeneration: 1,
      expectedLedgerRevision: 3,
      attendeeId: "attendee1", canonicalSeatKey: "guest1",
      resultingLedgerRevision: 4, admittedAtMillis: 1_900_000,
      seatAlreadyOccupied: false, actorUid: "host1"};
    facts.receipt = receipt;
    facts.sourceAdmission = {organizerId: "org1", eventId: "event1",
      responseId: "response1", receiptId: "receipt1",
      attendeeId: "attendee1", canonicalSeatKey: "guest1",
      offerId: "offer1", offerRevision: 2, offerGeneration: 1};
    facts.source.withdrawn = true;
    facts.offer.status = "withdrawn";
    assert.deepEqual(decideFormAdmission(command, facts), {
      kind: "replay", requestHash: receipt.requestHash, receipt,
    });
    facts.manager.accountDeleted = true;
    denied(command, facts, "denied");
  });

test("reused request ID or malformed receipt conflicts",
  () => {
    const {command, facts} = fixture();
    facts.receipt = {organizerId: "org1", eventId: "event1",
      responseId: "response1", contactId: "contact1", offerId: "offer1",
      requestId: "request1", receiptId: "receipt1",
      requestHash: admissionRequestHash(command),
      expectedOfferRevision: 2, expectedOfferGeneration: 1,
      expectedLedgerRevision: 3,
      attendeeId: "attendee1", canonicalSeatKey: "guest1",
      resultingLedgerRevision: 4, admittedAtMillis: 1_900_000,
      seatAlreadyOccupied: false, actorUid: "host1"};
    facts.sourceAdmission = {organizerId: "org1", eventId: "event1",
      responseId: "response1", receiptId: "receipt1",
      attendeeId: "attendee1", canonicalSeatKey: "guest1",
      offerId: "offer1", offerRevision: 2, offerGeneration: 1};
    denied({...command, responseId: "anotherResponse"}, facts, "conflict");
    facts.receipt.resultingLedgerRevision = 0;
    denied(command, facts, "conflict");
  });

test("new request ID cannot admit one response twice", () => {
  const {command, facts} = fixture();
  facts.seat.seatAlreadyOccupied = true;
  facts.seat.occupancySource = "imported";
  facts.seat.rosterTarget = "sameImported";
  facts.seat.sourceAttendeeId = "attendee1";
  facts.sourceAdmission = {organizerId: "org1", eventId: "event1",
    responseId: "response1", receiptId: "earlierReceipt",
    attendeeId: "attendee1", canonicalSeatKey: "guest1",
    offerId: "offer1", offerRevision: 2, offerGeneration: 1};
  denied(command, facts, "conflict");
});
