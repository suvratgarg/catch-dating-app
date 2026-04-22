import {
  CallableRequest,
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import Razorpay from "razorpay";
import {RunDoc} from "../shared/firestore";
import {buildOrderCreatePayload} from "./paymentValidation";
import {
  createRazorpayClient,
  razorpayKeyId,
  razorpayKeySecret,
} from "./razorpay";

interface CreateOrderData {
  runId: string;
}

interface CreateRazorpayOrderDeps {
  createClient: () => Razorpay;
  firestore: () => FirebaseFirestore.Firestore;
  now: () => number;
}

const defaultDeps: CreateRazorpayOrderDeps = {
  createClient: createRazorpayClient,
  firestore: () => admin.firestore(),
  now: () => Date.now(),
};

export async function createRazorpayOrderHandler(
  request: CallableRequest<Partial<CreateOrderData> | null>,
  deps: CreateRazorpayOrderDeps = defaultDeps
) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be signed in to book.");
  }

  const runId = request.data?.runId;

  if (!runId) {
    throw new HttpsError("invalid-argument", "runId is required.");
  }

  const db = deps.firestore();
  const runSnap = await db.collection("runs").doc(runId).get();

  if (!runSnap.exists) {
    throw new HttpsError("not-found", "Run not found.");
  }

  const run = runSnap.data() as RunDoc;

  // Pre-flight capacity check; the real atomic check happens in
  // signUpUserForRun.
  if (run.signedUpUserIds.includes(request.auth.uid)) {
    throw new HttpsError(
      "already-exists",
      "You are already booked for this run."
    );
  }

  if (run.signedUpUserIds.length >= run.capacityLimit) {
    throw new HttpsError(
      "failed-precondition",
      "This run is full. You can join the waitlist instead."
    );
  }

  const razorpay = deps.createClient();
  const order = await razorpay.orders.create(
    buildOrderCreatePayload({
      runId,
      run,
      userId: request.auth.uid,
      receiptToken: deps.now(),
    })
  );

  return {
    orderId: order.id,
    amount: Number(order.amount),
    currency: order.currency,
  };
}

export const createRazorpayOrder = onCall(
  {secrets: [razorpayKeyId, razorpayKeySecret]},
  (request) => createRazorpayOrderHandler(request)
);
