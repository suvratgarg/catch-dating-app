/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private bounded Sales callable request. Server authorization and transaction policy are enforced separately.
 */
export interface AdminPreviewSalesImportCallablePayload {
  sourceId: string;
  contentHash: string;
  mappingVersion: string;
  /**
   * @minItems 1
   * @maxItems 25
   */
  rows: {
    sourceRowId: string;
    organizerId: string | null;
    name: string;
    researchStatus:
      | "new"
      | "needs_research"
      | "ready_for_review"
      | "qualified"
      | "benchmark_only"
      | "no_fit"
      | "archived";
    summary?: string | null;
    originalScore?: {
      [k: string]: string | number | boolean | null;
    } | null;
    /**
     * @maxItems 60
     */
    originalCells?: {
      column: string;
      value: string;
    }[];
  }[];
}
