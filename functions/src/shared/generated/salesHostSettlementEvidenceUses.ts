/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable uniqueness receipt preventing one settlement source from double counting.
 */
export interface SalesHostSettlementEvidenceUsesDocument {
  schemaVersion: 1;
  classification: "sales_private";
  evidenceId: string;
  attestationId: string;
  organizerId: string;
  opportunityId: string;
  createdAt: string;
}
