/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Host-controlled event conversation availability. No attendee admission or profile data.
 */
export interface EventChatRoomDocument {
  eventId: string;
  organizerId: string;
  status: "open" | "announcementsOnly" | "paused" | "closed" | "archived";
  revision: number;
  createdByUid: string;
  updatedByUid: string;
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
  lastMessageSequence?: number;
  opensAtMillis?: number | null;
  closesAtMillis?: number | null;
}
