import assert from "node:assert/strict";
import test from "node:test";
import {createHash} from "crypto";
import {Timestamp} from "firebase-admin/firestore";
import {FirestoreSeatIdentityAuthority, seatIdentityAliasId,
  seatVerifiedPhoneProofId, SeatIdentityAuthorityError,
  linkVerifiedUidToGuestSeat} from
  "./seatIdentityAuthority";
import {eventAttendeeId} from "./eventAttendees";

type Row = Record<string, unknown>;
type Subject = Parameters<FirestoreSeatIdentityAuthority["resolve"]>[0][
  "subject"];
const eventId = "event1";
const organizerId = "org1";
const phone = "+919999999999";

function hash(kind: string, value: string) {
  return createHash("sha256").update([kind, value].join("\u001f"))
    .digest("hex");
}

class FakeStore {
  rows = new Map<string, Row>();
  reads: string[] = [];
  writes: string[] = [];
  collection(name: string) {
    return {doc: (id: string) => ({path: `${name}/${id}`})};
  }
  tx() {
    return {get: async (ref: {path: string}) => {
      this.reads.push(ref.path);
      return {data: () => this.rows.get(ref.path)};
    }} as unknown as FirebaseFirestore.Transaction;
  }
  writeTx() {
    const pending: Array<() => void> = [];
    const tx = {
      get: async (ref: {path: string}) => {
        assert.equal(pending.length, 0, "all reads precede writes");
        this.reads.push(ref.path);
        const value = this.rows.get(ref.path);
        return {exists: value !== undefined, data: () => value};
      },
      create: (ref: {path: string}, value: Row) => pending.push(() => {
        assert.equal(this.rows.has(ref.path), false);
        this.rows.set(ref.path, value);
        this.writes.push(ref.path);
      }),
      update: (ref: {path: string}, value: Row) => pending.push(() => {
        assert.equal(this.rows.has(ref.path), true);
        this.rows.set(ref.path, {...this.rows.get(ref.path), ...value});
        this.writes.push(ref.path);
      }),
    } as unknown as FirebaseFirestore.Transaction;
    return {tx, commit: () => pending.forEach((write) => write())};
  }
  db() {
    return this as unknown as FirebaseFirestore.Firestore;
  }
  alias(kind: "uid" | "phone" | "attendee" | "external" |
    "contactOrigin" | "contact", value: string, key = "person1",
  revision = 1, migrationRevision = 1) {
    this.rows.set(`eventSeatIdentityAliases/${seatIdentityAliasId(
      eventId, kind, value)}`, {
      eventId, organizerId, kind, valueHash: hash(kind, value),
      canonicalKey: key, identityRevision: revision, migrationRevision,
      state: "ready",
    });
  }
  ready() {
    this.rows.set(`eventSeatLedgers/${eventId}`, {
      eventId, state: "ready", migrationRevision: 1,
    });
  }
  proof(uid = "uid1") {
    this.rows.set(`eventSeatVerifiedPhones/${seatVerifiedPhoneProofId(
      eventId, uid)}`, {
      eventId, organizerId, uid, phoneE164: phone,
      migrationRevision: 1, state: "current",
    });
  }
  resolve(subject: Subject, scope = {eventId, organizerId}) {
    return new FirestoreSeatIdentityAuthority().resolve({db: this.db(),
      tx: this.tx(), ...scope, subject});
  }
}

function unavailable(error: unknown) {
  return error instanceof SeatIdentityAuthorityError &&
    error.code === "unavailable";
}

test("reviewed import and verified UID converge on one seat", async () => {
  const store = new FakeStore();
  store.ready();
  store.proof();
  store.rows.set("eventAttendees/att1", {eventId, organizerId,
    source: "hostImport", status: "registered", linkedUid: null,
    phoneE164: phone, externalReference: "ORDER-1"});
  for (const [kind, value] of [
    ["uid", "uid1"], ["phone", phone], ["attendee", "att1"],
    ["external", "order-1"],
  ] as const) store.alias(kind, value);
  const imported = await store.resolve({kind: "importAttendee",
    attendeeId: "att1"});
  const verified = await store.resolve({kind: "verifiedUid", uid: "uid1"});
  assert.deepEqual(imported, {key: "person1", revision: 1});
  assert.deepEqual(verified, imported);
  assert.ok(store.reads.every((path) => path.startsWith("eventSeat") ||
    path === "eventAttendees/att1"));
});

test("conflicting aliases and unreviewed phone cannot merge seats",
  async () => {
    const store = new FakeStore();
    store.ready();
    store.proof();
    store.alias("uid", "uid1", "person1");
    store.alias("phone", phone, "person2");
    await assert.rejects(store.resolve({kind: "verifiedUid", uid: "uid1"}),
      unavailable);
    store.rows.delete(`eventSeatIdentityAliases/${seatIdentityAliasId(
      eventId, "phone", phone)}`);
    await assert.rejects(store.resolve({kind: "verifiedUid", uid: "uid1"}),
      unavailable);
  });

test("CRM origin follows current survivor only after alias reconciliation",
  async () => {
    const store = new FakeStore();
    store.ready();
    store.rows.set("organizerContactOrigins/origin1", {
      organizerId, eventId: null, sourceKind: "hostForm",
      sourceEntityKind: "hostFormResponse", sourceEntityId: "response1",
      responseId: "response1", originContactId: "oldContact",
      currentContactId: "newContact",
    });
    store.rows.set("organizerContacts/newContact", {
      organizerId, deletedAt: null, hiddenAt: null,
      mergedIntoContactId: null, identityState: "unlinked",
      ambiguousCandidateContactIds: [], linkedUid: null,
    });
    store.alias("contactOrigin", "origin1", "oldSeat", 1);
    store.alias("contact", "newContact", "newSeat", 2);
    const subject = {kind: "crmOrigin" as const, originId: "origin1",
      responseId: "response1"};
    await assert.rejects(store.resolve(subject), unavailable);
    store.alias("contactOrigin", "origin1", "newSeat", 2);
    assert.deepEqual(await store.resolve(subject),
      {key: "newSeat", revision: 2});
    store.rows.get("organizerContacts/newContact")!
      .mergedIntoContactId = "thirdContact";
    await assert.rejects(store.resolve(subject), unavailable);
  });

test("foreign or stale records reject within current transaction", async () => {
  const store = new FakeStore();
  store.ready();
  store.proof();
  store.alias("uid", "uid1");
  store.alias("phone", phone);
  const subject = {kind: "verifiedUid" as const, uid: "uid1"};
  await assert.rejects(store.resolve(subject,
    {eventId, organizerId: "foreign"}), unavailable);
  store.rows.get(`eventSeatVerifiedPhones/${seatVerifiedPhoneProofId(
    eventId, "uid1")}`)!.organizerId = "foreign";
  await assert.rejects(store.resolve(subject), unavailable);
  store.rows.get(`eventSeatVerifiedPhones/${seatVerifiedPhoneProofId(
    eventId, "uid1")}`)!.organizerId = organizerId;
  store.rows.get(`eventSeatIdentityAliases/${seatIdentityAliasId(
    eventId, "uid", "uid1")}`)!.migrationRevision = 0;
  await assert.rejects(store.resolve(subject), unavailable);
});

test("missing or unreconciled migration fails closed", async () => {
  const store = new FakeStore();
  await assert.rejects(store.resolve({kind: "verifiedUid", uid: "uid1"}),
    unavailable);
  store.ready();
  store.rows.get(`eventSeatLedgers/${eventId}`)!.state = "unreconciled";
  await assert.rejects(store.resolve({kind: "verifiedUid", uid: "uid1"}),
    unavailable);
});

function guestSeatStore(options: {externalReference?: string} = {}) {
  const store = new FakeStore();
  const attendeeId = options.externalReference ? eventAttendeeId(eventId,
    `external:${options.externalReference.toLowerCase()}`) :
    eventAttendeeId(eventId, `phone:${phone}`);
  const key = "guestSeat";
  store.rows.set(`events/${eventId}`, {clubId: organizerId,
    organizerId, status: "active"});
  store.rows.set(`eventSeatLedgers/${eventId}`, {eventId, state: "ready",
    migrationRevision: 1, revision: 3});
  store.rows.set(`eventAttendees/${attendeeId}`, {eventId, organizerId,
    source: "hostImport", status: "registered", linkedUid: null,
    phoneE164: phone,
    externalReference: options.externalReference ?? null});
  store.alias("attendee", attendeeId, key);
  store.alias("phone", phone, key);
  if (options.externalReference) {
    store.alias("external", options.externalReference.toLowerCase(), key);
  }
  store.rows.set(`eventSeatReservations/${hash(eventId, key)}`, {
    eventId, canonicalKey: key, active: true, identityRevision: 1});
  const link = async (uid = "uid1", tokenPhone = phone) => {
    const prepared = store.writeTx();
    const result = await linkVerifiedUidToGuestSeat({db: store.db(),
      tx: prepared.tx, eventId, organizerId, attendeeId, uid,
      authTokenPhoneNumber: tokenPhone, now: Timestamp.fromMillis(1000)});
    prepared.commit();
    return result;
  };
  return {store, attendeeId, key, link};
}

test("verified phone links an imported guest without reserving another seat",
  async () => {
    const h = guestSeatStore();
    assert.deepEqual(await h.link(), {canonicalKey: h.key,
      ledgerRevision: 4, replayed: false});
    assert.equal(h.store.rows.get(`eventAttendees/${h.attendeeId}`)
      ?.linkedUid, "uid1");
    assert.equal(h.store.rows.get(`eventSeatLedgers/${eventId}`)?.revision, 4);
    assert.equal(h.store.writes.filter((path) => path.startsWith(
      "eventSeatReservations/")).length, 0);
    assert.deepEqual(await h.link(), {canonicalKey: h.key,
      ledgerRevision: 4, replayed: true});
    assert.deepEqual(await h.store.resolve({kind: "verifiedUid",
      uid: "uid1"}), {key: h.key, revision: 1});
  });

test("different token phone, duplicate UID seat or missing alias denies",
  async () => {
    const wrongPhone = guestSeatStore();
    await assert.rejects(wrongPhone.link("uid1", "+919999999998"),
      unavailable);
    assert.deepEqual(wrongPhone.store.writes, []);
    const existingSeat = guestSeatStore();
    existingSeat.store.alias("uid", "uid1", "anotherSeat");
    await assert.rejects(existingSeat.link(), unavailable);
    assert.deepEqual(existingSeat.store.writes, []);
    const existingProof = guestSeatStore();
    existingProof.store.proof();
    await assert.rejects(existingProof.link(), unavailable);
    assert.deepEqual(existingProof.store.writes, []);
    const missingAlias = guestSeatStore();
    missingAlias.store.rows.delete(`eventSeatIdentityAliases/${
      seatIdentityAliasId(eventId, "phone", phone)}`);
    await assert.rejects(missingAlias.link(), unavailable);
    assert.deepEqual(missingAlias.store.writes, []);
  });

test("verified phone links external-reference import by its actual ID",
  async () => {
    const h = guestSeatStore({externalReference: "ORDER-42"});
    assert.deepEqual(await h.link(), {canonicalKey: h.key,
      ledgerRevision: 4, replayed: false});
    assert.equal(h.store.rows.get(`eventAttendees/${h.attendeeId}`)
      ?.linkedUid, "uid1");
    assert.equal(h.store.writes.filter((path) => path.startsWith(
      "eventSeatReservations/")).length, 0);
    const wrong = guestSeatStore({externalReference: "ORDER-42"});
    wrong.store.alias("external", "order-42", "otherSeat");
    await assert.rejects(wrong.link(), unavailable);
    assert.deepEqual(wrong.store.writes, []);
  });
