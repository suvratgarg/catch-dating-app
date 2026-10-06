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
        orders: string[] = [], count = Infinity,
        after?: {values: unknown[]}) => ({
        doc: (id: string) => ({path: `${name}/${id}`}),
        where: (field: string, op: string, value: unknown) =>
          query([...filters, [field, op, value]], orders, count, after),
        orderBy: (field: unknown) => query(filters,
          [...orders, typeof field === "string" ? field : "id"], count, after),
        limit: (size: number) => query(filters, orders, size, after),
        startAfter: (...values: unknown[]) => {
          const value = values[0] as {id?: string; data?: () =>
            Record<string, unknown>};
          if (values.length === 1 && value.id) {
            const row = value.data?.() ?? {};
            const effective = orders.length ? orders : ["id"];
            return query(filters, orders, count, {values: effective.map((field) =>
              field === "id" ? value.id : field.split(".").reduce<unknown>(
                (v, part) => (v as Record<string, unknown>)?.[part], row))});
          }
          return query(filters, orders, count, {values: values.map((v) =>
            v !== null && typeof v === "object" && "path" in v ?
              String((v as {path: string}).path).split("/").at(-1) : v)});
        },
        get: async () => {
          const get = (row: Record<string, unknown>, key: string): unknown =>
            key.split(".").reduce<unknown>((value, part) =>
              (value as Record<string, unknown>)?.[part], row);
          const effective = orders.length ? orders : ["id"];
          const tuple = (doc: {id: string; data: () =>
            Record<string, unknown>}) => effective.map((field) =>
            field === "id" ? doc.id : get(doc.data(), field));
          const compare = (a: unknown[], b: unknown[]) => {
            for (let i = 0; i < a.length; i++) {
              const delta = typeof a[i] === "number" ?
                Number(a[i]) - Number(b[i]) :
                String(a[i]).localeCompare(String(b[i]));
              if (delta) return delta;
            }
            return 0;
          };
          const docs = [...store.rows].filter(([path, row]) =>
            path.startsWith(`${name}/`) &&
            filters.every(([field, op, value]) => op === "==" ?
              get(row, field) === value : op === "in" ?
                (value as unknown[]).includes(get(row, field)) :
                Number(get(row, field)) <= Number(value)))
            .map(([path, row]) => ({id: path.split("/")[1], ref: {path},
              data: () => row}))
            .sort((a, b) => compare(tuple(a), tuple(b)))
            .filter((doc) => !after || compare(tuple(doc), after.values) > 0)
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

// Ownership regressions run against preserved production before integration.
test("ownership recovery: unknown refusal cannot trigger scheduler catch writes",
  async () => {
    const h = fixture();
    h.store.rows.delete("payments/payment1");
    h.store.put("payments/pay_one", {...h.payment,
      cancellationRefund: planLegacyCancellationRefund({payment: h.payment,
        reason: "guestCancelled", targetAmountMinor: 1000, nowMillis: 1})});
    const before = JSON.stringify(h.store.get("payments/pay_one"));
    const writesBefore = h.store.writes.length;
    const timelineBefore = h.store.timeline.length;
    const {db} = queryDatabase(h.store);
    await reconcileNativeCancellationRefunds({db, nowMillis: 1000,
      process: async () => { throw new Error("Unknown native order ownership"); }});
    assert.equal(JSON.stringify(h.store.get("payments/pay_one")), before);
    assert.equal(h.store.writes.length - writesBefore, 0);
    assert.deepEqual(h.store.timeline.slice(timelineBefore)
      .filter((entry) => entry.startsWith("write:")), []);
  });

test("ownership recovery: unknown legacy capture cannot stage cancellation intent",
  async () => {
    const h = fixture();
    h.store.rows.delete("payments/payment1");
    h.store.put("payments/pay_one", {...h.payment});
    h.store.put("events/event1", {status: "cancelled"});
    const before = JSON.stringify(h.store.get("payments/pay_one"));
    const writesBefore = h.store.writes.length;
    const timelineBefore = h.store.timeline.length;
    await stageCancelledEventPayment({db: h.store.db(),
      paymentId: "pay_one", nowMillis: 1000}).catch(() => undefined);
    assert.equal(JSON.stringify(h.store.get("payments/pay_one")), before);
    assert.equal(h.store.writes.length - writesBefore, 0);
    assert.deepEqual(h.store.timeline.slice(timelineBefore)
      .filter((entry) => entry.startsWith("write:")), []);
  });

function unresolvedQueueFixture(count: number) {
  const h = fixture();
  h.store.rows.delete("payments/payment1");
  for (let index = 0; index < count; index++) {
    const id = `pay_unknown${String(index).padStart(4, "0")}`;
    const payment: PaymentDocument = {...h.payment, paymentId: id,
      orderId: `order_${id}`};
    const cancellationRefund = planLegacyCancellationRefund({payment,
      reason: "guestCancelled", targetAmountMinor: 1000, nowMillis: index + 1});
    h.store.put(`payments/${id}`, {...payment, cancellationRefund});
  }
  const ownedStripe: PaymentDocument = {...h.payment, provider: "stripe",
    paymentId: "ownedStripe", providerPaymentId: "pi_one",
    stripeAccountId: "acct_one"};
  const cancellationRefund = planLegacyCancellationRefund({payment: ownedStripe,
    reason: "guestCancelled", targetAmountMinor: 1000, nowMillis: count + 1});
  h.store.put("payments/ownedStripe", {...ownedStripe, cancellationRefund});
  return h;
}
function unresolvedQueueBytes(store: Store) {
  return JSON.stringify([...store.rows].filter(([path]) =>
    path.startsWith("payments/pay_unknown")));
}

test("ownership recovery: 80 unresolved oldest rows do not block later owned work",
  async () => {
    const h = unresolvedQueueFixture(80);
    const before = unresolvedQueueBytes(h.store);
    const {db, pages} = queryDatabase(h.store);
    const processed: string[] = [];
    await reconcileNativeCancellationRefunds({db, nowMillis: 1000,
      process: async (id) => { processed.push(id); }});
    assert.deepEqual(processed, ["ownedStripe"]);
    assert.equal(unresolvedQueueBytes(h.store), before);
    assert.deepEqual(h.store.writes, []);
    assert.ok(pages.length <= 3);
    assert.ok(pages.reduce((a, b) => a + b, 0) <= 81);
  });

test("ownership recovery: bounded continuation reaches owned work beyond 400 refusals",
  async () => {
    const h = unresolvedQueueFixture(450);
    const before = unresolvedQueueBytes(h.store);
    const {db, pages} = queryDatabase(h.store);
    const processed: string[] = [];
    const run = (continuation?: {nextAttemptAtMillis: number; paymentId: string}) => {
      // Variable permits the prospective optional seam without breaking baseline
      // compilation; original source ignores it and cannot advance its page.
      const options = Object.assign({db, nowMillis: 1000,
        process: async (id: string) => { processed.push(id); }}, {continuation});
      return reconcileNativeCancellationRefunds(options);
    };
    const first = await run();
    assert.deepEqual(processed, []);
    assert.ok(pages.length <= 10);
    assert.ok(pages.reduce((a, b) => a + b, 0) <= 400);
    const continuation = Reflect.get(first, "continuation") as
      {nextAttemptAtMillis: number; paymentId: string} | undefined;
    assert.ok(continuation, "Capped scan must retain explicit continuation");
    await run(continuation);
    assert.deepEqual(processed, ["ownedStripe"]);
    assert.equal(unresolvedQueueBytes(h.store), before);
    assert.deepEqual(h.store.writes, []);
    assert.ok(pages.length <= 12);
    assert.ok(pages.reduce((a, b) => a + b, 0) <= 451);
  });

// Legacy Stripe remains eligible; ownership guards are native Razorpay only.
test("ownership recovery control: Stripe cancellation staging replays exactly",
  async () => {
    const h = fixture();
    const payment: PaymentDocument = {...h.payment, provider: "stripe",
      providerPaymentId: "pi_one", stripeAccountId: "acct_one"};
    h.store.put("payments/payment1", {...payment});
    h.store.put("events/event1", {status: "cancelled"});
    await h.stage();
    const intent = JSON.stringify(h.read().cancellationRefund);
    const writes = h.store.writes.length;
    await h.stage();
    assert.equal(JSON.stringify(h.read().cancellationRefund), intent);
    assert.equal(h.store.writes.length, writes);
    assert.equal(h.read().cancellationRefund?.provider, "stripe");
    assert.equal(h.read().cancellationRefund?.providerPaymentId, "pi_one");
    assert.equal(h.read().cancellationRefund?.targetAmountMinor, 1000);
  });
