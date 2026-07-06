import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {
  ClubDocument,
  EventDocument,
} from "../shared/generated/firestoreAdminTypes";
import {CreateClubPostCallablePayload} from
  "../shared/generated/createClubPostCallablePayload";
import {validateCreateClubPostCallablePayload} from
  "../shared/generated/schemaValidators";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {isClubHost} from "../shared/clubHosts";
import {
  activityNotificationId,
  allowsPushPreference,
  sendFcmNotification,
  setActivityNotification,
} from "../shared/notifications";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";

const weeklyQuota = 3;
const quotaWindowMs = 7 * 24 * 60 * 60 * 1000;

type ClubPostStatus = "active" | "removed";

type ClubPostQuotaDocument = {
  createdAt?: FirebaseFirestore.Timestamp;
  status?: ClubPostStatus;
};

type ClubMembershipNotificationDocument = {
  uid?: string;
  status?: string;
  pushNotificationsEnabled?: boolean;
};

type NotificationUserDocument = {
  fcmToken?: string;
  prefsClubUpdates?: boolean;
};

interface CreateClubPostDeps {
  firestore: () => FirebaseFirestore.Firestore;
  now: () => Date;
  timestampFromMillis: (millis: number) => FirebaseFirestore.Timestamp;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  sendNotification?: typeof sendFcmNotification;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: CreateClubPostDeps = {
  firestore: () => admin.firestore(),
  now: () => new Date(),
  timestampFromMillis: (millis) => admin.firestore.Timestamp.fromMillis(millis),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  sendNotification: sendFcmNotification,
  checkRateLimit: defaultCheckRateLimit,
};

type CreateClubPostResult = {
  postId: string;
  remainingWeeklyQuota: number;
};

/**
 * Creates an organizer post for followers of a hosted club.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {CreateClubPostDeps} deps Injectable dependencies for tests.
 * @return {Promise<CreateClubPostResult>} Created post id and remaining quota.
 */
export async function createClubPostHandler(
  request: CallableRequest<unknown>,
  deps: CreateClubPostDeps = defaultDeps
): Promise<CreateClubPostResult> {
  const authorUid = requireAuth(request);
  const data = validateCallableWithAjv<CreateClubPostCallablePayload>(
    request,
    validateCreateClubPostCallablePayload,
    normalizeCreateClubPostPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, authorUid, "createClubPost");

  const clubRef = db.collection("clubs").doc(data.clubId);
  const deletedUserRef = db.collection("deletedUsers").doc(authorUid);
  const postsRef = clubRef.collection("posts");
  const postRef = postsRef.doc();
  const quotaWindowStart = deps.timestampFromMillis(
    deps.now().getTime() - quotaWindowMs
  );
  let clubName = "";
  let remainingWeeklyQuota = 0;

  await db.runTransaction(async (tx) => {
    const eventRef = data.eventId ?
      db.collection("events").doc(data.eventId) :
      null;
    const recentPostsQuery = postsRef
      .where("createdAt", ">=", quotaWindowStart);
    const [
      clubSnap,
      deletedUserSnap,
      eventSnap,
      recentPostsSnap,
    ] = await Promise.all([
      tx.get(clubRef),
      tx.get(deletedUserRef),
      eventRef ? tx.get(eventRef) : Promise.resolve(null),
      tx.get(recentPostsQuery),
    ]);

    if (deletedUserSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "This account cannot create club posts."
      );
    }
    if (!clubSnap.exists) {
      throw new HttpsError("not-found", "Club not found.");
    }
    const club = requireDoc<ClubDocument>(clubSnap, "ClubDocument");
    if (!isClubHost(club, authorUid)) {
      throw new HttpsError(
        "permission-denied",
        "Only club hosts can create posts."
      );
    }
    if (data.eventId) {
      if (!eventSnap?.exists) {
        throw new HttpsError("not-found", "Linked event not found.");
      }
      const event = requireDoc<EventDocument>(eventSnap, "EventDocument");
      if (event.clubId !== data.clubId) {
        throw new HttpsError(
          "failed-precondition",
          "Linked event must belong to this club."
        );
      }
    }

    const activeRecentCount = recentPostsSnap.docs
      .map((doc) => doc.data() as ClubPostQuotaDocument)
      .filter((post) => post.status === "active")
      .length;
    if (activeRecentCount >= weeklyQuota) {
      throw new HttpsError(
        "resource-exhausted",
        "This club has used its 3 follower posts for the last 7 days."
      );
    }

    clubName = club.name;
    remainingWeeklyQuota = Math.max(0, weeklyQuota - activeRecentCount - 1);
    tx.create(postRef, {
      authorUid,
      text: data.text,
      photoPath: data.photoPath ?? null,
      eventId: data.eventId ?? null,
      audience: "followers",
      createdAt: deps.serverTimestamp(),
      status: "active",
    });
  });

  await notifyClubFollowersForPost({
    db,
    deps,
    clubId: data.clubId,
    clubName,
    authorUid,
    postId: postRef.id,
    text: data.text,
    eventId: data.eventId,
  });

  return {postId: postRef.id, remainingWeeklyQuota};
}

/**
 * Normalizes createClubPost input before schema validation.
 * @param {unknown} raw Raw callable data.
 * @return {unknown} Normalized callable data.
 */
function normalizeCreateClubPostPayload(raw: unknown): unknown {
  if (typeof raw !== "object" || raw === null || Array.isArray(raw)) {
    return raw;
  }
  const input = raw as Record<string, unknown>;
  const normalized: Record<string, unknown> = {...input};
  if (typeof input.clubId === "string") {
    normalized.clubId = input.clubId.trim();
  }
  if (typeof input.text === "string") {
    normalized.text = input.text.trim();
  }
  if (typeof input.photoPath === "string") {
    const value = input.photoPath.trim();
    if (value.length > 0) normalized.photoPath = value;
    else delete normalized.photoPath;
  }
  if (typeof input.eventId === "string") {
    const value = input.eventId.trim();
    if (value.length > 0) normalized.eventId = value;
    else delete normalized.eventId;
  }
  return normalized;
}

/**
 * Fans out a club-post activity item to active followers.
 *
 * This is best-effort after the canonical post commits so a notification
 * delivery issue does not make the host lose the post they just wrote.
 * @param {object} params Fan-out parameters.
 */
async function notifyClubFollowersForPost(params: {
  db: FirebaseFirestore.Firestore;
  deps: CreateClubPostDeps;
  clubId: string;
  clubName: string;
  authorUid: string;
  postId: string;
  text: string;
  eventId?: string;
}): Promise<void> {
  try {
    const members = await params.db
      .collection("clubMemberships")
      .where("clubId", "==", params.clubId)
      .where("status", "==", "active")
      .get();
    const followers = members.docs
      .map((doc) => doc.data() as ClubMembershipNotificationDocument)
      .filter((membership): membership is
        Required<Pick<ClubMembershipNotificationDocument, "uid">> &
        ClubMembershipNotificationDocument =>
        typeof membership.uid === "string" &&
        membership.uid !== params.authorUid
      );
    if (followers.length === 0) return;

    const userSnaps = await Promise.all(
      followers.map((membership) =>
        params.db.collection("users").doc(membership.uid).get()
      )
    );
    const title = `New update from ${params.clubName}`;
    const body = params.text;

    await Promise.all(userSnaps.map(async (snap, index) => {
      const membership = followers[index];
      const uid = membership.uid;
      const user = snap.data() as NotificationUserDocument | undefined;
      if (!user) return;
      await setActivityNotification(params.db, {
        id: activityNotificationId("clubUpdate", params.postId),
        uid,
        type: "clubUpdate",
        title,
        body,
        createdAt: params.deps.serverTimestamp(),
        eventId: params.eventId,
        clubId: params.clubId,
        postId: params.postId,
        actorUid: params.authorUid,
        actorName: params.clubName,
      });
      if (
        membership.pushNotificationsEnabled === true &&
        user.fcmToken &&
        allowsPushPreference(user, "clubUpdates")
      ) {
        await params.deps.sendNotification?.({
          token: user.fcmToken,
          title,
          body,
          type: "clubUpdate",
          eventId: params.eventId,
          clubId: params.clubId,
          postId: params.postId,
        });
      }
    }));
  } catch (error) {
    logger.error("Failed to fan out club post notifications", {
      clubId: params.clubId,
      postId: params.postId,
      error,
    });
  }
}

export const createClubPost = onCall(
  appCheckCallableOptions,
  (request) => createClubPostHandler(request)
);
