/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Identity and exact grant receipt for a native participant application.
 */
export interface SubmitParticipantOrganizerApplicationCallableResponse {
  organizerId: string;
  applicationId: string;
  responseId: string;
  grantId: string;
  reviewStatus: "submitted";
  intakeProfileRevision: number | null;
  replayed: boolean;
}
