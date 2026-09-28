// Pure room-block / stay helpers for program accommodation (R5). Mirrors
// programSelection.ts conventions: callers translate Firestore documents
// into these row shapes; the module never touches the database.
//
// A programRoomBlock is reserved inventory at one hotel, optionally
// earmarked for guest groups (heldForGroupIds). A programStay binds one
// guest to one hotel — roomBlockId when it consumes block capacity, or
// null for ad-hoc assignments. Guests sharing a room are separate stays
// with the same roomLabel; block capacity counts rooms, not heads.

export type StayStatus =
  "held" | "confirmed" | "checkedIn" | "checkedOut" | "cancelled";

export interface RoomBlockRow {
  roomBlockId: string;
  hotelId: string;
  label: string;
  totalRooms: number;
  // Server-maintained rollup of live stays bound to the block.
  assignedCount: number;
  heldForGroupIds: ReadonlyArray<string>;
}

export interface StayRow {
  stayId: string;
  guestId: string;
  hotelId: string;
  roomBlockId: string | null;
  roomLabel: string | null;
  status: StayStatus;
}

export interface StayGuestRow {
  guestId: string;
  groupIds: ReadonlyArray<string>;
}

// Live = the stay still consumes capacity. Cancelled releases the block;
// checkedOut frees the room but the block's held inventory is unchanged —
// assignment math counts held/confirmed/checkedIn as consuming a room.
const CAPACITY_CONSUMING: ReadonlySet<StayStatus> =
  new Set(["held", "confirmed", "checkedIn"]);

/** Stays still drawing a room from `blockId`. */
export function staysConsumingBlock(
  stays: ReadonlyArray<StayRow>,
  blockId: string,
): StayRow[] {
  return stays.filter((stay) =>
    stay.roomBlockId === blockId && CAPACITY_CONSUMING.has(stay.status));
}

/**
 * Rooms still open in a block. `assignedCount` is the trusted rollup;
 * when live stays disagree (rollup drift), the stricter of the two wins —
 * a block never overbooks because its counter lagged.
 */
export function blockRemainingRooms(
  block: RoomBlockRow,
  stays: ReadonlyArray<StayRow>,
): number {
  const live = staysConsumingBlock(stays, block.roomBlockId).length;
  return Math.max(0, block.totalRooms - Math.max(block.assignedCount, live));
}

/**
 * Guests in `guestIds` with no live stay anywhere. Cancelled and
 * checked-out stays don't hold a guest — they can be re-placed.
 */
export function unplacedGuests(
  guests: ReadonlyArray<StayGuestRow>,
  stays: ReadonlyArray<StayRow>,
): StayGuestRow[] {
  const placed = new Set(
    stays
      .filter((stay) => CAPACITY_CONSUMING.has(stay.status))
      .map((stay) => stay.guestId));
  return guests.filter((guest) => !placed.has(guest.guestId));
}

/**
 * Suggest the block a guest's stay should draw from at `hotelId`.
 *
 * Group-informed order: a block held for one of the guest's groups with
 * rooms left beats general inventory; ties break by label for stable
 * output. Returns null when nothing at the hotel has capacity — the
 * caller decides whether to fall back to an ad-hoc stay.
 */
export function suggestStayBlock(
  guest: StayGuestRow,
  hotelId: string,
  blocks: ReadonlyArray<RoomBlockRow>,
  stays: ReadonlyArray<StayRow>,
): RoomBlockRow | null {
  const guestGroups = new Set(guest.groupIds);
  const candidates = blocks
    .filter((block) => block.hotelId === hotelId)
    .map((block) => ({
      block,
      remaining: blockRemainingRooms(block, stays),
      held: block.heldForGroupIds.some((groupId) => guestGroups.has(groupId)),
    }))
    .filter(({remaining}) => remaining > 0)
    .sort((a, b) =>
      // 1) a block the guest's groups hold always wins; 2) otherwise
      // unheld (general) inventory before blocks earmarked for other
      // groups — an ungrouped guest must not fill the bride block just
      // because its label sorts first; 3) label for stable output.
      Number(b.held) - Number(a.held) ||
      Number(a.block.heldForGroupIds.length > 0) -
        Number(b.block.heldForGroupIds.length > 0) ||
      a.block.label.localeCompare(b.block.label));
  return candidates[0]?.block ?? null;
}
