import assert from "node:assert/strict";
import test from "node:test";
import type {TransportOperationReceiptDocument} from
  "../shared/generated/firestoreAdminTypes";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {completedManifestRows} from "./programManifestChunks";
import {seed, request, deps, row, ts, NOW} from "./programManifestFixture";
import {importProgramManifestHandler} from "./programManifestImport";

const records = (store: FakeFirestore, collection: string) =>
  [...store.docs.entries()].filter(([path]) =>
    path.startsWith(`${collection}/`));
const sourceRow = (index: number) => ({...row,
  displayName: `Guest ${index}`, externalReference: `ref-${index}`,
  householdLabel: `Family ${index}`, partyLabel: `Party ${index}`,
});
const payload = (rows: unknown[]) => ({programId: "program-1",
  mode: "commit", clientOperationId: "chunk-import-test", rows});

for (const progress of [
  {completedRows: -1}, {completedRows: 1e20}, {completedRows: 1.5},
  {completedRows: 2, completedRowIndices: [0, 0]},
  {completedRows: 1, completedRowIndices: [2]},
  {completedRows: 1, completedRowIndices: [0.5]},
  {completedRows: 1, completedRowIndices: []},
  {completedRows: 1, completedRowIndices: "0"},
]) {
  test(`corrupt import progress fails closed: ${JSON.stringify(progress)}`,
    () => {
      assert.throws(() => completedManifestRows(progress as unknown as
        TransportOperationReceiptDocument, 2), /needs reconciliation/);
    });
}

test("legacy completed receipts and prefix cursors remain readable", () => {
  const receipt = (value: object) => value as
    TransportOperationReceiptDocument;
  assert.deepEqual(completedManifestRows(undefined, 3), []);
  assert.deepEqual(completedManifestRows(receipt({}), 3), [0, 1, 2]);
  assert.deepEqual(completedManifestRows(receipt({completedRows: 2}), 3),
    [0, 1]);
  assert.deepEqual(completedManifestRows(receipt({completedRows: 2,
    completedRowIndices: [2, 0]}), 3), [0, 2]);
});

test("invalid last member never publishes the rest of its interleaved party",
  async () => {
    const store = new FakeFirestore(seed());
    const rows = Array.from({length: 65}, (_, index) => ({
      ...sourceRow(index), partyLabel: `Party ${index % 2}`,
    }));
    rows[64].destinationHotelName = "Missing hotel";
    const preview = await importProgramManifestHandler(
      request({...payload(rows), mode: "preview"}), deps(store));
    const committed = await importProgramManifestHandler(
      request(payload(rows)), deps(store));
    assert.deepEqual(committed, {...preview, mode: "commit"});
    assert.equal(committed.guestsCreated, 32);
    const rejected = new Set(committed.rowErrors.map((issue) => issue.index));
    assert.deepEqual([...rejected],
      Array.from({length: 33}, (_, i) => i * 2));
    assert.deepEqual(records(store, "programTravelParties")
      .map(([, party]) => party.label), ["Party 1"]);
    assert.equal(records(store, "programHouseholds").length, 32);
  });

test("a rejected party consumes no shared household capacity", async () => {
  const store = new FakeFirestore(seed());
  const rows = Array.from({length: 52}, (_, index) => ({
    ...sourceRow(index), householdLabel: "Shared family",
    partyLabel: index < 2 ? "Invalid party" : "Valid party",
  }));
  rows[1].destinationHotelName = "Missing hotel";
  const result = await importProgramManifestHandler(request(payload(rows)),
    deps(store));
  assert.equal(result.guestsCreated, 50);
  assert.deepEqual([...new Set(result.rowErrors.map((issue) => issue.index))],
    [0, 1]);
  assert.equal((records(store, "programHouseholds")[0][1]
    .memberGuestIds as string[]).length, 50);
});

test("a reordered later duplicate does not poison its earlier source row",
  async () => {
    const store = new FakeFirestore(seed());
    const rows = Array.from({length: 100}, (_, index) => sourceRow(index));
    rows[99] = {...rows[2], partyLabel: rows[0].partyLabel};
    const result = await importProgramManifestHandler(request(payload(rows)),
      deps(store));
    assert.equal(result.guestsCreated, 98);
    assert.deepEqual(result.rowErrors.map((issue) => issue.index), [0, 99]);
    assert.equal(records(store, "programGuests")
      .filter(([, guest]) => guest.externalReference === "ref-2").length, 1);
    assert.equal(records(store, "programGuests")
      .filter(([, guest]) => guest.externalReference === "ref-0").length, 0);
  });

test("omitted party labels still bind existing members to requested additions",
  async () => {
    const store = new FakeFirestore(seed());
    await importProgramManifestHandler(request({...payload([sourceRow(0)]),
      clientOperationId: "seed-existing-party"}), deps(store));
    const [guestPath, guest] = records(store, "programGuests")[0];
    const result = await importProgramManifestHandler(request(payload([
      {...sourceRow(0), partyLabel: undefined, phoneE164: "+919999999999"},
      {...sourceRow(1), partyLabel: "Party 0",
        destinationHotelName: "Missing hotel"},
    ])), deps(store));
    assert.equal(result.guestsUpdated, 0);
    assert.equal(result.guestsCreated, 0);
    assert.deepEqual([...new Set(result.rowErrors.map((issue) => issue.index))],
      [0, 1]);
    assert.deepEqual(store.getDoc(guestPath), guest);
  });

test("500 independent rows publish at most 50 per transaction and replay once",
  async () => {
    const store = new FakeFirestore(seed());
    const rows = Array.from({length: 500}, (_, index) => sourceRow(index));
    const counts: number[] = [];
    store.beforeCommit = async () => {
      counts.push(records(store, "programGuests").length);
    };
    const result = await importProgramManifestHandler(request(payload(rows)),
      deps(store));
    assert.equal(result.guestsCreated, 500);
    assert.equal(result.rowErrors.length, 0);
    assert.deepEqual(counts, Array.from({length: 10}, (_, i) => i * 50));
    const replay = await importProgramManifestHandler(request(payload(rows)),
      deps(store));
    assert.deepEqual(replay, {...result, alreadyApplied: true});
    assert.equal(records(store, "programGuests").length, 500);
  });

test("legacy prefix receipts resume without reapplying completed rows",
  async () => {
    const store = new FakeFirestore(seed());
    const rows = Array.from({length: 60}, (_, index) => sourceRow(index));
    store.beforeCommit = async () => {
      if (store.transactionCommits === 1) throw new Error("interrupted");
    };
    await assert.rejects(importProgramManifestHandler(request(payload(rows)),
      deps(store)), /interrupted/);
    const [receiptPath, receipt] = records(store,
      "transportOperationReceipts")[0];
    const legacy = {...receipt};
    delete legacy.completedRowIndices;
    store.setDoc(receiptPath, legacy);
    store.beforeCommit = undefined;
    const result = await importProgramManifestHandler(request(payload(rows)),
      deps(store));
    assert.equal(result.guestsCreated, 60);
    assert.equal(records(store, "programGuests").length, 60);
    assert.equal(result.guestsUpdated, 0);
  });

test("revoking authority between transactions stops remaining parties",
  async () => {
    const store = new FakeFirestore({...seed(),
      "programStaffGrants/program-1__coordinator": {
        programId: "program-1", organizerId: "org-1", uid: "coordinator",
        status: "active", duties: [{duty: "programCoordinator"}],
        expiresAt: ts(NOW + 3600_000),
      },
    });
    const rows = Array.from({length: 60}, (_, index) => sourceRow(index));
    store.beforeCommit = async () => {
      if (store.transactionCommits === 1) {
        store.beforeCommit = undefined;
        store.updateDoc("programStaffGrants/program-1__coordinator",
          {status: "revoked"});
      }
    };
    await assert.rejects(importProgramManifestHandler(
      request(payload(rows), "coordinator"), deps(store)),
    (error: unknown) =>
      (error as {code?: string}).code === "permission-denied");
    assert.equal(records(store, "programGuests").length, 50);
    const receipt = records(store, "transportOperationReceipts")[0][1];
    assert.equal(receipt.completedRows, 50);
  });
