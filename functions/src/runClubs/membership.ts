import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {z} from "zod";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {RunClubDoc, UserProfileDoc} from "../shared/firestore";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {requireDoc, validateCallable} from "../shared/validation";
import {
  activeRunClubMembershipPatch,
  leftRunClubMembershipPatch,
  runClubMembershipId,
} from "../shared/relationshipDocuments";

const RunClubMembershipSchema = z.object({
  clubId: z.string().min(1),
});

interface RunClubMembershipDeps {
  firestore: () => FirebaseFirestore.Firestore;
  arrayUnion: (value: string) => FirebaseFirestore.FieldValue;
  arrayRemove: (value: string) => FirebaseFirestore.FieldValue;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: RunClubMembershipDeps = {
  firestore: () => admin.firestore(),
  arrayUnion: (value) => admin.firestore.FieldValue.arrayUnion(value),
  arrayRemove: (value) => admin.firestore.FieldValue.arrayRemove(value),
  checkRateLimit: defaultCheckRateLimit,
};

/**
 * Adds the signed-in user to a run club and mirrors the membership onto the
 * user's profile document.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {RunClubMembershipDeps} deps Injectable dependencies for tests.
 * @return {Promise<{joined: boolean}>} Whether the user is a member now.
 */
export async function joinRunClubHandler(
  request: CallableRequest<unknown>,
  deps: RunClubMembershipDeps = defaultDeps
): Promise<{joined: boolean}> {
  const userId = requireAuth(request);
  const {clubId} = validateCallable(request, RunClubMembershipSchema);
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, userId, "joinRunClub");

  await db.runTransaction(async (tx) => {
    const clubRef = db.collection("runClubs").doc(clubId);
    const userRef = db.collection("users").doc(userId);
    const deletedUserRef = db.collection("deletedUsers").doc(userId);
    const membershipRef = db
      .collection("runClubMemberships")
      .doc(runClubMembershipId(clubId, userId));

    const [clubSnap, userSnap, deletedUserSnap] = await Promise.all([
      tx.get(clubRef),
      tx.get(userRef),
      tx.get(deletedUserRef),
    ]);

    assertCanMutateMembership(clubSnap, userSnap, deletedUserSnap);

    const club = requireDoc<RunClubDoc>(clubSnap, "RunClubDoc");
    const nextMemberIds = uniqueStrings([...club.memberUserIds, userId]);

    const isAlreadyMember = club.memberUserIds.includes(userId);
    if (!isAlreadyMember || club.memberCount !== nextMemberIds.length) {
      tx.update(clubRef, {
        ...(!isAlreadyMember && {memberUserIds: deps.arrayUnion(userId)}),
        memberCount: nextMemberIds.length,
      });
    }

    tx.set(userRef, {
      joinedRunClubIds: deps.arrayUnion(clubId),
    }, {merge: true});
    tx.set(membershipRef, activeRunClubMembershipPatch({
      clubId,
      uid: userId,
      role: club.hostUserId === userId ? "host" : "member",
    }), {merge: true});
  });

  return {joined: true};
}

/**
 * Removes the signed-in user from a run club and mirrors the removal onto the
 * user's profile document.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {RunClubMembershipDeps} deps Injectable dependencies for tests.
 * @return {Promise<{joined: boolean}>} Whether the user is a member now.
 */
export async function leaveRunClubHandler(
  request: CallableRequest<unknown>,
  deps: RunClubMembershipDeps = defaultDeps
): Promise<{joined: boolean}> {
  const userId = requireAuth(request);
  const {clubId} = validateCallable(request, RunClubMembershipSchema);
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, userId, "leaveRunClub");

  await db.runTransaction(async (tx) => {
    const clubRef = db.collection("runClubs").doc(clubId);
    const userRef = db.collection("users").doc(userId);
    const deletedUserRef = db.collection("deletedUsers").doc(userId);
    const membershipRef = db
      .collection("runClubMemberships")
      .doc(runClubMembershipId(clubId, userId));

    const [clubSnap, userSnap, deletedUserSnap] = await Promise.all([
      tx.get(clubRef),
      tx.get(userRef),
      tx.get(deletedUserRef),
    ]);

    assertCanMutateMembership(clubSnap, userSnap, deletedUserSnap);

    const club = requireDoc<RunClubDoc>(clubSnap, "RunClubDoc");
    if (club.hostUserId === userId) {
      throw new HttpsError(
        "failed-precondition",
        "Hosts cannot leave clubs they own."
      );
    }

    const nextMemberIds = club.memberUserIds.filter((id) => id !== userId);

    const isMember = club.memberUserIds.includes(userId);
    if (isMember || club.memberCount !== nextMemberIds.length) {
      tx.update(clubRef, {
        ...(isMember && {memberUserIds: deps.arrayRemove(userId)}),
        memberCount: nextMemberIds.length,
      });
    }

    tx.update(userRef, {
      joinedRunClubIds: deps.arrayRemove(clubId),
    });
    tx.set(membershipRef, leftRunClubMembershipPatch(), {merge: true});
  });

  return {joined: false};
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
    throw new HttpsError("not-found", "Run club not found.");
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

/**
 * Returns unique strings while preserving first-seen order.
 * @param {string[]} values Input values.
 * @return {string[]} Unique values.
 */
function uniqueStrings(values: string[]): string[] {
  return [...new Set(values)];
}

export const joinRunClub = onCall(
  appCheckCallableOptions,
  (request) => joinRunClubHandler(request)
);
export const leaveRunClub = onCall(
  appCheckCallableOptions,
  (request) => leaveRunClubHandler(request)
);
