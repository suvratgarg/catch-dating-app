import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {ClubDoc, UserProfileDoc} from "../shared/firestore";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {ClubMembershipCallablePayload} from
  "../shared/generated/clubMembershipCallablePayload";
import {
  validateClubMembershipCallablePayload,
  validateSetClubNotificationPreferenceCallablePayload,
} from "../shared/generated/schemaValidators";
import {SetClubNotificationPreferenceCallablePayload} from
  "../shared/generated/setClubNotificationPreferenceCallablePayload";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {
  activeClubMembershipPatch,
  leftClubMembershipPatch,
  clubMembershipId,
} from "../shared/relationshipDocuments";
import {normalizeClubIdPayload} from "./clubPayloadNormalization";
import {clubOwnerUserId, isClubHost, isClubOwner} from "../shared/clubHosts";

interface ClubMembershipDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: ClubMembershipDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit: defaultCheckRateLimit,
};

/**
 * Adds the signed-in user to a club through the membership edge document.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {ClubMembershipDeps} deps Injectable dependencies for tests.
 * @return {Promise<{joined: boolean}>} Whether the user is a member now.
 */
export async function joinClubHandler(
  request: CallableRequest<unknown>,
  deps: ClubMembershipDeps = defaultDeps
): Promise<{joined: boolean}> {
  const userId = requireAuth(request);
  const {clubId} = validateCallableWithAjv<ClubMembershipCallablePayload>(
    request,
    validateClubMembershipCallablePayload,
    normalizeClubIdPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, userId, "joinClub");

  await db.runTransaction(async (tx) => {
    const clubRef = db.collection("clubs").doc(clubId);
    const userRef = db.collection("users").doc(userId);
    const deletedUserRef = db.collection("deletedUsers").doc(userId);
    const membershipRef = db
      .collection("clubMemberships")
      .doc(clubMembershipId(clubId, userId));

    const [clubSnap, userSnap, deletedUserSnap, membershipSnap] =
      await Promise.all([
        tx.get(clubRef),
        tx.get(userRef),
        tx.get(deletedUserRef),
        tx.get(membershipRef),
      ]);

    assertCanMutateMembership(clubSnap, userSnap, deletedUserSnap);

    const club = requireDoc<ClubDoc>(clubSnap, "ClubDoc");
    const membership = membershipSnap.exists ?
      membershipSnap.data() as {status?: string} :
      null;

    const isAlreadyMember = membership?.status === "active";
    if (!isAlreadyMember) {
      tx.update(clubRef, {
        memberCount: (club.memberCount ?? 0) + 1,
      });
      tx.set(membershipRef, activeClubMembershipPatch({
        clubId,
        uid: userId,
        role: isClubOwner(club, userId) ?
          "owner" :
          isClubHost(club, userId) ? "host" : "member",
      }), {merge: true});
    }
  });

  return {joined: true};
}

/**
 * Removes the signed-in user from a club through the membership edge.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {ClubMembershipDeps} deps Injectable dependencies for tests.
 * @return {Promise<{joined: boolean}>} Whether the user is a member now.
 */
export async function leaveClubHandler(
  request: CallableRequest<unknown>,
  deps: ClubMembershipDeps = defaultDeps
): Promise<{joined: boolean}> {
  const userId = requireAuth(request);
  const {clubId} = validateCallableWithAjv<ClubMembershipCallablePayload>(
    request,
    validateClubMembershipCallablePayload,
    normalizeClubIdPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, userId, "leaveClub");

  await db.runTransaction(async (tx) => {
    const clubRef = db.collection("clubs").doc(clubId);
    const userRef = db.collection("users").doc(userId);
    const deletedUserRef = db.collection("deletedUsers").doc(userId);
    const membershipRef = db
      .collection("clubMemberships")
      .doc(clubMembershipId(clubId, userId));

    const [clubSnap, userSnap, deletedUserSnap, membershipSnap] =
      await Promise.all([
        tx.get(clubRef),
        tx.get(userRef),
        tx.get(deletedUserRef),
        tx.get(membershipRef),
      ]);

    assertCanMutateMembership(clubSnap, userSnap, deletedUserSnap);

    const club = requireDoc<ClubDoc>(clubSnap, "ClubDoc");
    if (clubOwnerUserId(club) === userId) {
      throw new HttpsError(
        "failed-precondition",
        "Owners cannot leave clubs they own."
      );
    }
    if (isClubHost(club, userId)) {
      throw new HttpsError(
        "failed-precondition",
        "Hosts must be removed from the host team before leaving."
      );
    }

    const membership = membershipSnap.exists ?
      membershipSnap.data() as {status?: string} :
      null;
    const isMember = membership?.status === "active";
    if (isMember) {
      tx.update(clubRef, {
        memberCount: Math.max(0, (club.memberCount ?? 0) - 1),
      });
    }

    tx.set(membershipRef, leftClubMembershipPatch(), {merge: true});
  });

  return {joined: false};
}

/**
 * Updates the signed-in user's per-club push notification opt-in.
 *
 * The active membership document is the ownership boundary for this setting:
 * membership means the club's updates appear in Activity, while this boolean
 * determines whether non-critical club updates also produce FCM pushes.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {ClubMembershipDeps} deps Injectable dependencies for tests.
 * @return {Promise<{enabled: boolean}>} The saved push preference.
 */
export async function setClubNotificationPreferenceHandler(
  request: CallableRequest<unknown>,
  deps: ClubMembershipDeps = defaultDeps
): Promise<{enabled: boolean}> {
  const userId = requireAuth(request);
  const {clubId, enabled} = validateCallableWithAjv<
    SetClubNotificationPreferenceCallablePayload
  >(
    request,
    validateSetClubNotificationPreferenceCallablePayload,
    normalizeClubIdPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(
    db,
    userId,
    "setClubNotificationPreference"
  );

  await db.runTransaction(async (tx) => {
    const membershipRef = db
      .collection("clubMemberships")
      .doc(clubMembershipId(clubId, userId));
    const membershipSnap = await tx.get(membershipRef);
    if (!membershipSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "Join this club before enabling notifications."
      );
    }
    const membership = membershipSnap.data();
    if (membership?.uid !== userId ||
        membership?.clubId !== clubId ||
        membership?.status !== "active") {
      throw new HttpsError(
        "failed-precondition",
        "Join this club before enabling notifications."
      );
    }
    tx.update(membershipRef, {pushNotificationsEnabled: enabled});
  });

  return {enabled};
}

/**
 * Verifies the user and club are in a state that can mutate membership.
 * @param {FirebaseFirestore.DocumentSnapshot} clubSnap Club snapshot.
 * @param {FirebaseFirestore.DocumentSnapshot} userSnap User snapshot.
 * @param {FirebaseFirestore.DocumentSnapshot} deletedUserSnap Tombstone snap.
 */
function assertCanMutateMembership(
  clubSnap: FirebaseFirestore.DocumentSnapshot,
  userSnap: FirebaseFirestore.DocumentSnapshot,
  deletedUserSnap: FirebaseFirestore.DocumentSnapshot
) {
  if (!clubSnap.exists) {
    throw new HttpsError("not-found", "Club not found.");
  }
  if (!userSnap.exists) {
    throw new HttpsError("not-found", "User profile not found.");
  }
  if (deletedUserSnap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "This account cannot join or leave clubs."
    );
  }

  const user = requireDoc<UserProfileDoc>(userSnap, "UserProfileDoc");
  if (user.profileComplete !== true) {
    throw new HttpsError(
      "failed-precondition",
      "Complete your profile before joining clubs."
    );
  }
}

export const joinClub = onCall(
  appCheckCallableOptions,
  (request) => joinClubHandler(request)
);
export const leaveClub = onCall(
  appCheckCallableOptions,
  (request) => leaveClubHandler(request)
);
export const setClubNotificationPreference = onCall(
  appCheckCallableOptions,
  (request) => setClubNotificationPreferenceHandler(request)
);
