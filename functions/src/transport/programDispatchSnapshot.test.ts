import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {readySeed, deps, now, request}
  from "../shared/testing/programFixtures";
import {FakeFirestore} from "../shared/testing/programFirestore";
import type {TransportTripDocument}
  from "../shared/generated/firestoreAdminTypes";
import {dispatchProgramTripHandler, markProgramTripArrivedHandler,
  voidProgramTripHandler} from "./programDispatch";
import {getProgramHotelInboundHandler, listProgramTripsHandler}
  from "./programTripReads";

const input = {programId: "program-1", pickupPointId: "pp-t3",
  destinationHotelId: "hotel-1", vehicleClassId: "suv",
  plateDisplay: "DL-1T-4471", vendorId: "vendor-1", legIds: ["leg-1"],
  expectedLegRevisions: [{legId: "leg-1", revision: 1}],
  departedAtMillis: now.toMillis() - 60_000,
  clientOperationId: "snapshot-dispatch"};
const dispatch = (db: FakeFirestore) => dispatchProgramTripHandler(
  request(input, "dispatcher-1"), deps(db));
const tripDocument = (db: FakeFirestore, id: string) =>
  db.getDoc(`transportTrips/${id}`) as unknown as TransportTripDocument;
const isPrecondition = (error: unknown) =>
  error instanceof HttpsError && error.code === "failed-precondition";

class TrackingFirestore extends FakeFirestore {
  readonly reads: string[] = [];
  override getDoc(path: string) {
    this.reads.push(path);
    return super.getDoc(path);
  }
}

test("dispatch captures guest and class facts at recording time", async () => {
  const db = new FakeFirestore(readySeed());
  const result = await dispatch(db);
  const trip = tripDocument(db, result.tripId);
  assert.equal(trip.departedAt.toMillis(), input.departedAtMillis);
  assert.equal(trip.dispatchSnapshot?.recordedAt.toMillis(), now.toMillis());
  assert.deepEqual(trip.dispatchSnapshot?.manifest, [{legId: "leg-1",
    guestId: "guest-1", guestDisplayName: "Rohan Sharma", partyId: null,
    passengers: 2, luggageUnits: 3}]);
  assert.equal(trip.dispatchSnapshot?.vehicleClass.label, "Innova / SUV");
  assert.equal(trip.dispatchSnapshot?.vehicleClass.passengerCapacity, 6);
});

for (const patch of [{programId: "foreign"}, {organizerId: "foreign"}]) {
  test(`dispatch retries recheck guest ${Object.keys(patch)[0]}`, async () => {
    const db = new FakeFirestore(readySeed());
    db.beforeCommit = async () => {
      db.beforeCommit = undefined;
      db.updateDoc("programGuests/guest-1", patch);
    };
    await assert.rejects(dispatch(db), isPrecondition);
    assert.equal(db.getDoc("programTravelLegs/leg-1")?.readiness, "ready");
    assert.equal([...db.docs.keys()].some((id) =>
      id.startsWith("transportTrips/")), false);
  });
}

for (const displayName of ["", "x".repeat(141)]) {
  test(`invalid guest name length ${displayName.length} cannot be snapshotted`,
    async () => {
      const db = new FakeFirestore(readySeed());
      db.updateDoc("programGuests/guest-1", {displayName});
      await assert.rejects(dispatch(db), isPrecondition);
    });
}

test("a missing guest cannot be dispatched with only a journey reference",
  async () => {
    const db = new FakeFirestore(readySeed());
    db.docs.delete("programGuests/guest-1");
    await assert.rejects(dispatch(db), isPrecondition);
  });

test("a concurrent name edit is captured at commit", async () => {
  const db = new FakeFirestore(readySeed());
  db.beforeCommit = async () => {
    db.beforeCommit = undefined;
    db.updateDoc("programGuests/guest-1", {displayName: "Corrected name"});
  };
  const result = await dispatch(db);
  assert.equal(tripDocument(db, result.tripId)
    .dispatchSnapshot?.manifest[0].guestDisplayName, "Corrected name");
});

test("saved manifests survive changed or deleted source records and replay",
  async () => {
    const db = new TrackingFirestore(readySeed());
    const result = await dispatch(db);
    const snapshot = tripDocument(db, result.tripId).dispatchSnapshot;
    db.docs.delete("programGuests/guest-1");
    db.docs.delete("programTravelLegs/leg-1");
    db.updateDoc("organizerPrograms/program-1", {transportSettings: {
      ...(db.getDoc("organizerPrograms/program-1")!
        .transportSettings as object),
      vehicleClasses: [],
    }});
    db.reads.length = 0;
    const ledger = await listProgramTripsHandler(request({
      programId: "program-1"}, "manager-1"), deps(db));
    const hotel = await getProgramHotelInboundHandler(request({
      programId: "program-1", hotelId: "hotel-1"}, "hotelier-1"), deps(db));
    for (const row of [ledger.trips[0], hotel.trips[0]]) {
      assert.deepEqual(row.guestNames, ["Rohan Sharma"]);
      assert.equal(row.manifestSource, "dispatchSnapshot");
      assert.equal(row.vehicleClassLabel, "Innova / SUV");
    }
    assert.ok(!db.reads.includes("programGuests/guest-1"));
    assert.ok(!db.reads.includes("programTravelLegs/leg-1"));
    const replay = await dispatch(db);
    assert.equal(replay.tripId, result.tripId);
    assert.equal(replay.alreadyApplied, true);
    assert.deepEqual(tripDocument(db, result.tripId).dispatchSnapshot,
      snapshot);
  });

for (const action of [markProgramTripArrivedHandler, voidProgramTripHandler]) {
  test(`${action.name} preserves the original dispatch snapshot`, async () => {
    const db = new FakeFirestore(readySeed());
    const created = await dispatch(db);
    const before = tripDocument(db, created.tripId).dispatchSnapshot;
    await action(request({programId: "program-1", tripId: created.tripId,
      expectedRevision: 1, clientOperationId: "complete-trip",
      reason: "Wrong dispatch"}, "dispatcher-1"), deps(db));
    assert.deepEqual(tripDocument(db, created.tripId).dispatchSnapshot, before);
  });
}

test("legacy names remain explicitly current and never invent a class label",
  async () => {
    const db = new FakeFirestore(readySeed());
    const result = await dispatch(db);
    const legacy = {...db.getDoc(`transportTrips/${result.tripId}`)!};
    delete legacy.dispatchSnapshot;
    db.setDoc(`transportTrips/${result.tripId}`, legacy);
    db.updateDoc("programGuests/guest-1", {displayName: "Current name"});
    const ledger = await listProgramTripsHandler(request({
      programId: "program-1"}, "manager-1"), deps(db));
    assert.equal(ledger.trips[0].manifestSource, "currentRecords");
    assert.deepEqual(ledger.trips[0].guestNames, ["Current name"]);
    assert.equal(ledger.trips[0].vehicleClassLabel, null);
  });

for (const corruption of ["null", "empty", "wrong-leg", "count", "class"]) {
  test(`an invalid ${corruption} snapshot cannot fall back to current names`,
    async () => {
      const db = new FakeFirestore(readySeed());
      const result = await dispatch(db);
      const snapshot = tripDocument(db, result.tripId).dispatchSnapshot!;
      const broken = corruption === "null" ? null : {
        ...snapshot,
        vehicleClass: corruption === "class" ?
          {...snapshot.vehicleClass, id: "other"} : snapshot.vehicleClass,
        manifest: corruption === "empty" ? [] : snapshot.manifest.map((row) =>
          ({...row, legId: corruption === "wrong-leg" ? "other" : row.legId,
            passengers: corruption === "count" ? 10 : row.passengers})),
      };
      db.updateDoc(`transportTrips/${result.tripId}`,
        {dispatchSnapshot: broken});
      await assert.rejects(listProgramTripsHandler(request({
        programId: "program-1"}, "manager-1"), deps(db)), isPrecondition);
    });
}
