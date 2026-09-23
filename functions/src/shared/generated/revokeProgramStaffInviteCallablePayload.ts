/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Revoke a pending program staff invite so the link can no longer be claimed. Manager-only; claimed invites are unaffected (revoke the grant instead).
 */
export interface RevokeProgramStaffInviteCallablePayload {
  programId: string;
  inviteId: string;
}
