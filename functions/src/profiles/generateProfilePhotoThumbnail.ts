import {onObjectFinalized} from "firebase-functions/v2/storage";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import sharp from "sharp";
import {randomUUID} from "crypto";
import {profilePhotoPolicy} from "../shared/generated/schemaRegistry";

const THUMBNAIL_SIZE = profilePhotoPolicy.thumbnailSize;
const JPEG_QUALITY = 72;

interface ProfilePhotoPath {
  uid: string;
  index: number;
  fileName: string;
}

/**
 * Generates a tiny public-profile thumbnail whenever a user profile photo is
 * uploaded. Avatar-scale UI should consume `profilePhotos.thumbnailUrl`
 * instead of downloading full profile images.
 */
export const generateProfilePhotoThumbnail = onObjectFinalized(
  async (event) => {
    const filePath = event.data.name;
    if (!filePath) return;

    const parsed = parseProfilePhotoPath(filePath);
    if (!parsed) return;

    const bucket = admin.storage().bucket(event.data.bucket);
    const file = bucket.file(filePath);
    const [exists] = await file.exists();
    if (!exists) return;

    try {
      const [sourceBuffer] = await file.download();
      const thumbnailBuffer = await sharp(sourceBuffer)
        .rotate()
        .resize(THUMBNAIL_SIZE, THUMBNAIL_SIZE, {
          fit: "cover",
          position: "attention",
        })
        .jpeg({quality: JPEG_QUALITY, mozjpeg: true})
        .toBuffer();

      const thumbnailPath = thumbnailPathFor(parsed);
      const token = randomUUID();
      await bucket.file(thumbnailPath).save(thumbnailBuffer, {
        resumable: false,
        contentType: "image/jpeg",
        metadata: {
          metadata: {
            firebaseStorageDownloadTokens: token,
            sourceObject: filePath,
            profilePhotoIndex: String(parsed.index),
          },
        },
      });

      const url = downloadUrl(bucket.name, thumbnailPath, token);
      await updateProfileThumbnailUrl({
        uid: parsed.uid,
        sourcePath: filePath,
        thumbnailPath,
        thumbnailUrl: url,
      });
    } catch (error) {
      logger.error(
        `[profiles] failed to generate thumbnail for ${filePath}`,
        error
      );
    }
  }
);

/**
 * Parses a profile-photo Storage path.
 * @param {string} filePath The Storage object path.
 * @return {ProfilePhotoPath|null} Parsed profile photo details, or null.
 */
function parseProfilePhotoPath(filePath: string): ProfilePhotoPath | null {
  const parts = filePath.split("/");
  if (
    parts.length !== 4 ||
    parts[0] !== "users" ||
    parts[2] !== "photos"
  ) {
    return null;
  }

  const fileName = parts[3];
  const index = Number.parseInt(fileName.split("_")[0], 10);
  if (!Number.isInteger(index) || index < 0) return null;

  return {uid: parts[1], index, fileName};
}

/**
 * Builds the thumbnail Storage path for a profile photo.
 * @param {ProfilePhotoPath} photo Parsed profile photo details.
 * @return {string} The generated thumbnail object path.
 */
function thumbnailPathFor(photo: ProfilePhotoPath): string {
  const sourceName = photo.fileName.replace(/\.[^.]+$/, "");
  return `users/${photo.uid}/photoThumbnails/${sourceName}.jpg`;
}

/**
 * Builds a Firebase Storage token download URL.
 * @param {string} bucketName The Storage bucket name.
 * @param {string} filePath The object path.
 * @param {string} token The download token stored in object metadata.
 * @return {string} The public token URL.
 */
function downloadUrl(bucketName: string, filePath: string, token: string) {
  return `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/` +
    `${encodeURIComponent(filePath)}?alt=media&token=${token}`;
}

/**
 * Writes the thumbnail URL into the matching users/{uid} photo slot.
 * @param {object} input Thumbnail update input.
 * @param {string} input.uid User id.
 * @param {string} input.sourcePath Source profile photo Storage path.
 * @param {string} input.thumbnailPath Generated thumbnail Storage path.
 * @param {string} input.thumbnailUrl Generated thumbnail download URL.
 */
async function updateProfileThumbnailUrl({
  uid,
  sourcePath,
  thumbnailPath,
  thumbnailUrl,
}: {
  uid: string;
  sourcePath: string;
  thumbnailPath: string;
  thumbnailUrl: string;
}) {
  const userRef = admin.firestore().collection("users").doc(uid);
  await admin.firestore().runTransaction(async (tx) => {
    const snap = await tx.get(userRef);
    if (!snap.exists) return;

    const data = snap.data() ?? {};
    const groupedUpdate = updateGroupedProfilePhotoThumbnail({
      profilePhotos: data.profilePhotos,
      sourcePath,
      thumbnailPath,
      thumbnailUrl,
    });
    if (groupedUpdate) {
      tx.update(userRef, {
        profilePhotos: groupedUpdate.profilePhotos,
      });
    }
  });
}

/**
 * Updates the grouped ProfilePhoto object that corresponds to the generated
 * thumbnail while leaving malformed legacy values untouched.
 * @param {object} input Update input.
 * @param {unknown} input.profilePhotos Stored profilePhotos value.
 * @param {string} input.sourcePath Full-size Storage object path.
 * @param {string} input.thumbnailPath Thumbnail Storage object path.
 * @param {string} input.thumbnailUrl Thumbnail download URL.
 * @return {{profilePhotos: unknown[], position: number} | null} Updated
 * grouped photos, or null when absent.
 */
function updateGroupedProfilePhotoThumbnail({
  profilePhotos,
  sourcePath,
  thumbnailPath,
  thumbnailUrl,
}: {
  profilePhotos: unknown;
  sourcePath: string;
  thumbnailPath: string;
  thumbnailUrl: string;
}): {profilePhotos: unknown[]; position: number} | null {
  if (!Array.isArray(profilePhotos)) return null;
  let updatedPosition: number | null = null;
  const updated = profilePhotos.map((photo) => {
    if (!isRecord(photo)) return photo;
    const position = photo.position;
    const url = typeof photo.url === "string" ? photo.url : undefined;
    const storagePath = typeof photo.storagePath === "string" ?
      photo.storagePath :
      undefined;
    const isMatch = storagePath === sourcePath ||
      downloadUrlContainsPath(url, sourcePath);
    if (!isMatch) return photo;
    updatedPosition = typeof position === "number" ? position : 0;
    return {
      ...photo,
      thumbnailUrl,
      thumbnailStoragePath: thumbnailPath,
      updatedAt: admin.firestore.Timestamp.now(),
    };
  });
  return updatedPosition === null ? null : {
    profilePhotos: updated,
    position: updatedPosition,
  };
}

/**
 * Checks for a plain object record.
 * @param {unknown} value Candidate value.
 * @return {boolean} True for non-array object records.
 */
function isRecord(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

/**
 * Checks whether a Firebase download URL references a Storage object path.
 * @param {string|undefined} url The stored download URL.
 * @param {string} filePath The Storage object path.
 * @return {boolean} True when the URL points at that object.
 */
function downloadUrlContainsPath(url: string | undefined, filePath: string) {
  if (!url) return false;
  const encodedPath = encodeURIComponent(filePath);
  return url.includes(encodedPath) || url.includes(filePath);
}
