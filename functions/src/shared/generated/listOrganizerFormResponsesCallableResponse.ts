/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Safe response inbox rows and opaque pagination cursor.
 */
export interface ListOrganizerFormResponsesCallableResponse {
  organizerId: string;
  /**
   * @maxItems 100
   */
  items: {
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
  }[];
  nextCursor: string | null;
}
