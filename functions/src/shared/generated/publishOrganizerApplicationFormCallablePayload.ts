/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Creates or revises and publishes one provider-neutral organizer application form.
 */
export interface PublishOrganizerApplicationFormCallablePayload {
  organizerId: string;
  formId: string | null;
  expectedRevision: number | null;
  title: string;
  description: string | null;
  defaultTargetKind: "organizer" | "event" | "campaign";
  /**
   * @minItems 1
   * @maxItems 100
   */
  questions: {
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
  }[];
  consentCopy: string;
  consentVersion: string;
  retentionCopy: string;
}
