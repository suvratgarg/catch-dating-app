import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {UserProfileDoc, MatchDoc, PublicProfileDoc} from "../shared/firestore";
import {
  allowsPushPreference,
  activityNotificationId,
  sendFcmNotification,
  setActivityNotification,
} from "../shared/notifications";

interface MatchCreatedEvent {
  params: {matchId: string};
  data?: {
    data(): FirebaseFirestore.DocumentData | undefined;
  };
}

interface MatchCreatedDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  sendNotification: typeof sendFcmNotification;
}

const defaultDeps: MatchCreatedDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  sendNotification: sendFcmNotification,
};

/**
 * Creates durable activity notifications and push notifications for a match.
 * @param {MatchCreatedEvent} event Firestore match-created event.
 * @param {MatchCreatedDeps} deps Injectable dependencies for tests.
 */
export async function onMatchCreatedHandler(
  event: MatchCreatedEvent,
  deps: MatchCreatedDeps = defaultDeps
): Promise<void> {
  const {matchId} = event.params;
  const match = event.data?.data() as MatchDoc | undefined;
  if (!match) return;

  const db = deps.firestore();
  const {user1Id, user2Id} = match;
  const [user1Doc, user2Doc, profile1Doc, profile2Doc] = await Promise.all([
    db.collection("users").doc(user1Id).get(),
    db.collection("users").doc(user2Id).get(),
    db.collection("publicProfiles").doc(user1Id).get(),
    db.collection("publicProfiles").doc(user2Id).get(),
  ]);

  const user1 = user1Doc.data() as UserProfileDoc | undefined;
  const user2 = user2Doc.data() as UserProfileDoc | undefined;
  const profile1Name =
    (profile1Doc.data() as PublicProfileDoc | undefined)?.name ?? "Someone";
  const profile2Name =
    (profile2Doc.data() as PublicProfileDoc | undefined)?.name ?? "Someone";

  await Promise.all([
    setActivityNotification(db, {
      id: activityNotificationId("match", matchId),
      uid: user1Id,
      type: "match",
      title: "It's a catch",
      body: `You and ${profile2Name} matched. Say hi!`,
      createdAt: deps.serverTimestamp(),
      matchId,
      runId: match.runId,
      actorUid: user2Id,
      actorName: profile2Name,
    }),
    setActivityNotification(db, {
      id: activityNotificationId("match", matchId),
      uid: user2Id,
      type: "match",
      title: "It's a catch",
      body: `You and ${profile1Name} matched. Say hi!`,
      createdAt: deps.serverTimestamp(),
      matchId,
      runId: match.runId,
      actorUid: user1Id,
      actorName: profile1Name,
    }),
  ]);

  const pushTargets = [
    {
      token: user1?.fcmToken,
      enabled: allowsPushPreference(user1, "matches"),
      body: `You and ${profile2Name} matched. Say hi!`,
    },
    {
      token: user2?.fcmToken,
      enabled: allowsPushPreference(user2, "matches"),
      body: `You and ${profile1Name} matched. Say hi!`,
    },
  ].flatMap((target) =>
    target.enabled &&
    typeof target.token === "string" &&
    target.token.length > 0 ?
      [{token: target.token, body: target.body}] :
      []
  );

  if (pushTargets.length === 0) return;

  logger.info("Sending match notifications", {
    matchId,
    tokenCount: pushTargets.length,
  });

  await Promise.allSettled(
    pushTargets.map((target) =>
      deps.sendNotification({
        token: target.token,
        title: "It's a catch",
        body: target.body,
        type: "match",
        matchId,
      })
    )
  );
}

export const onMatchCreated = onDocumentCreated(
  "matches/{matchId}",
  (event) => onMatchCreatedHandler(event)
);
