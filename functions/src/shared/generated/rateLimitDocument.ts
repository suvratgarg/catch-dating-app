/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned callable rate-limit counter stored at rateLimits/{docId}.
 */
export interface RateLimitDocument {
  uid: string;
  action: string;
  windowKey: number;
  count: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
