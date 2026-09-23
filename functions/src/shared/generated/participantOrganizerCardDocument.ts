/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Participant-owned selection of applicant-submitted organizer-card fields. No CRM content or event sharing permission.
 */
export interface ParticipantOrganizerCardDocument {
  uid: string;
  organizerId: string;
  responseId: string;
  /**
   * @maxItems 100
   */
  questionIds: string[];
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
