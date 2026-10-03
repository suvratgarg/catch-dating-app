/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Durable journal for one program's archive-anonymization run. Document id equals the program id (a program anonymizes at most once). Phases record per-collection progress so a crashed or chunked run resumes idempotently.
 */
export interface ProgramRetentionRunDocument {
  programId: string;
  organizerId: string;
  status: "running" | "completed" | "failed";
  /**
   * Per-collection progress journal; one entry per scrubbed collection, appended in order as phases complete.
   *
   * @maxItems 23
   */
  phases: {
    collection: string;
    processed: number;
    /**
     * Last document id processed in this phase; resume token for chunked sweeps.
     */
    cursor: string | null;
    completedAtMillis?: number | null;
  }[];
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  startedAt: {
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
  completedAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  leaseUntil: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Fencing token for the worker currently holding the run lease.
   */
  leaseToken: string | null;
  error: string | null;
  revision: number;
}
