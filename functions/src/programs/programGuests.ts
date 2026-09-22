import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithLimits} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {
  assertRevision,
  nextRevision,
  requireProgramAccess,
  requireProgramDuty,
} from "../shared/programAuthority";
import type {
  ProgramGuestDocument,
  ProgramHouseholdDocument,
} from "../shared/generated/firestoreAdminTypes";
import type {UpsertProgramGuestCallablePayload} from
  "../shared/generated/upsertProgramGuestCallablePayload";
import type {ListProgramGuestsCallablePayload} from
  "../shared/generated/listProgramGuestsCallablePayload";
import type {UpsertProgramHouseholdCallablePayload} from
  "../shared/generated/upsertProgramHouseholdCallablePayload";
import type {ProgramIdCallablePayload} from
  "../shared/generated/programIdCallablePayload";
import type {ProgramGuestListCallableResponse} from
  "../shared/generated/programGuestListCallableResponse";
import type {ProgramMutationCallableResponse} from
  "../shared/generated/programMutationCallableResponse";
import {
  validateUpsertProgramGuestCallablePayload,
} from "../shared/generated/validators/upsertProgramGuestInput";
import {
  validateListProgramGuestsCallablePayload,
} from "../shared/generated/validators/listProgramGuestsInput";
import {
  validateUpsertProgramHouseholdCallablePayload,
} from "../shared/generated/validators/upsertProgramHouseholdInput";
import {
  validateProgramIdCallablePayload,
} from "../shared/generated/validators/programIdInput";

interface ProgramGuestDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
  now: () => FirebaseFirestore.Timestamp;
}

const defaultDeps: ProgramGuestDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  now: () => admin.firestore.Timestamp.now(),
};

const guestCallableLimits = {timeoutSeconds: 60, maxInstances: 20};
const guestPageCap = 200;

export async function upsertProgramGuestHandler(
  request: CallableRequest<unknown>,
  deps: ProgramGuestDeps = defaultDeps
): Promise<ProgramMutationCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<UpsertProgramGuestCallablePayload>(
    request, validateUpsertProgramGuestCallablePayload, normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "upsertProgramGuest");
  const access = await requireProgramAccess({
    db, programId: data.programId, actorUid, now: deps.now(),
  });
  requireProgramDuty(access, "programCoordinator");
  if (data.householdId) {
    await requireHouseholdInProgram(db, data.programId, data.householdId);
  }
  const ref = data.guestId ?
    db.collection("programGuests").doc(data.guestId) :
    db.collection("programGuests").doc();
  let committedRevision = 0;
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const existing = snap.data() as ProgramGuestDocument | undefined;
    if (snap.exists &&
        existing!.programId !== data.programId) {
      throw new HttpsError("not-found", "Guest not found in this program.");
    }
    assertRevision(existing?.revision ?? 0, snap.exists ?
      data.expectedRevision : undefined);
    if (!snap.exists && data.expectedRevision !== undefined) {
      throw new HttpsError(
        "failed-precondition", "Guest does not exist yet.");
    }
    if (existing && existing.organizerId !== access.program.organizerId) {
      throw new HttpsError("aborted", "Guest ownership changed.");
    }
    const now = deps.now();
    const document: ProgramGuestDocument = {
      programId: data.programId,
      organizerId: access.program.organizerId,
      displayName: data.displayName,
      householdId: data.householdId === undefined ?
        existing?.householdId ?? null : data.householdId,
      contactId: existing?.contactId ?? null,
      phoneE164: data.phoneE164 === undefined ?
        existing?.phoneE164 ?? null : data.phoneE164,
      email: data.email === undefined ?
        existing?.email ?? null : data.email,
      externalReference: data.externalReference === undefined ?
        existing?.externalReference ?? null : data.externalReference,
      invitationStatus: existing?.invitationStatus ?? "notInvited",
      rsvpStatus: data.rsvpStatus ?? existing?.rsvpStatus ?? "pending",
      source: existing?.source ?? "manual",
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      revision: nextRevision(existing?.revision, now),
    };
    committedRevision = document.revision;
    tx.set(ref, document);
  });
  return {entityId: ref.id, revision: committedRevision,
    alreadyApplied: false};
}

export async function listProgramGuestsHandler(
  request: CallableRequest<unknown>,
  deps: ProgramGuestDeps = defaultDeps
): Promise<ProgramGuestListCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<ListProgramGuestsCallablePayload>(
    request, validateListProgramGuestsCallablePayload, normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "listProgramGuests");
  const access = await requireProgramAccess({
    db, programId: data.programId, actorUid, now: deps.now(),
  });
  requireProgramDuty(access, "programCoordinator");
  const limit = data.limit ?? guestPageCap;
  let query = db.collection("programGuests")
    .where("programId", "==", data.programId)
    .orderBy("displayName")
    .limit(limit + 1);
  if (data.cursor) {
    const cursorRef = db.collection("programGuests").doc(data.cursor);
    const cursorSnap = await cursorRef.get();
    const cursorDoc = cursorSnap.data() as ProgramGuestDocument | undefined;
    if (!cursorDoc || cursorDoc.programId !== data.programId) {
      throw new HttpsError("invalid-argument", "Unknown page cursor.");
    }
    query = query.startAfter(cursorDoc.displayName);
  }
  const snap = await query.get();
  const page = snap.docs.slice(0, limit);
  const nextCursor = snap.docs.length > limit ?
    page[page.length - 1].id : null;
  const householdIds = [...new Set(page
    .map((doc) =>
      (doc.data() as ProgramGuestDocument).householdId)
    .filter((id): id is string => id !== null))];
  const households = await Promise.all(householdIds.map(async (id) => {
    const snap = await db.collection("programHouseholds").doc(id).get();
    const doc = snap.data() as ProgramHouseholdDocument | undefined;
    if (!doc || doc.programId !== data.programId) return null;
    return {
      householdId: id,
      label: doc.label,
      memberGuestIds: doc.memberGuestIds,
      revision: doc.revision,
    };
  }));
  return {
    programId: data.programId,
    guests: page.map((doc) => {
      const guest = requireDoc<ProgramGuestDocument>(
        doc, "ProgramGuestDocument");
      return {
        guestId: doc.id,
        displayName: guest.displayName,
        householdId: guest.householdId,
        phoneE164: guest.phoneE164,
        email: guest.email,
        externalReference: guest.externalReference,
        invitationStatus: guest.invitationStatus,
        rsvpStatus: guest.rsvpStatus,
        revision: guest.revision,
      };
    }),
    households: households.filter((h) => h !== null),
    nextCursor,
  };
}

export async function upsertProgramHouseholdHandler(
  request: CallableRequest<unknown>,
  deps: ProgramGuestDeps = defaultDeps
): Promise<ProgramMutationCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<UpsertProgramHouseholdCallablePayload>(
    request, validateUpsertProgramHouseholdCallablePayload, normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "upsertProgramHousehold");
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
  const ref = data.householdId ?
    db.collection("programHouseholds").doc(data.householdId) :
    db.collection("programHouseholds").doc();
  let committedRevision = 0;
  await db.runTransaction(async (tx) => {
    // All transaction reads must precede writes.
    const snap = await tx.get(ref);
    const guestSnaps = await Promise.all(data.memberGuestIds.map(
      (guestId) => tx.get(db.collection("programGuests").doc(guestId))));
    const existing = snap.data() as ProgramHouseholdDocument | undefined;
    if (snap.exists && existing!.programId !== data.programId) {
      throw new HttpsError(
        "not-found", "Household not found in this program.");
    }
    assertRevision(existing?.revision ?? 0, snap.exists ?
      data.expectedRevision : undefined);
    const now = deps.now();
    const document: ProgramHouseholdDocument = {
      programId: data.programId,
      organizerId: access.program.organizerId,
      label: data.label,
      primaryContactName: data.primaryContactName,
      primaryPhoneE164: data.primaryPhoneE164 === undefined ?
        existing?.primaryPhoneE164 ?? null : data.primaryPhoneE164,
      primaryEmail: data.primaryEmail === undefined ?
        existing?.primaryEmail ?? null : data.primaryEmail,
      memberGuestIds: data.memberGuestIds,
      deliveryPreference: data.deliveryPreference ??
        existing?.deliveryPreference ?? "none",
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      revision: nextRevision(existing?.revision, now),
    };
    committedRevision = document.revision;
    tx.set(ref, document);
    // Keep guests' householdId in step so projections stay consistent.
    for (const guestSnap of guestSnaps) {
      const guest = guestSnap.data() as ProgramGuestDocument | undefined;
      if (guest && guest.programId === data.programId &&
          guest.householdId !== ref.id) {
        tx.update(guestSnap.ref, {
          householdId: ref.id,
          updatedAt: now,
          revision: nextRevision(guest.revision, now),
        });
      }
    }
  });
  return {entityId: ref.id, revision: committedRevision,
    alreadyApplied: false};
}

export async function listProgramHouseholdsHandler(
  request: CallableRequest<unknown>,
  deps: ProgramGuestDeps = defaultDeps
): Promise<ProgramGuestListCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<ProgramIdCallablePayload>(
    request, validateProgramIdCallablePayload, normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "listProgramHouseholds");
  const access = await requireProgramAccess({
    db, programId: data.programId, actorUid, now: deps.now(),
  });
  requireProgramDuty(access, "programCoordinator");
  const snap = await db.collection("programHouseholds")
    .where("programId", "==", data.programId)
    .limit(500)
    .get();
  return {
    programId: data.programId,
    guests: [],
    households: snap.docs.map((doc) => {
      const household = doc.data() as ProgramHouseholdDocument;
      return {
        householdId: doc.id,
        label: household.label,
        memberGuestIds: household.memberGuestIds,
        revision: household.revision,
      };
    }),
    nextCursor: null,
  };
}

async function requireHouseholdInProgram(
  db: FirebaseFirestore.Firestore,
  programId: string,
  householdId: string
): Promise<void> {
  const snap = await db.collection("programHouseholds").doc(householdId).get();
  const household = snap.data() as ProgramHouseholdDocument | undefined;
  if (!household || household.programId !== programId) {
    throw new HttpsError(
      "invalid-argument", "Household is not in this program.");
  }
}

function normalizePayload(value: unknown): unknown {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return value;
  }
  const input = value as Record<string, unknown>;
  const trimmed = {...input};
  for (const key of ["programId", "guestId", "householdId", "displayName",
    "label", "primaryContactName", "cursor"]) {
    if (typeof trimmed[key] === "string") {
      trimmed[key] = (trimmed[key] as string).trim();
    }
  }
  return trimmed;
}

export const upsertProgramGuest = onCall(
  appCheckCallableOptionsWithLimits(guestCallableLimits),
  (request) => upsertProgramGuestHandler(request)
);
export const listProgramGuests = onCall(
  appCheckCallableOptionsWithLimits(guestCallableLimits),
  (request) => listProgramGuestsHandler(request)
);
export const upsertProgramHousehold = onCall(
  appCheckCallableOptionsWithLimits(guestCallableLimits),
  (request) => upsertProgramHouseholdHandler(request)
);
export const listProgramHouseholds = onCall(
  appCheckCallableOptionsWithLimits(guestCallableLimits),
  (request) => listProgramHouseholdsHandler(request)
);
