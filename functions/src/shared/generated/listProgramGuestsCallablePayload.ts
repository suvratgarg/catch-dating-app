/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager/coordinator paginated guest listing.
 */
export interface ListProgramGuestsCallablePayload {
  programId: string;
  limit?: number;
  /**
   * Opaque cursor returned by the previous page.
   */
  cursor?: string;
}
