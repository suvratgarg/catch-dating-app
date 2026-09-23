import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import {baseSeed, deps, now, request} from "../shared/testing/programFixtures";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {setProgramTravelReadinessHandler} from "./programReadiness";

function data(action = "markReady") {
  return {programId: "program-1", legId: "leg-1", action,
    expectedRevision: 1, observedAtMillis: now.toMillis(),
    clientOperationId: "readiness-operation"};
}
function isCode(code: string) {
  return (error: unknown) => error instanceof HttpsError && error.code === code;
}

for (const [path, patch] of [
  ["programStaffGrants/program-1__greeter-1", {status: "revoked"}],
  ["programPickupPoints/pp-t3", {active: false}],
  ["programPickupPoints/pp-t3", {organizerId: "foreign"}],
  ["organizerPrograms/program-1", {status: "archived"}],
]) {
  test(`readiness rechecks ${path} before commit`, async () => {
    const db = new FakeFirestore(baseSeed());
    db.beforeCommit = async () => {
      db.beforeCommit = undefined;
      db.updateDoc(path as string, patch as Record<string, unknown>);
    };
    await assert.rejects(setProgramTravelReadinessHandler(
      request(data(), "greeter-1"), deps(db)), (error: unknown) =>
      error instanceof HttpsError &&
      ["permission-denied", "failed-precondition"].includes(error.code));
    assert.equal(db.getDoc("programTravelLegs/leg-1")?.readiness, "expected");
    assert.equal([...db.docs.keys()].some((key) =>
      key.startsWith("transportOperationReceipts/")), false);
  });
}

test("readiness receipts bind the reviewed manual note", async () => {
  const db = new FakeFirestore(baseSeed());
  await setProgramTravelReadinessHandler(request({
    ...data(), manualCurbAtMillis: now.toMillis(), manualCurbNote: "At gate 2",
  }, "greeter-1"), deps(db));
  await assert.rejects(setProgramTravelReadinessHandler(request({
    ...data(), manualCurbAtMillis: now.toMillis(), manualCurbNote: "At gate 4",
  }, "greeter-1"), deps(db)), isCode("aborted"));
});

test("replayed readiness requires current leg access", async () => {
  const db = new FakeFirestore(baseSeed());
  await setProgramTravelReadinessHandler(
    request(data(), "greeter-1"), deps(db));
  db.updateDoc("programStaffGrants/program-1__greeter-1", {duties: [{
    duty: "airportGreeter",
    expiresAtMillis: 1_800_086_400_000,
    pickupPointIds: ["pp-t1"], hotelIds: [],
  }]});
  await assert.rejects(setProgramTravelReadinessHandler(
    request(data(), "greeter-1"), deps(db)), isCode("permission-denied"));
});

test("dispatcher duty elsewhere cannot release another greeter's claim",
  async () => {
    const seed = baseSeed();
    seed["programStaffGrants/program-1__greeter-1"].duties = [{
      duty: "airportGreeter",
      expiresAtMillis: 1_800_086_400_000,
      pickupPointIds: ["pp-t3"], hotelIds: [],
    }, {
      duty: "transportDispatcher",
      expiresAtMillis: 1_800_086_400_000,
      pickupPointIds: ["pp-t1"], hotelIds: [],
    }];
    seed["programTravelLegs/leg-1"].claimedByUid = "greeter-2";
    const db = new FakeFirestore(seed);
    await assert.rejects(setProgramTravelReadinessHandler(
      request(data("unclaim"), "greeter-1"), deps(db)),
    isCode("permission-denied"));
    assert.equal(db.getDoc("programTravelLegs/leg-1")?.claimedByUid,
      "greeter-2");
  });

test("disruption clears old readiness and repeated ready preserves wait time",
  async () => {
    const db = new FakeFirestore(baseSeed());
    const first = await setProgramTravelReadinessHandler(
      request(data(), "greeter-1"), deps(db));
    const later = deps(db, {now: () =>
      admin.firestore.Timestamp.fromMillis(now.toMillis() + 10 * 60_000)});
    const repeated = await setProgramTravelReadinessHandler(request({
      ...data(), clientOperationId: "ready-again",
      expectedRevision: first.revision,
    }, "greeter-1"), later);
    assert.equal((db.getDoc("programTravelLegs/leg-1")?.readyAt as
      FirebaseFirestore.Timestamp).toMillis(), now.toMillis());
    await setProgramTravelReadinessHandler(request({
      ...data("markDisrupted"), clientOperationId: "disruption",
      expectedRevision: repeated.revision,
    }, "greeter-1"), later);
    assert.equal(db.getDoc("programTravelLegs/leg-1")?.readyAt, null);
    assert.equal(db.getDoc("programTravelLegs/leg-1")?.readiness, "disrupted");
  });

test("readiness needs a real pickup and valid Firestore time", async () => {
  const db = new FakeFirestore(baseSeed());
  await assert.rejects(setProgramTravelReadinessHandler(request({
    ...data(), manualCurbAtMillis: Number.MAX_SAFE_INTEGER,
  }, "greeter-1"), deps(db)), isCode("invalid-argument"));
  db.updateDoc("programTravelLegs/leg-1", {pickupPointId: null});
  await assert.rejects(setProgramTravelReadinessHandler(
    request(data(), "manager-1"), deps(db)), isCode("failed-precondition"));
});


test("unclaim permits an inactive owned pickup but rejects changed ownership",
  async () => {
    const db = new FakeFirestore(baseSeed());
    db.updateDoc("programPickupPoints/pp-t3", {active: false});
    db.updateDoc("programTravelLegs/leg-1", {claimedByUid: "greeter-1"});
    await setProgramTravelReadinessHandler(request(data("unclaim"),
      "greeter-1"), deps(db));
    assert.equal(db.getDoc("programTravelLegs/leg-1")?.claimedByUid, null);
    db.updateDoc("programPickupPoints/pp-t3", {organizerId: "foreign"});
    await assert.rejects(setProgramTravelReadinessHandler(request({
      ...data("unclaim"), clientOperationId: "unclaim-foreign",
      expectedRevision: db.getDoc("programTravelLegs/leg-1")!.revision,
    }, "greeter-1"), deps(db)), isCode("failed-precondition"));
  });
