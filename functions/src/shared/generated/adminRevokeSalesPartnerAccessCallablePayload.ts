/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminRevokeSalesPartnerAccessCallablePayload {
  requestId: string;
  organizerId: string | null;
  partnerUid: string;
  expectedRevision: number;
  reason: string;
}
