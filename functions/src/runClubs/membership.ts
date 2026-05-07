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

const RunClubNotificationPreferenceSchema = z.object({
  clubId: z.string().min(1),
  enabled: z.boolean(),
});

interface RunClubMembershipDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: RunClubMembershipDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit: defaultCheckRateLimit,
};

/**
 * Adds the signed-in user to a run club through the membership edge document.
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

    const [clubSnap, userSnap, deletedUserSnap, membershipSnap] =
      await Promise.all([
        tx.get(clubRef),
        tx.get(userRef),
        tx.get(deletedUserRef),
        tx.get(membershipRef),
      ]);

    assertCanMutateMembership(clubSnap, userSnap, deletedUserSnap);

    const club = requireDoc<RunClubDoc>(clubSnap, "RunClubDoc");
    const membership = membershipSnap.exists ?
      membershipSnap.data() as {status?: string} :
      null;

    const isAlreadyMember = membership?.status === "active";
    if (!isAlreadyMember) {
      tx.update(clubRef, {
        memberCount: (club.memberCount ?? 0) + 1,
      });
      tx.set(membershipRef, activeRunClubMembershipPatch({
        clubId,
        uid: userId,
        role: club.hostUserId === userId ? "host" : "member",
      }), {merge: true});
    }
  });

  return {joined: true};
}

/**
 * Removes the signed-in user from a run club through the membership edge.
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

    const [clubSnap, userSnap, deletedUserSnap, membershipSnap] =
      await Promise.all([
        tx.get(clubRef),
        tx.get(userRef),
        tx.get(deletedUserRef),
        tx.get(membershipRef),
      ]);

    assertCanMutateMembership(clubSnap, userSnap, deletedUserSnap);

    const club = requireDoc<RunClubDoc>(clubSnap, "RunClubDoc");
    if (club.hostUserId === userId) {
      throw new HttpsError(
        "failed-precondition",
        "Hosts cannot leave clubs they own."
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

    tx.set(membershipRef, leftRunClubMembershipPatch(), {merge: true});
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
 * @param {RunClubMembershipDeps} deps Injectable dependencies for tests.
 * @return {Promise<{enabled: boolean}>} The saved push preference.
 */
export async function setRunClubNotificationPreferenceHandler(
  request: CallableRequest<unknown>,
  deps: RunClubMembershipDeps = defaultDeps
): Promise<{enabled: boolean}> {
  const userId = requireAuth(request);
  const {clubId, enabled} = validateCallable(
    request,
    RunClubNotificationPreferenceSchema
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(
    db,
    userId,
    "setRunClubNotificationPreference"
  );

  await db.runTransaction(async (tx) => {
    const membershipRef = db
      .collection("runClubMemberships")
      .doc(runClubMembershipId(clubId, userId));
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

export const joinRunClub = onCall(
  appCheckCallableOptions,
  (request) => joinRunClubHandler(request)
);
export const leaveRunClub = onCall(
  appCheckCallableOptions,
  (request) => leaveRunClubHandler(request)
);
export const setRunClubNotificationPreference = onCall(
  appCheckCallableOptions,
  (request) => setRunClubNotificationPreferenceHandler(request)
);
