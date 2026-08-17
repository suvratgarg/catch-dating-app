/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-only application answers, source context, and validated outreach actions.
 */
export interface GetOrganizerApplicationDetailCallableResponse {
  organizerId: string;
  applicationId: string;
  formId: string;
  formVersionId: string;
  targetKind: "organizer" | "event" | "campaign";
  targetId: string | null;
  applicantDisplayName: string;
  reviewStatus:
    | "submitted"
    | "inReview"
    | "approved"
    | "waitlisted"
    | "declined"
    | "withdrawn";
  dataAccessState:
    | "organizerImported"
    | "activeParticipantGrant"
    | "revokedParticipantGrant";
  /**
   * @maxItems 100
   */
  answers: {
    questionId: string;
    questionKey: string;
    questionLabel: string;
    questionKind:
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
    hostPresentation: "detailOnly" | "filterable" | "sortable";
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
  outreach: {
    phoneE164: string | null;
    email: string | null;
    instagramUrl: string | null;
    linkedinUrl: string | null;
  };
  reviewNote: string | null;
  assignedReviewerUid: string | null;
  submittedAtMillis: number;
  reviewedAtMillis: number | null;
  revision: number;
}
