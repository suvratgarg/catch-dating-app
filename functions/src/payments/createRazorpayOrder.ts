import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {defineSecret} from "firebase-functions/params";
import Razorpay from "razorpay";
import {RunDoc} from "../types/firestore";

const razorpayKeyId = defineSecret("RAZORPAY_KEY_ID");
const razorpayKeySecret = defineSecret("RAZORPAY_KEY_SECRET");

interface CreateOrderData {
  activityId: string; // runId
  amount: number; // in paise
  currency: string;
}

export const createRazorpayOrder = onCall(
  {secrets: [razorpayKeyId, razorpayKeySecret]},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be signed in to book.");
    }

    const {activityId, amount, currency} = request.data as CreateOrderData;

    if (!activityId || typeof amount !== "number" || amount <= 0) {
      throw new HttpsError(
        "invalid-argument",
        "activityId and a positive amount are required."
      );
    }

    const db = admin.firestore();
    const runSnap = await db.collection("runs").doc(activityId).get();

    if (!runSnap.exists) {
      throw new HttpsError("not-found", "Run not found.");
    }

    const run = runSnap.data() as RunDoc;

    // Pre-flight capacity check (non-atomic — the real check is in signUpUserForRun).
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

    const razorpay = new Razorpay({
      key_id: razorpayKeyId.value(),
      key_secret: razorpayKeySecret.value(),
    });

    const order = await razorpay.orders.create({
      amount,
      currency: currency || "INR",
      receipt: `run_${activityId}_${Date.now()}`,
      notes: {
        activityId,
        userId: request.auth.uid,
      },
    });

    return {
      orderId: order.id,
      amount: order.amount,
      currency: order.currency,
    };
  }
);
