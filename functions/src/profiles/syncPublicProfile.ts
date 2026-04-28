import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {UserProfileDoc, PublicProfileDoc} from "../shared/firestore";

/**
 * Computes a user's age in full years from their birth date.
 * @param {FirebaseFirestore.Timestamp} dateOfBirth Firestore birth date.
 * @return {number} User age in whole years.
 */
function computeAge(dateOfBirth: FirebaseFirestore.Timestamp): number {
  const dob = dateOfBirth.toDate();
  const today = new Date();
  let age = today.getFullYear() - dob.getFullYear();
  const hasHadBirthdayThisYear =
    today.getMonth() > dob.getMonth() ||
    (today.getMonth() === dob.getMonth() && today.getDate() >= dob.getDate());
  if (!hasHadBirthdayThisYear) age--;
  return age;
}

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

    const publicProfile: PublicProfileDoc = {
      name: user.name,
      age: computeAge(user.dateOfBirth),
      bio: user.bio,
      gender: user.gender,
      photoUrls: user.photoUrls ?? [],
      // Optional fields — omit undefined values so Firestore doesn't store them
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
    };

    logger.info("Syncing public profile", {userId});
    await publicProfileRef.set(publicProfile);
  }
);
