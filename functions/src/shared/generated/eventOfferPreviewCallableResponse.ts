/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventOfferPreviewCallableResponse {
  planDigest: string;
  /**
   * @minItems 1
   * @maxItems 25
   */
  rows: {
    offerId: string;
    revision: number;
    generation: number;
    status: "new" | "draft" | "offered" | "withdrawn" | "expired";
  }[];
}
