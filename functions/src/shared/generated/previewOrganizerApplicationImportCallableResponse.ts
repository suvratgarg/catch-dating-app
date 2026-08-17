/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Safe import preview with deterministic mapping suggestions and bounded row errors.
 */
export interface PreviewOrganizerApplicationImportCallableResponse {
  organizerId: string;
  formVersionId: string;
  /**
   * @maxItems 100
   */
  columns: {
    headerIndex: number;
    header: string;
    questionId: string | null;
    questionLabel: string | null;
    suggestionConfidence: "explicit" | "exact" | "alias" | "none";
  }[];
  /**
   * @maxItems 20
   */
  sampleRows: {
    rowId: string;
    displayName: string | null;
    /**
     * @maxItems 100
     */
    errors: {
      questionId: string | null;
      code: string;
      message: string;
    }[];
  }[];
  rowCount: number;
  validRowCount: number;
  invalidRowCount: number;
}
