/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Metadata only after exact account, response and immutable-version proof.
 */
export interface ListParticipantActivityCallableResponse {
  /**
   * @maxItems 30
   */
  items: {
    sourceKind: "formResponse";
    sourceId: string;
    organizerId: string;
    formId: string;
    versionId: string;
    eventId: string | null;
    formTitle: string;
    purpose:
      | "application"
      | "registration"
      | "intake"
      | "waiver"
      | "feedback"
      | "survey";
    submittedAtMillis: number;
  }[];
  nextCursor: string | null;
}
