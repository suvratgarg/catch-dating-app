import assert from "node:assert/strict";
import test from "node:test";
import {applySeatBatch, prepareSeatBatch, SeatBatchCommand} from
  "./seatBatch";
import {SeatAuthorityError, SeatLedger, SeatReceipt, SeatReservation,
  SeatTransaction} from "./seatAuthority";

type Subject = {key: string; revision: number};
const policyHash = "a".repeat(64);
const ledger = (): SeatLedger => ({eventId: "event-1", capacity: 1,
  occupied: 1, revision: 5, capacityRevision: 2,
  policyVersion: "v2", policyHash, migrationRevision: 3, state: "ready"});
const seated = (): SeatReservation => ({eventId: "event-1",
  canonicalKey: "old", identityRevision: 1, active: true, revision: 1,
  reservedAtMillis: 10, releasedAtMillis: null});
const command = (): SeatBatchCommand<Subject> => ({eventId: "event-1",
  batchId: "cancel-promote-1", expectedLedgerRevision: 5,
  expectedCapacityRevision: 2, expectedMigrationRevision: 3,
  nowMillis: 100, operations: [
    {subject: {key: "old", revision: 1}, operation: "release",
      requestId: "cancel-1", expectedReservationRevision: 1},
    {subject: {key: "new", revision: 1}, operation: "reserve",
      requestId: "promote-1", expectedReservationRevision: 0},
  ]});

class Store {
  ledgerValue = ledger();
  reservations = new Map<string, SeatReservation>([["old", seated()]]);
  receipts = new Map<string, SeatReceipt>();
  log: string[] = [];
  tx(): SeatTransaction {
    return {
      ledger: async () => {
        this.log.push("read-ledger");
        return {...this.ledgerValue};
      },
      reservation: async (_eventId, key) => {
        this.log.push("read-reservation:" + key);
        return this.reservations.get(key) ?? null;
      },
      receipt: async (_eventId, id) => {
        this.log.push("read-receipt:" + id);
        return this.receipts.get(id) ?? null;
      },
      putLedger: (value) => {
        this.log.push("write-ledger");
        this.ledgerValue = value;
      },
      putReservation: (value) => {
        this.log.push("write-reservation:" + value.canonicalKey);
        this.reservations.set(value.canonicalKey, value);
      },
      createReceipt: (value) => {
        this.log.push("write-receipt:" + value.requestId);
        assert.equal(this.receipts.has(value.requestId), false);
        this.receipts.set(value.requestId, value);
      },
    };
  }
  async prepare(input = command()) {
    const tx = this.tx();
    const plan = await prepareSeatBatch({tx, command: input,
      resolveIdentity: async (subject) => {
        this.log.push("read-identity:" + subject.key);
        return subject;
      }});
    return {tx, plan};
  }
}
const hasCode = (code: SeatAuthorityError["code"]) =>
  (error: unknown) => error instanceof SeatAuthorityError &&
    error.code === code;

test("last seat transfers atomically with one ledger read and revision",
  async () => {
    const store = new Store();
    const {tx, plan} = await store.prepare();
    assert.equal(store.log.filter((entry) => entry === "read-ledger")
      .length, 1);
    assert.equal(store.log.some((entry) => entry.startsWith("write")), false);
    const result = applySeatBatch(tx, plan);
    assert.equal(result.occupied, 1);
    assert.equal(store.ledgerValue.revision, 6);
    assert.equal(store.reservations.get("old")?.active, false);
    assert.equal(store.reservations.get("new")?.active, true);
    assert.equal(store.receipts.size, 2);
    const firstWrite = store.log.findIndex((entry) =>
      entry.startsWith("write"));
    assert.equal(store.log.slice(firstWrite).some((entry) =>
      entry.startsWith("read")), false);
    assert.throws(() => applySeatBatch(tx, plan), hasCode("invalid"));
    assert.throws(() => applySeatBatch(store.tx(), plan), hasCode("invalid"));
  });

test("replay is all-or-nothing and historical after further ledger changes",
  async () => {
    const store = new Store();
    const first = await store.prepare();
    applySeatBatch(first.tx, first.plan);
    store.ledgerValue = {...store.ledgerValue, revision: 7};
    const replay = await store.prepare();
    assert.equal(applySeatBatch(replay.tx, replay.plan).replayed, true);
    assert.equal(store.ledgerValue.revision, 7);
    assert.equal(store.log.filter((entry) => entry === "write-ledger")
      .length, 1);
    store.receipts.delete("promote-1");
    await assert.rejects(store.prepare(), hasCode("conflict"));
  });

test("duplicate canonical alias and partial rejection stage zero writes",
  async () => {
    const store = new Store();
    const duplicate = command();
    duplicate.operations[1].subject.key = "old";
    await assert.rejects(store.prepare(duplicate), hasCode("conflict"));
    assert.equal(store.log.some((entry) => entry.startsWith("write")), false);
    const bad = command();
    bad.operations[1].expectedReservationRevision = 1;
    await assert.rejects(store.prepare(bad), hasCode("conflict"));
    assert.equal(store.receipts.size, 0);
    assert.equal(store.ledgerValue.occupied, 1);
  });

test("stale ledger and insufficient net capacity reject before writes",
  async () => {
    const store = new Store();
    const stale = command();
    stale.expectedLedgerRevision = 4;
    await assert.rejects(store.prepare(stale), hasCode("conflict"));
    const extra = command();
    extra.operations = [...extra.operations,
      {subject: {key: "third", revision: 1},
        operation: "reserve", requestId: "promote-2",
        expectedReservationRevision: 0}];
    await assert.rejects(store.prepare(extra), hasCode("conflict"));
    assert.equal(store.log.some((entry) => entry.startsWith("write")), false);
  });
