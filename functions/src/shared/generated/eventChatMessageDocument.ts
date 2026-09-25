/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned event conversation message; replies are same-room references, never quoted copies.
 */
export interface EventChatMessageDocument {
  eventId: string;
  organizerId: string;
  uid: string | null;
  sequence: number;
  text: string | null;
  replyToMessageId: string | null;
  status: "visible" | "removed";
  /**
   * Legacy omission means text.
   */
  kind?: "text" | "announcement";
  payloadHash: string;
  reactionCounts: {
    like: number;
    love: number;
    laugh: number;
    wow: number;
    sad: number;
    thanks: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  removedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
