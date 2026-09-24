/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventOfferConfigurationReceiptDocument {
  actorUid: string;
  organizerId: string;
  requestId: string;
  requestHash: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  appliedPreferencesRevision: number;
  eventId: string;
}
