import * as admin from "firebase-admin";
import {
  EventDocument,
} from "./generated/firestoreAdminTypes";

export interface FcmParams {
  token: string;
  title: string;
  body: string;
  type: string;
  matchId?: string;
  eventId?: string;
  clubId?: string;
  postId?: string;
}

export type ActivityNotificationType =
  | "message"
  | "match"
  | "eventReminder"
  | "eventSignup"
  | "waitlistPromotion"
  | "waitlistOffer"
  | "waitlistOfferExpiring"
  | "waitlistOfferExpired"
  | "eventCancelled"
  | "eventUpdated"
  | "clubUpdate";

export interface ActivityNotificationParams {
  id: string;
  uid: string;
  type: ActivityNotificationType;
  title: string;
  body: string;
  createdAt: FirebaseFirestore.Timestamp | FirebaseFirestore.FieldValue;
  matchId?: string;
  eventId?: string;
  clubId?: string;
  postId?: string;
  actorUid?: string;
  actorName?: string;
  demoOps?: boolean;
  demoOpsId?: string;
  demoOpsCommand?: string;
  seedPrefix?: string;
  synthetic?: boolean;
}

export type NotificationPreference =
  | "matches"
  | "messages"
  | "eventReminders"
  | "eventStatusUpdates"
  | "clubUpdates";

export interface NotificationPreferenceDocument {
  prefsNewCatches?: boolean;
  prefsMessages?: boolean;
  prefsEventReminders?: boolean;
  prefsRunStatusUpdates?: boolean;
  prefsClubUpdates?: boolean;
}

/**
 * Returns whether a user-level notification category permits push delivery.
 *
 * Durable in-app activity is controlled by the producer; this helper only
 * gates FCM delivery. Missing fields default to true so existing beta profiles
 * continue receiving expected notifications until their settings are saved.
 * @param {NotificationPreferenceDocument | undefined} user User preference doc.
 * @param {NotificationPreference} preference Notification category.
 * @return {boolean} Whether FCM delivery is enabled.
 */
export function allowsPushPreference(
  user: NotificationPreferenceDocument | undefined,
  preference: NotificationPreference
): boolean {
  if (!user) return false;
  switch (preference) {
  case "matches":
    return user.prefsNewCatches !== false;
  case "messages":
    return user.prefsMessages !== false;
  case "eventReminders":
    return user.prefsEventReminders !== false;
  case "eventStatusUpdates":
    return user.prefsRunStatusUpdates !== false;
  case "clubUpdates":
    return user.prefsClubUpdates !== false;
  }
}

/**
 * Sends a single FCM notification with the shared APNs / Android sound config.
 * @param {FcmParams} params The notification parameters.
 * @return {Promise<void>}
 */
export async function sendFcmNotification(params: FcmParams): Promise<void> {
  await admin.messaging().send({
    token: params.token,
    notification: {title: params.title, body: params.body},
    data: compactStringMap({
      type: params.type,
      matchId: params.matchId,
      eventId: params.eventId,
      clubId: params.clubId,
      postId: params.postId,
    }),
    apns: {payload: {aps: {sound: "default"}}},
    android: {notification: {sound: "default"}},
  });
}

/**
 * Builds a deterministic notification id for a user-scoped notification.
 * @param {ActivityNotificationType} type Notification type.
 * @param {string} sourceId Stable source event/doc id.
 * @return {string} Deterministic notification document id.
 */
export function activityNotificationId(
  type: ActivityNotificationType,
  sourceId: string
): string {
  return `${type}_${sourceId}`;
}

/**
 * Writes a server-owned in-app notification inside an existing transaction.
 * @param {FirebaseFirestore.Transaction} tx Firestore transaction.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {ActivityNotificationParams} params Notification payload.
 */
export function setActivityNotificationInTransaction(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  params: ActivityNotificationParams
): void {
  tx.set(activityNotificationRef(db, params.uid, params.id), {
    ...activityNotificationData(params),
    readAt: null,
  }, {merge: true});
}

/**
 * Writes a server-owned in-app notification outside a transaction.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {ActivityNotificationParams} params Notification payload.
 * @return {Promise<void>} Resolves after the notification doc is written.
 */
export async function setActivityNotification(
  db: FirebaseFirestore.Firestore,
  params: ActivityNotificationParams
): Promise<void> {
  await activityNotificationRef(db, params.uid, params.id).set({
    ...activityNotificationData(params),
    readAt: null,
  }, {merge: true});
}

/**
 * Creates a server-owned in-app notification only if it does not already exist.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {ActivityNotificationParams} params Notification payload.
 * @return {Promise<boolean>} True when a new notification was created.
 */
export async function createActivityNotificationIfAbsent(
  db: FirebaseFirestore.Firestore,
  params: ActivityNotificationParams
): Promise<boolean> {
  const ref = activityNotificationRef(db, params.uid, params.id);
  let created = false;
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (snap.exists) return;
    tx.create(ref, {
      ...activityNotificationData(params),
      readAt: null,
    });
    created = true;
  });
  return created;
}

export type ActiveUserActivityCreationResult =
  | "created"
  | "existing"
  | "recipient-deleted";

/**
 * Creates Activity only while the recipient account is still active. The
 * deletion tombstone and user projection are read in the same transaction as
 * the notification create, closing the cleanup-versus-delivery race.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {ActivityNotificationParams} params Notification payload.
 * @return {Promise<ActiveUserActivityCreationResult>} Creation outcome.
 */
export async function createActivityForActiveUserIfAbsent(
  db: FirebaseFirestore.Firestore,
  params: ActivityNotificationParams
): Promise<ActiveUserActivityCreationResult> {
  const ref = activityNotificationRef(db, params.uid, params.id);
  const userRef = db.collection("users").doc(params.uid);
  const deletedRef = db.collection("deletedUsers").doc(params.uid);
  return db.runTransaction(async (tx) => {
    const [snap, userSnap, deletedSnap] = await Promise.all([
      tx.get(ref),
      tx.get(userRef),
      tx.get(deletedRef),
    ]);
    if (deletedSnap.exists || userSnap.data()?.deleted === true) {
      return "recipient-deleted";
    }
    if (snap.exists) return "existing";
    tx.create(ref, {
      ...activityNotificationData(params),
      readAt: null,
    });
    return "created";
  });
}

/**
 * Builds user-facing copy for event participation notifications.
 * @param {ActivityNotificationType} type Notification type.
 * @param {EventDocument} event Event document that caused the notification.
 * @return {{title: string, body: string}} Title and body copy.
 */
export function eventActivityNotificationCopy(
  type: ActivityNotificationType,
  event: EventDocument
): {title: string; body: string} {
  const eventLabel = `${formatDistance(event.distanceKm)} event`;
  const locationName = event.meetingLocation?.name ?? event.meetingPoint;
  switch (type) {
  case "eventReminder":
    return {
      title: "Your event starts soon",
      body: `Your ${eventLabel} from ${locationName} starts in about ` +
        "15 minutes.",
    };
  case "eventSignup":
    return {
      title: "You're booked",
      body: `Your ${eventLabel} from ${locationName} is confirmed.`,
    };
  case "waitlistPromotion":
    return {
      title: "You're in",
      body: `A spot opened for your ${eventLabel} from ${locationName}.`,
    };
  case "waitlistOffer":
    return {
      title: "A spot is available",
      body: `You have a limited-time spot for your ${eventLabel} from ` +
        `${locationName}.`,
    };
  case "waitlistOfferExpiring":
    return {
      title: "Your spot is expiring",
      body: `Confirm your ${eventLabel} from ${locationName} soon to keep ` +
        "the spot.",
    };
  case "waitlistOfferExpired":
    return {
      title: "Spot offer expired",
      body: `Your spot offer for the ${eventLabel} from ${locationName} ` +
        "has expired.",
    };
  case "eventUpdated":
    return {
      title: "Event details changed",
      body: `Check the latest time and meeting point for your ${eventLabel}.`,
    };
  case "eventCancelled":
    return {
      title: "Event cancelled",
      body: `Your ${eventLabel} from ${locationName} has been cancelled.`,
    };
  default:
    return {
      title: "Event update",
      body: `There is an update for your ${eventLabel} from ` +
        `${locationName}.`,
    };
  }
}

/**
 * Builds user-facing copy for the companion-ready push notification.
 * @param {EventDocument} event Event whose live companion is ready.
 * @return {object} Title and body copy.
 */
export function eventCompanionReadyNotificationCopy(
  event: EventDocument
): {title: string; body: string} {
  const eventLabel = `${formatDistance(event.distanceKm)} event`;
  const locationName = event.meetingLocation?.name ?? event.meetingPoint;
  return {
    title: "Your event companion is ready",
    body: `Open the live guide for your ${eventLabel} from ${locationName}.`,
  };
}

/**
 * Returns the user-scoped notification document reference.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} uid Notification owner UID.
 * @param {string} id Notification document ID.
 * @return {FirebaseFirestore.DocumentReference} Notification doc reference.
 */
function activityNotificationRef(
  db: FirebaseFirestore.Firestore,
  uid: string,
  id: string
): FirebaseFirestore.DocumentReference {
  return db.collection("notifications").doc(uid).collection("items").doc(id);
}

/**
 * Builds the Firestore payload for a durable in-app notification.
 * @param {ActivityNotificationParams} params Notification payload.
 * @return {Record<string, unknown>} Firestore-safe notification data.
 */
function activityNotificationData(
  params: ActivityNotificationParams
): Record<string, unknown> {
  return {
    uid: params.uid,
    type: params.type,
    title: params.title,
    body: params.body,
    createdAt: params.createdAt,
    ...compactStringMap({
      matchId: params.matchId,
      eventId: params.eventId,
      clubId: params.clubId,
      postId: params.postId,
      actorUid: params.actorUid,
      actorName: params.actorName,
      demoOpsId: params.demoOpsId,
      demoOpsCommand: params.demoOpsCommand,
      seedPrefix: params.seedPrefix,
    }),
    ...compactBooleanMap({
      demoOps: params.demoOps,
      synthetic: params.synthetic,
    }),
  };
}

/**
 * Removes undefined optional string values before writing FCM/Firestore data.
 * @param {Record<string, string | undefined>} value Raw string map.
 * @return {Record<string, string>} Map containing only non-empty strings.
 */
function compactStringMap(
  value: Record<string, string | undefined>
): Record<string, string> {
  return Object.fromEntries(
    Object.entries(value).filter((entry): entry is [string, string] =>
      typeof entry[1] === "string" && entry[1].length > 0
    )
  );
}

/**
 * Removes undefined optional boolean values before writing Firestore data.
 * @param {Record<string, boolean | undefined>} value Raw boolean map.
 * @return {Record<string, boolean>} Map containing only booleans.
 */
function compactBooleanMap(
  value: Record<string, boolean | undefined>
): Record<string, boolean> {
  return Object.fromEntries(
    Object.entries(value).filter((entry): entry is [string, boolean] =>
      typeof entry[1] === "boolean"
    )
  );
}

/**
 * Formats a distance without noisy trailing decimals.
 * @param {number} distanceKm Distance in kilometres.
 * @return {string} Human-readable distance.
 */
function formatDistance(distanceKm: number): string {
  return Number.isInteger(distanceKm) ?
    `${distanceKm} km` :
    `${distanceKm.toFixed(1)} km`;
}
