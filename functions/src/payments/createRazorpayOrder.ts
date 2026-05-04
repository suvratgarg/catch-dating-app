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
import {hasBlockingRelationship} from "../safety/blocking";
import {appCheckCallableOptionsWithSecrets} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {requireAuth} from "../shared/auth";
import {validateCallable, requireDoc} from "../shared/validation";
import {z} from "zod";

const CreateOrderSchema = z.object({
  runId: z.string(),
});

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

/**
 * Creates a Razorpay order from trusted Firestore run data.
 * @param {CallableRequest<Partial<CreateOrderData> | null>} request Callable.
 * @param {CreateRazorpayOrderDeps} deps Injectable service dependencies.
 * @return {Promise<{orderId: string, amount: number, currency: string}>} Order.
 */
export async function createRazorpayOrderHandler(
  request: CallableRequest<unknown>,
  deps: CreateRazorpayOrderDeps = defaultDeps
) {
  const uid = requireAuth(request);
  const {runId} = validateCallable(request, CreateOrderSchema);

  const db = deps.firestore();
  const runSnap = await db.collection("runs").doc(runId).get();

  if (!runSnap.exists) {
    throw new HttpsError("not-found", "Run not found.");
  }

  const run = requireDoc<RunDoc>(runSnap, "RunDoc");

  // Pre-flight capacity check; the real atomic check happens in
  // signUpUserForRun.
  if (run.signedUpUserIds.includes(uid)) {
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

  if (await hasBlockingRelationship(db, uid, [
    ...run.signedUpUserIds,
    ...(run.attendedUserIds ?? []),
  ])) {
    throw new HttpsError(
      "failed-precondition",
      "This run is unavailable."
    );
  }

  const razorpay = deps.createClient();
  const order = await razorpay.orders.create(
    buildOrderCreatePayload({
      runId,
      run,
      userId: uid,
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
  appCheckCallableOptionsWithSecrets([razorpayKeyId, razorpayKeySecret]),
  async (request) => {
    if (request.auth) {
      await checkRateLimit(
        admin.firestore(),
        request.auth.uid,
        "createRazorpayOrder"
      );
    }
    return createRazorpayOrderHandler(request);
  }
);
