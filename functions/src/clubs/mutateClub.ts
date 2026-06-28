import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {
  ClubDocument,
} from "../shared/generated/firestoreAdminTypes";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {ArchiveClubCallablePayload} from
  "../shared/generated/archiveClubCallablePayload";
import {DeleteClubCallablePayload} from
  "../shared/generated/deleteClubCallablePayload";
import {
  validateArchiveClubCallablePayload,
  validateDeleteClubCallablePayload,
  validateUpdateClubCallablePayload,
} from "../shared/generated/schemaValidators";
import {UpdateClubCallablePayload} from
  "../shared/generated/updateClubCallablePayload";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {isClubHost, isClubOwner} from "../shared/clubHosts";
import {
  normalizeOptionalUploadedPhotoForFirestore,
  normalizeUploadedPhotosForFirestore,
} from "../shared/uploadedPhotoNormalization";
import {
  normalizeArchiveClubPayload,
  normalizeClubIdPayload,
  normalizeUpdateClubPayload,
} from "./clubPayloadNormalization";
import {marketForIdOrAlias} from "../locations/marketConfig";

interface ClubLifecycleDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp?: () => FirebaseFirestore.FieldValue;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: ClubLifecycleDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  checkRateLimit: defaultCheckRateLimit,
};

export async function updateClubHandler(
  request: CallableRequest<unknown>,
  deps: ClubLifecycleDeps = defaultDeps
): Promise<{updated: boolean}> {
  const hostUserId = requireAuth(request);
  const data = validateCallableWithAjv<UpdateClubCallablePayload>(
    request,
    validateUpdateClubCallablePayload,
    normalizeUpdateClubPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, hostUserId, "updateClub");

  const clubRef = db.collection("clubs").doc(data.clubId);
  const deletedUserRef = db.collection("deletedUsers").doc(hostUserId);

  await db.runTransaction(async (tx) => {
    const [clubSnap, deletedUserSnap] = await Promise.all([
      tx.get(clubRef),
      tx.get(deletedUserRef),
    ]);
    assertCanUpdateClub(clubSnap, deletedUserSnap, hostUserId, data.fields);
    tx.update(clubRef, clubPatchWithLegacyFields(data.fields));
  });

  return {updated: true};
}

export async function archiveClubHandler(
  request: CallableRequest<unknown>,
  deps: ClubLifecycleDeps = defaultDeps
): Promise<{archived: boolean}> {
  const hostUserId = requireAuth(request);
  const data = validateCallableWithAjv<ArchiveClubCallablePayload>(
    request,
    validateArchiveClubCallablePayload,
    normalizeArchiveClubPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, hostUserId, "archiveClub");

  const clubRef = db.collection("clubs").doc(data.clubId);
  const deletedUserRef = db.collection("deletedUsers").doc(hostUserId);

  await db.runTransaction(async (tx) => {
    const [clubSnap, deletedUserSnap] = await Promise.all([
      tx.get(clubRef),
      tx.get(deletedUserRef),
    ]);
    assertCanMutateClub(clubSnap, deletedUserSnap, hostUserId);
    const existing = clubSnap.data();
    if (existing?.status === "archived" || existing?.archived === true) {
      return;
    }
    tx.update(clubRef, {
      status: "archived",
      archived: true,
      archivedAt: deps.serverTimestamp?.() ??
        admin.firestore.FieldValue.serverTimestamp(),
      archiveReason: data.reason ?? null,
    });
  });

  return {archived: true};
}

export async function deleteClubHandler(
  request: CallableRequest<unknown>,
  deps: ClubLifecycleDeps = defaultDeps
): Promise<{deleted: boolean}> {
  const hostUserId = requireAuth(request);
  const data = validateCallableWithAjv<DeleteClubCallablePayload>(
    request,
    validateDeleteClubCallablePayload,
    normalizeClubIdPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, hostUserId, "deleteClub");

  const clubRef = db.collection("clubs").doc(data.clubId);
  const hostClaimRef = db.collection("clubHostClaims").doc(hostUserId);
  const deletedUserRef = db.collection("deletedUsers").doc(hostUserId);

  await db.runTransaction(async (tx) => {
    const [
      clubSnap,
      deletedUserSnap,
      eventsSnap,
      reviewsSnap,
      paymentsSnap,
      membershipsSnap,
    ] = await Promise.all([
      tx.get(clubRef),
      tx.get(deletedUserRef),
      tx.get(db.collection("events")
        .where("clubId", "==", data.clubId)
        .limit(1)),
      tx.get(db.collection("reviews")
        .where("clubId", "==", data.clubId)
        .limit(1)),
      tx.get(db.collection("payments")
        .where("clubId", "==", data.clubId)
        .limit(1)),
      tx.get(db.collection("clubMemberships")
        .where("clubId", "==", data.clubId)
        .limit(2)),
    ]);

    assertCanMutateClub(clubSnap, deletedUserSnap, hostUserId);
    const memberships = membershipsSnap.docs.map((doc) => doc.data());
    const onlyHostMembership = memberships.length <= 1 &&
      memberships.every((membership) =>
        membership.uid === hostUserId &&
        (membership.role === "owner" || membership.role === "host")
      );
    if (
      !eventsSnap.empty ||
      !reviewsSnap.empty ||
      !paymentsSnap.empty ||
      !onlyHostMembership
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Clubs with events, payments, reviews, or members must be archived."
      );
    }

    membershipsSnap.docs.forEach((doc) => tx.delete(doc.ref));
    tx.delete(hostClaimRef);
    tx.delete(clubRef);
  });

  return {deleted: true};
}

function assertCanMutateClub(
  clubSnap: FirebaseFirestore.DocumentSnapshot,
  deletedUserSnap: FirebaseFirestore.DocumentSnapshot,
  hostUserId: string
) {
  if (deletedUserSnap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "This account cannot manage clubs."
    );
  }
  if (!clubSnap.exists) {
    throw new HttpsError("not-found", "Club not found.");
  }
  const club = requireDoc<ClubDocument>(
    clubSnap,
    "ClubDocument"
  );
  if (!isClubOwner(club, hostUserId)) {
    throw new HttpsError(
      "permission-denied",
      "Only the club owner can manage this club."
    );
  }
}

function assertCanUpdateClub(
  clubSnap: FirebaseFirestore.DocumentSnapshot,
  deletedUserSnap: FirebaseFirestore.DocumentSnapshot,
  hostUserId: string,
  fields: UpdateClubCallablePayload["fields"]
) {
  if (deletedUserSnap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "This account cannot manage clubs."
    );
  }
  if (!clubSnap.exists) {
    throw new HttpsError("not-found", "Club not found.");
  }
  const club = requireDoc<ClubDocument>(
    clubSnap,
    "ClubDocument"
  );
  if (isClubOwner(club, hostUserId)) return;
  if (
    isClubHost(club, hostUserId) &&
    Object.keys(fields).every((field) =>
      field === "imageUrl" ||
        field === "profileImageUrl" ||
        field === "clubPhotos" ||
        field === "logoPhoto"
    )
  ) {
    return;
  }
  throw new HttpsError(
    "permission-denied",
    "Only the club owner can manage this club."
  );
}

function clubPatchWithLegacyFields(
  fields: UpdateClubCallablePayload["fields"]
): Record<string, unknown> {
  const patch: Record<string, unknown> = {...fields};
  if (fields.location !== undefined) {
    const market = marketForIdOrAlias(fields.location);
    if (!market || !market.hostCreatable) {
      throw new HttpsError(
        "failed-precondition",
        "This city is not open for host creation yet."
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
  if (fields.clubPhotos !== undefined) {
    const clubPhotos = normalizeUploadedPhotosForFirestore(fields.clubPhotos);
    patch.clubPhotos = clubPhotos;
    patch.imageUrl = primaryPhotoUrl(clubPhotos);
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

export const archiveClub = onCall(
  appCheckCallableOptions,
  (request) => archiveClubHandler(request)
);

export const deleteClub = onCall(
  appCheckCallableOptions,
  (request) => deleteClubHandler(request)
);

export const updateClub = onCall(
  appCheckCallableOptions,
  (request) => updateClubHandler(request)
);
