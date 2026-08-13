/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Short-lived server-owned venue-presence authority shown only in the Host live QR.
 */
export interface EventVenueSessionDocument {
  eventId: string;
  organizerId: string;
  createdBy: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  issuedAt: {
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
