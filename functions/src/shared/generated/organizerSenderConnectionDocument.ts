/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Safe organizer-owned messaging sender metadata. Provider access tokens live in Secret Manager, never Firestore.
 */
export interface OrganizerSenderConnectionDocument {
  organizerId: string;
  channel: "whatsapp";
  provider: "metaCloudApi";
  status:
    | "pending"
    | "testing"
    | "active"
    | "degraded"
    | "blocked"
    | "tokenRevoked"
    | "disconnected";
  wabaId: string | null;
  phoneNumberId: string | null;
  businessId: string | null;
  displayPhoneNumber: string | null;
  verifiedName: string | null;
  secretVersionResource: string | null;
  qualityRating: null | "GREEN" | "YELLOW" | "RED" | "UNKNOWN";
  messagingLimitTier: string | null;
  templateSyncStatus: "notStarted" | "current" | "stale" | "failed";
  webhookStatus: "notSubscribed" | "subscribed" | "degraded";
  testStatus: "notSent" | "pending" | "delivered" | "failed";
  testProviderMessageId: string | null;
  testRecipientHash: string | null;
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
  lastHealthSyncAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  disconnectedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
