/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-only identity evidence edge used for keyed candidate lookup. Hashes are restricted identifiers, not anonymous data.
 */
export interface OrganizerContactIdentityLinkDocument {
  organizerId: string;
  contactId: string;
  attendeeId: string;
  kind: "uid" | "phone" | "email" | "provider";
  identityHash: string;
  hashVersion: "hmac-sha256-v1";
  confidence: "proposed" | "verified";
  source: "catchBooking" | "hostImport" | "hostManual" | "webOtp";
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
