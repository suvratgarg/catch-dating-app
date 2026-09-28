/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminRefreshSalesFitQueueBatchResponse {
  /**
   * @maxItems 10
   */
  rows: {
    organizerId: string;
    result: "refreshed" | "needs_review";
    sourceHash: string | null;
    reason: string | null;
  }[];
  nextCursor: string | null;
}
