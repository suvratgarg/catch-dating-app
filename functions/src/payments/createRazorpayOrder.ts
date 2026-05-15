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
import {RunIdCallablePayload} from "../shared/generated/runIdCallablePayload";
import {validateRunIdCallablePayload} from
  "../shared/generated/schemaValidators";
import {normalizeSingleIdPayload} from
  "../shared/callablePayloadNormalization";
import {validateCallableWithAjv, requireDoc} from "../shared/validation";
import {runParticipationId} from "../shared/relationshipDocuments";
import {assertNoUserRunScheduleConflict} from "../runs/scheduleConflicts";

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
  const {runId} = validateCallableWithAjv<RunIdCallablePayload>(
    request,
    validateRunIdCallablePayload,
    normalizeSingleIdPayload("runId")
  );

  const db = deps.firestore();
  const [runSnap, participationSnap, activeParticipationsSnap] =
    await Promise.all([
      db.collection("runs").doc(runId).get(),
      db.collection("runParticipations")
        .doc(runParticipationId(runId, uid))
        .get(),
      db.collection("runParticipations")
        .where("runId", "==", runId)
        .where("status", "in", ["signedUp", "attended"])
        .get(),
    ]);

  if (!runSnap.exists) {
    throw new HttpsError("not-found", "Run not found.");
  }

  const run = requireDoc<RunDoc>(runSnap, "RunDoc");
  const participation = participationSnap.exists ?
    participationSnap.data() as {status?: string} :
    null;
  const activeParticipantIds = activeParticipationsSnap.docs
    .map((doc) => doc.data().uid)
    .filter((participantUid) => typeof participantUid === "string");

  // Pre-flight capacity check; the real atomic check happens in
  // signUpUserForRun.
  if (
    participation?.status === "signedUp" ||
    participation?.status === "attended"
  ) {
    throw new HttpsError(
      "already-exists",
      "You are already booked for this run."
    );
  }

  const signedUpCount = activeParticipationsSnap.docs
    .filter((doc) => doc.data().status === "signedUp")
    .length;
  if ((run.bookedCount ?? signedUpCount) >= run.capacityLimit) {
    throw new HttpsError(
      "failed-precondition",
      "This run is full. You can join the waitlist instead."
    );
  }

  await assertNoUserRunScheduleConflict(db, {
    uid,
    runId,
    runClubId: run.runClubId,
    startTimeMillis: run.startTime.toMillis(),
    endTimeMillis: run.endTime.toMillis(),
  });

  if (await hasBlockingRelationship(db, uid, activeParticipantIds)) {
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
