/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Strict private Sales commercial request; current role, scope, revision and evidence policy are transactional.
 */
export interface AdminUpsertSalesPilotPlanCallablePayload {
  organizerId: string;
  opportunityId: string;
  requestId: string;
  expectedRevision: number;
  plan: {
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
    } | null;
    outcomeEvidence: {
      evidenceId: string;
    } | null;
  };
}
