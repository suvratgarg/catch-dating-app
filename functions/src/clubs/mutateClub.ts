/* eslint-disable require-jsdoc, valid-jsdoc */
import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {ClubDoc} from "../shared/generated/firestoreAdminTypes";
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
  normalizeArchiveClubPayload,
  normalizeClubIdPayload,
  normalizeUpdateClubPayload,
} from "./clubPayloadNormalization";

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
    tx.update(clubRef, data.fields);
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
  const club = requireDoc<ClubDoc>(clubSnap, "ClubDoc");
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
  const club = requireDoc<ClubDoc>(clubSnap, "ClubDoc");
  if (isClubOwner(club, hostUserId)) return;
  if (
    isClubHost(club, hostUserId) &&
    Object.keys(fields).every((field) =>
      field === "imageUrl" || field === "profileImageUrl"
    )
  ) {
    return;
  }
  throw new HttpsError(
    "permission-denied",
    "Only the club owner can manage this club."
  );
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
