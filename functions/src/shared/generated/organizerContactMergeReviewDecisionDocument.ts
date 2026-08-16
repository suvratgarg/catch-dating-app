/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Latest manager decision for one deterministic organizer-contact candidate pair. A different-people decision suppresses the pair until the same manager reopens it.
 */
export interface OrganizerContactMergeReviewDecisionDocument {
  schemaVersion: 1;
  decisionId: string;
  organizerId: string;
  /**
   * @minItems 2
   * @maxItems 2
   */
  contactIds: string[];
  state: "differentPeople" | "reopened";
  reviewedByUid: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  reviewedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  reopenedByUid: string | null;
  reopenedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  revision: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
