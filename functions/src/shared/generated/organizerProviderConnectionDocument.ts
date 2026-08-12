/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Safe organizer-owned booking-provider connection metadata. Provider credentials live in Secret Manager, never Firestore.
 */
export interface OrganizerProviderConnectionDocument {
  organizerId: string;
  provider: "luma";
  adapterClass: "A";
  status: "active" | "degraded" | "credentialRevoked" | "disconnected";
  externalAccountId: string;
  externalAccountName: string;
  secretVersionResource: string | null;
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
  connectedByUid: string;
  revision: number;
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
  lastHealthSyncAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  lastSuccessfulSyncAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  lastErrorCode: string | null;
  disconnectedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
