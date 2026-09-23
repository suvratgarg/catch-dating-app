/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Payload-bound idempotency receipt for an explicit room availability, membership, reaction or message safety action.
 */
export interface EventChatAccessReceiptDocument {
  eventId: string;
  uid: string;
  payloadHash: string;
  revision: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
