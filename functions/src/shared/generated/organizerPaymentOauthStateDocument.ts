/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Single-use hashed OAuth state bound to initiating user, organizer, connection and mode.
 */
export interface OrganizerPaymentOauthStateDocument {
  organizerId: string;
  connectionId: string;
  actorUid: string;
  mode: "test" | "live";
  status: "pending" | "exchanging" | "completed" | "failed";
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
  completedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
