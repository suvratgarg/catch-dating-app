import {effectiveMemberships} from "./programLodgingGroups";
import type {LodgingInventory, LodgingIssue, LodgingPlacement,
  LodgingRoomFacts, LodgingSnapshot, LodgingWindow} from
  "./programLodgingTypes";

const DAY = 86_400_000;
export function localNight(date: string): number {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) throw new Error("Invalid local date.");
  const value = Date.parse(date + "T00:00:00Z");
  if (!Number.isFinite(value) ||
      new Date(value).toISOString().slice(0, 10) !== date) {
    throw new Error("Invalid local date.");
  }
  return value / DAY;
}
export function lodgingNights(window: LodgingWindow): number[] {
  const start = localNight(window.arrival);
  const end = localNight(window.departure);
  if (end <= start || end - start > 366) {
    throw new Error("A lodging window must contain 1–366 local nights.");
  }
  return Array.from({length: end - start}, (_, index) => start + index);
}
export function inventoryFacts(snapshot: LodgingSnapshot,
  unit: LodgingInventory): LodgingRoomFacts {
  if (unit.physicalRoomId) {
    const room = snapshot.rooms.find((r) => r.id === unit.physicalRoomId);
    if (!room || unit.provisional) throw new Error("Invalid physical room.");
    return room;
  }
  if (!unit.provisional) {
    throw new Error("Missing provisional inventory facts.");
  }
  return {...unit.provisional, id: "provisional:" + unit.id,
    resourceIds: ["provisional:" + unit.id], position: null};
}

/** Fail closed on incomplete/ambiguous source data before searching. Callers
 * must supply a complete event snapshot, including demand without travel. */
export function assertLodgingSnapshot(snapshot: LodgingSnapshot): void {
  if (!snapshot.scope.organizerId || !snapshot.scope.programId) {
    throw new Error("Missing private event scope.");
  }
  for (const rows of [snapshot.guests, snapshot.parties, snapshot.groups,
    snapshot.rooms, snapshot.inventory, snapshot.contracts]) {
    if (rows.length > 500 ||
        new Set(rows.map((r) => r.id)).size !== rows.length ||
        rows.some((r) => !r.id)) {
      throw new Error("Invalid or oversized roster.");
    }
  }
  if ((["source", "inventory", "layout", "published"] as const).some((key) =>
    !Number.isSafeInteger(snapshot.revisions[key]) ||
      snapshot.revisions[key] < 0)) {
    throw new Error("Invalid revision.");
  }
  const guests = new Set(snapshot.guests.map((guest) => guest.id));
  const covered = new Set<string>();
  const positive = (n: number) => Number.isSafeInteger(n) && n > 0;
  for (const guest of snapshot.guests) {
    lodgingNights(guest);
    if (!positive(guest.beds)) throw new Error("Invalid guest bed demand.");
  }
  for (const party of snapshot.parties) {
    if (!party.confirmed || party.guestIds.length === 0 ||
        !Number.isSafeInteger(party.priority) || party.priority < 0) {
      throw new Error("Sharing parties need confirmed members and priority.");
    }
    for (const id of party.guestIds) {
      if (!guests.has(id) || covered.has(id)) {
        throw new Error("Guests must belong to exactly one sharing party.");
      }
      covered.add(id);
    }
  }
  if (covered.size !== guests.size) {
    throw new Error("Uncovered lodging demand.");
  }
  effectiveMemberships(snapshot.groups, snapshot.memberships);
  if (snapshot.memberships.some((m) => !guests.has(m.guestId))) {
    throw new Error("Unknown membership guest.");
  }
  for (const contract of snapshot.contracts) {
    lodgingNights(contract);
    if (!positive(contract.nightlyRoomQuota)) throw new Error("Invalid quota.");
  }
  for (const unit of snapshot.inventory) {
    const facts = inventoryFacts(snapshot, unit);
    const contract = snapshot.contracts.find((c) => c.id === unit.contractId);
    if (!contract || contract.hotelId !== facts.hotelId ||
        !positive(facts.beds) || !positive(facts.maxOccupants) ||
        !facts.hotelId || !facts.zoneId || facts.resourceIds.length === 0 ||
        new Set(facts.resourceIds).size !== facts.resourceIds.length ||
        facts.resourceIds.some((id) => !id)) {
      throw new Error("Invalid inventory.");
    }
    const contractNights = new Set(lodgingNights(contract));
    if (!unit.availability.length) throw new Error("Missing availability.");
    for (const window of unit.availability) {
      if (lodgingNights(window).some((night) => !contractNights.has(night))) {
        throw new Error("Inventory exceeds contracted dates.");
      }
    }
  }
  const published = new Set<string>();
  for (const row of snapshot.published) {
    if (published.has(row.partyId) ||
        !snapshot.parties.some((p) => p.id === row.partyId) ||
        !snapshot.inventory.some((r) => r.id === row.inventoryId)) {
      throw new Error("Invalid published placement.");
    }
    published.add(row.partyId);
  }
}

/** Independent hard validator for BOTH manual and automatic proposals.
 * Partial proposals may leave demand unplaced but cannot violate a lock. */
export function validateLodgingPlacements(snapshot: LodgingSnapshot,
  placements: readonly LodgingPlacement[], requireComplete = false,
): LodgingIssue[] {
  assertLodgingSnapshot(snapshot);
  return placementIssues(snapshot, placements, requireComplete);
}

/** A search validates its fixed snapshot once, then checks many candidates. */
export function prepareLodgingValidator(snapshot: LodgingSnapshot):
    (placements: readonly LodgingPlacement[]) => LodgingIssue[] {
  assertLodgingSnapshot(snapshot);
  return (placements) => placementIssues(snapshot, placements, false);
}

function placementIssues(snapshot: LodgingSnapshot,
  placements: readonly LodgingPlacement[], requireComplete: boolean,
): LodgingIssue[] {
  const issues: LodgingIssue[] = [];
  const issue = (code: string, partyIds: string[], inventoryIds: string[],
    detail: string) => issues.push({code, partyIds, inventoryIds, detail});
  const seen = new Set<string>();
  const resources = new Map<string, string>();
  const quota = new Map<string, Set<string>>();
  for (const row of placements) {
    const party = snapshot.parties.find((p) => p.id === row.partyId);
    const unit = snapshot.inventory.find((r) => r.id === row.inventoryId);
    if (seen.has(row.partyId)) {
      issue("duplicateParty", [row.partyId], [], "Party assigned twice.");
    }
    seen.add(row.partyId);
    if (!party || !unit) {
      issue("unknownReference", [row.partyId], [row.inventoryId],
        "The party or inventory unit no longer exists.");
      continue;
    }
    const facts = inventoryFacts(snapshot, unit);
    const pin = party.pin;
    if (pin && ((pin.inventoryId && pin.inventoryId !== unit.id) ||
        (pin.hotelId && pin.hotelId !== facts.hotelId) ||
        (pin.zoneId && pin.zoneId !== facts.zoneId))) {
      issue("pin", [party.id], [unit.id], "Placement conflicts with a pin.");
    }
    if (party.requiredRoomType && party.requiredRoomType !== facts.roomType) {
      issue("roomType", [party.id], [unit.id],
        "Required room type unavailable.");
    }
    const available = new Set(unit.availability.flatMap(lodgingNights));
    const nights = new Map<number, {occupants: number; beds: number}>();
    for (const guestId of party.guestIds) {
      const guest = snapshot.guests.find((g) => g.id === guestId)!;
      if (guest.requiredFeatures.some((f) =>
        !facts.verifiedFeatures.includes(f))) {
        issue("accessibility", [party.id], [unit.id],
          "A required functional feature is not verified for this unit.");
      }
      for (const night of lodgingNights(guest)) {
        const count = nights.get(night) ?? {occupants: 0, beds: 0};
        nights.set(night, {occupants: count.occupants + 1,
          beds: count.beds + guest.beds});
      }
    }
    for (const [night, count] of nights) {
      if (!available.has(night)) {
        issue("dates", [party.id], [unit.id],
          "The entire stay must be covered by contracted availability.");
      }
      if (count.occupants > facts.maxOccupants || count.beds > facts.beds) {
        issue("capacity", [party.id], [unit.id],
          "Concurrent occupants or required beds exceed room capacity.");
      }
      // Hotel identity namespaces reusable leaf IDs across properties.
      for (const resourceId of [...facts.resourceIds, "room:" + facts.id]) {
        const key = JSON.stringify([facts.hotelId, resourceId, night]);
        const other = resources.get(key);
        if (other && other !== party.id) {
          issue("roomOverlap", [other, party.id],
            [unit.id], "Room or villa component already occupied that night.");
        }
        resources.set(key, party.id);
      }
      const key = JSON.stringify([unit.contractId, night]);
      const occupied = quota.get(key) ?? new Set<string>();
      occupied.add(unit.id);
      quota.set(key, occupied);
      const contract = snapshot.contracts.find((c) =>
        c.id === unit.contractId)!;
      if (occupied.size > contract.nightlyRoomQuota) {
        issue("quota", [party.id],
          [unit.id], "Contracted nightly room quota exceeded.");
      }
    }
  }
  for (const row of snapshot.published) {
    if ((row.checkedIn || row.locked) && !placements.some((p) =>
      p.partyId === row.partyId && p.inventoryId === row.inventoryId)) {
      issue("locked", [row.partyId], [row.inventoryId],
        "Checked-in and locked placements must be preserved.");
    }
  }
  if (requireComplete) {
    for (const party of snapshot.parties) {
      if (!seen.has(party.id)) {
        issue("unplaced", [party.id], [],
          "This party still needs accommodation.");
      }
    }
  }
  return issues;
}
