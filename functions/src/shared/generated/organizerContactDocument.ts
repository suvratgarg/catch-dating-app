/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned organizer-scoped contact projection. It is not a Consumer profile and may contain restricted operational contact data.
 */
export interface OrganizerContactDocument {
  organizerId: string;
  displayName: string;
  searchName: string;
  linkedUid: string | null;
  phoneE164: string | null;
  email: string | null;
  identityState: "unlinked" | "verified" | "ambiguous" | "merged";
  identityConfidence: "eventOnly" | "proposed" | "verified";
  primarySource: "catchBooking" | "hostImport" | "hostManual" | "webOtp";
  /**
   * @maxItems 20
   */
  ambiguousCandidateContactIds: string[];
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  firstSeenAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  lastSeenAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  sourceCount: number;
  whatsappStatus: "unknown" | "optedIn" | "optedOut";
  smsStatus: "unknown" | "optedIn" | "optedOut";
  revision: number;
  mergedIntoContactId: string | null;
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
  deletedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
