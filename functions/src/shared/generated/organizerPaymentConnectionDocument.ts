/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Merchant-owned Razorpay OAuth connection. Secret values are held in the bound credential vault; this server-only document contains pinned references.
 */
export interface OrganizerPaymentConnectionDocument {
  organizerId: string;
  provider: "razorpay";
  mode: "test" | "live";
  status: "connecting" | "ready" | "needsAttention" | "disconnected";
  accountId: string | null;
  publicToken: string | null;
  secretVersionResource: string | null;
  tokenExpiresAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  webhookId: string | null;
  webhookUrl: string | null;
  webhookVerifiedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  connectedByUid: string;
  revision: number;
  refreshLeaseUntil: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
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
  disconnectedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  lastErrorCode: string | null;
}
