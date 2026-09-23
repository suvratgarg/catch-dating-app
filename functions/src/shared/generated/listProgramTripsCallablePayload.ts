/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Scoped trip ledger page, ordered by departure time descending.
 */
export interface ListProgramTripsCallablePayload {
  programId: string;
  limit?: number;
  /**
   * Opaque cursor returned by the previous page.
   */
  cursor?: string;
}
