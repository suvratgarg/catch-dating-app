/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-only post-scoped, de-identified per-recipient retry evidence for an organizer follower update.
 */
export interface OrganizerPostDeliveryRecipientDocument {
  organizerId: string;
  postId: string;
  activityStatus: "created" | "existing" | "failed";
  pushStatus: "ineligible" | "accepted" | "failed" | "unknown";
  activityNotificationId: string;
  excluded: boolean;
  errorCode: string | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
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
