/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Owner-submitted launch access application stored at accessApplications/{uid}; review and cohort fields are admin-owned.
 */
export interface AccessApplicationDocument {
  applicationVersion: number;
  status:
    | "pending"
    | "waitlisted"
    | "invited"
    | "approvedForProfile"
    | "activeMember"
    | "paused"
    | "notSelectedYet";
  city: string;
  role: "member" | "host" | "both";
  /**
   * @minItems 1
   * @maxItems 7
   */
  eventTypes: (
    | "runClub"
    | "walkingSocial"
    | "coffee"
    | "boardGames"
    | "fitnessClass"
    | "food"
    | "culture"
  )[];
  /**
   * @minItems 1
   * @maxItems 6
   */
  availabilityWindows: (
    | "weekdayMornings"
    | "weekdayEvenings"
    | "saturdayMornings"
    | "saturdayEvenings"
    | "sundayMornings"
    | "sundayEvenings"
  )[];
  wantsToHost: boolean;
  inviteCode?: string | null;
  instagramHandle?: string | null;
  referralSource?: string | null;
  whyCatch?: string | null;
  cohortId?: string | null;
  hostUserId?: string | null;
  reviewerUid?: string | null;
  reviewNote?: string | null;
  submissionCount: number;
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
  submittedAt: {
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
  reviewedAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
