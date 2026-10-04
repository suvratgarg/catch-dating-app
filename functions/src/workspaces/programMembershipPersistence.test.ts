import assert from "node:assert/strict";
import test from "node:test";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {planImportedMembership, planManualMembership} from
  "./programMembershipPersistence";
import type {ScopedMembershipGuest} from "./programMembershipPersistence";
import {membershipAssertionMatches} from "./workspaceMembershipAuthority";

const source = {programId: "program", organizerId: "org", guestId: "guest",
  groupIds: ["family", "friends"], operationId: "list-one", rowIndex: 0,
  actorUid: "host", observedAtMillis: 1};

test("import suggests membership without duplicate demand", () => {
  const result = planImportedMembership({...source, guest: {groupIds: []}});
  assert.deepEqual(result.projection.groupIds, []);
  assert.equal(result.projection.suggestions.length, 2);
  for (const write of result.writes) {
    assert.equal((write.data as {sourceLabel: string}).sourceLabel,
      "Manifest row 1");
    assert.equal((write.data as {included: boolean}).included, true);
  }
  const repeated = planImportedMembership({...source, guest: {
    groupIds: result.projection.groupIds,
    membershipSuggestions: result.projection.suggestions}});
  assert.deepEqual(repeated.projection, result.projection);
});

test("persisted manual includes and excludes survive repeated changed lists",
  async () => {
    const first = planImportedMembership({...source, guest: {groupIds: []}});
    const fake = new FakeFirestore(Object.fromEntries(first.writes
      .map((w) => [w.path, {...w.data}])));
    const db = fake as unknown as FirebaseFirestore.Firestore;
    const guest: Partial<ScopedMembershipGuest> = {groupIds: [],
      membershipSuggestions: first.projection.suggestions};
    const chosen = await db.runTransaction(async (tx) =>
      planManualMembership({...source, db, tx, guest, groupIds: ["friends"],
        currentRevision: 2, nextRevision: 3, observedAtMillis: 2}));
    for (const write of chosen.writes) fake.setDoc(write.path, {...write.data});
    assert.deepEqual(chosen.projection.groupIds, ["friends"]);
    assert.deepEqual(chosen.projection.suggestions, []);
    let projection = chosen.projection;
    for (let i = 2; i < 6; i++) {
      projection = planImportedMembership({...source,
        operationId: `list-${i}`, observedAtMillis: i,
        guest: {groupIds: projection.groupIds,
          membershipSelections: projection.selections,
          membershipSuggestions: projection.suggestions}}).projection;
      assert.deepEqual(projection.groupIds, ["friends"]);
      assert.deepEqual(projection.selections, chosen.projection.selections);
    }
    const family = chosen.projection.selections
      .find((s) => s.groupId === "family")!;
    assert.equal(fake.getDoc(
      `workspaceMembershipAssertions/${family.assertionId}`)
      ?.included, false);
    const next = await db.runTransaction(async (tx) =>
      planManualMembership({...source, db, tx, guest: {
        groupIds: projection.groupIds,
        membershipSelections: projection.selections,
        membershipSuggestions: projection.suggestions}, groupIds: ["family"],
      currentRevision: 3, nextRevision: 4, observedAtMillis: 7}));
    assert.deepEqual(next.projection.groupIds, ["family"]);
  });

test("manual writer rejects a foreign selected pointer before any mutation",
  async () => {
    const imported = planImportedMembership({...source, guest: {groupIds: []}});
    const write = imported.writes[0];
    const id = write.path.split("/")[1];
    const fake = new FakeFirestore({[write.path]: {...write.data,
      organizerId: "foreign"}});
    const db = fake as unknown as FirebaseFirestore.Firestore;
    await assert.rejects(db.runTransaction((tx) => planManualMembership({
      ...source, db, tx, guest: {groupIds: ["family"],
        membershipSelections: [{groupId: "family", assertionId: id}]},
      currentRevision: 2, nextRevision: 3})), /needs reconciliation/);
    assert.equal(fake.getDoc("programGuests/guest"), undefined);
    assert.equal(membershipAssertionMatches(undefined, id, {
      workspaceRef: {kind: "program", id: "program"}, organizerId: "org",
      relationshipRef: {kind: "programGuest", id: "guest"},
      groupId: "family"}), false);
  });
