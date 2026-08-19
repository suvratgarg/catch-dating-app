/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned retry state and aggregate delivery receipt for one organizer follower update.
 */
export interface OrganizerPostDeliveryOperationDocument {
  organizerId: string;
  postId: string;
  authorUid: string;
  requestId: string;
  payloadHash: string;
  status: "pending" | "processing" | "completed" | "partial";
  remainingWeeklyQuota: number;
  cursorFollowId: string | null;
  recipientCount: number;
  excludedCount: number;
  activityAvailableCount: number;
  pushAttemptedCount: number;
  pushAcceptedCount: number;
  pushFailedCount: number;
  pushUnknownCount: number;
  /**
   * @maxItems 20
   */
  errorCodes: string[];
  attemptCount: number;
  leaseOwner: string | null;
  leaseExpiresAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
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
  completedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
