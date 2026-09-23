/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface GetEventChatProfileSharingCallablePayload {
  eventId: string;
  expectedUid: string;
  /**
   * Owner-only proposed selection; no sharing receipt is written.
   */
  previewSelection?: {
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
    firstName?: string;
    introduction?: string;
    termsVersion: "event-profile-sharing-v1" | "event-profile-sharing-v2";
  };
}
