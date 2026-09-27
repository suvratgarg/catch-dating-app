/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Employee-reviewed factor rating linked to existing reviewed Sales evidence; unknown and disputed ratings cannot score.
 */
export interface SalesIntelligenceAssessmentsDocument {
  schemaVersion: 1;
  classification: "sales_private";
  assessmentId: string;
  organizerId: string;
  factorId: string;
  revision: number;
  state: "known" | "unknown" | "disputed";
  value: number | null;
  /**
   * @maxItems 8
   */
  evidenceIds: string[];
  reason: string | null;
  reviewedAt: string;
  reviewerUid: string;
}
