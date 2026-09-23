/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Explicit room participation. Current admission and claimed identity must still be rechecked on every access.
 */
export interface EventChatMembershipDocument {
  eventId: string;
  organizerId: string;
  uid: string;
  status: "joined" | "left";
  revision: number;
  termsVersion: "event-chat-v1";
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  joinedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  leftAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
