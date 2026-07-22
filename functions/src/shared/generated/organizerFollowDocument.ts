/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Canonical consumer follow edge stored at organizerFollows/{organizerId_uid}.
 */
export interface OrganizerFollowDocument {
  organizerId: string;
  uid: string;
  status: "active" | "inactive";
  pushNotificationsEnabled: boolean;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  followedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  unfollowedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
