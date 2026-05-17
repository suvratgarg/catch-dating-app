import {computeAge} from "./dates";
import * as admin from "firebase-admin";
import {
  PhotoPromptAnswer,
  ProfilePromptAnswer,
  PublicProfileDoc,
  UserProfileDoc,
} from "./firestore";
import {DemoMetadata, demoMetadataFromSources} from "./demoMetadata";
import {
  profilePhotoPolicy,
  profilePromptCatalog,
} from "./generated/schemaRegistry";

export type PublicProfileProjection = PublicProfileDoc & DemoMetadata;

interface StoredProfilePhoto {
  id: string;
  url: string;
  thumbnailUrl: string;
  storagePath: string;
  thumbnailStoragePath: string;
  prompt?: PhotoPromptAnswer | null;
  moderation?: {
    status: "pending" | "approved" | "rejected";
    reason?: string | null;
    reviewedAt?: FirebaseFirestore.Timestamp | null;
  } | null;
  position: number;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

type UserProfileWithPhotos = UserProfileDoc & {
  profilePhotos?: StoredProfilePhoto[];
};

const perfectRunPromptDefinition = profilePromptCatalog.prompts.find(
  (prompt) => prompt.id === profilePromptCatalog.defaultPromptIds[0]
) ?? profilePromptCatalog.prompts[0];
const maxProfilePhotos = profilePhotoPolicy.maxPhotos;

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
  const primaryPhoto = normalizeProfilePhotos(user)[0];
  return primaryPhoto?.thumbnailUrl ??
    primaryPhoto?.url ??
    normalizePhotoUrls(user.photoThumbnailUrls)[0] ??
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
  const profilePhotos = normalizeProfilePhotos(user);
  return {
    ...demoMetadataFromSources(user),
    name: publicDisplayName(user),
    age: computeAge(user.dateOfBirth.toDate()),
    profilePrompts: normalizeProfilePrompts(user),
    gender: user.gender,
    photoUrls: profilePhotos.length > 0 ?
      profilePhotos.map((photo) => photo.url) :
      normalizePhotoUrls(user.photoUrls),
    photoThumbnailUrls: profilePhotos.length > 0 ?
      profilePhotos.map((photo) => photo.thumbnailUrl) :
      normalizePhotoUrls(user.photoThumbnailUrls),
    photoPrompts: profilePhotos.length > 0 ?
      profilePhotos
        .map((photo) => photo.prompt ?
          {...photo.prompt, photoIndex: photo.position} :
          null)
        .filter((prompt): prompt is PhotoPromptAnswer => prompt !== null) :
      normalizePhotoPrompts(user.photoPrompts),
    ...(profilePhotos.length > 0 && {profilePhotos}),
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
      prompt.photoIndex < maxProfilePhotos &&
      prompt.promptId.length > 0 &&
      prompt.prompt.length > 0 &&
      prompt.caption.length > 0
    )
    .slice(0, maxProfilePhotos);
}

/**
 * Normalizes grouped profile photos, falling back to legacy parallel arrays
 * until all live profile documents have been backfilled.
 * @param {UserProfileDoc} user Private user profile document.
 * @return {StoredProfilePhoto[]} Ordered profile photos.
 */
export function normalizeProfilePhotos(
  user: UserProfileDoc
): StoredProfilePhoto[] {
  const userWithPhotos = user as UserProfileWithPhotos;
  const groupedPhotos = (userWithPhotos.profilePhotos ?? [])
    .filter(isStoredProfilePhoto)
    .map((photo) => ({
      ...photo,
      id: photo.id.trim(),
      url: photo.url.trim(),
      thumbnailUrl: photo.thumbnailUrl.trim() || photo.url.trim(),
      storagePath: photo.storagePath.trim(),
      thumbnailStoragePath: photo.thumbnailStoragePath.trim(),
      prompt: normalizeProfilePhotoPrompt(photo.prompt, photo.position),
      position: photo.position,
    }))
    .filter((photo) =>
      photo.id.length > 0 &&
      isPublicPhotoUri(photo.url) &&
      isPublicPhotoUri(photo.thumbnailUrl) &&
      photo.storagePath.length > 0 &&
      photo.thumbnailStoragePath.length > 0 &&
      Number.isInteger(photo.position) &&
      photo.position >= 0 &&
      photo.position < maxProfilePhotos
    )
    .sort((a, b) => a.position - b.position)
    .slice(0, maxProfilePhotos);
  if (groupedPhotos.length > 0) return groupedPhotos;

  const promptsByIndex = new Map(
    normalizePhotoPrompts(user.photoPrompts).map((prompt) => [
      prompt.photoIndex,
      prompt,
    ])
  );
  return normalizePhotoUrls(user.photoUrls)
    .map((url, index) => {
      const thumbnailUrl = normalizePhotoUrls(user.photoThumbnailUrls)[index] ??
        url;
      const storagePath = storagePathFromDownloadUrl(url) ??
        `users/legacy/photos/${index}.jpg`;
      return {
        id: profilePhotoIdForStoragePath(storagePath, index),
        url,
        thumbnailUrl,
        storagePath,
        thumbnailStoragePath: storagePathFromDownloadUrl(thumbnailUrl) ??
          thumbnailStoragePathForStoragePath(storagePath),
        prompt: promptsByIndex.get(index) ?? null,
        moderation: null,
        position: index,
        createdAt: admin.firestore.Timestamp.fromMillis(0),
        updatedAt: admin.firestore.Timestamp.fromMillis(0),
      };
    });
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
    .slice(0, maxProfilePhotos);
}

/**
 * Checks whether an unknown value has the minimum shape of a stored
 * ProfilePhoto object.
 * @param {unknown} value Candidate value.
 * @return {boolean} True when the value is a stored profile photo.
 */
function isStoredProfilePhoto(value: unknown): value is StoredProfilePhoto {
  if (value === null || typeof value !== "object") return false;
  const photo = value as Partial<StoredProfilePhoto>;
  return typeof photo.id === "string" &&
    typeof photo.url === "string" &&
    typeof photo.thumbnailUrl === "string" &&
    typeof photo.storagePath === "string" &&
    typeof photo.thumbnailStoragePath === "string" &&
    Number.isInteger(photo.position) &&
    isTimestampLike(photo.createdAt) &&
    isTimestampLike(photo.updatedAt);
}

/**
 * Normalizes a grouped photo prompt/caption.
 * @param {PhotoPromptAnswer | null | undefined} prompt Stored prompt.
 * @param {number} position Photo position.
 * @return {PhotoPromptAnswer | null} Normalized prompt or null.
 */
function normalizeProfilePhotoPrompt(
  prompt: PhotoPromptAnswer | null | undefined,
  position: number
): PhotoPromptAnswer | null {
  if (!prompt) return null;
  const normalized = normalizePhotoPrompts([
    {...prompt, photoIndex: position},
  ]);
  return normalized[0] ?? null;
}

/**
 * Best-effort Firebase download URL to Storage object path parser.
 * @param {string} value Download URL.
 * @return {string | null} Storage object path if the URL contains one.
 */
function storagePathFromDownloadUrl(value: string): string | null {
  try {
    const url = new URL(value);
    const segments = url.pathname.split("/").filter(Boolean);
    const objectMarkerIndex = segments.indexOf("o");
    if (objectMarkerIndex < 0 || objectMarkerIndex + 1 >= segments.length) {
      return null;
    }
    return decodeURIComponent(segments[objectMarkerIndex + 1]);
  } catch {
    return null;
  }
}

/**
 * Derives the profile thumbnail path that generateProfilePhotoThumbnail writes.
 * @param {string} storagePath Full-size photo Storage path.
 * @return {string} Thumbnail Storage path.
 */
function thumbnailStoragePathForStoragePath(storagePath: string): string {
  const parts = storagePath.split("/");
  if (parts.length >= 4 && parts[0] === "users" && parts[2] === "photos") {
    const sourceName = stripExtension(parts[parts.length - 1]);
    return `users/${parts[1]}/photoThumbnails/${sourceName}.jpg`;
  }
  return `${storagePath}.thumbnail.jpg`;
}

/**
 * Builds a stable id from a Storage object path.
 * @param {string} storagePath Storage object path.
 * @param {number} position Fallback photo position.
 * @return {string} Contract-safe id.
 */
function profilePhotoIdForStoragePath(
  storagePath: string,
  position: number
): string {
  const fileName = stripExtension(storagePath.split("/").pop() ?? "");
  const normalized = fileName
    .replace(/[^A-Za-z0-9_-]+/g, "_")
    .replace(/_+/g, "_")
    .replace(/^_|_$/g, "");
  return normalized || `photo_${position}`;
}

/**
 * Removes the final file extension.
 * @param {string} fileName File name.
 * @return {string} File name without extension.
 */
function stripExtension(fileName: string): string {
  const dot = fileName.lastIndexOf(".");
  return dot <= 0 ? fileName : fileName.slice(0, dot);
}

/**
 * Checks for Firestore Timestamp-like values.
 * @param {unknown} value Candidate timestamp.
 * @return {boolean} True when a toDate method exists.
 */
function isTimestampLike(
  value: unknown
): value is FirebaseFirestore.Timestamp {
  return value !== null &&
    typeof value === "object" &&
    typeof (value as {toDate?: unknown}).toDate === "function";
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
