/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private bounded Sales callable request. Server authorization and transaction policy are enforced separately.
 */
export interface AdminSetSalesAccountSuppressionCallablePayload {
  organizerId: string;
  requestId: string;
  expectedRevision: number;
  status: "clear" | "held" | "suppressed";
  reason: string;
}
