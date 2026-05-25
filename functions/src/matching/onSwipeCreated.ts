import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {MatchDoc, SwipeDoc} from "../shared/generated/firestoreAdminTypes";
import {
  schemaProfileDecisionCollectionPath,
  schemaProfileDecisionOutgoingSubcollectionPath,
  schemaProfileDecisionTriggerPath,
} from "../shared/generated/schemaPaths";
import {hasBlockingRelationship} from "../safety/blocking";
import {buildSwipeSignalFacts} from "../marketplace/signalBuilders";
import {
  recordParticipantSignalFactsBestEffort,
} from "../marketplace/participantSignals";

interface SwipeCreatedParams {
  swiperId: string;
  targetId: string;
  swipeData: SwipeDoc | undefined;
}

interface SwipeCreatedDeps {
  firestore: () => FirebaseFirestore.Firestore;
  hasBlockingRelationship: (
    db: FirebaseFirestore.Firestore,
    userId: string,
    peerIds: string[]
  ) => Promise<boolean>;
  arrayUnion: (...elements: string[]) => FirebaseFirestore.FieldValue;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  recordSignalFacts?: typeof recordParticipantSignalFactsBestEffort;
}

const defaultDeps: SwipeCreatedDeps = {
  firestore: () => admin.firestore(),
  hasBlockingRelationship,
  arrayUnion: (...elements) =>
    admin.firestore.FieldValue.arrayUnion(...elements),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  recordSignalFacts: recordParticipantSignalFactsBestEffort,
};

/**
 * Creates a match when a newly created like has a reciprocal like.
 *
 * The Firestore trigger adapter passes path params and document data here so
 * tests can verify the match contract without the Functions event runtime.
 * @param {SwipeCreatedParams} params Trigger path params and swipe data.
 * @param {SwipeCreatedDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>} Resolves when processing is complete.
 */
export async function onSwipeCreatedHandler(
  {swiperId, targetId, swipeData}: SwipeCreatedParams,
  deps: SwipeCreatedDeps = defaultDeps
): Promise<void> {
  if (!swipeData || swipeData.direction !== "like") return;

  const db = deps.firestore();

  if (await deps.hasBlockingRelationship(db, swiperId, [targetId])) {
    logger.info("Skipping blocked profile decision metrics", {
      swiperId,
      targetId,
    });
    return;
  }

  if (deps.recordSignalFacts) {
    await deps.recordSignalFacts(
      db,
      buildSwipeSignalFacts(swiperId, targetId, swipeData)
    );
  }

  // Check if the target has already liked the swiper.
  const reverseSwipeDoc = await db
    .collection(schemaProfileDecisionCollectionPath)
    .doc(targetId)
    .collection(schemaProfileDecisionOutgoingSubcollectionPath)
    .doc(swiperId)
    .get();

  const reverseSwipe = reverseSwipeDoc.data() as SwipeDoc | undefined;
  if (!reverseSwipeDoc.exists || reverseSwipe?.direction !== "like") {
    return;
  }

  const sharedEventIds = Array.from(
    new Set([reverseSwipe.eventId, swipeData.eventId].filter(Boolean))
  );

  // Deterministic match ID, regardless of who swiped first.
  const [id1, id2] = [swiperId, targetId].sort();
  const matchId = `${id1}_${id2}`;
  const matchRef = db.collection("matches").doc(matchId);

  const matchDoc: MatchDoc = {
    user1Id: id1,
    user2Id: id2,
    participantIds: [id1, id2],
    eventIds: sharedEventIds,
    createdAt:
      deps.serverTimestamp() as unknown as FirebaseFirestore.Timestamp,
    lastMessageAt: null,
    lastMessagePreview: null,
    lastMessageSenderId: null,
    unreadCounts: {[id1]: 0, [id2]: 0},
    status: "active",
    blockedBy: null,
    blockedAt: null,
    conversationType: "match",
  };

  try {
    // create() throws if the document already exists.
    await matchRef.create(matchDoc);
    await writeReactionCommentMessages(
      matchRef,
      [reverseSwipe, swipeData],
      deps
    );
    logger.info("Match created", {
      matchId,
      user1Id: id1,
      user2Id: id2,
    });
  } catch (e: unknown) {
    const code = (e as {code?: unknown}).code;
    if (code === 6 || code === "already-exists") {
      // ALREADY_EXISTS - keep one match doc per pair and append shared event
      // history instead of creating another conversation.
      if (sharedEventIds.length > 0) {
        await matchRef.update({
          eventIds: deps.arrayUnion(...sharedEventIds),
          conversationType: "match",
          clubId: admin.firestore.FieldValue.delete(),
        });
      }
      await writeReactionCommentMessages(
        matchRef,
        [reverseSwipe, swipeData],
        deps
      );
      return;
    }
    throw e;
  }
}

/**
 * Writes swipe comments as deterministic starter messages after a match.
 * @param {FirebaseFirestore.DocumentReference} matchRef Match document ref.
 * @param {SwipeDoc[]} swipes Reciprocal swipe documents to inspect.
 * @param {SwipeCreatedDeps} deps Injectable Firestore helpers.
 * @return {Promise<void>} Resolves when all comment messages are written.
 */
async function writeReactionCommentMessages(
  matchRef: FirebaseFirestore.DocumentReference,
  swipes: SwipeDoc[],
  deps: SwipeCreatedDeps
): Promise<void> {
  const writes: Promise<unknown>[] = [];
  for (const swipe of swipes) {
    const text = buildReactionCommentText(swipe);
    if (!text) continue;
    const messageId = `profileReaction_${swipe.swiperId}_${swipe.targetId}`;
    writes.push(
      matchRef.collection("messages").doc(messageId).set({
        senderId: swipe.swiperId,
        text,
        sentAt: deps.serverTimestamp(),
      })
    );
  }
  await Promise.all(writes);
}

/**
 * Builds a chat-safe message from a profile-section reaction comment.
 * @param {SwipeDoc} swipe Swipe document that may contain reaction context.
 * @return {string | null} Message text, or null when there is no comment.
 */
function buildReactionCommentText(swipe: SwipeDoc): string | null {
  const comment = swipe.comment?.trim();
  if (!comment) return null;

  const label = swipe.reactionTargetLabel?.trim();
  const preview = swipe.reactionTargetPreview?.trim();
  if (!label && !preview) return comment;

  const context = [label, preview].filter(Boolean).join(": ");
  return `${comment}\n\nAbout ${context}`;
}

export const onSwipeCreated = onDocumentCreated(
  schemaProfileDecisionTriggerPath,
  async (event) => {
    const {swiperId, targetId} = event.params;
    const swipeData = event.data?.data() as SwipeDoc | undefined;
    await onSwipeCreatedHandler({swiperId, targetId, swipeData});
  }
);
