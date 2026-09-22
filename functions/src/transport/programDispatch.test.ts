import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {readySeed, deps, request} from "../shared/testing/programFixtures";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {dispatchProgramTripHandler, markProgramTripArrivedHandler,
  voidProgramTripHandler} from "./programDispatch";

function dispatchData() {
  return {programId: "program-1", pickupPointId: "pp-t3",
    destinationHotelId: "hotel-1", vehicleClassId: "suv",
    plateDisplay: "DL-1T-4471", vendorId: "vendor-1", legIds: ["leg-1"],
    expectedLegRevisions: [{legId: "leg-1", revision: 1}],
    clientOperationId: "dispatch-operation-1"};
}
function isCode(code: string) {
  return (error: unknown) => error instanceof HttpsError && error.code === code;
}
function changeBeforeCommit(db: FakeFirestore, change: () => void) {
  db.beforeCommit = async () => {
    db.beforeCommit = undefined;
    change();
  };
}
async function dispatch(db: FakeFirestore) {
  return dispatchProgramTripHandler(
    request(dispatchData(), "dispatcher-1"), deps(db));
}

for (const [path, patch, code] of [
  ["programStaffGrants/program-1__dispatcher-1",
    {status: "revoked"}, "permission-denied"],
  ["programPickupPoints/pp-t3", {active: false}, "failed-precondition"],
  ["programHotels/hotel-1", {active: false}, "invalid-argument"],
  ["transportVendors/vendor-1", {active: false}, "invalid-argument"],
  ["organizerPrograms/program-1", {status: "archived"}, "failed-precondition"],
  ["organizerPrograms/program-1", {capabilities: []}, "failed-precondition"],
] as const) {
  test(`dispatch revalidates ${path} in its transaction`, async () => {
    const db = new FakeFirestore(readySeed());
    changeBeforeCommit(db, () => db.updateDoc(path, patch));
    await assert.rejects(dispatch(db), isCode(code));
    assert.equal([...db.docs.keys()].some((key) =>
      key.startsWith("transportTrips/")), false);
    assert.equal(db.getDoc("programTravelLegs/leg-1")?.readiness, "ready");
  });
}

test("dispatch enforces both resource scopes from the same duty", async () => {
  const seed = readySeed();
  seed["programStaffGrants/program-1__dispatcher-1"].duties = [{
    duty: "transportDispatcher", pickupPointIds: ["pp-t3"],
    hotelIds: ["hotel-2"],
  }];
  await assert.rejects(dispatch(new FakeFirestore(seed)),
    isCode("permission-denied"));
});

for (const changed of [
  {notes: "Changed instructions"}, {destinationLabel: "Changed destination"},
  {kind: "repositioning"},
  {expectedLegRevisions: [{legId: "leg-1", revision: 2}]},
]) {
  test(`receipt binds changed ${Object.keys(changed)[0]}`, async () => {
    const db = new FakeFirestore(readySeed());
    await dispatch(db);
    await assert.rejects(dispatchProgramTripHandler(request({
      ...dispatchData(), ...changed,
    }, "dispatcher-1"), deps(db)), isCode("aborted"));
  });
}

test("valid receipt can replay after its vendor is disabled", async () => {
  const db = new FakeFirestore(readySeed());
  const created = await dispatch(db);
  db.updateDoc("transportVendors/vendor-1", {active: false});
  const replay = await dispatch(db);
  assert.equal(replay.alreadyApplied, true);
  assert.equal(replay.tripId, created.tripId);
  db.updateDoc("programStaffGrants/program-1__dispatcher-1",
    {status: "revoked"});
  await assert.rejects(dispatch(db), isCode("permission-denied"));
});

for (const action of [markProgramTripArrivedHandler, voidProgramTripHandler]) {
  test(`${action.name} revalidates authority during completion`, async () => {
    const db = new FakeFirestore(readySeed());
    const created = await dispatch(db);
    changeBeforeCommit(db, () => db.updateDoc(
      "programStaffGrants/program-1__dispatcher-1", {status: "revoked"}));
    await assert.rejects(action(request({programId: "program-1",
      tripId: created.tripId, expectedRevision: created.revision,
      reason: "Incorrect dispatch", clientOperationId: "complete-1",
    }, "dispatcher-1"), deps(db)), isCode("permission-denied"));
    assert.equal(db.getDoc(`transportTrips/${created.tripId}`)?.status,
      "enRoute");
  });

  test(`${action.name} cannot release another trip's assignment`, async () => {
    const db = new FakeFirestore(readySeed());
    const created = await dispatch(db);
    db.updateDoc("transportActiveAssignments/program-1__leg-1", {
      tripId: "another-trip",
    });
    await assert.rejects(action(request({programId: "program-1",
      tripId: created.tripId, expectedRevision: created.revision,
      reason: "Incorrect dispatch", clientOperationId: "complete-1",
    }, "dispatcher-1"), deps(db)), isCode("failed-precondition"));
    assert.equal(db.getDoc("transportActiveAssignments/program-1__leg-1")
      ?.status, "active");
    assert.equal(db.getDoc(`transportTrips/${created.tripId}`)?.status,
      "enRoute");
    assert.equal(db.getDoc("programTravelLegs/leg-1")?.readiness, "dispatched");
  });

  test(`${action.name} replay rechecks the trip's current scope`, async () => {
    const db = new FakeFirestore(readySeed());
    const created = await dispatch(db);
    const data = {programId: "program-1", tripId: created.tripId,
      expectedRevision: created.revision, reason: "Incorrect dispatch",
      clientOperationId: "complete-1"};
    await action(request(data, "dispatcher-1"), deps(db));
    db.updateDoc("programStaffGrants/program-1__dispatcher-1", {duties: [{
      duty: "transportDispatcher", pickupPointIds: ["pp-t1"], hotelIds: [],
    }]});
    await assert.rejects(action(request(data, "dispatcher-1"), deps(db)),
      isCode("permission-denied"));
  });
}

for (const [label, legPatch, requestPatch] of [
  ["expected passenger", {readiness: "expected", readyAt: null}, {}],
  ["missing curb observation", {readyAt: null}, {}],
  ["outbound journey", {kind: "outbound"}, {}],
  ["different hotel", {destinationHotelId: "hotel-2"}, {}],
  ["unsupported accessibility",
    {requiredCapabilities: ["wheelchairAccessible"]}, {}],
  ["excess luggage", {luggageUnits: 9}, {}],
  ["empty normalized plate", {}, {plateDisplay: "----"}],
  ["empty repositioning", {}, {kind: "repositioning"}],
] as const) {
  test(`dispatch rejects ${label}`, async () => {
    const db = new FakeFirestore(readySeed());
    db.updateDoc("programTravelLegs/leg-1", legPatch);
    await assert.rejects(dispatchProgramTripHandler(request({
      ...dispatchData(), ...requestPatch,
    }, "dispatcher-1"), deps(db)), (error: unknown) =>
      error instanceof HttpsError &&
      ["failed-precondition", "invalid-argument"].includes(error.code));
    assert.equal([...db.docs.keys()].some((key) =>
      key.startsWith("transportTrips/")), false);
  });
}

test("dispatch requires the complete ready party",
  async () => {
    const db = new FakeFirestore(readySeed());
    db.updateDoc("programTravelLegs/leg-1", {partyId: "party-1"});
    db.updateDoc("programTravelLegs/leg-2", {partyId: "party-1",
      pickupPointId: "pp-t3", readiness: "ready",
      readyAt: db.getDoc("programTravelLegs/leg-1")!.readyAt});
    db.setDoc("programTravelParties/party-1", {programId: "program-1",
      memberGuestIds: ["guest-1", "guest-2"], dedicatedVehicle: true});
    await assert.rejects(dispatch(db), isCode("failed-precondition"));
    const complete = await dispatchProgramTripHandler(request({
      ...dispatchData(), legIds: ["leg-1", "leg-2"],
      expectedLegRevisions: [{legId: "leg-1", revision: 1},
        {legId: "leg-2", revision: 1}],
    }, "dispatcher-1"), deps(db));
    assert.equal(complete.passengerCount, 3);
  });

for (const party of [false, true]) {
  test(`private ${party ? "party" : "leg"} cannot mix unrelated guests`,
    async () => {
      const db = new FakeFirestore(readySeed());
      db.updateDoc("programTravelLegs/leg-1", party ? {partyId: "private"} :
        {dedicatedVehicle: true});
      db.setDoc("programTravelParties/private", {programId: "program-1",
        memberGuestIds: ["guest-1"], dedicatedVehicle: true});
      db.updateDoc("programTravelLegs/leg-2", {pickupPointId: "pp-t3",
        readiness: "ready",
        readyAt: db.getDoc("programTravelLegs/leg-1")!.readyAt});
      await assert.rejects(dispatchProgramTripHandler(request({
        ...dispatchData(), legIds: ["leg-1", "leg-2"],
        expectedLegRevisions: [{legId: "leg-1", revision: 1},
          {legId: "leg-2", revision: 1}],
      }, "dispatcher-1"), deps(db)), isCode("failed-precondition"));
    });
}

test("two legs cannot count the same guest twice on a manifest", async () => {
  const db = new FakeFirestore(readySeed());
  db.setDoc("programTravelLegs/duplicate",
    db.getDoc("programTravelLegs/leg-1")!);
  await assert.rejects(dispatchProgramTripHandler(request({
    ...dispatchData(), legIds: ["leg-1", "duplicate"],
    expectedLegRevisions: [{legId: "leg-1", revision: 1},
      {legId: "duplicate", revision: 1}],
  }, "dispatcher-1"), deps(db)), isCode("failed-precondition"));
});

for (const fences of [undefined, [],
  [{legId: "unselected", revision: 1}],
  [{legId: "leg-1", revision: 1}, {legId: "leg-1", revision: 2}],
  [{legId: "leg-1", revision: 1}, {legId: "unselected", revision: 1}],
]) {
  test(`dispatch requires complete unique fences: ${JSON.stringify(fences)}`,
    async () => {
      const db = new FakeFirestore(readySeed());
      await assert.rejects(dispatchProgramTripHandler(request({
        ...dispatchData(), expectedLegRevisions: fences,
      }, "dispatcher-1"), deps(db)), isCode("invalid-argument"));
    });
}

for (const offset of [6 * 60_000, -8 * 24 * 60 * 60_000]) {
  test(`dispatch rejects departure offset ${offset}`, async () => {
    const db = new FakeFirestore(readySeed());
    await assert.rejects(dispatchProgramTripHandler(request({
      ...dispatchData(), departedAtMillis: 1_800_000_000_000 + offset,
    }, "dispatcher-1"), deps(db)), isCode("failed-precondition"));
  });
}

function addSecondProgram(db: FakeFirestore) {
  db.setDoc("organizerPrograms/program-2", {
    ...db.getDoc("organizerPrograms/program-1"),
  });
  db.setDoc("programPickupPoints/pickup-2", {
    ...db.getDoc("programPickupPoints/pp-t3"), programId: "program-2",
  });
  db.setDoc("programHotels/destination-2", {
    ...db.getDoc("programHotels/hotel-1"), programId: "program-2",
  });
  db.setDoc("programTravelLegs/leg-3", {
    ...db.getDoc("programTravelLegs/leg-1"), programId: "program-2",
    guestId: "guest-3", pickupPointId: "pickup-2",
    destinationHotelId: "destination-2",
  });
  return {...dispatchData(), programId: "program-2", pickupPointId: "pickup-2",
    destinationHotelId: "destination-2", vendorId: null, legIds: ["leg-3"],
    plateDisplay: "dl1t4471",
    expectedLegRevisions: [{legId: "leg-3", revision: 1}]};
}

test("one vehicle cannot depart on concurrent trips across organizer programs",
  async () => {
    const db = new FakeFirestore(readySeed());
    const second = addSecondProgram(db);
    const results = await Promise.allSettled([
      dispatch(db),
      dispatchProgramTripHandler(request(second, "manager-1"), deps(db)),
    ]);
    assert.equal(results.filter((r) => r.status === "fulfilled").length, 1);
    const rejected = results.find((r) => r.status === "rejected");
    assert.ok(rejected?.status === "rejected");
    assert.ok(isCode("already-exists")(rejected.reason));
    assert.equal([...db.docs.keys()].filter((key) =>
      key.startsWith("transportTrips/")).length, 1);
  });

for (const action of [markProgramTripArrivedHandler, voidProgramTripHandler]) {
  test(`${action.name} releases its vehicle for another program`, async () => {
    const db = new FakeFirestore(readySeed());
    const second = addSecondProgram(db);
    const first = await dispatch(db);
    const data = {programId: "program-1", tripId: first.tripId,
      expectedRevision: first.revision, clientOperationId: "complete-first",
      reason: "Wrong vehicle"};
    await action(request(data, "dispatcher-1"), deps(db));
    const next = await dispatchProgramTripHandler(
      request(second, "manager-1"), deps(db));
    assert.notEqual(first.tripId, next.tripId);
    // A delayed replay must not release the vehicle from the newer trip.
    await action(request(data, "dispatcher-1"), deps(db));
    const reservations = [...db.docs].filter(([path]) =>
      path.startsWith("transportVehicleAssignments/"));
    assert.equal(reservations.length, 1);
    assert.equal(reservations[0][1].status, "active");
    assert.equal(reservations[0][1].tripId, next.tripId);
  });
}

test("stale trip completion cannot release a vehicle owned by another trip",
  async () => {
    const db = new FakeFirestore(readySeed());
    const trip = await dispatch(db);
    const key = [...db.docs.keys()].find((path) =>
      path.startsWith("transportVehicleAssignments/"))!;
    db.updateDoc(key, {tripId: "other-trip"});
    await assert.rejects(voidProgramTripHandler(request({
      programId: "program-1", tripId: trip.tripId,
      expectedRevision: trip.revision, clientOperationId: "void-stale",
      reason: "Wrong vehicle",
    }, "dispatcher-1"), deps(db)), isCode("failed-precondition"));
    assert.equal(db.getDoc(key)?.status, "active");
    assert.equal(db.getDoc("programTravelLegs/leg-1")?.readiness, "dispatched");
  });

test("vehicle occupancy is isolated between organizers", async () => {
  const db = new FakeFirestore(readySeed());
  const second = addSecondProgram(db);
  db.setDoc("organizers/org-2", {...db.getDoc("organizers/org-1")});
  for (const path of ["organizerPrograms/program-2",
    "programPickupPoints/pickup-2", "programHotels/destination-2",
    "programTravelLegs/leg-3"]) {
    db.updateDoc(path, {organizerId: "org-2"});
  }
  await dispatch(db);
  await dispatchProgramTripHandler(request(second, "manager-1"), deps(db));
  const reservations = [...db.docs.keys()].filter((path) =>
    path.startsWith("transportVehicleAssignments/"));
  assert.equal(reservations.length, 2);
});
