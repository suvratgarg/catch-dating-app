import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {
  UserProfileDoc,
  ChatMessageDoc,
  MatchDoc,
  PublicProfileDoc,
} from "../shared/firestore";
import {sendFcmNotification} from "../shared/notifications";

interface MessageCreatedEvent {
  id?: string;
  params: {
    matchId: string;
    messageId: string;
  };
  data?: {
    data(): FirebaseFirestore.DocumentData | undefined;
  };
}

interface MessageCreatedDeps {
  firestore: () => FirebaseFirestore.Firestore;
  increment: (value: number) => FirebaseFirestore.FieldValue;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  sendNotification: typeof sendFcmNotification;
}

const defaultDeps: MessageCreatedDeps = {
  firestore: () => admin.firestore(),
  increment: (value) => admin.firestore.FieldValue.increment(value),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  sendNotification: sendFcmNotification,
};

/**
 * Applies server-owned match metadata for a newly created chat message.
 * @param {MessageCreatedEvent} event Firestore message-created event.
 * @param {MessageCreatedDeps} deps Injectable dependencies for tests.
 */
export async function onMessageCreatedHandler(
  event: MessageCreatedEvent,
  deps: MessageCreatedDeps = defaultDeps
): Promise<void> {
  const {matchId, messageId} = event.params;
  const message = event.data?.data() as ChatMessageDoc | undefined;
  if (!message) return;

  const db = deps.firestore();
  const eventId = event.id ?? `${matchId}_${messageId}`;
  const matchRef = db.collection("matches").doc(matchId);
  const receiptRef = db
    .collection("functionEventReceipts")
    .doc(`onMessageCreated_${eventId}`);

  let recipientId: string | null = null;
  let shouldNotify = false;

  await db.runTransaction(async (tx) => {
    const [receiptSnap, matchDoc] = await Promise.all([
      tx.get(receiptRef),
      tx.get(matchRef),
    ]);

    if (receiptSnap.exists || !matchDoc.exists) {
      return;
    }

    const match = matchDoc.data() as MatchDoc;
    if (match.status === "blocked") {
      logger.info("Skipping notification for blocked match", {matchId});
      return;
    }
    recipientId =
      match.user1Id === message.senderId ? match.user2Id : match.user1Id;

    // Keep match-list metadata server-owned. The client writes only the
    // message. The receipt makes this increment idempotent across retries.
    tx.update(matchRef, {
      lastMessageAt: message.sentAt,
      lastMessagePreview: buildMessagePreview(message),
      lastMessageSenderId: message.senderId,
      [`unreadCounts.${recipientId}`]: deps.increment(1),
    });

    tx.create(receiptRef, {
      handler: "onMessageCreated",
      eventId,
      matchId,
      messageId,
      createdAt: deps.serverTimestamp(),
    });

    shouldNotify = true;
  });

  if (!shouldNotify || !recipientId) {
    return;
  }

  // Fetch sender name and recipient FCM token concurrently.
  const [senderProfileDoc, recipientUserDoc] = await Promise.all([
    db.collection("publicProfiles").doc(message.senderId).get(),
    db.collection("users").doc(recipientId).get(),
  ]);

  const fcmToken =
    (recipientUserDoc.data() as UserProfileDoc | undefined)?.fcmToken;
  if (!fcmToken) return;

  const senderName =
    (senderProfileDoc.data() as PublicProfileDoc | undefined)?.name ??
    "New message";
  const body =
    message.text.length > 100 ?
      message.text.slice(0, 100) + "…" :
      message.text;

  logger.info("Sending message notification", {matchId, recipientId});

  await deps.sendNotification({
    token: fcmToken,
    title: senderName,
    body,
    type: "message",
    matchId,
  });
}

export const onMessageCreated = onDocumentCreated(
  "chats/{matchId}/messages/{messageId}",
  (event) => onMessageCreatedHandler(event)
);

/**
 * Builds the match-list preview for the latest chat message.
 *
 * @param {ChatMessageDoc} message Chat message document data.
 * @return {string} Preview text for the match list.
 */
function buildMessagePreview(message: ChatMessageDoc): string {
  if (message.imageUrl) {
    return "Image";
  }

  const text = message.text.trim();
  return text.length > 80 ? text.slice(0, 80) + "…" : text;
}
