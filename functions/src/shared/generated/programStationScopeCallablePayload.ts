/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Pickup-station scoped program read shared by the arrivals roster and transport plan callables.
 */
export interface ProgramStationScopeCallablePayload {
  programId: string;
  /**
   * Requested station. Staff are still intersected with their granted station scope; managers may read any station.
   */
  pickupPointId?: string | null;
}
