import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {baseSeed, deps, request, now} from "../shared/testing/programFixtures";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {upsertProgramTravelPartyHandler} from "./programTravelParties";
import {upsertProgramTravelLegHandler} from "./programTravel";
import {getProgramTransportPlanHandler} from "./programArrivals";

const isCode = (code: string) => (error: unknown) =>
  error instanceof HttpsError && error.code === code;
function seedParty() {
  const seed = baseSeed();
  seed["programTravelLegs/leg-2"].pickupPointId = "pp-t3";
  seed["programTravelLegs/outbound"] = {
    ...seed["programTravelLegs/leg-1"], kind: "outbound",
  };
  return seed;
}
function save(db: FakeFirestore, data: Record<string, unknown> = {}) {
  return upsertProgramTravelPartyHandler(request({programId: "program-1",
    label: "Airport group", legIds: ["leg-1"], dedicatedVehicle: false,
    ...data}, "manager-1"), deps(db));
}
function editLeg(db: FakeFirestore, data: Record<string, unknown> = {}) {
  return upsertProgramTravelLegHandler(request({programId: "program-1",
    legId: "leg-1", guestId: "guest-1", kind: "inbound", passengers: 2,
    luggageUnits: 3, requiredCapabilities: [], dedicatedVehicle: false,
    expectedRevision: db.getDoc("programTravelLegs/leg-1")!.revision,
    ...data}, "manager-1"), deps(db));
}

test("party names journeys and never adopts the guest's other journeys",
  async () => {
    const db = new FakeFirestore(seedParty());
    const result = await save(db);
    assert.equal(db.getDoc("programTravelLegs/leg-1")!.partyId,
      result.entityId);
    assert.equal(db.getDoc("programTravelLegs/outbound")!.partyId, null);
    assert.deepEqual(
      db.getDoc(`programTravelParties/${result.entityId}`)!.legIds,
      ["leg-1"]);
    const changed = await save(db, {partyId: result.entityId,
      expectedRevision: result.revision, legIds: ["leg-2"]});
    assert.equal(db.getDoc("programTravelLegs/leg-1")!.partyId, null);
    assert.equal(db.getDoc("programTravelLegs/leg-2")!.partyId,
      result.entityId);
    await save(db, {partyId: result.entityId,
      expectedRevision: changed.revision,
      legIds: []});
    assert.equal(db.getDoc("programTravelLegs/leg-2")!.partyId, null);
  });

test("new parties need a journey; existing party writes need a current fence",
  async () => {
    const db = new FakeFirestore(seedParty());
    await assert.rejects(save(db, {legIds: []}), isCode("invalid-argument"));
    const created = await save(db);
    await assert.rejects(save(db, {partyId: created.entityId}),
      isCode("invalid-argument"));
    await assert.rejects(save(db, {partyId: created.entityId,
      expectedRevision: created.revision + 1}), isCode("aborted"));
  });

for (const [label, patch] of [
  ["different pickup", {pickupPointId: "pp-t1"}],
  ["different destination", {destinationHotelId: "hotel-2"}],
  ["different journey kind", {kind: "outbound"}],
  ["duplicate passenger", {guestId: "guest-1"}],
  ["already departed", {readiness: "dispatched"}],
  ["arrived", {readiness: "arrived"}],
  ["another party", {partyId: "other-party"}],
] as const) {
  test(`party rejects ${label} atomically`, async () => {
    const db = new FakeFirestore(seedParty());
    db.updateDoc("programTravelLegs/leg-2", patch);
    await assert.rejects(save(db, {legIds: ["leg-1", "leg-2"]}),
      isCode("failed-precondition"));
    assert.equal(db.getDoc("programTravelLegs/leg-1")!.partyId, null);
    assert.equal([...db.docs.keys()].some((key) =>
      key.startsWith("programTravelParties/")), false);
  });
}

test("party cannot adopt a foreign journey or repair an index by guessing",
  async () => {
    const db = new FakeFirestore(seedParty());
    db.updateDoc("programTravelLegs/leg-2", {organizerId: "other"});
    await assert.rejects(save(db, {legIds: ["leg-1", "leg-2"]}),
      isCode("not-found"));
    const created = await save(db);
    db.updateDoc("programTravelLegs/leg-1", {partyId: null});
    await assert.rejects(save(db, {partyId: created.entityId,
      expectedRevision: created.revision}), isCode("failed-precondition"));
  });

for (const action of [save, editLeg]) {
  test(`${action.name} checks current program authority before commit`,
    async () => {
      const db = new FakeFirestore(seedParty());
      db.beforeCommit = async () => {
        db.beforeCommit = undefined;
        db.updateDoc("organizers/org-1", {hostUserId: "new-manager",
          ownerUserId: "new-manager",
          hostUserIds: ["new-manager"]});
      };
      await assert.rejects(action(db), isCode("permission-denied"));
      assert.equal(db.getDoc("programTravelLegs/leg-1")!.revision, 1);
    });
}

test("party cannot race a dispatch of its selected journey", async () => {
  const db = new FakeFirestore(seedParty());
  db.beforeCommit = async () => {
    db.beforeCommit = undefined;
    db.updateDoc("programTravelLegs/leg-1", {readiness: "dispatched"});
  };
  await assert.rejects(save(db), isCode("failed-precondition"));
  assert.equal(db.getDoc("programTravelLegs/leg-1")!.partyId, null);
});

test("leg patch preserves observations unless rebooked",
  async () => {
    const db = new FakeFirestore(seedParty());
    db.updateDoc("programTravelLegs/leg-1", {readiness: "ready", readyAt: now,
      claimedByUid: "greeter-1", claimedAt: now, manualCurbAt: now,
      manualCurbNote: "At the curb"});
    await editLeg(db, {luggageUnits: 4});
    assert.equal(db.getDoc("programTravelLegs/leg-1")!.readiness, "ready");
    await editLeg(db, {scheduledArrivalAtMillis: now.toMillis() + 86_400_000});
    const leg = db.getDoc("programTravelLegs/leg-1")!;
    for (const field of ["readyAt", "claimedByUid", "claimedAt",
      "manualCurbAt", "manualCurbNote"]) assert.equal(leg[field], null);
    assert.equal(leg.readiness, "expected");
  });

for (const [patch, code] of [
  [{guestId: "guest-2"}, "failed-precondition"],
  [{kind: "outbound"}, "failed-precondition"],
  [{partyId: "some-party"}, "invalid-argument"],
  [{expectedRevision: undefined}, "invalid-argument"],
] as const) {
  test(`leg rejects unsafe patch ${Object.keys(patch)[0]}`, async () => {
    await assert.rejects(editLeg(new FakeFirestore(seedParty()), patch),
      isCode(code));
  });
}

test("party-bound leg must be detached before changing its route", async () => {
  const db = new FakeFirestore(seedParty());
  await save(db);
  await assert.rejects(editLeg(db, {pickupPointId: "pp-t1"}),
    isCode("failed-precondition"));
  await assert.rejects(editLeg(db, {destinationHotelId: "hotel-2"}),
    isCode("failed-precondition"));
});

test("legacy guest-only parties require explicit journey reconciliation",
  async () => {
    const db = new FakeFirestore(seedParty());
    db.setDoc("programTravelParties/legacy", {programId: "program-1",
      organizerId: "org-1", memberGuestIds: ["guest-1"], revision: 1});
    await assert.rejects(save(db, {partyId: "legacy", expectedRevision: 1}),
      isCode("failed-precondition"));
  });

for (const patch of [
  {readiness: "dispatched"}, {pickupPointId: "pp-t1"}, {partyId: null},
]) {
  test(`suggestions cannot split an incomplete party: ${JSON.stringify(patch)}`,
    async () => {
      const db = new FakeFirestore(seedParty());
      await save(db, {legIds: ["leg-1", "leg-2"]});
      db.updateDoc("programTravelLegs/leg-2", patch);
      const plan = await getProgramTransportPlanHandler(request({
        programId: "program-1", pickupPointId: "pp-t3",
      }, "dispatcher-1"), deps(db));
      assert.ok(plan.unassigned.some((leg) => leg.legId === "leg-1"));
      assert.ok(plan.groups.every((group) => !group.legIds.includes("leg-1")));
    });
}
