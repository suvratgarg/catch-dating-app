/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * New or idempotently reused organizer form editor state.
 */
export type CreateOrganizerFormCallableResponse = {
  form: {
    organizerId: string;
    formId: string;
    title: string;
    description: string | null;
    purpose:
      | "application"
      | "registration"
      | "intake"
      | "waiver"
      | "feedback"
      | "survey";
    status: "draft" | "published" | "paused" | "archived";
    templateId: string | null;
    publicFormId: string;
    defaultTargetKind: "organizer" | "event" | "campaign";
    defaultTargetId: string | null;
    activeVersionId: string | null;
    draftRevision: number;
    publishedVersion: number;
    submittedResponseCount: number;
    updatedAtMillis: number;
    publishedAtMillis: number | null;
    lastResponseAtMillis: number | null;
  };
  definition: {
    title: string;
    description: string | null;
    purpose:
      | "application"
      | "registration"
      | "intake"
      | "waiver"
      | "feedback"
      | "survey";
    defaultTargetKind: "organizer" | "event" | "campaign";
    defaultTargetId: string | null;
    identityPolicy:
      | "anonymous"
      | "emailVerified"
      | "phoneVerified"
      | "emailOrPhoneVerified"
      | "catchAccount";
    /**
     * @minItems 1
     * @maxItems 40
     */
    sections: {
      sectionId: string;
      title: string;
      description: string | null;
      pageBreak: boolean;
      /**
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
          | "file"
          | "acknowledgement"
          | "signature";
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
        validation: {
          minLength: number | null;
          maxLength: number | null;
          minNumber: number | null;
          maxNumber: number | null;
          earliestDate: string | null;
          latestDate: string | null;
          minSelections: number | null;
          maxSelections: number | null;
          maxFileCount: number | null;
          maxFileSizeBytes: number | null;
          /**
           * @maxItems 20
           */
          allowedMimeTypes: string[];
          patternPreset:
            | null
            | "lettersAndSpaces"
            | "alphanumeric"
            | "postalCode"
            | "handle";
          customError: string | null;
        };
      }[];
    }[];
    /**
     * @maxItems 100
     */
    logicRules: {
      ruleId: string;
      conditionMode: "all" | "any";
      /**
       * @minItems 1
       * @maxItems 20
       */
      conditions: {
        questionId: string;
        operator:
          | "equals"
          | "notEquals"
          | "contains"
          | "notContains"
          | "greaterThan"
          | "lessThan"
          | "answered"
          | "notAnswered";
        /**
         * @maxItems 20
         */
        expectedValues: (string | number | boolean)[];
      }[];
      action:
        | "showQuestion"
        | "hideQuestion"
        | "showSection"
        | "hideSection"
        | "routeToSection"
        | "finish";
      targetQuestionId: string | null;
      targetSectionId: string | null;
    }[];
    appearance: {
      preset: "editorial" | "minimal" | "activity";
      logoAssetId: string | null;
      coverAssetId: string | null;
      activityKind: string | null;
    };
    availability: {
      opensAt: {
        _seconds: number;
        _nanoseconds: number;
      } | null;
      closesAt: {
        _seconds: number;
        _nanoseconds: number;
      } | null;
      responseLimit: number | null;
      closedMessage: string | null;
    };
    consent: {
      consentCopy: string;
      consentVersion: string;
      retentionCopy: string;
    };
    completion: {
      title: string;
      message: string | null;
      actionKind: "none" | "externalUrl" | "event" | "eventRuntime";
      actionLabel: string | null;
      actionUrl: string | null;
    };
  };
  /**
   * @maxItems 250
   */
  validationIssues: {
    code: string;
    path: string;
    message: string;
    severity: "error" | "warning";
  }[];
};
