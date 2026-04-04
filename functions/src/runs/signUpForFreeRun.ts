import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {RunDoc} from "../types/firestore";
import {signUpUserForRun} from "./signUpUserForRun";

interface SignUpForFreeRunData {
  runId: string;
}

export const signUpForFreeRun = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be signed in to book a run.");
  }

  const {runId} = request.data as SignUpForFreeRunData;

  if (!runId) {
    throw new HttpsError("invalid-argument", "runId is required.");
  }

  const db = admin.firestore();

  // Verify the run exists and is actually free.
  const runSnap = await db.collection("runs").doc(runId).get();

  if (!runSnap.exists) {
    throw new HttpsError("not-found", "Run not found.");
  }

  const run = runSnap.data() as RunDoc;

  if (run.priceInPaise !== 0) {
    throw new HttpsError(
      "permission-denied",
      "This run requires payment. Use the payment flow instead."
    );
  }

  await signUpUserForRun(db, runId, request.auth.uid);

  return {success: true};
});
