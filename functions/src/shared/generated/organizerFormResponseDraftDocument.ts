/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Expiring version-bound respondent autosave state.
 */
export interface OrganizerFormResponseDraftDocument {
  organizerId: string;
  formId: string;
  versionId: string;
  publicFormId: string;
  status: "active" | "submitted" | "expired" | "withdrawn";
  revision: number;
  identityKind:
    | "anonymous"
    | "emailVerified"
    | "phoneVerified"
    | "catchAccount";
  respondentUid: string | null;
  draftTokenHash: string | null;
  answers: {
    [k: string]: string | number | boolean | null | string[];
  };
  consentAccepted: boolean;
  consentVersion: string;
  sourceLinkId: string | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  submittedResponseId: string | null;
}
