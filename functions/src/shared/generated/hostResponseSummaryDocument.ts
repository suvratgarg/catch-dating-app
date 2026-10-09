/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-maintained response inbox metadata. No answer snapshots or asset URLs. Withdrawal atomically redacts a verified view or deletes an invalid view.
 */
export interface HostResponseSummaryDocument {
  organizerId: string;
  summaryId: string;
  kind: "response" | "application";
  formId: string;
  submittedAtMillis: number;
  row: {
    entryId: string;
    submittedAtMillis: number;
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
    } | null;
    application: {
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
        | "revokedParticipantGrant"
        | "submittedFormResponse";
      sourceKind: "native" | "tabularImport" | "connector";
      providerId: string | null;
      submittedAtMillis: number;
      revision: number;
      contactId?: string | null;
      sourceResponseId?: string | null;
    } | null;
  };
  version: 1;
}
