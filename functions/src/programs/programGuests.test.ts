import assert from "node:assert/strict";
import test from "node:test";
import {baseSeed, deps, request, now} from "../shared/testing/programFixtures";
import {FakeFirestore, type FakeData} from
  "../shared/testing/programFirestore";
import {listProgramGuestsHandler, listProgramHouseholdsHandler,
  upsertProgramGuestHandler,
  upsertProgramHouseholdHandler} from "./programGuests";
import {importProgramManifestHandler} from "./programManifestImport";
import {validateProgramHouseholdDocument} from
  "../shared/generated/validators/programHouseholdDocument";

const household = (members: string[]): FakeData => ({
  programId: "program-1", organizerId: "org-1", label: "Family",
  primaryContactName: "Household contact", primaryPhoneE164: "+919900000000",
  primaryEmail: null, memberGuestIds: members, deliveryPreference: "none",
  createdAt: now, updatedAt: now, revision: 1,
});
const seed = () => ({...baseSeed(),
  "programHouseholds/first": household(["guest-1"]),
  "programHouseholds/second": household(["guest-2"]),
  "programGuests/guest-1": {...baseSeed()["programGuests/guest-1"],
    householdId: "first", externalReference: "person-one"},
  "programGuests/guest-2": {...baseSeed()["programGuests/guest-2"],
    householdId: "second"},
});
const members = (db: FakeFirestore, id: string) =>
  db.getDoc(`programHouseholds/${id}`)!.memberGuestIds;
const guestEdit = (db: FakeFirestore, patch: object = {}) =>
  upsertProgramGuestHandler(request({programId: "program-1",
    guestId: "guest-1", displayName: "Rohan Sharma", expectedRevision: 1,
    ...patch}, "manager-1"), deps(db));
const householdEdit = (db: FakeFirestore, patch: object = {}) =>
  upsertProgramHouseholdHandler(request({programId: "program-1",
    householdId: "first", label: "Updated family",
    primaryContactName: "Household contact", expectedRevision: 1,
    memberGuestIds: ["guest-1"], ...patch}, "manager-1"), deps(db));

function assertHouseholdContracts(db: FakeFirestore) {
  for (const [path, doc] of db.docs) {
    if (!path.startsWith("programHouseholds/")) continue;
    assert.ok(validateProgramHouseholdDocument(doc),
      `${path}: ${JSON.stringify(validateProgramHouseholdDocument.errors)}`);
  }
}

test("guest moves update both households and retain the empty contact record",
  async () => {
    const db = new FakeFirestore(seed());
    await guestEdit(db, {householdId: "second"});
    assert.deepEqual(members(db, "first"), []);
    assert.deepEqual(members(db, "second"), ["guest-1", "guest-2"]);
    assert.equal(db.getDoc("programGuests/guest-1")!.householdId, "second");
    assert.equal(db.getDoc("programHouseholds/first")!.primaryPhoneE164,
      "+919900000000");
    assertHouseholdContracts(db);
  });

test("clearing a household removes the guest from canonical membership",
  async () => {
    const db = new FakeFirestore(seed());
    await guestEdit(db, {householdId: null});
    assert.deepEqual(members(db, "first"), []);
    assert.equal(db.getDoc("programGuests/guest-1")!.householdId, null);
  });

test("profile edits preserve membership without advancing household revision",
  async () => {
    const db = new FakeFirestore(seed());
    const before = db.getDoc("programHouseholds/first");
    await guestEdit(db, {displayName: "Updated name"});
    assert.deepEqual(db.getDoc("programHouseholds/first"), before);
  });

test("household replacement detaches removed guests and moves new members",
  async () => {
    const db = new FakeFirestore(seed());
    await householdEdit(db, {memberGuestIds: ["guest-2"]});
    assert.deepEqual(members(db, "first"), ["guest-2"]);
    assert.deepEqual(members(db, "second"), []);
    assert.equal(db.getDoc("programGuests/guest-1")!.householdId, null);
    assert.equal(db.getDoc("programGuests/guest-2")!.householdId, "first");
    assertHouseholdContracts(db);
  });

test("household can release its final member without deleting contact details",
  async () => {
    const db = new FakeFirestore(seed());
    await householdEdit(db, {memberGuestIds: []});
    assert.deepEqual(members(db, "first"), []);
    assert.equal(db.getDoc("programGuests/guest-1")!.householdId, null);
    assertHouseholdContracts(db);
  });

test("a new guest joins its household in the same transaction", async () => {
  const db = new FakeFirestore(seed());
  const result = await upsertProgramGuestHandler(request({
    programId: "program-1", displayName: "New guest", householdId: "first",
  }, "manager-1"), deps(db));
  assert.deepEqual(new Set(members(db, "first") as string[]),
    new Set(["guest-1", result.entityId]));
});

for (const edit of [guestEdit, householdEdit]) {
  test(`${edit.name} rechecks current manager authority on contention`,
    async () => {
      const db = new FakeFirestore(seed());
      const before = db.getDoc("programGuests/guest-1");
      db.beforeCommit = async () => {
        db.beforeCommit = undefined;
        db.updateDoc("organizers/org-1", {ownerUserId: "other",
          hostUserId: "other", hostUserIds: ["other"], hostProfiles: []});
      };
      await assert.rejects(edit(db), /active program access/);
      assert.equal(db.transactionCommits, 0);
      assert.deepEqual(db.getDoc("programGuests/guest-1"), before);
      assert.deepEqual(members(db, "first"), ["guest-1"]);
    });
}

for (const path of ["programHouseholds/first", "programHouseholds/second",
  "programGuests/guest-2"]) {
  test(`foreign ownership at ${path} blocks household replacement`,
    async () => {
      const db = new FakeFirestore(seed());
      db.updateDoc(path, {organizerId: "foreign-org"});
      const before = new Map(db.docs);
      await assert.rejects(householdEdit(db, {memberGuestIds: ["guest-2"]}));
      assert.deepEqual(db.docs, before);
    });
}

test("changed related guest ownership causes a transaction retry and rejection",
  async () => {
    const db = new FakeFirestore(seed());
    db.beforeCommit = async () => {
      db.beforeCommit = undefined;
      db.updateDoc("programGuests/guest-2", {programId: "foreign-program"});
    };
    await assert.rejects(householdEdit(db, {memberGuestIds: ["guest-2"]}),
      /reconciliation/);
    assert.deepEqual(members(db, "first"), ["guest-1"]);
    assert.deepEqual(members(db, "second"), ["guest-2"]);
  });

test("full destination household rejects a guest move atomically", async () => {
  const db = new FakeFirestore(seed());
  db.updateDoc("programHouseholds/second", {
    memberGuestIds: Array.from({length: 50}, (_, i) => `member-${i}`),
  });
  const before = new Map(db.docs);
  await assert.rejects(guestEdit(db, {householdId: "second"}), /50 guests/);
  assert.deepEqual(db.docs, before);
});

test("missing household with an expected revision is not recreated",
  async () => {
    const db = new FakeFirestore(seed());
    await assert.rejects(householdEdit(db, {householdId: "missing"}),
      /does not exist/);
    assert.equal(db.getDoc("programHouseholds/missing"), undefined);
  });

test("stale household revision withholds all membership updates", async () => {
  const db = new FakeFirestore(seed());
  db.updateDoc("programHouseholds/first", {revision: 5});
  const before = new Map(db.docs);
  await assert.rejects(householdEdit(db, {memberGuestIds: ["guest-2"]}),
    /Record changed/);
  assert.deepEqual(db.docs, before);
});

test("removing a stale member cannot clear another household's guest pointer",
  async () => {
    const db = new FakeFirestore(seed());
    db.updateDoc("programGuests/guest-1", {householdId: "second"});
    const before = new Map(db.docs);
    await assert.rejects(householdEdit(db, {memberGuestIds: []}), /disagree/);
    assert.deepEqual(db.docs, before);
  });

test("imports use the same membership move and retain an empty old household",
  async () => {
    const db = new FakeFirestore(seed());
    db.updateDoc("programHouseholds/second", {label: "Other family"});
    const result = await importProgramManifestHandler(request({
      programId: "program-1", mode: "commit", clientOperationId: "move-import",
      rows: [{displayName: "Rohan Sharma", externalReference: "person-one",
        householdLabel: "Other family"}],
    }, "manager-1"), deps(db));
    assert.equal(result.guestsUpdated, 1);
    assert.deepEqual(members(db, "first"), []);
    assert.deepEqual(members(db, "second"), ["guest-1", "guest-2"]);
    assertHouseholdContracts(db);
  });

test("equal-name guests remain visible across every page boundary",
  async () => {
    const db = new FakeFirestore(baseSeed());
    db.updateDoc("programGuests/guest-1", {displayName: "Same Name"});
    db.updateDoc("programGuests/guest-2", {displayName: "Same Name"});
    db.setDoc("programGuests/guest-3", {...db.getDoc("programGuests/guest-1")});
    const seen: string[] = [];
    let cursor: string | null = null;
    do {
      const page = await listProgramGuestsHandler(request({
        programId: "program-1", limit: 1, ...(cursor ? {cursor} : {}),
      }, "manager-1"), deps(db));
      seen.push(...page.guests.map((guest) => guest.guestId));
      cursor = page.nextCursor;
      assert.ok(seen.length <= 3);
    } while (cursor);
    assert.deepEqual(seen, ["guest-1", "guest-2", "guest-3"]);
  });


test("household inventory reports overflow instead of silently dropping rows",
  async () => {
    const db = new FakeFirestore(baseSeed());
    for (let i = 0; i < 501; i++) {
      db.setDoc(`programHouseholds/group-${i}`, household([]));
    }
    await assert.rejects(listProgramHouseholdsHandler(request({
      programId: "program-1",
    }, "manager-1"), deps(db)), /500-record limit/);
  });

test("guest inventory rejects foreign ownership and cursor references",
  async () => {
    const db = new FakeFirestore(seed());
    db.updateDoc("programGuests/guest-2", {organizerId: "foreign"});
    await assert.rejects(listProgramGuestsHandler(request({
      programId: "program-1",
    }, "manager-1"), deps(db)), /ownership needs reconciliation/);
    await assert.rejects(listProgramGuestsHandler(request({
      programId: "program-1", cursor: "guest-2",
    }, "manager-1"), deps(db)), /Unknown page cursor/);
  });

test("missing previous households cannot be silently replaced by guest edits",
  async () => {
    const db = new FakeFirestore(seed());
    db.updateDoc("programGuests/guest-1", {householdId: "missing"});
    const before = new Map(db.docs);
    await assert.rejects(guestEdit(db, {householdId: "second"}),
      /ownership needs reconciliation/);
    assert.deepEqual(db.docs, before);
  });

test("invalid household membership fails before loading an unbounded roster",
  async () => {
    const db = new FakeFirestore(seed());
    db.updateDoc("programHouseholds/first", {
      memberGuestIds: Array.from({length: 51}, (_, i) => `guest-${i}`),
    });
    await assert.rejects(householdEdit(db), /membership needs reconciliation/);
    assert.equal(db.transactionCommits, 0);
  });
