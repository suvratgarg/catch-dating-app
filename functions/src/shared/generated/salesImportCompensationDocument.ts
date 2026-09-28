/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable private per-import per-organizer compensating effect; original job and lineage remain intact.
 */
export interface SalesImportCompensationDocument {
  schemaVersion: 1;
  classification: "sales_private";
  effectId: string;
  importId: string;
  organizerId: string;
  mode: "archive_companion" | "remove_cohorts";
  /**
   * @minItems 1
   * @maxItems 25
   */
  sourceRowIds: string[];
  /**
   * @maxItems 30
   */
  cohortIdsRemoved: string[];
  beforeRevision: number;
  afterRevision: number;
  beforeCohortMutationId: string | "initial";
  afterCohortMutationId: string;
  reason: string;
  createdAt: string;
  createdBy: string;
  requestId: string;
}
