import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {reconcileOrganizerFormPaymentsHandler} from "./formPaymentTriggers";
import type {formPaymentRuntime} from "./formPaymentRuntime";

type Runtime = Awaited<ReturnType<typeof formPaymentRuntime>>;
type Update = Record<string, Timestamp>;
function row(id: string, status = "checkoutReady", failsWrite = false) {
  const updates: Update[] = [];
  return {id, updates, get: (field: string) => {
    assert.equal(field, "status"); return status;
  }, ref: {update: async (update: Update) => {
    updates.push(update);
    if (failsWrite) throw new Error("Unavailable write");
  }}};
}
function runtime(batches: Array<Array<ReturnType<typeof row>>>,
  reconcile: (id: string) => Promise<void>) {
  let index = 0;
  const db = {collection: () => {
    const docs = batches[index++];
    const query = {where: () => query, orderBy: () => query,
      limit: () => query, get: async () => ({docs})};
    return query;
  }};
  return {db, processor: {reconcile}} as unknown as Runtime;
}

test("one receipt, expiry or reschedule failure cannot stop unrelated recovery",
  async () => {
    const receipts = [row("receipt-write", "pending", true),
      row("receipt-process", "pending")];
    const payments = [row("bad-expiry"), row("bad-touch", "failed", true),
      row("manual", "reviewRequired"), row("good")];
    const completed = [row("settled", "submitted")];
    const reconciled: string[] = []; const expired: string[] = [];
    const deps = runtime([receipts, payments, completed], async (id) => {
      reconciled.push(id);
    });
    const result = await reconcileOrganizerFormPaymentsHandler(deps, 1_000, {
      clock: () => 0,
      receipt: async (id) => {
        if (id === "receipt-process") throw new Error("Retry later");
      },
      expire: async ({paymentId}) => {
        expired.push(paymentId);
        if (paymentId === "bad-expiry") throw new Error("Malformed record");
      },
    });
    assert.deepEqual(result, {processed: 3, failed: 4, deferred: 0});
    assert.deepEqual(new Set(reconciled),
      new Set(["bad-expiry", "bad-touch", "good", "settled"]));
    assert.deepEqual(new Set(expired),
      new Set(payments.concat(completed).map((payment) => payment.id)));
    assert.equal(payments[0].updates[0].updatedAt.toMillis(), 1_000);
    assert.equal(receipts[1].updates[0].nextAttemptAt.toMillis(), 301_000);
  });

test("provider failure still releases expired capacity and rotates the record",
  async () => {
    const payment = row("unreachable-merchant");
    let expired = false;
    const result = await reconcileOrganizerFormPaymentsHandler(
      runtime([[], [payment], []], async () => {
        throw new Error("Provider unavailable");
      }), 5_000, {
        clock: () => 0, receipt: async () => undefined,
        expire: async () => {
          expired = true;
        },
      });
    assert.deepEqual(result, {processed: 0, failed: 1, deferred: 0});
    assert.equal(expired, true);
    assert.equal(payment.updates[0].updatedAt.toMillis(), 5_000);
  });

test("provider work has four slots rather than serializing behind one merchant",
  async () => {
    let active = 0; let peak = 0;
    let release!: () => void; let started!: () => void;
    const gate = new Promise<void>((resolve) => {
      release = resolve;
    });
    const firstWave = new Promise<void>((resolve) => {
      started = resolve;
    });
    const payments = Array.from({length: 8}, (_, i) => row(`payment-${i}`));
    const operation = reconcileOrganizerFormPaymentsHandler(
      runtime([[], payments, []], async () => {
        active++;
        peak = Math.max(peak, active);
        if (active === 4) started();
        await gate;
        active--;
      }), 1_000, {clock: () => 0, receipt: async () => undefined,
        expire: async () => undefined});
    await firstWave;
    assert.equal(peak, 4);
    release();
    assert.deepEqual(await operation, {processed: 8, failed: 0, deferred: 0});
    assert.equal(peak, 4);
  });

test("a depleted run leaves unstarted receipts and payments eligible next time",
  async () => {
    let elapsed = 0;
    const receipts = [row("started", "pending"), row("deferred", "pending")];
    const payment = row("deferred-payment");
    const result = await reconcileOrganizerFormPaymentsHandler(
      runtime([receipts, [payment], []], async () => {
        assert.fail("Do not start work after the run budget");
      }), 1_000, {clock: () => elapsed,
        receipt: async () => {
          elapsed = 8 * 60_000;
        },
        expire: async () => assert.fail("Unstarted payment must stay eligible"),
      });
    assert.deepEqual(result, {processed: 1, failed: 0, deferred: 2});
    assert.equal(receipts[1].updates.length, 0);
    assert.equal(payment.updates.length, 0);
  });

test("receipt backlogs do not monopolize the first four recovery slots",
  async () => {
    const receipts = Array.from({length: 10}, (_, i) => row(`receipt-${i}`));
    const payment = row("payment");
    const starts: string[] = [];
    let release!: () => void;
    let started!: () => void;
    const gate = new Promise<void>((resolve) => {
      release = resolve;
    });
    const wave = new Promise<void>((resolve) => {
      started = resolve;
    });
    const run = async (id: string) => {
      starts.push(id);
      if (starts.length === 4) started();
      await gate;
    };
    const operation = reconcileOrganizerFormPaymentsHandler(
      runtime([receipts, [payment], []], run), 1_000, {
        clock: () => 0, receipt: run, expire: async () => undefined,
      });
    await wave;
    assert.ok(starts.includes("payment"));
    release();
    assert.deepEqual(await operation, {processed: 11, failed: 0, deferred: 0});
  });
