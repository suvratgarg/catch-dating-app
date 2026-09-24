/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface OrganizerEventOfferBatchReceiptDocument {
  organizerId: string;
  eventId: string;
  requestId: string;
  requestHash: string;
  /**
   * @minItems 1
   * @maxItems 25
   */
  results: {
    offerId: string;
    revision: number;
    generation: number;
  }[];
}
