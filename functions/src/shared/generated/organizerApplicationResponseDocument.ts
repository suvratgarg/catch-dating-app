/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable answer snapshot for one native, imported, or connector-originated organizer application response.
 */
export interface OrganizerApplicationResponseDocument {
  organizerId: string;
  applicationId: string;
  formId: string;
  formVersionId: string;
  linkedUid: string | null;
  /**
   * @minItems 1
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
  source: {
    kind: "native" | "tabularImport" | "connector";
    providerId: string | null;
    externalFormId: string | null;
    externalResponseId: string | null;
    importReceiptId: string | null;
  };
  consentVersion: string | null;
  grantId: string | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  submittedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
