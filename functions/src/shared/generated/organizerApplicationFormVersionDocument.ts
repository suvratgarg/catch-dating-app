/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable published or imported snapshot of one organizer application form.
 */
export interface OrganizerApplicationFormVersionDocument {
  organizerId: string;
  formId: string;
  version: number;
  state: "draftSnapshot" | "published" | "retired";
  title: string;
  description: string | null;
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
  createdByUid: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  publishedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
