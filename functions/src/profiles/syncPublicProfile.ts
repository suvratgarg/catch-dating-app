import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {UserProfileDoc} from "../shared/firestore";
import {
  publicAvatarUrl,
  publicProfileFromUserProfileDoc,
} from "../shared/profileProjection";

interface SyncPublicProfileDeps {
  firestore: () => FirebaseFirestore.Firestore;
}

const defaultDeps: SyncPublicProfileDeps = {
  firestore: () => admin.firestore(),
};

export const syncPublicProfile = onDocumentWritten(
  "users/{userId}",
  async (event) => {
    const {userId} = event.params;
    const user = event.data?.after.data() as UserProfileDoc | undefined;
    await syncUserProfileProjectionsHandler(userId, user);
  }
);

/**
 * Syncs public/profile-owned denormalized projections after users/{uid} writes.
 * @param {string} userId User id whose private profile changed.
 * @param {UserProfileDoc | undefined} user Current user profile, undefined
 * when the source document was deleted.
 * @param {SyncPublicProfileDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function syncUserProfileProjectionsHandler(
  userId: string,
  user: UserProfileDoc | undefined,
  deps: SyncPublicProfileDeps = defaultDeps
): Promise<void> {
  const db = deps.firestore();
  const publicProfileRef = db.collection("publicProfiles").doc(userId);

  // User deleted — remove public profile too
  if (!user) {
    logger.info("Deleting public profile", {userId});
    await publicProfileRef.delete();
    return;
  }

  if (user.deleted) {
    logger.info("Deleting public profile for deleted user", {userId});
    await publicProfileRef.delete();
    return;
  }

  // Only sync once the profile is marked complete
  if (!user.profileComplete) return;

  const publicProfile = publicProfileFromUserProfileDoc(user);

  // Block underage users from appearing in any swipe queue.
  if (publicProfile.age < 18) {
    logger.warn("Blocking underage public profile sync", {
      userId,
      age: publicProfile.age,
    });
    await publicProfileRef.delete();
    return;
  }

  logger.info("Syncing public profile", {userId});
  await Promise.all([
    publicProfileRef.set(publicProfile),
    syncHostedRunClubHostProfile(userId, {
      hostName: publicProfile.name,
      hostAvatarUrl: publicAvatarUrl(user),
    }, deps),
    syncAuthoredReviewReviewerProfile(userId, {
      reviewerName: publicProfile.name,
    }, deps),
  ]);
}

/**
 * Updates hosted run-club denormalized host profile fields.
 * @param {string} userId Host user id.
 * @param {object} patch Host projection patch.
 * @param {string} patch.hostName Public host display name.
 * @param {string | null} patch.hostAvatarUrl Public host avatar URL.
 * @param {SyncPublicProfileDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function syncHostedRunClubHostProfile(
  userId: string,
  patch: {hostName: string; hostAvatarUrl: string | null},
  deps: SyncPublicProfileDeps = defaultDeps
): Promise<void> {
  const db = deps.firestore();
  const clubsSnap = await db
    .collection("runClubs")
    .where("hostUserId", "==", userId)
    .get();
  if (clubsSnap.empty) return;

  const batch = db.batch();
  clubsSnap.docs.forEach((doc) => batch.set(doc.ref, patch, {merge: true}));
  await batch.commit();
}

/**
 * Updates authored review denormalized reviewer profile fields.
 * @param {string} userId Reviewer user id.
 * @param {object} patch Reviewer projection patch.
 * @param {string} patch.reviewerName Public reviewer display name.
 * @param {SyncPublicProfileDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function syncAuthoredReviewReviewerProfile(
  userId: string,
  patch: {reviewerName: string},
  deps: SyncPublicProfileDeps = defaultDeps
): Promise<void> {
  const db = deps.firestore();
  const reviewsSnap = await db
    .collection("reviews")
    .where("reviewerUserId", "==", userId)
    .get();
  if (reviewsSnap.empty) return;

  const batch = db.batch();
  reviewsSnap.docs.forEach((doc) => batch.set(doc.ref, patch, {merge: true}));
  await batch.commit();
}
