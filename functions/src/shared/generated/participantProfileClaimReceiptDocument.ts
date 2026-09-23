/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Idempotency proof for a participant-reviewed form profile claim. Contains no submitted answers.
 */
export interface ParticipantProfileClaimReceiptDocument {
  uid: string;
  responseId: string;
  payloadHash: string;
  profileRevision: number;
  organizerCardId: string | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
