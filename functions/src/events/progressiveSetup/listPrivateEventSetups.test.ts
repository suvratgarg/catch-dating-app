import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {listPrivateEventSetups} from "./listPrivateEventSetups";

type Row = Record<string, unknown>;
const NOW = Date.parse("2026-10-01T00:00:00Z");

class FakeStore {
  rows = new Map<string, Row>();
  reads: string[] = [];
  queryLimits: number[] = [];
  collection(path: string) {
    return new FakeQuery(this, path);
  }
  async runTransaction<T>(fn: (tx: {
    get: (target: FakeRef | FakeQuery) => Promise<unknown>;
  }) => Promise<T>): Promise<T> {
    return fn({get: async (target) => target instanceof FakeRef ?
      this.read(target.path) : target.get()});
  }
  read(path: string) {
    this.reads.push(path);
    const row = this.rows.get(path);
    return {exists: !!row, id: path.split("/").at(-1),
      data: () => row};
  }
  db() {
    return this as unknown as FirebaseFirestore.Firestore;
  }
}

class FakeRef {
  constructor(readonly store: FakeStore, readonly path: string) {}
}

class FakeQuery {
  constructor(readonly store: FakeStore, readonly path: string,
    readonly filters: Array<[string, string, unknown]> = [],
    readonly after: [number, string] | null = null,
    readonly max = Infinity) {}
  doc(id: string) {
    return new FakeRef(this.store, `${this.path}/${id}`);
  }
  where(field: string, op: string, value: unknown) {
    return new FakeQuery(this.store, this.path,
      [...this.filters, [field, op, value]], this.after, this.max);
  }
  orderBy(_field: unknown, _direction: string) {
    assert.ok(_field);
    assert.equal(_direction, "asc");
    return this;
  }
  startAfter(time: Timestamp, id: string) {
    return new FakeQuery(this.store, this.path, this.filters,
      [time.toMillis(), id], this.max);
  }
  limit(max: number) {
    return new FakeQuery(this.store, this.path, this.filters,
      this.after, max);
  }
  async get() {
    this.store.queryLimits.push(this.max);
    const docs = [...this.store.rows.entries()]
      .filter(([path, row]) => path.startsWith(`${this.path}/`) &&
        this.filters.every(([field, op, expected]) => {
          const actual = row[field];
          return op === "==" ? actual === expected :
            op === ">=" && actual instanceof Timestamp &&
              expected instanceof Timestamp &&
              actual.toMillis() >= expected.toMillis();
        }))
      .sort(([aPath, a], [bPath, b]) =>
        (a.startTime as Timestamp).toMillis() -
        (b.startTime as Timestamp).toMillis() ||
        aPath.localeCompare(bPath))
      .filter(([path, row]) => !this.after ||
        (row.startTime as Timestamp).toMillis() > this.after[0] ||
        ((row.startTime as Timestamp).toMillis() === this.after[0] &&
          path.split("/").at(-1)! > this.after[1]))
      .slice(0, this.max)
      .map(([path, row]) => ({id: path.split("/").at(-1)!,
        data: () => row}));
    return {docs};
  }
}

function event(start: number, patch: Row = {}): Row {
  return {
    clubId: "org1", organizerId: "org1", name: "Mixer",
    startTime: Timestamp.fromMillis(start),
    status: "active", publicationState: "private", setupRevision: 1,
    publicRegistrationEnabled: false,
    eventCityId: "city1", eventMarketId: "market1",
    eventLocalDate: "2026-10-02", eventLocalStartTime: "18:00",
    eventTimezone: "Asia/Kolkata",
    setupDefaults: {
      city: {value: {cityId: "city1", marketId: "market1"},
        source: "event"},
      timezone: {value: "Asia/Kolkata", source: "event"},
      organizerDefaultsRevision: null,
      organizerDefaultsHash: "a".repeat(64),
    },
    bookedCount: 0, checkedInCount: 0, waitlistedCount: 0,
    cancelledAt: null, cancellationReason: null,
    genderCounts: {}, cohortCounts: {}, waitlistedCohortCounts: {},
    ...patch,
  };
}

function setup() {
  const store = new FakeStore();
  store.rows.set("organizers/org1", {
    ownerUserId: "host1", hostUserId: "host1", hostUserIds: [],
    hostProfiles: [], status: "active", archived: false,
  });
  return store;
}

function list(store: FakeStore, command: {
  organizerId: string; limit?: number; cursor?: string;
}, now = NOW, actorUid = "host1") {
  return listPrivateEventSetups({actorUid, command, db: store.db(),
    nowMillis: () => now});
}

test("manager sees only upcoming private whitelisted summaries", async () => {
  const store = setup();
  store.rows.set("events/b", event(NOW + 1000));
  store.rows.set("events/public", event(NOW + 1000,
    {publicationState: "published"}));
  store.rows.set("events/other", event(NOW + 1000,
    {organizerId: "org2", clubId: "org2"}));
  store.rows.set("events/past", event(NOW - 1000));
  const result = await list(store, {organizerId: "org1"});
  assert.deepEqual(result.events.map((row) => row.eventId), ["b"]);
  assert.equal(result.nextCursor, null);
  assert.deepEqual(Object.keys(result.events[0]).sort(), [
    "city", "detailsConfigured", "eventId", "localDate",
    "localStartTime", "name", "setupRevision", "startTimeMillis",
    "status", "timezone",
  ]);
  assert.equal(JSON.stringify(result).includes("organizerDefaultsHash"), false);
  assert.deepEqual(store.queryLimits, [21]);
});

test("ties paginate by document ID with frozen first-page cutoff", async () => {
  const store = setup();
  for (const id of ["a", "b", "c"]) {
    store.rows.set(`events/${id}`, event(NOW + 1000));
  }
  const first = await list(store, {organizerId: "org1", limit: 1});
  const second = await list(store, {organizerId: "org1", limit: 1,
    cursor: first.nextCursor!}, NOW + 500);
  const third = await list(store, {organizerId: "org1", limit: 1,
    cursor: second.nextCursor!}, NOW + 750);
  assert.deepEqual([first, second, third].flatMap((page) =>
    page.events.map((row) => row.eventId)), ["a", "b", "c"]);
  assert.equal(third.nextCursor, null);
  assert.deepEqual(store.queryLimits, [2, 2, 2]);
});

test("permission and cursor scope fail before event scan", async () => {
  const store = setup();
  store.rows.set("events/a", event(NOW + 1000));
  const first = await list(store, {organizerId: "org1", limit: 1});
  const invalid = Buffer.from(JSON.stringify({v: 1, organizerId: "org2",
    asOfMillis: NOW, lastStartTimeMillis: NOW + 1000,
    lastEventId: "a"})).toString("base64url");
  for (const cursor of ["garbage", invalid, first.nextCursor ?? "bad"]) {
    await assert.rejects(list(store, {organizerId: "org1", cursor}),
      (error) => error instanceof HttpsError &&
        error.code === "invalid-argument");
  }
  store.rows.get("organizers/org1")!.ownerUserId = "other";
  store.rows.get("organizers/org1")!.hostUserId = "other";
  const before = store.queryLimits.length;
  await assert.rejects(list(store, {organizerId: "org1"}),
    (error) => error instanceof HttpsError &&
      error.code === "permission-denied");
  assert.equal(store.queryLimits.length, before);
  store.rows.set("deletedUsers/host1", {});
  await assert.rejects(list(store, {organizerId: "org1"}),
    (error) => error instanceof HttpsError &&
      error.code === "failed-precondition");
});

test("malformed matching row rejects instead of disappearing", async () => {
  const store = setup();
  store.rows.set("events/broken", event(NOW + 1000, {name: ""}));
  await assert.rejects(list(store, {organizerId: "org1"}),
    (error) => error instanceof HttpsError &&
      error.code === "failed-precondition");
});
