import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {OrganizerDocument} from "../shared/generated/firestoreAdminTypes";
import {ArchiveOrganizerCallablePayload} from
  "../shared/generated/archiveOrganizerCallablePayload";
import {DeleteOrganizerCallablePayload} from
  "../shared/generated/deleteOrganizerCallablePayload";
import {UpdateOrganizerCallablePayload} from
  "../shared/generated/updateOrganizerCallablePayload";
import {
  validateArchiveOrganizerCallablePayload,
  validateDeleteOrganizerCallablePayload,
  validateUpdateOrganizerCallablePayload,
} from "../shared/generated/schemaValidators";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {isOrganizerManager, isOrganizerOwner} from
  "../shared/organizerHosts";
import {
  normalizeOptionalUploadedPhotoForFirestore,
  normalizeUploadedPhotosForFirestore,
} from "../shared/uploadedPhotoNormalization";
import {marketForIdOrAlias} from "../locations/marketConfig";
import {
  normalizeArchiveOrganizerPayload,
  normalizeOrganizerIdPayload,
  normalizeUpdateOrganizerPayload,
} from "./organizerPayloadNormalization";

interface OrganizerLifecycleDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp?: () => FirebaseFirestore.FieldValue;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: OrganizerLifecycleDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  checkRateLimit: defaultCheckRateLimit,
};

export async function updateOrganizerHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerLifecycleDeps = defaultDeps
): Promise<{updated: boolean}> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<UpdateOrganizerCallablePayload>(
    request,
    validateUpdateOrganizerCallablePayload,
    normalizeUpdateOrganizerPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, actorUid, "updateOrganizer");
  const organizerRef = db.collection("organizers").doc(data.organizerId);
  const legacyClubRef = db.collection("clubs").doc(data.organizerId);
  const deletedUserRef = db.collection("deletedUsers").doc(actorUid);

  await db.runTransaction(async (tx) => {
    const [organizerSnap, legacyClubSnap, deletedUserSnap] = await Promise.all([
      tx.get(organizerRef),
      tx.get(legacyClubRef),
      tx.get(deletedUserRef),
    ]);
    assertCanUpdateOrganizer(
      organizerSnap,
      deletedUserSnap,
      actorUid,
      data.fields
    );
    const patch = organizerPatch(
      data.fields,
      actorUid,
      deps.serverTimestamp?.() ??
        admin.firestore.FieldValue.serverTimestamp()
    );
    tx.update(organizerRef, patch);
    if (legacyClubSnap.exists) {
      tx.update(legacyClubRef, legacyClubPatch(patch));
    }
  });
  return {updated: true};
}

export async function archiveOrganizerHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerLifecycleDeps = defaultDeps
): Promise<{archived: boolean}> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<ArchiveOrganizerCallablePayload>(
    request,
    validateArchiveOrganizerCallablePayload,
    normalizeArchiveOrganizerPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, actorUid, "archiveOrganizer");
  const organizerRef = db.collection("organizers").doc(data.organizerId);
  const legacyClubRef = db.collection("clubs").doc(data.organizerId);
  const deletedUserRef = db.collection("deletedUsers").doc(actorUid);

  await db.runTransaction(async (tx) => {
    const [organizerSnap, legacyClubSnap, deletedUserSnap] = await Promise.all([
      tx.get(organizerRef),
      tx.get(legacyClubRef),
      tx.get(deletedUserRef),
    ]);
    assertCanMutateOrganizer(organizerSnap, deletedUserSnap, actorUid);
    const existing = organizerSnap.data();
    if (existing?.status === "archived" || existing?.archived === true) return;
    const patch = {
      status: "archived",
      archived: true,
      archivedAt: deps.serverTimestamp?.() ??
        admin.firestore.FieldValue.serverTimestamp(),
      archiveReason: data.reason ?? null,
    };
    tx.update(organizerRef, patch);
    if (legacyClubSnap.exists) tx.update(legacyClubRef, patch);
  });
  return {archived: true};
}

export async function deleteOrganizerHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerLifecycleDeps = defaultDeps
): Promise<{deleted: boolean}> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<DeleteOrganizerCallablePayload>(
    request,
    validateDeleteOrganizerCallablePayload,
    normalizeOrganizerIdPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, actorUid, "deleteOrganizer");
  const organizerRef = db.collection("organizers").doc(data.organizerId);
  const legacyClubRef = db.collection("clubs").doc(data.organizerId);
  const deletedUserRef = db.collection("deletedUsers").doc(actorUid);

  await db.runTransaction(async (tx) => {
    const [
      organizerSnap,
      legacyClubSnap,
      deletedUserSnap,
      organizerEventsSnap,
      legacyEventsSnap,
      organizerReviewsSnap,
      legacyReviewsSnap,
      organizerPaymentsSnap,
      legacyPaymentsSnap,
      teamSnap,
      followsSnap,
    ] = await Promise.all([
      tx.get(organizerRef),
      tx.get(legacyClubRef),
      tx.get(deletedUserRef),
      tx.get(db.collection("events")
        .where("organizerId", "==", data.organizerId).limit(1)),
      tx.get(db.collection("events")
        .where("clubId", "==", data.organizerId).limit(1)),
      tx.get(db.collection("reviews")
        .where("organizerId", "==", data.organizerId).limit(1)),
      tx.get(db.collection("reviews")
        .where("clubId", "==", data.organizerId).limit(1)),
      tx.get(db.collection("payments")
        .where("organizerId", "==", data.organizerId).limit(1)),
      tx.get(db.collection("payments")
        .where("clubId", "==", data.organizerId).limit(1)),
      tx.get(db.collection("organizerTeamMemberships")
        .where("organizerId", "==", data.organizerId).limit(2)),
      tx.get(db.collection("organizerFollows")
        .where("organizerId", "==", data.organizerId).limit(1)),
    ]);
    assertCanMutateOrganizer(organizerSnap, deletedUserSnap, actorUid);
    const team = teamSnap.docs.map((doc) => doc.data());
    const onlyOwner = team.length <= 1 && team.every((membership) =>
      membership.uid === actorUid && membership.role === "owner"
    );
    if (
      !organizerEventsSnap.empty || !legacyEventsSnap.empty ||
      !organizerReviewsSnap.empty || !legacyReviewsSnap.empty ||
      !organizerPaymentsSnap.empty || !legacyPaymentsSnap.empty ||
      !followsSnap.empty || !onlyOwner
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Organizers with events, payments, reviews, followers, or managers " +
          "must be archived."
      );
    }
    teamSnap.docs.forEach((doc) => tx.delete(doc.ref));
    if (legacyClubSnap.exists) tx.delete(legacyClubRef);
    tx.delete(organizerRef);
  });
  return {deleted: true};
}

function assertCanMutateOrganizer(
  organizerSnap: FirebaseFirestore.DocumentSnapshot,
  deletedUserSnap: FirebaseFirestore.DocumentSnapshot,
  actorUid: string
) {
  if (deletedUserSnap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "This account cannot manage organizers."
    );
  }
  if (!organizerSnap.exists) {
    throw new HttpsError("not-found", "Organizer not found.");
  }
  const organizer = requireDoc<OrganizerDocument>(
    organizerSnap,
    "OrganizerDocument"
  );
  if (!isOrganizerOwner(organizer, actorUid)) {
    throw new HttpsError(
      "permission-denied",
      "Only the organizer owner can manage this organizer."
    );
  }
}

function assertCanUpdateOrganizer(
  organizerSnap: FirebaseFirestore.DocumentSnapshot,
  deletedUserSnap: FirebaseFirestore.DocumentSnapshot,
  actorUid: string,
  fields: UpdateOrganizerCallablePayload["fields"]
) {
  if (deletedUserSnap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "This account cannot manage organizers."
    );
  }
  if (!organizerSnap.exists) {
    throw new HttpsError("not-found", "Organizer not found.");
  }
  const organizer = requireDoc<OrganizerDocument>(
    organizerSnap,
    "OrganizerDocument"
  );
  if (isOrganizerOwner(organizer, actorUid)) return;
  if (
    isOrganizerManager(organizer, actorUid) &&
    Object.keys(fields).every((field) =>
      field === "imageUrl" ||
      field === "profileImageUrl" ||
      field === "organizerPhotos" ||
      field === "logoPhoto"
    )
  ) return;
  throw new HttpsError(
    "permission-denied",
    "Only the organizer owner can change organizer identity."
  );
}

function organizerPatch(
  fields: UpdateOrganizerCallablePayload["fields"],
  actorUid: string,
  serverTimestamp: FirebaseFirestore.FieldValue
): Record<string, unknown> {
  const patch: Record<string, unknown> = {...fields};
  if (fields.organizerType !== undefined) {
    patch.organizerTypeUpdatedAt = serverTimestamp;
    patch.organizerTypeUpdatedByUid = actorUid;
  }
  if (fields.location !== undefined) {
    const market = marketForIdOrAlias(fields.location);
    if (!market || !market.hostCreatable) {
      throw new HttpsError(
        "failed-precondition",
        "This city is not open for organizer creation yet."
      );
    }
    patch.location = market.marketId;
    patch.locationCityId = market.cityId;
    patch.locationMarketId = market.marketId;
    patch.cityName = market.cityLabel;
    patch.regionName = market.regionName;
    patch.countryCode = market.countryIsoCode;
    patch.countryName = market.countryName;
  }
  if (fields.organizerPhotos !== undefined) {
    const organizerPhotos = normalizeUploadedPhotosForFirestore(
      fields.organizerPhotos
    );
    patch.organizerPhotos = organizerPhotos;
    patch.imageUrl = primaryPhotoUrl(organizerPhotos);
  }
  if (fields.logoPhoto !== undefined) {
    const logoPhoto = normalizeOptionalUploadedPhotoForFirestore(
      fields.logoPhoto
    );
    patch.logoPhoto = logoPhoto;
    patch.profileImageUrl = thumbnailOrUrl(logoPhoto);
  }
  return patch;
}

function legacyClubPatch(
  organizerPatch: Record<string, unknown>
): Record<string, unknown> {
  const patch = {...organizerPatch};
  if ("organizerPhotos" in patch) {
    patch.clubPhotos = patch.organizerPhotos;
    delete patch.organizerPhotos;
  }
  return patch;
}

function primaryPhotoUrl(photos: unknown[] | undefined): string | null {
  if (!Array.isArray(photos) || photos.length === 0) return null;
  const first = photos[0];
  if (first === null || typeof first !== "object") return null;
  const url = (first as {url?: unknown}).url;
  return typeof url === "string" && url.trim().length > 0 ? url : null;
}

function thumbnailOrUrl(photo: unknown): string | null {
  if (photo === null || typeof photo !== "object") return null;
  const thumbnailUrl = (photo as {thumbnailUrl?: unknown}).thumbnailUrl;
  if (typeof thumbnailUrl === "string" && thumbnailUrl.trim().length > 0) {
    return thumbnailUrl;
  }
  const url = (photo as {url?: unknown}).url;
  return typeof url === "string" && url.trim().length > 0 ? url : null;
}

export const updateOrganizer = onCall(
  appCheckCallableOptions,
  (request) => updateOrganizerHandler(request)
);
export const archiveOrganizer = onCall(
  appCheckCallableOptions,
  (request) => archiveOrganizerHandler(request)
);
export const deleteOrganizer = onCall(
  appCheckCallableOptions,
  (request) => deleteOrganizerHandler(request)
);
