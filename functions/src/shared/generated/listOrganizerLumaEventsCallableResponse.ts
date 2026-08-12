/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Safe calendar identity and manageable Luma event choices returned after transient key verification.
 */
export interface ListOrganizerLumaEventsCallableResponse {
  calendarName: string;
  /**
   * @maxItems 50
   */
  events: {
    externalEventId: string;
    name: string;
    startAtMillis: number;
  }[];
  truncated: boolean;
}
