import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {UserProfileDoc} from "../shared/firestore";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {CreateClubCallablePayload} from
  "../shared/generated/createClubCallablePayload";
import {validateCreateClubCallablePayload} from
  "../shared/generated/schemaValidators";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {
  activeClubMembershipPatch,
  clubMembershipId,
} from "../shared/relationshipDocuments";
import {publicAvatarUrl, publicDisplayName} from "../shared/profileProjection";
import {normalizeCreateClubPayload} from "./clubPayloadNormalization";

interface CreateClubDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: CreateClubDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  checkRateLimit: defaultCheckRateLimit,
};

/**
 * Creates a club and host membership edge.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {CreateClubDeps} deps Injectable dependencies for tests.
 * @return {Promise<{clubId: string}>} Created club id.
 */
export async function createClubHandler(
  request: CallableRequest<unknown>,
  deps: CreateClubDeps = defaultDeps
): Promise<{clubId: string}> {
  const hostUserId = requireAuth(request);
  const data = validateCallableWithAjv<CreateClubCallablePayload>(
    request,
    validateCreateClubCallablePayload,
    normalizeCreateClubPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, hostUserId, "createClub");
  const clubRef = data.clubId ?
    db.collection("clubs").doc(data.clubId) :
    db.collection("clubs").doc();
  const hostClaimRef = db.collection("clubHostClaims").doc(hostUserId);
  const membershipRef = db
    .collection("clubMemberships")
    .doc(clubMembershipId(clubRef.id, hostUserId));
  const userRef = db.collection("users").doc(hostUserId);
  const deletedUserRef = db.collection("deletedUsers").doc(hostUserId);
  const existingHostedClubSnap = await db
    .collection("clubs")
    .where("hostUserId", "==", hostUserId)
    .limit(1)
    .get();
  if (!existingHostedClubSnap.empty) {
    throw new HttpsError(
      "failed-precondition",
      "You can only host one club."
    );
  }

  await db.runTransaction(async (tx) => {
    const [clubSnap, hostClaimSnap, userSnap, deletedUserSnap] =
      await Promise.all([
        tx.get(clubRef),
        tx.get(hostClaimRef),
        tx.get(userRef),
        tx.get(deletedUserRef),
      ]);

    if (clubSnap.exists) {
      throw new HttpsError("already-exists", "Club already exists.");
    }
    if (hostClaimSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "You can only host one club."
      );
    }
    if (!userSnap.exists) {
      throw new HttpsError("not-found", "User profile not found.");
    }
    if (deletedUserSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "This account cannot create clubs."
      );
    }

    const user = requireDoc<UserProfileDoc>(userSnap, "UserProfileDoc");
    if (user.profileComplete !== true) {
      throw new HttpsError(
        "failed-precondition",
        "Complete your profile before creating a club."
      );
    }

    tx.create(clubRef, {
      name: data.name,
      description: data.description,
      location: data.location,
      area: data.area,
      hostUserId,
      hostName: publicDisplayName(user),
      hostAvatarUrl: publicAvatarUrl(user),
      createdAt: deps.serverTimestamp(),
      imageUrl: data.imageUrl ?? null,
      tags: [],
      memberCount: 1,
      rating: 0,
      reviewCount: 0,
      nextEventAt: null,
      nextEventLabel: null,
      status: "active",
      archived: false,
      archivedAt: null,
      archiveReason: null,
      instagramHandle: data.instagramHandle ?? null,
      phoneNumber: data.phoneNumber ?? null,
      email: data.email ?? null,
    });
    tx.set(membershipRef, activeClubMembershipPatch({
      clubId: clubRef.id,
      uid: hostUserId,
      role: "host",
    }), {merge: true});
    tx.create(hostClaimRef, {
      uid: hostUserId,
      clubId: clubRef.id,
      createdAt: deps.serverTimestamp(),
    });
  });

  return {clubId: clubRef.id};
}

export const createClub = onCall(
  appCheckCallableOptions,
  (request) => createClubHandler(request)
);
