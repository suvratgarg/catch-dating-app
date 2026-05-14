import {UserProfileDoc} from "./firestore";

/**
 * Returns the public-safe display name for denormalized app surfaces.
 * @param {UserProfileDoc} user Private user profile document.
 * @return {string} Editable public display name, with first-name fallback.
 */
export function publicDisplayName(user: UserProfileDoc): string {
  const displayName = user.displayName?.trim();
  if (displayName) return displayName;

  const firstName = user.firstName?.trim();
  if (firstName) return firstName;

  const legacyName = user.name?.trim();
  if (!legacyName) return "Runner";
  return legacyName.split(/\s+/)[0];
}

/**
 * Returns the best public avatar URL for denormalized host/profile surfaces.
 * @param {UserProfileDoc} user Private user profile document.
 * @return {string | null} Thumbnail-first avatar URL.
 */
export function publicAvatarUrl(user: UserProfileDoc): string | null {
  return user.photoThumbnailUrls?.[0] ?? user.photoUrls?.[0] ?? null;
}
