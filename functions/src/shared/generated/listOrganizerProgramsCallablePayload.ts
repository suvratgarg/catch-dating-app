/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-scoped listing of an organizer's private programs.
 */
export interface ListOrganizerProgramsCallablePayload {
  organizerId: string;
  limit?: number;
  /**
   * Optional opaque value from nextCursor. Server verifies current organizer scope and continues after the immutable ordering tuple encoded by that cursor.
   */
  cursor?: string;
  /**
   * Optional exact program ID for bounded saved-program confirmation. Organizer authority and document scope are rechecked; cannot be combined with cursor.
   */
  programId?: string;
}
