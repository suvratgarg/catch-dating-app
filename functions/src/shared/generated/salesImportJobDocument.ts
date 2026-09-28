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
  /**
   * @maxItems 25
   */
  accountEffects?: {
    organizerId: string;
    /**
     * @minItems 1
     * @maxItems 25
     */
    sourceRowIds: string[];
    created: boolean;
    revisionBefore: number | null;
    revisionAfter: number;
    /**
     * @maxItems 30
     */
    cohortIdsBefore: string[];
    /**
     * @maxItems 30
     */
    cohortIdsAfter: string[];
    /**
     * @maxItems 30
     */
    cohortIdsAdded: string[];
    cohortMutationIdBefore: string | "initial" | null;
    cohortMutationIdAfter: string | "initial";
    createdAccountHash: string | null;
  }[];
}
