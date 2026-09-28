import assert from "node:assert/strict";
import test from "node:test";
import {applyTemporaryHold, prepareTemporaryHold,
  TemporaryHoldCommand} from "./temporarySeatHold";
import {applyCheckoutHold, prepareCheckoutHold} from "./checkoutSeatHold";
import {applySeatCommand, SeatLedger, SeatReceipt,
  SeatReservation, SeatTransaction} from "./seatAuthority";
import {prepareSeatBatch} from "./seatBatch";

class Store implements SeatTransaction {
  value: SeatLedger = {eventId: "event", capacity: 1, occupied: 0,
    revision: 1, capacityRevision: 1, migrationRevision: 1,
    policyVersion: "v1", policyHash: "a".repeat(64), state: "ready"};
  rows = new Map<string, SeatReservation>();
  receipts = new Map<string, SeatReceipt>();
  writes = 0;
  async ledger() {
    return this.value;
  }
  async reservation(_event: string, key: string) {
    return this.rows.get(key) ?? null;
  }
  async receipt(_event: string, key: string) {
    return this.receipts.get(key) ?? null;
  }
  putLedger(value: SeatLedger) {
    this.value = value; this.writes++;
  }
  putReservation(value: SeatReservation) {
    this.rows.set(value.canonicalKey, value); this.writes++;
  }
  createReceipt(value: SeatReceipt) {
    assert.ok(!this.receipts.has(value.requestId));
    this.receipts.set(value.requestId, value); this.writes++;
  }
  command(overrides: Partial<TemporaryHoldCommand<string>> = {}):
    TemporaryHoldCommand<string> {
    const subject = overrides.subject ?? "person";
    return {eventId: "event", subject, operation: "temporaryHold",
      ownerKind: "crossPathsPair", ownerId: "pair", expiresAtMillis: 301000,
      requestId: "start", expectedLedgerRevision: this.value.revision,
      expectedCapacityRevision: 1, expectedMigrationRevision: 1,
      expectedReservationRevision: this.rows.get(subject)?.revision ?? 0,
      nowMillis: 1000, ...overrides};
  }
  async execute(command = this.command()) {
    const plan = await prepareTemporaryHold({tx: this, command,
      resolveIdentity});
    applyTemporaryHold(this, plan);
    return plan;
  }
}
const resolveIdentity = async (key: string) => ({key, revision: 1});

test("pair, checkout and ordinary registration contend for one last seat",
  async () => {
    for (const first of ["pair", "checkout", "ordinary"]) {
      const store = new Store();
      const command = store.command();
      if (first === "pair") await store.execute();
      else if (first === "checkout") {
        const plan = await prepareCheckoutHold({tx: store,
          command: {eventId: command.eventId, subject: command.subject,
            operation: "checkoutHold", paymentId: "pay",
            requestId: command.requestId, expectedLedgerRevision: 1,
            expectedCapacityRevision: 1, expectedMigrationRevision: 1,
            expectedReservationRevision: 0, nowMillis: 1000},
          resolveIdentity});
        applyCheckoutHold(store, plan);
      } else {
        await applySeatCommand({tx: store,
          command: {...command, operation: "reserve"}, resolveIdentity});
      }
      const next = store.command({subject: "other", requestId: "other"});
      await assert.rejects(store.execute(next), /full/u);
      await assert.rejects(prepareCheckoutHold({tx: store,
        command: {eventId: next.eventId, subject: next.subject,
          operation: "checkoutHold", paymentId: "pay-two",
          requestId: next.requestId,
          expectedLedgerRevision: next.expectedLedgerRevision,
          expectedCapacityRevision: 1, expectedMigrationRevision: 1,
          expectedReservationRevision: 0, nowMillis: 1000},
        resolveIdentity}), /full/u);
      await assert.rejects(applySeatCommand({tx: store,
        command: {...next, operation: "reserve"}, resolveIdentity}), /full/u);
      assert.equal(store.writes, 3);
    }
  });

test("pair confirmation pins owner and deadline; replay cannot renew or revive",
  async () => {
    const store = new Store();
    const original = store.command();
    const plan = await store.execute(original);
    assert.ok(Object.isFrozen(plan.reservation?.temporaryHold));
    for (const bad of [{ownerId: "other"}, {expiresAtMillis: 300000}]) {
      await assert.rejects(store.execute(store.command({
        operation: "confirmTemporaryHold", requestId: "bad", ...bad})),
      /does not own/u);
    }
    await assert.rejects(store.execute(store.command({
      operation: "confirmTemporaryHold", requestId: "late",
      nowMillis: original.expiresAtMillis})), /expired/u);
    const confirm = store.command({operation: "confirmTemporaryHold",
      requestId: "confirm", nowMillis: 2000});
    await store.execute(confirm);
    await store.execute({...confirm, nowMillis: 400000});
    await store.execute({...original, nowMillis: 400000});
    assert.equal(store.value.occupied, 1);
    assert.equal(store.value.temporaryHeld, 0);
    assert.equal(store.rows.get("person")?.temporaryHold, undefined);
    await assert.rejects(store.execute(store.command({
      operation: "releaseTemporaryHold", requestId: "release"})),
    /does not own/u);
  });

test("expired pair release is idempotent and cannot release a later hold",
  async () => {
    const store = new Store();
    await store.execute();
    const release = store.command({operation: "releaseTemporaryHold",
      requestId: "release", nowMillis: 400000});
    await store.execute(release);
    await store.execute(release);
    assert.equal(store.value.occupied, 0);
    assert.equal(store.value.temporaryHeld, 0);
    await store.execute(store.command({ownerId: "new-pair", requestId: "new",
      nowMillis: 400001, expiresAtMillis: 500000}));
    await store.execute(release);
    assert.equal(store.value.temporaryHeld, 1);
    assert.equal(store.rows.get("person")?.temporaryHold?.ownerId, "new-pair");
  });

test("other seat writers cannot overwrite a temporary hold", async () => {
  const store = new Store();
  store.value.capacity = 2;
  await store.execute();
  for (const operation of ["reserve", "release"] as const) {
    await assert.rejects(applySeatCommand({tx: store,
      command: {...store.command({requestId: operation}), operation},
      resolveIdentity}), /checkout in progress/u);
    await assert.rejects(prepareSeatBatch({tx: store, command: {
      ...store.command(), batchId: "batch", operations: [{subject: "person",
        operation, requestId: operation, expectedReservationRevision: 1}]},
    resolveIdentity}), /checkout in progress/u);
  }
  assert.equal(store.writes, 3);
});

test("malformed combined inventory and hold lifetime fail before writes",
  async () => {
    for (const temporaryHeld of [-1, 0.5, NaN, null, 2]) {
      const store = new Store();
      store.value.temporaryHeld = temporaryHeld as number;
      await assert.rejects(store.execute(), /inventory/u);
      assert.equal(store.writes, 0);
    }
    for (const expiresAtMillis of [1000, 1000 + 30 * 60 * 1000 + 1]) {
      const store = new Store();
      await assert.rejects(store.execute(store.command({expiresAtMillis})),
        /deadline/u);
      assert.equal(store.writes, 0);
    }
  });

/** Optimistic retries isolate reads and pending writes until commit. */
async function race(store: Store,
  writers: Array<(tx: Store) => Promise<unknown>>) {
  let version = 0;
  return Promise.allSettled(writers.map(async (write) => {
    for (let attempt = 0; attempt < 3; attempt++) {
      const observed = version;
      const tx = new Store();
      tx.value = {...store.value};
      tx.rows = new Map(store.rows);
      tx.receipts = new Map(store.receipts);
      await write(tx);
      await Promise.resolve();
      if (observed !== version) continue;
      store.value = tx.value;
      store.rows = tx.rows;
      store.receipts = tx.receipts;
      version++;
      return;
    }
    throw new Error("retry exhausted");
  }));
}

test("concurrent pair and paid checkout cannot both win the last seat",
  async () => {
    const store = new Store();
    const results = await race(store, [async (tx) => tx.execute(),
      async (tx) => {
        const plan = await prepareCheckoutHold({tx, resolveIdentity,
          command: {eventId: "event", subject: "other",
            operation: "checkoutHold",
            paymentId: "pay", requestId: "pay", expectedLedgerRevision:
            tx.value.revision, expectedCapacityRevision: 1,
            expectedMigrationRevision: 1, expectedReservationRevision: 0,
            nowMillis: 1000}});
        applyCheckoutHold(tx, plan);
      }]);
    assert.equal(results.filter((r) => r.status === "fulfilled").length, 1);
    assert.equal((store.value.checkoutHeld ?? 0) +
      (store.value.temporaryHeld ?? 0), 1);
    assert.equal(store.value.occupied, 0);
  });

test("concurrent pair confirmation and release consume the hold once",
  async () => {
    const store = new Store();
    await store.execute();
    const results = await race(store, ["confirmTemporaryHold",
      "releaseTemporaryHold"].map((operation) => async (tx) =>
      tx.execute(tx.command({operation: operation as
        TemporaryHoldCommand<string>["operation"], requestId: operation,
      nowMillis: 2000}))));
    assert.equal(results.filter((r) => r.status === "fulfilled").length, 1);
    assert.equal(store.value.temporaryHeld, 0);
    assert.equal(store.value.revision, 3);
    assert.equal(store.value.occupied,
      store.rows.get("person")?.active ? 1 : 0);
  });
