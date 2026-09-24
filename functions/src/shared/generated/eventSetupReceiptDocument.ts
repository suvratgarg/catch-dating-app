/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventSetupReceiptDocument {
  operation: "create" | "update" | "preferences" | "details";
  actorUid: string;
  organizerId: string;
  requestHash: string;
  eventId: string;
  appliedRevision: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
