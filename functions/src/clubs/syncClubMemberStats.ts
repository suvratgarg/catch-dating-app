import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {ClubMembershipDoc} from "../shared/firestore";

interface SyncClubMemberStatsDeps {
  firestore: () => FirebaseFirestore.Firestore;
}

const defaultDeps: SyncClubMemberStatsDeps = {
  firestore: () => admin.firestore(),
};

/**
 * Recomputes the denormalized member count for one club.
 * @param {string} clubId Club id.
 * @param {SyncClubMemberStatsDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function refreshClubMemberStats(
  clubId: string,
  deps: SyncClubMemberStatsDeps = defaultDeps
): Promise<void> {
  const db = deps.firestore();
  const clubRef = db.collection("clubs").doc(clubId);
  const clubSnap = await clubRef.get();

  if (!clubSnap.exists) {
    return;
  }

  const membershipsSnap = await db
    .collection("clubMemberships")
    .where("clubId", "==", clubId)
    .where("status", "==", "active")
    .get();

  await clubRef.set({
    memberCount: membershipsSnap.docs.length,
  }, {merge: true});
}

/**
 * Recomputes club member counts affected by a membership write.
 * @param {ClubMembershipDoc | undefined} before Membership before state.
 * @param {ClubMembershipDoc | undefined} after Membership after state.
 * @param {SyncClubMemberStatsDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function syncClubMemberStatsHandler(
  before: ClubMembershipDoc | undefined,
  after: ClubMembershipDoc | undefined,
  deps: SyncClubMemberStatsDeps = defaultDeps
): Promise<void> {
  const clubIds = new Set<string>();

  if (before?.clubId) {
    clubIds.add(before.clubId);
  }
  if (after?.clubId) {
    clubIds.add(after.clubId);
  }

  await Promise.all(
    Array.from(clubIds).map(
      (clubId) => refreshClubMemberStats(clubId, deps)
    )
  );
}

export const syncClubMemberStats = onDocumentWritten(
  "clubMemberships/{membershipId}",
  async (event) => {
    const before = event.data?.before.data() as
      ClubMembershipDoc | undefined;
    const after = event.data?.after.data() as
      ClubMembershipDoc | undefined;
    await syncClubMemberStatsHandler(before, after);
  }
);
