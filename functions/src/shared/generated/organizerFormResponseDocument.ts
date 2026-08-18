/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable submitted response envelope with withdrawal state.
 */
export interface OrganizerFormResponseDocument {
  organizerId: string;
  formId: string;
  versionId: string;
  publicFormId: string;
  draftId: string;
  status: "submitted" | "withdrawn";
  identityKind:
    | "anonymous"
    | "emailVerified"
    | "phoneVerified"
    | "catchAccount";
  respondentUid: string | null;
  identity: {
    displayName: string | null;
    email: string | null;
    phoneE164: string | null;
    searchName: string | null;
    origin: "anonymous" | "respondentGranted" | "organizerAcquired";
  };
  withdrawalTokenHash: string | null;
  answers: {
    [k: string]: string | number | boolean | null | string[];
  };
  /**
   * @maxItems 4000
   */
  answerSnapshots: {
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
    answer: string | number | boolean | null | string[];
  }[];
  consentVersion: string;
  sourceLinkId: string | null;
  completionMillis: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  submittedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  withdrawnAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
