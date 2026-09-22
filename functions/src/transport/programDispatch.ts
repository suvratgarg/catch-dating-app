import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithLimits} from "../shared/callableOptions";
import {validateCallableWithAjv} from "../shared/validation";
import {
  assertRevision,
  dutyAssignments,
  dutyCoversHotel,
  dutyCoversPickupPoint,
  nextRevision,
  requireProgramAccess,
} from "../shared/programAuthority";
import {hashRequest} from "../shared/programOperationHash";
import type {
  ProgramHotelDocument,
  ProgramTravelLegDocument,
  TransportActiveAssignmentDocument,
  TransportOperationReceiptDocument,
  TransportTripDocument,
  TransportVendorDocument,
} from "../shared/generated/firestoreAdminTypes";
import type {DispatchProgramTripCallablePayload} from
  "../shared/generated/dispatchProgramTripCallablePayload";
import type {ProgramTripActionCallablePayload} from
  "../shared/generated/programTripActionCallablePayload";
import type {DispatchProgramTripCallableResponse} from
  "../shared/generated/dispatchProgramTripCallableResponse";
import type {ProgramMutationCallableResponse} from
  "../shared/generated/programMutationCallableResponse";
import {
  validateDispatchProgramTripCallablePayload,
} from "../shared/generated/validators/dispatchProgramTripInput";
import {
  validateProgramTripActionCallablePayload,
} from "../shared/generated/validators/programTripActionInput";

import {defaultProgramDataDeps} from "../shared/programDataDeps";
import type {ProgramDataDeps} from "../shared/programDataDeps";

const dispatchCallableLimits = {timeoutSeconds: 60, maxInstances: 40};
const receiptRetentionMillis = 7 * 24 * 60 * 60 * 1000;

export function transportAssignmentId(programId: string,
  legId: string): string {
  return `${programId}__${legId}`;
}

export function normalizePlate(plate: string): string {
  return plate.toUpperCase().replace(/[^A-Z0-9]/g, "");
}

export async function dispatchProgramTripHandler(
  request: CallableRequest<unknown>,
  deps: ProgramDataDeps = defaultProgramDataDeps
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
      resultJson: null,
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
  deps: ProgramDataDeps = defaultProgramDataDeps
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
      resultJson: null,
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
  deps: ProgramDataDeps = defaultProgramDataDeps
): Promise<ProgramMutationCallableResponse> {
  const actorUid = requireAuth(request);
  await deps.checkRateLimit(
    deps.firestore(), actorUid, "markProgramTripArrived");
  return tripActionHandler(request, "markArrived", deps);
}

export async function voidProgramTripHandler(
  request: CallableRequest<unknown>,
  deps: ProgramDataDeps = defaultProgramDataDeps
): Promise<ProgramMutationCallableResponse> {
  const actorUid = requireAuth(request);
  await deps.checkRateLimit(
    deps.firestore(), actorUid, "voidProgramTrip");
  return tripActionHandler(request, "void", deps);
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
export {getProgramHotelInbound, getProgramHotelInboundHandler,
  listProgramTrips, listProgramTripsHandler} from "./programTripReads";
