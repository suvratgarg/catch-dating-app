import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {RunClubMembershipDoc} from "../shared/firestore";

interface SyncRunClubMemberStatsDeps {
  firestore: () => FirebaseFirestore.Firestore;
}

const defaultDeps: SyncRunClubMemberStatsDeps = {
  firestore: () => admin.firestore(),
};

/**
 * Recomputes the denormalized member count for one run club.
 * @param {string} runClubId Run club id.
 * @param {SyncRunClubMemberStatsDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function refreshRunClubMemberStats(
  runClubId: string,
  deps: SyncRunClubMemberStatsDeps = defaultDeps
): Promise<void> {
  const db = deps.firestore();
  const clubRef = db.collection("runClubs").doc(runClubId);
  const clubSnap = await clubRef.get();

  if (!clubSnap.exists) {
    return;
  }

  const membershipsSnap = await db
    .collection("runClubMemberships")
    .where("clubId", "==", runClubId)
    .where("status", "==", "active")
    .get();

  await clubRef.set({
    memberCount: membershipsSnap.docs.length,
  }, {merge: true});
}

/**
 * Recomputes run-club member counts affected by a membership write.
 * @param {RunClubMembershipDoc | undefined} before Membership before state.
 * @param {RunClubMembershipDoc | undefined} after Membership after state.
 * @param {SyncRunClubMemberStatsDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function syncRunClubMemberStatsHandler(
  before: RunClubMembershipDoc | undefined,
  after: RunClubMembershipDoc | undefined,
  deps: SyncRunClubMemberStatsDeps = defaultDeps
): Promise<void> {
  const runClubIds = new Set<string>();

  if (before?.clubId) {
    runClubIds.add(before.clubId);
  }
  if (after?.clubId) {
    runClubIds.add(after.clubId);
  }

  await Promise.all(
    Array.from(runClubIds).map(
      (runClubId) => refreshRunClubMemberStats(runClubId, deps)
    )
  );
}

export const syncRunClubMemberStats = onDocumentWritten(
  "runClubMemberships/{membershipId}",
  async (event) => {
    const before = event.data?.before.data() as
      RunClubMembershipDoc | undefined;
    const after = event.data?.after.data() as
      RunClubMembershipDoc | undefined;
    await syncRunClubMemberStatsHandler(before, after);
  }
);
