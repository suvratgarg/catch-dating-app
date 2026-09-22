/* firestore-index: transportTrips (
  programId:ASCENDING,
  pickupPointId:ASCENDING,
  departedAt:DESCENDING
) */
/* firestore-index: transportTrips (
  programId:ASCENDING,
  destinationHotelId:ASCENDING,
  departedAt:DESCENDING
) */
/* firestore-index: transportTrips (
  programId:ASCENDING,
  pickupPointId:ASCENDING,
  destinationHotelId:ASCENDING,
  departedAt:DESCENDING
) */
/* firestore-index: transportTrips (
  programId:ASCENDING,
  destinationHotelId:ASCENDING,
  status:ASCENDING,
  departedAt:ASCENDING
) */
/* firestore-index: programTravelLegs (
  programId:ASCENDING,
  destinationHotelId:ASCENDING,
  readiness:ASCENDING
) */
/* firestore-index: transportTrips (
  programId:ASCENDING,
  departedAt:DESCENDING
) */
import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithLimits} from "../shared/callableOptions";
import {validateCallableWithAjv} from "../shared/validation";
import {staffTimestampMillis} from "../shared/eventOperatorAuthority";
import {dutyAssignments, dutyCoversHotel,
  requireProgramAccess} from "../shared/programAuthority";
import type {ProgramDutyAssignment} from "../shared/programAuthority";
import {defaultProgramDataDeps} from "../shared/programDataDeps";
import type {ProgramDataDeps} from "../shared/programDataDeps";
import {legTiming} from "./programArrivals";
import type {ProgramGuestDocument, ProgramHotelDocument,
  ProgramTravelLegDocument, ProgramTravelPartyDocument, TransportTripDocument}
  from "../shared/generated/firestoreAdminTypes";
import type {GetProgramHotelInboundCallablePayload} from
  "../shared/generated/getProgramHotelInboundCallablePayload";
import type {ProgramIdCallablePayload} from
  "../shared/generated/programIdCallablePayload";
import type {ProgramHotelInboundCallableResponse} from
  "../shared/generated/programHotelInboundCallableResponse";
import type {ProgramTripListCallableResponse} from
  "../shared/generated/programTripListCallableResponse";
import {validateGetProgramHotelInboundCallablePayload} from
  "../shared/generated/validators/getProgramHotelInboundInput";
import {validateProgramIdCallablePayload} from
  "../shared/generated/validators/programIdInput";

const tripListCap = 200;
const readLimits = {timeoutSeconds: 60, maxInstances: 40};

export async function getProgramHotelInboundHandler(
  request: CallableRequest<unknown>,
  deps: ProgramDataDeps = defaultProgramDataDeps
): Promise<ProgramHotelInboundCallableResponse> {
  const actorUid = requireAuth(request);
  const data =
    validateCallableWithAjv<GetProgramHotelInboundCallablePayload>(
      request, validateGetProgramHotelInboundCallablePayload,
      normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "getProgramHotelInbound");
  const access = await requireProgramAccess({
    db, programId: data.programId, actorUid, now: deps.now(),
  });
  if (access.role !== "manager") {
    const hotelDuties = dutyAssignments(access, "hotelDesk");
    if (!dutyCoversHotel(hotelDuties, data.hotelId)) {
      throw new HttpsError(
        "permission-denied",
        "This hotel is outside your assigned scope.");
    }
  }
  const hotelSnap = await db.collection("programHotels")
    .doc(data.hotelId).get();
  const hotel = hotelSnap.data() as ProgramHotelDocument | undefined;
  if (!hotel || hotel.programId !== data.programId) {
    throw new HttpsError("not-found", "Hotel not found in this program.");
  }
  const [tripsSnap, legsSnap] = await Promise.all([
    db.collection("transportTrips")
      .where("programId", "==", data.programId)
      .where("destinationHotelId", "==", data.hotelId)
      .where("status", "==", "enRoute")
      .orderBy("departedAt")
      .limit(tripListCap)
      .get(),
    db.collection("programTravelLegs")
      .where("programId", "==", data.programId)
      .where("destinationHotelId", "==", data.hotelId)
      .where("readiness", "in", ["expected", "ready"])
      .limit(500)
      .get(),
  ]);
  const legs = new Map<string, ProgramTravelLegDocument>();
  const guestIds = new Set<string>();
  for (const doc of legsSnap.docs) {
    const leg = doc.data() as ProgramTravelLegDocument;
    legs.set(doc.id, leg);
    guestIds.add(leg.guestId);
  }
  const trips = tripsSnap.docs.map((doc) => ({
    id: doc.id, doc: doc.data() as TransportTripDocument}));
  for (const trip of trips) {
    for (const legId of trip.doc.legIds) {
      const legSnap = await db.collection("programTravelLegs")
        .doc(legId).get();
      const leg = legSnap.data() as ProgramTravelLegDocument | undefined;
      if (leg && leg.programId === data.programId) {
        legs.set(legId, leg);
        guestIds.add(leg.guestId);
      }
    }
  }
  const partyIds = [...new Set([...legs.values()]
    .map((leg) => leg.partyId)
    .filter((id): id is string => id !== null))];
  const [guestSnaps, partySnaps] = await Promise.all([
    Promise.all([...guestIds].map((id) =>
      db.collection("programGuests").doc(id).get())),
    Promise.all(partyIds.map((id) =>
      db.collection("programTravelParties").doc(id).get())),
  ]);
  const guests = new Map<string, ProgramGuestDocument>();
  for (const snap of guestSnaps) {
    const guest = snap.data() as ProgramGuestDocument | undefined;
    if (guest && guest.programId === data.programId) {
      guests.set(snap.id, guest);
    }
  }
  const parties = new Map<string, ProgramTravelPartyDocument>();
  for (const snap of partySnaps) {
    const party = snap.data() as ProgramTravelPartyDocument | undefined;
    if (party && party.programId === data.programId) {
      parties.set(snap.id, party);
    }
  }
  const settings = access.program.transportSettings;
  const now = deps.now();
  return {
    programId: data.programId,
    hotelId: data.hotelId,
    hotelName: hotel.name,
    generatedAtMillis: now.toMillis(),
    trips: trips.map((trip) => ({
      tripId: trip.id,
      plateDisplay: trip.doc.plateDisplay,
      vehicleClassId: trip.doc.vehicleClassId,
      vendorName: trip.doc.vendorNameSnapshot,
      departedAtMillis: staffTimestampMillis(trip.doc.departedAt),
      estimatedArriveAtMillis: null,
      passengerCount: trip.doc.passengerCount,
      guestNames: trip.doc.legIds
        .map((legId) => legs.get(legId)?.guestId)
        .map((guestId) => guestId ? guests.get(guestId)?.displayName :
          undefined)
        .filter((name): name is string => name !== undefined),
      status: trip.doc.status,
      revision: trip.doc.revision,
    })),
    expectedLegs: legsSnap.docs.map((doc) => {
      const leg = legs.get(doc.id)!;
      const timing = legTiming(leg, settings);
      return {
        legId: doc.id,
        guestDisplayName: guests.get(leg.guestId)?.displayName ?? "Guest",
        partyLabel: leg.partyId ? parties.get(leg.partyId)?.label ??
          null : null,
        passengers: leg.passengers,
        curbAtMillis: timing.kind === "available" ?
          timing.curbAtMillis : null,
        readiness: leg.readiness,
      };
    }),
  };
}

export async function listProgramTripsHandler(
  request: CallableRequest<unknown>,
  deps: ProgramDataDeps = defaultProgramDataDeps
): Promise<ProgramTripListCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<ProgramIdCallablePayload>(
    request, validateProgramIdCallablePayload, normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "listProgramTrips");
  const access = await requireProgramAccess({
    db, programId: data.programId, actorUid, now: deps.now(),
  });
  const duties: ProgramDutyAssignment[] = [
    ...dutyAssignments(access, "reconciliationViewer"),
    ...dutyAssignments(access, "transportDispatcher"),
  ];
  if (access.role !== "manager") {
    if (duties.length === 0) {
      throw new HttpsError(
        "permission-denied",
        "This account has no reconciliation or dispatcher duty.");
    }
  }
  // Apply resource predicates before each page cap. Filtering a global first
  // page could hide every trip at a less busy assigned station.
  const scopes = access.role === "manager" ? [{pickup: [], hotels: []}] :
    duties.flatMap((duty) => {
      const pickups = duty.pickupPointIds;
      const hotels = duty.hotelIds;
      const chunks = (ids: string[]): string[][] => ids.length === 0 ? [[]] :
        Array.from({length: Math.ceil(ids.length / 30)}, (_, index) =>
          ids.slice(index * 30, (index + 1) * 30));
      const pickupChunks = hotels.length > 0 ?
        (pickups.length ? pickups.map((id) => [id]) : [[]]) : chunks(pickups);
      return pickupChunks.flatMap((pickup) =>
        chunks(hotels).map((hotelScope) => ({pickup, hotels: hotelScope})));
    });
  const uniqueScopes = new Map(scopes.map((scope) =>
    [JSON.stringify(scope), scope]));
  const pages = await Promise.all([...uniqueScopes.values()].map((scope) => {
    let query = db.collection("transportTrips")
      .where("programId", "==", data.programId);
    if (scope.pickup.length) {
      query = query.where("pickupPointId", "in", scope.pickup);
    }
    if (scope.hotels.length) {
      query = query.where("destinationHotelId", "in", scope.hotels);
    }
    return query.orderBy("departedAt", "desc").limit(tripListCap).get();
  }));
  const byId = new Map(pages.flatMap((page) =>
    page.docs.map((doc) => [doc.id, doc])));
  const visibleTrips = [...byId.values()].sort((a, b) =>
    staffTimestampMillis(b.data().departedAt) -
      staffTimestampMillis(a.data().departedAt) || a.id.localeCompare(b.id))
    .slice(0, tripListCap);
  const guestIds = new Set<string>();
  const legIds = new Set<string>();
  for (const doc of visibleTrips) {
    for (const legId of (doc.data() as TransportTripDocument).legIds) {
      legIds.add(legId);
    }
  }
  const legSnaps = await Promise.all([...legIds].map((id) =>
    db.collection("programTravelLegs").doc(id).get()));
  const legs = new Map<string, ProgramTravelLegDocument>();
  for (const snap of legSnaps) {
    const leg = snap.data() as ProgramTravelLegDocument | undefined;
    if (leg && leg.programId === data.programId) {
      legs.set(snap.id, leg);
      guestIds.add(leg.guestId);
    }
  }
  const guestSnaps = await Promise.all([...guestIds].map((id) =>
    db.collection("programGuests").doc(id).get()));
  const guests = new Map<string, ProgramGuestDocument>();
  for (const snap of guestSnaps) {
    const guest = snap.data() as ProgramGuestDocument | undefined;
    if (guest && guest.programId === data.programId) {
      guests.set(snap.id, guest);
    }
  }
  return {
    programId: data.programId,
    trips: visibleTrips.map((doc) => {
      const trip = doc.data() as TransportTripDocument;
      return {
        tripId: doc.id,
        pickupPointId: trip.pickupPointId,
        destinationHotelId: trip.destinationHotelId,
        destinationLabel: trip.destinationLabel ?? "Unassigned",
        vehicleClassId: trip.vehicleClassId,
        plateDisplay: trip.plateDisplay,
        vendorId: trip.vendorId,
        vendorName: trip.vendorNameSnapshot,
        kind: trip.kind,
        status: trip.status,
        passengerCount: trip.passengerCount,
        departedAtMillis: staffTimestampMillis(trip.departedAt),
        arrivedAtMillis: trip.arrivedAt ?
          staffTimestampMillis(trip.arrivedAt) : null,
        voidReason: trip.voidReason,
        guestNames: trip.legIds
          .map((legId) => legs.get(legId)?.guestId)
          .map((guestId) => guestId ? guests.get(guestId)?.displayName :
            undefined)
          .filter((name): name is string => name !== undefined),
        revision: trip.revision,
      };
    }),
  };
}

function normalizePayload(value: unknown): unknown {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return value;
  }
  const input = value as Record<string, unknown>;
  const trimmed = {...input};
  for (const key of ["programId", "hotelId"]) {
    if (typeof trimmed[key] === "string") {
      trimmed[key] = (trimmed[key] as string).trim();
    }
  }
  return trimmed;
}

export const getProgramHotelInbound = onCall(
  appCheckCallableOptionsWithLimits(readLimits),
  (request) => getProgramHotelInboundHandler(request)
);
export const listProgramTrips = onCall(
  appCheckCallableOptionsWithLimits(readLimits),
  (request) => listProgramTripsHandler(request)
);
