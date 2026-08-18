/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * One immutable response with classified answers and expiring asset downloads.
 */
export interface GetOrganizerFormResponseDetailCallableResponse {
  response: {
    responseId: string;
    formId: string;
    formTitle: string;
    versionId: string;
    version: number;
    status: "submitted" | "withdrawn";
    identityKind:
      | "anonymous"
      | "emailVerified"
      | "phoneVerified"
      | "catchAccount";
    identity: {
      displayName: string | null;
      email: string | null;
      phoneE164: string | null;
      searchName: string | null;
      origin: "anonymous" | "respondentGranted" | "organizerAcquired";
    };
    sourceLinkId: string | null;
    sourceLabel: string | null;
    submittedAtMillis: number;
    withdrawnAtMillis: number | null;
    /**
     * @maxItems 12
     */
    highlights: {
      questionId: string;
      label: string;
      answer: string | number | boolean | null | string[];
    }[];
    /**
     * @maxItems 4
     */
    conversionKinds: (
      | "crmContact"
      | "application"
      | "eventAttendeeProposal"
      | "followUp"
    )[];
  };
  /**
   * @maxItems 200
   */
  answers: {
    questionId: string;
    key: string;
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
    privacyClass: "contact" | "profile" | "sensitive" | "organizerCustom";
    hostPresentation: "detailOnly" | "filterable" | "sortable";
    answer: string | number | boolean | null | string[];
    origin: "anonymous" | "respondentGranted" | "organizerAcquired" | "revoked";
    /**
     * @maxItems 10
     */
    assetDownloads: {
      assetId: string;
      fileName: string;
      contentType: string;
      sizeBytes: number;
      downloadUrl: string;
      expiresAtMillis: number;
    }[];
  }[];
  consentVersion: string;
  completionMillis: number;
}
