import {computeAge} from "./dates";
import {
  PhotoPromptAnswer,
  ProfilePromptAnswer,
  PublicProfileDoc,
  UserProfileDoc,
} from "./firestore";
import {DemoMetadata, demoMetadataFromSources} from "./demoMetadata";
import {profilePromptCatalog} from "./generated/schemaRegistry";

export type PublicProfileProjection = PublicProfileDoc & DemoMetadata;

const perfectRunPromptDefinition = profilePromptCatalog.prompts.find(
  (prompt) => prompt.id === profilePromptCatalog.defaultPromptIds[0]
) ?? profilePromptCatalog.prompts[0];

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
  return normalizePhotoUrls(user.photoThumbnailUrls)[0] ??
    normalizePhotoUrls(user.photoUrls)[0] ??
    null;
}

/**
 * Projects a private users/{uid} profile into the publicProfiles/{uid} shape.
 *
 * This function is intentionally pure so Functions triggers, tests, and seed
 * tooling can verify the same public-profile contract without duplicating
 * display-name, prompt, photo, running, and demo-metadata decisions.
 * @param {UserProfileDoc} user Private profile document.
 * @return {PublicProfileProjection} Public profile projection.
 */
export function publicProfileFromUserProfileDoc(
  user: UserProfileDoc
): PublicProfileProjection {
  return {
    ...demoMetadataFromSources(user),
    name: publicDisplayName(user),
    age: computeAge(user.dateOfBirth.toDate()),
    profilePrompts: normalizeProfilePrompts(user),
    gender: user.gender,
    photoUrls: normalizePhotoUrls(user.photoUrls),
    photoThumbnailUrls: normalizePhotoUrls(user.photoThumbnailUrls),
    photoPrompts: normalizePhotoPrompts(user.photoPrompts),
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
}

/**
 * Normalizes stored profile prompts and migrates legacy bios into prompt one.
 * @param {UserProfileDoc} user Private user profile document.
 * @return {ProfilePromptAnswer[]} Public prompt answers.
 */
export function normalizeProfilePrompts(
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
    promptId: perfectRunPromptDefinition.id,
    prompt: perfectRunPromptDefinition.title,
    answer: legacyBio,
  }];
}

/**
 * Normalizes photo captions into public profile prompt records.
 * @param {PhotoPromptAnswer[] | undefined} prompts Stored captions.
 * @return {PhotoPromptAnswer[]} Public photo prompt captions.
 */
export function normalizePhotoPrompts(
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
 * Normalizes user-supplied photo URL arrays into public-safe URI strings.
 * @param {string[] | undefined} urls Stored full-size or thumbnail URLs.
 * @return {string[]} Trimmed valid URI strings.
 */
export function normalizePhotoUrls(urls: string[] | undefined): string[] {
  return (urls ?? [])
    .map((url) => url.trim())
    .filter((url) => isPublicPhotoUri(url))
    .slice(0, 12);
}

/**
 * Collapses excessive blank lines in prompt text.
 * @param {string} value Raw prompt text.
 * @return {string} Prompt text with at most one empty line in a row.
 */
export function collapseStackedPromptBlankLines(value: string): string {
  return value
    .replace(/\r\n/g, "\n")
    .replace(/\r/g, "\n")
    .replace(/\n[ \t]*\n(?:[ \t]*\n)+/g, "\n\n");
}

/**
 * Checks whether a string can safely be published as a profile photo URI.
 * @param {string} value Candidate URL or URI string.
 * @return {boolean} True when the value is a bounded absolute URI.
 */
function isPublicPhotoUri(value: string): boolean {
  if (value.length === 0 || value.length > 2048) return false;
  try {
    new URL(value);
    return true;
  } catch {
    return false;
  }
}
