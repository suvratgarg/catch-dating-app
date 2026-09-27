/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable per-row review result for every row in a bounded import job.
 */
export interface SalesImportJobRowDocument {
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
}
