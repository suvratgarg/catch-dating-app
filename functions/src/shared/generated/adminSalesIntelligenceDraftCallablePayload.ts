/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Selects only existing approved clause IDs; trusted server builds the Operations snapshot. No source prose is accepted from the caller.
 */
export interface AdminBuildSalesOutreachInputPayload {
  organizerId: string;
  contactId: string;
  opportunityId: string;
  /**
   * @minItems 1
   * @maxItems 12
   */
  observationIds: string[];
  /**
   * @minItems 1
   * @maxItems 12
   */
  capabilityIds: string[];
  /**
   * @maxItems 8
   */
  referenceIds: string[];
  /**
   * @minItems 1
   * @maxItems 8
   */
  ctaIds: string[];
  channel: "email" | "message";
  purpose: "first_message" | "follow_up";
  priorActivityId?: string;
}
