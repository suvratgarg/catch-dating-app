import {
  functionsById,
  type FunctionGuestRowLike,
  type FunctionLike,
  type FunctionLookup,
  type ProgramRsvpStatus,
} from "./functionInvitation";

export interface FunctionCountPatch {
  expectedCount: number;
  checkedInCount: number;
}

// Precedence for the derived programGuests.rsvpStatus rollup: attending
// wins, then maybe, then pending; all-declined or no rows at all reads
// as declined. The caller controls the row set — pass only the rows
// that should count for this guest.
export function rollupGuestRsvp(
  rows: ReadonlyArray<FunctionGuestRowLike>,
): ProgramRsvpStatus {
  let sawMaybe = false;
  let sawPending = false;
  for (const row of rows) {
    if (row.rsvpStatus === "attending") return "attending";
    if (row.rsvpStatus === "maybe") {
      sawMaybe = true;
    } else if (row.rsvpStatus === "pending") {
      sawPending = true;
    }
  }
  if (sawMaybe) return "maybe";
  if (sawPending) return "pending";
  return "declined";
}

// Caller-facing wrapper: rows for cancelled or missing functions never
// feed the program-level rollup, and neither do revoked invitations —
// an invited:false tombstone is history, not a live response.
export function rollupGuestRsvpForFunctions(
  rows: ReadonlyArray<FunctionGuestRowLike>,
  functions: FunctionLookup,
): ProgramRsvpStatus {
  const index = functionsById(functions);
  return rollupGuestRsvp(rows.filter((row) => {
    if (row.invited !== true) return false;
    const fn = index.get(row.functionId);
    return fn !== undefined && fn.status !== "cancelled";
  }));
}

// Derives the server-maintained expectedCount/checkedInCount fields on a
// function document. expectedCount sums partySize (null reads as 1)
// over attending rows; checkedInCount sums partySize over checked-in
// rows. Returns null when both already match the function's stored
// values so callers skip a no-op write and its revision bump.
export function functionCountPatch(
  fn: FunctionLike,
  rows: ReadonlyArray<FunctionGuestRowLike>,
): FunctionCountPatch | null {
  // Cancelled functions freeze their counters.
  if (fn.status === "cancelled") return null;
  let expectedCount = 0;
  let checkedInCount = 0;
  for (const row of rows) {
    if (row.functionId !== fn.functionId || row.invited !== true) continue;
    const partySize = row.partySize ?? 1;
    if (row.rsvpStatus === "attending") expectedCount += partySize;
    if (row.attendanceStatus === "checkedIn") checkedInCount += partySize;
  }
  // Absent or null counters read as 0.
  if (expectedCount === (fn.expectedCount ?? 0) &&
      checkedInCount === (fn.checkedInCount ?? 0)) {
    return null;
  }
  return {expectedCount, checkedInCount};
}
