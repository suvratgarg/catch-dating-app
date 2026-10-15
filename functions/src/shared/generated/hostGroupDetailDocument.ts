/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {OrganizerSavedAudienceCallableResponse} from "./organizerSavedAudienceCallableResponse";

/**
 * Server-maintained organizer-scoped Host read view. Never identity, permission or mutation authority.
 */
export interface HostGroupDetailDocument {
  organizerId: string;
  audienceId: string;
  row: OrganizerSavedAudienceCallableResponse;
  version: 1;
}
