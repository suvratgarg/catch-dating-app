import {HttpsError} from "firebase-functions/v2/https";
import type {ProgramDataDeps} from "../shared/programDataDeps";
import type {ProgramAccess} from "../shared/programAuthority";
import {assertRevision, dutyAssignments, nextRevision,
  programProjectionExpiresAt, requireProgramAccess, requireProgramDuty,
  requireProgramMutable} from "../shared/programAuthority";
import type {ProgramLodgingConfigDocument} from
  "../shared/generated/programLodgingConfigDocument";
import {validateProgramLodgingConfigDocument} from
  "../shared/generated/validators/programLodgingConfigDocument";
import {prepareCanonicalLodgingPublication} from "./programLodgingCanonical";
import {prepareLodgingRevisionFence, readCanonicalLodgingRecords} from
  "./programLodgingSource";
import type {CanonicalLodgingRecords} from "./programLodgingSource";
import type {LoadLodgingSource} from "./programLodgingStore";
import {consumesRoom} from "./programRoomOccupancy";
import {assertLodgingSnapshot, inventoryFacts} from
  "./programLodgingValidation";
import type {LodgingSnapshot, PublishedLodgingPlacement} from
  "./programLodgingTypes";

function reject(message: string): never {
  throw new HttpsError("failed-precondition", message);
}
function date(millis: number, timezone: string): string {
  const parts = new Intl.DateTimeFormat("en-US", {timeZone: timezone,
    year: "numeric", month: "2-digit", day: "2-digit"})
    .formatToParts(millis);
  const part = (type: string) => parts.find((p) => p.type === type)!.value;
  return `${part("year")}-${part("month")}-${part("day")}`;
}

/** Canonical guests/groups/blocks own truth. Configuration contains only
 * explicit demand, sharing choices and property/inventory facts. */
export function canonicalLodgingSnapshot(
  config: ProgramLodgingConfigDocument, records: CanonicalLodgingRecords,
  access: ProgramAccess,
): LodgingSnapshot {
  if (!validateProgramLodgingConfigDocument(config) ||
      config.organizerId !== access.program.organizerId) {
    reject("Invalid or foreign lodging configuration.");
  }
  const scope = {programId: config.programId, organizerId: config.organizerId};
  const parents = new Map(config.groupParents.map((g) => [g.id, g.parentIds]));
  const nativeGroups = new Set(records.groups.map((g) => g.id));
  const nativeGuests = new Map(records.guests.map((g) => [g.id, g.data]));
  if (parents.size !== config.groupParents.length ||
      [...parents.keys()].some((id) => !nativeGroups.has(id))) {
    reject("Group nesting must reference unique canonical groups.");
  }
  if (new Set(config.demand.map((d) => d.guestId)).size !==
      config.demand.length) reject("Duplicate lodging demand.");
  const timezone = access.program.timezone;
  const guests = config.demand.map((d) => {
    const guest = nativeGuests.get(d.guestId);
    if (!guest || guest.programId !== config.programId ||
        guest.organizerId !== config.organizerId ||
        d.startsAtMillis >= d.endsAtMillis) {
      reject("Lodging demand must reference a current canonical guest.");
    }
    return {id: d.guestId, beds: d.beds, requiredFeatures: d.requiredFeatures,
      arrival: date(d.startsAtMillis, timezone),
      departure: date(d.endsAtMillis, timezone)};
  });
  const blockIds = new Set(config.inventory.map((u) => u.contractId));
  const hotels = new Map(records.hotels.map((r) => [r.id, r.data]));
  const contracts = records.blocks.filter((b) => blockIds.has(b.id))
    .map(({id, data}) => {
      if (data.programId !== config.programId ||
          data.organizerId !== config.organizerId) {
        reject("Foreign contracted inventory.");
      }
      return {id, hotelId: data.hotelId, nightlyRoomQuota: data.totalRooms,
        arrival: date(data.startsAt.toMillis(), timezone),
        departure: date(data.endsAt.toMillis(), timezone)};
    });
  const snapshot: LodgingSnapshot = {scope,
    revisions: {source: 0, inventory: 0, layout: 0, published: 0}, guests,
    parties: config.parties, groups: records.groups.map((g) => ({id: g.id,
      parentIds: parents.get(g.id) ?? []})),
    memberships: config.demand.flatMap((d) =>
      (nativeGuests.get(d.guestId)!.groupIds ?? []).map((groupId) => ({
        guestId: d.guestId, groupId, included: true,
        authority: "canonical" as const, sourceId: null}))),
    rooms: config.rooms, inventory: config.inventory, contracts, published: []};
  const labels = new Map(config.labels.map((r) =>
    [r.inventoryId, r.roomLabel]));
  if (labels.size !== config.labels.length ||
      labels.size !== config.inventory.length ||
      config.inventory.some((u) => !labels.has(u.id))) {
    reject("Inventory requires one explicit room-label decision per unit.");
  }
  for (const unit of snapshot.inventory) {
    const facts = inventoryFacts(snapshot, unit);
    const hotel = hotels.get(facts.hotelId);
    const block = records.blocks.find((b) => b.id === unit.contractId)?.data;
    if (!block || facts.maxOccupants > (block.maxOccupantsPerRoom ?? 1)) {
      reject("Inventory exceeds verified contracted occupant capacity.");
    }
    if (!hotel?.active || hotel.programId !== scope.programId ||
        hotel.organizerId !== scope.organizerId ||
        (unit.provisional && labels.get(unit.id) !== null)) {
      reject("Inventory must reference an active canonical hotel.");
    }
  }
  const published = new Map<string, PublishedLodgingPlacement>();
  const seenGuests = new Set<string>();
  for (const {data: stay} of records.stays.filter((r) =>
    consumesRoom(r.data))) {
    const party = snapshot.parties.find((p) => p.id === stay.lodgingPartyId);
    const unit = snapshot.inventory.find((u) =>
      u.id === stay.lodgingInventoryId);
    if (!party || !unit || !party.guestIds.includes(stay.guestId) ||
        seenGuests.has(stay.guestId) || unit.contractId !== stay.roomBlockId ||
        inventoryFacts(snapshot, unit).hotelId !== stay.hotelId ||
        labels.get(unit.id) !== stay.roomLabel) {
      reject("Every live stay needs a verified canonical inventory binding.");
    }
    const demand = config.demand.find((d) => d.guestId === stay.guestId)!;
    if (stay.status === "checkedIn" &&
        (stay.startsAt?.toMillis() !== demand.startsAtMillis ||
         stay.endsAt?.toMillis() !== demand.endsAtMillis)) {
      reject("Checked-in guest dates must remain unchanged.");
    }
    seenGuests.add(stay.guestId);
    const previous = published.get(party.id);
    if (previous && previous.inventoryId !== unit.id) {
      reject("A sharing party has conflicting current inventory.");
    }
    const checkedIn = previous?.checkedIn || stay.status === "checkedIn";
    published.set(party.id, {partyId: party.id, inventoryId: unit.id,
      checkedIn, locked: checkedIn});
  }
  snapshot.published = [...published.values()];
  assertLodgingSnapshot(snapshot);
  return snapshot;
}

/** Every Store operation reads native records/config/fence before writing.
 * Own publication changes only the published domain: native guest/block
 * rollup revisions are excluded from the source/inventory projections. */
export function canonicalLodgingSource(deps: ProgramDataDeps):
    LoadLodgingSource {
  return async (tx, access, programId) => {
    const db = deps.firestore();
    const configSnap = await tx.get(db.collection("programLodgingConfigs")
      .doc(programId));
    const config = configSnap.data() as
      ProgramLodgingConfigDocument | undefined;
    if (!config || config.programId !== programId) {
      reject("Set up lodging demand and verified inventory first.");
    }
    const records = await readCanonicalLodgingRecords(tx, db, access,
      programId);
    const snapshot = canonicalLodgingSnapshot(config, records, access);
    const fence = await prepareLodgingRevisionFence(tx, db, snapshot.scope, {
      source: {timezone: access.program.timezone, demand: config.demand,
        parties: config.parties, parents: config.groupParents,
        groups: records.groups,
        memberships: snapshot.memberships},
      inventory: {units: config.inventory, labels: config.labels,
        hotels: records.hotels, blocks: records.blocks.map(({id, data}) => ({
          id, programId: data.programId, organizerId: data.organizerId,
          hotelId: data.hotelId, roomType: data.roomType,
          totalRooms: data.totalRooms, startsAt: data.startsAt,
          endsAt: data.endsAt,
          maxOccupantsPerRoom: data.maxOccupantsPerRoom ?? 1,
          heldForGroupIds: data.heldForGroupIds}))},
      layout: config.rooms,
      published: records.stays,
    });
    snapshot.revisions = fence.revisions;
    const publish = prepareCanonicalLodgingPublication(tx, db, records,
      snapshot, config.demand, Object.fromEntries(config.labels.map((r) =>
        [r.inventoryId, r.roomLabel])), access.program.timezone, deps.now(),
      fence.publish);
    return {snapshot, persistSource: fence.persist, publish};
  };
}

export interface LodgingStayAdoption {
  stayId: string;
  partyId: string;
  inventoryId: string;
  expectedRevision: number;
}
export type LodgingSetup = Omit<ProgramLodgingConfigDocument,
  "programId" | "organizerId" | "revision">;

/** Explicit coordinator verification links existing stays to inventory.
 * It never infers sharing from household/labels and never moves a stay.
 * Existing roommates must already share the same native occupancy identity. */
export async function saveCanonicalLodgingConfig(
  deps: ProgramDataDeps, programId: string, actorUid: string,
  setup: LodgingSetup, expectedRevision: number,
  adoptions: readonly LodgingStayAdoption[] = [],
): Promise<number> {
  if (!Number.isSafeInteger(expectedRevision) || expectedRevision < 0 ||
      adoptions.length > 200 || new Set(adoptions.map((a) => a.stayId)).size !==
        adoptions.length) {
    reject("Invalid configuration revision or adoptions.");
  }
  const db = deps.firestore();
  return db.runTransaction(async (tx) => {
    const access = await requireProgramAccess({db, transaction: tx, programId,
      actorUid, now: deps.now()});
    requireProgramMutable(access.program);
    requireProgramDuty(access, "programCoordinator");
    const ref = db.collection("programLodgingConfigs").doc(programId);
    const previous = (await tx.get(ref)).data() as
      ProgramLodgingConfigDocument | undefined;
    if (previous && (!validateProgramLodgingConfigDocument(previous) ||
        previous.programId !== programId ||
        previous.organizerId !== access.program.organizerId)) {
      reject("Invalid stored lodging configuration.");
    }
    assertRevision(previous?.revision ?? 0, expectedRevision);
    const revision = (previous?.revision ?? 0) + 1;
    if (!Number.isSafeInteger(revision)) reject("Configuration exhausted.");
    const document: ProgramLodgingConfigDocument = {...setup, programId,
      organizerId: access.program.organizerId, revision};
    if (!validateProgramLodgingConfigDocument(document)) {
      reject("Invalid lodging configuration shape.");
    }
    if (Buffer.byteLength(JSON.stringify(document), "utf8") > 900_000) {
      reject("Lodging configuration exceeds the bounded document size.");
    }
    const records = await readCanonicalLodgingRecords(tx, db, access,
      programId);
    const adopted = new Set<string>();
    for (const adoption of adoptions) {
      const row = records.stays.find((r) => r.id === adoption.stayId);
      const party = document.parties.find((p) => p.id === adoption.partyId);
      const unit = document.inventory.find((u) =>
        u.id === adoption.inventoryId);
      const demand = document.demand.find((d) =>
        d.guestId === row?.data.guestId);
      const label = document.labels.find((l) => l.inventoryId === unit?.id);
      if (!row || !consumesRoom(row.data) || !party || !unit || !demand ||
          !party.guestIds.includes(row.data.guestId) ||
          row.data.roomBlockId !== unit.contractId ||
          row.data.roomLabel !== label?.roomLabel ||
          row.data.startsAt?.toMillis() !== demand.startsAtMillis ||
          row.data.endsAt?.toMillis() !== demand.endsAtMillis ||
          !Number.isSafeInteger(adoption.expectedRevision)) {
        reject("Adoption must verify the unchanged current stay and dates.");
      }
      if ((row.data.lodgingPartyId && row.data.lodgingPartyId !== party.id) ||
          (row.data.lodgingInventoryId &&
           row.data.lodgingInventoryId !== unit.id)) {
        reject("Adoption cannot change an existing planner binding.");
      }
      assertRevision(row.data.revision, adoption.expectedRevision);
      row.data = {...row.data, lodgingPartyId: party.id,
        lodgingInventoryId: unit.id, updatedAt: deps.now(),
        revision: nextRevision(row.data.revision, deps.now())};
      adopted.add(row.id);
    }
    // Occupied inventory identities cannot silently be repointed by editing
    // setup. Add another inventory unit and use a reviewed allocation move.
    for (const row of records.stays.filter((r) => consumesRoom(r.data))) {
      const before = previous?.inventory.find((u) =>
        u.id === row.data.lodgingInventoryId);
      const after = document.inventory.find((u) =>
        u.id === row.data.lodgingInventoryId);
      if (before && after && (before.physicalRoomId !== after.physicalRoomId ||
          before.contractId !== after.contractId)) {
        reject("Occupied inventory identity cannot be repointed.");
      }
    }
    canonicalLodgingSnapshot(document, records, access);
    for (const party of document.parties) {
      const occupancies = new Set(records.stays.filter((r) =>
        consumesRoom(r.data) && r.data.lodgingPartyId === party.id)
        .map((r) => r.data.roomOccupancyId ?? r.id));
      if (occupancies.size > 1) {
        reject("Explicitly join native roommates before adopting one party.");
      }
    }
    // All reads have completed; recheck expiry before enqueuing mutations.
    if (access.role !== "manager") {
      const nowMillis = deps.now().toMillis();
      const active = dutyAssignments(access, "programCoordinator")
        .filter((d) => d.expiresAtMillis > nowMillis);
      const expiry = programProjectionExpiresAt(access, active);
      if (expiry !== null && expiry <= nowMillis) {
        throw new HttpsError("permission-denied", "Lodging duty expired.");
      }
    }
    tx.set(ref, document);
    for (const row of records.stays.filter((r) => adopted.has(r.id))) {
      tx.set(db.collection("programStays").doc(row.id), row.data);
    }
    return revision;
  });
}
