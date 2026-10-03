// Lodging capacity uses local calendar nights [arrival, departure), not
// elapsed 24-hour periods. Unknown dates reserve the entire contract window.
// An occupancy is an explicit shared-room identity; labels and households
// never establish sharing. Legacy rows retain their own stable stay identity.
import type {RoomBlockRow, StayRow} from "./programStayAllocation";

export interface NightWindow {
  startsAtMillis?: number | null;
  endsAtMillis?: number | null;
}

export function consumesRoom(stay: Pick<StayRow, "status">): boolean {
  return ["held", "confirmed", "checkedIn"].includes(stay.status);
}

export function occupancyId(stay: StayRow): string {
  return stay.roomOccupancyId ?? stay.stayId;
}

function localDay(millis: number, timezone: string): number {
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone: timezone, year: "numeric", month: "2-digit", day: "2-digit",
  }).formatToParts(millis);
  const value = (type: string) =>
    Number(parts.find((p) => p.type === type)!.value);
  return Date.UTC(value("year"), value("month") - 1, value("day"));
}

export function nightInterval(row: NightWindow, timezone: string):
    readonly [number, number] {
  if (row.startsAtMillis == null || row.endsAtMillis == null) {
    return [-Infinity, Infinity];
  }
  return [localDay(row.startsAtMillis, timezone),
    localDay(row.endsAtMillis, timezone)];
}

export function nightsOverlap(a: NightWindow, b: NightWindow,
  timezone: string): boolean {
  const [aStart, aEnd] = nightInterval(a, timezone);
  const [bStart, bEnd] = nightInterval(b, timezone);
  return aStart < bEnd && bStart < aEnd;
}

/** Exact peak of distinct identities. Multiple roommate rows form a union
 * of nights, including gaps; end events run before starts on turnover day. */
export function peakRoomOccupancy(stays: ReadonlyArray<StayRow>,
  timezone = "UTC", identity: (stay: StayRow) => string = occupancyId): number {
  const events: Array<{at: number; key: string; delta: number}> = [];
  for (const stay of stays.filter(consumesRoom)) {
    let [start, end] = nightInterval(stay, timezone);
    // Old malformed records must never disappear from capacity accounting.
    if (start >= end) [start, end] = [-Infinity, Infinity];
    const key = JSON.stringify([stay.hotelId, identity(stay)]);
    events.push({at: start, key, delta: 1}, {at: end, key, delta: -1});
  }
  events.sort((a, b) => a.at - b.at || a.delta - b.delta);
  const counts = new Map<string, number>();
  let peak = 0;
  for (const event of events) {
    const next = (counts.get(event.key) ?? 0) + event.delta;
    if (next === 0) counts.delete(event.key);
    else counts.set(event.key, next);
    peak = Math.max(peak, counts.size);
  }
  return peak;
}

export type OccupancyViolation =
  "invalidDates" | "outsideBlockDates" | "duplicateGuest" |
  "occupancyLocationConflict" | "roomCapacity" | "blockCapacity";

/** Shared by manual writes and future automatic proposals. Requires a
 * complete scoped snapshot; callers must reject truncated reads. */
export function validateRoomOccupancy(stays: ReadonlyArray<StayRow>,
  blocks: ReadonlyArray<RoomBlockRow>, timezone: string): OccupancyViolation[] {
  const errors = new Set<OccupancyViolation>();
  const live = stays.filter(consumesRoom);
  const byGuest = new Map<string, StayRow[]>();
  const byOccupancy = new Map<string, StayRow[]>();
  for (const stay of live) {
    const [start, end] = nightInterval(stay, timezone);
    if (start >= end) errors.add("invalidDates");
    const guests = byGuest.get(stay.guestId) ?? [];
    if (guests.some((other) => nightsOverlap(stay, other, timezone))) {
      errors.add("duplicateGuest");
    }
    guests.push(stay);
    byGuest.set(stay.guestId, guests);
    const key = occupancyId(stay);
    const members = byOccupancy.get(key) ?? [];
    if (members.some((other) => other.hotelId !== stay.hotelId ||
        other.roomBlockId !== stay.roomBlockId)) {
      errors.add("occupancyLocationConflict");
    }
    members.push(stay);
    byOccupancy.set(key, members);
  }
  for (const block of blocks) {
    const rows = live.filter((s) => s.roomBlockId === block.roomBlockId);
    const [start, end] = nightInterval(block, timezone);
    if (start >= end) errors.add("invalidDates");
    for (const row of rows) {
      const [arrival, departure] = nightInterval(row, timezone);
      // Undated holds consume capacity but do not invent arrival dates.
      if (Number.isFinite(arrival) && (arrival < start || departure > end)) {
        errors.add("outsideBlockDates");
      }
    }
    if (peakRoomOccupancy(rows, timezone) > block.totalRooms) {
      errors.add("blockCapacity");
    }
    for (const members of byOccupancy.values()) {
      if (members[0].roomBlockId === block.roomBlockId &&
          peakRoomOccupancy(members, timezone, (s) => s.guestId) >
            (block.maxOccupantsPerRoom ?? 1)) errors.add("roomCapacity");
    }
  }
  return [...errors];
}
