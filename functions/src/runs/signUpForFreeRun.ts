import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {z} from "zod";
import {RunDoc} from "../shared/firestore";
import {signUpUserForRun} from "./signUpUserForRun";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {requireAuth} from "../shared/auth";
import {validateCallable} from "../shared/validation";

const SignUpForFreeRunSchema = z.object({
  runId: z.string().trim().min(1),
});

interface SignUpForFreeRunDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
  signUpForRun: (
    db: FirebaseFirestore.Firestore,
    runId: string,
    userId: string
  ) => Promise<void>;
}

const defaultDeps: SignUpForFreeRunDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  signUpForRun: signUpUserForRun,
};

/**
 * Callable implementation for signing the caller up for a free run.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {SignUpForFreeRunDeps} deps Injectable Firebase dependencies.
 * @return {Promise<{success: boolean}>} Operation result.
 */
export async function signUpForFreeRunHandler(
  request: CallableRequest<unknown>,
  deps: SignUpForFreeRunDeps = defaultDeps
): Promise<{success: boolean}> {
  const uid = requireAuth(request);
  const {runId} = validateCallable(request, SignUpForFreeRunSchema);
  const db = deps.firestore();

  await deps.checkRateLimit(db, uid, "signUpForFreeRun");

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

  await deps.signUpForRun(db, runId, uid);

  return {success: true};
}

export const signUpForFreeRun = onCall(appCheckCallableOptions, (request) =>
  signUpForFreeRunHandler(request)
);
