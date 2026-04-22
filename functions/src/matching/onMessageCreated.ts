import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {
  UserProfileDoc,
  ChatMessageDoc,
  MatchDoc,
  PublicProfileDoc,
} from "../shared/firestore";

export const onMessageCreated = onDocumentCreated(
  "chats/{matchId}/messages/{messageId}",
  async (event) => {
    const {matchId} = event.params;
    const message = event.data?.data() as ChatMessageDoc | undefined;
    if (!message) return;

    const db = admin.firestore();

    // Fetch the match doc to find the recipient
    const matchDoc = await db.collection("matches").doc(matchId).get();
    if (!matchDoc.exists) return;

    const match = matchDoc.data() as MatchDoc;
    const recipientId =
      match.user1Id === message.senderId ? match.user2Id : match.user1Id;

    // Atomically increment recipient's unread count
    await db.collection("matches").doc(matchId).update({
      [`unreadCounts.${recipientId}`]: admin.firestore.FieldValue.increment(1),
    });

    // Fetch sender name and recipient FCM token concurrently
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

    await admin.messaging().send({
      token: fcmToken,
      notification: {title: senderName, body},
      data: {type: "message", matchId},
      apns: {payload: {aps: {sound: "default"}}},
      android: {notification: {sound: "default"}},
    });
  }
);
