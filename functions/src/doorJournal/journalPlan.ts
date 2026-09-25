// Server-side decision logic for the durable door check-in journal.
// The journal is the append-only record that door staff (function
// check-in) and dispatch ops write to; clients never own attendance
// truth, they only submit requests the server plans against this
// module. Field names mirror the W0 program contracts —
// programFunctionGuests.attendanceStatus ("expected"|"checkedIn"|
// "noShow"), programFunctionGuests.partySize (1..20, null reads as 1),
// and programFunctions.checkInEnabled / expectedCount / checkedInCount
// — without importing generated contract code.
import {createHash} from "node:crypto";

// Document ids in this codebase are bounded well under this ceiling.
const MAX_ID_LENGTH = 180;
// programFunctionGuests.partySize contract bound; null reads as 1.
const MAX_PARTY_SIZE = 20;
// Journal notes mirror the 500-char bound on guest response notes.
const MAX_NOTE_LENGTH = 500;

export type JournalScopeKind = "event" | "program";

export interface JournalScope {
  kind: JournalScopeKind;
  id: string;
}

export type JournalAction =
  "checkIn" | "undoCheckIn" | "markNoShow" | "walkInCreate" |
  "partySizeAdjust";

// Mirrors programFunctionGuests.attendanceStatus.
export type JournalAttendanceStatus = "expected" | "checkedIn" | "noShow";

export interface JournalEntry {
  // Deterministic idempotency key from journalIdFor; retries collapse.
  journalId: string;
  scope: JournalScope;
  // Null for program-level entries that name no single function.
  functionId: string | null;
  guestId: string;
  actorUid: string;
  action: JournalAction;
  occurredAtMillis: number;
  deviceId: string | null;
  // New attending party size for partySizeAdjust, initial size for
  // walkInCreate; null on every other action. Bounds mirror the
  // contract (integer 1..20).
  partySize: number | null;
  note: string | null;
}

// A requested journal append. journalId is always derived, never
// supplied, so callers cannot mint conflicting idempotency keys.
export type JournalRequest = Omit<JournalEntry, "journalId">;

// The fields journalIdFor hashes into the idempotency key.
export type JournalIdInput = Pick<JournalRequest,
  "scope" | "functionId" | "guestId" | "action" | "occurredAtMillis" |
  "actorUid">;

// Projected per-guest state produced by projectJournal and consumed by
// planJournalWrite. Keyed by guestJournalKey(functionId, guestId).
export interface GuestJournalState {
  attendanceStatus: JournalAttendanceStatus;
  // Null reads as 1, mirroring the contract.
  partySize: number | null;
  // Journal id of the most recent entry that touched this guest; null
  // on a caller-synthesized state for a listed guest with no entries.
  lastJournalId: string | null;
}

// The current state planJournalWrite decides against.
export interface JournalExisting {
  // Projected state for the target (functionId, guestId), or null when
  // the guest is not on the list and has no entries — only
  // walkInCreate may write an unlisted guest. Callers synthesize
  // {attendanceStatus: "expected", partySize: <doc>, lastJournalId:
  // null} for listed guests that have no journal entries yet.
  guest: GuestJournalState | null;
  // programFunctions.checkInEnabled for the target function.
  checkInEnabled: boolean;
  // Journal ids already appended in this scope; a request that hashes
  // to a known id is a retry and rejects as a duplicate.
  journalIds: ReadonlySet<string>;
}

export type JournalRejectReason =
  "alreadyCheckedIn" | "notCheckedIn" | "functionCheckInDisabled" |
  "duplicateJournalId" | "invalidTransition";

export type JournalPlan = {
  kind: "append";
  entry: JournalEntry;
} | {
  kind: "reject";
  reason: JournalRejectReason;
};

export interface FunctionJournalTotals {
  // Head counts (partySize summed, null reads as 1) matching the
  // expectedCount / checkedInCount rollup semantics.
  checkedInCount: number;
  noShowCount: number;
  // Guests whose journal holds a walkInCreate — a count of walk-in
  // guest records, not heads; their heads already ride inside the
  // attendance counts. Origin survives a later undo or no-show.
  walkInCount: number;
}

export interface JournalProjection {
  // Keyed by guestJournalKey(functionId, guestId).
  guests: ReadonlyMap<string, GuestJournalState>;
  // Keyed by functionId. Program-level (functionId = null) entries
  // update guest state but roll into no function totals.
  functions: ReadonlyMap<string, FunctionJournalTotals>;
}

export interface DedupeJournalResult {
  entries: JournalEntry[];
  dropped: number;
}

// Internal fold record: the public guest state plus the walk-in origin
// flag that feeds FunctionJournalTotals.walkInCount.
interface GuestFold {
  functionId: string | null;
  state: GuestJournalState;
  walkInOrigin: boolean;
}

// Deterministic journal id: a fixed-order serialization of the fields
// that identify one logical door action, hashed with sha256. Two
// requests that serialize identically are the same logical action, so
// device retries collapse to one appended entry.
export function journalIdFor(input: JournalIdInput): string {
  requireScope(input.scope);
  requireNullableId(input.functionId, "functionId");
  requireId(input.guestId, "guestId");
  requireAction(input.action);
  requireMillis(input.occurredAtMillis, "occurredAtMillis");
  requireId(input.actorUid, "actorUid");
  const serialized = JSON.stringify([
    input.scope.kind,
    input.scope.id,
    input.functionId,
    input.guestId,
    input.action,
    input.occurredAtMillis,
    input.actorUid,
  ]);
  return createHash("sha256").update(serialized, "utf8").digest("hex");
}

// Composite map key for one guest at one function (or at program level
// when functionId is null). JSON keeps the pair unambiguous for any id
// characters.
export function guestJournalKey(
  functionId: string | null,
  guestId: string,
): string {
  return JSON.stringify([functionId, guestId]);
}

// Decide whether a requested door action may append to the journal.
// Pure: the same projected state and request always yield the same
// plan, and a replayed request always yields duplicateJournalId.
export function planJournalWrite(
  existing: JournalExisting,
  requested: JournalRequest,
): JournalPlan {
  requireExisting(existing);
  requireRequest(requested);
  const journalId = journalIdFor(requested);
  // The idempotency key dominates every other rule: a retried request
  // collapses to a reject instead of a second entry, no matter how the
  // projected state has moved since the first attempt.
  if (existing.journalIds.has(journalId)) {
    return {kind: "reject", reason: "duplicateJournalId"};
  }
  const status = existing.guest?.attendanceStatus ?? null;
  const reason = rejectionFor(requested.action, status, existing);
  if (reason !== null) return {kind: "reject", reason};
  return {kind: "append", entry: {...requested, journalId}};
}

// Fold one scope's journal into projected state. Order-insensitive:
// entries sort by occurredAtMillis then journalId, duplicate
// journalIds collapse (first in sorted order wins), and the function
// totals derive from final guest states so input order can never
// change the result. All entries must share one scope.
export function projectJournal(
  entries: ReadonlyArray<JournalEntry>,
): JournalProjection {
  let scope: JournalScope | null = null;
  for (const entry of entries) {
    requireEntry(entry);
    if (scope === null) {
      scope = entry.scope;
    } else if (scope.kind !== entry.scope.kind ||
        scope.id !== entry.scope.id) {
      throw new RangeError(
        "projectJournal entries must share one scope.");
    }
  }
  const sorted = dedupeJournal(sortEntries(entries)).entries;
  const folds = new Map<string, GuestFold>();
  for (const entry of sorted) {
    const key = guestJournalKey(entry.functionId, entry.guestId);
    const fold = folds.get(key) ?? {
      functionId: entry.functionId,
      state: {
        attendanceStatus: "expected" as JournalAttendanceStatus,
        partySize: null,
        lastJournalId: null,
      },
      walkInOrigin: false,
    };
    applyEntry(fold, entry);
    folds.set(key, fold);
  }
  const guests = new Map<string, GuestJournalState>();
  const functions = new Map<string, FunctionJournalTotals>();
  for (const [key, fold] of folds) {
    guests.set(key, fold.state);
    if (fold.functionId === null) continue;
    const totals = functions.get(fold.functionId) ?? {
      checkedInCount: 0,
      noShowCount: 0,
      walkInCount: 0,
    };
    // Head counts sum party sizes; null reads as 1, matching the
    // contract rollups.
    const heads = fold.state.partySize ?? 1;
    if (fold.state.attendanceStatus === "checkedIn") {
      totals.checkedInCount += heads;
    } else if (fold.state.attendanceStatus === "noShow") {
      totals.noShowCount += heads;
    }
    if (fold.walkInOrigin) totals.walkInCount += 1;
    functions.set(fold.functionId, totals);
  }
  return {guests, functions};
}

// Collapse duplicate journalIds; the first occurrence in the given
// order wins and the rest drop. A replayed batch reduces to the
// entries it actually adds.
export function dedupeJournal(
  entries: ReadonlyArray<JournalEntry>,
): DedupeJournalResult {
  const seen = new Set<string>();
  const kept: JournalEntry[] = [];
  for (const entry of entries) {
    requireId(entry.journalId, "journalId");
    if (seen.has(entry.journalId)) continue;
    seen.add(entry.journalId);
    kept.push(entry);
  }
  return {entries: kept, dropped: entries.length - kept.length};
}

// The per-action transition rules. status is the projected
// attendanceStatus, or null for a guest that is neither listed nor
// journaled.
function rejectionFor(
  action: JournalAction,
  status: JournalAttendanceStatus | null,
  existing: JournalExisting,
): JournalRejectReason | null {
  switch (action) {
  case "checkIn":
    // The function-level kill switch dominates guest state.
    if (!existing.checkInEnabled) return "functionCheckInDisabled";
    // checkIn serves listed guests; an unlisted arrival is a
    // walkInCreate, never a bare checkIn.
    if (status === null) return "invalidTransition";
    if (status === "checkedIn") return "alreadyCheckedIn";
    // expected and noShow may both check in — a late arrival clears
    // the no-show mark.
    return null;
  case "undoCheckIn":
    return status === "checkedIn" ? null : "notCheckedIn";
  case "markNoShow":
    // A checked-in guest cannot be a no-show — the edge itself is
    // invalid and the check-in must be undone first. An unlisted
    // guest has no attendance to mark.
    if (status === null || status === "checkedIn") {
      return "invalidTransition";
    }
    return null;
  case "walkInCreate":
    // Always appends — even a re-creation is a fact worth keeping.
    return null;
  case "partySizeAdjust":
    // Only a guest who is expected or already in may resize.
    if (status !== "expected" && status !== "checkedIn") {
      return "invalidTransition";
    }
    return null;
  }
}

function applyEntry(fold: GuestFold, entry: JournalEntry): void {
  switch (entry.action) {
  case "checkIn":
  case "walkInCreate":
    fold.state.attendanceStatus = "checkedIn";
    break;
  case "undoCheckIn":
    fold.state.attendanceStatus = "expected";
    break;
  case "markNoShow":
    fold.state.attendanceStatus = "noShow";
    break;
  case "partySizeAdjust":
    break;
  }
  if (entry.action === "walkInCreate") fold.walkInOrigin = true;
  // Only partySizeAdjust and walkInCreate may carry partySize (enforced
  // by requireEntry), so a non-null value always applies.
  if (entry.partySize !== null) fold.state.partySize = entry.partySize;
  fold.state.lastJournalId = entry.journalId;
}

function sortEntries(
  entries: ReadonlyArray<JournalEntry>,
): JournalEntry[] {
  return [...entries].sort((a, b) =>
    a.occurredAtMillis - b.occurredAtMillis ||
    (a.journalId < b.journalId ? -1 :
      a.journalId > b.journalId ? 1 : 0));
}

function requireExisting(existing: JournalExisting): void {
  if (typeof existing.checkInEnabled !== "boolean") {
    throw new RangeError("checkInEnabled must be a boolean.");
  }
  if (typeof existing.journalIds?.has !== "function") {
    throw new RangeError(
      "journalIds must be a ReadonlySet of journal ids.");
  }
  const guest = existing.guest ?? null;
  if (guest !== null) {
    requireAttendanceStatus(guest.attendanceStatus);
    requireNullablePartySize(guest.partySize);
    if (guest.lastJournalId !== null) {
      requireId(guest.lastJournalId, "lastJournalId");
    }
  }
}

function requireEntry(entry: JournalEntry): void {
  requireId(entry.journalId, "journalId");
  requireRequest(entry);
}

function requireRequest(requested: JournalRequest): void {
  requireScope(requested.scope);
  requireNullableId(requested.functionId, "functionId");
  requireId(requested.guestId, "guestId");
  requireId(requested.actorUid, "actorUid");
  requireAction(requested.action);
  requireMillis(requested.occurredAtMillis, "occurredAtMillis");
  requireNullableId(requested.deviceId, "deviceId");
  requireNullableNote(requested.note);
  if (requested.action === "partySizeAdjust") {
    requirePartySize(requested.partySize);
  } else if (requested.action === "walkInCreate") {
    requireNullablePartySize(requested.partySize);
  } else if (requested.partySize !== null) {
    throw new RangeError(
      "partySize rides only on partySizeAdjust and walkInCreate entries.");
  }
}

function requireScope(scope: JournalScope): void {
  if (scope.kind !== "event" && scope.kind !== "program") {
    throw new RangeError("scope.kind must be \"event\" or \"program\".");
  }
  requireId(scope.id, "scope.id");
}

function requireAction(action: JournalAction): void {
  switch (action) {
  case "checkIn":
  case "undoCheckIn":
  case "markNoShow":
  case "walkInCreate":
  case "partySizeAdjust":
    return;
  }
  throw new RangeError(`Unknown journal action: ${String(action)}.`);
}

function requireAttendanceStatus(
  status: JournalAttendanceStatus,
): void {
  if (status !== "expected" && status !== "checkedIn" &&
      status !== "noShow") {
    throw new RangeError(
      "attendanceStatus must be \"expected\", \"checkedIn\" or \"noShow\".");
  }
}

function requireId(value: string, label: string): void {
  if (typeof value !== "string" ||
      value.length < 1 || value.length > MAX_ID_LENGTH) {
    throw new RangeError(
      `${label} must be a string of 1..${MAX_ID_LENGTH} characters.`);
  }
}

function requireNullableId(value: string | null, label: string): void {
  if (value !== null) requireId(value, label);
}

function requireMillis(value: number, label: string): void {
  if (!Number.isSafeInteger(value) || value < 1) {
    throw new RangeError(
      `${label} must be a positive safe integer of milliseconds.`);
  }
}

function requireNullablePartySize(value: number | null): void {
  if (value !== null) requirePartySizeValue(value);
}

function requirePartySize(value: number | null): void {
  if (value === null) {
    throw new RangeError(
      "partySizeAdjust entries must carry a partySize.");
  }
  requirePartySizeValue(value);
}

function requirePartySizeValue(value: number): void {
  if (!Number.isSafeInteger(value) ||
      value < 1 || value > MAX_PARTY_SIZE) {
    throw new RangeError(
      `partySize must be an integer of 1..${MAX_PARTY_SIZE}.`);
  }
}

function requireNullableNote(note: string | null): void {
  if (note !== null &&
      (typeof note !== "string" || note.length > MAX_NOTE_LENGTH)) {
    throw new RangeError(
      `note must be null or a string of 0..${MAX_NOTE_LENGTH} characters.`);
  }
}
