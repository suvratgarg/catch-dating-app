import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {baseSeed, now} from "../shared/testing/programFixtures";
import {requireProgramAccess} from "../shared/programAuthority";
import {lodgingEvidenceFingerprint, prepareLodgingRevisionFence,
  readCanonicalLodgingRecords} from "./programLodgingSource";

const scope = {organizerId: "org-1", programId: "program-1"};
const emptyEvidence = {source: [], inventory: [], layout: [], published: []};
function database(seed = baseSeed()) {
  const fake = new FakeFirestore(seed);
  return {fake, db: fake as unknown as FirebaseFirestore.Firestore};
}

test("native source includes no-travel guests and rejects truncation",
  async () => {
    const {db, fake} = database();
    fake.setDoc("programGuests/no-flight", {
      ...fake.getDoc("programGuests/guest-1"), displayName: "No flight"});
    fake.setDoc("programGuests/foreign", {
      ...fake.getDoc("programGuests/guest-1"), organizerId: "other"});
    const read = () => db.runTransaction(async (tx) => {
      const access = await requireProgramAccess({db, transaction: tx,
        programId: scope.programId, actorUid: "manager-1", now});
      return readCanonicalLodgingRecords(tx, db, access, scope.programId);
    });
    const records = await read();
    assert.deepEqual(records.guests.map((g) => g.id),
      ["guest-1", "guest-2", "no-flight"]);
    for (let i = 0; i < 498; i++) {
      fake.setDoc("programGuests/extra-" + i,
        {...fake.getDoc("programGuests/guest-1")});
    }
    await assert.rejects(read(), /complete-read limit/);
  });

test("source fingerprints canonicalize maps but preserve timestamps and arrays",
  () => {
    const first = {name: "guest", at: Timestamp.fromMillis(1000)};
    assert.equal(lodgingEvidenceFingerprint(first),
      lodgingEvidenceFingerprint({at: Timestamp.fromMillis(1000),
        name: "guest"}));
    assert.notEqual(lodgingEvidenceFingerprint(first),
      lodgingEvidenceFingerprint({...first, at: Timestamp.fromMillis(1001)}));
    assert.notEqual(lodgingEvidenceFingerprint(new Timestamp(1, 1)),
      lodgingEvidenceFingerprint(new Timestamp(1, 2)));
    assert.notEqual(lodgingEvidenceFingerprint(Timestamp.fromMillis(1000)),
      lodgingEvidenceFingerprint(["timestamp", 1, 0]));
    assert.throws(() => lodgingEvidenceFingerprint(new Date()), /Unsupported/);
    assert.notEqual(lodgingEvidenceFingerprint([1, 2]),
      lodgingEvidenceFingerprint([2, 1]));
    assert.throws(() => lodgingEvidenceFingerprint({missing: undefined}),
      /Unsupported/);
  });

test("native edits advance counters even when snapshot counts stay equal",
  async () => {
    const {db, fake} = database();
    const read = () => db.runTransaction(async (tx) => {
      const guest = await tx.get(db.collection("programGuests").doc("guest-1"));
      const fence = await prepareLodgingRevisionFence(tx, db, scope,
        {...emptyEvidence, source: guest.data()});
      fence.persist();
      return fence.revisions;
    });
    const first = await read();
    assert.deepEqual(first, {source: 1, inventory: 1, layout: 1, published: 1});
    assert.deepEqual(await read(), first);
    fake.updateDoc("programGuests/guest-1", {groupIds: ["friends"]});
    assert.deepEqual(await read(), {...first, source: 2});
    fake.updateDoc("programGuests/guest-1", {groupIds: ["family"]});
    assert.deepEqual(await read(), {...first, source: 3});
  });

test("racing previews share one revision and publication/check-in advance it",
  async () => {
    const {db, fake} = database();
    const evidence = [{id: "stay", status: "confirmed"}];
    const preview = () => db.runTransaction(async (tx) => {
      const fence = await prepareLodgingRevisionFence(tx, db, scope,
        emptyEvidence);
      fence.persist();
      return fence.revisions;
    });
    const [a, b] = await Promise.all([preview(), preview()]);
    assert.deepEqual(a, b);
    await db.runTransaction(async (tx) => {
      const fence = await prepareLodgingRevisionFence(tx, db, scope,
        emptyEvidence);
      tx.set(db.collection("programStays").doc("stay"), evidence[0]);
      fence.publish(evidence);
    });
    const readPublished = (published: unknown) => db.runTransaction(
      async (tx) => {
        const fence = await prepareLodgingRevisionFence(tx, db, scope,
          {...emptyEvidence, published});
        return fence.revisions.published;
      });
    assert.equal(await readPublished(evidence), a.published + 1);
    fake.updateDoc("programStays/stay", {status: "checkedIn"});
    assert.equal(await readPublished([fake.getDoc("programStays/stay")]),
      a.published + 2);
  });

test("source fence rejects foreign scope and rolls back with native writes",
  async () => {
    const {db, fake} = database();
    await assert.rejects(db.runTransaction(async (tx) => {
      const fence = await prepareLodgingRevisionFence(tx, db, scope,
        emptyEvidence);
      fence.persist();
      throw new Error("Abort prepared publication");
    }), /Abort/);
    assert.equal(fake.getDoc("programLodgingSourceVersions/program-1"),
      undefined);
    await db.runTransaction(async (tx) => {
      const fence = await prepareLodgingRevisionFence(tx, db, scope,
        emptyEvidence);
      fence.persist();
    });
    fake.updateDoc("programLodgingSourceVersions/program-1",
      {organizerId: "foreign"});
    await assert.rejects(db.runTransaction((tx) =>
      prepareLodgingRevisionFence(tx, db, scope, emptyEvidence)),
    /Invalid lodging source fence/);
  });
