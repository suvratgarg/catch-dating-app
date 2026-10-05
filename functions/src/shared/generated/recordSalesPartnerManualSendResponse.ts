/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface RecordSalesPartnerManualSendResponse {
  organizerId: string;
  draftId: string;
  activityId: string;
  exactContentHash: string;
  occurredAt: string;
  outcome: "actor_attested_sent";
  providerConfirmed: false;
  sendAuthority: false;
}
