/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Submits one participant-reviewed native application and an exact organizer field grant.
 */
export interface SubmitParticipantOrganizerApplicationCallablePayload {
  organizerId: string;
  formId: string;
  formVersionId: string;
  targetKind: "organizer" | "event" | "campaign";
  targetId: string | null;
  submissionKey: string;
  /**
   * @minItems 1
   * @maxItems 100
   */
  answers: {
    questionId: string;
    value: {
      valueKind:
        | "empty"
        | "text"
        | "number"
        | "boolean"
        | "date"
        | "options"
        | "assets";
      textValue: string | null;
      numberValue: number | null;
      booleanValue: boolean | null;
      dateValue: string | null;
      /**
       * @maxItems 100
       */
      optionValues: string[];
      /**
       * @maxItems 10
       */
      assetIds: string[];
    };
  }[];
  /**
   * @minItems 1
   * @maxItems 100
   */
  reviewedQuestionIds: string[];
  /**
   * @maxItems 40
   */
  saveToIntakeCanonicalFieldIds: (
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
  )[];
  consentVersion: string;
  confirmedConsent: true;
}
