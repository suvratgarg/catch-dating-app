import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {
  UserProfileDoc,
  PublicProfileDoc,
  ProfilePromptAnswer,
  PhotoPromptAnswer,
} from "../shared/firestore";
import {computeAge} from "../shared/dates";
import {publicAvatarUrl, publicDisplayName} from "../shared/profileProjection";

interface SyncPublicProfileDeps {
  firestore: () => FirebaseFirestore.Firestore;
}

const defaultDeps: SyncPublicProfileDeps = {
  firestore: () => admin.firestore(),
};

const perfectRunPrompt = {
  promptId: "perfectRun",
  prompt: "A perfect run with me looks like...",
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

  const age = computeAge(user.dateOfBirth.toDate());

  // Block underage users from appearing in any swipe queue.
  if (age < 18) {
    logger.warn("Blocking underage public profile sync", {userId, age});
    await publicProfileRef.delete();
    return;
  }

  const displayName = publicDisplayName(user);
  const publicProfile: PublicProfileDoc = {
    name: displayName,
    age,
    profilePrompts: normalizeProfilePrompts(user),
    gender: user.gender,
    photoUrls: user.photoUrls ?? [],
    photoThumbnailUrls: user.photoThumbnailUrls ?? [],
    photoPrompts: normalizePhotoPrompts(user.photoPrompts),
    // Optional fields — omit undefined values so Firestore doesn't store them
    ...(user.city && {city: user.city}),
    ...(user.height !== undefined && {height: user.height}),
    ...(user.occupation && {occupation: user.occupation}),
    ...(user.company && {company: user.company}),
    ...(user.education && {education: user.education}),
    ...(user.religion && {religion: user.religion}),
    ...(user.languages?.length && {languages: user.languages}),
    ...(user.relationshipGoal && {relationshipGoal: user.relationshipGoal}),
    ...(user.drinking && {drinking: user.drinking}),
    ...(user.smoking && {smoking: user.smoking}),
    ...(user.workout && {workout: user.workout}),
    ...(user.diet && {diet: user.diet}),
    ...(user.children && {children: user.children}),
    paceMinSecsPerKm: user.paceMinSecsPerKm,
    paceMaxSecsPerKm: user.paceMaxSecsPerKm,
    preferredDistances: user.preferredDistances ?? [],
    runningReasons: user.runningReasons ?? [],
    preferredRunTimes: user.preferredRunTimes ?? [],
  };

  logger.info("Syncing public profile", {userId});
  await Promise.all([
    publicProfileRef.set(publicProfile),
    syncHostedRunClubHostProfile(userId, {
      hostName: displayName,
      hostAvatarUrl: publicAvatarUrl(user),
    }, deps),
    syncAuthoredReviewReviewerProfile(userId, {
      reviewerName: displayName,
    }, deps),
  ]);
}

/**
 * Normalizes stored profile prompts and migrates legacy bios into prompt one.
 * @param {UserProfileDoc} user Private user profile document.
 * @return {ProfilePromptAnswer[]} Public prompt answers.
 */
function normalizeProfilePrompts(
  user: UserProfileDoc
): ProfilePromptAnswer[] {
  const prompts = (user.profilePrompts ?? [])
    .map((prompt) => ({
      promptId: prompt.promptId.trim(),
      prompt: prompt.prompt.trim(),
      answer: collapseStackedPromptBlankLines(prompt.answer).trim(),
    }))
    .filter((prompt) =>
      prompt.promptId.length > 0 &&
      prompt.prompt.length > 0 &&
      prompt.answer.length > 0
    );

  if (prompts.length > 0) return prompts.slice(0, 3);

  const legacyUser = user as UserProfileDoc & {bio?: string};
  const legacyBio = collapseStackedPromptBlankLines(
    legacyUser.bio ?? ""
  ).trim();
  if (legacyBio.length === 0) return [];

  return [{
    ...perfectRunPrompt,
    answer: legacyBio,
  }];
}

/**
 * Normalizes photo captions into public profile prompt records.
 * @param {PhotoPromptAnswer[] | undefined} prompts Stored captions.
 * @return {PhotoPromptAnswer[]} Public photo prompt captions.
 */
function normalizePhotoPrompts(
  prompts: PhotoPromptAnswer[] | undefined
): PhotoPromptAnswer[] {
  return (prompts ?? [])
    .map((prompt) => ({
      photoIndex: prompt.photoIndex,
      promptId: prompt.promptId.trim(),
      prompt: prompt.prompt.trim(),
      caption: collapseStackedPromptBlankLines(prompt.caption).trim(),
    }))
    .filter((prompt) =>
      Number.isInteger(prompt.photoIndex) &&
      prompt.photoIndex >= 0 &&
      prompt.photoIndex < 6 &&
      prompt.promptId.length > 0 &&
      prompt.prompt.length > 0 &&
      prompt.caption.length > 0
    )
    .slice(0, 6);
}

/**
 * Collapses excessive blank lines in prompt text.
 * @param {string} value Raw prompt text.
 * @return {string} Prompt text with at most one empty line in a row.
 */
function collapseStackedPromptBlankLines(value: string): string {
  return value
    .replace(/\r\n/g, "\n")
    .replace(/\r/g, "\n")
    .replace(/\n[ \t]*\n(?:[ \t]*\n)+/g, "\n\n");
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
