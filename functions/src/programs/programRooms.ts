/* firestore-index: programRoomBlocks (
  programId:ASCENDING,
  organizerId:ASCENDING,
  hotelId:ASCENDING
) */
/* firestore-index: programStays (
  programId:ASCENDING,
  organizerId:ASCENDING,
  hotelId:ASCENDING
) */
/* firestore-index: programStays (
  programId:ASCENDING,
  organizerId:ASCENDING,
  roomBlockId:ASCENDING
) */
/* firestore-index: programTravelLegs (
  programId:ASCENDING,
  organizerId:ASCENDING,
  destinationHotelId:ASCENDING,
  kind:ASCENDING
) */
/* Hotel desk room board: room blocks, live stays, and unplaced guests (R5/E).
 * Reads follow programTripReads conventions; mutations are transactional with
 * revision fences. Block capacity rollups are recomputed from live stays on
 * every write so a stale counter can never overbook.
 */
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithLimits} from "../shared/callableOptions";
import {validateCallableWithAjv} from "../shared/validation";
import {staffTimestampMillis} from "../shared/eventOperatorAuthority";
import {
  assertRevision,
  dutyAssignments,
  dutyCoversHotel,
  nextRevision,
  programProjectionExpiresAt,
  requireProgramAccess,
  requireProgramDuty,
} from "../shared/programAuthority";
import type {ProgramAccess, ProgramDutyAssignment} from
  "../shared/programAuthority";
import {defaultProgramDataDeps} from "../shared/programDataDeps";
import type {ProgramDataDeps} from "../shared/programDataDeps";
import {
  blockRemainingRooms,
  suggestStayBlock,
  staysConsumingBlock,
  unplacedGuests,
} from "./programStayAllocation";
import type {RoomBlockRow, StayRow} from "./programStayAllocation";
import type {
  ProgramGuestDocument,
  ProgramHotelDocument,
  ProgramRoomBlockDocument,
  ProgramStayDocument,
  ProgramTravelLegDocument,
} from "../shared/generated/firestoreAdminTypes";
import type {GetProgramHotelRoomsCallablePayload} from
  "../shared/generated/getProgramHotelRoomsCallablePayload";
import type {ProgramHotelRoomsCallableResponse} from
  "../shared/generated/programHotelRoomsCallableResponse";
import type {UpsertProgramStayCallablePayload} from
  "../shared/generated/upsertProgramStayCallablePayload";
import type {UpsertProgramRoomBlockCallablePayload} from
  "../shared/generated/upsertProgramRoomBlockCallablePayload";
import type {ProgramMutationCallableResponse} from
  "../shared/generated/programMutationCallableResponse";
import {
  validateGetProgramHotelRoomsCallablePayload,
} from "../shared/generated/validators/getProgramHotelRoomsInput";
import {
  validateUpsertProgramStayCallablePayload,
} from "../shared/generated/validators/upsertProgramStayInput";
import {
  validateUpsertProgramRoomBlockCallablePayload,
} from "../shared/generated/validators/upsertProgramRoomBlockInput";

// Stays per hotel are bounded by the property's room count, so the board
// reads the full set in one shot with a hard safety cap.
const roomsReadCap = 2000;
const roomsCallableLimits = {timeoutSeconds: 60, maxInstances: 20};
const readLimits = {timeoutSeconds: 60, maxInstances: 40};

export async function getProgramHotelRoomsHandler(
  request: CallableRequest<unknown>,
  deps: ProgramDataDeps = defaultProgramDataDeps
): Promise<ProgramHotelRoomsCallableResponse> {
  const actorUid = requireAuth(request);
  const data =
    validateCallableWithAjv<GetProgramHotelRoomsCallablePayload>(
      request, validateGetProgramHotelRoomsCallablePayload,
      normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "getProgramHotelRooms");
  const access = await requireProgramAccess({
    db, programId: data.programId, actorUid, now: deps.now(),
  });
  const hotelDuties = dutyAssignments(access, "hotelDesk");
  const hotel = await requireHotel(
    db, access, data.programId, data.hotelId, hotelDuties);
  const [blocksSnap, staysSnap, legsSnap] = await Promise.all([
    db.collection("programRoomBlocks")
      .where("programId", "==", data.programId)
      .where("organizerId", "==", access.program.organizerId)
      .where("hotelId", "==", data.hotelId)
      .get(),
    db.collection("programStays")
      .where("programId", "==", data.programId)
      .where("organizerId", "==", access.program.organizerId)
      .where("hotelId", "==", data.hotelId)
      .limit(roomsReadCap)
      .get(),
    db.collection("programTravelLegs")
      .where("programId", "==", data.programId)
      .where("organizerId", "==", access.program.organizerId)
      .where("destinationHotelId", "==", data.hotelId)
      .where("kind", "==", "inbound")
      .limit(roomsReadCap)
      .get(),
  ]);
  const blocks: ProgramRoomBlockDocument[] = [];
  for (const doc of blocksSnap.docs) {
    blocks.push(doc.data() as ProgramRoomBlockDocument);
  }
  blocks.sort((a, b) => a.label.localeCompare(b.label));
  const stayDocs = staysSnap.docs.map((doc) =>
    ({id: doc.id, doc: doc.data() as ProgramStayDocument}));
  const stayRows: StayRow[] = stayDocs.map(({id, doc}) => ({
    stayId: id,
    guestId: doc.guestId,
    hotelId: doc.hotelId,
    roomBlockId: doc.roomBlockId,
    roomLabel: doc.roomLabel,
    status: doc.status,
  }));
  const blockRows: RoomBlockRow[] = blocksSnap.docs.map((doc) => {
    const block = doc.data() as ProgramRoomBlockDocument;
    return {
      roomBlockId: doc.id,
      hotelId: block.hotelId,
      label: block.label,
      totalRooms: block.totalRooms,
      assignedCount: block.assignedCount,
      heldForGroupIds: block.heldForGroupIds,
    };
  });
  // Guests expected at this hotel: inbound legs that did not no-show, plus
  // anyone with a stay row here (cancelled stays re-appear for re-placement).
  const routedGuestIds = new Set<string>();
  for (const doc of legsSnap.docs) {
    const leg = doc.data() as ProgramTravelLegDocument;
    if (leg.readiness !== "noShow") routedGuestIds.add(leg.guestId);
  }
  for (const {doc} of stayDocs) routedGuestIds.add(doc.guestId);
  const guestSnaps = await readGuestDocuments(db, [...routedGuestIds]);
  const guests = new Map<string, ProgramGuestDocument>();
  for (const snap of guestSnaps) {
    const guest = snap.data() as ProgramGuestDocument | undefined;
    if (guest && guest.programId === data.programId &&
        guest.organizerId === access.program.organizerId) {
      guests.set(snap.id, guest);
    }
  }
  const guestRows = [...guests.entries()].map(([guestId, guest]) => ({
    guestId, groupIds: guest.groupIds,
  }));
  const unplaced = unplacedGuests(guestRows, stayRows);
  const now = deps.now();
  return {
    programId: data.programId,
    hotelId: data.hotelId,
    hotelName: hotel.name,
    accessExpiresAtMillis: programProjectionExpiresAt(access,
      hotelDuties.filter((duty) => dutyCoversHotel([duty], data.hotelId))),
    generatedAtMillis: now.toMillis(),
    roomBlocks: blocksSnap.docs.map((doc) => {
      const row = blockRows.find((r) => r.roomBlockId === doc.id)!;
      return {
        roomBlockId: doc.id,
        label: row.label,
        roomType: (doc.data() as ProgramRoomBlockDocument).roomType,
        totalRooms: row.totalRooms,
        assignedCount: row.assignedCount,
        remainingRooms: blockRemainingRooms(row, stayRows),
        heldForGroupIds: [...row.heldForGroupIds],
        startsAtMillis: staffTimestampMillis(
          (doc.data() as ProgramRoomBlockDocument).startsAt),
        endsAtMillis: staffTimestampMillis(
          (doc.data() as ProgramRoomBlockDocument).endsAt),
      };
    }).sort((a, b) => a.label.localeCompare(b.label)),
    stays: stayDocs.map(({id, doc}) => ({
      stayId: id,
      guestId: doc.guestId,
      guestDisplayName: guests.get(doc.guestId)?.displayName ?? "Guest",
      roomBlockId: doc.roomBlockId,
      roomLabel: doc.roomLabel,
      status: doc.status,
      startsAtMillis: millisOrNull(doc.startsAt),
      endsAtMillis: millisOrNull(doc.endsAt),
      roomReadyAtMillis: millisOrNull(doc.roomReadyAt),
      hotelArrivedAtMillis: millisOrNull(doc.hotelArrivedAt),
      revision: doc.revision,
    })).sort((a, b) => a.guestDisplayName
      .localeCompare(b.guestDisplayName)),
    unplacedGuests: unplaced.map((row) => ({
      guestId: row.guestId,
      displayName: guests.get(row.guestId)?.displayName ?? "Guest",
      suggestedRoomBlockId: suggestStayBlock(
        row, data.hotelId, blockRows, stayRows)?.roomBlockId ?? null,
    })).sort((a, b) => a.displayName.localeCompare(b.displayName)),
  };
}

export async function upsertProgramStayHandler(
  request: CallableRequest<unknown>,
  deps: ProgramDataDeps = defaultProgramDataDeps
): Promise<ProgramMutationCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<UpsertProgramStayCallablePayload>(
    request, validateUpsertProgramStayCallablePayload, normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "upsertProgramStay");
  const ref = data.stayId ?
    db.collection("programStays").doc(data.stayId) :
    db.collection("programStays").doc();
  let committedRevision = 0;
  await db.runTransaction(async (tx) => {
    const access = await requireProgramAccess({
      db, programId: data.programId, actorUid, now: deps.now(),
      transaction: tx,
    });
    const hotelDuties = access.role === "manager" ? [] :
      dutyAssignments(access, "hotelDesk");
    if (access.role !== "manager" && hotelDuties.length === 0) {
      throw new HttpsError("permission-denied",
        "This account lacks the hotelDesk duty for this program.");
    }
    if (!["draft", "active"].includes(access.program.status)) {
      throw new HttpsError("failed-precondition", "This program is closed.");
    }
    const [staySnap, guestSnap, hotelSnap] = await Promise.all([
      tx.get(ref),
      tx.get(db.collection("programGuests").doc(data.guestId)),
      tx.get(db.collection("programHotels").doc(data.hotelId)),
    ]);
    const guest = guestSnap.data() as ProgramGuestDocument | undefined;
    if (!guest || guest.programId !== data.programId ||
        guest.organizerId !== access.program.organizerId) {
      throw new HttpsError("invalid-argument",
        "Guest is not in this program.");
    }
    const hotel = hotelSnap.data() as ProgramHotelDocument | undefined;
    if (!hotel || hotel.programId !== data.programId ||
        hotel.organizerId !== access.program.organizerId) {
      throw new HttpsError("invalid-argument",
        "Hotel is not in this program.");
    }
    const existing = staySnap.data() as ProgramStayDocument | undefined;
    if ((data.stayId && !existing) ||
        (existing && (existing.programId !== data.programId ||
          existing.organizerId !== access.program.organizerId))) {
      throw new HttpsError("not-found", "Stay not found in this program.");
    }
    assertRevision(existing?.revision ?? 0, staySnap.exists ?
      data.expectedRevision : undefined);
    if (existing && (existing.guestId !== data.guestId ||
        existing.hotelId !== data.hotelId)) {
      throw new HttpsError("failed-precondition",
        "Guest and hotel cannot change. Cancel this stay and create " +
        "a new one.");
    }
    if (access.role !== "manager" &&
        !dutyCoversHotel(hotelDuties, data.hotelId)) {
      throw new HttpsError("permission-denied",
        "This hotel is outside your assigned scope.");
    }
    const roomBlockId = data.roomBlockId === undefined ?
      existing?.roomBlockId ?? null : data.roomBlockId;
    const status = data.status ?? existing?.status ?? "held";
    const affectedBlockIds = new Set<string>();
    if (existing?.roomBlockId) affectedBlockIds.add(existing.roomBlockId);
    if (roomBlockId) affectedBlockIds.add(roomBlockId);
    const blockSnaps = await Promise.all([...affectedBlockIds]
      .map((id) => tx.get(db.collection("programRoomBlocks").doc(id))));
    const blocks = new Map<string, ProgramRoomBlockDocument>();
    for (const snap of blockSnaps) {
      const block = snap.data() as ProgramRoomBlockDocument | undefined;
      if (!block || block.programId !== data.programId ||
          block.organizerId !== access.program.organizerId ||
          block.hotelId !== data.hotelId) {
        throw new HttpsError("invalid-argument",
          "Room block is not at this hotel.");
      }
      blocks.set(snap.id, block);
    }
    // Re-count live stays per affected block inside the transaction so the
    // rollup and the capacity check use the post-write truth.
    const stayLists = await Promise.all([...affectedBlockIds].map((id) =>
      tx.get(db.collection("programStays")
        .where("programId", "==", data.programId)
        .where("organizerId", "==", access.program.organizerId)
        .where("roomBlockId", "==", id))));
    const liveByBlock = new Map<string, StayRow[]>();
    [...affectedBlockIds].forEach((blockId, index) => {
      const rows: StayRow[] = stayLists[index].docs.map((doc) => {
        const stay = doc.data() as ProgramStayDocument;
        return {
          stayId: doc.id,
          guestId: stay.guestId,
          hotelId: stay.hotelId,
          roomBlockId: stay.roomBlockId,
          roomLabel: stay.roomLabel,
          status: stay.status,
        };
      });
      liveByBlock.set(blockId, rows);
    });
    const consuming = status === "held" || status === "confirmed" ||
      status === "checkedIn";
    if (roomBlockId && consuming) {
      const live = liveByBlock.get(roomBlockId)!.filter((row) =>
        row.stayId !== ref.id);
      const block = blocks.get(roomBlockId)!;
      const remaining = Math.max(0, block.totalRooms -
        Math.max(live.filter((r) => consumingStatus(r.status)).length,
          block.assignedCount));
      // A stay already consuming this block keeps its room — exclude it
      // from the capacity rejection.
      if (remaining <= 0 && !(existing?.roomBlockId === roomBlockId &&
          consumingStatus(existing.status))) {
        throw new HttpsError("failed-precondition",
          `"${block.label}" has no rooms left. Choose another block ` +
          "or assign outside the blocks.");
      }
    }
    const now = deps.now();
    const document: ProgramStayDocument = {
      programId: data.programId,
      organizerId: access.program.organizerId,
      guestId: data.guestId,
      hotelId: data.hotelId,
      roomBlockId,
      roomLabel: data.roomLabel === undefined ?
        existing?.roomLabel ?? null : data.roomLabel,
      startsAt: data.startsAtMillis === undefined ?
        existing?.startsAt ?? null :
        data.startsAtMillis === null ? null :
          admin.firestore.Timestamp.fromMillis(data.startsAtMillis),
      endsAt: data.endsAtMillis === undefined ?
        existing?.endsAt ?? null :
        data.endsAtMillis === null ? null :
          admin.firestore.Timestamp.fromMillis(data.endsAtMillis),
      status,
      roomReadyAt: data.markRoomReady ? now : existing?.roomReadyAt ?? null,
      hotelArrivedAt: data.markHotelArrived ? now :
        existing?.hotelArrivedAt ?? null,
      notes: data.notes === undefined ?
        existing?.notes ?? null : data.notes,
      source: existing?.source ??
        (access.role === "manager" ? "planner" : "manual"),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      revision: nextRevision(existing?.revision, now),
    };
    committedRevision = document.revision;
    tx.set(ref, document);
    // Rewrite each affected block's rollup from live stays, including the
    // row just staged (set-then-count keeps the invariant exact).
    for (const [blockId, rows] of liveByBlock) {
      const live = rows.filter((row) => row.stayId !== ref.id);
      if (roomBlockId === blockId && consuming) {
        live.push({stayId: ref.id, guestId: data.guestId,
          hotelId: data.hotelId, roomBlockId, roomLabel: document.roomLabel,
          status});
      }
      const block = blocks.get(blockId)!;
      const next = live.filter((row) => consumingStatus(row.status)).length;
      if (block.assignedCount !== next) {
        tx.update(db.collection("programRoomBlocks").doc(blockId), {
          assignedCount: next, updatedAt: now,
          revision: nextRevision(block.revision, now),
        });
      }
    }
  });
  return {entityId: ref.id, revision: committedRevision,
    alreadyApplied: false};
}

export async function upsertProgramRoomBlockHandler(
  request: CallableRequest<unknown>,
  deps: ProgramDataDeps = defaultProgramDataDeps
): Promise<ProgramMutationCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<UpsertProgramRoomBlockCallablePayload>(
    request, validateUpsertProgramRoomBlockCallablePayload, normalizePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "upsertProgramRoomBlock");
  const ref = data.roomBlockId ?
    db.collection("programRoomBlocks").doc(data.roomBlockId) :
    db.collection("programRoomBlocks").doc();
  let committedRevision = 0;
  await db.runTransaction(async (tx) => {
    const access = await requireProgramAccess({
      db, programId: data.programId, actorUid, now: deps.now(),
      transaction: tx,
    });
    // Inventory definition is coordinator/manager work; hotelDesk consumes it.
    requireProgramDuty(access, "programCoordinator");
    if (!["draft", "active"].includes(access.program.status)) {
      throw new HttpsError("failed-precondition", "This program is closed.");
    }
    const hotelSnap = await tx.get(db.collection("programHotels")
      .doc(data.hotelId));
    const hotel = hotelSnap.data() as ProgramHotelDocument | undefined;
    if (!hotel || hotel.programId !== data.programId ||
        hotel.organizerId !== access.program.organizerId) {
      throw new HttpsError("invalid-argument",
        "Hotel is not in this program.");
    }
    const snap = await tx.get(ref);
    const existing = snap.data() as ProgramRoomBlockDocument | undefined;
    if ((data.roomBlockId && !existing) ||
        (existing && (existing.programId !== data.programId ||
          existing.organizerId !== access.program.organizerId))) {
      throw new HttpsError("not-found",
        "Room block not found in this program.");
    }
    assertRevision(existing?.revision ?? 0, snap.exists ?
      data.expectedRevision : undefined);
    if (existing && existing.hotelId !== data.hotelId) {
      throw new HttpsError("failed-precondition",
        "A room block cannot move hotels. Create a new block instead.");
    }
    const liveSnap = await tx.get(db.collection("programStays")
      .where("programId", "==", data.programId)
      .where("organizerId", "==", access.program.organizerId)
      .where("roomBlockId", "==", ref.id));
    const liveStays: StayRow[] = liveSnap.docs.map((doc) => {
      const stay = doc.data() as ProgramStayDocument;
      return {
        stayId: doc.id,
        guestId: stay.guestId,
        hotelId: stay.hotelId,
        roomBlockId: stay.roomBlockId,
        roomLabel: stay.roomLabel,
        status: stay.status,
      };
    });
    const liveCount = staysConsumingBlock(liveStays, ref.id).length;
    if (data.totalRooms < liveCount) {
      throw new HttpsError("failed-precondition",
        `${liveCount} guests already hold rooms in this block — ` +
        "capacity cannot drop below that.");
    }
    const now = deps.now();
    const document: ProgramRoomBlockDocument = {
      programId: data.programId,
      organizerId: access.program.organizerId,
      hotelId: data.hotelId,
      label: data.label,
      roomType: data.roomType === undefined ?
        existing?.roomType ?? null : data.roomType,
      totalRooms: data.totalRooms,
      assignedCount: liveCount,
      heldForGroupIds: data.heldForGroupIds,
      startsAt: data.startsAtMillis === undefined ?
        existing?.startsAt ?? requireBlockWindow(existing, "startsAt") :
        admin.firestore.Timestamp.fromMillis(data.startsAtMillis),
      endsAt: data.endsAtMillis === undefined ?
        existing?.endsAt ?? requireBlockWindow(existing, "endsAt") :
        admin.firestore.Timestamp.fromMillis(data.endsAtMillis),
      notes: data.notes === undefined ?
        existing?.notes ?? null : data.notes,
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

function millisOrNull(value: FirebaseFirestore.Timestamp | null |
    undefined): number | null {
  return value == null ? null : staffTimestampMillis(value);
}

/** Block windows are required fields — a create must supply both ends. */
function requireBlockWindow(
  existing: ProgramRoomBlockDocument | undefined,
  field: "startsAt" | "endsAt",
): FirebaseFirestore.Timestamp {
  if (!existing) {
    throw new HttpsError("invalid-argument",
      `A room block needs its ${field === "startsAt" ? "start" : "end"} ` +
      "time.");
  }
  return existing[field];
}

function consumingStatus(status: StayRow["status"]): boolean {
  return status === "held" || status === "confirmed" ||
    status === "checkedIn";
}

async function requireHotel(
  db: FirebaseFirestore.Firestore,
  access: ProgramAccess,
  programId: string,
  hotelId: string,
  hotelDuties: ProgramDutyAssignment[],
): Promise<ProgramHotelDocument> {
  if (access.role !== "manager") {
    if (hotelDuties.length === 0) {
      throw new HttpsError("permission-denied",
        "This account lacks the hotelDesk duty for this program.");
    }
    if (!dutyCoversHotel(hotelDuties, hotelId)) {
      throw new HttpsError("permission-denied",
        "This hotel is outside your assigned scope.");
    }
  }
  const snap = await db.collection("programHotels").doc(hotelId).get();
  const hotel = snap.data() as ProgramHotelDocument | undefined;
  if (!hotel || hotel.programId !== programId ||
      hotel.organizerId !== access.program.organizerId) {
    throw new HttpsError("not-found", "Hotel not found in this program.");
  }
  return hotel;
}

/** Deduplicate references and bound concurrent RPCs for large boards. */
async function readGuestDocuments(db: FirebaseFirestore.Firestore,
  ids: string[],
): Promise<FirebaseFirestore.DocumentSnapshot[]> {
  const unique = [...new Set(ids)];
  const snapshots: FirebaseFirestore.DocumentSnapshot[] = [];
  for (let offset = 0; offset < unique.length; offset += 32) {
    snapshots.push(...await Promise.all(unique.slice(offset, offset + 32)
      .map((id) => db.collection("programGuests").doc(id).get())));
  }
  return snapshots;
}

function normalizePayload(value: unknown): unknown {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return value;
  }
  const input = value as Record<string, unknown>;
  const trimmed = {...input};
  for (const key of ["programId", "hotelId", "guestId", "stayId",
    "roomBlockId", "roomLabel", "label", "roomType"]) {
    if (typeof trimmed[key] === "string") {
      trimmed[key] = (trimmed[key] as string).trim();
    }
  }
  return trimmed;
}

export const getProgramHotelRooms = onCall(
  appCheckCallableOptionsWithLimits(readLimits),
  (request) => getProgramHotelRoomsHandler(request)
);
export const upsertProgramStay = onCall(
  appCheckCallableOptionsWithLimits(roomsCallableLimits),
  (request) => upsertProgramStayHandler(request)
);
export const upsertProgramRoomBlock = onCall(
  appCheckCallableOptionsWithLimits(roomsCallableLimits),
  (request) => upsertProgramRoomBlockHandler(request)
);
