#!/usr/bin/env node

const admin = require("firebase-admin");
const sharp = require("sharp");
const {randomUUID} = require("crypto");

const THUMBNAIL_SIZE = 160;
const JPEG_QUALITY = 72;

const args = new Set(process.argv.slice(2));
const apply = args.has("--apply");

if (!process.env.FIREBASE_STORAGE_BUCKET) {
  console.error(
    "Set FIREBASE_STORAGE_BUCKET before running this script. " +
      "Example: FIREBASE_STORAGE_BUCKET=<bucket> " +
      "node scripts/backfill-profile-thumbnails.cjs --apply"
  );
  process.exit(1);
}

admin.initializeApp({storageBucket: process.env.FIREBASE_STORAGE_BUCKET});

async function main() {
  const db = admin.firestore();
  const bucket = admin.storage().bucket();
  const usersSnap = await db.collection("users").get();
  let scanned = 0;
  let missing = 0;
  let written = 0;
  let skipped = 0;

  for (const userDoc of usersSnap.docs) {
    scanned += 1;
    const data = userDoc.data();
    const entries = profilePhotoEntries(data);
    if (entries.length === 0) continue;

    const thumbnailUrls = asStringArray(data.photoThumbnailUrls);
    const updatedThumbnailUrls = [...thumbnailUrls];
    const updatedProfilePhotos = Array.isArray(data.profilePhotos) ?
      data.profilePhotos.map((photo) => isRecord(photo) ? {...photo} : photo) :
      null;
    let changed = false;

    for (const entry of entries) {
      if (entry.thumbnailUrl) continue;
      missing += 1;
      const sourcePath = entry.storagePath ??
        storagePathFromDownloadUrl(entry.url);
      if (!sourcePath) {
        skipped += 1;
        console.warn(
          `[skip] ${userDoc.id} photo ${entry.position}: unsupported URL`
        );
        continue;
      }

      const sourceFile = bucket.file(sourcePath);
      const [exists] = await sourceFile.exists();
      if (!exists) {
        skipped += 1;
        console.warn(
          `[skip] ${userDoc.id} photo ${entry.position}: source missing`
        );
        continue;
      }

      const thumbnailPath = entry.thumbnailStoragePath ??
        thumbnailPathFor(userDoc.id, entry.position, sourcePath);
      if (!apply) {
        console.log(
          `[dry-run] ${userDoc.id} ${sourcePath} -> ${thumbnailPath}`
        );
        continue;
      }

      try {
        const [sourceBuffer] = await sourceFile.download();
        if (sourceBuffer.length === 0) {
          skipped += 1;
          console.warn(
            `[skip] ${userDoc.id} photo ${entry.position}: empty source`
          );
          continue;
        }

        const thumbnailBuffer = await sharp(sourceBuffer)
          .rotate()
          .resize(THUMBNAIL_SIZE, THUMBNAIL_SIZE, {
            fit: "cover",
            position: "attention",
          })
          .jpeg({quality: JPEG_QUALITY, mozjpeg: true})
          .toBuffer();
        const token = randomUUID();
        await bucket.file(thumbnailPath).save(thumbnailBuffer, {
          resumable: false,
          contentType: "image/jpeg",
          metadata: {
            metadata: {
              firebaseStorageDownloadTokens: token,
              sourceObject: sourcePath,
              profilePhotoIndex: String(entry.position),
            },
          },
        });
        const thumbnailUrl = downloadUrl(bucket.name, thumbnailPath, token);
        while (updatedThumbnailUrls.length <= entry.position) {
          updatedThumbnailUrls.push("");
        }
        updatedThumbnailUrls[entry.position] = thumbnailUrl;
        if (
          updatedProfilePhotos &&
          entry.profilePhotoArrayIndex !== null &&
          isRecord(updatedProfilePhotos[entry.profilePhotoArrayIndex])
        ) {
          updatedProfilePhotos[entry.profilePhotoArrayIndex] = {
            ...updatedProfilePhotos[entry.profilePhotoArrayIndex],
            thumbnailUrl,
            thumbnailStoragePath: thumbnailPath,
            updatedAt: admin.firestore.Timestamp.now(),
          };
        }
        changed = true;
        written += 1;
        console.log(
          `[write] ${userDoc.id} ${sourcePath} -> ${thumbnailPath}`
        );
      } catch (error) {
        skipped += 1;
        console.warn(
          `[skip] ${userDoc.id} photo ${entry.position}: ${error.message}`
        );
      }
    }

    if (apply && changed) {
      await userDoc.ref.update({
        photoThumbnailUrls: updatedThumbnailUrls,
        ...(updatedProfilePhotos && {profilePhotos: updatedProfilePhotos}),
      });
    }
  }

  console.log(
    JSON.stringify({mode: apply ? "apply" : "dry-run", scanned, missing, written, skipped}, null, 2)
  );
}

function asStringArray(value) {
  return Array.isArray(value) ?
    value.filter((item) => typeof item === "string") :
    [];
}

function profilePhotoEntries(data) {
  if (Array.isArray(data.profilePhotos) && data.profilePhotos.length > 0) {
    return data.profilePhotos
      .map((photo, arrayIndex) => {
        if (!isRecord(photo)) return null;
        const position = Number.isInteger(photo.position) ?
          photo.position :
          arrayIndex;
        const legacyThumbnail =
          asStringArray(data.photoThumbnailUrls)[position] ?? "";
        return {
          profilePhotoArrayIndex: arrayIndex,
          position,
          url: typeof photo.url === "string" ? photo.url : "",
          thumbnailUrl: typeof photo.thumbnailUrl === "string" ?
            photo.thumbnailUrl :
            legacyThumbnail,
          storagePath: typeof photo.storagePath === "string" ?
            photo.storagePath :
            null,
          thumbnailStoragePath:
            typeof photo.thumbnailStoragePath === "string" ?
              photo.thumbnailStoragePath :
              null,
        };
      })
      .filter((entry) => entry && entry.url);
  }

  return asStringArray(data.photoUrls).map((url, position) => ({
    profilePhotoArrayIndex: null,
    position,
    url,
    thumbnailUrl: asStringArray(data.photoThumbnailUrls)[position] ?? "",
    storagePath: null,
    thumbnailStoragePath: null,
  }));
}

function isRecord(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function storagePathFromDownloadUrl(url) {
  try {
    const parsed = new URL(url);
    const objectMarker = "/o/";
    if (parsed.pathname.includes(objectMarker)) {
      return decodeURIComponent(parsed.pathname.split(objectMarker)[1]);
    }

    const pathname = parsed.pathname.replace(/^\/+/, "");
    const parts = pathname.split("/");
    if (parsed.hostname === "storage.googleapis.com" && parts.length > 1) {
      return parts.slice(1).join("/");
    }
  } catch (_) {
    return null;
  }
  return null;
}

function thumbnailPathFor(uid, index, sourcePath) {
  const sourceName = sourcePath.split("/").pop().replace(/\.[^.]+$/, "");
  return `users/${uid}/photoThumbnails/${index}_${sourceName}.jpg`;
}

function downloadUrl(bucketName, filePath, token) {
  return `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/` +
    `${encodeURIComponent(filePath)}?alt=media&token=${token}`;
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
