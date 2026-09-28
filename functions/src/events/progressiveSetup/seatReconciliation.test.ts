import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp, FieldValue} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {Store, migrationTestAttendee, migrationTestEvent} from
  "../seatAuthority/migrationTestFixture";
import {getManagerEventSetupDefaults} from
  "../../organizers/eventSetupDefaults/service";
import {eventSetupDefaultsDependencies} from
  "../../organizers/eventSetupDefaults/dependencies";
import {reconcilePrivateEventSeats, SeatReconciliationDependencies} from
  "./seatReconciliation";
import {UpdatePrivateEventDetailsCommand, updatePrivateEventDetails} from
  "./details";

async function setup() {
  const store = new Store();
  store.rows.set("organizers/org1", {ownerUserId: "host1", hostUserId: "host1",
    hostUserIds: [], hostProfiles: [], status: "active", archived: false,
    hostDefaults: {eventPolicy: {admissionPreset: "openCapacity"}}});
  const event = migrationTestEvent();
  delete event.capacityLimit;
  store.rows.set("events/event1", event);
  store.rows.set("eventAttendees/guest1", migrationTestAttendee(1));
  const db = store.db();
  const defaults = await getManagerEventSetupDefaults({actorUid: "host1",
    organizerId: "org1", deps: eventSetupDefaultsDependencies(db)});
  const deps: SeatReconciliationDependencies = {db,
    auth: {getUser: async (uid) => ({uid})}, nowMillis: () => 100,
    privacyMigrationReady: () => true, freshEventSeatWritersReady: () => true,
    timestampFromMillis: Timestamp.fromMillis,
    serverTimestamp: () => Timestamp.fromMillis(100) as unknown as
      FirebaseFirestore.FieldValue};
  const command: UpdatePrivateEventDetailsCommand = {eventId: "event1",
    organizerId: "org1", requestId: "reconcile-1", expectedSetupRevision: 1,
    reviewedDefaultsHash: defaults.preferencesHash,
    details: {admissionTerms: {capacityLimit: 20, priceInPaise: 0,
      currency: "INR", cancellationPolicyId: "notApplicable"}}};
  const next = (pageBudget = 1, cmd = command, actorUid = "host1") =>
    reconcilePrivateEventSeats({actorUid, command: cmd, deps, pageBudget});
  const finish = async () => {
    for (let i = 0; i < 30; i++) {
      const result = await next();
      if (result.kind === "complete") return result;
    }
    throw new Error("reconciliation did not finish");
  };
  return {store, deps, command, next, finish};
}
const code = (value: unknown, expected: string) =>
  value instanceof HttpsError && value.code === expected;

test("manager resumes missing terms atomically and keeps guests and offers",
  async () => {
    const {store, command, deps, next, finish} = await setup();
    const guest = {...store.rows.get("eventAttendees/guest1")};
    const offer = {eventId: "event1", status: "offered", priceInPaise: 25000};
    store.rows.set("organizerEventOffers/offer1", offer);
    assert.equal((await next()).kind, "progress");
    assert.equal(store.rows.get("events/event1")!.capacityLimit, undefined);
    assert.equal(store.rows.get("events/event1")!.setupRevision, 1);
    const result = await finish();
    assert.equal(result.receipt.setupRevision, 2);
    assert.equal(store.rows.get("events/event1")!.capacityLimit, 20);
    assert.equal(store.rows.get("eventSeatLedgers/event1")!.occupied, 1);
    assert.equal(store.rows.get("eventSeatMigrationRuns/event1")!.phase,
      "complete");
    assert.deepEqual(store.rows.get("eventAttendees/guest1"), guest);
    assert.deepEqual(store.rows.get("organizerEventOffers/offer1"), offer);
    assert.ok(![...store.rows.keys()].some((key) =>
      key.startsWith("eventSeatMigrationStages/") ||
      key.startsWith("eventSeatMigrationPlans/")));
    const writes = store.writes.length;
    assert.equal((await finish()).receipt.replayed, true);
    assert.equal(store.writes.length, writes);
    assert.equal((await updatePrivateEventDetails({actorUid: "host1",
      command, deps})).replayed, true);
  });

test("existing configured terms cannot change during reconciliation",
  async () => {
    const {store, next} = await setup();
    store.rows.get("events/event1")!.capacityLimit = 25;
    await assert.rejects(next(), (error) => code(error, "failed-precondition"));
    assert.equal(store.writes.length, 0);
  });

test("writer gate, manager authority, revision and defaults fail closed",
  async () => {
    const {store, deps, command, next} = await setup();
    deps.freshEventSeatWritersReady = () => false;
    await assert.rejects(next(), (error) => code(error, "failed-precondition"));
    deps.freshEventSeatWritersReady = () => true;
    await assert.rejects(next(1, command, "stranger"),
      (error) => code(error, "permission-denied"));
    await assert.rejects(next(1, {...command, expectedSetupRevision: 2}),
      (error) => code(error, "aborted"));
    await assert.rejects(next(1, {...command,
      reviewedDefaultsHash: "0".repeat(64)}),
    (error) => code(error, "aborted"));
    assert.equal(store.writes.length, 0);
  });

test("progress rechecks deletion and original command on every request",
  async () => {
    const {store, command, next} = await setup();
    await next();
    const count = store.writes.length;
    await assert.rejects(next(1, {...command, requestId: "different-1"}),
      (error) => code(error, "failed-precondition"));
    store.rows.set("deletedUsers/host1", {});
    await assert.rejects(next(), (error) => code(error, "failed-precondition"));
    assert.equal(store.writes.length, count);
  });

test("authority loss between pages blocks the next transaction", async () => {
  const {store, next} = await setup();
  let page = 0;
  store.beforeTransaction = () => {
    if (++page === 4) store.rows.get("organizers/org1")!.archived = true;
  };
  await assert.rejects(next(5), (error) => code(error, "failed-precondition"));
  assert.equal(store.rows.get("events/event1")!.setupRevision, 1);
  assert.equal(store.rows.get("eventSeatLedgers/event1")!.state,
    "unreconciled");
});

test("receipt after activation does not bypass staged source cleanup",
  async () => {
    const {store, next, finish} = await setup();
    for (let i = 0; i < 20; i++) {
      const result = await next();
      if (result.kind === "progress" && result.progress.phase === "cleanup") {
        break;
      }
    }
    assert.equal(store.rows.get("eventSeatMigrationRuns/event1")!.phase,
      "cleanup");
    assert.ok([...store.rows.keys()].some((key) =>
      key.startsWith("eventSetupReceipts/")));
    assert.ok([...store.rows.keys()].some((key) =>
      key.startsWith("eventSeatMigrationStages/")));
    await finish();
    assert.ok(![...store.rows.keys()].some((key) =>
      key.startsWith("eventSeatMigrationStages/")));
  });

test("production timestamp sentinels do not become unvalidated event terms",
  async () => {
    const {deps, finish} = await setup();
    deps.serverTimestamp = FieldValue.serverTimestamp;
    await finish();
  });


test("normal details cannot invalidate a pending guest reconciliation",
  async () => {
    const {store, deps, command, next, finish} = await setup();
    await next();
    await assert.rejects(updatePrivateEventDetails({actorUid: "host1", deps,
      command: {...command, requestId: "description-2",
        details: {description: "Changed elsewhere"}}}),
    (error) => code(error, "failed-precondition"));
    assert.equal(store.rows.get("events/event1")!.setupRevision, 1);
    await finish();
  });

test("explicit reviewed terms survive later organizer-default changes",
  async () => {
    const {store, next, finish} = await setup();
    await next();
    store.rows.get("organizers/org1")!.hostDefaults = {
      eventPolicy: {admissionPreset: "openCapacity"},
      eventSetup: {usualDurationMinutes: 120},
    };
    await finish();
    assert.equal(store.rows.get("events/event1")!.capacityLimit, 20);
  });
