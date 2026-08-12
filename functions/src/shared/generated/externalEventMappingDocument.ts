/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Stable mapping and field-level authority between one Catch event and one organizer-authorized booking-provider event.
 */
export interface ExternalEventMappingDocument {
  organizerId: string;
  eventId: string;
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
  createdByUid: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  lastSyncAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  lastSuccessfulSyncAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  lastSyncStatus: "never" | "running" | "completed" | "partial" | "failed";
  lastSyncRunId: string | null;
  disconnectedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
