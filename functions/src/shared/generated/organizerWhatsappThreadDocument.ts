/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-only organizer/contact WhatsApp thread summary with a 12-month rolling retention boundary.
 */
export interface OrganizerWhatsappThreadDocument {
  schemaVersion: 1;
  threadId: string;
  organizerId: string;
  contactId: string;
  connectionId: string;
  endpointHash: string;
  /**
   * @maxItems 50
   */
  eventIds: string[];
  lastMessageBody: string;
  lastMessageDirection: "inbound" | "outbound";
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  lastMessageAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  lastInboundAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  serviceWindowExpiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  messageCount: number;
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
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
