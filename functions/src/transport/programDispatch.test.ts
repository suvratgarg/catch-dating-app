import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {baseSeed, deps, request} from "../shared/testing/programFixtures";
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
    const db = new FakeFirestore(baseSeed());
    changeBeforeCommit(db, () => db.updateDoc(path, patch));
    await assert.rejects(dispatch(db), isCode(code));
    assert.equal([...db.docs.keys()].some((key) =>
      key.startsWith("transportTrips/")), false);
    assert.equal(db.getDoc("programTravelLegs/leg-1")?.readiness, "expected");
  });
}

test("dispatch enforces both resource scopes from the same duty", async () => {
  const seed = baseSeed();
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
    const db = new FakeFirestore(baseSeed());
    await dispatch(db);
    await assert.rejects(dispatchProgramTripHandler(request({
      ...dispatchData(), ...changed,
    }, "dispatcher-1"), deps(db)), isCode("aborted"));
  });
}

test("valid receipt can replay after its vendor is disabled", async () => {
  const db = new FakeFirestore(baseSeed());
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
    const db = new FakeFirestore(baseSeed());
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
    const db = new FakeFirestore(baseSeed());
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
    const db = new FakeFirestore(baseSeed());
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
