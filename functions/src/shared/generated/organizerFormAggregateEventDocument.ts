/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Idempotency marker for one aggregate projection event.
 */
export interface OrganizerFormAggregateEventDocument {
  organizerId: string;
  formId: string;
  versionId: string;
  responseId: string;
  eventKind: "submitted" | "withdrawn";
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  projectedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
