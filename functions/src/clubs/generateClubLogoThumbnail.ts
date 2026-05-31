import {onObjectFinalized} from "firebase-functions/v2/storage";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import sharp from "sharp";
import {randomUUID} from "crypto";
import {profilePhotoPolicy} from "../shared/generated/schemaRegistry";

const THUMBNAIL_SIZE = profilePhotoPolicy.thumbnailSize;
const JPEG_QUALITY = 72;

interface ClubLogoPath {
  clubId: string;
  fileName: string;
}

/**
 * Generates an avatar-scale thumbnail whenever a club logo is uploaded.
 */
export const generateClubLogoThumbnail = onObjectFinalized(
  async (event) => {
    const filePath = event.data.name;
    if (!filePath) return;

    const parsed = parseClubLogoPath(filePath);
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
      await updateClubLogoThumbnail({
        clubId: parsed.clubId,
        sourcePath: filePath,
        thumbnailPath,
        thumbnailUrl: url,
      });
    } catch (error) {
      logger.error(
        `[clubs] failed to generate logo thumbnail for ${filePath}`,
        error
      );
    }
  }
);

/**
 * Parses a club-logo Storage path.
 * @param {string} filePath The Storage object path.
 * @return {ClubLogoPath|null} Parsed club logo details, or null.
 */
function parseClubLogoPath(filePath: string): ClubLogoPath | null {
  const parts = filePath.split("/");
  if (
    parts.length !== 4 ||
    parts[0] !== "clubs" ||
    parts[2] !== "logo"
  ) {
    return null;
  }
  return {clubId: parts[1], fileName: parts[3]};
}

/**
 * Builds the thumbnail Storage path for a club logo.
 * @param {ClubLogoPath} photo Parsed club logo details.
 * @return {string} The generated thumbnail object path.
 */
function thumbnailPathFor(photo: ClubLogoPath): string {
  const sourceName = photo.fileName.replace(/\.[^.]+$/, "");
  return `clubs/${photo.clubId}/logoThumbnails/${sourceName}.jpg`;
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
 * Writes the logo thumbnail URL into the matching clubs/{clubId} document.
 * @param {object} input Thumbnail update input.
 * @param {string} input.clubId Club id.
 * @param {string} input.sourcePath Source logo Storage path.
 * @param {string} input.thumbnailPath Generated thumbnail Storage path.
 * @param {string} input.thumbnailUrl Generated thumbnail download URL.
 */
async function updateClubLogoThumbnail({
  clubId,
  sourcePath,
  thumbnailPath,
  thumbnailUrl,
}: {
  clubId: string;
  sourcePath: string;
  thumbnailPath: string;
  thumbnailUrl: string;
}) {
  const clubRef = admin.firestore().collection("clubs").doc(clubId);
  await admin.firestore().runTransaction(async (tx) => {
    const snap = await tx.get(clubRef);
    if (!snap.exists) return;
    const data = snap.data() ?? {};
    const logoPhoto = data.logoPhoto;
    if (!isRecord(logoPhoto)) {
      tx.update(clubRef, {profileImageUrl: thumbnailUrl});
      return;
    }
    const storagePath = typeof logoPhoto.storagePath === "string" ?
      logoPhoto.storagePath :
      undefined;
    const url = typeof logoPhoto.url === "string" ? logoPhoto.url : undefined;
    const isMatch = storagePath === sourcePath ||
      downloadUrlContainsPath(url, sourcePath);
    if (!isMatch) return;
    tx.update(clubRef, {
      logoPhoto: {
        ...logoPhoto,
        thumbnailUrl,
        thumbnailStoragePath: thumbnailPath,
        updatedAt: admin.firestore.Timestamp.now(),
      },
      profileImageUrl: thumbnailUrl,
    });
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
