import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {UserProfileDoc, PublicProfileDoc} from "../shared/firestore";
import {computeAge} from "../shared/dates";

export const syncPublicProfile = onDocumentWritten(
  "users/{userId}",
  async (event) => {
    const {userId} = event.params;
    const publicProfileRef = admin
      .firestore()
      .collection("publicProfiles")
      .doc(userId);

    // User deleted — remove public profile too
    if (!event.data?.after.exists) {
      logger.info("Deleting public profile", {userId});
      await publicProfileRef.delete();
      return;
    }

    const user = event.data.after.data() as UserProfileDoc | undefined;
    if (!user) return;

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

    const publicProfile: PublicProfileDoc = {
      name: publicDisplayName(user),
      age,
      bio: user.bio,
      gender: user.gender,
      photoUrls: user.photoUrls ?? [],
      photoThumbnailUrls: user.photoThumbnailUrls ?? [],
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
    };

    logger.info("Syncing public profile", {userId});
    await publicProfileRef.set(publicProfile);
  }
);

/**
 * Returns the public-safe display name for discovery surfaces.
 * @param {UserProfileDoc} user Private user profile document.
 * @return {string} Editable public display name, with first-name fallback.
 */
function publicDisplayName(user: UserProfileDoc): string {
  const displayName = user.displayName?.trim();
  if (displayName) return displayName;

  const firstName = user.firstName?.trim();
  if (firstName) return firstName;

  const legacyName = user.name?.trim();
  if (!legacyName) return "Runner";
  return legacyName.split(/\s+/)[0];
}
