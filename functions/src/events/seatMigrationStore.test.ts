import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {bootstrapEventSeatLedger, SEAT_BOOTSTRAP_SOURCE_LIMIT} from
  "./seatMigrationStore";
import {seatVerifiedPhoneProofId} from "./seatIdentityAuthority";
import {formConversionReceiptId} from
  "../organizers/organizerFormAdmissionIdentity";
import {organizerContactOriginId} from
  "../shared/organizerContactOrigins";

type Row = Record<string, unknown>;

class Ref {
  constructor(readonly path: string) {}
}
class Query {
  constructor(readonly collectionPath: string,
    readonly filters: Array<[string, unknown]> = [],
    readonly max = Infinity) {}
  doc(id: string) {
    return new Ref(`${this.collectionPath}/${id}`);
  }
  where(field: string, operator: string, value: unknown) {
    assert.equal(operator, "==");
    return new Query(this.collectionPath, [...this.filters,
      [field, value]], this.max);
  }
  limit(max: number) {
    return new Query(this.collectionPath, this.filters, max);
  }
}
class Store {
  rows = new Map<string, Row>();
  writes: Array<{kind: string; path: string}> = [];
  reads: string[] = [];
  transactionCount = 0;
  failTransactionNumber: number | null = null;
  collection(name: string) {
    return new Query(name);
  }
  async runTransaction<T>(fn: (tx: unknown) => Promise<T>): Promise<T> {
    this.transactionCount++;
    if (this.transactionCount === this.failTransactionNumber) {
      throw new Error("interrupted after staging");
    }
    const pending: Array<() => void> = [];
    const tx = {
      get: async (source: Ref | Query) => {
        assert.equal(pending.length, 0, "all reads must precede writes");
        if (source instanceof Ref) {
          this.reads.push(source.path);
          const value = this.rows.get(source.path);
          return {exists: value !== undefined, data: () => value};
        }
        this.reads.push(`${source.collectionPath}:query`);
        const docs = [...this.rows.entries()]
          .filter(([path, row]) => path.startsWith(
            `${source.collectionPath}/`) &&
            source.filters.every(([field, expected]) =>
              row[field] === expected))
          .slice(0, source.max)
          .map(([path, row]) => ({id: path.split("/").at(-1)!,
            data: () => row}));
        return {size: docs.length, docs};
      },
      create: (ref: Ref, value: Row) => {
        pending.push(() => {
          if (this.rows.has(ref.path)) throw new Error("already exists");
          this.rows.set(ref.path, value);
          this.writes.push({kind: "create", path: ref.path});
        });
      },
      update: (ref: Ref, value: Row) => {
        pending.push(() => {
          assert.equal(this.rows.has(ref.path), true);
          this.rows.set(ref.path, {...this.rows.get(ref.path), ...value});
          this.writes.push({kind: "update", path: ref.path});
        });
      },
      set: (ref: Ref, value: Row) => {
        pending.push(() => {
          this.rows.set(ref.path, value);
          this.writes.push({kind: "set", path: ref.path});
        });
      },
      delete: (ref: Ref) => {
        pending.push(() => {
          this.rows.delete(ref.path);
          this.writes.push({kind: "delete", path: ref.path});
        });
      },
    };
    const result = await fn(tx);
    pending.forEach((write) => write());
    return result;
  }
  db() {
    return this as unknown as FirebaseFirestore.Firestore;
  }
}

function event(): Row {
  return {clubId: "org1", organizerId: "org1", name: "Event",
    startTime: Timestamp.fromMillis(100000), status: "active",
    publicationState: "private", setupRevision: 1,
    publicRegistrationEnabled: false, eventCityId: "city1",
    eventMarketId: "market1", eventLocalDate: "2026-10-21",
    eventLocalStartTime: "18:00", eventTimezone: "Asia/Kolkata",
    setupDefaults: {city: {value: {cityId: "city1", marketId: "market1"},
      source: "event"}, timezone: {value: "Asia/Kolkata", source: "event"},
    organizerDefaultsRevision: null, organizerDefaultsHash: "a".repeat(64)},
    capacityLimit: 2, bookedCount: 0, checkedInCount: 0,
    waitlistedCount: 0, cancelledAt: null, cancellationReason: null,
    genderCounts: {}, cohortCounts: {}, waitlistedCohortCounts: {}};
}

function attendee(id = "att1"): Row {
  return {eventId: "event1", organizerId: "org1", source: "hostImport",
    status: "registered", linkedUid: null, phoneE164: null,
    externalReference: `external-${id}`, sourceRowId: id};
}

function setup() {
  const store = new Store();
  store.rows.set("events/event1", event());
  store.rows.set("eventAttendees/att1", attendee());
  let integrated = true;
  let currentPhone: string | null = null;
  const command = {eventId: "event1", organizerId: "org1",
    migrationRevision: 1, asOfMillis: 1000};
  const deps = {db: store.db(), allWritersIntegrated: () => integrated,
    auth: {getUser: async (uid: string) => ({uid,
      phoneNumber: currentPhone})}};
  return {store, command, deps,
    setIntegrated: (value: boolean) => integrated = value,
    setAuthPhone: (value: string | null) => currentPhone = value,
    bootstrap: () => bootstrapEventSeatLedger({command, deps})};
}

const denied = (error: unknown) => error instanceof HttpsError &&
  error.code === "failed-precondition";

test("complete transaction installs exact ledger, reservation and aliases",
  async () => {
    const h = setup();
    assert.deepEqual(await h.bootstrap(), {eventId: "event1", occupied: 1,
      migrationRevision: 1});
    assert.deepEqual(h.store.writes.map((row) => row.path.split("/")[0]),
      ["eventSeatLedgers", "eventSeatReservations",
        "eventSeatIdentityAliases", "eventSeatIdentityAliases",
        "eventSeatLedgers"]);
    assert.equal(h.store.rows.get("eventSeatLedgers/event1")?.state, "ready");
    assert.ok(h.store.reads.includes("events/event1"));
    assert.ok(h.store.reads.includes("eventAttendees:query"));
  });

test("missing integration gate and second bootstrap never stage writes",
  async () => {
    const h = setup();
    h.setIntegrated(false);
    await assert.rejects(h.bootstrap(), denied);
    assert.deepEqual(h.store.writes, []);
    h.setIntegrated(true);
    await h.bootstrap();
    const count = h.store.writes.length;
    await assert.rejects(h.bootstrap(), denied);
    assert.equal(h.store.writes.length, count);
  });

test("current Auth source becomes a transaction proof", async () => {
  const h = setup();
  h.store.rows.set("events/event1", {...event(), bookedCount: 1});
  h.store.rows.set("eventParticipations/edge1", {eventId: "event1",
    organizerId: "org1", uid: "user1", status: "signedUp"});
  const proofId = seatVerifiedPhoneProofId("event1", "user1");
  const result = await h.bootstrap();
  assert.equal(result.occupied, 2);
  assert.deepEqual(h.store.rows.get(`eventSeatVerifiedPhones/${proofId}`),
    {eventId: "event1", organizerId: "org1", uid: "user1",
      phoneE164: null, migrationRevision: 1, state: "current"});
  assert.ok(h.store.writes.some((row) =>
    row.path === `eventSeatVerifiedPhones/${proofId}`));
});

test("invalid Admin Auth phone cannot create a proof", async () => {
  const h = setup();
  h.store.rows.set("events/event1", {...event(), bookedCount: 1});
  h.store.rows.set("eventParticipations/edge1", {eventId: "event1",
    organizerId: "org1", uid: "user1", status: "signedUp"});
  h.setAuthPhone("invalid");
  await assert.rejects(h.bootstrap(), denied);
  assert.deepEqual(h.store.writes, []);
});

test("Auth change during bootstrap leaves ledger unusable", async () => {
  const h = setup();
  h.store.rows.set("events/event1", {...event(), bookedCount: 1});
  h.store.rows.set("eventParticipations/edge1", {eventId: "event1",
    organizerId: "org1", uid: "user1", status: "signedUp"});
  let calls = 0;
  h.deps.auth.getUser = async (uid) => ({uid,
    phoneNumber: ++calls === 1 ? "+919999999999" : "+919999999998"});
  await assert.rejects(h.bootstrap(), denied);
  assert.equal(h.store.rows.get("eventSeatLedgers/event1")?.state,
    "unreconciled");
  assert.ok(h.store.writes.every((row) => row.kind === "create"));
});

test("policy change before readiness leaves ledger unusable", async () => {
  const h = setup();
  h.store.rows.set("events/event1", {...event(), bookedCount: 1});
  h.store.rows.set("eventParticipations/edge1", {eventId: "event1",
    organizerId: "org1", uid: "user1", status: "signedUp"});
  let calls = 0;
  h.deps.auth.getUser = async (uid) => {
    if (++calls === 2) {
      h.store.rows.set("events/event1", {...event(), bookedCount: 1,
        capacityLimit: 3});
    }
    return {uid, phoneNumber: null};
  };
  await assert.rejects(h.bootstrap(), denied);
  assert.equal(h.store.rows.get("eventSeatLedgers/event1")?.state,
    "unreconciled");
});

test("interrupted stage resumes only after a fresh source review", async () => {
  const h = setup();
  h.store.failTransactionNumber = 2;
  await assert.rejects(h.bootstrap(), /interrupted/);
  assert.equal(h.store.rows.get("eventSeatLedgers/event1")?.state,
    "unreconciled");
  h.store.failTransactionNumber = null;
  const result = await h.bootstrap();
  assert.equal(result.occupied, 1);
  assert.equal(h.store.rows.get("eventSeatLedgers/event1")?.state, "ready");
  assert.equal(h.store.rows.get("eventSeatLedgers/event1")?.revision, 2);
  assert.equal(h.store.writes.filter((write) =>
    write.path.startsWith("eventSeatReservations/")).length, 1);
});

test("Auth drift is reconciled from current Auth, not staged phone proof",
  async () => {
    const h = setup();
    h.store.rows.set("events/event1", {...event(), bookedCount: 1});
    h.store.rows.set("eventParticipations/edge1", {eventId: "event1",
      organizerId: "org1", uid: "user1", status: "signedUp"});
    let calls = 0;
    h.deps.auth.getUser = async (uid) => ({uid,
      phoneNumber: ++calls === 1 ? "+919999999999" : "+919999999998"});
    await assert.rejects(h.bootstrap(), denied);
    const oldProof = h.store.rows.get(`eventSeatVerifiedPhones/${
      seatVerifiedPhoneProofId("event1", "user1")}`);
    assert.equal(oldProof?.phoneE164, "+919999999999");
    const result = await h.bootstrap();
    assert.equal(result.occupied, 2);
    assert.equal(h.store.rows.get("eventSeatLedgers/event1")?.state,
      "ready");
    assert.equal(h.store.rows.get(`eventSeatVerifiedPhones/${
      seatVerifiedPhoneProofId("event1", "user1")}`)?.phoneE164,
    "+919999999998");
    assert.ok(h.store.writes.some((write) =>
      write.kind === "delete" &&
      write.path.startsWith("eventSeatIdentityAliases/")));
  });

test("event policy drift can be reconciled before any seat is ready",
  async () => {
    const h = setup();
    h.store.failTransactionNumber = 2;
    await assert.rejects(h.bootstrap(), /interrupted/);
    h.store.rows.set("events/event1", {...event(), capacityLimit: 3});
    h.store.failTransactionNumber = null;
    await h.bootstrap();
    const ledger = h.store.rows.get("eventSeatLedgers/event1");
    assert.equal(ledger?.capacity, 3);
    assert.equal(ledger?.capacityRevision, 2);
    assert.equal(ledger?.state, "ready");
  });

test("foreign staged evidence denies recovery without replacing it",
  async () => {
    const h = setup();
    h.store.failTransactionNumber = 2;
    await assert.rejects(h.bootstrap(), /interrupted/);
    const alias = [...h.store.rows.keys()].find((key) =>
      key.startsWith("eventSeatIdentityAliases/"))!;
    h.store.rows.get(alias)!.organizerId = "other";
    const writes = h.store.writes.length;
    h.store.failTransactionNumber = null;
    await assert.rejects(h.bootstrap(), denied);
    assert.equal(h.store.writes.length, writes);
    assert.equal(h.store.rows.get("eventSeatLedgers/event1")?.state,
      "unreconciled");
  });

test("unrelated organizer CRM history does not consume event limit",
  async () => {
    const h = setup();
    for (let index = 0; index < 100; index++) {
      h.store.rows.set(`organizerContactOrigins/foreign${index}`,
        {organizerId: "org1", eventId: "anotherEvent"});
      h.store.rows.set(`organizerFormConversionReceipts/foreign${index}`,
        {organizerId: "org1", kind: "eventAttendeeProposal"});
    }
    await h.bootstrap();
    assert.equal(h.store.rows.get("eventSeatLedgers/event1")?.state,
      "ready");
    assert.equal(h.store.reads.includes(
      "organizerFormConversionReceipts:query"), false);
  });

test("form-linked attendee reads exact receipt and null-event CRM origin",
  async () => {
    const h = setup();
    h.store.rows.set("eventAttendees/att1", {...attendee(),
      source: "hostManual", externalReference: "response1",
      sourceRowId: "response1"});
    const receiptId = formConversionReceiptId("response1",
      "eventAttendeeProposal", "event1");
    h.store.rows.set(`organizerFormConversionReceipts/${receiptId}`, {
      organizerId: "org1", kind: "eventAttendeeProposal",
      formId: "form1", responseId: "response1", status: "completed",
      fields: [{destinationField: "eventId", value: "event1"}],
    });
    const originId = organizerContactOriginId({organizerId: "org1",
      sourceKind: "hostForm", sourceEntityKind: "hostFormResponse",
      sourceEntityId: "response1"});
    h.store.rows.set(`organizerContactOrigins/${originId}`, {
      organizerId: "org1", eventId: null, sourceKind: "hostForm",
      sourceEntityKind: "hostFormResponse", sourceEntityId: "response1",
      responseId: "response1", formId: "form1",
      currentContactId: "contact1", originContactId: "contact1",
    });
    h.store.rows.set("organizerContacts/contact1", {organizerId: "org1",
      linkedUid: null, identityState: "unlinked", deletedAt: null,
      hiddenAt: null, mergedIntoContactId: null,
      ambiguousCandidateContactIds: []});
    await h.bootstrap();
    assert.ok(h.store.reads.includes(
      `organizerFormConversionReceipts/${receiptId}`));
    assert.ok(h.store.reads.includes(
      `organizerContactOrigins/${originId}`));
    assert.equal(h.store.reads.includes(
      "organizerFormConversionReceipts:query"), false);
  });

test("true event-specific origin oversize denies before staging", async () => {
  const h = setup();
  for (let index = 0; index <= SEAT_BOOTSTRAP_SOURCE_LIMIT; index++) {
    h.store.rows.set(`organizerContactOrigins/eventOrigin${index}`,
      {organizerId: "org1", eventId: "event1"});
  }
  await assert.rejects(h.bootstrap(), denied);
  assert.deepEqual(h.store.writes, []);
});

test("concurrent bootstraps cannot both create the same ledger", async () => {
  const h = setup();
  const outcomes = await Promise.allSettled([h.bootstrap(), h.bootstrap()]);
  assert.equal(outcomes.filter((row) => row.status === "fulfilled").length, 1);
  assert.equal(h.store.rows.get("eventSeatLedgers/event1")?.occupied, 1);
});

test("truncated source query and mixed identity deny without writes",
  async () => {
    const tooLarge = setup();
    for (let index = 2; index <= SEAT_BOOTSTRAP_SOURCE_LIMIT + 1;
      index += 1) {
      tooLarge.store.rows.set(`eventAttendees/att${index}`,
        attendee(`att${index}`));
    }
    await assert.rejects(tooLarge.bootstrap(), denied);
    assert.deepEqual(tooLarge.store.writes, []);
    const mixed = setup();
    mixed.store.rows.set("eventAttendees/att1", {...attendee(),
      linkedUid: "uid1", phoneE164: "+919999999999"});
    await assert.rejects(mixed.bootstrap(), denied);
    assert.deepEqual(mixed.store.writes, []);
  });

test("malformed or foreign event denies before alias writes", async () => {
  for (const patch of [{clubId: "other"}, {capacityLimit: undefined},
    {bookedCount: 1}]) {
    const h = setup();
    h.store.rows.set("events/event1", {...event(), ...patch});
    await assert.rejects(h.bootstrap(), denied);
    assert.deepEqual(h.store.writes, []);
  }
});
