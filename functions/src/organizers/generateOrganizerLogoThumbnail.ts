import {onObjectFinalized} from "firebase-functions/v2/storage";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import sharp from "sharp";
import {randomUUID} from "crypto";
import {profilePhotoPolicy} from "../shared/generated/schemaRegistry";

const THUMBNAIL_SIZE = profilePhotoPolicy.thumbnailSize;
const JPEG_QUALITY = 72;

interface OrganizerLogoPath {
  organizerId: string;
  fileName: string;
}

/**
 * Generates an avatar-scale thumbnail whenever an organizer logo is uploaded.
 */
export const generateOrganizerLogoThumbnail = onObjectFinalized(
  async (event) => {
    const filePath = event.data.name;
    if (!filePath) return;

    const parsed = parseOrganizerLogoPath(filePath);
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
          },
        },
      });

      const url = downloadUrl(bucket.name, thumbnailPath, token);
      await updateOrganizerLogoThumbnail({
        organizerId: parsed.organizerId,
        sourcePath: filePath,
        thumbnailPath,
        thumbnailUrl: url,
      });
    } catch (error) {
      logger.error(
        `[organizers] failed to generate logo thumbnail for ${filePath}`,
        error
      );
    }
  }
);

/**
 * Parses an organizer-logo Storage path.
 * @param {string} filePath The Storage object path.
 * @return {OrganizerLogoPath|null} Parsed organizer logo details, or null.
 */
function parseOrganizerLogoPath(filePath: string): OrganizerLogoPath | null {
  const parts = filePath.split("/");
  if (
    parts.length !== 4 ||
    parts[0] !== "organizers" ||
    parts[2] !== "logo"
  ) {
    return null;
  }
  return {organizerId: parts[1], fileName: parts[3]};
}

/**
 * Builds the thumbnail Storage path for an organizer logo.
 * @param {OrganizerLogoPath} photo Parsed organizer logo details.
 * @return {string} The generated thumbnail object path.
 */
function thumbnailPathFor(photo: OrganizerLogoPath): string {
  const sourceName = photo.fileName.replace(/\.[^.]+$/, "");
  return `organizers/${photo.organizerId}/logoThumbnails/${sourceName}.jpg`;
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
 * Writes the logo thumbnail URL into the matching organizer document.
 * @param {object} input Thumbnail update input.
 * @param {string} input.organizerId Organizer id.
 * @param {string} input.sourcePath Source logo Storage path.
 * @param {string} input.thumbnailPath Generated thumbnail Storage path.
 * @param {string} input.thumbnailUrl Generated thumbnail download URL.
 */
async function updateOrganizerLogoThumbnail({
  organizerId,
  sourcePath,
  thumbnailPath,
  thumbnailUrl,
}: {
  organizerId: string;
  sourcePath: string;
  thumbnailPath: string;
  thumbnailUrl: string;
}) {
  const organizerRef = admin.firestore()
    .collection("organizers").doc(organizerId);
  const legacyClubRef = admin.firestore().collection("clubs").doc(organizerId);
  await admin.firestore().runTransaction(async (tx) => {
    const snap = await tx.get(organizerRef);
    if (!snap.exists) return;
    const data = snap.data() ?? {};
    const logoPhoto = data.logoPhoto;
    if (!isRecord(logoPhoto)) {
      tx.update(organizerRef, {profileImageUrl: thumbnailUrl});
      tx.set(legacyClubRef, {profileImageUrl: thumbnailUrl}, {merge: true});
      return;
    }
    const storagePath = typeof logoPhoto.storagePath === "string" ?
      logoPhoto.storagePath :
      undefined;
    const url = typeof logoPhoto.url === "string" ? logoPhoto.url : undefined;
    const isMatch = storagePath === sourcePath ||
      downloadUrlContainsPath(url, sourcePath);
    if (!isMatch) return;
    const patch = {
      logoPhoto: {
        ...logoPhoto,
        thumbnailUrl,
        thumbnailStoragePath: thumbnailPath,
        updatedAt: admin.firestore.Timestamp.now(),
      },
      profileImageUrl: thumbnailUrl,
    };
    tx.update(organizerRef, patch);
    tx.set(legacyClubRef, patch, {merge: true});
  });
}

/**
 * Checks whether a token download URL points at the expected source path.
 * @param {string | undefined} url Candidate download URL.
 * @param {string} filePath Source Storage object path.
 * @return {boolean} True when the URL contains the raw or encoded path.
 */
function downloadUrlContainsPath(url: string | undefined, filePath: string) {
  if (!url) return false;
  const encodedPath = encodeURIComponent(filePath);
  return url.includes(encodedPath) || url.includes(filePath);
}

/**
 * Checks whether a value is a non-array object record.
 * @param {unknown} value Candidate value.
 * @return {boolean} True when the value can be read as an object record.
 */
function isRecord(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
