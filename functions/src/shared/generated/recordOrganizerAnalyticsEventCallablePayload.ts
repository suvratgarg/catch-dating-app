/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Public website analytics event for host-visible organizer metrics. The callable validates organizer scope and writes a raw, aggregate-safe event to BigQuery.
 */
export interface RecordOrganizerAnalyticsEventCallablePayload {
  clubId: string;
  eventId?: string | null;
  eventName:
    | "listingView"
    | "searchAppearance"
    | "eventView"
    | "organizerSave"
    | "eventSave"
    | "contactClick"
    | "claimClick"
    | "outboundClick";
  pagePath: string;
  source?: string | null;
  sessionId?: string | null;
  platform?: string | null;
}
