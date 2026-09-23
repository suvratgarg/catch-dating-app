/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Participant-only form review, with an optimistic profile revision and no unrelated CRM data.
 */
export interface GetParticipantFormProfileCallableResponse {
  responseId: string;
  organizerId: string;
  formId: string;
  formTitle: string;
  submittedAtMillis: number;
  /**
   * @maxItems 100
   */
  fields: {
    questionId: string;
    destination: "catchProfile" | "organizerCard";
    canonicalFieldId:
      | (
          | "givenName"
          | "familyName"
          | "displayName"
          | "dateOfBirth"
          | "age"
          | "gender"
          | "phoneNumber"
          | "email"
          | "instagramHandle"
          | "linkedinUrl"
          | "profilePhoto"
          | "city"
          | "heightCm"
          | "occupation"
          | "company"
          | "education"
          | "languages"
          | "relationshipGoal"
          | "interestedInGenders"
          | "drinking"
          | "smoking"
          | "religion"
          | "workout"
          | "diet"
          | "children"
        )
      | null;
    label: string;
    kind:
      | "shortText"
      | "longText"
      | "singleChoice"
      | "multiChoice"
      | "date"
      | "phone"
      | "email"
      | "url"
      | "number"
      | "boolean"
      | "file"
      | "acknowledgement"
      | "signature";
    value: string | number | boolean | null | string[];
    /**
     * @maxItems 100
     */
    options: {
      optionId: string;
      label: string;
      value: string;
    }[];
  }[];
  profileRevision: number;
  termsVersion: "form-profile-claim-v1";
  intakeRevision: number;
}
