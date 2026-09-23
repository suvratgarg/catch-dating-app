import {HttpsError} from "firebase-functions/v2/https";
import type {ProgramGuestDocument, ProgramTravelLegDocument,
  TransportTripDocument} from "../shared/generated/firestoreAdminTypes";

type DispatchSnapshot = NonNullable<TransportTripDocument["dispatchSnapshot"]>;

/** Missing means legacy; inconsistent snapshots must not fall back. */
export function readTripDispatchSnapshot(
  trip: TransportTripDocument,
): DispatchSnapshot | undefined {
  const snapshot = trip.dispatchSnapshot;
  if (snapshot === undefined) return undefined;
  if (!snapshot || !snapshot.vehicleClass ||
      snapshot.vehicleClass.id !== trip.vehicleClassId ||
      typeof snapshot.vehicleClass.label !== "string" ||
      snapshot.vehicleClass.label.length < 1 ||
      snapshot.vehicleClass.label.length > 60 ||
      !Array.isArray(snapshot.manifest) ||
      snapshot.manifest.length < 1 || snapshot.manifest.length > 50 ||
      snapshot.manifest.length !== trip.legIds.length ||
      new Set(snapshot.manifest.map((entry) => entry?.legId)).size !==
        trip.legIds.length ||
      new Set(snapshot.manifest.map((entry) => entry?.guestId)).size !==
        snapshot.manifest.length ||
      snapshot.manifest.some((entry) => !entry ||
        !trip.legIds.includes(entry.legId) ||
        typeof entry.guestId !== "string" || !entry.guestId ||
        entry.guestId.length > 180 ||
        typeof entry.guestDisplayName !== "string" ||
        !entry.guestDisplayName || entry.guestDisplayName.length > 140 ||
        !Number.isInteger(entry.passengers) || entry.passengers < 1 ||
        entry.passengers > 200 ||
        !Number.isInteger(entry.luggageUnits) || entry.luggageUnits < 0 ||
        entry.luggageUnits > 500) ||
      snapshot.manifest.reduce((sum, entry) => sum + entry.passengers, 0) !==
        trip.passengerCount) {
    throw new HttpsError("failed-precondition",
      "The recorded trip manifest needs reconciliation.");
  }
  return snapshot;
}

/** A malformed legacy reference cannot disclose another station's guest. */
export function tripIncludesLeg(trip: TransportTripDocument,
  leg: ProgramTravelLegDocument): boolean {
  return leg.programId === trip.programId &&
    leg.organizerId === trip.organizerId &&
    leg.pickupPointId === trip.pickupPointId &&
    leg.destinationHotelId === trip.destinationHotelId;
}

/** Both receiving and reconciliation surfaces show the same source of names. */
export function projectTripManifest(
  trip: TransportTripDocument,
  snapshot: DispatchSnapshot | undefined,
  legs: ReadonlyMap<string, ProgramTravelLegDocument>,
  guests: ReadonlyMap<string, ProgramGuestDocument>,
): {manifestSource: "dispatchSnapshot" | "currentRecords";
  vehicleClassLabel: string | null; guestNames: string[]} {
  if (snapshot) {
    return {manifestSource: "dispatchSnapshot",
      vehicleClassLabel: snapshot.vehicleClass.label,
      guestNames: snapshot.manifest.map((entry) => entry.guestDisplayName)};
  }
  return {manifestSource: "currentRecords", vehicleClassLabel: null,
    guestNames: trip.legIds.map((id) => legs.get(id))
      .filter((leg) => leg !== undefined && tripIncludesLeg(trip, leg))
      .map((leg) => guests.get(leg!.guestId))
      .filter((guest) => guest?.programId === trip.programId &&
        guest.organizerId === trip.organizerId)
      .map((guest) => guest!.displayName)};
}
