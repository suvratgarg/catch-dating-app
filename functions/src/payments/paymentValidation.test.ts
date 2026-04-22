import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {RunDoc} from "../shared/firestore";
import {
  buildOrderCreatePayload,
  buildPaymentRecord,
  verifyPaidRunBooking,
} from "./paymentValidation";

function buildRunDoc(overrides: Partial<RunDoc> = {}): RunDoc {
  return {
    runClubId: "club-1",
    startTime: {} as FirebaseFirestore.Timestamp,
    endTime: {} as FirebaseFirestore.Timestamp,
    meetingPoint: "Carter Road",
    distanceKm: 5,
    pace: "easy",
    capacityLimit: 20,
    description: "Easy paced seaside run.",
    priceInPaise: 25000,
    signedUpUserIds: [],
    attendedUserIds: [],
    waitlistUserIds: [],
    constraints: {
      minAge: 0,
      maxAge: 99,
    },
    genderCounts: {},
    ...overrides,
  };
}

test("buildOrderCreatePayload derives trusted amount and notes", () => {
  const payload = buildOrderCreatePayload({
    runId: "run-1",
    run: buildRunDoc(),
    userId: "runner-1",
    receiptToken: 123,
  });

  assert.deepEqual(payload, {
    amount: 25000,
    currency: "INR",
    receipt: "run_run-1_123",
    notes: {
      runId: "run-1",
      userId: "runner-1",
    },
  });
});

test("buildOrderCreatePayload rejects free runs", () => {
  assert.throws(
    () =>
      buildOrderCreatePayload({
        runId: "run-1",
        run: buildRunDoc({priceInPaise: 0}),
        userId: "runner-1",
        receiptToken: 123,
      }),
    isHttpsError("invalid-argument", "Run price must be a positive integer.")
  );
});

test("verifyPaidRunBooking returns booking details from trusted Razorpay data", () => {
  const booking = verifyPaidRunBooking({
    order: {
      id: "order_123",
      amount: 25000,
      currency: "INR",
      amount_paid: 25000,
      amount_due: 0,
      notes: {
        runId: "run-1",
        userId: "runner-1",
      },
    },
    payment: {
      id: "pay_123",
      order_id: "order_123",
      amount: 25000,
      currency: "INR",
      status: "captured",
      refund_status: "null",
    },
    expectedUserId: "runner-1",
  });

  assert.deepEqual(booking, {
    runId: "run-1",
    userId: "runner-1",
    amountInPaise: 25000,
    currency: "INR",
  });
});

test("verifyPaidRunBooking rejects mismatched users and refunded payments", () => {
  assert.throws(
    () =>
      verifyPaidRunBooking({
        order: {
          id: "order_123",
          amount: 25000,
          currency: "INR",
          amount_paid: 25000,
          amount_due: 0,
          notes: {
            runId: "run-1",
            userId: "runner-2",
          },
        },
        payment: {
          id: "pay_123",
          order_id: "order_123",
          amount: 25000,
          currency: "INR",
          status: "captured",
          refund_status: "null",
        },
        expectedUserId: "runner-1",
      }),
    isHttpsError(
      "permission-denied",
      "This order does not belong to the signed-in user."
    )
  );

  assert.throws(
    () =>
      verifyPaidRunBooking({
        order: {
          id: "order_123",
          amount: 25000,
          currency: "INR",
          amount_paid: 25000,
          amount_due: 0,
          notes: {
            runId: "run-1",
            userId: "runner-1",
          },
        },
        payment: {
          id: "pay_123",
          order_id: "order_123",
          amount: 25000,
          currency: "INR",
          status: "captured",
          refund_status: "full",
          amount_refunded: 25000,
        },
        expectedUserId: "runner-1",
      }),
    isHttpsError(
      "failed-precondition",
      "Refunded payments cannot be used for booking."
    )
  );
});

test("buildPaymentRecord always writes signUpFailed explicitly", () => {
  assert.deepEqual(
    buildPaymentRecord({
      userId: "runner-1",
      orderId: "order_123",
      paymentId: "pay_123",
      runId: "run-1",
      amountInPaise: 25000,
      currency: "INR",
      status: "completed",
    }),
    {
      userId: "runner-1",
      orderId: "order_123",
      paymentId: "pay_123",
      runId: "run-1",
      amount: 25000,
      currency: "INR",
      status: "completed",
      signUpFailed: false,
    }
  );
});

function isHttpsError(expectedCode: string, expectedMessage: string) {
  return (error: unknown) =>
    error instanceof HttpsError &&
    error.code === expectedCode &&
    error.message === expectedMessage;
}
