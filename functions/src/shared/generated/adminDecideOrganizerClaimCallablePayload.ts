/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by adminDecideOrganizerClaim.
 */
export interface AdminDecideOrganizerClaimCallablePayload {
  requestId: string;
  decision: "approve" | "reject";
  decisionReason?: string | null;
}
