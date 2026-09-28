/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Create or update an organizer-defined guest group for a program. label and dimension are always supplied; sortOrder preserves the existing value when omitted.
 */
export interface UpsertProgramGuestGroupCallablePayload {
  programId: string;
  groupId?: string;
  expectedRevision?: number;
  label: string;
  /**
   * Grouping axis key. Conventional values per program kind (weddings: side/lineage/relation; corporate: company/delegation/country); other keys are allowed.
   */
  dimension: string;
  sortOrder?: number;
  /**
   * Optional programHotels link — where this group's members stay; feeds distance-aware moment lead times. Omitted preserves the existing link; explicit null clears it.
   */
  hotelId?: string | null;
}
