/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private bounded Sales callable request. Server authorization and transaction policy are enforced separately.
 */
export interface AdminRecordSalesActivityCallablePayload {
  organizerId: string;
  requestId: string;
  opportunityId?: string;
  type:
    | "note"
    | "reply"
    | "call"
    | "demo"
    | "pilot"
    | "correction"
    | "outreach_sent_manual";
  channel?: "email" | "whatsapp" | "other";
  attestation?: "sent_elsewhere_by_actor";
  occurredAt: string;
  note: string;
}
