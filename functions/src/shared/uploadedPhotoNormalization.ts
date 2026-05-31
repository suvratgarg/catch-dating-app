import * as admin from "firebase-admin";
import {
  UploadedPhoto,
} from "./generated/firestoreAdminTypes";

/**
 * Normalizes callable uploaded photo arrays before Admin SDK Firestore writes.
 * @param {unknown} value Candidate uploaded photo array from a callable.
 * @return {UploadedPhoto[]} Firestore-ready uploaded photo records.
 */
export function normalizeUploadedPhotosForFirestore(
  value: unknown
): UploadedPhoto[] {
  if (!Array.isArray(value)) return [];
  return value.map((photo) => normalizeUploadedPhotoForFirestore(photo));
}

/**
 * Normalizes a nullable callable uploaded photo before a Firestore write.
 * @param {unknown} value Candidate uploaded photo from a callable.
 * @return {UploadedPhoto|null} Firestore-ready record or null.
 */
export function normalizeOptionalUploadedPhotoForFirestore(
  value: unknown
): UploadedPhoto | null {
  if (value === undefined || value === null) return null;
  return normalizeUploadedPhotoForFirestore(value);
}

/**
 * Converts one uploaded photo record to the Admin SDK timestamp shape.
 * @param {unknown} value Candidate uploaded photo record.
 * @return {UploadedPhoto} Firestore-ready uploaded photo.
 */
function normalizeUploadedPhotoForFirestore(value: unknown): UploadedPhoto {
  if (value === null || typeof value !== "object") {
    throw new Error("Uploaded photo must be an object.");
  }

  const photo = value as Record<string, unknown>;
  const moderation = normalizeModeration(photo.moderation);
  return {
    ...photo,
    ...(moderation !== undefined && {moderation}),
    createdAt: timestampFromUploadValue(photo.createdAt),
    updatedAt: timestampFromUploadValue(photo.updatedAt),
  } as UploadedPhoto;
}

/**
 * Converts the optional moderation timestamp inside an uploaded photo.
 * @param {unknown} value Candidate moderation object.
 * @return {unknown} Moderation with Admin SDK timestamps when present.
 */
function normalizeModeration(value: unknown): unknown {
  if (value === undefined || value === null || typeof value !== "object") {
    return value;
  }
  const moderation = value as Record<string, unknown>;
  if (moderation.reviewedAt === undefined || moderation.reviewedAt === null) {
    return moderation;
  }
  return {
    ...moderation,
    reviewedAt: timestampFromUploadValue(moderation.reviewedAt),
  };
}

/**
 * Converts callable timestamp encodings to Admin SDK Timestamp instances.
 * @param {unknown} value Number, serialized timestamp, or Admin Timestamp.
 * @return {FirebaseFirestore.Timestamp} Admin SDK timestamp value.
 */
function timestampFromUploadValue(
  value: unknown
): FirebaseFirestore.Timestamp {
  if (value instanceof admin.firestore.Timestamp) return value;
  if (typeof value === "number") {
    return admin.firestore.Timestamp.fromMillis(value);
  }
  if (value !== null && typeof value === "object") {
    const timestamp = value as Record<string, unknown>;
    const seconds = timestamp._seconds ?? timestamp.seconds;
    const nanoseconds = timestamp._nanoseconds ?? timestamp.nanoseconds ?? 0;
    if (typeof seconds === "number" && typeof nanoseconds === "number") {
      return new admin.firestore.Timestamp(seconds, nanoseconds);
    }
  }
  throw new Error("Uploaded photo timestamp must be a timestamp-like value.");
}
