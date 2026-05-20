import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {ClubDoc, UserProfileDoc} from "../shared/firestore";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {AddClubHostCallablePayload} from
  "../shared/generated/addClubHostCallablePayload";
import {RemoveClubHostCallablePayload} from
  "../shared/generated/removeClubHostCallablePayload";
import {
  validateAddClubHostCallablePayload,
  validateRemoveClubHostCallablePayload,
} from "../shared/generated/schemaValidators";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {
  activeClubMembershipPatch,
  clubMembershipId,
} from "../shared/relationshipDocuments";
import {
  clubHostProfiles,
  clubHostUserIds,
  ClubHostProfile,
  isClubOwner,
} from "../shared/clubHosts";
import {publicAvatarUrl, publicDisplayName} from "../shared/profileProjection";
import {normalizeClubHostPayload} from "./clubPayloadNormalization";

interface ManageClubHostsDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: ManageClubHostsDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit: defaultCheckRateLimit,
};

/**
 * Adds a completed-profile user as a co-host of an owner-managed club.
 * @param {CallableRequest<unknown>} request Callable request payload.
 * @param {ManageClubHostsDeps} deps Injectable dependencies for tests.
 * @return {Promise<{added: boolean}>} Result flag.
 */
export async function addClubHostHandler(
  request: CallableRequest<unknown>,
  deps: ManageClubHostsDeps = defaultDeps
): Promise<{added: boolean}> {
  const callerUid = requireAuth(request);
  const data = validateCallableWithAjv<AddClubHostCallablePayload>(
    request,
    validateAddClubHostCallablePayload,
    normalizeClubHostPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, callerUid, "addClubHost");

  await db.runTransaction(async (tx) => {
    const clubRef = db.collection("clubs").doc(data.clubId);
    const targetUserRef = db.collection("users").doc(data.uid);
    const callerDeletedRef = db.collection("deletedUsers").doc(callerUid);
    const targetDeletedRef = db.collection("deletedUsers").doc(data.uid);
    const membershipRef = db
      .collection("clubMemberships")
      .doc(clubMembershipId(data.clubId, data.uid));

    const [
      clubSnap,
      targetUserSnap,
      callerDeletedSnap,
      targetDeletedSnap,
    ] = await Promise.all([
      tx.get(clubRef),
      tx.get(targetUserRef),
      tx.get(callerDeletedRef),
      tx.get(targetDeletedRef),
    ]);

    assertCanManageHostTeam(clubSnap, callerDeletedSnap, callerUid);
    if (!targetUserSnap.exists) {
      throw new HttpsError("not-found", "User profile not found.");
    }
    if (targetDeletedSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "This account cannot host clubs."
      );
    }

    const club = requireDoc<ClubDoc>(clubSnap, "ClubDoc");
    const user = requireDoc<UserProfileDoc>(targetUserSnap, "UserProfileDoc");
    if (user.profileComplete !== true) {
      throw new HttpsError(
        "failed-precondition",
        "Co-hosts must complete their profile first."
      );
    }

    const hostIds = uniqueStrings([...clubHostUserIds(club), data.uid]);
    const hostProfile = hostProfileForUser(data.uid, user);
    const profiles = [
      ...clubHostProfiles(club).filter((host) => host.uid !== data.uid),
      hostProfile,
    ].sort((a, b) => hostIds.indexOf(a.uid) - hostIds.indexOf(b.uid));

    tx.update(clubRef, {
      hostUserIds: hostIds,
      hostProfiles: profiles,
    });
    tx.set(membershipRef, activeClubMembershipPatch({
      clubId: data.clubId,
      uid: data.uid,
      role: "host",
    }), {merge: true});
  });

  return {added: true};
}

/**
 * Removes a co-host from a club while preserving their member relationship.
 * @param {CallableRequest<unknown>} request Callable request payload.
 * @param {ManageClubHostsDeps} deps Injectable dependencies for tests.
 * @return {Promise<{removed: boolean}>} Result flag.
 */
export async function removeClubHostHandler(
  request: CallableRequest<unknown>,
  deps: ManageClubHostsDeps = defaultDeps
): Promise<{removed: boolean}> {
  const callerUid = requireAuth(request);
  const data = validateCallableWithAjv<RemoveClubHostCallablePayload>(
    request,
    validateRemoveClubHostCallablePayload,
    normalizeClubHostPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, callerUid, "removeClubHost");

  await db.runTransaction(async (tx) => {
    const clubRef = db.collection("clubs").doc(data.clubId);
    const callerDeletedRef = db.collection("deletedUsers").doc(callerUid);
    const membershipRef = db
      .collection("clubMemberships")
      .doc(clubMembershipId(data.clubId, data.uid));

    const [clubSnap, callerDeletedSnap] = await Promise.all([
      tx.get(clubRef),
      tx.get(callerDeletedRef),
    ]);

    assertCanManageHostTeam(clubSnap, callerDeletedSnap, callerUid);
    const club = requireDoc<ClubDoc>(clubSnap, "ClubDoc");
    if (isClubOwner(club, data.uid)) {
      throw new HttpsError(
        "failed-precondition",
        "Transfer ownership before removing the club owner."
      );
    }

    tx.update(clubRef, {
      hostUserIds: clubHostUserIds(club).filter((uid) => uid !== data.uid),
      hostProfiles: clubHostProfiles(club).filter(
        (host) => host.uid !== data.uid
      ),
    });
    tx.set(membershipRef, {
      role: "member",
      status: "active",
      leftAt: admin.firestore.FieldValue.delete(),
      deletedAt: admin.firestore.FieldValue.delete(),
    }, {merge: true});
  });

  return {removed: true};
}

/**
 * Verifies that the caller is the non-deleted owner of the target club.
 * @param {FirebaseFirestore.DocumentSnapshot} clubSnap Club document.
 * @param {FirebaseFirestore.DocumentSnapshot} callerDeletedSnap Tombstone.
 * @param {string} callerUid Authenticated caller id.
 */
function assertCanManageHostTeam(
  clubSnap: FirebaseFirestore.DocumentSnapshot,
  callerDeletedSnap: FirebaseFirestore.DocumentSnapshot,
  callerUid: string
) {
  if (callerDeletedSnap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "This account cannot manage club hosts."
    );
  }
  if (!clubSnap.exists) {
    throw new HttpsError("not-found", "Club not found.");
  }
  const club = requireDoc<ClubDoc>(clubSnap, "ClubDoc");
  if (!isClubOwner(club, callerUid)) {
    throw new HttpsError(
      "permission-denied",
      "Only the club owner can manage club hosts."
    );
  }
}

/**
 * Builds the public co-host projection stored on the club document.
 * @param {string} uid Co-host user id.
 * @param {UserProfileDoc} user Private user profile.
 * @return {ClubHostProfile} Public host profile projection.
 */
function hostProfileForUser(
  uid: string,
  user: UserProfileDoc
): ClubHostProfile {
  return {
    uid,
    displayName: publicDisplayName(user),
    avatarUrl: publicAvatarUrl(user),
    role: "host",
  };
}

/**
 * Removes empty and duplicate ids while preserving first-seen order.
 * @param {string[]} values Candidate string ids.
 * @return {string[]} Unique non-empty ids.
 */
function uniqueStrings(values: string[]): string[] {
  return [...new Set(values.filter((value) => value.length > 0))];
}

export const addClubHost = onCall(
  appCheckCallableOptions,
  (request) => addClubHostHandler(request)
);

export const removeClubHost = onCall(
  appCheckCallableOptions,
  (request) => removeClubHostHandler(request)
);
