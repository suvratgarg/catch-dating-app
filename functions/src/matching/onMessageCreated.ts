import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {
  UserProfileDoc,
  ChatMessageDoc,
  MatchDoc,
  PublicProfileDoc,
} from "../shared/firestore";
import {
  allowsPushPreference,
  sendFcmNotification,
} from "../shared/notifications";

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
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  sendNotification: typeof sendFcmNotification;
}

const defaultDeps: MessageCreatedDeps = {
  firestore: () => admin.firestore(),
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
  let notificationTitle = "New message";
  let notificationBody = buildMessageBody(message);

  await db.runTransaction(async (tx) => {
    const senderProfileRef = db.collection("publicProfiles").doc(
      message.senderId
    );
    const [receiptSnap, matchDoc, senderProfileDoc] = await Promise.all([
      tx.get(receiptRef),
      tx.get(matchRef),
      tx.get(senderProfileRef),
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
    const senderName =
      (senderProfileDoc.data() as PublicProfileDoc | undefined)?.name ??
      "New message";
    notificationTitle = senderName;
    notificationBody = buildMessageBody(message);
    const messageSentAt = message.sentAt ?? deps.serverTimestamp();

    // Keep match-list metadata server-owned. The client writes only the
    // message. The receipt makes this increment idempotent across retries.
    tx.update(matchRef, {
      lastMessageAt: messageSentAt,
      lastMessagePreview: buildMessagePreview(message),
      lastMessageSenderId: message.senderId,
      [`unreadCounts.${message.senderId}`]: 0,
      [`unreadCounts.${recipientId}`]: 1,
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

  const recipientUserDoc = await db.collection("users").doc(recipientId).get();
  const recipientUser = recipientUserDoc.data() as UserProfileDoc | undefined;
  const fcmToken = recipientUser?.fcmToken;
  if (!fcmToken) return;
  if (!allowsPushPreference(recipientUser, "messages")) return;

  logger.info("Sending message notification", {matchId, recipientId});

  await deps.sendNotification({
    token: fcmToken,
    title: notificationTitle,
    body: notificationBody,
    type: "message",
    matchId,
  });
}

export const onMessageCreated = onDocumentCreated(
  "matches/{matchId}/messages/{messageId}",
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

/**
 * Builds the user-facing body for message push and activity notifications.
 * @param {ChatMessageDoc} message Chat message document data.
 * @return {string} Notification body text.
 */
function buildMessageBody(message: ChatMessageDoc): string {
  if (message.imageUrl) return "Sent a photo";

  const text = message.text.trim();
  return text.length > 100 ? text.slice(0, 100) + "…" : text;
}
