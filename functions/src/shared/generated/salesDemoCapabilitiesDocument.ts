/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Trusted server-owned current eligibility for the synthetic Forms adapter; absence denies demos.
 */
export interface SalesDemoCapabilitiesDocument {
  schemaVersion: 1;
  classification: "sales_private";
  capability: "synthetic_forms_v1";
  revision: string;
  evidenceRevision: string;
  enabled: boolean;
  reviewedByUid: string;
  reviewedAt: string;
}
