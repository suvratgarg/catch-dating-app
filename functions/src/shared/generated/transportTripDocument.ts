/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned dispatched vehicle record. The dispatch act is the reconciliation atom: plate, vendor, class and manifest are snapshotted at departure. Airport, hotel and finance surfaces read field-redacted projections.
 */
export interface TransportTripDocument {
  programId: string;
  organizerId: string;
  kind: "guestTransfer" | "repositioning";
  pickupPointId: string;
  destinationHotelId: string | null;
  destinationLabel: string | null;
  /**
   * Program vehicle-class catalog id snapshotted at dispatch.
   */
  vehicleClassId: string;
  vendorId: string | null;
  vendorNameSnapshot: string | null;
  /**
   * Uppercased plate with separators stripped; the reconciliation join key.
   */
  plateNormalized: string;
  plateDisplay: string;
  /**
   * @maxItems 50
   */
  partyIds: string[];
  /**
   * @minItems 1
   * @maxItems 50
   */
  legIds: string[];
  passengerCount: number;
  status: "enRoute" | "arrived" | "cancelled" | "voided";
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  departedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  departedByUid: string;
  arrivedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Dispatcher/manager who voided the trip.
   */
  voidedByUid: string | null;
  /**
   * Required reason recorded when a dispatch is voided; reviewed in reconciliation.
   */
  voidReason: string | null;
  arrivedByUid: string | null;
  /**
   * Optional agreed rate frozen at dispatch; commercial terms ship with the reconciliation slice.
   */
  rateSnapshot: {
    currency: string;
    amountMinor: number;
    pricingKind: "perTrip" | "perVehicleDay" | "custom";
  } | null;
  /**
   * Idempotent dispatch key; a replay returns the original trip.
   */
  clientOperationId: string;
  notes: string | null;
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
  revision: number;
  /**
   * Facts captured atomically when dispatch is recorded, including offline departures recorded later. Absent only on legacy trips; never reconstructed as historical evidence from current records.
   */
  dispatchSnapshot?: {
    /**
     * Serialized Firestore Timestamp fixture shape.
     */
    recordedAt: {
      _seconds: number;
      _nanoseconds: number;
    };
    vehicleClass: {
      id: string;
      label: string;
      passengerCapacity: number;
      luggageCapacity: number;
      /**
       * @maxItems 12
       */
      capabilities: ("wheelchairAccessible" | "extraLuggage" | "childSeat")[];
      sortOrder: number;
    };
    /**
     * @minItems 1
     * @maxItems 50
     */
    manifest: {
      legId: string;
      guestId: string;
      guestDisplayName: string;
      partyId: string | null;
      passengers: number;
      luggageUnits: number;
    }[];
  };
}
