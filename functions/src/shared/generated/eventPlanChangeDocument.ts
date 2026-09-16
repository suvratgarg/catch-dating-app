/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable server-authored event plan change stored at eventPlanChanges/{sourceId}. Each revision captures the attendee-relevant event facts after one committed host edit.
 */
export interface EventPlanChangeDocument {
  schemaVersion: 1;
  sourceId: string;
  eventId: string;
  organizerId: string;
  revision: number;
  /**
   * @minItems 1
   * @maxItems 5
   */
  changedFields: (
    | "name"
    | "schedule"
    | "meetingLocation"
    | "itinerary"
    | "format"
  )[];
  eventTitle: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  startTime: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  endTime: {
    _seconds: number;
    _nanoseconds: number;
  };
  meetingPoint: string;
  itineraryStopCount: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  occurredAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  validUntil: {
    _seconds: number;
    _nanoseconds: number;
  };
  createdBy: string;
}
