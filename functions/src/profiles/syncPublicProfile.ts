import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {
  UserProfileDocument,
} from "../shared/generated/firestoreAdminTypes";
import {
  publicProfileFromUserProfileDoc,
} from "../shared/profileProjection";
import {isSocialReadyUserProfile} from "../shared/profileReadiness";
import {clubHostProfiles} from "../shared/clubHosts";
import {HostProfileDocument} from "../shared/hostProfiles";

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
    const user = event.data?.after.data() as UserProfileDocument | undefined;
    await syncUserProfileProjectionsHandler(userId, user);
  }
);

export const syncHostProfile = onDocumentWritten(
  "hostProfiles/{userId}",
  async (event) => {
    const {userId} = event.params;
    const hostProfile = event.data?.after.data() as
      HostProfileDocument | undefined;
    await syncHostProfileProjectionsHandler(userId, hostProfile);
  }
);

/**
 * Syncs public/profile-owned denormalized projections after users/{uid} writes.
 * @param {string} userId User id whose private profile changed.
 * @param {UserProfileDocument | undefined} user Current user profile, undefined
 * when the source document was deleted.
 * @param {SyncPublicProfileDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function syncUserProfileProjectionsHandler(
  userId: string,
  user: UserProfileDocument | undefined,
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

  if (!isSocialReadyUserProfile(user)) {
    logger.info("Deleting public profile for incomplete social profile", {
      userId,
    });
    await publicProfileRef.delete();
    return;
  }

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
    syncAuthoredReviewReviewerProfile(userId, {
      reviewerName: publicProfile.name,
    }, deps),
  ]);
}

/**
 * Syncs professional host-owned denormalized projections.
 * @param {string} userId Host user id.
 * @param {HostProfileDocument | undefined} hostProfile Current host profile,
 * undefined when the source document was deleted.
 * @param {SyncPublicProfileDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function syncHostProfileProjectionsHandler(
  userId: string,
  hostProfile: HostProfileDocument | undefined,
  deps: SyncPublicProfileDeps = defaultDeps
): Promise<void> {
  await syncHostedClubHostProfile(userId, {
    hostName: nonBlank(hostProfile?.displayName) ?? "Catch Host",
    hostAvatarUrl: nonBlank(hostProfile?.avatarUrl),
  }, deps);
}

/**
 * Updates hosted club denormalized professional host profile fields.
 * @param {string} userId Host user id.
 * @param {object} patch Host projection patch.
 * @param {string} patch.hostName Professional host display name.
 * @param {string | null} patch.hostAvatarUrl Professional host avatar URL.
 * @param {SyncPublicProfileDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function syncHostedClubHostProfile(
  userId: string,
  patch: {hostName: string; hostAvatarUrl: string | null},
  deps: SyncPublicProfileDeps = defaultDeps
): Promise<void> {
  const db = deps.firestore();
  const [
    canonicalOwnerSnap,
    canonicalTeamSnap,
    legacyHostedSnap,
    legacyHostedByProjectionSnap,
  ] = await Promise.all([
    db.collection("organizers").where("ownerUserId", "==", userId).get(),
    db.collection("organizers")
      .where("hostUserIds", "array-contains", userId)
      .get(),
    db.collection("clubs").where("hostUserId", "==", userId).get(),
    db.collection("clubs").where("hostUserIds", "array-contains", userId).get(),
  ]);
  const docsByPath = new Map<string, FirebaseFirestore.QueryDocumentSnapshot>();
  for (const doc of canonicalOwnerSnap.docs) docsByPath.set(doc.ref.path, doc);
  for (const doc of canonicalTeamSnap.docs) docsByPath.set(doc.ref.path, doc);
  for (const doc of legacyHostedSnap.docs) docsByPath.set(doc.ref.path, doc);
  for (const doc of legacyHostedByProjectionSnap.docs) {
    docsByPath.set(doc.ref.path, doc);
  }
  if (docsByPath.size === 0) return;

  const batch = db.batch();
  docsByPath.forEach((doc) => {
    const club = doc.data() as Parameters<typeof clubHostProfiles>[0];
    const fields: Record<string, unknown> = {};
    if (club.hostUserId === userId) {
      fields.hostName = patch.hostName;
      fields.hostAvatarUrl = patch.hostAvatarUrl;
    }
    fields.hostProfiles = clubHostProfiles(club).map((host) =>
      host.uid === userId ?
        {
          ...host,
          displayName: patch.hostName,
          avatarUrl: patch.hostAvatarUrl,
        } :
        host
    );
    batch.set(doc.ref, fields, {merge: true});
  });
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

/**
 * Returns a trimmed string when a host profile field has display text.
 * @param {string | null | undefined} value Candidate profile text.
 * @return {string | null} Normalized text or null.
 */
function nonBlank(value: string | null | undefined): string | null {
  const normalized = value?.trim();
  return normalized ? normalized : null;
}
