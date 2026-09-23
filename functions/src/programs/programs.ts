/* firestore-index: organizerPrograms (
  organizerId:ASCENDING,
  startsAt:DESCENDING
) */
/* firestore-index: programTravelLegs (
  programId:ASCENDING,
  kind:ASCENDING
) */
/* firestore-index: programStaffGrants (
  programId:ASCENDING,
  status:ASCENDING
) */
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithLimits} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {requireOrganizerManager} from "../shared/organizerManagerAuthority";
import {isOrganizerManager} from "../shared/organizerHosts";
import {
  assertRevision,
  loadProgramBundle,
  nextRevision,
} from "../shared/programAuthority";
import type {
  OrganizerProgramDocument,
  ProgramFunctionDocument,
  ProgramHotelDocument,
  ProgramPickupPointDocument,
} from "../shared/generated/firestoreAdminTypes";
import type {CreateOrganizerProgramCallablePayload} from
  "../shared/generated/createOrganizerProgramCallablePayload";
import type {UpdateOrganizerProgramCallablePayload} from
  "../shared/generated/updateOrganizerProgramCallablePayload";
import type {ListOrganizerProgramsCallablePayload} from
  "../shared/generated/listOrganizerProgramsCallablePayload";
import type {ProgramIdCallablePayload} from
  "../shared/generated/programIdCallablePayload";
import type {OrganizerProgramCallableResponse} from
  "../shared/generated/organizerProgramCallableResponse";
import type {OrganizerProgramListCallableResponse} from
  "../shared/generated/organizerProgramListCallableResponse";
import type {ProgramMutationCallableResponse} from
  "../shared/generated/programMutationCallableResponse";
import {
  validateCreateOrganizerProgramCallablePayload,
} from "../shared/generated/validators/createOrganizerProgramInput";
import {
  validateUpdateOrganizerProgramCallablePayload,
} from "../shared/generated/validators/updateOrganizerProgramInput";
import {
  validateListOrganizerProgramsCallablePayload,
} from "../shared/generated/validators/listOrganizerProgramsInput";
import {
  validateProgramIdCallablePayload,
} from "../shared/generated/validators/programIdInput";

interface ProgramDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
  now: () => FirebaseFirestore.Timestamp;
}

const defaultDeps: ProgramDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  now: () => admin.firestore.Timestamp.now(),
};

const defaultTransportSettings:
  OrganizerProgramDocument["transportSettings"] = {
    bandWindowMillis: 30 * 60 * 1000,
    maxReadyWaitMillis: 10 * 60 * 1000,
    domesticExitLagMillis: 25 * 60 * 1000,
    internationalExitLagMillis: 60 * 60 * 1000,
    vehicleClasses: [
      {id: "sedan", label: "Sedan", passengerCapacity: 3,
        luggageCapacity: 3, capabilities: [], sortOrder: 0},
      {id: "suv", label: "Innova / SUV", passengerCapacity: 6,
        luggageCapacity: 8, capabilities: ["extraLuggage"], sortOrder: 1},
      {id: "tempo", label: "Tempo Traveller", passengerCapacity: 12,
        luggageCapacity: 16, capabilities: ["extraLuggage"], sortOrder: 2},
    ],
  };

const programCallableLimits = {timeoutSeconds: 60, maxInstances: 20};

export async function createOrganizerProgramHandler(
  request: CallableRequest<unknown>,
  deps: ProgramDeps = defaultDeps
): Promise<ProgramMutationCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<CreateOrganizerProgramCallablePayload>(
    request,
    validateCreateOrganizerProgramCallablePayload,
    normalizeProgramPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "createOrganizerProgram");
  if (data.endsAtMillis <= data.startsAtMillis) {
    throw new HttpsError(
      "invalid-argument", "Program end must be after its start."
    );
  }
  const settings = data.transportSettings ?? defaultTransportSettings;
  validateVehicleClasses(settings.vehicleClasses);
  const ref = db.collection("organizerPrograms").doc();
  await db.runTransaction(async (tx) => {
    await requireOrganizerManager({
      db, organizerId: data.organizerId, actorUid, transaction: tx,
    });
    const now = deps.now();
    const document: OrganizerProgramDocument = {
      organizerId: data.organizerId,
      kind: data.kind,
      title: data.title,
      timezone: data.timezone,
      startsAt: admin.firestore.Timestamp.fromMillis(data.startsAtMillis),
      endsAt: admin.firestore.Timestamp.fromMillis(data.endsAtMillis),
      status: "draft",
      capabilities: data.capabilities,
      transportSettings: settings,
      createdBy: actorUid,
      createdAt: now,
      updatedAt: now,
      revision: 1,
    };
    tx.set(ref, document);
  });
  return {entityId: ref.id, revision: 1, alreadyApplied: false};
}

export async function updateOrganizerProgramHandler(
  request: CallableRequest<unknown>,
  deps: ProgramDeps = defaultDeps
): Promise<ProgramMutationCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<UpdateOrganizerProgramCallablePayload>(
    request,
    validateUpdateOrganizerProgramCallablePayload,
    normalizeProgramPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "updateOrganizerProgram");
  const ref = db.collection("organizerPrograms").doc(data.programId);
  let committedRevision = 0;
  await db.runTransaction(async (tx) => {
    const {program, organizer} = await loadProgramBundle({
      db, programId: data.programId, transaction: tx,
    });
    if (!isOrganizerManager(organizer, actorUid)) {
      throw new HttpsError(
        "permission-denied", "Only organizer managers can edit programs."
      );
    }
    assertRevision(program.revision, data.expectedRevision);
    if (data.transportSettings) {
      validateVehicleClasses(data.transportSettings.vehicleClasses);
    }
    const startsAtMillis = data.startsAtMillis ?? program.startsAt.toMillis();
    const endsAtMillis = data.endsAtMillis ?? program.endsAt.toMillis();
    if (endsAtMillis <= startsAtMillis) {
      throw new HttpsError(
        "invalid-argument", "Program end must be after its start."
      );
    }
    const now = deps.now();
    const update: Record<string, unknown> = {
      updatedAt: now,
      revision: nextRevision(program.revision, now),
    };
    if (data.title !== undefined) update.title = data.title;
    if (data.timezone !== undefined) update.timezone = data.timezone;
    if (data.status !== undefined) update.status = data.status;
    if (data.capabilities !== undefined) {
      update.capabilities = data.capabilities;
    }
    if (data.transportSettings !== undefined) {
      update.transportSettings = data.transportSettings;
    }
    if (data.startsAtMillis !== undefined) {
      update.startsAt =
        admin.firestore.Timestamp.fromMillis(data.startsAtMillis);
    }
    if (data.endsAtMillis !== undefined) {
      update.endsAt =
        admin.firestore.Timestamp.fromMillis(data.endsAtMillis);
    }
    committedRevision = update.revision as number;
    tx.update(ref, update);
  });
  return {
    entityId: data.programId,
    revision: committedRevision,
    alreadyApplied: false,
  };
}

export async function listOrganizerProgramsHandler(
  request: CallableRequest<unknown>,
  deps: ProgramDeps = defaultDeps
): Promise<OrganizerProgramListCallableResponse> {
  const actorUid = requireAuth(request);
  const data =
    validateCallableWithAjv<ListOrganizerProgramsCallablePayload>(
      request,
      validateListOrganizerProgramsCallablePayload,
      normalizeProgramPayload
    );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "listOrganizerPrograms");
  await requireOrganizerManager({
    db, organizerId: data.organizerId, actorUid,
  });
  const snap = await db.collection("organizerPrograms")
    .where("organizerId", "==", data.organizerId)
    .orderBy("startsAt", "desc")
    .limit(data.limit ?? 50)
    .get();
  return {
    programs: snap.docs.map((doc) => {
      const program = requireDoc<OrganizerProgramDocument>(
        doc, "OrganizerProgramDocument");
      return {
        programId: doc.id,
        kind: program.kind,
        title: program.title,
        status: program.status,
        startsAtMillis: program.startsAt.toMillis(),
        endsAtMillis: program.endsAt.toMillis(),
        capabilities: program.capabilities,
        revision: program.revision,
      };
    }),
  };
}

export async function getOrganizerProgramHandler(
  request: CallableRequest<unknown>,
  deps: ProgramDeps = defaultDeps
): Promise<OrganizerProgramCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<ProgramIdCallablePayload>(
    request, validateProgramIdCallablePayload, normalizeProgramPayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "getOrganizerProgram");
  const {program, organizer} = await loadProgramBundle({
    db, programId: data.programId,
  });
  if (!isOrganizerManager(organizer, actorUid)) {
    throw new HttpsError(
      "permission-denied",
      "Only organizer managers can open program setup."
    );
  }
  const [functionsSnap, pickupsSnap, hotelsSnap, guestsSnap,
    householdsSnap, legsSnap, staffSnap] = await Promise.all([
    db.collection("programFunctions")
      .where("programId", "==", data.programId).limit(40).get(),
    db.collection("programPickupPoints")
      .where("programId", "==", data.programId).limit(32).get(),
    db.collection("programHotels")
      .where("programId", "==", data.programId).limit(64).get(),
    db.collection("programGuests")
      .where("programId", "==", data.programId).limit(501).get(),
    db.collection("programHouseholds")
      .where("programId", "==", data.programId).limit(501).get(),
    db.collection("programTravelLegs")
      .where("programId", "==", data.programId)
      .where("kind", "==", "inbound").limit(501).get(),
    db.collection("programStaffGrants")
      .where("programId", "==", data.programId)
      .where("status", "==", "active").limit(101).get(),
  ]);
  const capped = (snap: FirebaseFirestore.QuerySnapshot) =>
    Math.min(snap.size, 500);
  return {
    program: {
      programId: data.programId,
      kind: program.kind,
      title: program.title,
      timezone: program.timezone,
      status: program.status,
      startsAtMillis: program.startsAt.toMillis(),
      endsAtMillis: program.endsAt.toMillis(),
      capabilities: program.capabilities,
      transportSettings: program.transportSettings,
      revision: program.revision,
    },
    functions: functionsSnap.docs.map((doc) => {
      const fn = doc.data() as ProgramFunctionDocument;
      return {
        functionId: doc.id,
        name: fn.name,
        startsAtMillis: fn.startsAt.toMillis(),
        endsAtMillis: fn.endsAt.toMillis(),
        venueName: fn.venueName,
        status: fn.status,
      };
    }),
    pickupPoints: pickupsSnap.docs.map((doc) => {
      const point = doc.data() as ProgramPickupPointDocument;
      return {
        pickupPointId: doc.id,
        kind: point.kind,
        label: point.label,
        iataCode: point.iataCode,
        terminal: point.terminal,
        meetingZone: point.meetingZone,
        instructions: point.instructions,
        active: point.active,
        revision: point.revision,
      };
    }),
    hotels: hotelsSnap.docs.map((doc) => {
      const hotel = doc.data() as ProgramHotelDocument;
      return {
        hotelId: doc.id,
        name: hotel.name,
        address: hotel.address,
        receptionContact: hotel.receptionContact,
        active: hotel.active,
        revision: hotel.revision,
      };
    }),
    counts: {
      guests: capped(guestsSnap),
      households: capped(householdsSnap),
      inboundLegs: capped(legsSnap),
      activeStaff: Math.min(staffSnap.size, 100),
    },
  };
}

export function validateVehicleClasses(
  classes: OrganizerProgramDocument["transportSettings"]["vehicleClasses"]
): void {
  const ids = new Set<string>();
  for (const vehicle of classes) {
    if (ids.has(vehicle.id)) {
      throw new HttpsError(
        "invalid-argument", `Duplicate vehicle class "${vehicle.id}".`
      );
    }
    ids.add(vehicle.id);
  }
}

function normalizeProgramPayload(value: unknown): unknown {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return value;
  }
  const input = value as Record<string, unknown>;
  const trimmed = {...input};
  for (const key of [
    "programId", "organizerId", "title", "timezone", "name", "label",
    "venueName", "address",
  ]) {
    if (typeof trimmed[key] === "string") {
      trimmed[key] = (trimmed[key] as string).trim();
    }
  }
  return trimmed;
}

export const createOrganizerProgram = onCall(
  appCheckCallableOptionsWithLimits(programCallableLimits),
  (request) => createOrganizerProgramHandler(request)
);
export const updateOrganizerProgram = onCall(
  appCheckCallableOptionsWithLimits(programCallableLimits),
  (request) => updateOrganizerProgramHandler(request)
);
export const listOrganizerPrograms = onCall(
  appCheckCallableOptionsWithLimits(programCallableLimits),
  (request) => listOrganizerProgramsHandler(request)
);
export const getOrganizerProgram = onCall(
  appCheckCallableOptionsWithLimits(programCallableLimits),
  (request) => getOrganizerProgramHandler(request)
);
