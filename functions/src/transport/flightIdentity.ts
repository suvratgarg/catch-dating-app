import type {ProgramTravelLegDocument} from
  "../shared/generated/firestoreAdminTypes";

export type TravelLegFlightStatus = ProgramTravelLegDocument["flightStatus"];

export interface FlightStatusSnapshot {
  flightNumber: string | null;
  originIata: string | null;
  destinationIata: string | null;
  status: TravelLegFlightStatus;
  scheduledArrivalMillis: number | null;
  estimatedArrivalMillis: number | null;
  actualArrivalMillis: number | null;
  arrivalTerminal: string | null;
  baggageBelt: string | null;
  providerUpdatedAtMillis: number | null;
}

/** A flight number is not an ATC call sign or a person identity. */
export function normalizeFlightNumber(value: string): string {
  return value.replace(/[\s-]+/g, "").toUpperCase();
}

/** Planner-owned identity also fences guest/program changes during polling. */
export function flightIdentity(leg: ProgramTravelLegDocument): string {
  return [leg.programId, leg.guestId, leg.kind,
    flightInstanceKey(leg)].join("|");
}

export function flightInstanceKey(leg: ProgramTravelLegDocument): string {
  return [normalizeFlightNumber(leg.flightNumber ?? ""),
    leg.originIata ?? "", leg.destinationIata ?? "",
    leg.scheduledArrivalAt?.toMillis() ?? ""].join("|");
}

export function snapshotMatchesLeg(leg: ProgramTravelLegDocument,
  snapshot: FlightStatusSnapshot): boolean {
  return !!leg.flightNumber && !!leg.destinationIata &&
    leg.scheduledArrivalAt != null &&
    snapshot.flightNumber === normalizeFlightNumber(leg.flightNumber) &&
    snapshot.destinationIata === leg.destinationIata &&
    (!leg.originIata || snapshot.originIata === leg.originIata) &&
    snapshot.scheduledArrivalMillis === leg.scheduledArrivalAt.toMillis();
}
