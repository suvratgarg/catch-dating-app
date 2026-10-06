import assert from "node:assert/strict";
import test from "node:test";
import type {Firestore, Transaction} from "firebase-admin/firestore";
import {FakeFirestore} from "../operations/testFirestore";
import {previewHostRosterIntake} from "./hostRosterIntakeCore";
import {
  AuthorizeHostRosterSession,
  HostRosterIntakeSessionStore,
} from "./hostRosterIntakeSessionStore";

const row = {value: {rowId: "2", displayName: "Asha Shah",
  externalReference: "ticket-7", status: "registered" as const},
sourceRowNumber: 2,
fields: {displayName: {column: 0, header: "Name",
  origin: "upload" as const, confidence: null},
externalReference: {column: 1, header: "Attendee ID",
  origin: "upload" as const, confidence: null}}};

const input = {hostUid: "host-1", organizerId: "organizer-1",
  eventId: "event-1", fileFingerprint: "b".repeat(64),
  fileName: "guests.csv", format: "csv" as const,
  headers: ["Name", "Attendee ID"],
  mapping: {displayName: 0, externalReference: 1}, rows: [row]};

function harness() {
  const db = new FakeFirestore();
  let allowed = true;
  let now = 10;
  const authorize: AuthorizeHostRosterSession = async (scope) => {
    assert.equal(scope.hostUid, "host-1");
    assert.equal(scope.organizerId, "organizer-1");
    assert.equal(scope.eventId, "event-1");
    if (!allowed) throw new Error("manager revoked");
  };
  const store = new HostRosterIntakeSessionStore(
    db as unknown as Firestore, () => ++now);
  return {db, store, authorize, revoke: () => {
    allowed = false;
  }};
}

test("upload resumes a durable event/account scoped private draft",
  async () => {
    const {db, store, authorize, revoke} = harness();
    const first = await store.createOrResume(input, authorize);
    const restarted = new HostRosterIntakeSessionStore(
      db as unknown as Firestore);
    assert.deepEqual(await restarted.get({sessionId: first.sessionId,
      hostUid: "host-1"}, authorize), first);
    assert.deepEqual(await restarted.createOrResume({...input,
      fileName: "renamed.csv"}, authorize), first);
    await assert.rejects(restarted.get({sessionId: first.sessionId,
      hostUid: "other-account"}, authorize), /another account/u);
    await assert.rejects(restarted.revise({sessionId: first.sessionId,
      hostUid: "host-1", expectedRevision: 0, rows: first.rows,
      excludedRowIds: []}, authorize), /Stale/u);
    revoke();
    await assert.rejects(restarted.get({sessionId: first.sessionId,
      hostUid: "host-1"}, authorize), /manager revoked/u);
  });

test("revision, failed commit and receipt replay preserve every row",
  async () => {
    const {db, store, authorize} = harness();
    const first = await store.createOrResume(input, authorize);
    const revised = await store.revise({sessionId: first.sessionId,
      hostUid: "host-1", expectedRevision: 1,
      rows: first.rows, excludedRowIds: []}, authorize);
    assert.equal(revised.revision, 2);
    assert.deepEqual(revised.rows, first.rows);
    const preview = previewHostRosterIntake({draft: revised,
      currentRows: new Map()});
    const complete = async (replayed: boolean) => db.runTransaction(
      async (tx) => {
        const commit = await store.prepareCompletion({
          tx: tx as unknown as Transaction,
          sessionId: first.sessionId, hostUid: "host-1",
          expectedDraft: revised, preview,
          importId: "receipt-1", replayed,
          authorize});
        commit();
      });
    db.failNextCommit = true;
    await assert.rejects(complete(false), /transaction interruption/u);
    assert.equal((await store.get({sessionId: first.sessionId,
      hostUid: "host-1"}, authorize))?.state, "review");
    await complete(false);
    const applied = await store.get({sessionId: first.sessionId,
      hostUid: "host-1"}, authorize);
    assert.equal(applied?.state, "applied");
    assert.equal(applied?.appliedImportId, "receipt-1");
    assert.deepEqual(applied?.rows, first.rows);
    const reviewReceipt = await store.getAppliedReview({
      sessionId: first.sessionId, hostUid: "host-1"}, authorize);
    assert.equal(reviewReceipt?.importId, "receipt-1");
    assert.equal(reviewReceipt?.preview.counts.add, 1);
    assert.equal(reviewReceipt?.preview.reviewHash, preview.reviewHash);
    await complete(true);
    await assert.rejects(store.revise({sessionId: first.sessionId,
      hostUid: "host-1", expectedRevision: 2, rows: first.rows,
      excludedRowIds: []}, authorize), /Stale/u);
    await assert.rejects(db.runTransaction(async (tx) => {
      await store.prepareCompletion({tx: tx as unknown as Transaction,
        sessionId: first.sessionId, hostUid: "host-1",
        expectedDraft: revised, preview, importId: "wrong-receipt",
        replayed: true,
        authorize});
    }), /Unmatched/u);
  });
