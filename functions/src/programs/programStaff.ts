import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithLimits} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {validateCallableWithAjv} from "../shared/validation";
import {isOrganizerManager} from "../shared/organizerHosts";
import {
  loadProgramBundle,
  nextRevision,
  programStaffGrantId,
  requireProgramAccess,
} from "../shared/programAuthority";
import {staffTimestampMillis} from "../shared/eventOperatorAuthority";
import {normalizeRosterPhone} from "../events/eventAttendees";
import {eventStaffDisplayName, resolveStaffAuthUser} from
  "../events/eventStaff";
import type {
  ProgramHotelDocument,
  ProgramPickupPointDocument,
  ProgramStaffGrantDocument,
} from "../shared/generated/firestoreAdminTypes";
import type {ProgramIdCallablePayload} from
  "../shared/generated/programIdCallablePayload";
import type {GrantProgramStaffCallablePayload} from
  "../shared/generated/grantProgramStaffCallablePayload";
import type {RevokeProgramStaffCallablePayload} from
  "../shared/generated/revokeProgramStaffCallablePayload";
import type {ProgramAccessCallableResponse} from
  "../shared/generated/programAccessCallableResponse";
import type {ProgramStaffListCallableResponse} from
  "../shared/generated/programStaffListCallableResponse";
import {
  validateProgramIdCallablePayload,
} from "../shared/generated/validators/programIdInput";
import {
  validateGrantProgramStaffCallablePayload,
} from "../shared/generated/validators/grantProgramStaffInput";
import {
  validateRevokeProgramStaffCallablePayload,
} from "../shared/generated/validators/revokeProgramStaffInput";

interface ProgramStaffDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
  now: () => FirebaseFirestore.Timestamp;
  getUserByPhoneNumber: (
    phoneNumber: string
  ) => Promise<admin.auth.UserRecord>;
}

const defaultDeps: ProgramStaffDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  now: () => admin.firestore.Timestamp.now(),
  getUserByPhoneNumber: (phoneNumber) =>
    admin.auth().getUserByPhoneNumber(phoneNumber),
};

const maxProgramStaff = 100;
const maxGrantDurationMillis = 14 * 24 * 60 * 60 * 1000;

const staffCallableLimits = {timeoutSeconds: 60, maxInstances: 20};

/** Work-shell bootstrap: role, duties, station scopes and labeled resources. */
export async function getProgramWorkAccessHandler(
  request: CallableRequest<unknown>,
  deps: ProgramStaffDeps = defaultDeps
): Promise<ProgramAccessCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<ProgramIdCallablePayload>(
    request, validateProgramIdCallablePayload, normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "getProgramWorkAccess");
  const access = await requireProgramAccess({
    db, programId: data.programId, actorUid, now: deps.now(),
  });
  const {program} = access;
  const pickupScope = access.role === "manager" ? null :
    unionScope(access.grant!, "pickupPointIds");
  const hotelScope = access.role === "manager" ? null :
    unionScope(access.grant!, "hotelIds");
  const [pickupsSnap, hotelsSnap] = await Promise.all([
    db.collection("programPickupPoints")
      .where("programId", "==", data.programId)
      .where("active", "==", true).limit(32).get(),
    db.collection("programHotels")
      .where("programId", "==", data.programId)
      .where("active", "==", true).limit(64).get(),
  ]);
  const pickupPoints = pickupsSnap.docs
    .map((doc) => ({id: doc.id,
      doc: doc.data() as ProgramPickupPointDocument}))
    .filter((entry) => pickupScope === null || pickupScope.has(entry.id))
    .map((entry) => ({
      pickupPointId: entry.id,
      label: entry.doc.label,
      kind: entry.doc.kind,
      iataCode: entry.doc.iataCode,
      terminal: entry.doc.terminal,
    }));
  const hotels = hotelsSnap.docs
    .map((doc) => ({id: doc.id, doc: doc.data() as ProgramHotelDocument}))
    .filter((entry) => hotelScope === null || hotelScope.has(entry.id))
    .map((entry) => ({hotelId: entry.id, name: entry.doc.name}));
  return {
    programId: data.programId,
    organizerId: program.organizerId,
    title: program.title,
    kind: program.kind,
    timezone: program.timezone,
    status: program.status,
    actorRole: access.role,
    duties: access.role === "manager" ? [] : access.grant!.duties,
    grantExpiresAtMillis: access.grant ?
      staffTimestampMillis(access.grant.expiresAt) : null,
    capabilities: program.capabilities,
    pickupPoints,
    hotels,
    vehicleClasses: program.transportSettings.vehicleClasses,
  };
}

export async function listProgramStaffHandler(
  request: CallableRequest<unknown>,
  deps: ProgramStaffDeps = defaultDeps
): Promise<ProgramStaffListCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<ProgramIdCallablePayload>(
    request, validateProgramIdCallablePayload, normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "listProgramStaff");
  await requireProgramManager(db, data.programId, actorUid);
  return programStaffList(db, data.programId, deps.now());
}

export async function grantProgramStaffHandler(
  request: CallableRequest<unknown>,
  deps: ProgramStaffDeps = defaultDeps
): Promise<ProgramStaffListCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<GrantProgramStaffCallablePayload>(
    request, validateGrantProgramStaffCallablePayload, normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "grantProgramStaff");
  const {program, organizer} =
    await requireProgramManager(db, data.programId, actorUid);
  const now = deps.now();
  if (data.expiresAtMillis <= now.toMillis() ||
      data.expiresAtMillis > now.toMillis() + maxGrantDurationMillis) {
    throw new HttpsError(
      "invalid-argument",
      "Program staff access must expire within the next 14 days."
    );
  }
  await validateDutyStations(db, data.programId, data.duties);
  const phone = normalizeRosterPhone(data.phoneNumber);
  if (!phone.value || phone.issue) {
    throw new HttpsError("invalid-argument", phone.issue ?? "Invalid phone.");
  }
  const authUser = await resolveStaffAuthUser(
    deps.getUserByPhoneNumber, phone.value);
  if (isOrganizerManager(organizer, authUser.uid)) {
    throw new HttpsError(
      "failed-precondition",
      "Organizer managers already have program access."
    );
  }
  const ref = db.collection("programStaffGrants").doc(
    programStaffGrantId(data.programId, authUser.uid));
  await db.runTransaction(async (tx) => {
    const fresh = await requireProgramManager(
      db, data.programId, actorUid, tx);
    if (fresh.program.organizerId !== program.organizerId ||
        isOrganizerManager(fresh.organizer, authUser.uid)) {
      throw new HttpsError("aborted", "Program staff authority changed.");
    }
    const [currentSnap, activeSnap] = await Promise.all([
      tx.get(ref),
      tx.get(db.collection("programStaffGrants")
        .where("programId", "==", data.programId)
        .where("status", "==", "active")
        .where("expiresAt", ">", now)
        .limit(maxProgramStaff)),
    ]);
    const current = currentSnap.data() as ProgramStaffGrantDocument |
      undefined;
    const currentActive = current?.status === "active" &&
      staffTimestampMillis(current.expiresAt) > now.toMillis();
    if (!currentActive && activeSnap.size >= maxProgramStaff) {
      throw new HttpsError(
        "resource-exhausted",
        "This program already has the maximum number of staff grants."
      );
    }
    const committedAt = deps.now();
    if (data.expiresAtMillis <= committedAt.toMillis() ||
        data.expiresAtMillis >
          committedAt.toMillis() + maxGrantDurationMillis) {
      throw new HttpsError("failed-precondition",
        "Staff access window changed.");
    }
    const document: ProgramStaffGrantDocument = {
      organizerId: program.organizerId,
      programId: data.programId,
      uid: authUser.uid,
      displayName: eventStaffDisplayName(authUser),
      phoneLastFour: phone.value!.slice(-4),
      duties: dedupeDuties(data.duties),
      status: "active",
      createdBy: current?.createdBy ?? actorUid,
      createdAt: current?.createdAt ?? committedAt,
      expiresAt:
        admin.firestore.Timestamp.fromMillis(data.expiresAtMillis),
      revokedBy: null,
      revokedAt: null,
      updatedAt: committedAt,
      revision: nextRevision(current?.revision, committedAt),
    };
    tx.set(ref, document);
  });
  return programStaffList(db, data.programId, deps.now());
}

export async function revokeProgramStaffHandler(
  request: CallableRequest<unknown>,
  deps: ProgramStaffDeps = defaultDeps
): Promise<ProgramStaffListCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<RevokeProgramStaffCallablePayload>(
    request, validateRevokeProgramStaffCallablePayload, normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "revokeProgramStaff");
  await requireProgramManager(db, data.programId, actorUid);
  const ref = db.collection("programStaffGrants").doc(
    programStaffGrantId(data.programId, data.uid));
  const now = deps.now();
  await db.runTransaction(async (tx) => {
    await requireProgramManager(db, data.programId, actorUid, tx);
    const snap = await tx.get(ref);
    const grant = snap.data() as ProgramStaffGrantDocument | undefined;
    if (!grant || grant.programId !== data.programId) {
      throw new HttpsError("not-found", "Program staff member not found.");
    }
    if (grant.revision !== data.expectedRevision) {
      throw new HttpsError(
        "aborted", "Staff access changed. Reload and retry.");
    }
    tx.update(ref, {
      status: "revoked",
      revokedBy: actorUid,
      revokedAt: now,
      updatedAt: now,
      revision: nextRevision(grant.revision, now),
    });
  });
  return programStaffList(db, data.programId, deps.now());
}

async function programStaffList(
  db: FirebaseFirestore.Firestore,
  programId: string,
  now: FirebaseFirestore.Timestamp
): Promise<ProgramStaffListCallableResponse> {
  const snap = await db.collection("programStaffGrants")
    .where("programId", "==", programId)
    .orderBy("updatedAt", "desc")
    .limit(maxProgramStaff)
    .get();
  const members = snap.docs
    .map((doc) => doc.data() as ProgramStaffGrantDocument)
    .sort((a, b) =>
      staffTimestampMillis(b.updatedAt) - staffTimestampMillis(a.updatedAt));
  return {
    programId,
    members: members.map((member) => ({
      uid: member.uid,
      displayName: member.displayName,
      phoneLastFour: member.phoneLastFour,
      duties: member.duties,
      status: member.status === "revoked" ? "revoked" :
        staffTimestampMillis(member.expiresAt) <= now.toMillis() ?
          "expired" : "active",
      expiresAtMillis: staffTimestampMillis(member.expiresAt),
      revision: member.revision,
    })),
  };
}

async function requireProgramManager(
  db: FirebaseFirestore.Firestore,
  programId: string,
  actorUid: string,
  transaction?: FirebaseFirestore.Transaction
): Promise<Awaited<ReturnType<typeof loadProgramBundle>>> {
  const bundle = await loadProgramBundle({db, programId, transaction});
  if (!isOrganizerManager(bundle.organizer, actorUid)) {
    throw new HttpsError(
      "permission-denied",
      "Only organizer managers can manage program staff."
    );
  }
  return bundle;
}

/** Referenced stations must exist inside the program. */
async function validateDutyStations(
  db: FirebaseFirestore.Firestore,
  programId: string,
  duties: GrantProgramStaffCallablePayload["duties"]
): Promise<void> {
  const pickupIds = new Set<string>();
  const hotelIds = new Set<string>();
  for (const assignment of duties) {
    for (const id of assignment.pickupPointIds) pickupIds.add(id);
    for (const id of assignment.hotelIds) hotelIds.add(id);
  }
  const missing: string[] = [];
  for (const id of pickupIds) {
    const snap = await db.collection("programPickupPoints").doc(id).get();
    const point = snap.data() as ProgramPickupPointDocument | undefined;
    if (!point || point.programId !== programId) missing.push(id);
  }
  for (const id of hotelIds) {
    const snap = await db.collection("programHotels").doc(id).get();
    const hotel = snap.data() as ProgramHotelDocument | undefined;
    if (!hotel || hotel.programId !== programId) missing.push(id);
  }
  if (missing.length > 0) {
    throw new HttpsError(
      "invalid-argument",
      `Stations outside this program: ${missing.join(", ")}.`
    );
  }
}

function dedupeDuties(
  duties: GrantProgramStaffCallablePayload["duties"]
): ProgramStaffGrantDocument["duties"] {
  const byDuty = new Map<string,
    ProgramStaffGrantDocument["duties"][number]>();
  for (const assignment of duties) {
    const existing = byDuty.get(assignment.duty);
    if (existing) {
      existing.pickupPointIds = [...new Set([
        ...existing.pickupPointIds, ...assignment.pickupPointIds])];
      existing.hotelIds = [...new Set([
        ...existing.hotelIds, ...assignment.hotelIds])];
    } else {
      byDuty.set(assignment.duty, {
        duty: assignment.duty,
        pickupPointIds: [...assignment.pickupPointIds],
        hotelIds: [...assignment.hotelIds],
      });
    }
  }
  return [...byDuty.values()];
}

function unionScope(grant: ProgramStaffGrantDocument,
  field: "pickupPointIds" | "hotelIds"): Set<string> | null {
  const scoped = new Set<string>();
  for (const assignment of grant.duties) {
    if (assignment[field].length === 0) return null;
    for (const id of assignment[field]) scoped.add(id);
  }
  return scoped;
}

function normalizePayload(value: unknown): unknown {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return value;
  }
  const input = value as Record<string, unknown>;
  const trimmed = {...input};
  for (const key of ["programId", "uid", "phoneNumber"]) {
    if (typeof trimmed[key] === "string") {
      trimmed[key] = (trimmed[key] as string).trim();
    }
  }
  return trimmed;
}

export const getProgramWorkAccess = onCall(
  appCheckCallableOptionsWithLimits(staffCallableLimits),
  (request) => getProgramWorkAccessHandler(request)
);
export const listProgramStaff = onCall(
  appCheckCallableOptionsWithLimits(staffCallableLimits),
  (request) => listProgramStaffHandler(request)
);
export const grantProgramStaff = onCall(
  appCheckCallableOptionsWithLimits(staffCallableLimits),
  (request) => grantProgramStaffHandler(request)
);
export const revokeProgramStaff = onCall(
  appCheckCallableOptionsWithLimits(staffCallableLimits),
  (request) => revokeProgramStaffHandler(request)
);
