import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {RunDoc} from "../shared/firestore";

interface SyncRunClubNextRunDeps {
  firestore: () => FirebaseFirestore.Firestore;
  nowTimestamp: () => FirebaseFirestore.Timestamp;
}

const defaultDeps: SyncRunClubNextRunDeps = {
  firestore: () => admin.firestore(),
  nowTimestamp: () => admin.firestore.Timestamp.now(),
};

/**
 * Recomputes the next upcoming active run projection for one run club.
 * @param {string} runClubId Run club id.
 * @param {SyncRunClubNextRunDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function refreshRunClubNextRun(
  runClubId: string,
  deps: SyncRunClubNextRunDeps = defaultDeps
): Promise<void> {
  const db = deps.firestore();
  const clubRef = db.collection("runClubs").doc(runClubId);
  const clubSnap = await clubRef.get();

  if (!clubSnap.exists) {
    return;
  }

  const nextRunSnap = await db
    .collection("runs")
    .where("runClubId", "==", runClubId)
    .where("status", "==", "active")
    .where("startTime", ">=", deps.nowTimestamp())
    .orderBy("startTime", "asc")
    .limit(1)
    .get();

  const nextRun = nextRunSnap.docs[0]?.data() as RunDoc | undefined;
  await clubRef.set({
    nextRunAt: nextRun?.startTime ?? null,
    nextRunLabel: nextRun?.meetingPoint ?? null,
  }, {merge: true});
}

/**
 * Recomputes run-club next-run projections affected by a run write.
 * @param {RunDoc | undefined} before Run before state.
 * @param {RunDoc | undefined} after Run after state.
 * @param {SyncRunClubNextRunDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function syncRunClubNextRunHandler(
  before: RunDoc | undefined,
  after: RunDoc | undefined,
  deps: SyncRunClubNextRunDeps = defaultDeps
): Promise<void> {
  const runClubIds = new Set<string>();

  if (before?.runClubId) {
    runClubIds.add(before.runClubId);
  }
  if (after?.runClubId) {
    runClubIds.add(after.runClubId);
  }

  await Promise.all(
    Array.from(runClubIds).map(
      (runClubId) => refreshRunClubNextRun(runClubId, deps)
    )
  );
}

export const syncRunClubNextRun = onDocumentWritten(
  "runs/{runId}",
  async (event) => {
    const before = event.data?.before.data() as RunDoc | undefined;
    const after = event.data?.after.data() as RunDoc | undefined;
    await syncRunClubNextRunHandler(before, after);
  }
);
