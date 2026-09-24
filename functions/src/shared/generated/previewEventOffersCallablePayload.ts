/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {EventOfferRow} from "./eventOfferRow";

export interface PreviewEventOffersCallablePayload {
  organizerId: string;
  eventId: string;
  mode: "draft" | "offer";
  /**
   * @minItems 1
   * @maxItems 25
   */
  rows: EventOfferRow[];
}
