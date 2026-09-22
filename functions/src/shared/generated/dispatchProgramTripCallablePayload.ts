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
   * Exactly one revision fence for every selected leg; missing, duplicate, extraneous or stale fences abort dispatch.
   *
   * @minItems 1
   * @maxItems 50
   */
  expectedLegRevisions: {
    legId: string;
    revision: number;
    /**
     * A preceding observation by the same actor on the same journey. Its receipt result revision must still equal the current leg revision.
     */
    afterObservation?: {
      clientOperationId: string;
      action: "claim" | "unclaim" | "markReady" | "markDisrupted";
    };
  }[];
  /**
   * Explicit departure timestamp for late offline sync; defaults to server now.
   */
  departedAtMillis?: number | null;
  notes?: string | null;
  clientOperationId: string;
}
