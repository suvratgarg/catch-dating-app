// Pure decision layer for per-function invitations inside private
// programs. Field names mirror the programFunctionGuests and
// programFunctions contracts; callers translate these shapes to and
// from Firestore documents.

export type ProgramInvitationStatus =
  "notInvited" | "invited" | "delivered" | "responded";

export type ProgramRsvpStatus =
  "pending" | "attending" | "declined" | "maybe";

export type ProgramFunctionInvitationMode = "allGuests" | "selectedGuests";

export type ProgramFunctionStatus = "scheduled" | "completed" | "cancelled";

export type ProgramFunctionAttendanceStatus =
  "expected" | "checkedIn" | "noShow";

export interface ProgramGuestLike {
  guestId: string;
  invitationStatus: ProgramInvitationStatus;
  // Program-wide rollup maintained by the server from function rows;
  // writers never set it directly.
  rsvpStatus: ProgramRsvpStatus;
}

// One programFunctionGuests row; the document id is the deterministic
// `${functionId}_${guestId}` join key.
export interface FunctionGuestRowLike {
  functionId: string;
  guestId: string;
  invited: boolean;
  rsvpStatus: ProgramRsvpStatus;
  attendanceStatus: ProgramFunctionAttendanceStatus;
  // Attending party size including children; null reads as 1.
  partySize?: number | null;
  // Epoch milliseconds of the current response; null while pending.
  respondedAt?: number | null;
  responseNote?: string | null;
}

export interface FunctionLike {
  functionId: string;
  // Absent on functions written before per-function invitations;
  // reads as allGuests.
  invitationMode?: ProgramFunctionInvitationMode;
  status: ProgramFunctionStatus;
  // Server-maintained rollups; absent or null read as 0.
  expectedCount?: number | null;
  checkedInCount?: number | null;
}

export type FunctionLookup =
  ReadonlyArray<FunctionLike> | ReadonlyMap<string, FunctionLike>;

export interface InvitationDiffPlan {
  // Guest ids needing an invited:true upsert at the join key; covers
  // missing rows and revoked (invited:false) tombstones alike.
  toCreate: string[];
  // Currently invited rows that must flip to invited:false.
  toRevoke: FunctionGuestRowLike[];
  // Currently invited rows already on the desired list; no write needed.
  toKeep: FunctionGuestRowLike[];
}

export function functionsById(
  functions: FunctionLookup,
): ReadonlyMap<string, FunctionLike> {
  const index = new Map<string, FunctionLike>();
  // ReadonlyArray and ReadonlyMap both expose .values(), so either
  // lookup shape normalizes to the same id-keyed map.
  for (const fn of functions.values()) index.set(fn.functionId, fn);
  return index;
}

export function resolveEffectiveInviteSet(
  fn: FunctionLike,
  guests: ReadonlyArray<ProgramGuestLike>,
  rows: ReadonlyArray<FunctionGuestRowLike>,
): Set<string> {
  const invited = new Set<string>();
  // A cancelled function invites nobody, whatever the mode says.
  if (fn.status === "cancelled") return invited;
  const mode = fn.invitationMode ?? "allGuests";
  if (mode === "allGuests") {
    // Only "notInvited" keeps a program guest off the function list.
    for (const guest of guests) {
      if (guest.invitationStatus !== "notInvited") {
        invited.add(guest.guestId);
      }
    }
    return invited;
  }
  // selectedGuests functions invite exactly the rows marked invited.
  for (const row of rows) {
    if (row.functionId === fn.functionId && row.invited === true) {
      invited.add(row.guestId);
    }
  }
  return invited;
}

export function planInvitationDiff(
  fn: FunctionLike,
  currentRows: ReadonlyArray<FunctionGuestRowLike>,
  desiredGuestIds: ReadonlyArray<string>,
  guestIdsInProgram: ReadonlyArray<string>,
): InvitationDiffPlan {
  const plan: InvitationDiffPlan = {toCreate: [], toRevoke: [], toKeep: []};
  // Cancelled functions never grow or shrink invitation lists.
  if (fn.status === "cancelled") return plan;
  const programIds = new Set(guestIdsInProgram);
  const desired = new Set<string>();
  for (const guestId of desiredGuestIds) {
    // Desired ids outside the program are ignored, never planned.
    if (programIds.has(guestId)) desired.add(guestId);
  }
  const invitedRows = currentRows.filter((row) =>
    row.functionId === fn.functionId && row.invited === true);
  const invitedIds = new Set(invitedRows.map((row) => row.guestId));
  plan.toCreate = [...desired]
    .filter((guestId) => !invitedIds.has(guestId))
    .sort();
  const byGuestId = (a: FunctionGuestRowLike, b: FunctionGuestRowLike) =>
    a.guestId < b.guestId ? -1 : a.guestId > b.guestId ? 1 : 0;
  plan.toKeep =
    invitedRows.filter((row) => desired.has(row.guestId)).sort(byGuestId);
  plan.toRevoke =
    invitedRows.filter((row) => !desired.has(row.guestId)).sort(byGuestId);
  return plan;
}
