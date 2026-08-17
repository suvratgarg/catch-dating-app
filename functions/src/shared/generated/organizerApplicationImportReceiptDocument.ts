/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Idempotency and result receipt for one bounded application import commit.
 */
export interface OrganizerApplicationImportReceiptDocument {
  organizerId: string;
  formId: string;
  formVersionId: string;
  mappingId: string | null;
  uploadedByUid: string;
  importKey: string;
  fileName: string;
  format: "csv" | "xlsx" | "connector";
  payloadHash: string;
  status: "completed" | "partial" | "failed";
  rowCount: number;
  createdCount: number;
  skippedCount: number;
  /**
   * @maxItems 100
   */
  errors: {
    rowId: string;
    code: string;
    message: string;
  }[];
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  completedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
