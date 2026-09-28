/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminPreviewSalesImportHistoryPayload {
  sourceId: string;
  contentHash: string;
  mappingVersion: string;
  promotionVersion: string;
  /**
   * @minItems 1
   * @maxItems 10
   */
  rows: {
    importId: string;
    sourceRowId: string;
    organizerId: string;
    disposition: "promoted" | "skipped" | "review_needed";
    reason: string;
    /**
     * @minItems 0
     * @maxItems 5
     */
    entries: {
      sourceColumn: string;
      sourceValue: string;
      kind: "activity" | "observation" | "benchmark";
      occurredAt: string | null;
      dateSourceColumn: string | null;
      dateSourceValue: string | null;
    }[];
  }[];
}
