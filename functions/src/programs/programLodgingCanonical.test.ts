import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {baseSeed, now} from "../shared/testing/programFixtures";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {requireProgramAccess} from "../shared/programAuthority";
import {immutableLodgingProposal} from "./programLodgingPlanner";
import {readCanonicalLodgingRecords} from "./programLodgingSource";
import {prepareCanonicalLodgingPublication} from "./programLodgingCanonical";
import type {LodgingSnapshot} from "./programLodgingTypes";

const millis = (date: string) => Date.parse(date + "T00:00:00Z");
function setup() {
  const snapshot: LodgingSnapshot = {
    scope: {programId: "program-1", organizerId: "org-1"},
    revisions: {source: 1, inventory: 1, layout: 1, published: 1},
    guests: ["guest-1", "guest-2"].map((id, i) => ({id, beds: 1,
      requiredFeatures: [], arrival: "2026-10-01",
      departure: i ? "2026-10-02" : "2026-10-03"})),
    parties: [{id: "party", guestIds: ["guest-1", "guest-2"],
      confirmed: true, priority: 0, requiredRoomType: null, pin: null}],
    groups: [], memberships: [],
    rooms: [{id: "physical", hotelId: "hotel-1", zoneId: "wing",
      building: null, floor: "1", wing: null, roomType: "standard", beds: 2,
      maxOccupants: 2, verifiedFeatures: [], resourceIds: ["physical"],
      position: null}],
    inventory: [{id: "unit", contractId: "block", physicalRoomId: "physical",
      provisional: null, availability: [{arrival: "2026-10-01",
        departure: "2026-10-04"}]}],
    contracts: [{id: "block", hotelId: "hotel-1", nightlyRoomQuota: 1,
      arrival: "2026-10-01", departure: "2026-10-04"}], published: [],
  };
  const fake = new FakeFirestore({...baseSeed(),
    "programRoomBlocks/block": {...snapshot.scope, hotelId: "hotel-1",
      label: "Contract", roomType: "standard", totalRooms: 1,
      assignedCount: 0, maxOccupantsPerRoom: 2, heldForGroupIds: [],
      startsAt: Timestamp.fromMillis(millis("2026-10-01")),
      endsAt: Timestamp.fromMillis(millis("2026-10-04")),
      createdAt: now, updatedAt: now, revision: 1}});
  const db = fake as unknown as FirebaseFirestore.Firestore;
  const windows = snapshot.guests.map((g) => ({guestId: g.id,
    startsAtMillis: millis(g.arrival), endsAtMillis: millis(g.departure)}));
  const proposal = () => immutableLodgingProposal(snapshot,
    [{partyId: "party", inventoryId: "unit"}]);
  let failAfterWrites = false;
  const publish = () => db.runTransaction(async (tx) => {
    const access = await requireProgramAccess({db, transaction: tx,
      actorUid: "manager-1", programId: "program-1", now});
    const records = await readCanonicalLodgingRecords(tx, db, access,
      "program-1");
    const writer = prepareCanonicalLodgingPublication(tx, db, records,
      snapshot, windows, {unit: "101"}, "Asia/Kolkata", now, (stays) => {
        tx.set(db.collection("publicationEvidence").doc("program-1"),
          {ids: stays.map((r) => r.id)});
        if (failAfterWrites) throw new Error("Abort native publication");
      });
    writer(proposal());
  });
  const rows = () => [...fake.docs].filter(([path]) =>
    path.startsWith("programStays/"));
  return {fake, snapshot, windows, publish, rows,
    fail: () => {
      failAfterWrites = true;
    }};
}

test("canonical publication counts roommates with different departures once",
  async () => {
    const h = setup();
    await h.publish();
    const rows = h.rows().map(([, data]) => data);
    assert.equal(rows.length, 2);
    assert.equal(new Set(rows.map((r) => r.roomOccupancyId)).size, 1);
    assert.equal(rows[0].lodgingPartyId, "party");
    assert.equal(rows[0].lodgingInventoryId, "unit");
    assert.equal(h.fake.getDoc("programRoomBlocks/block")!.assignedCount, 1);
    assert.equal(new Set(rows.map((r) =>
      (r.endsAt as Timestamp).toMillis())).size, 2);
  });

test("checked-in canonical stays retain their complete documents", async () => {
  const h = setup();
  await h.publish();
  const [path] = h.rows().find(([, r]) => r.guestId === "guest-1")!;
  h.fake.updateDoc(path, {status: "checkedIn", roomReadyAt: now,
    notes: "Existing operational note"});
  const before = h.fake.getDoc(path);
  await h.publish();
  assert.deepEqual(h.fake.getDoc(path), before);
  h.windows[0].endsAtMillis = millis("2026-10-04");
  h.snapshot.guests[0].departure = "2026-10-04";
  await assert.rejects(h.publish(), /Checked-in/);
  assert.deepEqual(h.fake.getDoc(path), before);
});

test("unbound live stays and checked-out demand fail closed", async () => {
  const h = setup();
  await h.publish();
  const [path] = h.rows()[0];
  const original = h.fake.getDoc(path)!;
  const unbound = {...original};
  delete unbound.lodgingInventoryId;
  h.fake.setDoc(path, unbound);
  await assert.rejects(h.publish(), /verified canonical inventory binding/);
  h.fake.setDoc(path, {...original, status: "checkedOut"});
  await assert.rejects(h.publish(), /Checked-out/);
});

test("native capacity rejects larger planner inventory", async () => {
  const h = setup();
  h.fake.updateDoc("programRoomBlocks/block", {maxOccupantsPerRoom: 1});
  await assert.rejects(h.publish(), /capacity or dates/);
  assert.equal(h.rows().length, 0);
  assert.equal(h.fake.getDoc("programRoomBlocks/block")!.assignedCount, 0);
});

test("failed publication rolls back canonical rows and capacity", async () => {
  const h = setup();
  h.fail();
  await assert.rejects(h.publish(), /Abort native publication/);
  assert.equal(h.rows().length, 0);
  assert.equal(h.fake.getDoc("publicationEvidence/program-1"), undefined);
  assert.equal(h.fake.getDoc("programRoomBlocks/block")!.assignedCount, 0);
});
