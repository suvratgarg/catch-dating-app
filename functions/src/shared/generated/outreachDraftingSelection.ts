/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface OutreachDraftingSelection {
  organizerId: string;
  contactId: string;
  opportunityId: string;
  language: "en";
  observationId: string | null;
  capabilityId: string | null;
  referenceId: string | null;
  ctaId: string | null;
  reasonToBlock: string | null;
  /**
   * @maxItems 20
   */
  omittedIds: string[];
}
