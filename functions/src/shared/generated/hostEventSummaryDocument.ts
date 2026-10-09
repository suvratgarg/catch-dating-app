/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-maintained organizer-scoped Host read view. Never identity, permission or mutation authority.
 */
export interface HostEventSummaryDocument {
  organizerId: string;
  eventId: string;
  startTimeMillis: number;
  status: "active" | "cancelled";
  row: {
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
    status: "active" | "cancelled";
    detailsConfigured: boolean;
  };
  version: 1;
}
