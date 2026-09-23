/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned private function (ceremony, reception, offsite session) inside a program. Separate from public events documents; no public read surface exists.
 */
export interface ProgramFunctionDocument {
  programId: string;
  organizerId: string;
  name: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  startsAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  endsAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  venueName: string;
  venueNotes?: string | null;
  status: "scheduled" | "completed" | "cancelled";
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
