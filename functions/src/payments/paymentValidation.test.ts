/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {
  EventDocument,
} from "../shared/generated/firestoreAdminTypes";
import {
  buildOrderCreatePayload,
  buildPaymentRecord,
  verifyPaidEventBooking,
} from "./paymentValidation";

function buildEventDoc(overrides: Partial<EventDocument> = {}): EventDocument {
  return {
    clubId: "club-1",
    startTime: {} as FirebaseFirestore.Timestamp,
    endTime: {} as FirebaseFirestore.Timestamp,
    meetingPoint: "Carter Road",
    eventFormat: {
      version: 1,
      activityKind: "socialRun",
      interactionModel: "pacePods",
      defaultPlaybookId: "social_run_light",
    },
    distanceKm: 5,
    pace: "easy",
    capacityLimit: 20,
    description: "Easy paced seaside event.",
    priceInPaise: 25000,
    currency: "INR",
    status: "active",
    cancelledAt: null,
    cancellationReason: null,
    constraints: {
      minAge: 0,
      maxAge: 99,
    },
    genderCounts: {},
    cohortCounts: {},
    waitlistedCohortCounts: {},
    ...overrides,
  };
}

test("buildOrderCreatePayload derives trusted amount and notes", () => {
  const payload = buildOrderCreatePayload({
    eventId: "event-1",
    event: buildEventDoc(),
    userId: "runner-1",
    receiptToken: 123,
  });

  assert.deepEqual(payload, {
    amount: 25000,
    currency: "INR",
    receipt: "event_event-1_123",
    notes: {
      eventId: "event-1",
      userId: "runner-1",
      quotedAmountInPaise: 25000,
      inviteVerified: "false",
    },
  });
});

test("buildOrderCreatePayload records verified invite orders", () => {
  const payload = buildOrderCreatePayload({
    eventId: "event-1",
    event: buildEventDoc(),
    userId: "runner-1",
    receiptToken: 123,
    inviteVerified: true,
  });

  assert.equal(payload.notes.inviteVerified, "true");
});

test("buildOrderCreatePayload rejects free events", () => {
  assert.throws(
    () =>
      buildOrderCreatePayload({
        eventId: "event-1",
        event: buildEventDoc({priceInPaise: 0}),
        userId: "runner-1",
        receiptToken: 123,
      }),
    isHttpsError("invalid-argument", "Event price must be a positive integer.")
  );
});

test(
  "buildOrderCreatePayload rejects non-INR paid events until a provider exists",
  () => {
    assert.throws(
      () =>
        buildOrderCreatePayload({
          eventId: "event-1",
          event: buildEventDoc({currency: "AUD"}),
          userId: "runner-1",
          receiptToken: 123,
        }),
      isHttpsError(
        "failed-precondition",
        "Paid bookings are not available for this event currency yet."
      )
    );
  }
);

test("buildOrderCreatePayload rejects cancelled events", () => {
  assert.throws(
    () =>
      buildOrderCreatePayload({
        eventId: "event-1",
        event: buildEventDoc({status: "cancelled"}),
        userId: "runner-1",
        receiptToken: 123,
      }),
    isHttpsError("failed-precondition", "This event has been cancelled.")
  );
});

test(
  "verifyPaidEventBooking returns booking details from trusted Razorpay data",
  () => {
    const booking = verifyPaidEventBooking({
      order: {
        id: "order_123",
        amount: 25000,
        currency: "INR",
        amount_paid: 25000,
        amount_due: 0,
        notes: {
          eventId: "event-1",
          userId: "runner-1",
          inviteVerified: "true",
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
      eventId: "event-1",
      userId: "runner-1",
      amountInPaise: 25000,
      currency: "INR",
      inviteVerified: true,
    });
  }
);

test(
  "verifyPaidEventBooking rejects mismatched users and refunded payments",
  () => {
    assert.throws(
      () =>
        verifyPaidEventBooking({
          order: {
            id: "order_123",
            amount: 25000,
            currency: "INR",
            amount_paid: 25000,
            amount_due: 0,
            notes: {
              eventId: "event-1",
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
        verifyPaidEventBooking({
          order: {
            id: "order_123",
            amount: 25000,
            currency: "INR",
            amount_paid: 25000,
            amount_due: 0,
            notes: {
              eventId: "event-1",
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
  }
);

test("buildPaymentRecord always writes signUpFailed explicitly", () => {
  assert.deepEqual(
    buildPaymentRecord({
      userId: "runner-1",
      orderId: "order_123",
      paymentId: "pay_123",
      eventId: "event-1",
      amountInPaise: 25000,
      currency: "INR",
      status: "completed",
    }),
    {
      userId: "runner-1",
      orderId: "order_123",
      paymentId: "pay_123",
      eventId: "event-1",
      amount: 25000,
      amountMinor: 25000,
      currency: "INR",
      provider: "razorpay",
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
