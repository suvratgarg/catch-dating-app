/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface RecordSalesPartnerManualSendCallablePayload {
  requestId: string;
  organizerId: string;
  expectedAssignmentRevision: number;
  draftId: string;
  expectedContentHash: string;
  channel: "email" | "whatsapp" | "other";
  occurredAt: string;
  attestation: "i_manually_sent_this_reviewed_draft";
}
