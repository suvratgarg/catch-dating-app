import {createHash, randomUUID} from "node:crypto";
import * as admin from "firebase-admin";
import {ImageAnnotatorClient} from "@google-cloud/vision";
import sharp from "sharp";
import {HttpsError} from "firebase-functions/v2/https";
import type {OrganizerFormAssetDocument as Asset,
  OrganizerFormResponseDocument as Response, ProfilePhoto} from
  "../shared/generated/firestoreAdminTypes";
import {requireDoc} from "../shared/validation";
import {profilePhotoPolicy} from
  "../shared/generated/catalogs/profilePhotoPolicy";

export interface FormProfilePhotoInput {
  db: FirebaseFirestore.Firestore; uid: string; responseId: string;
  questionId: string; assetId: string; now: FirebaseFirestore.Timestamp;
}

/** Copy only an owned, active reviewed upload into owned profile media. */
export async function copyFormProfilePhoto(input: FormProfilePhotoInput):
  Promise<ProfilePhoto> {
  const {db, uid, responseId, questionId, assetId, now} = input;
  const [responseSnap, assetSnap] = await Promise.all([
    db.collection("organizerFormResponses").doc(responseId).get(),
    db.collection("organizerFormAssets").doc(assetId).get(),
  ]);
  if (!responseSnap.exists || !assetSnap.exists) throw unavailable();
  const response = requireDoc<Response>(responseSnap,
    "OrganizerFormResponseDocument");
  const asset = requireDoc<Asset>(assetSnap, "OrganizerFormAssetDocument");
  assertClaimPhotoAsset({uid, questionId, assetId, response, asset, now});
  const bucket = admin.storage().bucket();
  const source = bucket.file(asset.storagePath);
  const [metadata] = await source.getMetadata();
  if (Number(metadata.size) !== asset.sizeBytes ||
      metadata.contentType !== asset.contentType) throw unavailable();
  // Pin the inspected object generation and cap the transfer, including
  // one extra byte so a replaced/oversized object cannot pass the length check.
  if (!metadata.generation) throw unavailable();
  const [bytes] = await bucket.file(asset.storagePath, {
    generation: metadata.generation,
  }).download({start: 0, end: asset.sizeBytes!});
  if (bytes.length !== asset.sizeBytes ||
      createHash("sha256").update(bytes).digest("hex") !==
        asset.declaredSha256) throw unavailable();
  const [checked] = await new ImageAnnotatorClient().safeSearchDetection({
    image: {content: bytes},
  });
  // Use the same categories as normal uploads before writing profile media.
  const moderationStatus = assertFormPhotoSafety(checked.safeSearchAnnotation);
  const normalized = await normalizeFormProfilePhoto(bytes);
  const id = "form_" + createHash("sha256").update(
    [uid, responseId, questionId, assetId, asset.declaredSha256].join("|")
  ).digest("hex").slice(0, 40);
  const storagePath = `users/${uid}/photos/${id}.jpg`;
  const thumbnailStoragePath = `users/${uid}/photoThumbnails/${id}.jpg`;
  const saveOnce = async (path: string, content: Buffer) => {
    const file = bucket.file(path);
    const token = randomUUID();
    try {
      await file.save(content, {resumable: false, contentType: "image/jpeg",
        preconditionOpts: {ifGenerationMatch: 0},
        metadata: {metadata: {firebaseStorageDownloadTokens: token,
          formSourceSha256: asset.declaredSha256}}});
    } catch (error) {
      if ((error as {code?: number}).code !== 412 &&
          (error as {code?: number}).code !== 409) throw error;
    }
    const [saved] = await file.getMetadata();
    const savedToken = saved.metadata?.firebaseStorageDownloadTokens;
    if (saved.md5Hash !== createHash("md5").update(content).digest("base64") ||
        Number(saved.size) !== content.length ||
        saved.contentType !== "image/jpeg" ||
        saved.metadata?.formSourceSha256 !== asset.declaredSha256 ||
        typeof savedToken !== "string" || !savedToken) throw unavailable();
    return `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/` +
      `${encodeURIComponent(path)}?alt=media&token=${savedToken}`;
  };
  const saved = await Promise.allSettled([
    saveOnce(storagePath, normalized.full),
    saveOnce(thumbnailStoragePath, normalized.thumbnail),
  ]);
  if (await removeDeletedClaimPhoto({db, uid, photo: {
    storagePath, thumbnailStoragePath}})) throw unavailable();
  const [url, thumbnailUrl] = saved.map((result) => {
    if (result.status === "rejected") throw result.reason;
    return result.value;
  });
  return {id, url, thumbnailUrl, storagePath, thumbnailStoragePath,
    position: 0, createdAt: now, updatedAt: now,
    moderation: {status: moderationStatus,
      reviewedAt: moderationStatus === "approved" ? now : null}};
}

/** Remove copied media after account deletion. */
export async function removeDeletedClaimPhoto(input: {
  db: FirebaseFirestore.Firestore; uid: string;
  photo: Pick<ProfilePhoto, "storagePath" | "thumbnailStoragePath">;
}): Promise<boolean> {
  const deleted = await input.db.collection("deletedUsers")
    .doc(input.uid).get();
  if (!deleted.exists) {
    return false;
  }
  const paths = [input.photo.storagePath, input.photo.thumbnailStoragePath];
  if (paths.some((path) => !path.startsWith(`users/${input.uid}/photos/`) &&
      !path.startsWith(`users/${input.uid}/photoThumbnails/`))) {
    throw unavailable();
  }
  await Promise.all(paths.map((path) => admin.storage().bucket().file(path)
    .delete({ignoreNotFound: true})));
  return true;
}

export function assertFormPhotoSafety(safety: {
  adult?: string | number | null; violence?: string | number | null;
  racy?: string | number | null; medical?: string | number | null;
} | null | undefined): "approved" | "pending" {
  const known = new Set<string | number>([1, 2, 3, 4,
    "VERY_UNLIKELY", "UNLIKELY", "POSSIBLE", "LIKELY"]);
  if (!safety || [safety.adult, safety.violence, safety.racy, safety.medical]
    .some((value) => value == null || !known.has(value))) {
    throw new HttpsError("failed-precondition",
      "This photo could not be approved for your profile. Choose another.");
  }
  return [safety.adult, safety.violence, safety.racy, safety.medical]
    .some((value) => value === "LIKELY" || value === 4) ?
    "pending" : "approved";
}

export function assertClaimPhotoAsset(input: {
  uid: string; questionId: string; assetId: string; response: Response;
  asset: Asset; now: FirebaseFirestore.Timestamp;
}): void {
  const {uid, questionId, assetId, response, asset, now} = input;
  const answer = response.answers[questionId];
  if (response.respondentUid !== uid || response.status !== "submitted" ||
      response.withdrawnAt !== null || !Array.isArray(answer) ||
      answer.length !== 1 || answer[0] !== assetId ||
      asset.respondentUid !== uid ||
      asset.organizerId !== response.organizerId ||
      asset.formId !== response.formId ||
      asset.versionId !== response.versionId ||
      asset.draftId !== response.draftId || asset.questionId !== questionId ||
      asset.status !== "ready" || asset.deletedAt !== null ||
      asset.expiresAt.toMillis() <= now.toMillis() || !asset.sizeBytes ||
      asset.sizeBytes > 10 * 1024 * 1024 ||
      !["image/jpeg", "image/png", "image/webp"].includes(asset.contentType) ||
      asset.storagePath !==
        `organizerForms/${response.formId}/${response.draftId}/${assetId}`) {
    throw unavailable();
  }
}

export async function normalizeFormProfilePhoto(bytes: Buffer) {
  const source = sharp(bytes, {limitInputPixels: 40_000_000}).rotate();
  const [full, thumbnail] = await Promise.all([
    source.clone().resize(1600, 2000, {fit: "inside", withoutEnlargement: true})
      .jpeg({quality: 85}).toBuffer(),
    source.clone().resize(profilePhotoPolicy.thumbnailSize,
      profilePhotoPolicy.thumbnailSize, {fit: "cover"})
      .jpeg({quality: 72}).toBuffer(),
  ]);
  if (full.length > profilePhotoPolicy.maxUploadBytes) throw unavailable();
  return {full, thumbnail};
}

function unavailable() {
  return new HttpsError("failed-precondition",
    "This form photo is unavailable. Choose another photo for your profile.");
}
