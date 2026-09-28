import assert from "node:assert/strict";
import test from "node:test";
import {baseSeed, deps, request, now} from "../shared/testing/programFixtures";
import {FakeFirestore, type FakeData} from
  "../shared/testing/programFirestore";
import {
  deleteProgramGuestGroupHandler,
  listProgramGuestGroupsHandler,
  upsertProgramGuestGroupHandler,
} from "./programGuestGroups";
import {listProgramGuestsHandler, upsertProgramGuestHandler} from
  "./programGuests";
import {validateProgramGuestGroupDocument} from
  "../shared/generated/validators/programGuestGroupDocument";

const group = (patch: Partial<FakeData> = {}): FakeData => ({
  programId: "program-1", organizerId: "org-1", label: "Groom side",
  dimension: "side", sortOrder: 0, memberCount: 0, hotelId: null,
  createdAt: now, updatedAt: now, revision: 1, ...patch,
});
const seed = () => ({...baseSeed(),
  "programGuestGroups/side-a": group(),
  "programGuestGroups/company-b": group({label: "Acme", dimension: "company"}),
});
const groupEdit = (db: FakeFirestore, patch: object = {}) =>
  upsertProgramGuestGroupHandler(request({programId: "program-1",
    groupId: "side-a", label: "Groom side", dimension: "side",
    expectedRevision: 1, ...patch}, "manager-1"), deps(db));
const groupDoc = (db: FakeFirestore, id: string) =>
  db.getDoc(`programGuestGroups/${id}`)!;

function assertGroupContracts(db: FakeFirestore) {
  for (const [path, doc] of db.docs) {
    if (!path.startsWith("programGuestGroups/")) continue;
    assert.ok(validateProgramGuestGroupDocument(doc),
      `${path}: ${JSON.stringify(validateProgramGuestGroupDocument.errors)}`);
  }
}

test("creating a group defaults memberCount and rejects duplicate labels",
  async () => {
    const db = new FakeFirestore(seed());
    const created = await upsertProgramGuestGroupHandler(request({
      programId: "program-1", label: "Friends", dimension: "relation",
      sortOrder: 3}, "manager-1"), deps(db));
    assert.ok(created.revision >= 1);
    assert.equal(groupDoc(db, created.entityId).memberCount, 0);
    assert.equal(groupDoc(db, created.entityId).sortOrder, 3);
    await assert.rejects(upsertProgramGuestGroupHandler(request({
      programId: "program-1", label: "  groom SIDE ", dimension: "SIDE",
    }, "manager-1"), deps(db)), /already exists/);
    assertGroupContracts(db);
  });

test("updating a group preserves memberCount and honors expectedRevision",
  async () => {
    const db = new FakeFirestore(seed());
    db.updateDoc("programGuestGroups/side-a", {memberCount: 7});
    await groupEdit(db, {label: "Baraat side"});
    assert.equal(groupDoc(db, "side-a").label, "Baraat side");
    assert.equal(groupDoc(db, "side-a").memberCount, 7);
    await assert.rejects(groupEdit(db, {expectedRevision: 1}),
      /changed since you loaded/);
    await assert.rejects(upsertProgramGuestGroupHandler(request({
      programId: "program-1", groupId: "missing", label: "x",
      dimension: "side", expectedRevision: 1}, "manager-1"), deps(db)),
    /not found|does not exist/i);
    assertGroupContracts(db);
  });

test("groups from another program are invisible and immovable", async () => {
  const db = new FakeFirestore(seed());
  db.updateDoc("programGuestGroups/company-b",
    {programId: "program-2", organizerId: "org-2"});
  const list = await listProgramGuestGroupsHandler(request({
    programId: "program-1"}, "manager-1"), deps(db));
  await assert.rejects(groupEdit(db, {groupId: "company-b",
    label: "Other", dimension: "delegation"}), /not found/);
  assert.equal(list.groups.length, 1);
  assert.equal(list.groups[0].groupId, "side-a");
});

test("guest upserts set membership and keep memberCount exact", async () => {
  const db = new FakeFirestore(seed());
  const first = await upsertProgramGuestHandler(request({
    programId: "program-1",
    guestId: "guest-1", displayName: "Rohan Sharma", expectedRevision: 1,
    groupIds: ["side-a", "company-b"]}, "manager-1"), deps(db));
  assert.deepEqual(db.getDoc("programGuests/guest-1")!.groupIds,
    ["company-b", "side-a"]);
  assert.equal(groupDoc(db, "side-a").memberCount, 1);
  assert.equal(groupDoc(db, "company-b").memberCount, 1);
  await upsertProgramGuestHandler(request({programId: "program-1",
    guestId: "guest-1", displayName: "Rohan Sharma",
    expectedRevision: first.revision,
    groupIds: ["side-a"]}, "manager-1"), deps(db));
  assert.equal(groupDoc(db, "side-a").memberCount, 1);
  assert.equal(groupDoc(db, "company-b").memberCount, 0);
  assertGroupContracts(db);
});

test("guest upserts reject unknown or foreign groups", async () => {
  const db = new FakeFirestore(seed());
  db.updateDoc("programGuestGroups/company-b",
    {organizerId: "foreign-org"});
  await assert.rejects(upsertProgramGuestHandler(request({
    programId: "program-1", guestId: "guest-1", displayName: "Rohan Sharma",
    expectedRevision: 1, groupIds: ["nope"]}, "manager-1"), deps(db)),
  /Unknown guest group/);
  await assert.rejects(upsertProgramGuestHandler(request({
    programId: "program-1", guestId: "guest-1", displayName: "Rohan Sharma",
    expectedRevision: 1, groupIds: ["company-b"]}, "manager-1"), deps(db)),
  /reconciliation/);
});

test("deleting a group scrubs member groupIds in bounded pages", async () => {
  const db = new FakeFirestore(seed());
  db.updateDoc("programGuests/guest-1", {groupIds: ["side-a", "company-b"]});
  db.updateDoc("programGuests/guest-2", {groupIds: ["side-a"]});
  const result = await deleteProgramGuestGroupHandler(request({
    programId: "program-1", groupId: "side-a", expectedRevision: 1},
  "manager-1"), deps(db));
  assert.equal(result.entityId, "side-a");
  assert.equal(db.getDoc("programGuestGroups/side-a"), undefined);
  assert.deepEqual(db.getDoc("programGuests/guest-1")!.groupIds,
    ["company-b"]);
  assert.deepEqual(db.getDoc("programGuests/guest-2")!.groupIds, []);
  await assert.rejects(deleteProgramGuestGroupHandler(request({
    programId: "program-1", groupId: "side-a"}, "manager-1"), deps(db)),
  /not found/);
});

test("guest lists embed the referenced group labels", async () => {
  const db = new FakeFirestore(seed());
  db.updateDoc("programGuests/guest-1",
    {groupIds: ["side-a", "deleted-group"]});
  const response = await listProgramGuestsHandler(request({
    programId: "program-1"}, "manager-1"), deps(db));
  const guest = response.guests.find((g) => g.guestId === "guest-1")!;
  assert.deepEqual(guest.groupIds, ["side-a", "deleted-group"]);
  assert.deepEqual(response.groups.map((g) => g.groupId), ["side-a"]);
  assert.equal(response.groups[0].label, "Groom side");
});

test("groups pin a hotel, clear it, and preserve it when omitted",
  async () => {
    const db = new FakeFirestore(seed());
    // Omitted on create defaults to null; set links a program hotel.
    const created = await upsertProgramGuestGroupHandler(request({
      programId: "program-1", label: "Family", dimension: "relation"},
    "manager-1"), deps(db));
    assert.equal(groupDoc(db, created.entityId).hotelId, null);
    let current = groupDoc(db, created.entityId).revision as number;
    await upsertProgramGuestGroupHandler(request({
      programId: "program-1", groupId: created.entityId, label: "Family",
      dimension: "relation", expectedRevision: current,
      hotelId: "hotel-1"}, "manager-1"), deps(db));
    assert.equal(groupDoc(db, created.entityId).hotelId, "hotel-1");
    // Omitted on update preserves the link.
    current = groupDoc(db, created.entityId).revision as number;
    await upsertProgramGuestGroupHandler(request({
      programId: "program-1", groupId: created.entityId, label: "Family",
      dimension: "relation", expectedRevision: current, sortOrder: 2},
    "manager-1"), deps(db));
    assert.equal(groupDoc(db, created.entityId).hotelId, "hotel-1");
    // Explicit null clears it.
    current = groupDoc(db, created.entityId).revision as number;
    await upsertProgramGuestGroupHandler(request({
      programId: "program-1", groupId: created.entityId, label: "Family",
      dimension: "relation", expectedRevision: current, hotelId: null},
    "manager-1"), deps(db));
    assert.equal(groupDoc(db, created.entityId).hotelId, null);
    assertGroupContracts(db);
  });

test("group hotel links must live inside the same program", async () => {
  const db = new FakeFirestore(seed());
  await assert.rejects(groupEdit(db, {hotelId: "missing"}),
    /Hotel not found/);
  db.updateDoc("programHotels/hotel-1",
    {programId: "program-2", organizerId: "org-2"});
  await assert.rejects(groupEdit(db, {hotelId: "hotel-1"}),
    /Hotel not found/);
});

test("group lists project the hotel link", async () => {
  const db = new FakeFirestore(seed());
  db.updateDoc("programGuestGroups/side-a", {hotelId: "hotel-1"});
  const list = await listProgramGuestGroupsHandler(request({
    programId: "program-1"}, "manager-1"), deps(db));
  assert.equal(
    list.groups.find((g) => g.groupId === "side-a")!.hotelId, "hotel-1");
  assert.equal(
    list.groups.find((g) => g.groupId === "company-b")!.hotelId, null);
});

test("program groups reject staff without the coordinator duty", async () => {
  const db = new FakeFirestore({...seed(),
    "organizers/org-1": {
      hostUserId: "owner-1", ownerUserId: "owner-1",
      hostUserIds: ["owner-1"], hostProfiles: []},
  });
  await assert.rejects(listProgramGuestGroupsHandler(request({
    programId: "program-1"}, "manager-1"), deps(db)), /access|not found/i);
});
