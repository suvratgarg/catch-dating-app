/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable idempotency receipt for one required-data command.
 */
export interface EventRuntimeDataRequestReceiptDocument {
  schemaVersion: 1;
  receiptId: string;
  requestId: string;
  eventId: string;
  organizerId: string;
  attendeeId: string;
  uid: string;
  operationId: string;
  requestHash: string;
  requestRevision: number;
  profileRevision: number;
  sourceHash: string;
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
   * Serialized Firestore Timestamp fixture shape.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
