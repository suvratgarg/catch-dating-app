import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithLimits} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {validateCallableWithAjv} from "../shared/validation";
import {staffTimestampMillis} from "../shared/eventOperatorAuthority";
import {
  assertRevision,
  dutyAssignments,
  dutyCoversHotel,
  dutyCoversPickupPoint,
  nextRevision,
  requireProgramAccess,
} from "../shared/programAuthority";
import type {ProgramDutyAssignment} from "../shared/programAuthority";
import {hashRequest, legTiming} from "./programArrivals";
import type {
  ProgramGuestDocument,
  ProgramHotelDocument,
  ProgramTravelLegDocument,
  ProgramTravelPartyDocument,
  TransportActiveAssignmentDocument,
  TransportOperationReceiptDocument,
  TransportTripDocument,
  TransportVendorDocument,
} from "../shared/generated/firestoreAdminTypes";
import type {DispatchProgramTripCallablePayload} from
  "../shared/generated/dispatchProgramTripCallablePayload";
import type {ProgramTripActionCallablePayload} from
  "../shared/generated/programTripActionCallablePayload";
import type {GetProgramHotelInboundCallablePayload} from
  "../shared/generated/getProgramHotelInboundCallablePayload";
import type {ProgramIdCallablePayload} from
  "../shared/generated/programIdCallablePayload";
import type {DispatchProgramTripCallableResponse} from
  "../shared/generated/dispatchProgramTripCallableResponse";
import type {ProgramHotelInboundCallableResponse} from
  "../shared/generated/programHotelInboundCallableResponse";
import type {ProgramMutationCallableResponse} from
  "../shared/generated/programMutationCallableResponse";
import type {ProgramTripListCallableResponse} from
  "../shared/generated/programTripListCallableResponse";
import {
  validateDispatchProgramTripCallablePayload,
} from "../shared/generated/validators/dispatchProgramTripInput";
import {
  validateProgramTripActionCallablePayload,
} from "../shared/generated/validators/programTripActionInput";
import {
  validateGetProgramHotelInboundCallablePayload,
} from "../shared/generated/validators/getProgramHotelInboundInput";
import {
  validateProgramIdCallablePayload,
} from "../shared/generated/validators/programIdInput";

interface DispatchDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
  now: () => FirebaseFirestore.Timestamp;
}

const defaultDeps: DispatchDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  now: () => admin.firestore.Timestamp.now(),
};

const dispatchCallableLimits = {timeoutSeconds: 60, maxInstances: 40};
const receiptRetentionMillis = 7 * 24 * 60 * 60 * 1000;
const tripListCap = 200;

export function transportAssignmentId(programId: string,
  legId: string): string {
  return `${programId}__${legId}`;
}

export function normalizePlate(plate: string): string {
  return plate.toUpperCase().replace(/[^A-Z0-9]/g, "");
}

export async function dispatchProgramTripHandler(
  request: CallableRequest<unknown>,
  deps: DispatchDeps = defaultDeps
): Promise<DispatchProgramTripCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<DispatchProgramTripCallablePayload>(
    request, validateDispatchProgramTripCallablePayload, normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "dispatchProgramTrip");
  const access = await requireProgramAccess({
    db, programId: data.programId, actorUid, now: deps.now(),
  });
  const assignments = dutyAssignments(access, "transportDispatcher");
  if (access.role !== "manager" && assignments.length === 0) {
    throw new HttpsError(
      "permission-denied",
      "This account has no dispatcher duty for this program.");
  }
  if (access.role !== "manager" &&
      !dutyCoversPickupPoint(assignments, data.pickupPointId)) {
    throw new HttpsError(
      "permission-denied",
      "This station is outside your assigned scope.");
  }
  if (data.destinationHotelId) {
    const hotelSnap = await db.collection("programHotels")
      .doc(data.destinationHotelId).get();
    const hotel = hotelSnap.data() as ProgramHotelDocument | undefined;
    if (!hotel || hotel.programId !== data.programId) {
      throw new HttpsError(
        "invalid-argument", "Destination hotel is not in this program.");
    }
  }
  const vehicleClass = access.program.transportSettings.vehicleClasses
    .find((entry) => entry.id === data.vehicleClassId);
  if (!vehicleClass) {
    throw new HttpsError(
      "invalid-argument",
      `Unknown vehicle class "${data.vehicleClassId}".`);
  }
  let vendorName: string | null = null;
  if (data.vendorId) {
    const vendorSnap = await db.collection("transportVendors")
      .doc(data.vendorId).get();
    const vendor = vendorSnap.data() as TransportVendorDocument | undefined;
    if (!vendor || vendor.organizerId !== access.program.organizerId ||
        !vendor.programIds.includes(data.programId)) {
      throw new HttpsError(
        "invalid-argument", "Vendor is not bound to this program.");
    }
    vendorName = vendor.name;
  }
  const requestHash = hashRequest({
    programId: data.programId,
    pickupPointId: data.pickupPointId,
    destinationHotelId: data.destinationHotelId ?? null,
    vehicleClassId: data.vehicleClassId,
    plateDisplay: data.plateDisplay,
    vendorId: data.vendorId ?? null,
    legIds: [...data.legIds].sort(),
    departedAtMillis: data.departedAtMillis ?? null,
  });
  const receiptRef = db.collection("transportOperationReceipts").doc(
    `${data.programId}__dispatch__${data.clientOperationId}`);
  const tripRef = db.collection("transportTrips").doc();
  let result: DispatchProgramTripCallableResponse | null = null;
  await db.runTransaction(async (tx) => {
    // All reads precede writes.
    const receiptSnap = await tx.get(receiptRef);
    const receipt = receiptSnap.data() as
      TransportOperationReceiptDocument | undefined;
    if (receipt) {
      if (receipt.requestHash !== requestHash ||
          receipt.actorUid !== actorUid) {
        throw new HttpsError(
          "aborted",
          "This operation id was already used for a different request.");
      }
      const tripSnap = await tx.get(
        db.collection("transportTrips").doc(receipt.tripId!));
      const trip = tripSnap.data() as TransportTripDocument | undefined;
      result = {
        tripId: receipt.tripId!,
        revision: receipt.resultRevision,
        alreadyApplied: true,
        passengerCount: trip?.passengerCount ?? data.legIds.length,
      };
      return;
    }
    const legSnaps = await Promise.all(data.legIds.map((legId) =>
      tx.get(db.collection("programTravelLegs").doc(legId))));
    const assignmentSnaps = await Promise.all(data.legIds.map((legId) =>
      tx.get(db.collection("transportActiveAssignments")
        .doc(transportAssignmentId(data.programId, legId)))));
    const revisionFences = new Map((data.expectedLegRevisions ?? [])
      .map((fence) => [fence.legId, fence.revision]));
    const legs: Array<{id: string; doc: ProgramTravelLegDocument}> = [];
    for (const snap of legSnaps) {
      const leg = snap.data() as ProgramTravelLegDocument | undefined;
      if (!leg || leg.programId !== data.programId) {
        throw new HttpsError(
          "not-found", `Leg ${snap.id} is not in this program.`);
      }
      const fence = revisionFences.get(snap.id);
      if (fence !== undefined) assertRevision(leg.revision, fence);
      if (leg.pickupPointId !== data.pickupPointId) {
        throw new HttpsError(
          "failed-precondition",
          `Leg ${snap.id} is not staged at this pickup point.`);
      }
      if (!["ready", "expected"].includes(leg.readiness)) {
        throw new HttpsError(
          "failed-precondition",
          `Leg ${snap.id} is not dispatchable (state ${leg.readiness}).`);
      }
      legs.push({id: snap.id, doc: leg});
    }
    for (const snap of assignmentSnaps) {
      const assignment = snap.data() as
        TransportActiveAssignmentDocument | undefined;
      if (assignment && assignment.status === "active") {
        throw new HttpsError(
          "already-exists",
          `Guest leg ${snap.id.split("__").pop()} is already on a vehicle.`);
      }
    }
    const passengerCount = legs.reduce(
      (sum, leg) => sum + leg.doc.passengers, 0);
    const luggageUnits = legs.reduce(
      (sum, leg) => sum + leg.doc.luggageUnits, 0);
    if (passengerCount > vehicleClass.passengerCapacity ||
        luggageUnits > vehicleClass.luggageCapacity) {
      throw new HttpsError(
        "failed-precondition",
        `Manifest exceeds ${vehicleClass.label} capacity ` +
        `(${passengerCount}/${vehicleClass.passengerCapacity} seats, ` +
        `${luggageUnits}/${vehicleClass.luggageCapacity} luggage).`);
    }
    const now = deps.now();
    const departedAt = data.departedAtMillis !== undefined &&
      data.departedAtMillis !== null ?
      admin.firestore.Timestamp.fromMillis(data.departedAtMillis) : now;
    const destinationLabel = data.destinationLabel ??
      legs[0].doc.destinationLabel ??
      (data.destinationHotelId ? "Hotel" : "Unassigned");
    const partyIds = [...new Set(legs.map((leg) => leg.doc.partyId)
      .filter((id): id is string => id !== null))].sort();
    const trip: TransportTripDocument = {
      programId: data.programId,
      organizerId: access.program.organizerId,
      kind: data.kind ?? "guestTransfer",
      pickupPointId: data.pickupPointId,
      destinationHotelId: data.destinationHotelId ?? null,
      destinationLabel,
      vehicleClassId: data.vehicleClassId,
      vendorId: data.vendorId ?? null,
      vendorNameSnapshot: vendorName,
      plateNormalized: normalizePlate(data.plateDisplay),
      plateDisplay: data.plateDisplay,
      partyIds,
      legIds: [...data.legIds].sort(),
      passengerCount,
      status: "enRoute",
      departedAt,
      departedByUid: actorUid,
      voidedByUid: null,
      voidReason: null,
      arrivedAt: null,
      arrivedByUid: null,
      rateSnapshot: null,
      clientOperationId: data.clientOperationId,
      notes: data.notes ?? null,
      createdAt: now,
      updatedAt: now,
      revision: 1,
    };
    tx.set(tripRef, trip);
    for (const leg of legs) {
      const assignment: TransportActiveAssignmentDocument = {
        programId: data.programId,
        legId: leg.id,
        tripId: tripRef.id,
        status: "active",
        assignedAt: now,
        releasedAt: null,
        revision: 1,
      };
      tx.set(db.collection("transportActiveAssignments")
        .doc(transportAssignmentId(data.programId, leg.id)), assignment);
      tx.update(db.collection("programTravelLegs").doc(leg.id), {
        readiness: "dispatched",
        updatedAt: now,
        revision: nextRevision(leg.doc.revision, now),
      });
    }
    const receiptDoc: TransportOperationReceiptDocument = {
      programId: data.programId,
      operationKind: "dispatch",
      clientOperationId: data.clientOperationId,
      actorUid,
      requestHash,
      tripId: tripRef.id,
      legId: null,
      resultRevision: 1,
      createdAt: now,
      expiresAt: admin.firestore.Timestamp.fromMillis(
        now.toMillis() + receiptRetentionMillis),
    };
    tx.set(receiptRef, receiptDoc);
    result = {
      tripId: tripRef.id,
      revision: 1,
      alreadyApplied: false,
      passengerCount,
    };
  });
  return result!;
}

async function tripActionHandler(
  request: CallableRequest<unknown>,
  action: "markArrived" | "void",
  deps: DispatchDeps = defaultDeps
): Promise<ProgramMutationCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<ProgramTripActionCallablePayload>(
    request, validateProgramTripActionCallablePayload, normalizePayload);
  const db = deps.firestore();
  const access = await requireProgramAccess({
    db, programId: data.programId, actorUid, now: deps.now(),
  });
  if (action === "void" && data.reason == null) {
    throw new HttpsError(
      "invalid-argument", "A void reason is required.");
  }
  const requestHash = hashRequest({
    programId: data.programId,
    tripId: data.tripId,
    action,
    expectedRevision: data.expectedRevision,
    reason: data.reason ?? null,
  });
  const receiptRef = db.collection("transportOperationReceipts").doc(
    `${data.programId}__${action}__${data.clientOperationId}`);
  const tripRef = db.collection("transportTrips").doc(data.tripId);
  let result: ProgramMutationCallableResponse | null = null;
  await db.runTransaction(async (tx) => {
    const [receiptSnap, tripSnap] = await Promise.all([
      tx.get(receiptRef), tx.get(tripRef)]);
    const receipt = receiptSnap.data() as
      TransportOperationReceiptDocument | undefined;
    if (receipt) {
      if (receipt.requestHash !== requestHash ||
          receipt.actorUid !== actorUid) {
        throw new HttpsError(
          "aborted",
          "This operation id was already used for a different request.");
      }
      result = {entityId: data.tripId, revision: receipt.resultRevision,
        alreadyApplied: true};
      return;
    }
    const trip = tripSnap.data() as TransportTripDocument | undefined;
    if (!trip || trip.programId !== data.programId) {
      throw new HttpsError("not-found", "Trip not found in this program.");
    }
    if (access.role !== "manager") {
      if (action === "markArrived") {
        const hotelDuties = dutyAssignments(access, "hotelDesk");
        const dispatcherDuties =
          dutyAssignments(access, "transportDispatcher");
        const allowed = dutyCoversHotel(hotelDuties,
          trip.destinationHotelId ?? "") ||
          dutyCoversPickupPoint(dispatcherDuties, trip.pickupPointId);
        if (!allowed) {
          throw new HttpsError(
            "permission-denied",
            "This trip is outside your assigned scope.");
        }
      } else {
        const dispatcherDuties =
          dutyAssignments(access, "transportDispatcher");
        if (!dutyCoversPickupPoint(dispatcherDuties, trip.pickupPointId)) {
          throw new HttpsError(
            "permission-denied",
            "Only the dispatching station can void this trip.");
        }
      }
    }
    assertRevision(trip.revision, data.expectedRevision);
    if (trip.status !== "enRoute") {
      throw new HttpsError(
        "failed-precondition",
        `Trip is already ${trip.status}.`);
    }
    const now = deps.now();
    const assignmentSnaps = await Promise.all(trip.legIds.map((legId) =>
      tx.get(db.collection("transportActiveAssignments")
        .doc(transportAssignmentId(data.programId, legId)))));
    const legSnaps = await Promise.all(trip.legIds.map((legId) =>
      tx.get(db.collection("programTravelLegs").doc(legId))));
    const tripUpdate: Record<string, unknown> = {
      updatedAt: now,
      revision: nextRevision(trip.revision, now),
    };
    if (action === "markArrived") {
      tripUpdate.status = "arrived";
      tripUpdate.arrivedAt = now;
      tripUpdate.arrivedByUid = actorUid;
    } else {
      tripUpdate.status = "voided";
      tripUpdate.voidedByUid = actorUid;
      tripUpdate.voidReason = data.reason;
    }
    tx.update(tripRef, tripUpdate);
    const legReadiness = action === "markArrived" ? "arrived" : "ready";
    for (let index = 0; index < trip.legIds.length; index += 1) {
      const assignmentSnap = assignmentSnaps[index];
      if (assignmentSnap.exists) {
        tx.update(assignmentSnap.ref, {
          status: "released",
          releasedAt: now,
          revision: nextRevision(
            (assignmentSnap.data() as
              TransportActiveAssignmentDocument).revision, now),
        });
      }
      const legSnap = legSnaps[index];
      const leg = legSnap.data() as ProgramTravelLegDocument | undefined;
      if (leg && leg.readiness === "dispatched") {
        tx.update(legSnap.ref, {
          readiness: legReadiness,
          updatedAt: now,
          revision: nextRevision(leg.revision, now),
        });
      }
    }
    const receiptDoc: TransportOperationReceiptDocument = {
      programId: data.programId,
      operationKind: action === "void" ? "voidTrip" : "markArrived",
      clientOperationId: data.clientOperationId,
      actorUid,
      requestHash,
      tripId: data.tripId,
      legId: null,
      resultRevision: tripUpdate.revision as number,
      createdAt: now,
      expiresAt: admin.firestore.Timestamp.fromMillis(
        now.toMillis() + receiptRetentionMillis),
    };
    tx.set(receiptRef, receiptDoc);
    result = {entityId: data.tripId,
      revision: tripUpdate.revision as number, alreadyApplied: false};
  });
  return result!;
}

export async function markProgramTripArrivedHandler(
  request: CallableRequest<unknown>,
  deps: DispatchDeps = defaultDeps
): Promise<ProgramMutationCallableResponse> {
  const actorUid = requireAuth(request);
  await deps.checkRateLimit(
    deps.firestore(), actorUid, "markProgramTripArrived");
  return tripActionHandler(request, "markArrived", deps);
}

export async function voidProgramTripHandler(
  request: CallableRequest<unknown>,
  deps: DispatchDeps = defaultDeps
): Promise<ProgramMutationCallableResponse> {
  const actorUid = requireAuth(request);
  await deps.checkRateLimit(
    deps.firestore(), actorUid, "voidProgramTrip");
  return tripActionHandler(request, "void", deps);
}

export async function getProgramHotelInboundHandler(
  request: CallableRequest<unknown>,
  deps: DispatchDeps = defaultDeps
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
  deps: DispatchDeps = defaultDeps
): Promise<ProgramTripListCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<ProgramIdCallablePayload>(
    request, validateProgramIdCallablePayload, normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "listProgramTrips");
  const access = await requireProgramAccess({
    db, programId: data.programId, actorUid, now: deps.now(),
  });
  if (access.role !== "manager") {
    const duties: ProgramDutyAssignment[] = [
      ...dutyAssignments(access, "reconciliationViewer"),
      ...dutyAssignments(access, "transportDispatcher"),
    ];
    if (duties.length === 0) {
      throw new HttpsError(
        "permission-denied",
        "This account has no reconciliation or dispatcher duty.");
    }
  }
  const tripsSnap = await db.collection("transportTrips")
    .where("programId", "==", data.programId)
    .orderBy("departedAt", "desc")
    .limit(tripListCap)
    .get();
  const guestIds = new Set<string>();
  const legIds = new Set<string>();
  for (const doc of tripsSnap.docs) {
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
    trips: tripsSnap.docs.map((doc) => {
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
  for (const key of ["programId", "tripId", "pickupPointId", "hotelId",
    "vehicleClassId", "plateDisplay", "vendorId", "destinationHotelId",
    "destinationLabel", "clientOperationId", "reason"]) {
    if (typeof trimmed[key] === "string") {
      trimmed[key] = (trimmed[key] as string).trim();
    }
  }
  return trimmed;
}

export const dispatchProgramTrip = onCall(
  appCheckCallableOptionsWithLimits(dispatchCallableLimits),
  (request) => dispatchProgramTripHandler(request)
);
export const markProgramTripArrived = onCall(
  appCheckCallableOptionsWithLimits(dispatchCallableLimits),
  (request) => markProgramTripArrivedHandler(request)
);
export const voidProgramTrip = onCall(
  appCheckCallableOptionsWithLimits(dispatchCallableLimits),
  (request) => voidProgramTripHandler(request)
);
export const getProgramHotelInbound = onCall(
  appCheckCallableOptionsWithLimits(dispatchCallableLimits),
  (request) => getProgramHotelInboundHandler(request)
);
export const listProgramTrips = onCall(
  appCheckCallableOptionsWithLimits(dispatchCallableLimits),
  (request) => listProgramTripsHandler(request)
);
