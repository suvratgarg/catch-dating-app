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
    const photoUrls = asStringArray(data.photoUrls);
    const thumbnailUrls = asStringArray(data.photoThumbnailUrls);
    if (photoUrls.length === 0) continue;

    const updated = [...thumbnailUrls];
    let changed = false;

    for (let index = 0; index < photoUrls.length; index += 1) {
      if (updated[index]) continue;
      missing += 1;
      const sourcePath = storagePathFromDownloadUrl(photoUrls[index]);
      if (!sourcePath) {
        skipped += 1;
        console.warn(`[skip] ${userDoc.id} photo ${index}: unsupported URL`);
        continue;
      }

      const sourceFile = bucket.file(sourcePath);
      const [exists] = await sourceFile.exists();
      if (!exists) {
        skipped += 1;
        console.warn(`[skip] ${userDoc.id} photo ${index}: source missing`);
        continue;
      }

      const thumbnailPath = thumbnailPathFor(userDoc.id, index, sourcePath);
      console.log(
        `[${apply ? "write" : "dry-run"}] ${userDoc.id} ${sourcePath} -> ` +
          thumbnailPath
      );
      if (!apply) continue;

      const [sourceBuffer] = await sourceFile.download();
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
            profilePhotoIndex: String(index),
          },
        },
      });
      while (updated.length <= index) updated.push("");
      updated[index] = downloadUrl(bucket.name, thumbnailPath, token);
      changed = true;
      written += 1;
    }

    if (apply && changed) {
      await userDoc.ref.update({photoThumbnailUrls: updated});
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
