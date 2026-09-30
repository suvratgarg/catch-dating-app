/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned program accommodation property. Scopes hotel-desk duties, guest stays and transport destinations.
 */
export interface ProgramHotelDocument {
  programId: string;
  organizerId: string;
  name: string;
  address: string;
  latitude: number | null;
  longitude: number | null;
  receptionContact: string | null;
  notes: string | null;
  active: boolean;
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
  /**
   * Identity/free-text scrub marker set by the archive retention sweep; null until anonymized.
   */
  anonymizedAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
