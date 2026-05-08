import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {MatchDoc, SwipeDoc} from "../shared/firestore";
import {hasBlockingRelationship} from "../safety/blocking";

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
  serverTimestamp: () => FirebaseFirestore.FieldValue;
}

const defaultDeps: SwipeCreatedDeps = {
  firestore: () => admin.firestore(),
  hasBlockingRelationship,
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
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

  // Check if the target has already liked the swiper.
  const reverseSwipeDoc = await db
    .collection("swipes")
    .doc(targetId)
    .collection("outgoing")
    .doc(swiperId)
    .get();

  const reverseSwipe = reverseSwipeDoc.data() as SwipeDoc | undefined;
  if (!reverseSwipeDoc.exists || reverseSwipe?.direction !== "like") {
    return;
  }

  if (await deps.hasBlockingRelationship(db, swiperId, [targetId])) {
    logger.info("Skipping blocked match", {swiperId, targetId});
    return;
  }

  // Cross-run matching is intentional for MVP.
  // If A liked B on Run1 and B liked A on Run2, they still match.
  // Add `reverseSwipe.runId === swipeData.runId` here to restrict
  // matches to runners from the same event.

  // Deterministic match ID, regardless of who swiped first.
  const [id1, id2] = [swiperId, targetId].sort();
  const matchId = `${id1}_${id2}`;
  const matchRef = db.collection("matches").doc(matchId);

  const matchDoc: MatchDoc = {
    user1Id: id1,
    user2Id: id2,
    participantIds: [id1, id2],
    runId: swipeData.runId,
    createdAt:
      deps.serverTimestamp() as unknown as FirebaseFirestore.Timestamp,
    lastMessageAt: null,
    lastMessagePreview: null,
    lastMessageSenderId: null,
    unreadCounts: {[id1]: 0, [id2]: 0},
    status: "active",
  };

  try {
    // create() throws if the document already exists.
    await matchRef.create(matchDoc);
    logger.info("Match created", {
      matchId,
      user1Id: id1,
      user2Id: id2,
    });
  } catch (e: unknown) {
    const code = (e as {code?: unknown}).code;
    if (code === 6 || code === "already-exists") {
      // ALREADY_EXISTS - match already exists, nothing to do.
      return;
    }
    throw e;
  }
}

export const onSwipeCreated = onDocumentCreated(
  "swipes/{swiperId}/outgoing/{targetId}",
  async (event) => {
    const {swiperId, targetId} = event.params;
    const swipeData = event.data?.data() as SwipeDoc | undefined;
    await onSwipeCreatedHandler({swiperId, targetId, swipeData});
  }
);
