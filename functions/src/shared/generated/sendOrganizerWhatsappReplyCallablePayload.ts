/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface SendOrganizerWhatsappReplyCallablePayload {
  organizerId: string;
  threadId: string;
  body: string;
  expectedLastInboundAtMillis: number;
  idempotencyKey: string;
}
