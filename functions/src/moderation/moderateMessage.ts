/**
 * Text moderation for chat messages.
 *
 * Fires on every new chat message document. If the message contains a
 * block-list term, the message text is replaced with a placeholder and
 * a moderation flag is written for ops review. Flag-list matches are
 * logged but not replaced — they create a moderation flag for human
 * review while leaving the message intact.
 *
 * This is a Firestore onCreate trigger on `chats/{matchId}/messages/{id}`.
 * It augments the existing `onMessageCreated` trigger (which handles FCM
 * pushes and unread counts) rather than replacing it.
 */

import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {moderateText, type ModerationResult} from "./textFilter";

/**
 * Writes a moderation flag and optionally redacts a blocked message.
 * @param {ModerationResult} result The moderation result.
 * @param {string} messageId The message document ID.
 * @param {string} senderId The user who sent the message.
 * @param {string} matchId The match (chat) document ID.
 * @param {Object} deps Injectable Firestore dependencies.
 */
async function handleModerationResult(
  result: ModerationResult,
  messageId: string,
  senderId: string,
  matchId: string,
  deps: {
    firestore: () => FirebaseFirestore.Firestore;
    serverTimestamp: () => FirebaseFirestore.FieldValue;
  }
): Promise<void> {
  const matchList = result.matches.join(", ");
  const flagData = {
    targetUserId: senderId,
    flagType: "banned_text" as const,
    source: "chat_message" as const,
    status: "pending" as const,
    createdAt: deps.serverTimestamp(),
    contextId: messageId,
    context: `chat msg in match ${matchId}. Terms: ${matchList}`,
  };

  await deps.firestore().collection("moderationFlags").add(flagData);

  if (result.action === "block") {
    // Redact the message text in-place so other users never see it.
    await deps.firestore()
      .collection("chats")
      .doc(matchId)
      .collection("messages")
      .doc(messageId)
      .update({
        text: "[message removed for review]",
      });
  }
}

// ── Export ─────────────────────────────────────────────────────────────────

export const moderateChatMessage = onDocumentCreated(
  {
    document: "chats/{matchId}/messages/{messageId}",
    region: "asia-south1",
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const text = snapshot.get("text") as string | undefined;
    if (!text) return;

    const senderId = snapshot.get("senderId") as string | undefined;
    const matchId = event.params.matchId;

    const result = moderateText(text);
    if (result.action === "allow") return;

    await handleModerationResult(
      result,
      event.params.messageId,
      senderId ?? "unknown",
      matchId,
      {
        firestore: () => admin.firestore(),
        serverTimestamp: () =>
          admin.firestore.FieldValue.serverTimestamp(),
      }
    );

    if (result.action === "block") {
      logger.info(
        `[moderation] BLOCKED message ${event.params.messageId} ` +
        `in match ${matchId} — matches: ${result.matches.join(", ")}`
      );
    } else {
      logger.info(
        `[moderation] FLAGGED message ${event.params.messageId} ` +
        `in match ${matchId} — matches: ${result.matches.join(", ")}`
      );
    }
  }
);
