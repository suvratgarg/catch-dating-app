/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-only, session-idempotent Cross Paths exposure receipt used for ranking fatigue. It contains no private preference values or roster projection.
 */
export interface CrossPathsSuggestionExposureDocument {
  viewerUid: string;
  candidateUid: string;
  eventId: string;
  sessionIdHash: string;
  rankingVersion: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  shownAt: {
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
