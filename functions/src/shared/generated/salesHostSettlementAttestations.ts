/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Owner-attested first-party host subscription collection; provider unconfirmed and separate from guest payments.
 */
export interface SalesHostSettlementAttestationsDocument {
  schemaVersion: 1;
  classification: "sales_private";
  revision: 1;
  attestationId: string;
  organizerId: string;
  opportunityId: string;
  quoteId: string;
  termVersion: number;
  termsHash: string;
  amountMinor: number;
  currency: string;
  purpose: "host_subscription";
  receivedAt: string;
  settlementMethod: "bank_transfer" | "cash" | "other_external";
  settlementReference: string;
  recipientAccountScope: string;
  settlementIdentityHash: string;
  servicePeriod: {
    startsAt: string;
    endsAt: string;
  } | null;
  evidence: {
    evidenceId: string;
    sourceRef: string;
    contentHash: string;
    observedAt: string;
  };
  status: "manual_attested_collected";
  providerConfirmed: false;
  actorUid: string;
  attestedAt: string;
}
