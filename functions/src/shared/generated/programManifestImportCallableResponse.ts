/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manifest import plan or commit summary. Row errors never silently drop data: every rejected row reports its index and reason.
 */
export interface ProgramManifestImportCallableResponse {
  mode: "preview" | "commit";
  totalRows: number;
  guestsCreated: number;
  guestsUpdated: number;
  legsCreated: number;
  legsUpdated: number;
  householdsCreated: number;
  partiesCreated: number;
  rowErrors: {
    index: number;
    message: string;
  }[];
  alreadyApplied: boolean;
}
