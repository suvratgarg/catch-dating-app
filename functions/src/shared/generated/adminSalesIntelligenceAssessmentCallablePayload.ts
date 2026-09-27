/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminSalesIntelligenceAssessmentCallablePayload {
  requestId: string;
  organizerId: string;
  factorId: string;
  expectedRevision: number;
  state: "known" | "unknown" | "disputed";
  value: number | null;
  /**
   * @maxItems 8
   */
  evidenceIds: string[];
  reason: string | null;
}
