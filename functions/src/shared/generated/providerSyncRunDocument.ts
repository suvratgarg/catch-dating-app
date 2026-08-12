/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Idempotent audit and replay receipt for one external-provider event reconciliation.
 */
export interface ProviderSyncRunDocument {
  organizerId: string;
  eventId: string;
  connectionId: string;
  mappingId: string;
  provider: "luma";
  clientOperationId: string;
  inputHash: string;
  status: "running" | "completed" | "partial" | "failed";
  pageCount: number;
  receivedCount: number;
  createdCount: number;
  updatedCount: number;
  skippedCount: number;
  truncated: boolean;
  errorCode: string | null;
  startedByUid: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  startedAt: {
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
