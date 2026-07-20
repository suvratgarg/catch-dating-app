import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {
  ClubMembershipDocument,
  OrganizerFollowDocument,
} from "../shared/generated/firestoreAdminTypes";

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
 * @param {ClubMembershipDocument | undefined} before Membership before state.
 * @param {ClubMembershipDocument | undefined} after Membership after state.
 * @param {SyncClubMemberStatsDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function syncClubMemberStatsHandler(
  before: ClubMembershipDocument | undefined,
  after: ClubMembershipDocument | undefined,
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
      ClubMembershipDocument | undefined;
    const after = event.data?.after.data() as
      ClubMembershipDocument | undefined;
    await syncClubMemberStatsHandler(before, after);
  }
);

/** Recomputes the canonical follower count for one organizer. */
export async function refreshOrganizerFollowerStats(
  organizerId: string,
  deps: SyncClubMemberStatsDeps = defaultDeps
): Promise<void> {
  const db = deps.firestore();
  const organizerRef = db.collection("organizers").doc(organizerId);
  const organizerSnap = await organizerRef.get();
  if (!organizerSnap.exists) return;

  const followsSnap = await db
    .collection("organizerFollows")
    .where("organizerId", "==", organizerId)
    .where("status", "==", "active")
    .get();
  const followerCount = followsSnap.docs.length;
  const legacyClubRef = db.collection("clubs").doc(organizerId);
  const batch = db.batch();
  batch.set(organizerRef, {followerCount}, {merge: true});
  batch.set(legacyClubRef, {memberCount: followerCount}, {merge: true});
  await batch.commit();
}

/** Recomputes organizer follower counts affected by a follow-edge write. */
export async function syncOrganizerFollowerStatsHandler(
  before: OrganizerFollowDocument | undefined,
  after: OrganizerFollowDocument | undefined,
  deps: SyncClubMemberStatsDeps = defaultDeps
): Promise<void> {
  const organizerIds = new Set<string>();
  if (before?.organizerId) organizerIds.add(before.organizerId);
  if (after?.organizerId) organizerIds.add(after.organizerId);
  await Promise.all(
    Array.from(organizerIds).map((organizerId) =>
      refreshOrganizerFollowerStats(organizerId, deps)
    )
  );
}

export const syncOrganizerFollowerStats = onDocumentWritten(
  "organizerFollows/{followId}",
  async (event) => {
    const before = event.data?.before.data() as
      OrganizerFollowDocument | undefined;
    const after = event.data?.after.data() as
      OrganizerFollowDocument | undefined;
    await syncOrganizerFollowerStatsHandler(before, after);
  }
);
