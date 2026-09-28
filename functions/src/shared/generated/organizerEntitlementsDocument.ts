/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned entitlement document at organizerEntitlements/{organizerId} holding purchased plan grants and metered usage. Written only by admin grant/revoke callables in the pilot; managers receive a bounded callable projection.
 */
export interface OrganizerEntitlementsDocument {
  schemaVersion: 1;
  organizerId: string;
  /**
   * @maxItems 50
   */
  grants: {
    grantId: string;
    /**
     * Durable grant operation identity after the short-lived mutation receipt expires; absent only on legacy grants.
     */
    operationContentHash?: string;
    /**
     * Original grant result revision for exact replay after receipt expiry; absent only on legacy grants.
     */
    operationResultRevision?: number;
    sku:
      | "wedding_essentials"
      | "wedding_pro"
      | "wedding_signature"
      | "wedding_transport_addon"
      | "planner_annual";
    unit: "program" | "organizerYear";
    quantityTotal: number;
    quantityConsumed: number;
    /**
     * Serialized Firestore Timestamp fixture shape.
     */
    validFrom: {
      _seconds: number;
      _nanoseconds: number;
    };
    validUntil: {
      _seconds: number;
      _nanoseconds: number;
    } | null;
    source: "manualInvoice" | "checkout" | "promo";
    receiptRef: string | null;
    note: string | null;
    grantedBy: string;
    /**
     * Serialized Firestore Timestamp fixture shape.
     */
    grantedAt: {
      _seconds: number;
      _nanoseconds: number;
    };
    revokedAt: {
      _seconds: number;
      _nanoseconds: number;
    } | null;
    revokedBy: string | null;
    revokeReason: string | null;
  }[];
  meters: {
    flightDaysUsed: number;
    waConversationsUsed: number;
    /**
     * Serialized Firestore Timestamp fixture shape.
     */
    periodStartsAt: {
      _seconds: number;
      _nanoseconds: number;
    };
  };
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
}
