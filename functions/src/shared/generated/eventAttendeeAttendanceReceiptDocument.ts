/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Short-lived server-only idempotency receipt for one absolute Host attendance operation.
 */
export interface EventAttendeeAttendanceReceiptDocument {
  eventId: string;
  organizerId: string;
  attendeeId: string;
  actorUid: string;
  clientOperationId: string;
  desiredCheckedIn: boolean;
  priorRevision: number;
  acceptedRevision: number;
  changed: boolean;
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
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
