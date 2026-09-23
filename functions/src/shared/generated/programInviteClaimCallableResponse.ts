/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Result of redeeming a program staff invite. Carries the program the invite grants access to so the client can navigate into the work shell.
 */
export interface ProgramInviteClaimCallableResponse {
  programId: string;
  /**
   * True when this account already consumed the invite.
   */
  alreadyApplied: boolean;
}
