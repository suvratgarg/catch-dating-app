/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable uniqueness receipt for one external host settlement reference within one recipient ledger scope, independent of evidence and quote IDs.
 */
export interface SalesHostSettlementIdentitiesDocument {
  schemaVersion: 1;
  classification: "sales_private";
  settlementIdentityHash: string;
  attestationId: string;
  organizerId: string;
  opportunityId: string;
  createdAt: string;
}
