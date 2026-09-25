/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface OfferEventTargetListCallableResponse {
  /**
   * @maxItems 50
   */
  events: {
    eventId: string;
    name: string | null;
    startTimeMillis: number;
    timezone: string | null;
    publicationState: "private" | "published";
    setupRevision: number | null;
  }[];
  nextCursor: null | string;
}
