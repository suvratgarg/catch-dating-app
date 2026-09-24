import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {localStartMillis, normalizePrivateEventBasics} from "./basics";
import {resolveField, resolveProgressiveSetupDefaults} from "./defaults";
import {
  createPrivateEventSetup,
  ProgressiveSetupDependencies,
  updatePrivateEventBasics,
} from "./service";

type Row = Record<string, unknown>;

class FakeStore {
  private rows = new Map<string, Row>();
  private nextId = 0;

  collection(path: string) {
    return {doc: (id?: string) => ({path: `${path}/${id ?? ++this.nextId}`,
      id: id ?? String(this.nextId)})};
  }

  seed(path: string, value: Row) {
    this.rows.set(path, value);
  }

  read(path: string): Row | undefined {
    return this.rows.get(path);
  }

  async runTransaction<T>(callback: (tx: {
    get: (ref: {path: string}) => Promise<{
      exists: boolean; data: () => Row | undefined;
    }>;
    create: (ref: {path: string}, data: Row) => void;
    update: (ref: {path: string}, data: Row) => void;
  }) => Promise<T>): Promise<T> {
    const writes: Array<() => void> = [];
    const tx = {
      get: async (ref: {path: string}) => ({
        exists: this.rows.has(ref.path),
        data: () => this.rows.get(ref.path),
      }),
      create: (ref: {path: string}, data: Row) => writes.push(() => {
        assert.equal(this.rows.has(ref.path), false);
        this.rows.set(ref.path, data);
      }),
      update: (ref: {path: string}, data: Row) => writes.push(() => {
        const existing = this.rows.get(ref.path);
        assert.ok(existing);
        this.rows.set(ref.path, {...existing, ...data});
      }),
    };
    const result = await callback(tx);
    writes.forEach((write) => write());
    return result;
  }
}

const mumbai = {cityId: "in-mh-mumbai", marketId: "in-mh-mumbai"};
const basics = {
  name: "  Sunday Mixer  ",
  city: {mode: "set" as const, value: mumbai},
  localDate: "2026-10-18",
  localStartTime: "18:30",
  timezone: {mode: "set" as const, value: "Asia/Kolkata"},
};

function setup() {
  const store = new FakeStore();
  store.seed("organizers/org1", {
    hostUserId: "host1", hostUserIds: [], hostProfiles: [],
    ownerUserId: "host1", status: "active", archived: false,
    locationCityId: mumbai.cityId,
    locationMarketId: mumbai.marketId, hostDefaults: {},
  });
  let migrationReady = true;
  let editable = true;
  const deps: ProgressiveSetupDependencies = {
    db: store as unknown as FirebaseFirestore.Firestore,
    privacyMigrationReady: () => migrationReady,
    timestampFromMillis: (millis) => ({millis}) as unknown as
      FirebaseFirestore.Timestamp,
    serverTimestamp: () => ({serverTime: true}) as unknown as
      FirebaseFirestore.FieldValue,
    assertBasicsEditable: async () => {
      if (!editable) {
        throw new HttpsError("failed-precondition", "Commitment exists.");
      }
    },
  };
  return {store, deps,
    setReady: (value: boolean) => migrationReady = value,
    setEditable: (value: boolean) => editable = value};
}

function code(error: unknown): string | undefined {
  return error instanceof HttpsError ? error.code : undefined;
}

test("only valid unambiguous local time resolves to an instant", () => {
  assert.equal(localStartMillis("2026-10-18", "18:30", "Asia/Kolkata"),
    Date.UTC(2026, 9, 18, 13, 0));
  assert.throws(() => localStartMillis("2026-02-30", "18:30",
    "Asia/Kolkata"), (error) => code(error) === "invalid-argument");
  assert.throws(() => localStartMillis("2026-03-08", "02:30",
    "America/New_York"), (error) => code(error) === "invalid-argument");
  assert.throws(() => localStartMillis("2026-11-01", "01:30",
    "America/New_York"), (error) => code(error) === "invalid-argument");
});

test("defaults distinguish inherit, set and optional clear", () => {
  const organizer = {city: mumbai, timezone: "Asia/Kolkata", revision: 3};
  const reviewed = resolveProgressiveSetupDefaults({
    city: {mode: "inherit"}, timezone: {mode: "inherit"}, organizer,
  });
  assert.equal(reviewed.city.source, "organizer");
  assert.equal(reviewed.organizerDefaultsRevision, 3);
  assert.equal(resolveField({mode: "clear"}, "old", true).value, null);
  assert.throws(() => resolveField({mode: "clear"}, "old", false),
    (error) => code(error) === "invalid-argument");
  assert.throws(() => normalizePrivateEventBasics({
    basics: {...basics, city: {mode: "inherit"}}, defaults: organizer,
  }), (error) => code(error) === "failed-precondition");
  assert.throws(() => normalizePrivateEventBasics({
    basics: {...basics, city: {mode: "inherit"},
      reviewedDefaultsHash: "stale"}, defaults: organizer,
  }), (error) => code(error) === "aborted");
});

test("private create is gated and idempotent", async () => {
  const h = setup();
  const command = {organizerId: "org1", requestId: "request-111", basics};
  h.setReady(false);
  await assert.rejects(createPrivateEventSetup({actorUid: "host1",
    command, deps: h.deps}), (error) => code(error) === "failed-precondition");
  h.setReady(true);
  const first = await createPrivateEventSetup({actorUid: "host1",
    command, deps: h.deps});
  const saved = h.store.read(`events/${first.eventId}`);
  assert.ok(saved);
  assert.equal(saved.name, "Sunday Mixer");
  assert.equal(saved.publicationState, "private");
  assert.equal(saved.publicRegistrationEnabled, false);
  for (const key of ["endTime", "meetingLocation", "capacityLimit",
    "priceInPaise", "discoveryMarketId", "eventOrigin"]) {
    assert.equal(Object.hasOwn(saved, key), false, key);
  }
  const replay = await createPrivateEventSetup({actorUid: "host1",
    command, deps: h.deps});
  assert.deepEqual(replay, {...first, replayed: true});
  await assert.rejects(createPrivateEventSetup({actorUid: "host1",
    command: {...command, basics: {...basics, name: "Changed"}},
    deps: h.deps}), (error) => code(error) === "already-exists");
  h.store.seed("organizers/org1", {...h.store.read("organizers/org1"),
    ownerUserId: "other", hostUserId: "other"});
  await assert.rejects(createPrivateEventSetup({actorUid: "host1",
    command, deps: h.deps}), (error) => code(error) === "permission-denied");
});

test("private basics update fences revision and commitments", async () => {
  const h = setup();
  const created = await createPrivateEventSetup({actorUid: "host1",
    command: {organizerId: "org1", requestId: "request-111", basics},
    deps: h.deps});
  const command = {organizerId: "org1", eventId: created.eventId,
    requestId: "request-222", expectedSetupRevision: 1,
    basics: {...basics, name: "New name"}};
  h.setEditable(false);
  await assert.rejects(updatePrivateEventBasics({actorUid: "host1",
    command, deps: h.deps}), (error) => code(error) === "failed-precondition");
  h.setEditable(true);
  const updated = await updatePrivateEventBasics({actorUid: "host1",
    command, deps: h.deps});
  assert.equal(updated.setupRevision, 2);
  assert.equal(h.store.read(`events/${created.eventId}`)?.name, "New name");
  const replay = await updatePrivateEventBasics({actorUid: "host1",
    command, deps: h.deps});
  assert.deepEqual(replay, {...updated, replayed: true});
  await assert.rejects(updatePrivateEventBasics({actorUid: "host1",
    command: {...command, requestId: "request-333"}, deps: h.deps}),
  (error) => code(error) === "aborted");
});
