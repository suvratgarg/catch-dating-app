/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Provider-neutral tabular application preview after local CSV or XLSX decoding.
 */
export interface PreviewOrganizerApplicationImportCallablePayload {
  organizerId: string;
  formVersionId: string;
  /**
   * @minItems 1
   * @maxItems 100
   */
  headers: string[];
  /**
   * @maxItems 100
   */
  mappings: {
    headerIndex: number;
    questionId: string | null;
    transform:
      | "identity"
      | "trim"
      | "e164"
      | "isoDate"
      | "number"
      | "boolean"
      | "splitOptions"
      | "assetUrl";
  }[];
  /**
   * @minItems 1
   * @maxItems 200
   */
  rows: {
    rowId: string;
    /**
     * @minItems 1
     * @maxItems 100
     */
    values: (string | null)[];
  }[];
}
