/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private bounded Sales callable request. Server authorization and transaction policy are enforced separately.
 */
export interface AdminUpdateSalesAccountCallablePayload {
  organizerId: string;
  requestId: string;
  expectedRevision: number;
  patch: {
    researchStatus?:
      | "new"
      | "needs_research"
      | "ready_for_review"
      | "qualified"
      | "benchmark_only"
      | "no_fit"
      | "archived";
    assignedOwnerUid?: string | null;
    summary?: string | null;
    nextAction?: string | null;
  };
}
