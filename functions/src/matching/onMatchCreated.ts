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
import {demoMetadataFromSources} from "../shared/demoMetadata";
import {buildMatchSignalFacts} from "../marketplace/signalBuilders";
import {
  recordParticipantSignalFactsBestEffort,
} from "../marketplace/participantSignals";

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
  recordSignalFacts?: typeof recordParticipantSignalFactsBestEffort;
}

const defaultDeps: MatchCreatedDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  sendNotification: sendFcmNotification,
  recordSignalFacts: recordParticipantSignalFactsBestEffort,
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
  const latestEventId = latestMatchEventId(match);

  if (deps.recordSignalFacts) {
    await deps.recordSignalFacts(db, buildMatchSignalFacts(matchId, match));
  }

  await Promise.all([
    setActivityNotification(db, {
      id: activityNotificationId("match", matchId),
      uid: user1Id,
      type: "match",
      title: "It's a catch",
      body: `You and ${profile2Name} matched. Say hi!`,
      createdAt: deps.serverTimestamp(),
      matchId,
      eventId: latestEventId,
      actorUid: user2Id,
      actorName: profile2Name,
      ...demoMetadataFromSources(match),
    }),
    setActivityNotification(db, {
      id: activityNotificationId("match", matchId),
      uid: user2Id,
      type: "match",
      title: "It's a catch",
      body: `You and ${profile1Name} matched. Say hi!`,
      createdAt: deps.serverTimestamp(),
      matchId,
      eventId: latestEventId,
      actorUid: user1Id,
      actorName: profile1Name,
      ...demoMetadataFromSources(match),
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

type LegacyMatchDoc = MatchDoc & {eventId?: string | null};

/**
 * Returns the newest shared event id for a match, including legacy eventId
 * docs.
 *
 * @param {MatchDoc} match Match document data.
 * @return {string | undefined} Latest event id when one is available.
 */
function latestMatchEventId(match: MatchDoc): string | undefined {
  const eventIds = match.eventIds ?? [];
  const legacyEventId = (match as LegacyMatchDoc).eventId;
  return eventIds.at(-1) ?? legacyEventId ?? undefined;
}

export const onMatchCreated = onDocumentCreated(
  "matches/{matchId}",
  (event) => onMatchCreatedHandler(event)
);
