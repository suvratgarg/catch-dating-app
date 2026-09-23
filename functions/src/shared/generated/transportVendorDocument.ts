/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned organizer-level taxi/coach subcontractor identity. Program use requires an explicit binding; rate cards and commercial terms ship with the reconciliation slice.
 */
export interface TransportVendorDocument {
  organizerId: string;
  name: string;
  contactName: string | null;
  phoneE164: string | null;
  /**
   * Programs this vendor is bound to; dispatch may only snapshot bound vendors.
   *
   * @maxItems 100
   */
  programIds: string[];
  active: boolean;
  notes: string | null;
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
  revision: number;
}
