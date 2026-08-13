/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Reusable organizer-owned parametric room layout stored at organizerEventSuccessLayouts/{organizerId_layoutId}. Derived coordinates and proximity edges are never persisted.
 */
export interface OrganizerEventSuccessLayoutDocument {
  organizerId: string;
  layoutId: string;
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
}
