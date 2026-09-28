/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminListSalesImportHistoryRowsResponse {
  /**
   * @maxItems 25
   */
  rows: {
    schemaVersion: 1;
    classification: "sales_private";
    sourceId: string;
    sourceRowId: string;
    sourceContentHash: string;
    importId: string;
    organizerId: string;
    promotionVersion: string;
    rowId: string;
    disposition: "promoted" | "skipped" | "review_needed";
    reason: string;
    /**
     * @minItems 0
     * @maxItems 5
     */
    recordIds: string[];
    reviewHash: string;
    reviewedAt: string;
    reviewedBy: string;
  }[];
  nextCursor: string | null;
}
