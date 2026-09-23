import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {baseSeed, deps, request, now} from "../shared/testing/programFixtures";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {setProgramTravelReadinessHandler} from "./programReadiness";
import {dispatchProgramTripHandler} from "./programDispatch";

const claimRef = {action: "claim", clientOperationId: "offline-claim-1"};
const readyRef = {action: "markReady", clientOperationId: "offline-ready-1"};
const observedAtMillis = now.toMillis() - 2 * 3600_000;
const base = {programId: "program-1", legId: "leg-1",
  expectedRevision: 1, observedAtMillis};
const isAborted = (error: unknown) =>
  error instanceof HttpsError && error.code === "aborted";
async function claim(db: FakeFirestore) {
  return setProgramTravelReadinessHandler(request({...base, ...claimRef},
    "manager-1"), deps(db));
}
async function ready(db: FakeFirestore, patch: Record<string, unknown> = {},
  actor = "manager-1") {
  return setProgramTravelReadinessHandler(request({...base, ...readyRef,
    afterObservation: claimRef, ...patch}, actor), deps(db));
}
function dispatch(db: FakeFirestore,
  afterObservation: Record<string, unknown> = readyRef) {
  return dispatchProgramTripHandler(request({programId: "program-1",
    pickupPointId: "pp-t3", destinationHotelId: "hotel-1",
    vehicleClassId: "suv", plateDisplay: "DL1234", legIds: ["leg-1"],
    expectedLegRevisions: [{legId: "leg-1", revision: 1, afterObservation}],
    departedAtMillis: observedAtMillis + 10 * 60_000,
    clientOperationId: "offline-dispatch-1",
  }, "manager-1"), deps(db));
}

test("offline claim, ready and dispatch chain through their own receipts",
  async () => {
    const db = new FakeFirestore(baseSeed());
    await claim(db);
    await ready(db);
    const leg = db.getDoc("programTravelLegs/leg-1")!;
    assert.equal((leg.readyAt as FirebaseFirestore.Timestamp).toMillis(),
      observedAtMillis);
    assert.equal((leg.claimedAt as FirebaseFirestore.Timestamp).toMillis(),
      observedAtMillis);
    const trip = await dispatch(db);
    assert.equal(trip.passengerCount, 2);
    assert.equal((db.getDoc(`transportTrips/${trip.tripId}`)!.departedAt as
      FirebaseFirestore.Timestamp).toMillis(), observedAtMillis + 10 * 60_000);
    assert.equal((await claim(db)).alreadyApplied, true);
    assert.equal((await ready(db)).alreadyApplied, true);
    assert.equal((await dispatch(db)).alreadyApplied, true);
  });

test("missing or mismatched receipts cannot rebase",
  async () => {
    const db = new FakeFirestore(baseSeed());
    await assert.rejects(ready(db), isAborted);
    await claim(db);
    await assert.rejects(ready(db, {}, "greeter-1"), isAborted);
    await assert.rejects(ready(db, {legId: "leg-2"}), isAborted);
    await assert.rejects(ready(db, {afterObservation: {...claimRef,
      action: "unclaim"}}), isAborted);
    assert.equal(db.getDoc("programTravelLegs/leg-1")!.readiness, "expected");
  });

test("a change after the predecessor prevents both readiness and dispatch",
  async () => {
    const db = new FakeFirestore(baseSeed());
    const claimed = await claim(db);
    db.updateDoc("programTravelLegs/leg-1", {revision: claimed.revision + 1});
    await assert.rejects(ready(db), isAborted);
    const fresh = new FakeFirestore(baseSeed());
    await claim(fresh);
    const readied = await ready(fresh);
    fresh.updateDoc("programTravelLegs/leg-1", {
      revision: readied.revision + 1});
    await assert.rejects(dispatch(fresh), isAborted);
  });

test("replays bind both observed time and predecessor reference", async () => {
  const db = new FakeFirestore(baseSeed());
  await claim(db);
  await ready(db);
  await assert.rejects(ready(db, {observedAtMillis: observedAtMillis + 1}),
    isAborted);
  await assert.rejects(ready(db, {afterObservation: undefined}), isAborted);
  await dispatch(db);
  await assert.rejects(dispatch(db, claimRef), isAborted);
});

for (const patch of [
  {expectedRevision: undefined}, {observedAtMillis: undefined},
  {observedAtMillis: now.toMillis() - 8 * 86_400_000},
  {observedAtMillis: now.toMillis() + 6 * 60_000}]) {
  test(`observations need bounded time and a fence: ${JSON.stringify(patch)}`,
    async () => {
      const db = new FakeFirestore(baseSeed());
      await assert.rejects(setProgramTravelReadinessHandler(request({
        ...base, ...claimRef, ...patch,
      }, "manager-1"), deps(db)), (error: unknown) =>
        error instanceof HttpsError &&
        ["invalid-argument", "failed-precondition"].includes(error.code));
      assert.equal(db.getDoc("programTravelLegs/leg-1")!.revision, 1);
    });
}

test("predecessor cannot authorize an intervening transaction write",
  async () => {
    const db = new FakeFirestore(baseSeed());
    const claimed = await claim(db);
    db.beforeCommit = async () => {
      db.beforeCommit = undefined;
      db.updateDoc("programTravelLegs/leg-1", {revision: claimed.revision + 1});
    };
    await assert.rejects(ready(db), isAborted);
    assert.equal(db.getDoc("programTravelLegs/leg-1")!.readiness, "expected");
  });
