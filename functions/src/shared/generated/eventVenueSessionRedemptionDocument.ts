/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-only single-use receipt binding one attendee to one live venue session.
 */
export interface EventVenueSessionRedemptionDocument {
  eventId: string;
  sessionId: string;
  uid: string;
  purpose: "attendance" | "firstHello";
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  redeemedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  consumedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
