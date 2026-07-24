/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Canonical organizer review stored at reviews/{reviewId}. Verified reviews come from attended Catch events; unverified reviews can come from public listing pages.
 */
export interface ReviewDocument {
  /**
   * Deprecated organizer id alias retained while released clients migrate.
   */
  clubId: string;
  organizerId: string;
  eventId?: string | null;
  /**
   * Catch user id for signed-in reviewers. Null for anonymous public listing reviews.
   */
  reviewerUserId: string | null;
  reviewerName: string;
  rating: number;
  comment: string;
  /**
   * Verified reviews are created only after attended Catch events; public listing reviews are unverified.
   */
  verificationStatus?: "verified" | "unverified";
  /**
   * Submission surface that created the review.
   */
  source?: "catchEvent" | "publicListing";
  /**
   * Public rendering status for organizer listing pages.
   */
  moderationStatus?: "published" | "pending" | "rejected";
  /**
   * True when the public display name should be the anonymous fallback rather than a user-supplied or profile name.
   */
  isAnonymous?: boolean;
  /**
   * Website path that submitted an unverified public listing review.
   */
  submittedFromPath?: string | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  updatedAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  ownerResponse?: {
    hostUserId: string;
    hostName: string;
    hostAvatarUrl: string | null;
    message: string;
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
  };
  /**
   * Internal demo seed marker used for cleanup and diagnostics.
   */
  synthetic?: boolean;
  /**
   * Internal demo seed prefix used for cleanup and diagnostics.
   */
  seedPrefix?: string;
  /**
   * Internal demo seed scenario name used for cleanup and diagnostics.
   */
  scenario?: string;
  /**
   * Internal demo-operations marker used for cleanup and diagnostics.
   */
  demoOps?: boolean;
  /**
   * Internal demo-operations id used for cleanup and diagnostics.
   */
  demoOpsId?: string;
  /**
   * Internal demo-operations command name used for cleanup and diagnostics.
   */
  demoOpsCommand?: string;
}
