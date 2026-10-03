/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private one-reply-per-inbound support claim and saved provider delivery projection. Explicit human review of the exact inbound support request is service evidence, never marketing permission. No body, credential or pricing data. No automatic retry or TTL; uncertain and completed claims remain consumed beyond receipt retention. Source-only and disabled pending atomic STOP ingress and scoped activation.
 */
export type CatchWhatsappReplyOperationDocument = {
  [k: string]: unknown;
} & {
  schemaVersion: 1;
  operationId: string;
  purpose: "serviceSupport";
  source: "reviewedInboundSupportRequest";
  wabaId: string;
  phoneNumberId: string;
  recipientUid: string;
  endpointHash: string;
  actorUid: string;
  inboundEventId: string;
  inboundMessageId: string;
  inboundTextHash: string;
  bodyHash: string;
  materialHash: string;
  reviewedAtMillis: number;
  deadlineMillis: number;
  state: "claimed" | "unknown" | "completed";
  providerMessageId: string | null;
  deliveryStatus:
    | "pending"
    | "accepted"
    | "sent"
    | "delivered"
    | "read"
    | "failed";
  deliveryEventId: string | null;
  deliveryAtMillis: number | null;
  createdAtMillis: number;
  updatedAtMillis: number;
  readinessEvidenceHash: string;
};
