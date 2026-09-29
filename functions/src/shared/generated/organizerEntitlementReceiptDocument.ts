/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Idempotency receipt at organizerEntitlementReceipts/{receiptId} for admin entitlement mutations. receiptId is organizerId_operationId; a matching contentHash replays the stored result, a different hash fails closed.
 */
export interface OrganizerEntitlementReceiptDocument {
  schemaVersion: 1;
  receiptId: string;
  operationId: string;
  organizerId: string;
  actorUid: string;
  action: "grant" | "revoke";
  contentHash: string;
  resultRevision: number;
  grantId: string;
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
