/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminSalesIntelligenceClauseCallablePayload {
  requestId: string;
  clauseId: string;
  organizerId: string;
  expectedRevision: number;
  kind: "observation" | "capability" | "reference" | "cta";
  text: string;
  /**
   * @maxItems 8
   */
  evidenceIds: string[];
  validUntil: string;
  permission: "not_required" | "private_mention" | "withdrawn";
}
