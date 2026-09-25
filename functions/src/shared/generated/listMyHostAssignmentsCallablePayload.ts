/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Lists the caller's live staff assignments across program and event scopes for the unified host work shell. No filters: the shell needs the caller's full live set.
 */
export interface ListMyHostAssignmentsCallablePayload {
  /**
   * When true also returns expired grants for history views; the shell entry decision still uses live assignments only.
   */
  includeExpired?: boolean;
}
