/* firestore-index: programTravelLegs (
  programId:ASCENDING,
  organizerId:ASCENDING,
  kind:ASCENDING,
  readiness:ASCENDING
) */
/* firestore-index: programTravelLegs (
  programId:ASCENDING,
  organizerId:ASCENDING,
  kind:ASCENDING,
  readiness:ASCENDING,
  pickupPointId:ASCENDING
) */
/* firestore-index: programTravelLegs (
  programId:ASCENDING,
  organizerId:ASCENDING,
  kind:ASCENDING,
  readiness:ASCENDING,
  destinationHotelId:ASCENDING
) */
/* firestore-index: programTravelLegs (
  programId:ASCENDING,
  organizerId:ASCENDING,
  kind:ASCENDING,
  readiness:ASCENDING,
  pickupPointId:ASCENDING,
  destinationHotelId:ASCENDING
) */
import {HttpsError} from "firebase-functions/v2/https";
import type {StationAccess} from "../shared/programStationAuthority";
import {programResourceScopes} from "../shared/programResourceScopes";
import type {ProgramGuestDocument, ProgramHotelDocument,
  ProgramPickupPointDocument,
  ProgramTravelLegDocument,
  ProgramTravelPartyDocument} from "../shared/generated/firestoreAdminTypes";
import type {TravelLeg} from "./travelPartyPolicy";

const rosterCap = 500;
interface LegContext {
  legs: TravelLeg[];
  guests: Map<string, ProgramGuestDocument>;
  parties: Map<string, ProgramTravelPartyDocument>;
  hotels: Map<string, ProgramHotelDocument>;
  pickups: Map<string, ProgramPickupPointDocument>;
}

/** Scope queries before reading guests or applying page limits. */
export async function loadArrivalLegContext(
  db: FirebaseFirestore.Firestore,
  programId: string,
  station: StationAccess,
  requestedStation: string | null,
  projection: "roster" | "plan",
): Promise<LegContext> {
  if (requestedStation !== null && station.stationScope !== null &&
      !station.stationScope.has(requestedStation)) {
    throw new HttpsError("permission-denied",
      "This station is outside your assigned scope.");
  }
  const scopes = programResourceScopes(station.access.role === "manager" ?
    null : station.assignments, {requestedPickup: requestedStation,
    baseDisjunctions: 3});
  const pages = await Promise.all(scopes.map((scope) => {
    let query: FirebaseFirestore.Query = db.collection("programTravelLegs")
      .where("programId", "==", programId)
      .where("organizerId", "==", station.access.program.organizerId)
      .where("kind", "==", "inbound")
      .where("readiness", "in", ["expected", "ready", "disrupted"]);
    if (scope.pickup.length) {
      query = query.where("pickupPointId", "in", scope.pickup);
    }
    if (scope.hotels.length) {
      query = query.where("destinationHotelId", "in", scope.hotels);
    }
    return query.limit(rosterCap + 1).get();
  }));
  const byId = new Map(pages.flatMap((page) =>
    page.docs.map((doc) => [doc.id, doc])));
  if (byId.size > rosterCap) {
    throw new HttpsError("resource-exhausted",
      "This arrivals view exceeds 500 journeys. Narrow the station scope.");
  }
  const organizerId = station.access.program.organizerId;
  const legs = [...byId.values()].map((doc) => ({id: doc.id,
    doc: doc.data() as ProgramTravelLegDocument}))
    .filter((leg) => leg.doc.organizerId === organizerId)
    .sort((a, b) => a.id.localeCompare(b.id));
  // Planning needs pickup validity, while the roster needs guest labels.
  // Do not hydrate private guest details for a plan that does not use them.
  const guestIds = projection === "roster" ?
    [...new Set(legs.map((leg) => leg.doc.guestId))] : [];
  const pickupIds = projection === "plan" ?
    [...new Set(legs.map((leg) => leg.doc.pickupPointId)
      .filter((id): id is string => id !== null))] : [];
  const partyIds = [...new Set(legs.map((leg) => leg.doc.partyId)
    .filter((id): id is string => id !== null))];
  const hotelIds = [...new Set(legs.map((leg) => leg.doc.destinationHotelId)
    .filter((id): id is string => id !== null))];
  const [guestSnaps, partySnaps, hotelSnaps, pickupSnaps] = await Promise.all([
    Promise.all(guestIds.map((id) =>
      db.collection("programGuests").doc(id).get())),
    Promise.all(partyIds.map((id) =>
      db.collection("programTravelParties").doc(id).get())),
    Promise.all(hotelIds.map((id) =>
      db.collection("programHotels").doc(id).get())),
    Promise.all(pickupIds.map((id) =>
      db.collection("programPickupPoints").doc(id).get())),
  ]);
  const guests = new Map<string, ProgramGuestDocument>();
  for (const snap of guestSnaps) {
    const doc = snap.data() as ProgramGuestDocument | undefined;
    if (doc && doc.programId === programId && doc.organizerId === organizerId) {
      guests.set(snap.id, doc);
    }
  }
  const parties = new Map<string, ProgramTravelPartyDocument>();
  for (const snap of partySnaps) {
    const doc = snap.data() as ProgramTravelPartyDocument | undefined;
    if (doc && doc.programId === programId && doc.organizerId === organizerId) {
      parties.set(snap.id, doc);
    }
  }
  const hotels = new Map<string, ProgramHotelDocument>();
  for (const snap of hotelSnaps) {
    const doc = snap.data() as ProgramHotelDocument | undefined;
    if (doc && doc.programId === programId && doc.organizerId === organizerId) {
      hotels.set(snap.id, doc);
    }
  }
  const pickups = new Map<string, ProgramPickupPointDocument>();
  for (const snap of pickupSnaps) {
    const doc = snap.data() as ProgramPickupPointDocument | undefined;
    if (doc && doc.programId === programId && doc.organizerId === organizerId) {
      pickups.set(snap.id, doc);
    }
  }
  return {legs, guests, parties, hotels, pickups};
}
