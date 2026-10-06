/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminRevokeSalesPartnerMarketingGrantCallablePayload {
  requestId: string;
  partnerUid: string;
  grantId: string;
  expectedMembershipRevision: number;
  expectedGrantRevision: number;
  reason: string;
}
