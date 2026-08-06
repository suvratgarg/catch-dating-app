/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Sanitized cancellation receipt for a pending invitation or accepted plan.
 */
export interface CancelCrossPathsInvitationOrPlanCallableResponse {
  invitationId: string;
  status: "cancelled" | "invalidated";
}
