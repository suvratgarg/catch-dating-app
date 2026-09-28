/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Unique source-row lineage for successfully matched or created reviewed rows; rowKey is a source ID and row ID hash.
 */
export interface SalesImportRowDocument {
  schemaVersion: 1;
  classification: "sales_private";
  importId: string;
  sourceId: string;
  sourceRowId: string;
  sourceContentHash: string;
  mappingVersion: string;
  organizerId: string | null;
  disposition: "created" | "matched" | "duplicate" | "unresolved" | "rejected";
  reason: string;
  originalScore: {
    [k: string]: string | number | boolean | null;
  } | null;
  originalCells?:
    | {
        column: string;
        value: string;
      }[]
    | null;
  originalResearchStatus:
    | "new"
    | "needs_research"
    | "ready_for_review"
    | "qualified"
    | "benchmark_only"
    | "no_fit"
    | "archived";
  originalSummary: string | null;
  importedAt: string;
  importedBy: string;
  /**
   * @maxItems 30
   */
  cohortIds?: string[];
}
