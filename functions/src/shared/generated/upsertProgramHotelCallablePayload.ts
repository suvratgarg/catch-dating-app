/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Create or update a program accommodation property.
 */
export interface UpsertProgramHotelCallablePayload {
  programId: string;
  hotelId?: string;
  expectedRevision?: number;
  name: string;
  address: string;
  latitude?: number | null;
  longitude?: number | null;
  receptionContact?: string | null;
  notes?: string | null;
  active?: boolean;
}
