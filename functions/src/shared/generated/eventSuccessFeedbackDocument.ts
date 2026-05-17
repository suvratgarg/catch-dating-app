/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Attendee-owned decomposed post-event feedback stored at eventSuccessFeedback/{eventId_uid}. Hosts can read aggregate-relevant fields for their event report.
 */
export interface EventSuccessFeedbackDocument {
  eventId: string;
  clubId: string;
  uid: string;
  welcomeRating: number;
  structureRating: number;
  metNewPeopleCount: number;
  markedPrivateCrush: boolean;
  safetyConcern: boolean;
  privateNote?: string | null;
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
