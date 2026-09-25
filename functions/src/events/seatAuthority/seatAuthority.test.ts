import assert from "node:assert/strict";
import test from "node:test";
import {
  applySeatCommand, applySeatPlan, prepareSeatCommand,
  CanonicalSeatIdentity, SeatAuthorityError, SeatCommand,
  SeatLedger, SeatReceipt, SeatReservation, SeatTransaction,
} from "./seatAuthority";

type Subject = {key: string; revision: number};
const identity = async (subject: Subject): Promise<CanonicalSeatIdentity> =>
  ({key: subject.key, revision: subject.revision});
const initialLedger = (): SeatLedger => ({eventId: "event-1", capacity: 1,
  occupied: 0, revision: 4, capacityRevision: 2,
  policyVersion: "legacy", policyHash: "0d9299cd008e8ca01fb1070205278ada1" +
    "788be8a6b71d6bbd8b4760fff94a023",
  migrationRevision: 3,
  state: "ready"});
const command = (key: string, requestId: string, extras: Partial<
  SeatCommand<Subject>> = {}): SeatCommand<Subject> => ({
  eventId: "event-1", subject: {key, revision: 1}, operation: "reserve",
  requestId, expectedLedgerRevision: 4, expectedCapacityRevision: 2,
  expectedMigrationRevision: 3, expectedReservationRevision: 0,
  nowMillis: 100, ...extras,
});

/** Optimistic, serializable fake: stale readers retry on committed version. */
class Store {
  ledgerValue = initialLedger();
  reservations = new Map<string, SeatReservation>();
  receipts = new Map<string, SeatReceipt>();
  version = 0;
  async run(input: SeatCommand<Subject>) {
    for (let attempt = 0; attempt < 3; attempt++) {
      const start = this.version;
      const reservations = new Map(this.reservations);
      const receipts = new Map(this.receipts);
      let ledger = {...this.ledgerValue};
      const tx: SeatTransaction = {
        ledger: async () => ({...ledger}),
        reservation: async (_eventId, key) => reservations.get(key) ?? null,
        receipt: async (_eventId, id) => receipts.get(id) ?? null,
        putLedger: (value) => {
          ledger = value;
        },
        putReservation: (value) => {
          reservations.set(value.canonicalKey, value);
        },
        createReceipt: (value) => {
          receipts.set(value.requestId, value);
        },
      };
      const result = await applySeatCommand({tx, command: input,
        resolveIdentity: identity});
      // Yield to force concurrent transactions to read the same prior ledger.
      await Promise.resolve();
      if (start !== this.version) continue;
      if (!result.replayed) {
        this.ledgerValue = ledger;
        this.reservations = reservations;
        this.receipts = receipts;
        this.version++;
      }
      return result;
    }
    throw new Error("Transaction retry limit exceeded");
  }
}

function isError(code: SeatAuthorityError["code"], phrase: string) {
  return (error: unknown) => error instanceof SeatAuthorityError &&
    error.code === code && error.message.includes(phrase);
}

test("last seat is granted once across racing Host and Catch", async () => {
  const store = new Store();
  const results = await Promise.allSettled([
    store.run(command("person-a", "host-request")),
    store.run(command("person-b", "catch-request")),
  ]);
  assert.equal(results.filter((result) =>
    result.status === "fulfilled").length, 1);
  assert.equal(results.filter((result) =>
    result.status === "rejected").length, 1);
  assert.equal(store.ledgerValue.occupied, 1);
  assert.equal(store.receipts.size, 1);
  assert.equal([...store.reservations.values()].filter((row) =>
    row.active).length, 1);
});

test("replay is historical and cannot reactivate a released seat", async () => {
  const store = new Store();
  const reserve = command("person-a", "reserve-one");
  const first = await store.run(reserve);
  assert.equal(first.active, true);
  assert.equal((await store.run(reserve)).replayed, true);
  assert.equal(store.ledgerValue.occupied, 1);
  const released = await store.run(command("person-a", "release-one", {
    operation: "release", expectedLedgerRevision: 5,
    expectedReservationRevision: 1, nowMillis: 200,
  }));
  assert.equal(released.active, false);
  assert.equal(store.ledgerValue.occupied, 0);
  const historical = await store.run(reserve);
  assert.equal(historical.replayed, true);
  assert.equal(historical.active, false);
  assert.equal(store.ledgerValue.occupied, 0);
  await assert.rejects(store.run(command("person-a", "release-one", {
    operation: "reserve", expectedLedgerRevision: 6,
    expectedReservationRevision: 2,
  })), isError("conflict", "reused"));
});

test("revision and identity conflicts fail before a seat write", async () => {
  const store = new Store();
  await assert.rejects(store.run(command("person-a", "stale-capacity", {
    expectedCapacityRevision: 1,
  })), isError("conflict", "changed"));
  await assert.rejects(store.run(command("person-a", "stale-ledger", {
    expectedLedgerRevision: 3,
  })), isError("conflict", "changed"));
  await store.run(command("person-a", "reserve-a"));
  await assert.rejects(store.run(command("person-a", "reserve-again", {
    expectedLedgerRevision: 5, expectedReservationRevision: 1,
  })), isError("conflict", "already"));
  await assert.rejects(store.run(command("person-a", "release-wrong-identity", {
    operation: "release", subject: {key: "person-a", revision: 2},
    expectedLedgerRevision: 5, expectedReservationRevision: 1,
  })), isError("conflict", "identity changed"));
  assert.equal(store.ledgerValue.occupied, 1);
  assert.equal(store.receipts.size, 1);
});

test("unready, revoked and missing capacity or migration fail", async () => {
  for (const ledger of [
    {...initialLedger(), state: "unreconciled" as const},
    {...initialLedger(), state: "revoked" as const},
    {...initialLedger(), capacity: 0},
    {...initialLedger(), migrationRevision: 0},
    {...initialLedger(), capacityRevision: 0},
    {...initialLedger(), occupied: 2},
  ]) {
    const store = new Store();
    store.ledgerValue = ledger;
    await assert.rejects(store.run(command("person-a", "request-one")),
      isError("unavailable", "not reconciled"));
    assert.equal(store.receipts.size, 0);
  }
});

test("release needs an active seat; rebook needs new revisions", async () => {
  const store = new Store();
  await assert.rejects(store.run(command("person-a", "release-absent", {
    operation: "release",
  })), isError("conflict", "no active"));
  await store.run(command("person-a", "reserve-a"));
  await store.run(command("person-a", "release-a", {
    operation: "release", expectedLedgerRevision: 5,
    expectedReservationRevision: 1,
  }));
  await assert.rejects(store.run(command("person-a", "reserve-stale", {
    expectedLedgerRevision: 5, expectedReservationRevision: 1,
  })), isError("conflict", "changed"));
  const next = await store.run(command("person-a", "reserve-fresh", {
    expectedLedgerRevision: 6, expectedReservationRevision: 2,
  }));
  assert.equal(next.active, true);
  assert.equal(store.ledgerValue.occupied, 1);
});


test("an active reservation with zero occupied never writes a negative count",
  async () => {
    const store = new Store();
    store.reservations.set("person-a", {eventId: "event-1",
      canonicalKey: "person-a", identityRevision: 1, active: true,
      revision: 1, reservedAtMillis: 10, releasedAtMillis: null});
    await assert.rejects(store.run(command("person-a", "release-broken", {
      operation: "release", expectedReservationRevision: 1,
    })), isError("unavailable", "zero occupancy"));
    assert.equal(store.ledgerValue.occupied, 0);
    assert.equal(store.receipts.size, 0);
  });

test("malformed reservation and receipt fail before replay or writes",
  async () => {
    for (const patch of [
      {revision: 0}, {revision: Number.MAX_SAFE_INTEGER},
      {reservedAtMillis: -1}, {releasedAtMillis: 10},
    ]) {
      const store = new Store();
      store.ledgerValue.occupied = 1;
      store.reservations.set("person-a", {eventId: "event-1",
        canonicalKey: "person-a", identityRevision: 1, active: true,
        revision: 1, reservedAtMillis: 10, releasedAtMillis: null,
        ...patch});
      await assert.rejects(store.run(command("person-a", "bad-state")),
        isError("unavailable", "malformed"));
      assert.equal(store.receipts.size, 0);
    }
    const store = new Store();
    const request = command("person-a", "good-reserve");
    await store.run(request);
    const receipt = store.receipts.get("good-reserve")!;
    store.receipts.set("good-reserve", {...receipt,
      appliedLedgerRevision: 0});
    await assert.rejects(store.run(request),
      isError("unavailable", "receipt is malformed"));
    store.receipts.set("good-reserve", {...receipt,
      appliedReservationRevision: Number.MAX_SAFE_INTEGER + 1});
    await assert.rejects(store.run(request),
      isError("unavailable", "receipt is malformed"));
    assert.equal(store.ledgerValue.occupied, 1);
  });

test("overflowing ledger revision fails without staging writes", async () => {
  const store = new Store();
  store.ledgerValue.revision = Number.MAX_SAFE_INTEGER;
  await assert.rejects(store.run(command("person-a", "overflow", {
    expectedLedgerRevision: Number.MAX_SAFE_INTEGER,
  })), isError("unavailable", "not reconciled"));
  assert.equal(store.receipts.size, 0);
});

test("preparation reads only and a frozen plan applies to its own tx",
  async () => {
    const ledger = initialLedger();
    const writes: string[] = [];
    const tx: SeatTransaction = {
      ledger: async () => ledger,
      reservation: async () => null,
      receipt: async () => null,
      putLedger: () => {
        writes.push("ledger");
      },
      putReservation: () => {
        writes.push("reservation");
      },
      createReceipt: () => {
        writes.push("receipt");
      },
    };
    const plan = await prepareSeatCommand({tx,
      command: command("person-a", "prepared-once"),
      resolveIdentity: identity});
    assert.deepEqual(writes, []);
    assert.equal(Object.isFrozen(plan), true);
    assert.equal(Object.isFrozen(plan.result.receipt), true);
    assert.throws(() => applySeatPlan({...tx}, plan),
      isError("invalid", "not prepared"));
    assert.deepEqual(writes, []);
    assert.equal(applySeatPlan(tx, plan).active, true);
    assert.deepEqual(writes, ["ledger", "reservation", "receipt"]);
    assert.throws(() => applySeatPlan(tx, plan),
      isError("invalid", "not prepared"));
  });
