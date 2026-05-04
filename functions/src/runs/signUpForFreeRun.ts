import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {z} from "zod";
import {RunDoc} from "../shared/firestore";
import {signUpUserForRun} from "./signUpUserForRun";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {requireAuth} from "../shared/auth";
import {validateCallable} from "../shared/validation";

const SignUpForFreeRunSchema = z.object({
  runId: z.string(),
});

export const signUpForFreeRun = onCall(appCheckCallableOptions, async (
  request
) => {
  const uid = requireAuth(request);
  const {runId} = validateCallable(request, SignUpForFreeRunSchema);

  await checkRateLimit(admin.firestore(), uid, "signUpForFreeRun");

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

  await signUpUserForRun(db, runId, uid);

  return {success: true};
});
