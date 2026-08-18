/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * One bounded page of manager-safe organizer form summaries.
 */
export interface ListOrganizerFormsCallableResponse {
  organizerId: string;
  /**
   * @maxItems 100
   */
  items: {
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
  }[];
  nextCursor: string | null;
}
