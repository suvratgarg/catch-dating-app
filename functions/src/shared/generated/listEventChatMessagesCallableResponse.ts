/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ListEventChatMessagesCallableResponse {
  /**
   * @maxItems 30
   */
  messages: {
    messageId: string;
    sequence: number;
    sentAtMillis: number;
    senderUid: string | null;
    senderName: string | null;
    available: boolean;
    kind: "text" | "announcement";
    text: string | null;
    reply: {
      messageId: string;
      senderUid: string | null;
      senderName: string | null;
      available: boolean;
      text: string | null;
    } | null;
    reactionCounts: {
      like: number;
      love: number;
      laugh: number;
      wow: number;
      sad: number;
      thanks: number;
    };
    myReaction: ("like" | "love" | "laugh" | "wow" | "sad" | "thanks") | null;
    myReactionRevision: number;
  }[];
  nextBeforeSequence: number | null;
  /**
   * @maxItems 10
   */
  typing: {
    uid: string;
    displayName: string;
    expiresAtMillis: number;
  }[];
  typingHasMore: boolean;
  ownTypingRevision: number;
  serverTimeMillis: number;
}
