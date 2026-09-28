/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private bounded Sales callable request. Server authorization and transaction policy are enforced separately.
 */
export interface AdminSetSalesContactabilityCallablePayload {
  organizerId: string;
  contactId: string;
  requestId: string;
  expectedRevision: number;
  status: "unknown" | "draft_reviewed" | "held" | "suppressed";
  reason: string;
  evidenceId?: string | null;
}
