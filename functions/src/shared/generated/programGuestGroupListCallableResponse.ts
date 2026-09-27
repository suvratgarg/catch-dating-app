/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Coordinator-facing inventory of organizer-defined guest groups for a program, with denormalized member counts.
 */
export interface ProgramGuestGroupListCallableResponse {
  programId: string;
  /**
   * @maxItems 500
   */
  groups: {
    groupId: string;
    label: string;
    dimension: string;
    sortOrder: number;
    memberCount: number;
    revision: number;
  }[];
}
