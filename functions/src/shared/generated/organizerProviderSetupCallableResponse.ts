/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Safe provider capability catalog, organizer connections and event mapping projection.
 */
export interface OrganizerProviderSetupCallableResponse {
  organizerId: string;
  eventId: string;
  /**
   * @minItems 9
   * @maxItems 9
   */
  providers: {
    provider:
      | "generic"
      | "luma"
      | "eventbrite"
      | "partiful"
      | "posh"
      | "bookmyshow"
      | "district"
      | "sortmyscene"
      | "airbnb";
    displayName: string;
    adapterClass: "A" | "C" | "D" | "E" | "unclassified";
    availability:
      | "available"
      | "exportOnly"
      | "configurationRequired"
      | "partnerAccessRequired"
      | "sampleRequired"
      | "manualOnly";
    importSupport: "verified" | "generic" | "sampleRequired";
    connectionMethod: "apiKey" | "oauth" | "partner" | "none";
    capabilities: {
      fileImport: boolean;
      eventList: boolean;
      rosterIdentity: boolean;
      registrationStatus: boolean;
      providerCheckIn: boolean;
      orderAmount: boolean;
      refundStatus: boolean;
      referralCode: boolean;
      webhooks: boolean;
      writeBookings: boolean;
    };
    requirement: string;
  }[];
  /**
   * @maxItems 20
   */
  connections: {
    connectionId: string;
    provider: "luma";
    status: "active" | "degraded" | "credentialRevoked" | "disconnected";
    externalAccountId: string;
    externalAccountName: string;
    syncMode: "manualPoll";
    capabilities: {
      eventList: boolean;
      rosterIdentity: boolean;
      registrationStatus: boolean;
      providerCheckIn: boolean;
      orderAmount: boolean;
      refundStatus: boolean;
      referralCode: boolean;
      webhooks: boolean;
      writeBookings: boolean;
    };
    revision: number;
    lastHealthSyncAtMillis: number | null;
    lastSuccessfulSyncAtMillis: number | null;
  }[];
  mapping: {
    mappingId: string;
    connectionId: string;
    provider: "luma";
    externalEventId: string;
    status: "active" | "paused" | "disconnected";
    fieldAuthority: {
      rosterIdentity: "provider";
      registrationStatus: "provider";
      checkIn: "providerWhenPresent";
      orderAmount: "unavailable";
      refundStatus: "unavailable";
      referralCode: "unavailable";
    };
    revision: number;
    lastSyncAtMillis: number | null;
    lastSuccessfulSyncAtMillis: number | null;
    lastSyncStatus: "never" | "running" | "completed" | "partial" | "failed";
    lastSyncRunId: string | null;
  } | null;
}
