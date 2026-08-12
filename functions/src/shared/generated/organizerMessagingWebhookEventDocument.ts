/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Sanitized durable provider event queued after signature verification. Message bodies and phone numbers are not retained.
 */
export interface OrganizerMessagingWebhookEventDocument {
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
  providerMessageId: string | null;
  contextProviderMessageId: string | null;
  deliveryStatus: null | "sent" | "delivered" | "read" | "failed";
  endpointHash: string | null;
  isStop: boolean;
  hasReply: boolean;
  providerErrorCode: number | null;
  providerOccurredAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  processingStatus: "pending" | "processed" | "unmatched" | "failed";
  attemptCount: number;
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
