import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {bootstrapEventSeatLedger} from "./seatMigrationStore";
import {readSeatMigrationWriterFence} from "./seatMigrationPaged";

type Row = Record<string, unknown>;
class Ref {
  constructor(readonly path: string,
    private readonly rows: Map<string, Row>) {}
  async get() {
    const value = this.rows.get(this.path);
    return {exists: value !== undefined, data: () => value};
  }
}
class Query {
  constructor(readonly collectionPath: string,
    private readonly rows: Map<string, Row>,
    readonly filters: Array<[string, unknown]> = [],
    readonly after: string | null = null,
    readonly max = Infinity) {}
  doc(id: string) {
    return new Ref(`${this.collectionPath}/${id}`,
      this.rows);
  }
  where(field: string, op: string, value: unknown) {
    assert.equal(op, "==");
    return new Query(this.collectionPath, this.rows, [...this.filters,
      [field, value]], this.after, this.max);
  }
  orderBy(_field: unknown) {
    void _field;
    return this;
  }
  startAfter(id: string) {
    return new Query(this.collectionPath,
      this.rows, this.filters, id, this.max);
  }
  limit(max: number) {
    return new Query(this.collectionPath,
      this.rows, this.filters, this.after, max);
  }
}
class Store {
  rows = new Map<string, Row>();
  writes: Array<{kind: string; path: string}> = [];
  transactionCount = 0;
  failTransactionNumber: number | null = null;
  beforeTransaction: (() => void) | null = null;
  collection(name: string) {
    return new Query(name, this.rows);
  }
  async runTransaction<T>(fn: (tx: unknown) => Promise<T>): Promise<T> {
    this.transactionCount++;
    this.beforeTransaction?.();
    if (this.transactionCount === this.failTransactionNumber) {
      throw new Error("interrupted transaction");
    }
    const pending: Array<() => void> = [];
    const tx = {
      get: async (source: Ref | Query) => {
        assert.equal(pending.length, 0, "reads must precede writes");
        if (source instanceof Ref) {
          const value = this.rows.get(source.path);
          return {exists: value !== undefined, data: () => value};
        }
        const docs = [...this.rows.entries()]
          .filter(([path, row]) => path.startsWith(
            `${source.collectionPath}/`) &&
            source.filters.every(([field, expected]) =>
              row[field] === expected))
          .sort(([left], [right]) => left.localeCompare(right))
          .filter(([path]) => source.after === null ||
            path.split("/").at(-1)! > source.after!)
          .slice(0, source.max)
          .map(([path, row]) => ({id: path.split("/").at(-1)!,
            data: () => row}));
        return {size: docs.length, docs};
      },
      create: (ref: Ref, value: Row) => pending.push(() => {
        if (this.rows.has(ref.path)) throw new Error("already exists");
        this.rows.set(ref.path, value);
        this.writes.push({kind: "create", path: ref.path});
      }),
      update: (ref: Ref, value: Row) => pending.push(() => {
        assert.equal(this.rows.has(ref.path), true);
        this.rows.set(ref.path, {...this.rows.get(ref.path), ...value});
        this.writes.push({kind: "update", path: ref.path});
      }),
      delete: (ref: Ref) => pending.push(() => {
        this.rows.delete(ref.path);
        this.writes.push({kind: "delete", path: ref.path});
      }),
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
    capacityLimit: 200, bookedCount: 0, checkedInCount: 0,
    waitlistedCount: 0, cancelledAt: null, cancellationReason: null,
    genderCounts: {}, cohortCounts: {}, waitlistedCohortCounts: {}};
}
function attendee(index: number, phone: string | null = null): Row {
  return {eventId: "event1", organizerId: "org1", source: "hostImport",
    status: "registered", linkedUid: null, phoneE164: phone,
    externalReference: `external-${index}`, sourceRowId: `row-${index}`};
}
function setup(count = 1) {
  const store = new Store();
  store.rows.set("events/event1", event());
  for (let index = 0; index < count; index++) {
    store.rows.set(`eventAttendees/att${String(index).padStart(3, "0")}`,
      attendee(index));
  }
  let integrated = true;
  let authCalls = 0;
  const command = {eventId: "event1", organizerId: "org1",
    migrationRevision: 1, asOfMillis: 1000};
  const deps = {db: store.db(), allWritersIntegrated: () => integrated,
    auth: {getUser: async (uid: string) => {
      authCalls++;
      return {uid, phoneNumber: null};
    }}};
  return {store, command, deps,
    authCalls: () => authCalls,
    setIntegrated: (value: boolean) => integrated = value,
    bootstrap: () => bootstrapEventSeatLedger({command, deps})};
}
const denied = (error: unknown) => error instanceof HttpsError &&
  error.code === "failed-precondition";

test("150 guests migrate through bounded durable source/output pages",
  async () => {
    const h = setup(150);
    assert.deepEqual(await h.bootstrap(), {eventId: "event1",
      occupied: 150, migrationRevision: 1});
    assert.equal(h.store.rows.get("eventSeatLedgers/event1")?.state,
      "ready");
    assert.equal(h.store.rows.get("eventSeatMigrationFences/event1")?.state,
      "ready");
    assert.equal(h.store.rows.get("eventSeatMigrationRuns/event1")
      ?.outputCursor, 450);
    assert.ok(h.store.transactionCount > 15);
    assert.equal([...h.store.rows.keys()].filter((path) =>
      path.startsWith("eventSeatMigrationStages/")).length, 0);
    assert.equal(h.store.rows.get("eventSeatMigrationRuns/event1")?.phase,
      "complete");
  });

test("150 imported and 50 Catch participants reconcile one capacity",
  async () => {
    const h = setup(150);
    h.store.rows.set("events/event1", {...event(), bookedCount: 50});
    for (let index = 0; index < 50; index++) {
      h.store.rows.set(`eventParticipations/edge${index}`, {
        eventId: "event1", organizerId: "org1", uid: `uid${index}`,
        status: "signedUp"});
    }
    assert.equal((await h.bootstrap()).occupied, 200);
    assert.equal([...h.store.rows.keys()].filter((path) =>
      path.startsWith("eventSeatReservations/")).length, 200);
    assert.equal(h.authCalls(), 100,
      "Auth is read once for planning and once before activation");
  });

test("legacy unclaimed attendee omits nullable fields without UID inference",
  async () => {
    const h = setup(1);
    h.store.rows.set("eventAttendees/att000", {eventId: "event1",
      organizerId: "org1", source: "hostImport", status: "registered"});
    assert.equal((await h.bootstrap()).occupied, 1);
    assert.equal(h.authCalls(), 0);
  });

test("interrupted page resumes without duplicate reservation", async () => {
  const h = setup(80);
  h.store.failTransactionNumber = 5;
  await assert.rejects(h.bootstrap(), /interrupted transaction/);
  assert.equal(h.store.rows.get("eventSeatLedgers/event1")?.state,
    "unreconciled");
  h.store.failTransactionNumber = null;
  assert.equal((await h.bootstrap()).occupied, 80);
  assert.equal([...h.store.rows.keys()].filter((path) =>
    path.startsWith("eventSeatReservations/")).length, 80);
});

test("interrupted output page resumes from committed cursor", async () => {
  const h = setup(80);
  h.store.failTransactionNumber = 10;
  await assert.rejects(h.bootstrap(), /interrupted transaction/);
  const cursor = h.store.rows.get("eventSeatMigrationRuns/event1")
    ?.outputCursor as number;
  assert.ok(cursor > 0);
  assert.equal(h.store.rows.get("eventSeatLedgers/event1")?.state,
    "unreconciled");
  h.store.failTransactionNumber = null;
  assert.equal((await h.bootstrap()).occupied, 80);
  assert.equal([...h.store.rows.keys()].filter((path) =>
    path.startsWith("eventSeatReservations/")).length, 80);
});

test("cleanup resumes after activation and removes private source copies",
  async () => {
    const h = setup(80);
    h.store.failTransactionNumber = 20;
    await assert.rejects(h.bootstrap(), /interrupted transaction/);
    assert.equal(h.store.rows.get("eventSeatLedgers/event1")?.state,
      "ready");
    assert.equal(h.store.rows.get("eventSeatMigrationRuns/event1")?.phase,
      "cleanup");
    h.store.failTransactionNumber = null;
    // Retention cleanup must still finish if the event later disappears.
    h.store.rows.delete("events/event1");
    assert.equal((await h.bootstrap()).occupied, 80);
    assert.equal([...h.store.rows.keys()].filter((path) =>
      path.startsWith("eventSeatMigrationStages/")).length, 0);
  });

test("duplicate alias across page boundary denies readiness", async () => {
  const h = setup(60);
  h.store.rows.set("eventAttendees/att000", attendee(0, "+919999999999"));
  h.store.rows.set("eventAttendees/att059", attendee(59, "+919999999999"));
  await assert.rejects(h.bootstrap(), denied);
  assert.equal(h.store.rows.get("eventSeatLedgers/event1")?.state,
    "unreconciled");
});

test("lost writer fence denies activation", async () => {
  const h = setup(80);
  h.store.beforeTransaction = () => {
    if (h.store.transactionCount === 10) {
      h.store.rows.set("eventSeatMigrationFences/event1",
        {...h.store.rows.get("eventSeatMigrationFences/event1"),
          state: "released"});
    }
  };
  await assert.rejects(h.bootstrap(), denied);
  assert.equal(h.store.rows.get("eventSeatLedgers/event1")?.state,
    "unreconciled");
});

test("event policy drift leaves staged ledger unavailable", async () => {
  const h = setup(80);
  h.store.beforeTransaction = () => {
    if (h.store.transactionCount === 10) {
      h.store.rows.set("events/event1", {...event(), capacityLimit: 201});
    }
  };
  await assert.rejects(h.bootstrap(), denied);
  assert.equal(h.store.rows.get("eventSeatLedgers/event1")?.state,
    "unreconciled");
});

test("missing final page checkpoint cannot claim complete source", async () => {
  const h = setup(26);
  h.store.beforeTransaction = () => {
    const run = h.store.rows.get("eventSeatMigrationRuns/event1");
    if (run?.phase === "scan" && run.sourceIndex === 2 &&
        run.cursor === null) {
      h.store.rows.set("eventSeatMigrationRuns/event1",
        {...run, phase: "apply", sourceIndex: 2});
    }
  };
  await assert.rejects(h.bootstrap(), denied);
  assert.equal(h.store.rows.get("eventSeatLedgers/event1")?.state,
    "unreconciled");
});

test("deployment gate denies before acquiring fence", async () => {
  const h = setup(150);
  h.setIntegrated(false);
  await assert.rejects(h.bootstrap(), denied);
  assert.equal(h.store.writes.length, 0);
});

test("integrated source writer is blocked while a scan is in progress",
  async () => {
    const h = setup(80);
    h.store.failTransactionNumber = 3;
    await assert.rejects(h.bootstrap(), /interrupted transaction/);
    await assert.rejects(h.store.runTransaction(async (tx) => {
      await readSeatMigrationWriterFence({db: h.store.db(),
        tx: tx as FirebaseFirestore.Transaction, eventId: "event1"});
      throw new Error("source write was unexpectedly allowed");
    }), denied);
    assert.equal(h.store.rows.get("eventSeatLedgers/event1")?.state,
      "unreconciled");
  });
