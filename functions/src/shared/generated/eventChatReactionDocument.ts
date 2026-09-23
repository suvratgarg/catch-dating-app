/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * One current reaction per account and message; separate from aggregated anonymous counts.
 */
export interface EventChatReactionDocument {
  eventId: string;
  messageId: string;
  uid: string;
  reaction: ("like" | "love" | "laugh" | "wow" | "sad" | "thanks") | null;
  revision: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
