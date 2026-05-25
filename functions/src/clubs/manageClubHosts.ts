import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {ClubDoc, UserProfileDoc} from "../shared/generated/firestoreAdminTypes";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {AddClubHostCallablePayload} from
  "../shared/generated/addClubHostCallablePayload";
import {RemoveClubHostCallablePayload} from
  "../shared/generated/removeClubHostCallablePayload";
import {TransferClubOwnershipCallablePayload} from
  "../shared/generated/transferClubOwnershipCallablePayload";
import {
  validateAddClubHostCallablePayload,
  validateRemoveClubHostCallablePayload,
  validateTransferClubOwnershipCallablePayload,
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
  const targetUid = await resolveTargetHostUid(db, data);

  await db.runTransaction(async (tx) => {
    const clubRef = db.collection("clubs").doc(data.clubId);
    const targetUserRef = db.collection("users").doc(targetUid);
    const callerDeletedRef = db.collection("deletedUsers").doc(callerUid);
    const targetDeletedRef = db.collection("deletedUsers").doc(targetUid);
    const membershipRef = db
      .collection("clubMemberships")
      .doc(clubMembershipId(data.clubId, targetUid));

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

    const hostIds = uniqueStrings([...clubHostUserIds(club), targetUid]);
    const hostProfile = hostProfileForUser(targetUid, user);
    const profiles = [
      ...clubHostProfiles(club).filter((host) => host.uid !== targetUid),
      hostProfile,
    ].sort((a, b) => hostIds.indexOf(a.uid) - hostIds.indexOf(b.uid));

    tx.update(clubRef, {
      hostUserIds: hostIds,
      hostProfiles: profiles,
    });
    tx.set(membershipRef, activeClubMembershipPatch({
      clubId: data.clubId,
      uid: targetUid,
      role: "host",
    }), {merge: true});
  });

  return {added: true};
}

/**
 * Transfers club ownership to an existing co-host.
 * @param {CallableRequest<unknown>} request Callable request payload.
 * @param {ManageClubHostsDeps} deps Injectable dependencies for tests.
 * @return {Promise<{transferred: boolean}>} Result flag.
 */
export async function transferClubOwnershipHandler(
  request: CallableRequest<unknown>,
  deps: ManageClubHostsDeps = defaultDeps
): Promise<{transferred: boolean}> {
  const callerUid = requireAuth(request);
  const data = validateCallableWithAjv<TransferClubOwnershipCallablePayload>(
    request,
    validateTransferClubOwnershipCallablePayload,
    normalizeClubHostPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, callerUid, "transferClubOwnership");

  await db.runTransaction(async (tx) => {
    const clubRef = db.collection("clubs").doc(data.clubId);
    const targetUserRef = db.collection("users").doc(data.uid);
    const callerDeletedRef = db.collection("deletedUsers").doc(callerUid);
    const targetDeletedRef = db.collection("deletedUsers").doc(data.uid);
    const previousClaimRef = db.collection("clubHostClaims").doc(callerUid);
    const nextClaimRef = db.collection("clubHostClaims").doc(data.uid);
    const previousMembershipRef = db
      .collection("clubMemberships")
      .doc(clubMembershipId(data.clubId, callerUid));
    const nextMembershipRef = db
      .collection("clubMemberships")
      .doc(clubMembershipId(data.clubId, data.uid));

    const [
      clubSnap,
      targetUserSnap,
      callerDeletedSnap,
      targetDeletedSnap,
      nextClaimSnap,
    ] = await Promise.all([
      tx.get(clubRef),
      tx.get(targetUserRef),
      tx.get(callerDeletedRef),
      tx.get(targetDeletedRef),
      tx.get(nextClaimRef),
    ]);

    assertCanManageHostTeam(clubSnap, callerDeletedSnap, callerUid);
    if (callerUid === data.uid) return;
    if (!targetUserSnap.exists) {
      throw new HttpsError("not-found", "User profile not found.");
    }
    if (targetDeletedSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "This account cannot own clubs."
      );
    }
    if (nextClaimSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "This account already owns a club."
      );
    }

    const club = requireDoc<ClubDoc>(clubSnap, "ClubDoc");
    if (!clubHostUserIds(club).includes(data.uid)) {
      throw new HttpsError(
        "failed-precondition",
        "Ownership can be transferred only to an existing co-host."
      );
    }
    const targetUser = requireDoc<UserProfileDoc>(
      targetUserSnap,
      "UserProfileDoc"
    );
    const targetProfile = hostProfileForUser(data.uid, targetUser);
    const profiles = clubHostProfiles(club).map((host) => {
      if (host.uid === callerUid) return {...host, role: "host" as const};
      if (host.uid === data.uid) return {...targetProfile, role: "owner"};
      return host;
    });
    const hostIds = uniqueStrings([
      data.uid,
      callerUid,
      ...clubHostUserIds(club),
    ]);

    tx.update(clubRef, {
      ownerUserId: data.uid,
      hostUserId: data.uid,
      hostName: targetProfile.displayName,
      hostAvatarUrl: targetProfile.avatarUrl,
      hostUserIds: hostIds,
      hostProfiles: profiles.sort(
        (a, b) => hostIds.indexOf(a.uid) - hostIds.indexOf(b.uid)
      ),
    });
    tx.delete(previousClaimRef);
    tx.set(nextClaimRef, {uid: data.uid, clubId: data.clubId});
    tx.set(previousMembershipRef, {
      role: "host",
      status: "active",
      leftAt: admin.firestore.FieldValue.delete(),
      deletedAt: admin.firestore.FieldValue.delete(),
    }, {merge: true});
    tx.set(nextMembershipRef, activeClubMembershipPatch({
      clubId: data.clubId,
      uid: data.uid,
      role: "owner",
    }), {merge: true});
  });

  return {transferred: true};
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
 * Resolves a host target from explicit uid or a profile phone number.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {AddClubHostCallablePayload} data Validated callable payload.
 * @return {Promise<string>} Target user id.
 */
async function resolveTargetHostUid(
  db: FirebaseFirestore.Firestore,
  data: AddClubHostCallablePayload
): Promise<string> {
  if (typeof data.uid === "string" && data.uid.length > 0) {
    return data.uid;
  }
  const phoneNumber = normalizePhoneNumber(data.phoneNumber);
  if (!phoneNumber) {
    throw new HttpsError(
      "invalid-argument",
      "Provide a co-host user id or phone number."
    );
  }
  const snap = await db
    .collection("users")
    .where("phoneNumber", "==", phoneNumber)
    .limit(2)
    .get();
  if (snap.empty) {
    throw new HttpsError("not-found", "No Catch profile uses that phone.");
  }
  if (snap.docs.length > 1) {
    throw new HttpsError(
      "failed-precondition",
      "More than one profile uses that phone."
    );
  }
  return snap.docs[0].id;
}

/**
 * Normalizes owner-entered Indian phone input to the stored E.164-ish shape.
 * @param {unknown} value Raw phone value.
 * @return {string|null} Normalized phone.
 */
function normalizePhoneNumber(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const normalized = value.replace(/[^\d+]/g, "");
  if (normalized.length === 0) return null;
  if (normalized.startsWith("+")) return normalized;
  const withoutLeadingZero = normalized.replace(/^0+/, "");
  if (withoutLeadingZero.length === 10) return `+91${withoutLeadingZero}`;
  return withoutLeadingZero;
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

export const transferClubOwnership = onCall(
  appCheckCallableOptions,
  (request) => transferClubOwnershipHandler(request)
);
