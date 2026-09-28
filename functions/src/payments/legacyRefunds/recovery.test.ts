import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import type {PaymentDocument} from "../../shared/generated/firestoreAdminTypes";
import {Store} from "../../organizerFormAdmission/admissionTestFixture";
import {planLegacyCancellationRefund} from "./intent";
import {stageCancelledEventPayment, stageCancelledEventRefunds,
  reconcileNativeCancellationRefunds} from "./recovery";

function fixture() {
  const store = new Store();
  const payment: PaymentDocument = {userId: "user1", eventId: "event1",
    orderId: "order_one", paymentId: "pay_one", amount: 1000, currency: "INR",
    status: "completed", signUpFailed: false,
    createdAt: Timestamp.fromMillis(1)};
  store.put("payments/payment1", {...payment});
  store.put("events/event1", {status: "active"});
  return {store, payment,
    stage: () => stageCancelledEventPayment({db: store.db(),
      paymentId: "payment1", nowMillis: 1000}),
    read: () => store.get("payments/payment1") as unknown as PaymentDocument};
}

test("late capture stages a full refund only for a currently cancelled event",
  async () => {
    const h = fixture(); await h.stage();
    assert.equal(h.read().cancellationRefund, undefined);
    h.store.put("events/event1", {status: "cancelled"});
    await h.stage(); const intent = h.read().cancellationRefund;
    assert.equal(intent?.reason, "eventCancelled");
    assert.equal(intent?.targetAmountMinor, 1000);
    assert.equal(h.read().status, "completed");
    await h.stage(); assert.deepEqual(h.read().cancellationRefund, intent);
  });

test("host cancellation upgrades a frozen zero-refund guest cancellation",
  async () => {
    const h = fixture();
    h.store.put("payments/payment1", {...h.payment,
      cancellationRefund: planLegacyCancellationRefund({payment: h.payment,
        reason: "guestCancelled", targetAmountMinor: 0, nowMillis: 1})});
    h.store.put("events/event1", {status: "cancelled"});
    await h.stage();
    assert.equal(h.read().cancellationRefund?.state, "pending");
    assert.equal(h.read().cancellationRefund?.targetAmountMinor, 1000);
  });

test("a failed staging commit can be replayed without losing the refund",
  async () => {
    const h = fixture(); h.store.put("events/event1", {status: "cancelled"});
    h.store.failNextCommit = true;
    await assert.rejects(h.stage(), /Interrupted commit/);
    assert.equal(h.read().cancellationRefund, undefined);
    await h.stage();
    assert.equal(h.read().cancellationRefund?.state, "pending");
  });

test("staging cannot invent capture authority or re-refund historical payments",
  async () => {
    for (const patch of [{status: "pending"},
      {signUpFailed: true}]) {
      const h = fixture(); h.store.put("events/event1", {status: "cancelled"});
      h.store.put("payments/payment1", {...h.payment, ...patch});
      await h.stage(); assert.equal(h.read().cancellationRefund, undefined);
    }
  });

/** The query seam retains pagination and ordering for recovery regressions. */
function queryDatabase(store: Store) {
  const pages: number[] = [];
  const db = {runTransaction: store.runTransaction.bind(store),
    collection: (name: string) => {
      const query = (filters: Array<[string, string, unknown]> = [],
        order = "id", count = Infinity, after = "") => ({
        doc: (id: string) => ({path: `${name}/${id}`}),
        where: (field: string, op: string, value: unknown) =>
          query([...filters, [field, op, value]], order, count, after),
        orderBy: (field: unknown) => query(filters,
          typeof field === "string" ? field : "id", count, after),
        limit: (size: number) => query(filters, order, size, after),
        startAfter: (doc: {id: string}) => query(filters, order, count, doc.id),
        get: async () => {
          const get = (row: Record<string, unknown>, key: string): unknown =>
            key.split(".").reduce<unknown>((value, part) =>
              (value as Record<string, unknown>)?.[part], row);
          const docs = [...store.rows].filter(([path, row]) =>
            path.startsWith(`${name}/`) && path.split("/")[1] > after &&
            filters.every(([field, op, value]) => op === "==" ?
              get(row, field) === value : op === "in" ?
                (value as unknown[]).includes(get(row, field)) :
                Number(get(row, field)) <= Number(value)))
            .map(([path, row]) => ({id: path.split("/")[1], ref: {path},
              data: () => row}))
            .sort((a, b) => order === "id" ? a.id.localeCompare(b.id) :
              Number(get(a.data(), order)) - Number(get(b.data(), order)))
            .slice(0, count);
          pages.push(docs.length);
          return {docs};
        },
      });
      return query();
    }} as unknown as FirebaseFirestore.Firestore;
  return {db, pages};
}

test("host cancellation stages all payments in bounded pages", async () => {
  const h = fixture(); h.store.rows.delete("payments/payment1");
  h.store.put("events/event1", {status: "cancelled"});
  for (let index = 0; index < 205; index++) {
    const id = `payments/pay${String(index).padStart(3, "0")}`;
    h.store.put(id, {...h.payment});
  }
  const {db, pages} = queryDatabase(h.store);
  await stageCancelledEventRefunds({db, eventId: "event1",
    clock: () => 1000});
  assert.deepEqual(pages, [100, 100, 5]);
  assert.equal([...h.store.rows.values()].filter((row) =>
    row.cancellationRefund).length, 205);
});

test("recovery selects oldest due work without a purchase-age cutoff",
  async () => {
    const h = fixture(); h.store.rows.delete("payments/payment1");
    for (let index = 0; index < 43; index++) {
      const cancellationRefund = planLegacyCancellationRefund({
        payment: h.payment, reason: "guestCancelled", targetAmountMinor: 1000,
        nowMillis: index + 1});
      h.store.put(`payments/pay${index}`, {...h.payment, cancellationRefund});
    }
    const {db} = queryDatabase(h.store); const processed: string[] = [];
    const result = await reconcileNativeCancellationRefunds({db,
      nowMillis: 1000, process: async (paymentId) => {
        processed.push(paymentId);
      }});
    assert.deepEqual(result, {processed: 40, failed: 0});
    assert.equal(processed[0], "pay0");
    assert.equal(processed.at(-1), "pay39");
  });

test("a poison refund leaves the due queue while a transient retry stays",
  async () => {
    const h = fixture(); h.store.put("events/event1", {status: "cancelled"});
    await h.stage(); const {db} = queryDatabase(h.store);
    const result = await reconcileNativeCancellationRefunds({db,
      nowMillis: 2000, process: async () => {
        throw new Error("Bad authority");
      }});
    assert.deepEqual(result, {processed: 0, failed: 1});
    assert.equal(h.read().cancellationRefund?.state, "reviewRequired");
    h.store.put("payments/payment1", {...h.read(), cancellationRefund: {
      ...h.read().cancellationRefund!, state: "pending",
      nextAttemptAtMillis: 1000}});
    await reconcileNativeCancellationRefunds({db, nowMillis: 2000,
      process: async () => {
        h.store.put("payments/payment1", {...h.read(), cancellationRefund: {
          ...h.read().cancellationRefund!, nextAttemptAtMillis: 5000}});
        throw new Error("Retry already scheduled");
      }});
    assert.equal(h.read().cancellationRefund?.state, "pending");
  });


test("old refunded status without amount proof explicitly requires review",
  async () => {
    const h = fixture(); h.store.put("events/event1", {status: "cancelled"});
    h.store.put("payments/payment1", {...h.payment, status: "refunded"});
    const {db} = queryDatabase(h.store);
    await stageCancelledEventRefunds({db, eventId: "event1",
      clock: () => 1000});
    assert.equal(h.read().cancellationRefund?.state, "reviewRequired");
    assert.equal(h.read().cancellationRefund?.lastErrorCode,
      "historicalRefundAmountUnknown");
    assert.deepEqual(h.read().cancellationRefund?.attempts, []);
  });
