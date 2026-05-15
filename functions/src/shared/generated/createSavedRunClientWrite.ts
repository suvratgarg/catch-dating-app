/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Client-owned Firestore create operation for savedRuns/{savedRunId}.
 */
export interface CreateSavedRunClientWrite {
  path: {
    savedRunId: string;
  };
  data: {
    uid: string;
    runId: string;
    /**
     * Serialized Firestore Timestamp fixture shape.
     */
    savedAt: {
      _seconds: number;
      _nanoseconds: number;
    };
  };
}
