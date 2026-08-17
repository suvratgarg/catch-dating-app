/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Safe organizer application review rows and opaque pagination state.
 */
export interface ListOrganizerApplicationsCallableResponse {
  organizerId: string;
  /**
   * @maxItems 100
   */
  applications: {
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
    sourceKind: "native" | "tabularImport" | "connector";
    providerId: string | null;
    submittedAtMillis: number;
    revision: number;
  }[];
  nextCursor: string | null;
}
