/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Lists a bounded organizer manual-send queue or history page.
 */
export interface ListOrganizerManualSendTasksCallablePayload {
  organizerId: string;
  activeOnly?: boolean;
  limit?: number;
  cursor?: string | null;
}
