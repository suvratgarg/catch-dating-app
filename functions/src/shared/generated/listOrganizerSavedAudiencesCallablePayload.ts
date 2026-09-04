/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Lists one organizer's reusable CRM audiences.
 */
export interface ListOrganizerSavedAudiencesCallablePayload {
  organizerId: string;
  status?: "active" | "archived";
  limit?: number;
  cursor?: string | null;
  includeFilterOptions?: boolean;
}
