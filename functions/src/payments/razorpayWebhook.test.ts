import assert from "node:assert/strict";
import * as crypto from "node:crypto";
import test from "node:test";
import Razorpay from "razorpay";
import {razorpayWebhookHandler} from "./razorpayWebhook";

const WEBHOOK_SECRET = "whsec_razorpay_test";

test(
  "razorpayWebhookHandler signs up and completes a captured payment",
  async () => {
    const firestore = new FakeFirestore({
      "payments/pay_123": {status: "pending", createdAt: "created-at"},
      "razorpayPendingOrders/order_123": {
        status: "pending",
        orderId: "order_123",
      },
    });
    const signUps: Array<{eventId: string; userId: string}> = [];
    const payload = capturedEventPayload();

    await razorpayWebhookHandler(
      payload,
      sign(payload),
      WEBHOOK_SECRET,
      {
        firestore: () => firestore as unknown as FirebaseFirestore.Firestore,
        createClient: () => razorpayClient(),
        serverTimestamp: () => "server-now",
        signUpForEvent: async (_db, eventId, userId) => {
          signUps.push({eventId, userId});
        },
      }
    );

    assert.deepEqual(signUps, [{eventId: "trusted-event", userId: "runner-1"}]);
    const payment = firestore.data["payments/pay_123"] as
      Record<string, unknown>;
    assert.equal(payment.status, "completed");
    assert.equal(payment.signUpFailed, false);
    assert.equal(payment.orderId, "order_123");
    assert.equal(payment.amount, 25000);
    // The pending-order tracking doc is removed once fulfillment succeeds.
    assert.equal(firestore.data["razorpayPendingOrders/order_123"], undefined);
  }
);

test(
  "razorpayWebhookHandler is idempotent when the callback already fulfilled",
  async () => {
    const firestore = new FakeFirestore({
      "payments/pay_123": {status: "completed", createdAt: "created-at"},
      "razorpayPendingOrders/order_123": {
        status: "pending",
        orderId: "order_123",
      },
    });
    let signUpCalled = false;
    const payload = capturedEventPayload();

    await razorpayWebhookHandler(payload, sign(payload), WEBHOOK_SECRET, {
      firestore: () => firestore as unknown as FirebaseFirestore.Firestore,
      createClient: () => razorpayClient({
        refund: async () => {
          throw new Error("Refund should not run when already completed.");
        },
      }),
      serverTimestamp: () => "server-now",
      signUpForEvent: async () => {
        signUpCalled = true;
      },
    });

    assert.equal(signUpCalled, false);
    // The already-completed payment doc is left untouched.
    assert.deepEqual(firestore.data["payments/pay_123"], {
      status: "completed",
      createdAt: "created-at",
    });
    // The leftover pending-order doc is cleaned up.
    assert.equal(firestore.data["razorpayPendingOrders/order_123"], undefined);
  }
);

test("razorpayWebhookHandler marks the pending order failed on payment.failed",
  async () => {
    const firestore = new FakeFirestore({
      "razorpayPendingOrders/order_123": {
        status: "pending",
        orderId: "order_123",
      },
    });
    const payload = failedEventPayload();

    await razorpayWebhookHandler(payload, sign(payload), WEBHOOK_SECRET, {
      firestore: () => firestore as unknown as FirebaseFirestore.Firestore,
      createClient: () => {
        throw new Error("Razorpay client should not be created.");
      },
      serverTimestamp: () => "server-now",
      signUpForEvent: async () => {
        throw new Error("signUpForEvent should not be called.");
      },
    });

    assert.deepEqual(firestore.data["razorpayPendingOrders/order_123"], {
      status: "failed",
      orderId: "order_123",
      updatedAt: "server-now",
    });
  });

test("razorpayWebhookHandler rejects invalid webhook signatures", async () => {
  const payload = capturedEventPayload();

  await assert.rejects(
    razorpayWebhookHandler(payload, "deadbeef", WEBHOOK_SECRET, {
      firestore: () => new FakeFirestore({}) as unknown as
        FirebaseFirestore.Firestore,
      createClient: () => {
        throw new Error("Razorpay client should not be created.");
      },
      serverTimestamp: () => "server-now",
      signUpForEvent: async () => undefined,
    }),
    /Invalid Razorpay webhook signature/
  );
});

function capturedEventPayload(): Buffer {
  return Buffer.from(JSON.stringify({
    event: "payment.captured",
    payload: {
      payment: {
        entity: {
          id: "pay_123",
          order_id: "order_123",
          status: "captured",
        },
      },
    },
  }));
}

function failedEventPayload(): Buffer {
  return Buffer.from(JSON.stringify({
    event: "payment.failed",
    payload: {
      payment: {
        entity: {
          id: "pay_456",
          order_id: "order_123",
          status: "failed",
        },
      },
    },
  }));
}

function sign(payload: Buffer): string {
  return crypto
    .createHmac("sha256", WEBHOOK_SECRET)
    .update(payload)
    .digest("hex");
}

function razorpayClient(
  overrides: {refund?: () => Promise<void>} = {}
): Razorpay {
  return {
    orders: {
      fetch: async () => ({
        id: "order_123",
        amount: 25000,
        currency: "INR",
        amount_paid: 25000,
        amount_due: 0,
        notes: {
          eventId: "trusted-event",
          userId: "runner-1",
        },
      }),
    },
    payments: {
      fetch: async () => ({
        id: "pay_123",
        order_id: "order_123",
        amount: 25000,
        currency: "INR",
        status: "captured",
        refund_status: "null",
      }),
      refund: overrides.refund ?? (async () => {
        throw new Error("Refund should not be called on success.");
      }),
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
  // the fake serializes nothing (single-threaded tests) and just forwards
  // reads/writes to the doc refs.
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
    private readonly filters: QueryFilter[]
  ) {}

  async get() {
    const prefix = `${this.collectionPath}/`;
    const docs = Object.entries(this.firestore.data)
      .filter(([path]) => path.startsWith(prefix))
      .map(([path, data]) => ({
        id: path.slice(prefix.length),
        data: () => data,
      }))
      .filter((doc) => this.filters.every((filter) =>
        matchesFilter(doc.data(), filter)));
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
    return {
      exists: value !== undefined,
      id: this.id,
      data: () => value,
    };
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
  throw new Error(`Unsupported fake query op ${filter.op}`);
}
