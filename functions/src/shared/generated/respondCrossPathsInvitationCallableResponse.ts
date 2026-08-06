/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Sanitized terminal response after accepting or declining an invitation.
 */
export interface RespondCrossPathsInvitationCallableResponse {
  invitationId: string;
  status: "accepted" | "declined";
  conversationId: string | null;
  pairHoldId: string | null;
}
