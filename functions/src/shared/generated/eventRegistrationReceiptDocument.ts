/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventRegistrationReceiptDocument {
  organizerId: string;
  eventId: string;
  actorUid: string;
  requestHash: string;
  registrationRevision: number;
  mode: "closed" | "free" | "paid";
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
