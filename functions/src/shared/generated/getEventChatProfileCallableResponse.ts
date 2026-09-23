/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {GetParticipantFormPhotoCallableResponse} from "./getParticipantFormPhotoCallableResponse";

export interface GetEventChatProfileCallableResponse {
  eventId: string;
  participantUid: string;
  displayName: string;
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
   * @maxItems 20
   */
  cardFields: {
    label: string;
    value: string | number | boolean | string[];
  }[];
  photo: GetParticipantFormPhotoCallableResponse | null;
}
