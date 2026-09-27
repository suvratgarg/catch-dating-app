/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Reviewed 25-row maximum import receipt; row details live in a private subcollection.
 */
export interface SalesImportJobDocument {
  schemaVersion: 1;
  classification: "sales_private";
  importId: string;
  sourceId: string;
  contentHash: string;
  mappingVersion: string;
  previewHash: string;
  rowCount: number;
  counts: {
    created: number;
    matched: number;
    duplicate: number;
    unresolved: number;
    rejected: number;
  };
  status: "applied";
  createdAt: string;
  createdBy: string;
}
