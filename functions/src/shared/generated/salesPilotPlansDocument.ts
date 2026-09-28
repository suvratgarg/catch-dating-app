/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private revisioned pilot scope; no revenue or product activation authority.
 */
export interface SalesPilotPlansDocument {
  schemaVersion: 1;
  classification: "sales_private";
  organizerId: string;
  opportunityId: string;
  revision: number;
  status: "draft" | "reviewed" | "active" | "completed" | "cancelled";
  workflowId: string;
  objective: string;
  /**
   * @minItems 1
   * @maxItems 8
   */
  successMeasures: string[];
  startsAt: string | null;
  endsAt: string | null;
  reviewEvidence: {
    evidenceId: string;
    sourceRef: string;
    contentHash: string;
    observedAt: string;
  } | null;
  outcomeEvidence: {
    evidenceId: string;
    sourceRef: string;
    contentHash: string;
    observedAt: string;
  } | null;
  updatedAt: string;
  updatedBy: string;
}
