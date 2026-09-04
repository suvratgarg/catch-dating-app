import {randomUUID} from "crypto";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {onDocumentWritten} from "firebase-functions/v2/firestore";
import sharp from "sharp";
import {
  profilePhotoPolicy,
} from "../shared/generated/catalogs/profilePhotoPolicy";

const GALLERY_THUMBNAIL_SIZE = 640;
const LOGO_THUMBNAIL_SIZE = profilePhotoPolicy.thumbnailSize;
const JPEG_QUALITY = 76;
const MAX_CONCURRENT_THUMBNAILS = 2;

type MediaKind = "gallery" | "logo";

interface PendingThumbnail {
  sourcePath: string;
  thumbnailPath: string;
  kind: MediaKind;
}

/** Generates thumbnails only after organizer media is attached to Firestore. */
export const generateOrganizerMediaThumbnails = onDocumentWritten(
  "organizers/{organizerId}",
  async (event) => {
    const data = event.data?.after.data();
    if (!data) return;
    const organizerId = event.params.organizerId;
    const pending = pendingOrganizerThumbnails(data, organizerId);
    await processWithConcurrency(pending, async (item) => {
      await generateAndAttachThumbnail({
        collection: "organizers",
        documentId: organizerId,
        item,
      });
    });
  }
);

/** Generates thumbnails only after event gallery media is attached. */
export const generateEventMediaThumbnails = onDocumentWritten(
  "events/{eventId}",
  async (event) => {
    const data = event.data?.after.data();
    if (!data) return;
    const eventId = event.params.eventId;
    const pending = pendingEventThumbnails(data, eventId);
    await processWithConcurrency(pending, async (item) => {
      await generateAndAttachThumbnail({
        collection: "events",
        documentId: eventId,
        item,
      });
    });
  }
);

export function v2ThumbnailPath(sourcePath: string): string | null {
  const parts = sourcePath.split("/");
  const isOrganizerGallery = parts.length === 5 &&
    parts[0] === "organizers" && parts[2] === "media";
  const isOrganizerLogo = parts.length === 5 &&
    parts[0] === "organizers" && parts[2] === "logo";
  const isEventGallery = parts.length === 5 &&
    parts[0] === "events" && parts[2] === "media";
  if (!isOrganizerGallery && !isOrganizerLogo && !isEventGallery) return null;
  if (!/^original\.[A-Za-z0-9]+$/.test(parts[4])) return null;
  return [...parts.slice(0, 4), "thumbnail.jpg"].join("/");
}

export function applyThumbnailToPhotos({
  photos,
  sourcePath,
  thumbnailPath,
  thumbnailUrl,
  timestamp,
}: {
  photos: unknown;
  sourcePath: string;
  thumbnailPath: string;
  thumbnailUrl: string;
  timestamp: FirebaseFirestore.Timestamp;
}): {photos: unknown[]; matched: boolean} {
  if (!Array.isArray(photos)) return {photos: [], matched: false};
  let matched = false;
  const updated = photos.map((photo) => {
    if (!isRecord(photo) || photo.storagePath !== sourcePath) return photo;
    matched = true;
    return {
      ...photo,
      thumbnailUrl,
      thumbnailStoragePath: thumbnailPath,
      updatedAt: timestamp,
    };
  });
  return {photos: updated, matched};
}

function pendingOrganizerThumbnails(
  data: Record<string, unknown>,
  organizerId: string
): PendingThumbnail[] {
  const pending: PendingThumbnail[] = [];
  addPendingPhoto(pending, data.logoPhoto, "logo", organizerId);
  const gallery = data.organizerPhotos;
  if (Array.isArray(gallery)) {
    gallery.forEach((photo) =>
      addPendingPhoto(pending, photo, "gallery", organizerId));
  }
  return uniqueBySourcePath(pending);
}

function pendingEventThumbnails(
  data: Record<string, unknown>,
  eventId: string
): PendingThumbnail[] {
  const pending: PendingThumbnail[] = [];
  if (Array.isArray(data.eventPhotos)) {
    data.eventPhotos.forEach((photo) =>
      addPendingPhoto(pending, photo, "gallery", eventId));
  }
  return uniqueBySourcePath(pending);
}

function addPendingPhoto(
  output: PendingThumbnail[],
  value: unknown,
  kind: MediaKind,
  ownerId: string
) {
  if (!isRecord(value) ||
    typeof value.storagePath !== "string" ||
    (typeof value.thumbnailUrl === "string" && value.thumbnailUrl.length > 0)
  ) return;
  const thumbnailPath = v2ThumbnailPath(value.storagePath);
  if (!thumbnailPath) return;
  const parts = value.storagePath.split("/");
  if (parts[1] !== ownerId) return;
  output.push({sourcePath: value.storagePath, thumbnailPath, kind});
}

function uniqueBySourcePath(items: PendingThumbnail[]): PendingThumbnail[] {
  return [...new Map(items.map((item) => [item.sourcePath, item])).values()];
}

async function generateAndAttachThumbnail({
  collection,
  documentId,
  item,
}: {
  collection: "organizers" | "events";
  documentId: string;
  item: PendingThumbnail;
}) {
  const bucket = admin.storage().bucket();
  try {
    const [source] = await bucket.file(item.sourcePath).download();
    const size = item.kind === "logo" ?
      LOGO_THUMBNAIL_SIZE : GALLERY_THUMBNAIL_SIZE;
    const image = sharp(source).rotate();
    const resized = item.kind === "logo" ?
      image.resize(size, size, {fit: "cover", position: "attention"}) :
      image.resize(size, size, {fit: "inside", withoutEnlargement: true});
    const thumbnail = await resized
      .jpeg({quality: JPEG_QUALITY, mozjpeg: true})
      .toBuffer();
    const token = randomUUID();
    await bucket.file(item.thumbnailPath).save(thumbnail, {
      resumable: false,
      contentType: "image/jpeg",
      metadata: {metadata: {
        firebaseStorageDownloadTokens: token,
        sourceObject: item.sourcePath,
      }},
    });
    const thumbnailUrl = downloadUrl(
      bucket.name,
      item.thumbnailPath,
      token
    );
    const attached = await attachThumbnail({
      collection,
      documentId,
      item,
      thumbnailUrl,
    });
    if (!attached) {
      await bucket.file(item.thumbnailPath).delete({ignoreNotFound: true});
    }
  } catch (error) {
    logger.error("Attached media thumbnail generation failed", {
      collection,
      documentId,
      sourcePath: item.sourcePath,
      error,
    });
  }
}

async function attachThumbnail({
  collection,
  documentId,
  item,
  thumbnailUrl,
}: {
  collection: "organizers" | "events";
  documentId: string;
  item: PendingThumbnail;
  thumbnailUrl: string;
}): Promise<boolean> {
  const db = admin.firestore();
  const ref = db.collection(collection).doc(documentId);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) return false;
    const data = snap.data() ?? {};
    const timestamp = admin.firestore.Timestamp.now();
    const patch: Record<string, unknown> = {};
    let matched = false;
    if (collection === "events") {
      const update = applyThumbnailToPhotos({
        photos: data.eventPhotos,
        sourcePath: item.sourcePath,
        thumbnailPath: item.thumbnailPath,
        thumbnailUrl,
        timestamp,
      });
      if (update.matched) patch.eventPhotos = update.photos;
      matched = update.matched;
    } else if (item.kind === "logo") {
      const logoPhoto = data.logoPhoto;
      if (isRecord(logoPhoto) && logoPhoto.storagePath === item.sourcePath) {
        patch.logoPhoto = {
          ...logoPhoto,
          thumbnailUrl,
          thumbnailStoragePath: item.thumbnailPath,
          updatedAt: timestamp,
        };
        patch.profileImageUrl = thumbnailUrl;
        matched = true;
      }
    } else {
      const canonical = applyThumbnailToPhotos({
        photos: data.organizerPhotos,
        sourcePath: item.sourcePath,
        thumbnailPath: item.thumbnailPath,
        thumbnailUrl,
        timestamp,
      });
      if (canonical.matched) patch.organizerPhotos = canonical.photos;
      matched = canonical.matched;
    }
    if (!matched) return false;
    tx.update(ref, patch);
    return true;
  });
}

async function processWithConcurrency<T>(
  items: T[],
  process: (item: T) => Promise<void>
) {
  for (
    let start = 0;
    start < items.length;
    start += MAX_CONCURRENT_THUMBNAILS
  ) {
    await Promise.all(
      items.slice(start, start + MAX_CONCURRENT_THUMBNAILS).map(process)
    );
  }
}

function downloadUrl(bucket: string, path: string, token: string): string {
  return `https://firebasestorage.googleapis.com/v0/b/${bucket}/o/` +
    `${encodeURIComponent(path)}?alt=media&token=${token}`;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
