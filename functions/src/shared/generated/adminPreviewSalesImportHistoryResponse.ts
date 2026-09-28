/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminPreviewSalesImportHistoryResponse {
  previewHash: string;
  /**
   * @minItems 1
   * @maxItems 10
   */
  rows: {
    sourceRowId: string;
    organizerId: string;
    status: "promoted" | "skipped" | "review_needed" | "duplicate";
    /**
     * @minItems 0
     * @maxItems 5
     */
    recordIds: string[];
  }[];
  packetRowCount: number;
  effectsApplied: false;
}
