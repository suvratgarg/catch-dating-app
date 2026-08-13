/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Selected reusable layout or null when the event has no spatial map.
 */
export interface GetEventSuccessSpatialLayoutCallableResponse {
  layout: null | {
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
  };
}
