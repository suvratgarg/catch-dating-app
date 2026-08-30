/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Archives one reusable CRM audience with optimistic revision control.
 */
export interface ArchiveOrganizerSavedAudienceCallablePayload {
  organizerId: string;
  audienceId: string;
  expectedRevision: number;
}
