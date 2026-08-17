/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Published application form plus participant-private suggestions. Suggested values require explicit review and never grant organizer access.
 */
export interface GetParticipantOrganizerApplicationFormCallableResponse {
  organizerId: string;
  formId: string;
  formVersionId: string;
  targetKind: "organizer" | "event" | "campaign";
  targetId: string | null;
  title: string;
  description: string | null;
  /**
   * @minItems 1
   * @maxItems 100
   */
  questions: {
    question: {
      questionId: string;
      key: string;
      label: string;
      helpText: string | null;
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
        | "file";
      required: boolean;
      /**
       * @maxItems 100
       */
      options: {
        optionId: string;
        label: string;
        value: string;
      }[];
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
      privacyClass: "contact" | "profile" | "sensitive" | "organizerCustom";
      prefillPolicy: "never" | "participantReviewRequired";
      hostPresentation: "detailOnly" | "filterable" | "sortable";
    };
    suggestion: null | {
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
      source: "portableIntake" | "privateProfile" | "verifiedAuth";
      requiresParticipantReview: true;
    };
  }[];
  consentCopy: string;
  consentVersion: string;
  retentionCopy: string;
}
