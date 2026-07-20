/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Canonical owner or manager edge stored at organizerTeamMemberships/{organizerId_uid}.
 */
export interface OrganizerTeamMembershipDocument {
  organizerId: string;
  uid: string;
  role: "owner" | "manager";
  status: "active" | "removed";
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  removedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
