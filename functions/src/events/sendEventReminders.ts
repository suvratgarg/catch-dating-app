import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {
  EventDocument,
  EventParticipationDocument,
  UserProfileDocument,
} from "../shared/generated/firestoreAdminTypes";
import {
  activityNotificationId,
  allowsPushPreference,
  createActivityNotificationIfAbsent,
  eventActivityNotificationCopy,
  sendFcmNotification,
} from "../shared/notifications";

interface EventReminderDeps {
  firestore: () => FirebaseFirestore.Firestore;
  now: () => Date;
  timestampFromDate: (date: Date) => FirebaseFirestore.Timestamp;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  sendNotification: typeof sendFcmNotification;
}

const defaultDeps: EventReminderDeps = {
  firestore: () => admin.firestore(),
  now: () => new Date(),
  timestampFromDate: (date) => admin.firestore.Timestamp.fromDate(date),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  sendNotification: sendFcmNotification,
};

/**
 * Creates event reminder activity items and push notifications roughly
 * 15 minutes before booked events start.
 *
 * The deterministic `eventReminder_${eventId}` id makes this idempotent per
 * user, even if Cloud Scheduler retries or two windows overlap.
 * @param {EventReminderDeps} deps Injectable dependencies for tests.
 */
export async function sendEventRemindersHandler(
  deps: EventReminderDeps = defaultDeps
): Promise<void> {
  const db = deps.firestore();
  const now = deps.now();
  const windowStart = new Date(now.getTime() + 14 * 60 * 1000);
  const windowEnd = new Date(now.getTime() + 29 * 60 * 1000);

  const eventsSnap = await db
    .collection("events")
    .where("status", "==", "active")
    .where("startTime", ">=", deps.timestampFromDate(windowStart))
    .where("startTime", "<", deps.timestampFromDate(windowEnd))
    .get();

  if (eventsSnap.empty) return;

  const results = await Promise.allSettled(
    eventsSnap.docs.map((eventSnap) =>
      fanOutEventReminder({
        db,
        deps,
        eventId: eventSnap.id,
        event: eventSnap.data() as EventDocument,
      })
    )
  );
  for (const result of results) {
    if (result.status === "rejected") {
      logger.error("Failed to fan out event reminder", {
        error: result.reason,
        reasonMessage: result.reason instanceof Error ?
          result.reason.message :
          String(result.reason),
      });
    }
  }
}

/**
 * Fans an event reminder out to signed-up participants for one event.
 * @param {object} params Fan-out parameters.
 * @param {FirebaseFirestore.Firestore} params.db Firestore instance.
 * @param {EventReminderDeps} params.deps Injectable dependencies.
 * @param {string} params.eventId Event id.
 * @param {EventDocument} params.event Event document.
 */
async function fanOutEventReminder(params: {
  db: FirebaseFirestore.Firestore;
  deps: EventReminderDeps;
  eventId: string;
  event: EventDocument;
}) {
  const participationsSnap = await params.db
    .collection("eventParticipations")
    .where("eventId", "==", params.eventId)
    .where("status", "==", "signedUp")
    .get();
  if (participationsSnap.empty) return;

  const uidList = Array.from(new Set(participationsSnap.docs
    .map((doc) => (doc.data() as EventParticipationDocument).uid)
    .filter((uid): uid is string => typeof uid === "string")));
  if (uidList.length === 0) return;

  const copy = eventActivityNotificationCopy("eventReminder", params.event);
  const userSnaps = await Promise.all(
    uidList.map((uid) => params.db.collection("users").doc(uid).get())
  );

  await Promise.allSettled(userSnaps.map(async (userSnap, index) => {
    const uid = uidList[index];
    const user = userSnap.data() as UserProfileDocument | undefined;
    if (!user) return;

    const created = await createActivityNotificationIfAbsent(params.db, {
      id: activityNotificationId("eventReminder", params.eventId),
      uid,
      type: "eventReminder",
      title: copy.title,
      body: copy.body,
      createdAt: params.deps.serverTimestamp(),
      eventId: params.eventId,
      clubId: params.event.clubId,
    });

    if (!created || !user.fcmToken ||
        !allowsPushPreference(user, "eventReminders")) {
      return;
    }

    await params.deps.sendNotification({
      token: user.fcmToken,
      title: copy.title,
      body: copy.body,
      type: "eventReminder",
      eventId: params.eventId,
      clubId: params.event.clubId,
    });
  }));
}

export const sendEventReminders = onSchedule(
  {
    schedule: "every 15 minutes",
    timeZone: "Asia/Kolkata",
  },
  async () => {
    try {
      await sendEventRemindersHandler();
    } catch (error) {
      logger.error("Failed to send event reminders", {error});
      throw error;
    }
  }
);
