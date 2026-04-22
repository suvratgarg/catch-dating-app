import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError, type CallableRequest} from "firebase-functions/v2/https";
import Razorpay from "razorpay";
import {verifyRazorpayPaymentHandler} from "./verifyRazorpayPayment";

test("verifyRazorpayPaymentHandler books the trusted run from Razorpay metadata", async () => {
  const paymentDoc = createPaymentDocRecorder();
  const signUpCalls: Array<{runId: string; userId: string}> = [];
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
                runId: "trusted-run",
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
            refund: async () => {
              throw new Error("Refund should not be called on success.");
            },
          },
        }) as unknown as Razorpay,
      serverTimestamp: () => "server-now",
      signUpForRun: async (_db, runId, userId) => {
        signUpCalls.push({runId, userId});
      },
      verifySignature: () => true,
    }
  );

  assert.deepEqual(signUpCalls, [{runId: "trusted-run", userId: "runner-1"}]);
  assert.deepEqual(paymentDoc.setCalls, [
    {
      userId: "runner-1",
      orderId: "order_123",
      paymentId: "pay_123",
      runId: "trusted-run",
      amount: 25000,
      currency: "INR",
      status: "completed",
      signUpFailed: false,
      createdAt: "server-now",
    },
  ]);
  assert.deepEqual(result, {verified: true, runId: "trusted-run"});
});

test("verifyRazorpayPaymentHandler records a refunded failure when sign-up loses the race", async () => {
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
                  runId: "trusted-run",
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
        signUpForRun: async () => {
          throw new HttpsError("failed-precondition", "This run is now full.");
        },
        verifySignature: () => true,
      }
    ),
    isHttpsError("failed-precondition", "This run is now full.")
  );

  assert.deepEqual(refundCalls, [{paymentId: "pay_123", amount: 25000}]);
  assert.deepEqual(paymentDoc.setCalls, [
    {
      userId: "runner-1",
      orderId: "order_123",
      paymentId: "pay_123",
      runId: "trusted-run",
      amount: 25000,
      currency: "INR",
      status: "refunded",
      signUpFailed: true,
      createdAt: "server-now",
    },
  ]);
});

test("verifyRazorpayPaymentHandler rejects invalid signatures before fetching Razorpay", async () => {
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
        signUpForRun: async () => undefined,
        verifySignature: () => false,
      }
    ),
    isHttpsError(
      "invalid-argument",
      "Payment signature verification failed."
    )
  );

  assert.deepEqual(paymentDoc.setCalls, []);
});

function buildRequest({
  data,
  auth,
}: {
  data: Record<string, unknown> | null;
  auth?: {uid: string};
}): CallableRequest<Record<string, unknown> | null> {
  return {
    data,
    auth: auth
      ? ({uid: auth.uid, token: {}} as CallableRequest["auth"])
      : undefined,
    rawRequest: {} as CallableRequest["rawRequest"],
    acceptsStreaming: false,
  };
}

function createPaymentDocRecorder() {
  const setCalls: Array<Record<string, unknown>> = [];
  return {
    setCalls,
    ref: {
      set: async (data: Record<string, unknown>) => {
        setCalls.push(data);
      },
    },
  };
}

function createPaymentsFirestore(paymentDoc: {
  ref: {set: (data: Record<string, unknown>) => Promise<void>};
}): FirebaseFirestore.Firestore {
  return {
    collection: () => ({
      doc: () => paymentDoc.ref,
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
