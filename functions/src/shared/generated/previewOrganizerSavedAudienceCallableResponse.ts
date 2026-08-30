/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import {OrganizerSavedAudienceCallableResponse} from "./organizerSavedAudienceCallableResponse";

/**
 * Exact saved-audience preview. Incomplete or over-limit evaluation fails instead of returning this shape.
 */
export interface PreviewOrganizerSavedAudienceCallableResponse {
  audience: OrganizerSavedAudienceCallableResponse;
  coverage: "exact";
  matchCount: number;
  /**
   * @maxItems 25
   */
  sample: {
    contactId: string;
    displayName: string;
  }[];
  evaluatedAtMillis: number;
}
