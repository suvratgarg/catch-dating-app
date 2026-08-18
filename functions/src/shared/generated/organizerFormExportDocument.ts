/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Asynchronous, expiring, manager-requested form response export receipt.
 */
export interface OrganizerFormExportDocument {
  organizerId: string;
  formId: string;
  requestedByUid: string;
  requestId: string;
  format: "csv" | "xlsx";
  /**
   * @minItems 1
   * @maxItems 2
   */
  statuses: ("submitted" | "withdrawn")[];
  versionId: string | null;
  fromMillis: number | null;
  toMillis: number | null;
  status: "pending" | "running" | "completed" | "failed" | "expired";
  rowCount: number;
  storagePath: string | null;
  errorCode: string | null;
  errorMessage: string | null;
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
  completedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
