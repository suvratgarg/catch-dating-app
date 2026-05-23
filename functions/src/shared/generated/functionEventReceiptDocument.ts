/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned idempotency receipt stored at functionEventReceipts/{receiptId}.
 */
export interface FunctionEventReceiptDocument {
  handler: "onMessageCreated";
  eventId: string;
  matchId: string;
  messageId: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
