/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Resolves an exact bounded preview for one saved CRM audience.
 */
export interface PreviewOrganizerSavedAudienceCallablePayload {
  organizerId: string;
  audienceId: string;
  expectedRevision?: number | null;
  sampleLimit?: number;
  cursor?: string | null;
}
