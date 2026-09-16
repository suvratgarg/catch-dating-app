/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ListEventWhatsappPreferencesCallableResponse {
  eventId: string;
  attendeeId: string;
  serverTime: number;
  configuredSenderId: string | null;
  /**
   * @maxItems 50
   */
  previousSenderIds: string[];
  nextCursor: string | null;
}
