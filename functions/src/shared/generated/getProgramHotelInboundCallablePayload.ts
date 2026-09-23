/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Hotel-desk scoped inbound view: trips en route and expected guests for one hotel only.
 */
export interface GetProgramHotelInboundCallablePayload {
  programId: string;
  hotelId: string;
  /**
   * Continuation returned for this hotel list. Omit to read its first page.
   */
  tripCursor?: string;
  /**
   * Continuation returned for this hotel list. Omit to read its first page.
   */
  expectedCursor?: string;
  limit?: number;
}
