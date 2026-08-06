/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Recipient-only response accepted by respondCrossPathsInvitation.
 */
export interface RespondCrossPathsInvitationCallablePayload {
  invitationId: string;
  decision: "accept" | "decline";
}
