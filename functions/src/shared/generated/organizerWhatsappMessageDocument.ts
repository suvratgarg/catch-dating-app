/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-only inbound or outbound WhatsApp body retained for 12 months.
 */
export interface OrganizerWhatsappMessageDocument {
  schemaVersion: 1;
  messageId: string;
  threadId: string;
  organizerId: string;
  contactId: string;
  connectionId: string;
  direction: "inbound" | "outbound";
  body: string;
  providerMessageId: string;
  actorUid: string | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  occurredAt: {
    _seconds: number;
    _nanoseconds: number;
  };
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
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
