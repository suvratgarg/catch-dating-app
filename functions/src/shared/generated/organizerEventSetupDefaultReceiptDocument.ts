/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface OrganizerEventSetupDefaultReceiptDocument {
  actorUid: string;
  organizerId: string;
  requestId: string;
  requestHash: string;
  appliedRevision: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
