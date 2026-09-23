/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Explicit event-specific mini-profile selection. Pointers only; current membership, profile and card revisions must still match.
 */
export interface EventChatProfileShareDocument {
  eventId: string;
  uid: string;
  organizerId: string | null;
  revision: number;
  selection: {
    profileRevision: number;
    membershipRevision: number;
    /**
     * @maxItems 14
     */
    coreFieldIds: (
      | "age"
      | "gender"
      | "city"
      | "heightCm"
      | "occupation"
      | "company"
      | "education"
      | "languages"
      | "relationshipGoal"
      | "drinking"
      | "smoking"
      | "workout"
      | "diet"
      | "children"
    )[];
    photoId: string | null;
    card: {
      responseId: string;
      revision: number;
      /**
       * @minItems 1
       * @maxItems 20
       */
      questionIds: string[];
    } | null;
    termsVersion: "event-profile-sharing-v1";
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
}
