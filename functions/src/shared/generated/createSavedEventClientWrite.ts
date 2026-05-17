/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Client-owned Firestore create operation for savedEvents/{savedEventId}.
 */
export interface CreateSavedEventClientWrite {
  path: {
    savedEventId: string;
  };
  data: {
    uid: string;
    eventId: string;
    /**
     * Serialized Firestore Timestamp fixture shape.
     */
    savedAt: {
      _seconds: number;
      _nanoseconds: number;
    };
  };
}
