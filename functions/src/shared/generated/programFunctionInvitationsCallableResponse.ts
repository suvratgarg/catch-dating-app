/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Acknowledgement for an invitation-list apply: the committed function revision plus the row diff that landed.
 */
export interface ProgramFunctionInvitationsCallableResponse {
  /**
   * The function document id.
   */
  entityId: string;
  revision: number;
  createdCount: number;
  revokedCount: number;
  keptCount: number;
  /**
   * True when an exact replay returned the original result.
   */
  alreadyApplied: boolean;
}
