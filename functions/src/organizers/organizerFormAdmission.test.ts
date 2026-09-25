import assert from "node:assert/strict";
import {createHash} from "crypto";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {eventAttendeeId} from "../events/eventAttendees";
import {organizerContactOriginId} from
  "../shared/organizerContactOrigins";
import {formConversionReceiptId} from
  "./organizerFormAdmissionIdentity";
import {reviewOrganizerFormAdmission} from "./organizerFormAdmission";

type Row = Record<string, unknown>;
const organizerId = "org1";
const eventId = "event1";
const responseId = "response1";
const contactId = "contact1";
const phone = "+919876543210";
const attendeeId = eventAttendeeId(eventId, `phone:${phone}`);
const offerId = "applicationoffer_" + createHash("sha256")
  .update([organizerId, eventId, contactId].join("\u001f"))
  .digest("hex").slice(0, 40);

class FakeStore {
  readonly rows = new Map<string, Row>();
  reads: string[] = [];
  writes = 0;

  collection(path: string) {
    return {doc: (id: string) => ({path: `${path}/${id}`})};
  }

  async runTransaction<T>(callback: (tx: {
    get: (ref: {path: string}) => Promise<{data: () => Row | undefined}>;
  }) => Promise<T>): Promise<T> {
    return callback({get: async (ref) => {
      this.reads.push(ref.path);
      return {data: () => this.rows.get(ref.path)};
    }});
  }

  set(path: string, value: Row) {
    this.rows.set(path, value);
  }

  patch(path: string, value: Row) {
    this.rows.set(path, {...this.rows.get(path), ...value});
  }
}

function fixture(): FakeStore {
  const db = new FakeStore();
  db.set("organizers/org1", {hostUserId: "manager1", ownerUserId:
    "manager1", hostUserIds: [], hostProfiles: [], status: "active",
  archived: false});
  db.set(`organizerFormResponses/${responseId}`, {organizerId,
    formId: "form1", versionId: "version1", status: "submitted",
    withdrawnAt: null});
  db.set("organizerForms/form1", {organizerId});
  db.set("organizerFormVersions/version1", {organizerId,
    formId: "form1", definition: {purpose: "registration",
      defaultTargetKind: "event", defaultTargetId: eventId}});
  db.set(`events/${eventId}`, {organizerId, clubId: organizerId,
    status: "active", startTime: {toMillis: () => 5_000_000},
    bookedCount: 99, capacityLimit: 100, eventPolicy: {admission: {
      capacityLimit: 100}, pricing: {basePriceInPaise: 0}}});
  db.set("organizerFormConversionReceipts/" +
    formConversionReceiptId(responseId, "crmContact"), {
    organizerId, formId: "form1", responseId, kind: "crmContact",
    status: "completed", resultId: contactId,
    fields: [{destinationField: "phoneNumber", value: phone}],
  });
  db.set("organizerContactOrigins/" + organizerContactOriginId({
    organizerId, sourceKind: "hostForm",
    sourceEntityKind: "hostFormResponse", sourceEntityId: responseId,
  }), {organizerId, formId: "form1", responseId,
    sourceKind: "hostForm", sourceEntityKind: "hostFormResponse",
    sourceEntityId: responseId,
    originContactId: contactId, currentContactId: contactId});
  db.set(`organizerContacts/${contactId}`, {organizerId,
    deletedAt: null, hiddenAt: null, mergedIntoContactId: null,
    identityState: "unlinked", ambiguousCandidateContactIds: []});
  db.set(`organizerEventOffers/${offerId}`, {organizerId, eventId,
    contactId, status: "offered", expiresAtMillis: 4_000_000,
    manualPayment: {status: "hostAttestedReceived",
      bankReceiptChecked: true, reviewNote: "Bank checked",
      evidenceRecordedAtMillis: 1_000_000}});
  return db;
}

async function review(db: FakeStore) {
  return reviewOrganizerFormAdmission({
    db: db as unknown as FirebaseFirestore.Firestore,
    actorUid: "manager1", organizerId, responseId, eventId,
    nowMillis: () => 2_000_000,
  });
}

test("transaction reads source chain but never claims admission", async () => {
  const db = fixture();
  const result = await review(db);
  assert.equal(result.sourceReady, true);
  assert.equal(result.canCommit, false);
  assert.equal(result.offer.current, true);
  assert.equal(result.offer.manualPaymentAttested, true);
  assert.deepEqual(result.blockers,
    ["capacityAuthorityMissing", "paymentPolicyMissing"]);
  assert.ok(db.reads.includes(`organizerEventOffers/${offerId}`));
  assert.ok(db.reads.includes(`organizerContactEventEdges/${attendeeId}`));
  assert.equal(db.writes, 0);
});

test("withdrawal, closure and manager revocation fail closed", async () => {
  const db = fixture();
  db.patch(`organizerFormResponses/${responseId}`, {withdrawnAt: {}});
  assert.ok((await review(db)).blockers.includes("responseWithdrawn"));
  db.patch(`organizerFormResponses/${responseId}`, {withdrawnAt: null});
  db.patch(`organizerFormResponses/${responseId}`, {status: "withdrawn"});
  assert.ok((await review(db)).blockers.includes("responseWithdrawn"));
  db.patch(`events/${eventId}`, {status: "cancelled"});
  assert.ok((await review(db)).blockers.includes("eventClosed"));
  db.patch("organizers/org1", {ownerUserId: "other",
    hostUserId: "other"});
  await assert.rejects(review(db), (error) =>
    error instanceof HttpsError && error.code === "permission-denied");
});

test("withdrawn offer evidence cannot become admission authority", async () => {
  const db = fixture();
  db.patch(`organizerEventOffers/${offerId}`, {status: "withdrawn"});
  const result = await review(db);
  assert.equal(result.offer.current, false);
  assert.equal(result.offer.manualPaymentAttested, false);
  assert.equal(result.canCommit, false);
});

test("merged origin tracks current contact and fails closed", async () => {
  const db = fixture();
  const originPath = "organizerContactOrigins/" +
    organizerContactOriginId({organizerId, sourceKind: "hostForm",
      sourceEntityKind: "hostFormResponse", sourceEntityId: responseId});
  db.patch(originPath, {currentContactId: "contact2"});
  db.set("organizerContacts/contact2", {organizerId,
    deletedAt: null, hiddenAt: null, mergedIntoContactId: null,
    identityState: "unlinked", ambiguousCandidateContactIds: []});
  assert.equal((await review(db)).contactId, "contact2");
  db.patch("organizerContacts/contact2", {deletedAt: {}});
  assert.ok((await review(db)).blockers.includes("contactUnavailable"));
  db.patch(originPath, {originContactId: "other"});
  assert.ok((await review(db)).blockers.includes("originChanged"));
});

test("roster collision and receipt replay do not rewrite a guest", async () => {
  const db = fixture();
  db.set(`organizerContactEventEdges/${attendeeId}`, {organizerId, eventId,
    contactId: "someoneElse"});
  assert.ok((await review(db)).blockers.includes("rosterConflict"));
  db.patch(`organizerContactEventEdges/${attendeeId}`, {contactId});
  db.set(`eventAttendees/${attendeeId}`, {organizerId, eventId,
    externalReference: responseId, sourceRowId: responseId,
    phoneE164: phone, email: null, status: "registered",
    source: "hostManual"});
  db.set("organizerFormConversionReceipts/" +
    formConversionReceiptId(responseId, "eventAttendeeProposal", eventId), {
    organizerId, formId: "form1", responseId,
    kind: "eventAttendeeProposal", status: "completed",
    resultId: attendeeId,
    fields: [{destinationField: "eventId", value: eventId}],
  });
  const replay = await review(db);
  assert.equal(replay.historicallyAdmitted, true);
  assert.equal(replay.canCommit, false);
  assert.equal(db.writes, 0);
  db.patch(`eventAttendees/${attendeeId}`, {phoneE164: "+919111111111"});
  assert.ok((await review(db)).blockers.includes("rosterConflict"));
});

test("observed final seat is not authoritative capacity", async () => {
  const db = fixture();
  db.patch(`events/${eventId}`, {bookedCount: 100,
    capacityLimit: 100});
  const reviewAtLimit = await review(db);
  assert.equal(reviewAtLimit.canCommit, false);
  assert.ok(reviewAtLimit.blockers.includes("capacityAuthorityMissing"));
  db.patch(`events/${eventId}`, {bookedCount: 99});
  const apparentLastSeat = await review(db);
  assert.equal(apparentLastSeat.canCommit, false);
  assert.ok(apparentLastSeat.blockers.includes("capacityAuthorityMissing"));
});
