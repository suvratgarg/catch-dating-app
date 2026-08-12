/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Singleton organizer-scoped ownership claim for a person-verified UID or phone identity.
 */
export interface OrganizerContactIdentityClaimDocument {
  organizerId: string;
  kind: "uid" | "phone";
  identityHash: string;
  hashVersion: "hmac-sha256-v1";
  verifiedContactId: string;
  originVerifiedContactId: string;
  state: "verified" | "conflicted";
  /**
   * @maxItems 20
   */
  conflictingContactIds: string[];
  revision: number;
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
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
