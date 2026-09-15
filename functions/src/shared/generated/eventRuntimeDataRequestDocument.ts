/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Current source-fenced request for missing event-scoped runtime profile data.
 */
export interface EventRuntimeDataRequestDocument {
  schemaVersion: 1;
  requestId: string;
  eventId: string;
  organizerId: string;
  attendeeId: string;
  uid: string;
  revision: number;
  profileRevision: number;
  sourceHash: string;
  operationId: string;
  /**
   * @minItems 1
   * @maxItems 10
   */
  fieldIds: (
    | "displayName"
    | "gender"
    | "interestedInGenders"
    | "relationshipGoal"
    | "dateOfBirth"
    | "paceBand"
    | "skillBand"
    | "dietaryAndSeatingNotes"
    | "questionnaireAnswerIds"
    | "teamName"
  )[];
  /**
   * @maxItems 10
   */
  completedFieldIds: (
    | "displayName"
    | "gender"
    | "interestedInGenders"
    | "relationshipGoal"
    | "dateOfBirth"
    | "paceBand"
    | "skillBand"
    | "dietaryAndSeatingNotes"
    | "questionnaireAnswerIds"
    | "teamName"
  )[];
  status: "pending" | "completed";
  requestedBy: "systemWithinPolicy";
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  requestedAt: {
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
  completedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
