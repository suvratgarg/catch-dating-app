import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {z} from "zod";
import {RunDoc} from "../shared/firestore";
import {requireAuth} from "../shared/auth";
import {assertNoBlockingRelationshipInTransaction} from "../safety/blocking";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {validateCallable} from "../shared/validation";

const JoinRunWaitlistSchema = z.object({
  runId: z.string(),
});

/**
 * Adds a user to a run waitlist after applying the same block boundary as
 * booking. Kept server-side so block state is not exposed through rules.
 */
export const joinRunWaitlist = onCall(appCheckCallableOptions, async (
  request
) => {
  const userId = requireAuth(request);
  const {runId} = validateCallable(request, JoinRunWaitlistSchema);

  const db = admin.firestore();
  const runRef = db.collection("runs").doc(runId);

  await db.runTransaction(async (tx) => {
    const runSnap = await tx.get(runRef);
    if (!runSnap.exists) {
      throw new HttpsError("not-found", "Run not found.");
    }

    const run = runSnap.data() as RunDoc;
    if (run.signedUpUserIds.includes(userId)) {
      throw new HttpsError(
        "already-exists",
        "You are already booked for this run."
      );
    }

    if (run.waitlistUserIds?.includes(userId)) {
      return;
    }

    await assertNoBlockingRelationshipInTransaction(tx, db, userId, [
      ...run.signedUpUserIds,
      ...(run.attendedUserIds ?? []),
    ]);

    tx.update(runRef, {
      waitlistUserIds: admin.firestore.FieldValue.arrayUnion(userId),
    });
  });

  return {waitlisted: true};
});
