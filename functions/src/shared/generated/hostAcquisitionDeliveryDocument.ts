/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private, bounded Meta Lead delivery. Current consent and the original Sales intent are rechecked before dispatch. Contact data and form answers are excluded.
 */
export interface HostAcquisitionDeliveryDocument {
  schemaVersion: 1;
  classification: "sales_private";
  eventId: string;
  intentId: string;
  consentId: string;
  acceptedAt: number;
  status: "pending" | "sending" | "accepted" | "unknown" | "stopped";
  attempts: number;
  nextAttemptAt: number;
  attemptId: string | null;
  lastAttemptAt: number | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  context: {
    clientId: string;
    userAgent: string;
    fbclid?: string;
    clickCapturedAt?: number;
  } | null;
}
