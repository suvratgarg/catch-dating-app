/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Strict private Sales commercial request; current role, scope, revision and evidence policy are transactional.
 */
export interface AdminAttestSalesHostSettlementPayload {
  organizerId: string;
  opportunityId: string;
  requestId: string;
  expectedQuoteRevision: number;
  termVersion: number;
  amountMinor: number;
  currency: string;
  purpose: "host_subscription";
  receivedAt: string;
  settlementMethod: "bank_transfer" | "cash" | "other_external";
  settlementReference: string;
  recipientAccountScope: string;
  servicePeriod: {
    startsAt: string;
    endsAt: string;
  } | null;
  evidence: {
    evidenceId: string;
  };
}
