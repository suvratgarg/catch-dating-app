/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * TTL idempotency receipt for one authenticated provider webhook event.
 */
export interface OrganizerCampaignWebhookReceiptDocument {
  provider: "metaCloudApi";
  providerEventId: string;
  organizerId: string | null;
  connectionId: string | null;
  eventKind:
    | "status"
    | "inbound"
    | "template"
    | "quality"
    | "account"
    | "unmatched";
  payloadHash: string;
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
