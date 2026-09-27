/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private exact prose approved for one organizer. Revoked or expired source and reference permission block future use.
 */
export interface SalesIntelligenceClausesDocument {
  schemaVersion: 1;
  classification: "sales_private";
  clauseId: string;
  organizerId: string;
  revision: number;
  kind: "observation" | "capability" | "reference" | "cta";
  text: string;
  state: "draft" | "approved" | "withdrawn";
  /**
   * @maxItems 8
   */
  evidenceIds: string[];
  validUntil: string;
  permission: "not_required" | "private_mention" | "withdrawn";
  reviewedAt: string | null;
  reviewedBy: string | null;
  updatedAt: string;
  updatedBy: string;
}
