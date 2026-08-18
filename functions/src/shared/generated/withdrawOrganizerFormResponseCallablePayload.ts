/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Idempotently withdraws one submitted response under respondent authority.
 */
export interface WithdrawOrganizerFormResponseCallablePayload {
  responseId: string;
  withdrawalToken: string | null;
  requestId: string;
}
