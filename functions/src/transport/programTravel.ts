import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithLimits} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {validateCallableWithAjv} from "../shared/validation";
import {
  assertRevision,
  nextRevision,
  requireProgramAccess,
  requireProgramDuty,
} from "../shared/programAuthority";
import {nextFlightRefreshAt} from "./flightRefresh";
import type {
  ProgramGuestDocument,
  ProgramTravelLegDocument,
  ProgramTravelPartyDocument,
} from "../shared/generated/firestoreAdminTypes";
import type {UpsertProgramTravelLegCallablePayload} from
  "../shared/generated/upsertProgramTravelLegCallablePayload";
import type {UpsertProgramTravelPartyCallablePayload} from
  "../shared/generated/upsertProgramTravelPartyCallablePayload";
import type {ProgramMutationCallableResponse} from
  "../shared/generated/programMutationCallableResponse";
import {
  validateUpsertProgramTravelLegCallablePayload,
} from "../shared/generated/validators/upsertProgramTravelLegInput";
import {
  validateUpsertProgramTravelPartyCallablePayload,
} from "../shared/generated/validators/upsertProgramTravelPartyInput";

interface TravelDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
  now: () => FirebaseFirestore.Timestamp;
}

const defaultDeps: TravelDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  now: () => admin.firestore.Timestamp.now(),
};

const travelCallableLimits = {timeoutSeconds: 60, maxInstances: 20};

export async function upsertProgramTravelLegHandler(
  request: CallableRequest<unknown>,
  deps: TravelDeps = defaultDeps
): Promise<ProgramMutationCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<UpsertProgramTravelLegCallablePayload>(
    request, validateUpsertProgramTravelLegCallablePayload, normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "upsertProgramTravelLeg");
  const access = await requireProgramAccess({
    db, programId: data.programId, actorUid, now: deps.now(),
  });
  requireProgramDuty(access, "programCoordinator");
  const guestSnap = await db.collection("programGuests")
    .doc(data.guestId).get();
  const guest = guestSnap.data() as ProgramGuestDocument | undefined;
  if (!guest || guest.programId !== data.programId) {
    throw new HttpsError(
      "invalid-argument", "Guest is not in this program.");
  }
  if (data.pickupPointId) {
    await requireProgramDoc(
      db, "programPickupPoints", data.pickupPointId, data.programId,
      "Pickup point");
  }
  if (data.destinationHotelId) {
    await requireProgramDoc(
      db, "programHotels", data.destinationHotelId, data.programId, "Hotel");
  }
  if (data.partyId) {
    await requireProgramDoc(
      db, "programTravelParties", data.partyId, data.programId, "Party");
  }
  if (!data.destinationHotelId && !data.destinationLabel) {
    throw new HttpsError(
      "invalid-argument",
      "A leg needs a hotel destination or a destination label.");
  }
  const ref = data.legId ?
    db.collection("programTravelLegs").doc(data.legId) :
    db.collection("programTravelLegs").doc();
  let committedRevision = 0;
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const existing = snap.data() as ProgramTravelLegDocument | undefined;
    if (snap.exists && existing!.programId !== data.programId) {
      throw new HttpsError("not-found", "Leg not found in this program.");
    }
    assertRevision(existing?.revision ?? 0, snap.exists ?
      data.expectedRevision : undefined);
    // Operational state must survive planner edits to itinerary fields.
    if (existing && ["dispatched", "arrived"].includes(existing.readiness)) {
      throw new HttpsError(
        "failed-precondition",
        "This leg is already dispatched; void the trip instead.");
    }
    const now = deps.now();
    const document: ProgramTravelLegDocument = {
      programId: data.programId,
      organizerId: access.program.organizerId,
      guestId: data.guestId,
      partyId: data.partyId === undefined ?
        existing?.partyId ?? null : data.partyId,
      kind: data.kind,
      flightNumber: data.flightNumber === undefined ?
        existing?.flightNumber ?? null : data.flightNumber,
      carrierCode: data.carrierCode === undefined ?
        existing?.carrierCode ?? null : data.carrierCode,
      originIata: data.originIata === undefined ?
        existing?.originIata ?? null : data.originIata,
      destinationIata: data.destinationIata === undefined ?
        existing?.destinationIata ?? null : data.destinationIata,
      scheduledArrivalAt: data.scheduledArrivalAtMillis === undefined ?
        existing?.scheduledArrivalAt ?? null :
        data.scheduledArrivalAtMillis === null ? null :
          admin.firestore.Timestamp.fromMillis(data.scheduledArrivalAtMillis),
      estimatedArrivalAt: existing?.estimatedArrivalAt ?? null,
      actualArrivalAt: existing?.actualArrivalAt ?? null,
      flightStatus: existing?.flightStatus ??
        (data.flightNumber ? "scheduled" : "unknown"),
      flightInstanceId: existing?.flightInstanceId ?? null,
      // Provider-owned fields: itinerary edits never overwrite enrichment.
      arrivalTerminal: existing?.arrivalTerminal ?? null,
      flightRefreshedAt: existing?.flightRefreshedAt ?? null,
      flightNextRefreshAt: existing?.flightNextRefreshAt ?? null,
      international: data.international === undefined ?
        existing?.international ?? null : data.international,
      pickupPointId: data.pickupPointId === undefined ?
        existing?.pickupPointId ?? null : data.pickupPointId,
      destinationHotelId: data.destinationHotelId === undefined ?
        existing?.destinationHotelId ?? null : data.destinationHotelId,
      destinationLabel: data.destinationLabel === undefined ?
        existing?.destinationLabel ?? null : data.destinationLabel,
      readiness: existing?.readiness ?? "expected",
      readyAt: existing?.readyAt ?? null,
      claimedByUid: existing?.claimedByUid ?? null,
      claimedAt: existing?.claimedAt ?? null,
      manualCurbAt: existing?.manualCurbAt ?? null,
      manualCurbNote: existing?.manualCurbNote ?? null,
      passengers: data.passengers,
      luggageUnits: data.luggageUnits,
      requiredCapabilities: data.requiredCapabilities,
      dedicatedVehicle: data.dedicatedVehicle,
      source: existing?.source ?? "planner",
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      revision: nextRevision(existing?.revision, now),
    };
    // New flight legs, or legs whose number changed, join the refresh queue.
    if (!snap.exists || document.flightNumber !== existing?.flightNumber) {
      document.flightNextRefreshAt = nextFlightRefreshAt(
        document.flightNumber, document.scheduledArrivalAt, now.toDate());
    }
    committedRevision = document.revision;
    tx.set(ref, document);
  });
  return {entityId: ref.id, revision: committedRevision,
    alreadyApplied: false};
}

export async function upsertProgramTravelPartyHandler(
  request: CallableRequest<unknown>,
  deps: TravelDeps = defaultDeps
): Promise<ProgramMutationCallableResponse> {
  const actorUid = requireAuth(request);
  const data =
    validateCallableWithAjv<UpsertProgramTravelPartyCallablePayload>(
      request, validateUpsertProgramTravelPartyCallablePayload,
      normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "upsertProgramTravelParty");
  const access = await requireProgramAccess({
    db, programId: data.programId, actorUid, now: deps.now(),
  });
  requireProgramDuty(access, "programCoordinator");
  for (const guestId of data.memberGuestIds) {
    const snap = await db.collection("programGuests").doc(guestId).get();
    const guest = snap.data() as ProgramGuestDocument | undefined;
    if (!guest || guest.programId !== data.programId) {
      throw new HttpsError(
        "invalid-argument",
        `Guest ${guestId} is not in this program.`);
    }
  }
  const ref = data.partyId ?
    db.collection("programTravelParties").doc(data.partyId) :
    db.collection("programTravelParties").doc();
  let committedRevision = 0;
  await db.runTransaction(async (tx) => {
    // All transaction reads must precede writes.
    const snap = await tx.get(ref);
    const legSnaps = await Promise.all(data.memberGuestIds.map((guestId) =>
      tx.get(db.collection("programTravelLegs")
        .where("programId", "==", data.programId)
        .where("guestId", "==", guestId)
        .limit(4))));
    const existing = snap.data() as ProgramTravelPartyDocument | undefined;
    if (snap.exists && existing!.programId !== data.programId) {
      throw new HttpsError("not-found", "Party not found in this program.");
    }
    assertRevision(existing?.revision ?? 0, snap.exists ?
      data.expectedRevision : undefined);
    const now = deps.now();
    const document: ProgramTravelPartyDocument = {
      programId: data.programId,
      organizerId: access.program.organizerId,
      label: data.label === undefined ?
        existing?.label ?? null : data.label,
      memberGuestIds: data.memberGuestIds,
      dedicatedVehicle: data.dedicatedVehicle,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      revision: nextRevision(existing?.revision, now),
    };
    committedRevision = document.revision;
    tx.set(ref, document);
    // Keep legs' partyId in step with party membership.
    for (const legs of legSnaps) {
      for (const legDoc of legs.docs) {
        if (legDoc.data().partyId !== ref.id) {
          tx.update(legDoc.ref, {
            partyId: ref.id,
            updatedAt: now,
            revision: nextRevision(
              (legDoc.data() as ProgramTravelLegDocument).revision, now),
          });
        }
      }
    }
  });
  return {entityId: ref.id, revision: committedRevision,
    alreadyApplied: false};
}

async function requireProgramDoc(
  db: FirebaseFirestore.Firestore,
  collection: string,
  id: string,
  programId: string,
  label: string
): Promise<void> {
  const snap = await db.collection(collection).doc(id).get();
  const doc = snap.data() as {programId?: string} | undefined;
  if (!doc || doc.programId !== programId) {
    throw new HttpsError(
      "invalid-argument", `${label} is not in this program.`);
  }
}

function normalizePayload(value: unknown): unknown {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return value;
  }
  const input = value as Record<string, unknown>;
  const trimmed = {...input};
  for (const key of ["programId", "legId", "partyId", "guestId",
    "flightNumber", "carrierCode", "originIata", "destinationIata",
    "destinationLabel", "pickupPointId", "destinationHotelId"]) {
    if (typeof trimmed[key] === "string") {
      trimmed[key] = (trimmed[key] as string).trim();
    }
  }
  return trimmed;
}

export const upsertProgramTravelLeg = onCall(
  appCheckCallableOptionsWithLimits(travelCallableLimits),
  (request) => upsertProgramTravelLegHandler(request)
);
export const upsertProgramTravelParty = onCall(
  appCheckCallableOptionsWithLimits(travelCallableLimits),
  (request) => upsertProgramTravelPartyHandler(request)
);
