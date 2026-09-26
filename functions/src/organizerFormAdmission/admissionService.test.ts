import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {createHash} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";
import {eventAttendeeId} from "../events/eventAttendees";
import {deriveEventSeatPolicy} from
  "../events/seatAuthority/firestoreAdapter";
import {SeatAuthorityError} from "../events/seatAuthority/seatAuthority";
import {FirestoreSeatIdentityAuthority, seatIdentityAliasId,
  seatIdentityValueHash} from
  "../events/seatIdentityAuthority";
import {organizerContactOriginId} from
  "../shared/organizerContactOrigins";
import {eventOfferId} from
  "../organizerEventOffers/eventOfferDomain";
import {formConversionReceiptId} from
  "../organizers/organizerFormAdmissionIdentity";
import {AdmissionPolicyError} from "./admissionPolicy";
import {commitOrganizerFormAdmission, formAdmissionOwnershipId,
  formAdmissionReceiptId} from "./admissionService";

type Row = Record<string, unknown>;
const org = "org1";
const eventId = "event1";
const responseId = "response1";
const contactId = "contact1";
const requestId = "request1";
const actorUid = "manager1";
const offerId = eventOfferId({organizerId: org, eventId, contactId});
const ts = (millis: number) => Timestamp.fromMillis(millis);
const hash = (...parts: string[]) => createHash("sha256")
  .update(parts.join("\u001f")).digest("hex");

class Store {
  rows = new Map<string, Row>();
  updateTimes = new Map<string, Timestamp>();
  timeline: string[] = [];
  writes: string[] = [];
  collection(name: string) {
    const query = (filters: Array<[string, unknown]>) => ({
      collection: name, filters,
      where: (field: string, _op: string, value: unknown) =>
        query([...filters, [field, value]]),
      limit: (count: number) => ({collection: name, filters, count}),
    });
    return {doc: (id: string) => ({path: `${name}/${id}`}),
      where: (field: string, _op: string, value: unknown) =>
        query([[field, value]])};
  }
  runTransaction<T>(callback: (tx: FirebaseFirestore.Transaction) =>
    Promise<T>): Promise<T> {
    const pending: Array<() => void> = [];
    let startedWrite = false;
    const stage = (kind: "create" | "set" | "update",
      ref: {path: string}, value: Row) => {
      startedWrite = true;
      this.timeline.push(`write:${ref.path}`);
      pending.push(() => {
        if (kind === "create") assert.equal(this.rows.has(ref.path), false);
        if (kind === "update") assert.equal(this.rows.has(ref.path), true);
        this.rows.set(ref.path, kind === "update" ?
          {...this.rows.get(ref.path), ...value} : value);
        this.writes.push(ref.path);
      });
    };
    const tx = {
      get: async (ref: {path?: string; collection?: string;
        filters?: Array<[string, unknown]>; count?: number}) => {
        assert.equal(startedWrite, false, "no Firestore read after write");
        if (ref.collection && ref.filters) {
          this.timeline.push(`query:${ref.collection}`);
          const docs = [...this.rows].filter(([path, row]) =>
            path.startsWith(`${ref.collection}/`) &&
            ref.filters!.every(([field, value]) => row[field] === value))
            .slice(0, ref.count).map(([path, row]) => ({
              id: path.split("/").at(-1), data: () => row}));
          return {docs};
        }
        assert.ok(ref.path);
        this.timeline.push(`read:${ref.path}`);
        const value = this.rows.get(ref.path);
        return {exists: value !== undefined, data: () => value,
          updateTime: this.updateTimes.get(ref.path)};
      },
      create: (ref: {path: string}, value: Row) =>
        stage("create", ref, value),
      set: (ref: {path: string}, value: Row) => stage("set", ref, value),
      update: (ref: {path: string}, value: Row) =>
        stage("update", ref, value),
    } as unknown as FirebaseFirestore.Transaction;
    return callback(tx).then((result) => {
      pending.forEach((apply) => apply());
      return result;
    });
  }
  db() {
    return this as unknown as FirebaseFirestore.Firestore;
  }
  put(path: string, value: Row) {
    this.rows.set(path, value);
  }
  get(path: string): Row | undefined {
    return this.rows.get(path);
  }
  alias(kind: "uid" | "phone" | "attendee" | "external" |
    "contactOrigin" | "contact", value: string, canonicalKey: string) {
    this.put(`eventSeatIdentityAliases/${seatIdentityAliasId(
      eventId, kind, value)}`, {eventId, organizerId: org, kind,
      valueHash: seatIdentityValueHash(kind, value), canonicalKey,
      identityRevision: 1, migrationRevision: 1, state: "ready"});
  }
}

function fixture() {
  const store = new Store();
  const event = {clubId: org, organizerId: org, status: "active",
    startTime: ts(5_000_000),
    capacityLimit: 2, bookedCount: 0,
    eventPolicy: {version: 2, admission: {capacityLimit: 2}}};
  const policy = deriveEventSeatPolicy(event);
  store.put(`organizers/${org}`, {ownerUserId: actorUid,
    hostUserId: actorUid, hostUserIds: [actorUid], hostProfiles: [],
    archived: false, status: "active"});
  store.put(`users/${actorUid}`, {deleted: false, deletedAt: null});
  store.put(`events/${eventId}`, event);
  store.updateTimes.set(`events/${eventId}`,
    new Timestamp(1_800_000_000, 123_456_000));
  store.put(`eventSeatMigrationFences/${eventId}`,
    {eventId, state: "ready", migrationRevision: 1});
  store.put(`eventSeatLedgers/${eventId}`, {eventId, capacity: 2,
    occupied: 0, revision: 3, capacityRevision: 1,
    policyVersion: policy.policyVersion, policyHash: policy.policyHash,
    migrationRevision: 1, state: "ready"});
  store.put(`organizerFormResponses/${responseId}`, {
    organizerId: org, formId: "form1", versionId: "version1",
    publicFormId: "publicformabcdefghijklmnop", draftId: "draft1",
    status: "submitted", withdrawnAt: null, identityKind: "anonymous",
    respondentUid: null, withdrawalTokenHash: null, answers: {},
    answerSnapshots: [], consentVersion: "v1", sourceLinkId: null,
    completionMillis: 1000, submittedAt: ts(1100),
    identity: {displayName: "Ada Guest", email: null, phoneE164: null,
      searchName: "ada guest", origin: "anonymous"}});
  store.put("organizerForms/form1", {organizerId: org,
    purpose: "registration", status: "published"});
  store.put("organizerFormVersions/version1", {organizerId: org,
    formId: "form1", version: 1, sourceDraftRevision: 1,
    createdByUid: actorUid, createdAt: ts(1000), publishedAt: ts(1050),
    definition: {title: "Registration", description: null,
      purpose: "registration", defaultTargetKind: "event",
      defaultTargetId: eventId, identityPolicy: "anonymous",
      sections: [{sectionId: "section1", title: "Details",
        description: null, pageBreak: false, questions: []}],
      logicRules: [],
      appearance: {preset: "minimal", logoAssetId: null,
        coverAssetId: null, activityKind: null},
      availability: {opensAt: null, closesAt: null,
        responseLimit: null, closedMessage: null},
      consent: {consentCopy: "I consent to sharing my answers.",
        consentVersion: "v1", retentionCopy: "Response retained."},
      completion: {title: "Thanks", message: null, actionKind: "none",
        actionLabel: null, actionUrl: null}}});
  store.put(`organizerFormConversionReceipts/${formConversionReceiptId(
    responseId, "crmContact")}`, {organizerId: org, formId: "form1",
    responseId, kind: "crmContact", status: "completed",
    resultId: contactId});
  const originId = organizerContactOriginId({organizerId: org,
    sourceKind: "hostForm", sourceEntityKind: "hostFormResponse",
    sourceEntityId: responseId});
  store.put(`organizerContactOrigins/${originId}`, {
    organizerId: org, currentContactId: contactId,
    originContactId: contactId, sourceKind: "hostForm",
    sourceEntityKind: "hostFormResponse", sourceEntityId: responseId,
    eventId: null, formId: "form1", responseId});
  store.put(`organizerContacts/${contactId}`, {organizerId: org,
    displayName: "Ada Guest", searchName: "ada guest",
    linkedUid: null, phoneE164: null, email: null,
    identityState: "unlinked", ambiguousCandidateContactIds: [],
    deletedAt: null, hiddenAt: null, mergedIntoContactId: null});
  store.put(`organizerEventOffers/${offerId}`, {offerId, organizerId: org,
    eventId, contactId, applicationId: responseId,
    sourceKind: "formResponse", status: "offered", generation: 1,
    revision: 2, expiresAtMillis: 4_000_000, organizerPaymentLink: null,
    paymentSnapshot: {eventPaymentRevision: 1,
      eventPaymentHash: "a".repeat(64), expectedAmountMinor: 0,
      currency: "INR", collectionMode: null,
      reusablePaymentPageUrl: null, personalPaymentLink: null,
      paymentInstructions: null, messageTemplate: null,
      expiresAtMillis: 4_000_000},
    manualPayment: {status: "none", evidenceReference: null,
      evidenceRecordedAtMillis: null, reviewedByUid: null,
      reviewedAtMillis: null, reviewNote: null,
      bankReceiptChecked: false, attestedAmountMinor: null,
      attestedCurrency: null, attestedEventPaymentRevision: null,
      attestedEventPaymentHash: null},
    offeredAtMillis: 1500, createdAtMillis: 1000,
    updatedAtMillis: 1500});
  const payload = {organizerId: org, eventId, responseId, contactId,
    offerId, expectedOfferRevision: 2, expectedOfferGeneration: 1,
    expectedLedgerRevision: 3, requestId};
  const commit = (overrides: Partial<typeof payload> = {}) =>
    commitOrganizerFormAdmission({db: store.db(), actorUid,
      payload: {...payload, ...overrides}, nowMillis: () => 2000,
      loadCurrentAuthUser: async (uid) => ({uid,
        phoneNumber: "+919999999999"})});
  return {store, payload, commit, originId};
}

function denied(error: unknown) {
  return error instanceof SeatAuthorityError ||
    error instanceof HttpsError && error.code === "failed-precondition" ||
    error instanceof AdmissionPolicyError &&
      ["unavailable", "conflict", "stale", "denied"].includes(error.code);
}

test("reserves one seat and creates roster, marker and exact immutable receipt",
  async () => {
    const {store, commit} = fixture();
    const result = await commit();
    const commitTimeline = store.timeline.slice();
    assert.equal(result.replayed, false);
    assert.equal(result.resultingLedgerRevision, 4);
    assert.equal(store.get(`eventSeatLedgers/${eventId}`)?.occupied, 1);
    assert.equal(store.get(`events/${eventId}`)?.bookedCount, 1);
    const attendee = store.get(`eventAttendees/${result.attendeeId}`);
    assert.equal(attendee?.source, "hostManual");
    assert.equal(attendee?.externalReference, responseId);
    assert.equal(store.get(`organizerFormAdmissions/${
      formAdmissionOwnershipId(org, eventId, responseId)}`)?.attendeeId,
    result.attendeeId);
    const resolved = await store.runTransaction((tx) =>
      new FirestoreSeatIdentityAuthority().resolve({db: store.db(), tx,
        eventId, organizerId: org,
        subject: {kind: "importAttendee", attendeeId: result.attendeeId}}));
    assert.deepEqual(resolved, {key: result.canonicalSeatKey, revision: 1});
    assert.equal(store.get(`organizerFormAdmissionReceipts/${
      formAdmissionReceiptId(org, requestId)}`)?.requestHash,
    result.requestHash);
    assert.ok(commitTimeline.every((entry, index, rows) =>
      !entry.startsWith("read:") && !entry.startsWith("query:") ||
      !rows.slice(0, index).some((before) => before.startsWith("write:"))));
  });

test("legacy admission requires real event snapshot update metadata",
  async () => {
    const {store, commit} = fixture();
    store.updateTimes.delete(`events/${eventId}`);
    await assert.rejects(commit(), denied);
    assert.equal(store.writes.length, 0);
    store.updateTimes.set(`events/${eventId}`,
      new Timestamp(1_800_000_000, 123_456_000));
    store.get(`events/${eventId}`)!.setupRevision = 0;
    await assert.rejects(commit(), denied);
    assert.equal(store.writes.length, 0);
  });

test("historical replay has no writes and new request cannot duplicate source",
  async () => {
    const {store, commit} = fixture();
    const first = await commit();
    const writes = store.writes.length;
    store.get(`organizerFormResponses/${responseId}`)!.status = "withdrawn";
    store.get(`organizerEventOffers/${offerId}`)!.status = "expired";
    const replay = await commit();
    assert.deepEqual(replay, {...first, replayed: true});
    assert.equal(store.writes.length, writes);
    await assert.rejects(commit({requestId: "request2"}), denied);
    assert.equal(store.writes.length, writes);
  });

test("withdrawn, foreign, stale, unpaid and full sources leave zero writes",
  async () => {
    const scenarios: Array<(store: Store) => void> = [
      (store) => {
store.get(`organizerFormResponses/${responseId}`)!
  .status = "withdrawn";
      },
      (store) => {
store.get(`events/${eventId}`)!.clubId = "foreign";
      },
      (store) => {
store.get(`organizerEventOffers/${offerId}`)!
  .revision = 3;
      },
      (store) => {
store.get(`organizerEventOffers/${offerId}`)!
  .paymentSnapshot = {...store.get(`organizerEventOffers/${offerId}`)!
    .paymentSnapshot as Row, expectedAmountMinor: 100,
  collectionMode: "manualInstructions",
  paymentInstructions: "Pay before arrival"};
      },
      (store) => {
store.get(`eventSeatLedgers/${eventId}`)!.occupied = 2;
      },
      (store) => {
store.get(`organizerContacts/${contactId}`)!
  .mergedIntoContactId = "other";
      },
      (store) => {
store.get(`eventSeatMigrationFences/${eventId}`)!
  .state = "locked";
      },
    ];
    for (const mutate of scenarios) {
      const {store, commit} = fixture();
      mutate(store);
      await assert.rejects(commit(), denied);
      assert.deepEqual(store.writes, []);
    }
  });

test("changed manager or deleted account blocks a historical replay",
  async () => {
    const {store, commit} = fixture();
    await commit();
    const writes = store.writes.length;
    store.get(`organizers/${org}`)!.hostUserIds = [];
    store.get(`organizers/${org}`)!.hostUserId = null;
    store.get(`organizers/${org}`)!.ownerUserId = null;
    await assert.rejects(commit(), denied);
    store.get(`organizers/${org}`)!.ownerUserId = actorUid;
    store.put(`deletedUsers/${actorUid}`, {deletedAt: ts(2500)});
    await assert.rejects(commit(), denied);
    assert.equal(store.writes.length, writes);
  });

test("malformed deterministic marker cannot be bypassed by a new request",
  async () => {
    const {store, commit} = fixture();
    store.put(`organizerFormAdmissions/${formAdmissionOwnershipId(org,
      eventId, responseId)}`, {organizerId: org, eventId, responseId,
      receiptId: "wrong"});
    await assert.rejects(commit(), denied);
    assert.deepEqual(store.writes, []);
  });

test("verified imported guest keeps its source and existing seat", async () => {
  const {store, commit} = fixture();
  const phone = "+919999999999";
  const uid = "respondent1";
  const guestId = eventAttendeeId(eventId, `phone:${phone}`);
  const guestKey = "guest_key";
  store.get(`organizerFormResponses/${responseId}`)!.identityKind =
    "phoneVerified";
  store.get(`organizerFormResponses/${responseId}`)!.respondentUid = uid;
  store.get(`organizerFormResponses/${responseId}`)!.identity = {
    displayName: "Ada Guest", email: null, phoneE164: phone,
    searchName: "ada guest", origin: "respondentGranted"};
  store.get(`organizerContacts/${contactId}`)!.phoneE164 = phone;
  store.get(`eventSeatLedgers/${eventId}`)!.occupied = 1;
  store.get(`events/${eventId}`)!.bookedCount = 1;
  store.put(`eventAttendees/${guestId}`, {eventId, clubId: org,
    organizerId: org, source: "hostImport", status: "registered",
    linkedUid: null, phoneE164: phone, externalReference: null,
    displayName: "Imported Ada"});
  store.alias("attendee", guestId, guestKey);
  store.alias("phone", phone, guestKey);
  store.put(`eventSeatReservations/${hash(eventId, guestKey)}`,
    {eventId, canonicalKey: guestKey, identityRevision: 1,
      active: true, revision: 1, reservedAtMillis: 1000,
      releasedAtMillis: null});
  const result = await commit();
  assert.equal(result.seatAlreadyOccupied, true);
  assert.equal(result.attendeeId, guestId);
  assert.equal(result.resultingLedgerRevision, 4);
  assert.equal(store.get(`eventSeatLedgers/${eventId}`)?.occupied, 1);
  assert.equal(store.get(`eventAttendees/${guestId}`)?.source, "hostImport");
  assert.equal(store.get(`eventAttendees/${guestId}`)?.linkedUid, uid);
  assert.equal(store.writes.filter((path) =>
    path.startsWith("eventSeatReservations/")).length, 0);
});

test("retained Catch participation materializes missing display-only roster",
  async () => {
    const {store, commit} = fixture();
    const phone = "+919999999999";
    const uid = "respondent1";
    const catchKey = "uid_key";
    store.get(`organizerFormResponses/${responseId}`)!.identityKind =
      "phoneVerified";
    store.get(`organizerFormResponses/${responseId}`)!.respondentUid = uid;
    store.get(`organizerFormResponses/${responseId}`)!.identity = {
      displayName: "Ada Guest", email: null, phoneE164: phone,
      searchName: "ada guest", origin: "respondentGranted"};
    store.get(`organizerContacts/${contactId}`)!.phoneE164 = phone;
    store.get(`organizerContacts/${contactId}`)!.linkedUid = uid;
    store.get(`organizerContacts/${contactId}`)!.identityState = "verified";
    store.get(`eventSeatLedgers/${eventId}`)!.occupied = 1;
    store.get(`events/${eventId}`)!.bookedCount = 1;
    store.alias("uid", uid, catchKey);
    store.alias("phone", phone, catchKey);
    store.put(`eventSeatVerifiedPhones/${hash(eventId, "verifiedUid", uid)}`,
      {eventId, organizerId: org, uid, phoneE164: phone,
        migrationRevision: 1, state: "current"});
    store.put(`eventSeatReservations/${hash(eventId, catchKey)}`,
      {eventId, canonicalKey: catchKey, identityRevision: 1,
        active: true, revision: 1, reservedAtMillis: 1000,
        releasedAtMillis: null});
    store.put(`eventParticipations/${eventId}_${uid}`, {
      eventId, clubId: org, organizerId: org, uid,
      status: "signedUp", createdAt: ts(1000),
      signedUpAt: ts(1000)});
    store.put(`publicProfiles/${uid}`, {name: "Public Ada"});
    const result = await commit();
    const attendee = store.get(`eventAttendees/${result.attendeeId}`);
    assert.equal(result.seatAlreadyOccupied, true);
    assert.equal(result.resultingLedgerRevision, 3);
    assert.equal(result.attendeeId, eventAttendeeId(eventId,
      `phone:${phone}`));
    assert.equal(attendee?.source, "catchBooking");
    assert.equal(attendee?.displayName, "Public Ada");
    assert.equal(attendee?.phoneE164, null);
    assert.equal(attendee?.email, null);
    assert.equal(store.get(`eventSeatLedgers/${eventId}`)?.occupied, 1);
    const resolved = await store.runTransaction((tx) =>
      new FirestoreSeatIdentityAuthority().resolve({db: store.db(), tx,
        eventId, organizerId: org,
        subject: {kind: "importAttendee", attendeeId: result.attendeeId}}));
    assert.deepEqual(resolved, {key: result.canonicalSeatKey, revision: 1});
    assert.equal(store.writes.filter((path) =>
      path.startsWith("eventSeatReservations/")).length, 0);
  });

test("legacy proposal and malformed source cannot become a second admission",
  async () => {
    const legacy = fixture();
    legacy.store.put(`organizerFormConversionReceipts/${
      formConversionReceiptId(responseId, "eventAttendeeProposal", eventId)}`,
    {organizerId: org, eventId, responseId, status: "completed"});
    await assert.rejects(legacy.commit(), denied);
    assert.deepEqual(legacy.store.writes, []);
    const malformed = fixture();
    malformed.store.get(`organizerFormResponses/${responseId}`)!
      .identity = null;
    await assert.rejects(malformed.commit(), denied);
    assert.deepEqual(malformed.store.writes, []);
  });

test("stored manual payment attestation is copied exactly into receipt",
  async () => {
    const {store, commit} = fixture();
    const offer = store.get(`organizerEventOffers/${offerId}`)!;
    const snapshot = offer.paymentSnapshot as Row;
    offer.paymentSnapshot = {...snapshot, expectedAmountMinor: 500,
      collectionMode: "manualInstructions",
      paymentInstructions: "Pay at the counter"};
    offer.manualPayment = {status: "hostAttestedReceived",
      evidenceReference: "bank-123", evidenceRecordedAtMillis: 1600,
      reviewedByUid: actorUid, reviewedAtMillis: 1800,
      reviewNote: "Checked bank statement", bankReceiptChecked: true,
      attestedAmountMinor: 500, attestedCurrency: "INR",
      attestedEventPaymentRevision: 1,
      attestedEventPaymentHash: "a".repeat(64)};
    const result = await commit();
    const receipt = store.get(`organizerFormAdmissionReceipts/${
      result.receiptId}`);
    assert.deepEqual(receipt?.paymentSnapshot, offer.paymentSnapshot);
    assert.deepEqual(receipt?.manualPayment, offer.manualPayment);
    assert.equal(store.get(`eventSeatLedgers/${eventId}`)?.occupied, 1);
    const attendee = store.get(`eventAttendees/${result.attendeeId}`);
    assert.equal(attendee?.revenueAmountMinor, 500);
    assert.equal(attendee?.revenueCurrency, "INR");
    assert.equal(attendee?.revenueSource, "hostAttested");
    assert.equal(attendee?.revenueAllocation, "perAttendee");
  });

test("attested manual payment lands on a linked imported attendee",
  async () => {
    const {store, commit} = fixture();
    const phone = "+919999999999";
    const uid = "respondent1";
    const guestId = eventAttendeeId(eventId, `phone:${phone}`);
    const guestKey = "guest_key";
    store.get(`organizerFormResponses/${responseId}`)!.identityKind =
      "phoneVerified";
    store.get(`organizerFormResponses/${responseId}`)!.respondentUid = uid;
    store.get(`organizerFormResponses/${responseId}`)!.identity = {
      displayName: "Ada Guest", email: null, phoneE164: phone,
      searchName: "ada guest", origin: "respondentGranted"};
    store.get(`organizerContacts/${contactId}`)!.phoneE164 = phone;
    store.get(`eventSeatLedgers/${eventId}`)!.occupied = 1;
    store.get(`events/${eventId}`)!.bookedCount = 1;
    store.put(`eventAttendees/${guestId}`, {eventId, clubId: org,
      organizerId: org, source: "hostImport", status: "registered",
      linkedUid: null, phoneE164: phone, externalReference: null,
      displayName: "Imported Ada"});
    store.alias("attendee", guestId, guestKey);
    store.alias("phone", phone, guestKey);
    store.put(`eventSeatReservations/${hash(eventId, guestKey)}`,
      {eventId, canonicalKey: guestKey, identityRevision: 1,
        active: true, revision: 1, reservedAtMillis: 1000,
        releasedAtMillis: null});
    const offer = store.get(`organizerEventOffers/${offerId}`)!;
    const snapshot = offer.paymentSnapshot as Row;
    offer.paymentSnapshot = {...snapshot, expectedAmountMinor: 500,
      collectionMode: "manualInstructions",
      paymentInstructions: "Pay at the counter"};
    offer.manualPayment = {status: "hostAttestedReceived",
      evidenceReference: "bank-123", evidenceRecordedAtMillis: 1600,
      reviewedByUid: actorUid, reviewedAtMillis: 1800,
      reviewNote: "Checked bank statement", bankReceiptChecked: true,
      attestedAmountMinor: 500, attestedCurrency: "INR",
      attestedEventPaymentRevision: 1,
      attestedEventPaymentHash: "a".repeat(64)};
    const result = await commit();
    assert.equal(result.attendeeId, guestId);
    const guest = store.get(`eventAttendees/${guestId}`);
    assert.equal(guest?.source, "hostImport");
    assert.equal(guest?.revenueAmountMinor, 500);
    assert.equal(guest?.revenueCurrency, "INR");
    assert.equal(guest?.revenueSource, "hostAttested");
    assert.equal(guest?.revenueAllocation, "perAttendee");
  });

test("admission without an attested payment writes no revenue fact",
  async () => {
    const {store, commit} = fixture();
    const result = await commit();
    const attendee = store.get(`eventAttendees/${result.attendeeId}`);
    assert.equal(attendee?.revenueSource ?? null, null);
    assert.equal(attendee?.revenueAmountMinor ?? null, null);
  });

test("foreign roster and mismatched payment proof leave zero writes",
  async () => {
    const foreign = fixture();
    const attendeeId = eventAttendeeId(eventId,
      `external:form-admission:${responseId}`);
    foreign.store.put(`eventAttendees/${attendeeId}`, {eventId,
      organizerId: "foreign", source: "hostImport", status: "registered"});
    await assert.rejects(foreign.commit(), denied);
    assert.deepEqual(foreign.store.writes, []);
    const payment = fixture();
    const offer = payment.store.get(`organizerEventOffers/${offerId}`)!;
    offer.paymentSnapshot = {...offer.paymentSnapshot as Row,
      expectedAmountMinor: 500,
      collectionMode: "manualInstructions",
      paymentInstructions: "Pay at the counter"};
    offer.manualPayment = {status: "hostAttestedReceived",
      evidenceReference: "bank-123", evidenceRecordedAtMillis: 1600,
      reviewedByUid: actorUid, reviewedAtMillis: 1800,
      reviewNote: "Checked bank statement", bankReceiptChecked: true,
      attestedAmountMinor: 500, attestedCurrency: "INR",
      attestedEventPaymentRevision: 1,
      attestedEventPaymentHash: "b".repeat(64)};
    await assert.rejects(payment.commit());
    assert.deepEqual(payment.store.writes, []);
  });
