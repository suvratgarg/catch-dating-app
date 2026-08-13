/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Creates or updates one reusable organizer-owned parametric layout.
 */
export interface UpsertEventSuccessLayoutCallablePayload {
  organizerId: string;
  layoutId?: string | null;
  label: string;
  /**
   * @minItems 1
   * @maxItems 200
   */
  units: {
    id: string;
    label: string;
    shape: "round" | "rect" | "row" | "court" | "zone";
    capacity: number;
    gridX: number;
    gridY: number;
    order: number;
  }[];
}
