import {createHash} from "node:crypto";
import {Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {nextRevision} from "../shared/programAuthority";
import type {ProgramStayDocument} from
  "../shared/generated/firestoreAdminTypes";
import type {CanonicalLodgingRecords} from "./programLodgingSource";
import {assertLodgingProposalCurrent} from "./programLodgingPlanner";
import {inventoryFacts, validateLodgingPlacements} from
  "./programLodgingValidation";
import {consumesRoom, peakRoomOccupancy, validateRoomOccupancy} from
  "./programRoomOccupancy";
import type {StayRow, RoomBlockRow} from "./programStayAllocation";
import type {LodgingProposal, LodgingSnapshot} from "./programLodgingTypes";

/** Explicit event demand timestamps. They must represent the exact property-
 * local dates on the reviewed snapshot; never derive demand from flights. */
export interface CanonicalGuestWindow {
  guestId: string;
  startsAtMillis: number;
  endsAtMillis: number;
}
function fail(message: string): never {
  throw new HttpsError("failed-precondition", message);
}
function localDate(millis: number, timezone: string): string {
  if (!Number.isSafeInteger(millis)) fail("Invalid lodging timestamp.");
  const parts = new Intl.DateTimeFormat("en-US", {timeZone: timezone,
    year: "numeric", month: "2-digit", day: "2-digit"})
    .formatToParts(millis);
  const part = (name: string) => parts.find((p) => p.type === name)!.value;
  return `${part("year")}-${part("month")}-${part("day")}`;
}
function stayRow(id: string, data: ProgramStayDocument): StayRow {
  return {stayId: id, guestId: data.guestId, hotelId: data.hotelId,
    roomBlockId: data.roomBlockId, roomLabel: data.roomLabel,
    roomOccupancyId: data.roomOccupancyId ?? id, status: data.status,
    startsAtMillis: data.startsAt?.toMillis() ?? null,
    endsAtMillis: data.endsAt?.toMillis() ?? null};
}
function immutableKey(values: string[]): string {
  return createHash("sha256").update(JSON.stringify(values)).digest("hex");
}

/** Prepares the canonical writer from the SAME complete transactional reads
 * used for feasibility. No database reads or external calls occur in publish.
 * Unbound live stays fail closed: labels cannot prove physical inventory.
 * The caller must persist the returned exact post-write evidence through the
 * revision fence in the same transaction as the workflow and receipt. */
export function prepareCanonicalLodgingPublication(
  tx: FirebaseFirestore.Transaction, db: FirebaseFirestore.Firestore,
  records: CanonicalLodgingRecords, snapshot: LodgingSnapshot,
  windows: readonly CanonicalGuestWindow[],
  inventoryLabels: Readonly<Record<string, string | null>>,
  timezone: string, now: Timestamp,
  publishEvidence: (stays: CanonicalLodgingRecords["stays"]) => void,
): (proposal: LodgingProposal) => void {
  const {scope} = snapshot;
  const nativeGuests = new Map(records.guests.map((r) => [r.id, r.data]));
  const hotels = new Map(records.hotels.map((r) => [r.id, r.data]));
  const blocks = new Map(records.blocks.map((r) => [r.id, r.data]));
  const dates = new Map(windows.map((r) => [r.guestId, r]));
  if (dates.size !== windows.length || dates.size !== snapshot.guests.length) {
    fail("Each lodging guest needs exactly one explicit dated window.");
  }
  for (const guest of snapshot.guests) {
    const native = nativeGuests.get(guest.id);
    const window = dates.get(guest.id);
    if (!native || native.programId !== scope.programId ||
        native.organizerId !== scope.organizerId || !window ||
        window.startsAtMillis >= window.endsAtMillis ||
        localDate(window.startsAtMillis, timezone) !== guest.arrival ||
        localDate(window.endsAtMillis, timezone) !== guest.departure) {
      fail("Demand does not match a canonical guest and local dates.");
    }
  }
  const bound = new Map<string, CanonicalLodgingRecords["stays"][number]>();
  for (const row of records.stays.filter((r) => consumesRoom(r.data))) {
    const stay = row.data;
    const party = snapshot.parties.find((p) => p.id === stay.lodgingPartyId);
    const unit = snapshot.inventory.find((u) =>
      u.id === stay.lodgingInventoryId);
    if (!party || !unit || !party.guestIds.includes(stay.guestId) ||
        bound.has(stay.guestId) ||
        inventoryFacts(snapshot, unit).hotelId !== stay.hotelId ||
        unit.contractId !== stay.roomBlockId) {
      fail("Every live stay needs a verified canonical inventory binding.");
    }
    bound.set(stay.guestId, row);
  }
  const refs = new Map(snapshot.guests.map((g) => [g.id,
    db.collection("programStays").doc()]));
  const blockRows: RoomBlockRow[] = records.blocks.map(({id, data}) => ({
    roomBlockId: id, hotelId: data.hotelId, label: data.label,
    totalRooms: data.totalRooms, assignedCount: data.assignedCount,
    maxOccupantsPerRoom: data.maxOccupantsPerRoom ?? 1,
    heldForGroupIds: data.heldForGroupIds,
    startsAtMillis: data.startsAt.toMillis(),
    endsAtMillis: data.endsAt.toMillis(),
  }));
  return (proposal) => {
    assertLodgingProposalCurrent(proposal, snapshot.revisions);
    if (proposal.scope.programId !== scope.programId ||
        proposal.scope.organizerId !== scope.organizerId ||
        validateLodgingPlacements(snapshot, proposal.placements, true).length) {
      fail("Publication requires a current complete feasible proposal.");
    }
    const result = new Map(records.stays.map((r) => [r.id, r.data]));
    const writes = new Map<string, ProgramStayDocument>();
    for (const placement of proposal.placements) {
      const party = snapshot.parties.find((p) => p.id === placement.partyId)!;
      const unit = snapshot.inventory.find((u) => u.id ===
        placement.inventoryId)!;
      const facts = inventoryFacts(snapshot, unit);
      const block = blocks.get(unit.contractId);
      const hotel = hotels.get(facts.hotelId);
      if (!hotel?.active || !block || block.hotelId !== facts.hotelId ||
          block.programId !== scope.programId ||
          block.organizerId !== scope.organizerId ||
          hotel.programId !== scope.programId ||
          hotel.organizerId !== scope.organizerId) {
        fail("Inventory must use an active canonical hotel and room block.");
      }
      const label = inventoryLabels[unit.id];
      if (label === undefined || (unit.provisional && label !== null) ||
          (label !== null && (!label.trim() || label.length > 40))) {
        fail("Exact room labels require an explicit verified inventory label.");
      }
      const priorOccupancies = new Set([...bound.values()]
        .filter((r) => r.data.lodgingPartyId === party.id &&
          r.data.lodgingInventoryId === unit.id)
        .map((r) => r.data.roomOccupancyId ?? r.id));
      if (priorOccupancies.size > 1) {
        fail("A room-sharing party has conflicting occupancy identities.");
      }
      const occupancy = [...priorOccupancies][0] ??
        immutableKey([scope.programId, party.id, unit.id]);
      for (const guestId of party.guestIds) {
        const window = dates.get(guestId)!;
        const previous = bound.get(guestId);
        const existing = previous?.data;
        const sameHotel = existing?.hotelId === facts.hotelId;
        if (!existing && records.stays.some((r) =>
          r.data.guestId === guestId && r.data.status === "checkedOut" &&
          r.data.startsAt && r.data.endsAt &&
          r.data.startsAt.toMillis() < window.endsAtMillis &&
          window.startsAtMillis < r.data.endsAt.toMillis())) {
          fail("Checked-out guests need a new non-overlapping demand window.");
        }
        if (existing?.status === "checkedIn") {
          if (existing.lodgingPartyId !== party.id ||
              existing.lodgingInventoryId !== unit.id ||
              existing.roomLabel !== label ||
              existing.startsAt?.toMillis() !== window.startsAtMillis ||
              existing.endsAt?.toMillis() !== window.endsAtMillis) {
            fail("Checked-in stays must remain unchanged.");
          }
          continue;
        }
        if (previous && !sameHotel) {
          const cancelled = {...existing!, status: "cancelled" as const,
            updatedAt: now, revision: nextRevision(existing!.revision, now)};
          result.set(previous.id, cancelled);
          writes.set(previous.id, cancelled);
        }
        const id = previous && sameHotel ? previous.id : refs.get(guestId)!.id;
        const document: ProgramStayDocument = {...scope, guestId,
          hotelId: facts.hotelId, roomBlockId: unit.contractId,
          roomLabel: label, roomOccupancyId: occupancy,
          lodgingPartyId: party.id, lodgingInventoryId: unit.id,
          startsAt: Timestamp.fromMillis(window.startsAtMillis),
          endsAt: Timestamp.fromMillis(window.endsAtMillis),
          status: sameHotel && existing ? existing.status : "confirmed",
          roomReadyAt: sameHotel ? existing?.roomReadyAt ?? null : null,
          hotelArrivedAt: sameHotel ? existing?.hotelArrivedAt ?? null : null,
          notes: existing?.notes ?? null, source: existing?.source ?? "planner",
          createdAt: sameHotel ? existing!.createdAt : now, updatedAt: now,
          revision: nextRevision(sameHotel ? existing?.revision : undefined,
            now)};
        result.set(id, document);
        writes.set(id, document);
      }
    }
    const rows = [...result].map(([id, data]) => stayRow(id, data));
    const violations = validateRoomOccupancy(rows, blockRows, timezone);
    if (violations.length) {
      fail("Canonical publication violates room capacity or dates.");
    }
    // All feasibility checks finish before any write is queued.
    for (const [id, data] of writes) {
      tx.set(db.collection("programStays").doc(id), data);
    }
    for (const guest of snapshot.guests) {
      const native = nativeGuests.get(guest.id)!;
      tx.update(db.collection("programGuests").doc(guest.id), {
        revision: nextRevision(native.revision, now), updatedAt: now});
    }
    for (const [id, block] of blocks) {
      tx.update(db.collection("programRoomBlocks").doc(id), {
        assignedCount: peakRoomOccupancy(rows.filter((r) =>
          r.roomBlockId === id), timezone), updatedAt: now,
        revision: nextRevision(block.revision, now)});
    }
    publishEvidence([...result].map(([id, data]) => ({id, data}))
      .sort((a, b) => a.id < b.id ? -1 : a.id > b.id ? 1 : 0));
  };
}
