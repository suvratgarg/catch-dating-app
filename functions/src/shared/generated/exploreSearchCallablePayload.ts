/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by exploreSearch.
 */
export interface ExploreSearchCallablePayload {
  query: string;
  /**
   * Canonical launch market id. The field name is retained for callable compatibility.
   */
  cityName?: string;
  limit?: number;
}
