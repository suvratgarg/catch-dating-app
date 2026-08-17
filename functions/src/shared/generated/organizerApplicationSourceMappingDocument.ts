/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Reusable provider-neutral mapping from external tabular columns to one Catch form version.
 */
export interface OrganizerApplicationSourceMappingDocument {
  organizerId: string;
  formId: string;
  formVersionId: string;
  name: string;
  sourceKind: "csv" | "xlsx" | "connector";
  providerId: string | null;
  externalFormId: string | null;
  headerFingerprint: string;
  /**
   * @minItems 1
   * @maxItems 250
   */
  columns: {
    sourceHeader: string;
    sourceHeaderNormalized: string;
    action: "map" | "ignore";
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
  createdByUid: string;
  revision: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
