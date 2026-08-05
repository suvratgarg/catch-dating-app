import {UserProfileDocument} from "./generated/firestoreAdminTypes";

/**
 * Returns whether two complete profiles satisfy each other's gender and age
 * preferences. This is the canonical server predicate for both post-event
 * Catch and pre-event Cross Paths; callers still own their lifecycle rules.
 */
export function isReciprocallyEligible(params: {
  viewer: UserProfileDocument;
  candidate: UserProfileDocument;
  nowMillis: number;
}): boolean {
  const {viewer, candidate, nowMillis} = params;
  if (
    !viewer.interestedInGenders.includes(candidate.gender) ||
    !candidate.interestedInGenders.includes(viewer.gender)
  ) {
    return false;
  }
  const viewerAge = ageAt(viewer.dateOfBirth, nowMillis);
  const candidateAge = ageAt(candidate.dateOfBirth, nowMillis);
  const viewerRange = normalizedAgeRange(viewer);
  const candidateRange = normalizedAgeRange(candidate);
  return candidateAge >= viewerRange.min &&
    candidateAge <= viewerRange.max &&
    viewerAge >= candidateRange.min &&
    viewerAge <= candidateRange.max;
}

export function ageAt(
  dateOfBirth: FirebaseFirestore.Timestamp,
  nowMillis: number
): number {
  const birth = new Date(dateOfBirth.toMillis());
  const now = new Date(nowMillis);
  let age = now.getUTCFullYear() - birth.getUTCFullYear();
  const birthdayPending = now.getUTCMonth() < birth.getUTCMonth() ||
    (
      now.getUTCMonth() === birth.getUTCMonth() &&
      now.getUTCDate() < birth.getUTCDate()
    );
  if (birthdayPending) age -= 1;
  return age;
}

function normalizedAgeRange(profile: UserProfileDocument): {
  min: number;
  max: number;
} {
  const lower = Math.min(profile.minAgePreference, profile.maxAgePreference);
  const upper = Math.max(profile.minAgePreference, profile.maxAgePreference);
  const min = Math.max(18, Math.min(99, lower));
  const max = Math.max(min, Math.min(99, upper));
  return {min, max};
}
