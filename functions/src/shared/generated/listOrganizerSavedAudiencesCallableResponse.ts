/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import {OrganizerSavedAudienceCallableResponse} from "./organizerSavedAudienceCallableResponse";

/**
 * One bounded page of reusable organizer CRM audiences.
 */
export interface ListOrganizerSavedAudiencesCallableResponse {
  organizerId: string;
  /**
   * @maxItems 50
   */
  audiences: OrganizerSavedAudienceCallableResponse[];
  nextCursor: string | null;
}
