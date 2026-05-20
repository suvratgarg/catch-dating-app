import {HttpsError} from "firebase-functions/v2/https";
import {computeAge} from "./dates";
import {Gender, UserProfileDoc} from "./firestore";
import {
  defaultProfilePromptIds,
  profilePhotoPolicy,
} from "./generated/schemaRegistry";
import {
  normalizeProfilePhotos,
  normalizeProfilePrompts,
} from "./profileProjection";

const knownGenders = new Set<Gender>([
  "man",
  "woman",
  "nonBinary",
  "other",
]);

/**
 * Whether a private profile has the minimum identity needed for booking.
 * @param {UserProfileDoc} user Private user profile document.
 * @return {boolean} Whether booking engines can evaluate the profile.
 */
export function isBookingReadyUserProfile(user: UserProfileDoc): boolean {
  return hasBookingReadyName(user) &&
    hasAdultDateOfBirth(user) &&
    typeof user.phoneNumber === "string" &&
    user.phoneNumber.trim().length > 0 &&
    knownGenders.has(user.gender) &&
    Array.isArray(user.interestedInGenders) &&
    user.interestedInGenders.length > 0;
}

/**
 * Throws a client-safe error when booking identity is incomplete.
 * @param {UserProfileDoc} user Private user profile document.
 */
export function assertBookingReadyUserProfile(user: UserProfileDoc): void {
  if (isBookingReadyUserProfile(user)) return;
  throw new HttpsError(
    "failed-precondition",
    "Complete your booking details before signing up."
  );
}

/**
 * Whether a private profile can appear on social/profile-discovery surfaces.
 * @param {UserProfileDoc} user Private user profile document.
 * @return {boolean} Whether the social profile is complete enough.
 */
export function isSocialReadyUserProfile(user: UserProfileDoc): boolean {
  if (!user.profileComplete || !isBookingReadyUserProfile(user)) return false;
  if (normalizeProfilePhotos(user).length < profilePhotoPolicy.minPhotos) {
    return false;
  }

  const answeredPromptIds = new Set(
    normalizeProfilePrompts(user).map((prompt) => prompt.promptId)
  );
  return defaultProfilePromptIds.every((promptId) =>
    answeredPromptIds.has(promptId)
  );
}

/**
 * Checks whether the date of birth is present and belongs to an adult user.
 * @param {UserProfileDoc} user Private user profile document.
 * @return {boolean} Whether dateOfBirth is usable for booking decisions.
 */
function hasAdultDateOfBirth(user: UserProfileDoc): boolean {
  const dateOfBirth = user.dateOfBirth as
    | FirebaseFirestore.Timestamp
    | undefined;
  if (typeof dateOfBirth?.toDate !== "function") return false;
  return computeAge(dateOfBirth.toDate()) >= 18;
}

/**
 * Checks real stored name fields without using display fallbacks.
 * @param {UserProfileDoc} user Private user profile document.
 * @return {boolean} Whether a user-entered name is present.
 */
function hasBookingReadyName(user: UserProfileDoc): boolean {
  return hasText(user.name) ||
    hasText(user.firstName) ||
    hasText(user.displayName);
}

/**
 * @param {unknown} value Candidate text value.
 * @return {boolean} Whether it is a non-empty trimmed string.
 */
function hasText(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}
