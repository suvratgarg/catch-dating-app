/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface PrivateEventSetupListCallableResponse {
  /**
   * @maxItems 50
   */
  events: {
    eventId: string;
    name: string;
    city: {
      cityId: string;
      marketId: string;
    };
    localDate: string;
    localStartTime: string;
    timezone: string;
    startTimeMillis: number;
    setupRevision: number;
    status: "active";
    detailsConfigured: boolean;
  }[];
  nextCursor: null | string;
}
