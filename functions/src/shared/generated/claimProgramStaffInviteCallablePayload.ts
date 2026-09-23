/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Redeem a staff invite. The caller must be signed in with a verified phone number matching the invite's bound phone; on success a programStaffGrants document is written and the invite is consumed.
 */
export interface ClaimProgramStaffInviteCallablePayload {
  inviteId: string;
}
