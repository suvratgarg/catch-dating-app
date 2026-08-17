/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Commits a bounded provider-neutral tabular application import.
 */
export interface ImportOrganizerApplicationsCallablePayload {
  organizerId: string;
  formId: string;
  formVersionId: string;
  targetKind: "organizer" | "event" | "campaign";
  targetId: string | null;
  mappingId: string | null;
  importKey: string;
  fileName: string;
  format: "csv" | "xlsx" | "connector";
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
