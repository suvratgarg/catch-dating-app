/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError, type CallableRequest} from "firebase-functions/v2/https";
import Razorpay from "razorpay";
import {verifyRazorpayPaymentHandler} from "./verifyRazorpayPayment";

test(
  "verifyRazorpayPaymentHandler books trusted event from Razorpay metadata",
  async () => {
    const paymentDoc = createPaymentDocRecorder();
    const signUpCalls: Array<{
      eventId: string;
      userId: string;
      options: Record<string, unknown> | undefined;
    }> = [];
    const result = await verifyRazorpayPaymentHandler(
      buildRequest({
        auth: {uid: "runner-1"},
        data: {
          paymentId: "pay_123",
          orderId: "order_123",
          signature: "sig_123",
        },
      }),
      {
        firestore: () => createPaymentsFirestore(paymentDoc),
        createClient: () =>
        ({
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
                inviteLinkId: "link-1",
                inviteSource: "instagram-bio",
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
            refund: async () => {
              throw new Error("Refund should not be called on success.");
            },
          },
        }) as unknown as Razorpay,
        serverTimestamp: () => "server-now",
        signUpForEvent: async (_db, eventId, userId, _paymentId, options) => {
          signUpCalls.push({eventId, userId, options});
        },
        verifySignature: () => true,
      }
    );

    assert.deepEqual(signUpCalls, [{
      eventId: "trusted-event",
      userId: "runner-1",
      options: {
        hasValidInvite: false,
        inviteAttribution: {
          inviteLinkId: "link-1",
          inviteSource: "instagram-bio",
        },
      },
    }]);
    assert.deepEqual(paymentDoc.setCalls, [
      {
        userId: "runner-1",
        orderId: "order_123",
        paymentId: "pay_123",
        eventId: "trusted-event",
        amount: 25000,
        amountMinor: 25000,
        currency: "INR",
        provider: "razorpay",
        status: "completed",
        signUpFailed: false,
        inviteLinkId: "link-1",
        inviteSource: "instagram-bio",
        createdAt: "server-now",
      },
    ]);
    assert.equal(paymentDoc.inviteLinkSetCalls.length, 1);
    assert.equal(paymentDoc.inviteLinkSetCalls[0].docId, "link-1");
    assert.ok("paidCount" in paymentDoc.inviteLinkSetCalls[0].data);
    assert.deepEqual(result, {verified: true, eventId: "trusted-event"});
  }
);

test(
  "verifyRazorpayPaymentHandler records refunded race-loss failure",
  async () => {
    const paymentDoc = createPaymentDocRecorder();
    const refundCalls: Array<{paymentId: string; amount: number}> = [];

    await assert.rejects(
      verifyRazorpayPaymentHandler(
        buildRequest({
          auth: {uid: "runner-1"},
          data: {
            paymentId: "pay_123",
            orderId: "order_123",
            signature: "sig_123",
          },
        }),
        {
          firestore: () => createPaymentsFirestore(paymentDoc),
          createClient: () =>
          ({
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
              refund: async (paymentId: string, data: {amount: number}) => {
                refundCalls.push({paymentId, amount: data.amount});
              },
            },
          }) as unknown as Razorpay,
          serverTimestamp: () => "server-now",
          signUpForEvent: async () => {
            throw new HttpsError(
              "failed-precondition",
              "This event is now full."
            );
          },
          verifySignature: () => true,
        }
      ),
      isHttpsError("failed-precondition", "This event is now full.")
    );

    assert.deepEqual(refundCalls, [{paymentId: "pay_123", amount: 25000}]);
    assert.deepEqual(paymentDoc.setCalls, [
      {
        userId: "runner-1",
        orderId: "order_123",
        paymentId: "pay_123",
        eventId: "trusted-event",
        amount: 25000,
        amountMinor: 25000,
        currency: "INR",
        provider: "razorpay",
        status: "refunded",
        signUpFailed: true,
        createdAt: "server-now",
      },
    ]);
  }
);

test(
  "verifyRazorpayPaymentHandler rejects invalid signatures before fetching",
  async () => {
    const paymentDoc = createPaymentDocRecorder();

    await assert.rejects(
      verifyRazorpayPaymentHandler(
        buildRequest({
          auth: {uid: "runner-1"},
          data: {
            paymentId: "pay_123",
            orderId: "order_123",
            signature: "bad",
          },
        }),
        {
          firestore: () => createPaymentsFirestore(paymentDoc),
          createClient: failOnClientUse,
          serverTimestamp: () => "server-now",
          signUpForEvent: async () => undefined,
          verifySignature: () => false,
        }
      ),
      isHttpsError(
        "invalid-argument",
        "Payment signature verification failed."
      )
    );

    assert.deepEqual(paymentDoc.setCalls, []);
  }
);

test(
  "verifyRazorpayPaymentHandler rate limits before signature or Razorpay fetch",
  async () => {
    const paymentDoc = createPaymentDocRecorder();

    await assert.rejects(
      verifyRazorpayPaymentHandler(
        buildRequest({
          auth: {uid: "runner-1"},
          data: {
            paymentId: "pay_123",
            orderId: "order_123",
            signature: "sig_123",
          },
        }),
        {
          firestore: () => createPaymentsFirestore(paymentDoc),
          createClient: failOnClientUse,
          serverTimestamp: () => "server-now",
          signUpForEvent: async () => undefined,
          verifySignature: () => {
            throw new Error("Signature should not be checked.");
          },
          checkRateLimit: async (_db, uid, action) => {
            assert.equal(uid, "runner-1");
            assert.equal(action, "verifyRazorpayPayment");
            throw new HttpsError(
              "resource-exhausted",
              "Too many payment verification attempts."
            );
          },
        }
      ),
      isHttpsError(
        "resource-exhausted",
        "Too many payment verification attempts."
      )
    );

    assert.deepEqual(paymentDoc.setCalls, []);
  }
);

function buildRequest({
  data,
  auth,
}: {
  data: Record<string, unknown> | null;
  auth?: {uid: string};
}): CallableRequest<Record<string, unknown> | null> {
  return {
    data,
    auth: auth ?
      ({uid: auth.uid, token: {}} as CallableRequest["auth"]) :
      undefined,
    rawRequest: {} as CallableRequest["rawRequest"],
    acceptsStreaming: false,
  };
}

function createPaymentDocRecorder() {
  const setCalls: Array<Record<string, unknown>> = [];
  const inviteLinkSetCalls: Array<{
    docId: string;
    data: Record<string, unknown>;
  }> = [];
  return {
    setCalls,
    inviteLinkSetCalls,
    ref: {
      get: async () => ({
        exists: false,
        data: () => undefined,
      }),
      set: async (data: Record<string, unknown>) => {
        setCalls.push(data);
      },
    },
  };
}

function createPaymentsFirestore(paymentDoc: {
  inviteLinkSetCalls: Array<{docId: string; data: Record<string, unknown>}>;
  ref: {
    get: () => Promise<{
      exists: boolean;
      data: () => Record<string, unknown> | undefined;
    }>;
    set: (data: Record<string, unknown>) => Promise<void>;
  };
}): FirebaseFirestore.Firestore {
  return {
    collection: (path: string) => ({
      doc: (docId: string) => {
        if (path === "payments") return paymentDoc.ref;
        if (path === "eventInviteLinks") {
          return {
            set: async (data: Record<string, unknown>) => {
              paymentDoc.inviteLinkSetCalls.push({docId, data});
            },
          };
        }
        return {
          get: async () => ({
            exists: false,
            data: () => undefined,
          }),
        };
      },
    }),
  } as unknown as FirebaseFirestore.Firestore;
}

function failOnClientUse(): Razorpay {
  throw new Error("Razorpay client should not be created in this test.");
}

function isHttpsError(expectedCode: string, expectedMessage: string) {
  return (error: unknown) =>
    error instanceof HttpsError &&
    error.code === expectedCode &&
    error.message === expectedMessage;
}
