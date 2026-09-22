/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned per-guest travel leg. Carries itinerary facts, flight status snapshots, readiness/claim state and reviewed manual overrides. Provider facts are linked, never copied over manual observations.
 */
export interface ProgramTravelLegDocument {
  programId: string;
  organizerId: string;
  /**
   * Exactly one guest per leg; companions get their own legs sharing a party.
   */
  guestId: string;
  /**
   * Optional ride-together travel party; null means this leg travels as a singleton.
   */
  partyId: string | null;
  kind: "inbound" | "outbound" | "ground";
  flightNumber: string | null;
  carrierCode: string | null;
  originIata: string | null;
  destinationIata: string | null;
  scheduledArrivalAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  estimatedArrivalAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  actualArrivalAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  flightStatus:
    | "scheduled"
    | "enroute"
    | "landed"
    | "delayed"
    | "cancelled"
    | "diverted"
    | "unknown";
  /**
   * Resolved provider flight instance once flight tracking ships; null for manual entries.
   */
  flightInstanceId: string | null;
  pickupPointId: string | null;
  destinationHotelId: string | null;
  /**
   * Free-text destination when the drop is not a configured hotel.
   */
  destinationLabel: string | null;
  readiness:
    | "expected"
    | "ready"
    | "dispatched"
    | "arrived"
    | "disrupted"
    | "noShow";
  /**
   * Observed curb-ready timestamp; outranks every estimate.
   */
  readyAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  claimedByUid: string | null;
  claimedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Reviewed manual curb estimate; outranks flight-derived timing.
   */
  manualCurbAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  manualCurbNote: string | null;
  /**
   * Seats this leg consumes, including children without their own guest record.
   */
  passengers: number;
  luggageUnits: number;
  /**
   * @maxItems 12
   */
  requiredCapabilities: (
    | "wheelchairAccessible"
    | "extraLuggage"
    | "childSeat"
  )[];
  /**
   * VIP/private transfers never share a suggested vehicle.
   */
  dedicatedVehicle: boolean;
  source: "manual" | "import" | "formResponse" | "planner";
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
}
