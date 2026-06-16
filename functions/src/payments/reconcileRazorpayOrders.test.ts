import assert from "node:assert/strict";
import test from "node:test";
import Razorpay from "razorpay";
import {reconcileRazorpayOrdersHandler} from "./reconcileRazorpayOrders";

test("reconcileRazorpayOrdersHandler fulfills a stale captured order",
  async () => {
    const firestore = new FakeFirestore({
      "razorpayPendingOrders/order_stale": {
        provider: "razorpay",
        orderId: "order_stale",
        userId: "runner-1",
        eventId: "trusted-event",
        amountInPaise: 25000,
        currency: "INR",
        status: "pending",
        createdAt: ts(0),
      },
    });
    const signUps: Array<{eventId: string; userId: string}> = [];

    const summary = await reconcileRazorpayOrdersHandler({
      firestore: () => firestore as unknown as FirebaseFirestore.Firestore,
      createClient: () => razorpayClient({
        payments: [{
          id: "pay_stale",
          order_id: "order_stale",
          amount: 25000,
          currency: "INR",
          status: "captured",
          refund_status: "null",
        }],
      }),
      now: () => new Date(60 * 60 * 1000),
      timestampFromDate: (date) =>
        ts(date.getTime()) as unknown as FirebaseFirestore.Timestamp,
      serverTimestamp: () => "server-now",
      signUpForEvent: async (_db, eventId, userId) => {
        signUps.push({eventId, userId});
      },
      graceMs: 15 * 60 * 1000,
      batchLimit: 25,
    });

    assert.deepEqual(summary, {processed: 1, fulfilled: 1, expired: 0});
    assert.deepEqual(signUps, [{eventId: "trusted-event", userId: "runner-1"}]);
    const payment = firestore.data["payments/pay_stale"] as
      Record<string, unknown>;
    assert.equal(payment.status, "completed");
    assert.equal(payment.orderId, "order_stale");
    // Fulfillment removes the pending tracking doc.
    assert.equal(
      firestore.data["razorpayPendingOrders/order_stale"],
      undefined
    );
  });

test("reconcileRazorpayOrdersHandler expires an order with no captured payment",
  async () => {
    const firestore = new FakeFirestore({
      "razorpayPendingOrders/order_abandoned": {
        provider: "razorpay",
        orderId: "order_abandoned",
        userId: "runner-1",
        eventId: "trusted-event",
        amountInPaise: 25000,
        currency: "INR",
        status: "pending",
        createdAt: ts(0),
      },
    });

    const summary = await reconcileRazorpayOrdersHandler({
      firestore: () => firestore as unknown as FirebaseFirestore.Firestore,
      createClient: () => razorpayClient({payments: []}),
      now: () => new Date(60 * 60 * 1000),
      timestampFromDate: (date) =>
        ts(date.getTime()) as unknown as FirebaseFirestore.Timestamp,
      serverTimestamp: () => "server-now",
      signUpForEvent: async () => {
        throw new Error("signUpForEvent should not be called.");
      },
      graceMs: 15 * 60 * 1000,
      batchLimit: 25,
    });

    assert.deepEqual(summary, {processed: 1, fulfilled: 0, expired: 1});
    assert.deepEqual(
      firestore.data["razorpayPendingOrders/order_abandoned"],
      {
        provider: "razorpay",
        orderId: "order_abandoned",
        userId: "runner-1",
        eventId: "trusted-event",
        amountInPaise: 25000,
        currency: "INR",
        status: "expired",
        createdAt: ts(0),
        updatedAt: "server-now",
      }
    );
  });

test(
  "reconcileRazorpayOrdersHandler fulfills a failed order that was recaptured",
  async () => {
    // A payment.failed webhook already moved this order to "failed", but the
    // user retried and a later attempt on the SAME order was captured. The
    // sweep must still pick it up ("failed" stays sweep-eligible) and fulfill.
    const firestore = new FakeFirestore({
      "razorpayPendingOrders/order_stale": {
        provider: "razorpay",
        orderId: "order_stale",
        userId: "runner-1",
        eventId: "trusted-event",
        amountInPaise: 25000,
        currency: "INR",
        status: "failed",
        createdAt: ts(0),
      },
    });
    const signUps: Array<{eventId: string; userId: string}> = [];

    const summary = await reconcileRazorpayOrdersHandler({
      firestore: () => firestore as unknown as FirebaseFirestore.Firestore,
      createClient: () => razorpayClient({
        payments: [{
          id: "pay_recaptured",
          order_id: "order_stale",
          amount: 25000,
          currency: "INR",
          status: "captured",
          refund_status: "null",
        }],
      }),
      now: () => new Date(60 * 60 * 1000),
      timestampFromDate: (date) =>
        ts(date.getTime()) as unknown as FirebaseFirestore.Timestamp,
      serverTimestamp: () => "server-now",
      signUpForEvent: async (_db, eventId, userId) => {
        signUps.push({eventId, userId});
      },
      graceMs: 15 * 60 * 1000,
      batchLimit: 25,
    });

    assert.deepEqual(summary, {processed: 1, fulfilled: 1, expired: 0});
    assert.deepEqual(signUps, [{eventId: "trusted-event", userId: "runner-1"}]);
    const payment = firestore.data["payments/pay_recaptured"] as
      Record<string, unknown>;
    assert.equal(payment.status, "completed");
    // Fulfillment removes the tracking doc once the booking succeeds.
    assert.equal(
      firestore.data["razorpayPendingOrders/order_stale"],
      undefined
    );
  });

test("reconcileRazorpayOrdersHandler skips orders inside the grace window",
  async () => {
    const firestore = new FakeFirestore({
      "razorpayPendingOrders/order_fresh": {
        provider: "razorpay",
        orderId: "order_fresh",
        userId: "runner-1",
        eventId: "trusted-event",
        amountInPaise: 25000,
        currency: "INR",
        status: "pending",
        // Created 5 minutes ago; inside the 15 minute grace window.
        createdAt: ts(55 * 60 * 1000),
      },
    });

    const summary = await reconcileRazorpayOrdersHandler({
      firestore: () => firestore as unknown as FirebaseFirestore.Firestore,
      createClient: () => {
        throw new Error("Razorpay client should not be created.");
      },
      now: () => new Date(60 * 60 * 1000),
      timestampFromDate: (date) =>
        ts(date.getTime()) as unknown as FirebaseFirestore.Timestamp,
      serverTimestamp: () => "server-now",
      signUpForEvent: async () => undefined,
      graceMs: 15 * 60 * 1000,
      batchLimit: 25,
    });

    assert.deepEqual(summary, {processed: 0, fulfilled: 0, expired: 0});
    assert.equal(
      (firestore.data["razorpayPendingOrders/order_fresh"] as
        Record<string, unknown>).status,
      "pending"
    );
  });

interface FakeTimestamp {
  __millis: number;
}

function ts(millis: number): FakeTimestamp {
  return {__millis: millis};
}

function tsMillis(value: unknown): number {
  return (value as FakeTimestamp).__millis;
}

function razorpayClient(
  overrides: {payments?: Array<Record<string, unknown>>} = {}
): Razorpay {
  return {
    orders: {
      fetch: async () => ({
        id: "order_stale",
        amount: 25000,
        currency: "INR",
        amount_paid: 25000,
        amount_due: 0,
        notes: {
          eventId: "trusted-event",
          userId: "runner-1",
        },
      }),
      fetchPayments: async () => ({
        entity: "collection",
        count: overrides.payments?.length ?? 0,
        items: overrides.payments ?? [],
      }),
    },
    payments: {
      refund: async () => {
        throw new Error("Refund should not be called.");
      },
    },
  } as unknown as Razorpay;
}

interface QueryFilter {
  field: string;
  op: FirebaseFirestore.WhereFilterOp;
  value: unknown;
}

class FakeFirestore {
  constructor(readonly data: Record<string, unknown>) {}

  collection(collectionPath: string) {
    return new FakeCollectionRef(this, collectionPath);
  }

  // Fulfillment completes the payment + bumps paidCount inside a transaction;
  // the fake forwards tx reads/writes to the doc refs.
  async runTransaction<T>(
    updateFn: (tx: {
      get: (ref: FakeDocRef) => Promise<unknown>;
      set: (
        ref: FakeDocRef,
        data: Record<string, unknown>,
        options?: {merge?: boolean}
      ) => void;
    }) => Promise<T>
  ): Promise<T> {
    return updateFn({
      get: (ref) => ref.get(),
      set: (ref, data, options) => {
        void ref.set(data, options);
      },
    });
  }
}

class FakeCollectionRef {
  constructor(
    private readonly firestore: FakeFirestore,
    private readonly collectionPath: string
  ) {}

  doc(id: string) {
    return new FakeDocRef(this.firestore, this.collectionPath, id);
  }

  where(field: string, op: FirebaseFirestore.WhereFilterOp, value: unknown) {
    return new FakeQuery(this.firestore, this.collectionPath, [
      {field, op, value},
    ]);
  }
}

class FakeQuery {
  constructor(
    private readonly firestore: FakeFirestore,
    private readonly collectionPath: string,
    private readonly filters: QueryFilter[],
    private readonly limitCount?: number
  ) {}

  where(field: string, op: FirebaseFirestore.WhereFilterOp, value: unknown) {
    return new FakeQuery(
      this.firestore,
      this.collectionPath,
      [...this.filters, {field, op, value}],
      this.limitCount
    );
  }

  orderBy() {
    return this;
  }

  limit(limitCount: number) {
    return new FakeQuery(
      this.firestore,
      this.collectionPath,
      this.filters,
      limitCount
    );
  }

  async get() {
    const prefix = `${this.collectionPath}/`;
    let docs = Object.entries(this.firestore.data)
      .filter(([path]) => path.startsWith(prefix))
      .map(([path, data]) => ({
        id: path.slice(prefix.length),
        data: () => data,
      }))
      .filter((doc) => this.filters.every((filter) =>
        matchesFilter(doc.data(), filter)));
    if (this.limitCount !== undefined) docs = docs.slice(0, this.limitCount);
    return {docs, empty: docs.length === 0};
  }
}

class FakeDocRef {
  readonly path: string;

  constructor(
    private readonly firestore: FakeFirestore,
    collectionPath: string,
    readonly id: string
  ) {
    this.path = `${collectionPath}/${id}`;
  }

  async get() {
    const value = this.firestore.data[this.path];
    return {exists: value !== undefined, id: this.id, data: () => value};
  }

  async set(data: Record<string, unknown>, options?: {merge?: boolean}) {
    this.firestore.data[this.path] = options?.merge === true ?
      {
        ...(this.firestore.data[this.path] as Record<string, unknown>),
        ...data,
      } :
      data;
  }

  async delete() {
    delete this.firestore.data[this.path];
  }
}

function matchesFilter(data: unknown, filter: QueryFilter): boolean {
  const value = (data as Record<string, unknown>)[filter.field];
  if (filter.op === "==") return value === filter.value;
  if (filter.op === "in") {
    return Array.isArray(filter.value) && filter.value.includes(value);
  }
  if (filter.op === "<") return tsMillis(value) < tsMillis(filter.value);
  throw new Error(`Unsupported fake query op ${filter.op}`);
}
