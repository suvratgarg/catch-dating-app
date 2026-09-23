/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {GetEventChatProfileCallableResponse} from "./getEventChatProfileCallableResponse";

export interface GetEventChatProfileSharingCallableResponse {
  eventId: string;
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
    firstName?: string;
    introduction?: string;
    termsVersion: "event-profile-sharing-v1" | "event-profile-sharing-v2";
  } | null;
  canShare: boolean;
  profileRevision: number;
  membershipRevision: number | null;
  /**
   * @maxItems 14
   */
  coreFields: {
    fieldId:
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
      | "children";
    value: string | number | boolean | string[];
  }[];
  /**
   * @maxItems 12
   */
  photoIds: string[];
  preview?: GetEventChatProfileCallableResponse | null;
}
