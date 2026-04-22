import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {MatchDoc, SwipeDoc} from "../types/firestore";

export const onSwipeCreated = onDocumentCreated(
  "swipes/{swiperId}/outgoing/{targetId}",
  async (event) => {
    const {swiperId, targetId} = event.params;
    const swipeData = event.data?.data() as SwipeDoc | undefined;

    if (!swipeData || swipeData.direction !== "like") return;

    // Check if the target has already liked the swiper
    const reverseSwipeDoc = await admin
      .firestore()
      .collection("swipes")
      .doc(targetId)
      .collection("outgoing")
      .doc(swiperId)
      .get();

    const reverseSwipe = reverseSwipeDoc.data() as SwipeDoc | undefined;
    if (!reverseSwipeDoc.exists || reverseSwipe?.direction !== "like") {
      return;
    }

    // Cross-run matching is intentional for MVP: if A liked B on Run1 and B liked
    // A on Run2, they still match. Add a `reverseSwipe.runId === swipeData.runId`
    // check here if you want to restrict matches to runners from the same event.

    // Deterministic match ID — sorted so it's the same regardless of who swiped first
    const [id1, id2] = [swiperId, targetId].sort();
    const matchId = `${id1}_${id2}`;
    const matchRef = admin.firestore().collection("matches").doc(matchId);

    const matchDoc: MatchDoc = {
      user1Id: id1,
      user2Id: id2,
      participantIds: [id1, id2],
      runId: swipeData.runId,
      createdAt: admin.firestore.FieldValue.serverTimestamp() as unknown as FirebaseFirestore.Timestamp,
      lastMessageAt: null,
      lastMessagePreview: null,
      lastMessageSenderId: null,
      unreadCounts: {[id1]: 0, [id2]: 0},
    };

    try {
      // create() throws if the document already exists, preventing duplicate matches
      await matchRef.create(matchDoc);
      logger.info("Match created", {matchId, user1Id: id1, user2Id: id2});
    } catch (e: unknown) {
      if ((e as {code?: number}).code === 6) {
        // gRPC ALREADY_EXISTS — match already exists, nothing to do
        return;
      }
      throw e;
    }
  }
);
