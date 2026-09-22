import * as admin from "firebase-admin";
import {hashRequest} from "../shared/programOperationHash";
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
  dutyCoversPickupPoint,
  nextRevision,
  programStaffGrantId,
  requireProgramAccess,
} from "../shared/programAuthority";
import type {
  ProgramAccess,
  ProgramDutyAssignment,
} from "../shared/programAuthority";
import {resolveArrivalTiming} from "./arrivalTiming";
import {
  TransportParty,
  VehicleClass,
  suggestTransportGroups,
} from "./grouping";
import type {
  ProgramGuestDocument,
  ProgramTravelLegDocument,
  ProgramTravelPartyDocument,
  TransportOperationReceiptDocument,
} from "../shared/generated/firestoreAdminTypes";
import type {ProgramStationScopeCallablePayload} from
  "../shared/generated/programStationScopeCallablePayload";
import type {SetProgramTravelReadinessCallablePayload} from
  "../shared/generated/setProgramTravelReadinessCallablePayload";
import type {ProgramArrivalsRosterCallableResponse} from
  "../shared/generated/programArrivalsRosterCallableResponse";
import type {ProgramTransportPlanCallableResponse} from
  "../shared/generated/programTransportPlanCallableResponse";
import type {ProgramMutationCallableResponse} from
  "../shared/generated/programMutationCallableResponse";
import {
  validateProgramStationScopeCallablePayload,
} from "../shared/generated/validators/programStationScopeInput";
import {
  validateSetProgramTravelReadinessCallablePayload,
} from "../shared/generated/validators/setProgramTravelReadinessInput";

interface ArrivalsDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
  now: () => FirebaseFirestore.Timestamp;
}

const defaultDeps: ArrivalsDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  now: () => admin.firestore.Timestamp.now(),
};

const arrivalsCallableLimits = {timeoutSeconds: 60, maxInstances: 40};
const rosterCap = 500;
const receiptRetentionMillis = 7 * 24 * 60 * 60 * 1000;

type StationAccess = {
  access: ProgramAccess;
  assignments: ProgramDutyAssignment[];
  stationScope: Set<string> | null;
};

/** Greeters and dispatchers share the operational arrivals surface. */
async function requireStationAccess(
  db: FirebaseFirestore.Firestore,
  programId: string,
  actorUid: string,
  now: FirebaseFirestore.Timestamp
): Promise<StationAccess> {
  const access = await requireProgramAccess({
    db, programId, actorUid, now,
  });
  const assignments = access.role === "manager" ? [] : [
    ...dutyAssignments(access, "airportGreeter"),
    ...dutyAssignments(access, "transportDispatcher"),
  ];
  if (access.role !== "manager" && assignments.length === 0) {
    throw new HttpsError(
      "permission-denied",
      "This account has no airport duty for this program."
    );
  }
  const stationScope = access.role === "manager" ? null :
    unionStationScope(assignments);
  return {access, assignments, stationScope};
}

function unionStationScope(
  assignments: ProgramDutyAssignment[]
): Set<string> | null {
  const scoped = new Set<string>();
  for (const assignment of assignments) {
    if (assignment.pickupPointIds.length === 0) return null;
    for (const id of assignment.pickupPointIds) scoped.add(id);
  }
  return scoped;
}

interface LegContext {
  legs: Array<{id: string; doc: ProgramTravelLegDocument}>;
  guests: Map<string, ProgramGuestDocument>;
  parties: Map<string, ProgramTravelPartyDocument>;
}

async function loadLegContext(
  db: FirebaseFirestore.Firestore,
  programId: string,
  stationScope: Set<string> | null,
  requestedStation: string | null
): Promise<LegContext> {
  if (requestedStation !== null && stationScope !== null &&
      !stationScope.has(requestedStation)) {
    throw new HttpsError(
      "permission-denied",
      "This station is outside your assigned scope."
    );
  }
  let query: FirebaseFirestore.Query = db.collection("programTravelLegs")
    .where("programId", "==", programId)
    .where("kind", "==", "inbound")
    .where("readiness", "in", ["expected", "ready", "disrupted"]);
  if (requestedStation !== null) {
    query = query.where("pickupPointId", "==", requestedStation);
  }
  const legsSnap = await query.limit(rosterCap + 1).get();
  const legs = legsSnap.docs
    .map((doc) => ({id: doc.id,
      doc: doc.data() as ProgramTravelLegDocument}))
    .filter((leg) =>
      leg.doc.pickupPointId !== null &&
      (stationScope === null ||
        stationScope.has(leg.doc.pickupPointId!)));
  const guestIds = [...new Set(legs.map((leg) => leg.doc.guestId))];
  const partyIds = [...new Set(legs.map((leg) => leg.doc.partyId)
    .filter((id): id is string => id !== null))];
  const [guestSnaps, partySnaps] = await Promise.all([
    Promise.all(guestIds.map((id) =>
      db.collection("programGuests").doc(id).get())),
    Promise.all(partyIds.map((id) =>
      db.collection("programTravelParties").doc(id).get())),
  ]);
  const guests = new Map<string, ProgramGuestDocument>();
  for (const snap of guestSnaps) {
    const doc = snap.data() as ProgramGuestDocument | undefined;
    if (doc && doc.programId === programId) guests.set(snap.id, doc);
  }
  const parties = new Map<string, ProgramTravelPartyDocument>();
  for (const snap of partySnaps) {
    const doc = snap.data() as ProgramTravelPartyDocument | undefined;
    if (doc && doc.programId === programId) parties.set(snap.id, doc);
  }
  return {legs, guests, parties};
}

export function legTiming(leg: ProgramTravelLegDocument,
  settings: ProgramAccess["program"]["transportSettings"]) {
  const statusMap: Record<string,
    "scheduled" | "airborne" | "landed" | "cancelled" | "diverted"> = {
      scheduled: "scheduled",
      enroute: "airborne",
      landed: "landed",
      delayed: "scheduled",
      unknown: "scheduled",
      cancelled: "cancelled",
      diverted: "diverted",
    };
  return resolveArrivalTiming({
    flight: leg.flightNumber ? {
      status: statusMap[leg.flightStatus] ?? "scheduled",
      scheduledLandingAtMillis: leg.scheduledArrivalAt ?
        staffTimestampMillis(leg.scheduledArrivalAt) : null,
      estimatedLandingAtMillis: leg.estimatedArrivalAt ?
        staffTimestampMillis(leg.estimatedArrivalAt) : null,
      actualLandingAtMillis: leg.actualArrivalAt ?
        staffTimestampMillis(leg.actualArrivalAt) : null,
    } : null,
    exitLagMillis: leg.international ?
      settings.internationalExitLagMillis : settings.domesticExitLagMillis,
    manualCurbAtMillis: leg.manualCurbAt ?
      staffTimestampMillis(leg.manualCurbAt) : null,
    readyAtMillis: leg.readyAt ? staffTimestampMillis(leg.readyAt) : null,
  });
}

export async function getProgramArrivalsRosterHandler(
  request: CallableRequest<unknown>,
  deps: ArrivalsDeps = defaultDeps
): Promise<ProgramArrivalsRosterCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<ProgramStationScopeCallablePayload>(
    request, validateProgramStationScopeCallablePayload, normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "getProgramArrivalsRoster");
  const now = deps.now();
  const {access, stationScope} = await requireStationAccess(
    db, data.programId, actorUid, now);
  const {legs, guests, parties} = await loadLegContext(
    db, data.programId, stationScope, data.pickupPointId ?? null);
  const settings = access.program.transportSettings;
  // Resolve claimant display names through staff grants; never leak uids.
  const claimantUids = [...new Set(legs.map((leg) => leg.doc.claimedByUid)
    .filter((uid): uid is string => uid !== null))];
  const claimantSnaps = await Promise.all(claimantUids.map((uid) =>
    db.collection("programStaffGrants")
      .doc(programStaffGrantId(data.programId, uid)).get()));
  const claimantNames = new Map<string, string>();
  claimantSnaps.forEach((snap, index) => {
    const grant = snap.data() as
      {displayName?: string; programId?: string} | undefined;
    if (grant && grant.programId === data.programId &&
        grant.displayName) {
      claimantNames.set(claimantUids[index], grant.displayName);
    }
  });
  return {
    programId: data.programId,
    pickupPointId: data.pickupPointId ?? null,
    generatedAtMillis: now.toMillis(),
    rows: legs.map((leg) => {
      const timing = legTiming(leg.doc, settings);
      const guest = guests.get(leg.doc.guestId);
      const party = leg.doc.partyId ? parties.get(leg.doc.partyId) : null;
      const claimed = leg.doc.claimedByUid;
      return {
        legId: leg.id,
        guestId: leg.doc.guestId,
        partyId: leg.doc.partyId,
        guestDisplayName: guest?.displayName ?? "Guest",
        partyLabel: party?.label ?? null,
        partyGuestIds: party?.memberGuestIds ?? [leg.doc.guestId],
        passengers: leg.doc.passengers,
        luggageUnits: leg.doc.luggageUnits,
        flightNumber: leg.doc.flightNumber,
        originIata: leg.doc.originIata,
        arrivalTerminal: leg.doc.arrivalTerminal,
        flightStatus: leg.doc.flightStatus,
        curbAtMillis: timing.kind === "available" ?
          timing.curbAtMillis : null,
        curbSource: timing.kind === "available" ? timing.source : null,
        unavailableReason: timing.kind === "unavailable" ?
          timing.reason : null,
        readiness: leg.doc.readiness,
        claimedByDisplay: claimed ?
          claimantNames.get(claimed) ?? "Staff" : null,
        claimedByMe: claimed === actorUid,
        destinationHotelId: leg.doc.destinationHotelId,
        destinationLabel: leg.doc.destinationLabel ??
          leg.doc.destinationHotelId ?? "Unassigned",
        requiredCapabilities: leg.doc.requiredCapabilities,
        dedicatedVehicle: leg.doc.dedicatedVehicle,
        revision: leg.doc.revision,
      };
    }),
    vehicleClasses: settings.vehicleClasses,
  };
}

export async function getProgramTransportPlanHandler(
  request: CallableRequest<unknown>,
  deps: ArrivalsDeps = defaultDeps
): Promise<ProgramTransportPlanCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<ProgramStationScopeCallablePayload>(
    request, validateProgramStationScopeCallablePayload, normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "getProgramTransportPlan");
  const now = deps.now();
  const {access, stationScope} = await requireStationAccess(
    db, data.programId, actorUid, now);
  const {legs, parties} = await loadLegContext(
    db, data.programId, stationScope, data.pickupPointId ?? null);
  const settings = access.program.transportSettings;

  // Fold legs into ride-together units for the policy. A party's availability
  // is its slowest member; a member without usable timing unschedules the
  // whole party because a vehicle must not split it.
  const unitMap = new Map<string, {
    key: string;
    legIds: string[];
    partyId: string | null;
    pickupPointId: string | null;
    destinationId: string | null;
    readiness: "expected" | "ready";
    readyAt: number;
    availableAt: number | null;
    unusable: boolean;
    passengers: number;
    luggageUnits: number;
    capabilities: Set<string>;
    dedicated: boolean;
  }>();
  const unassigned: ProgramTransportPlanCallableResponse["unassigned"] = [];
  for (const leg of legs) {
    const key = leg.doc.partyId ?? leg.id;
    let unit = unitMap.get(key);
    if (!unit) {
      const party = leg.doc.partyId ? parties.get(leg.doc.partyId) : null;
      unit = {
        key,
        legIds: [],
        partyId: leg.doc.partyId,
        pickupPointId: leg.doc.pickupPointId,
        destinationId: leg.doc.destinationHotelId ??
          (leg.doc.destinationLabel ?
            `label:${leg.doc.destinationLabel.toLowerCase()}` : null),
        readiness: "ready",
        readyAt: 0,
        availableAt: 0,
        unusable: false,
        passengers: 0,
        luggageUnits: 0,
        capabilities: new Set(),
        dedicated: leg.doc.dedicatedVehicle ||
          (party?.dedicatedVehicle ?? false),
      };
      unitMap.set(key, unit);
    }
    unit.legIds.push(leg.id);
    unit.passengers += leg.doc.passengers;
    unit.luggageUnits += leg.doc.luggageUnits;
    for (const capability of leg.doc.requiredCapabilities) {
      unit.capabilities.add(capability);
    }
    unit.dedicated = unit.dedicated || leg.doc.dedicatedVehicle;
    const timing = legTiming(leg.doc, settings);
    if (timing.kind === "unavailable") {
      unit.unusable = true;
      unit.availableAt = null;
    } else if (!unit.unusable) {
      unit.availableAt = Math.max(unit.availableAt!, timing.curbAtMillis);
    }
    if (leg.doc.readiness === "ready" && leg.doc.readyAt) {
      unit.readyAt = Math.max(unit.readyAt,
        staffTimestampMillis(leg.doc.readyAt));
    } else {
      unit.readiness = "expected";
    }
    if (leg.doc.pickupPointId !== unit.pickupPointId ||
        (leg.doc.destinationHotelId ??
          (leg.doc.destinationLabel ?
            `label:${leg.doc.destinationLabel.toLowerCase()}` : null)) !==
          unit.destinationId) {
      unit.unusable = true;
    }
  }

  const parties_: TransportParty[] = [];
  for (const unit of unitMap.values()) {
    if (!unit.pickupPointId || !unit.destinationId) {
      for (const legId of unit.legIds) {
        unassigned.push({legId, reason: "missingScope"});
      }
      continue;
    }
    if (unit.unusable || unit.availableAt === null) {
      for (const legId of unit.legIds) {
        unassigned.push({legId, reason: "missingTime"});
      }
      continue;
    }
    const ready = unit.readiness === "ready" && unit.readyAt > 0;
    parties_.push({
      id: unit.key,
      programId: data.programId,
      pickupPointId: unit.pickupPointId,
      destinationId: unit.destinationId,
      readiness: ready ? "ready" : "expected",
      availableAtMillis: ready ? unit.readyAt : unit.availableAt,
      passengers: unit.passengers,
      luggageUnits: unit.luggageUnits,
      requiredCapabilities: [...unit.capabilities],
      dedicatedVehicle: unit.dedicated,
    });
  }

  const classes: VehicleClass[] = settings.vehicleClasses.map((vehicle) => ({
    id: vehicle.id,
    passengerCapacity: vehicle.passengerCapacity,
    luggageCapacity: vehicle.luggageCapacity,
    capabilities: vehicle.capabilities,
  }));
  const result = suggestTransportGroups({
    parties: parties_,
    vehicleClasses: classes,
    windowMillis: settings.bandWindowMillis,
    maxReadyWaitMillis: settings.maxReadyWaitMillis,
    nowMillis: now.toMillis(),
  });
  for (const item of result.unassigned) {
    for (const legId of unitMap.get(item.partyId)?.legIds ?? []) {
      unassigned.push({legId, reason: item.reason});
    }
  }
  const classLabels = new Map(settings.vehicleClasses.map(
    (vehicle) => [vehicle.id, vehicle.label]));
  const destinationLabels = new Map<string, string>();
  for (const leg of legs) {
    const key = leg.doc.destinationHotelId ??
      (leg.doc.destinationLabel ?
        `label:${leg.doc.destinationLabel.toLowerCase()}` : null);
    if (key) {
      destinationLabels.set(key,
        leg.doc.destinationLabel ?? leg.doc.destinationHotelId!);
    }
  }
  return {
    programId: data.programId,
    pickupPointId: data.pickupPointId ?? null,
    generatedAtMillis: now.toMillis(),
    groups: result.groups.map((group) => {
      const legIds = group.partyIds.flatMap(
        (key) => unitMap.get(key)?.legIds ?? []);
      return {
        legIds,
        partyIds: group.partyIds
          .map((key) => unitMap.get(key)?.partyId ?? null)
          .filter((id): id is string => id !== null),
        destinationHotelId: group.destinationId.startsWith("label:") ?
          null : group.destinationId,
        destinationLabel: destinationLabels.get(group.destinationId) ??
          group.destinationId,
        readiness: group.readiness,
        vehicleClassId: group.vehicleClassId,
        vehicleClassLabel: classLabels.get(group.vehicleClassId) ??
          group.vehicleClassId,
        passengers: group.passengers,
        luggageUnits: group.luggageUnits,
        earliestCurbAtMillis: group.earliestAtMillis,
        latestCurbAtMillis: group.latestAtMillis,
        dispatchByMillis: group.dispatchByMillis,
        waitOverdue: group.waitOverdue,
      };
    }),
    unassigned,
  };
}

export async function setProgramTravelReadinessHandler(
  request: CallableRequest<unknown>,
  deps: ArrivalsDeps = defaultDeps
): Promise<ProgramMutationCallableResponse> {
  const actorUid = requireAuth(request);
  const data =
    validateCallableWithAjv<SetProgramTravelReadinessCallablePayload>(
      request, validateSetProgramTravelReadinessCallablePayload,
      normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "setProgramTravelReadiness");
  const {access, assignments} = await requireStationAccess(
    db, data.programId, actorUid, deps.now());
  const requestHash = hashRequest({
    programId: data.programId,
    legId: data.legId,
    action: data.action,
    expectedRevision: data.expectedRevision ?? null,
    manualCurbAtMillis: data.manualCurbAtMillis ?? null,
  });
  const receiptRef = db.collection("transportOperationReceipts").doc(
    `${data.programId}__${data.action}__${data.clientOperationId}`);
  const legRef = db.collection("programTravelLegs").doc(data.legId);
  let result: {revision: number; alreadyApplied: boolean} | null = null;
  await db.runTransaction(async (tx) => {
    const [receiptSnap, legSnap] = await Promise.all([
      tx.get(receiptRef), tx.get(legRef)]);
    const receipt = receiptSnap.data() as
      TransportOperationReceiptDocument | undefined;
    if (receipt) {
      if (receipt.requestHash !== requestHash ||
          receipt.actorUid !== actorUid) {
        throw new HttpsError(
          "aborted",
          "This operation id was already used for a different request.");
      }
      result = {revision: receipt.resultRevision, alreadyApplied: true};
      return;
    }
    const leg = legSnap.data() as ProgramTravelLegDocument | undefined;
    if (!leg || leg.programId !== data.programId) {
      throw new HttpsError("not-found", "Leg not found in this program.");
    }
    // Re-check duty scope inside the transaction against the stored leg.
    if (access.role !== "manager" &&
        !dutyCoversPickupPoint(assignments, leg.pickupPointId ?? "")) {
      throw new HttpsError(
        "permission-denied",
        "This station is outside your assigned scope.");
    }
    assertRevision(leg.revision, data.expectedRevision);
    if (["dispatched", "arrived"].includes(leg.readiness)) {
      throw new HttpsError(
        "failed-precondition",
        "This guest is already dispatched.");
    }
    const now = deps.now();
    const update: Record<string, unknown> = {
      updatedAt: now,
      revision: nextRevision(leg.revision, now),
    };
    switch (data.action) {
    case "claim":
      if (leg.claimedByUid && leg.claimedByUid !== actorUid) {
        throw new HttpsError(
          "already-exists", "Another greeter has claimed this guest.");
      }
      update.claimedByUid = actorUid;
      update.claimedAt = now;
      break;
    case "unclaim":
      if (leg.claimedByUid && leg.claimedByUid !== actorUid &&
            access.role !== "manager" &&
            dutyAssignments(access, "transportDispatcher").length === 0) {
        throw new HttpsError(
          "permission-denied", "Only the claimant can release a claim.");
      }
      update.claimedByUid = null;
      update.claimedAt = null;
      break;
    case "markReady":
      update.readiness = "ready";
      update.readyAt = now;
      if (data.manualCurbAtMillis !== undefined &&
            data.manualCurbAtMillis !== null) {
        update.manualCurbAt = admin.firestore.Timestamp.fromMillis(
          data.manualCurbAtMillis);
        update.manualCurbNote = data.manualCurbNote ?? null;
      }
      break;
    case "markDisrupted":
      update.readiness = "disrupted";
      if (data.manualCurbAtMillis !== undefined &&
            data.manualCurbAtMillis !== null) {
        update.manualCurbAt = admin.firestore.Timestamp.fromMillis(
          data.manualCurbAtMillis);
        update.manualCurbNote = data.manualCurbNote ?? null;
      }
      break;
    }
    tx.update(legRef, update);
    const receiptDoc: TransportOperationReceiptDocument = {
      programId: data.programId,
      operationKind: data.action,
      clientOperationId: data.clientOperationId,
      actorUid,
      requestHash,
      tripId: null,
      legId: data.legId,
      resultRevision: update.revision as number,
      resultJson: null,
      createdAt: now,
      expiresAt: admin.firestore.Timestamp.fromMillis(
        now.toMillis() + receiptRetentionMillis),
    };
    tx.set(receiptRef, receiptDoc);
    result = {revision: update.revision as number, alreadyApplied: false};
  });
  return {entityId: data.legId, revision: result!.revision,
    alreadyApplied: result!.alreadyApplied};
}


function normalizePayload(value: unknown): unknown {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return value;
  }
  const input = value as Record<string, unknown>;
  const trimmed = {...input};
  for (const key of ["programId", "legId", "pickupPointId",
    "clientOperationId"]) {
    if (typeof trimmed[key] === "string") {
      trimmed[key] = (trimmed[key] as string).trim();
    }
  }
  return trimmed;
}

export const getProgramArrivalsRoster = onCall(
  appCheckCallableOptionsWithLimits(arrivalsCallableLimits),
  (request) => getProgramArrivalsRosterHandler(request)
);
export const getProgramTransportPlan = onCall(
  appCheckCallableOptionsWithLimits(arrivalsCallableLimits),
  (request) => getProgramTransportPlanHandler(request)
);
export const setProgramTravelReadiness = onCall(
  appCheckCallableOptionsWithLimits(arrivalsCallableLimits),
  (request) => setProgramTravelReadinessHandler(request)
);
