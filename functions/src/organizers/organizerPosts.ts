import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {
  EventDocument,
  OrganizerDocument,
} from "../shared/generated/firestoreAdminTypes";
import {CreateOrganizerPostCallablePayload} from
  "../shared/generated/createOrganizerPostCallablePayload";
import {CreateOrganizerPostCallableResponse} from
  "../shared/generated/createOrganizerPostCallableResponse";
import {validateCreateOrganizerPostCallablePayload} from
  "../shared/generated/schemaValidators";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {isOrganizerManager} from "../shared/organizerHosts";
import {
  activityNotificationId,
  allowsPushPreference,
  sendFcmNotification,
  setActivityNotification,
} from "../shared/notifications";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";

const weeklyQuota = 3;
const quotaWindowMs = 7 * 24 * 60 * 60 * 1000;

interface CreateOrganizerPostDeps {
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

const defaultDeps: CreateOrganizerPostDeps = {
  firestore: () => admin.firestore(),
  now: () => new Date(),
  timestampFromMillis: (millis) => admin.firestore.Timestamp.fromMillis(millis),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  sendNotification: sendFcmNotification,
  checkRateLimit: defaultCheckRateLimit,
};

export async function createOrganizerPostHandler(
  request: CallableRequest<unknown>,
  deps: CreateOrganizerPostDeps = defaultDeps
): Promise<CreateOrganizerPostCallableResponse> {
  const authorUid = requireAuth(request);
  const data = validateCallableWithAjv<CreateOrganizerPostCallablePayload>(
    request,
    validateCreateOrganizerPostCallablePayload,
    normalizeCreateOrganizerPostPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, authorUid, "createOrganizerPost");
  const organizerRef = db.collection("organizers").doc(data.organizerId);
  const legacyClubRef = db.collection("clubs").doc(data.organizerId);
  const postsRef = organizerRef.collection("posts");
  const postRef = postsRef.doc();
  const legacyPostRef = legacyClubRef.collection("posts").doc(postRef.id);
  const quotaWindowStart = deps.timestampFromMillis(
    deps.now().getTime() - quotaWindowMs
  );
  let organizerName = "";
  let remainingWeeklyQuota = 0;

  await db.runTransaction(async (tx) => {
    const eventRef = data.eventId ?
      db.collection("events").doc(data.eventId) : null;
    const [
      organizerSnap,
      legacyClubSnap,
      deletedUserSnap,
      eventSnap,
      postsSnap,
    ] = await Promise.all([
      tx.get(organizerRef),
      tx.get(legacyClubRef),
      tx.get(db.collection("deletedUsers").doc(authorUid)),
      eventRef ? tx.get(eventRef) : Promise.resolve(null),
      tx.get(postsRef.where("createdAt", ">=", quotaWindowStart)),
    ]);
    if (deletedUserSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "This account cannot create organizer posts."
      );
    }
    if (!organizerSnap.exists) {
      throw new HttpsError("not-found", "Organizer not found.");
    }
    const organizer = requireDoc<OrganizerDocument>(
      organizerSnap,
      "OrganizerDocument"
    );
    if (!isOrganizerManager(organizer, authorUid)) {
      throw new HttpsError(
        "permission-denied",
        "Only organizer owners and managers can create posts."
      );
    }
    if (data.eventId) {
      if (!eventSnap?.exists) {
        throw new HttpsError("not-found", "Linked event not found.");
      }
      const event = requireDoc<EventDocument>(eventSnap, "EventDocument");
      if ((event.organizerId ?? event.clubId) !== data.organizerId) {
        throw new HttpsError(
          "failed-precondition",
          "Linked event must belong to this organizer."
        );
      }
    }
    const activeCount = postsSnap.docs
      .filter((doc) => doc.data().status === "active").length;
    if (activeCount >= weeklyQuota) {
      throw new HttpsError(
        "resource-exhausted",
        "This organizer has used its 3 follower posts for the last 7 days."
      );
    }
    organizerName = organizer.name;
    remainingWeeklyQuota = Math.max(0, weeklyQuota - activeCount - 1);
    const post = {
      authorUid,
      text: data.text,
      photoPath: data.photoPath ?? null,
      eventId: data.eventId ?? null,
      audience: "followers",
      createdAt: deps.serverTimestamp(),
      status: "active",
    };
    tx.create(postRef, post);
    if (legacyClubSnap.exists) tx.create(legacyPostRef, post);
  });

  await notifyOrganizerFollowers({
    db,
    deps,
    organizerId: data.organizerId,
    organizerName,
    authorUid,
    postId: postRef.id,
    text: data.text,
    eventId: data.eventId,
  });
  return {postId: postRef.id, remainingWeeklyQuota};
}

function normalizeCreateOrganizerPostPayload(raw: unknown): unknown {
  if (typeof raw !== "object" || raw === null || Array.isArray(raw)) return raw;
  const input = raw as Record<string, unknown>;
  const normalized = {...input};
  for (const field of ["organizerId", "text", "photoPath", "eventId"]) {
    if (typeof normalized[field] === "string") {
      normalized[field] = normalized[field].trim();
      if ((field === "photoPath" || field === "eventId") &&
          normalized[field] === "") {
        delete normalized[field];
      }
    }
  }
  return normalized;
}

async function notifyOrganizerFollowers(params: {
  db: FirebaseFirestore.Firestore;
  deps: CreateOrganizerPostDeps;
  organizerId: string;
  organizerName: string;
  authorUid: string;
  postId: string;
  text: string;
  eventId?: string;
}): Promise<void> {
  try {
    const follows = await params.db.collection("organizerFollows")
      .where("organizerId", "==", params.organizerId)
      .where("status", "==", "active").get();
    const followers = follows.docs.map((doc) => doc.data() as {
      uid?: string;
      pushNotificationsEnabled?: boolean;
    }).filter(
      (follow): follow is {
        uid: string;
        pushNotificationsEnabled?: boolean;
      } => typeof follow.uid === "string" && follow.uid !== params.authorUid
    );
    const userSnaps = await Promise.all(followers.map((follow) =>
      params.db.collection("users").doc(follow.uid).get()
    ));
    const title = `New update from ${params.organizerName}`;
    await Promise.all(userSnaps.map(async (snap, index) => {
      const follow = followers[index];
      const user = snap.data() as {
        fcmToken?: string;
        prefsClubUpdates?: boolean;
      } | undefined;
      if (!user) return;
      await setActivityNotification(params.db, {
        id: activityNotificationId("organizerUpdate", params.postId),
        uid: follow.uid,
        type: "organizerUpdate",
        title,
        body: params.text,
        createdAt: params.deps.serverTimestamp(),
        eventId: params.eventId,
        organizerId: params.organizerId,
        postId: params.postId,
        actorUid: params.authorUid,
        actorName: params.organizerName,
      });
      if (follow.pushNotificationsEnabled === true && user.fcmToken &&
          allowsPushPreference(user, "clubUpdates")) {
        await params.deps.sendNotification?.({
          token: user.fcmToken,
          title,
          body: params.text,
          type: "organizerUpdate",
          eventId: params.eventId,
          organizerId: params.organizerId,
          postId: params.postId,
        });
      }
    }));
  } catch (error) {
    logger.error("Failed to fan out organizer post notifications", {
      organizerId: params.organizerId,
      postId: params.postId,
      error,
    });
  }
}

export const createOrganizerPost = onCall(
  appCheckCallableOptions,
  (request) => createOrganizerPostHandler(request)
);
