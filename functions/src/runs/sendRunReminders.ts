import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {
  RunDoc,
  RunParticipationDoc,
  UserProfileDoc,
} from "../shared/firestore";
import {
  activityNotificationId,
  allowsPushPreference,
  createActivityNotificationIfAbsent,
  runActivityNotificationCopy,
  sendFcmNotification,
} from "../shared/notifications";

interface RunReminderDeps {
  firestore: () => FirebaseFirestore.Firestore;
  now: () => Date;
  timestampFromDate: (date: Date) => FirebaseFirestore.Timestamp;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  sendNotification: typeof sendFcmNotification;
}

const defaultDeps: RunReminderDeps = {
  firestore: () => admin.firestore(),
  now: () => new Date(),
  timestampFromDate: (date) => admin.firestore.Timestamp.fromDate(date),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  sendNotification: sendFcmNotification,
};

/**
 * Creates run reminder activity items and push notifications roughly
 * 15 minutes before booked runs start.
 *
 * The deterministic `runReminder_${runId}` id makes this idempotent per user,
 * even if Cloud Scheduler retries or two windows overlap.
 * @param {RunReminderDeps} deps Injectable dependencies for tests.
 */
export async function sendRunRemindersHandler(
  deps: RunReminderDeps = defaultDeps
): Promise<void> {
  const db = deps.firestore();
  const now = deps.now();
  const windowStart = new Date(now.getTime() + 14 * 60 * 1000);
  const windowEnd = new Date(now.getTime() + 29 * 60 * 1000);

  const runsSnap = await db
    .collection("runs")
    .where("status", "==", "active")
    .where("startTime", ">=", deps.timestampFromDate(windowStart))
    .where("startTime", "<", deps.timestampFromDate(windowEnd))
    .get();

  if (runsSnap.empty) return;

  const results = await Promise.allSettled(
    runsSnap.docs.map((runSnap) =>
      fanOutRunReminder({
        db,
        deps,
        runId: runSnap.id,
        run: runSnap.data() as RunDoc,
      })
    )
  );
  for (const result of results) {
    if (result.status === "rejected") {
      logger.error("Failed to fan out run reminder", {
        error: result.reason,
        reasonMessage: result.reason instanceof Error ?
          result.reason.message :
          String(result.reason),
      });
    }
  }
}

/**
 * Fans a run reminder out to signed-up participants for one run.
 * @param {object} params Fan-out parameters.
 * @param {FirebaseFirestore.Firestore} params.db Firestore instance.
 * @param {RunReminderDeps} params.deps Injectable dependencies.
 * @param {string} params.runId Run id.
 * @param {RunDoc} params.run Run document.
 */
async function fanOutRunReminder(params: {
  db: FirebaseFirestore.Firestore;
  deps: RunReminderDeps;
  runId: string;
  run: RunDoc;
}) {
  const participationsSnap = await params.db
    .collection("runParticipations")
    .where("runId", "==", params.runId)
    .where("status", "==", "signedUp")
    .get();
  if (participationsSnap.empty) return;

  const uidList = Array.from(new Set(participationsSnap.docs
    .map((doc) => (doc.data() as RunParticipationDoc).uid)
    .filter((uid): uid is string => typeof uid === "string")));
  if (uidList.length === 0) return;

  const copy = runActivityNotificationCopy("runReminder", params.run);
  const userSnaps = await Promise.all(
    uidList.map((uid) => params.db.collection("users").doc(uid).get())
  );

  await Promise.allSettled(userSnaps.map(async (userSnap, index) => {
    const uid = uidList[index];
    const user = userSnap.data() as UserProfileDoc | undefined;
    if (!user) return;

    const created = await createActivityNotificationIfAbsent(params.db, {
      id: activityNotificationId("runReminder", params.runId),
      uid,
      type: "runReminder",
      title: copy.title,
      body: copy.body,
      createdAt: params.deps.serverTimestamp(),
      runId: params.runId,
      runClubId: params.run.runClubId,
    });

    if (!created || !user.fcmToken ||
        !allowsPushPreference(user, "runReminders")) {
      return;
    }

    await params.deps.sendNotification({
      token: user.fcmToken,
      title: copy.title,
      body: copy.body,
      type: "runReminder",
      runId: params.runId,
      runClubId: params.run.runClubId,
    });
  }));
}

export const sendRunReminders = onSchedule(
  {
    schedule: "every 15 minutes",
    timeZone: "Asia/Kolkata",
  },
  async () => {
    try {
      await sendRunRemindersHandler();
    } catch (error) {
      logger.error("Failed to send run reminders", {error});
      throw error;
    }
  }
);
