/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private immutable Catch-owned incoming message and status receipts. Exact configured WABA and sender binding, no organizer authority, no outgoing action. Bounded text expires after 30 days. Status facts remain individual events rather than an arrival-ordered delivery projection.
 */
export type CatchWhatsappWebhookEventDocument = {
  [k: string]: unknown;
} & {
  schema: "catch.whatsapp-webhook-event/v1";
  eventId: string;
  wabaId: string;
  phoneNumberId: string;
  payloadHash: string;
  eventKind: "inbound" | "status";
  messageId: string;
  providerTimestampSeconds: string;
  participantId: string;
  messageType: string | null;
  text: string | null;
  textTruncated: boolean;
  deliveryStatus: null | "sent" | "delivered" | "read" | "failed";
  /**
   * @maxItems 10
   */
  errorCodes: number[];
  receivedAtMillis: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
};
