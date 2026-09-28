/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Current quote head; accepted terms do not prove collection.
 */
export interface SalesQuotesDocument {
  schemaVersion: 1;
  classification: "sales_private";
  organizerId: string;
  opportunityId: string;
  quoteId: string;
  revision: number;
  termVersion: number;
  status: "draft" | "approved" | "accepted_reviewed";
  approvedDecisionId: string | null;
  acceptedDecisionId: string | null;
  updatedAt: string;
  updatedBy: string;
}
