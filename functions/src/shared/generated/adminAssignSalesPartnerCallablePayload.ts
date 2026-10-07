/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminAssignSalesPartnerCallablePayload {
  requestId: string;
  organizerId: string;
  partnerUid: string;
  expectedRevision: number;
  nextAction: string;
  reviewAt: string;
  expiresAt: string;
  reason: string;
  originatorUid: string | null;
}
