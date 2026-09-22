/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Dispatch a vehicle: snapshot plate, vendor, class and manifest in one transaction that also writes per-leg active assignments and an idempotency receipt.
 */
export interface DispatchProgramTripCallablePayload {
  programId: string;
  pickupPointId: string;
  destinationHotelId?: string | null;
  destinationLabel?: string | null;
  vehicleClassId: string;
  plateDisplay: string;
  vendorId?: string | null;
  kind?: "guestTransfer" | "repositioning";
  /**
   * @minItems 1
   * @maxItems 50
   */
  legIds: string[];
  /**
   * Optional revision fence per boarded leg; a stale roster aborts the dispatch instead of splitting a party.
   *
   * @maxItems 50
   */
  expectedLegRevisions?: {
    legId: string;
    revision: number;
  }[];
  /**
   * Explicit departure timestamp for late offline sync; defaults to server now.
   */
  departedAtMillis?: number | null;
  notes?: string | null;
  clientOperationId: string;
}
