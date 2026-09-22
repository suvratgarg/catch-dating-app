/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Deduplicated, verified merchant webhook receipt. Raw provider payloads and credentials are never stored.
 */
export interface OrganizerFormPaymentWebhookDocument {
  connectionId: string;
  accountId: string;
  providerEventId: string;
  event: string;
  providerOrderId: string | null;
  providerPaymentId: string | null;
  status: "pending" | "processed" | "ignored";
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  processedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
