/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-only at-most-once reservation for one organizer WhatsApp reply attempt.
 */
export interface OrganizerWhatsappReplyOperationDocument {
  schemaVersion: 1;
  operationId: string;
  organizerId: string;
  threadId: string;
  contactId: string;
  messageId: string;
  bodyHash: string;
  expectedLastInboundAtMillis: number;
  actorUid: string;
  state: "pending" | "completed" | "unknown";
  providerMessageId: string | null;
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
