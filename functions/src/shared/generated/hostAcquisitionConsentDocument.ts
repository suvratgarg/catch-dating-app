/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private anonymous device permission, keyed by a domain-separated capability hash. Revocation tombstones cannot be reactivated; fresh permission requires a new capability.
 */
export type HostAcquisitionConsentDocument = {
  [k: string]: unknown;
} & {
  schemaVersion: 1;
  classification: "sales_private";
  consentId: string;
  status: "active" | "revoked";
  authority: {
    version: 1;
    purpose: "host_acquisition_measurement";
    analytics: true;
    advertising: boolean;
    chosenAt: number;
    acceptedAt: number;
    expiresAt: number;
    revokedAt: number | null;
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
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
};
