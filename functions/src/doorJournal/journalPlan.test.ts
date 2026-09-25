import assert from "node:assert/strict";
import test from "node:test";
import {
  dedupeJournal,
  guestJournalKey,
  journalIdFor,
  planJournalWrite,
  projectJournal,
  type GuestJournalState,
  type JournalAttendanceStatus,
  type JournalEntry,
  type JournalExisting,
  type JournalRequest,
} from "./journalPlan";

const SCOPE = {kind: "program" as const, id: "program-1"};

function request(partial?: Partial<JournalRequest>): JournalRequest {
  return {
    scope: SCOPE,
    functionId: "fn-1",
    guestId: "guest-1",
    actorUid: "staff-1",
    action: "checkIn",
    occurredAtMillis: 1_000,
    deviceId: null,
    partySize: null,
    note: null,
    ...partial,
  };
}

// A journal entry whose journalId defaults to the deterministic id of
// its own fields — pass journalId in partial to pin an explicit one.
function entry(partial?: Partial<JournalEntry>): JournalEntry {
  const {journalId, ...rest} = partial ?? {};
  const req = request(rest);
  return {...req, journalId: journalId ?? journalIdFor(req)};
}

function state(
  attendanceStatus: JournalAttendanceStatus,
  partial?: Partial<GuestJournalState>,
): GuestJournalState {
  return {attendanceStatus, partySize: null, lastJournalId: null,
    ...partial};
}

function existing(partial?: Partial<JournalExisting>): JournalExisting {
  return {
    guest: state("expected"),
    checkInEnabled: true,
    journalIds: new Set<string>(),
    ...partial,
  };
}

test("journalIdFor is deterministic and field-sensitive", () => {
  const req = request();
  const id = journalIdFor(req);
  assert.match(id, /^[0-9a-f]{64}$/);
  // Same input always hashes to the same id — retries collapse.
  assert.equal(journalIdFor({...req}), id);
  // Any hashed field change produces a different id.
  assert.notEqual(
    journalIdFor({...req, occurredAtMillis: 1_001}), id);
  assert.notEqual(journalIdFor({...req, action: "markNoShow"}), id);
  assert.notEqual(journalIdFor({...req, actorUid: "staff-2"}), id);
  assert.notEqual(
    journalIdFor({...req, scope: {kind: "event", id: "event-1"}}), id);
  assert.notEqual(journalIdFor({...req, functionId: "fn-2"}), id);
  assert.notEqual(journalIdFor({...req, guestId: "guest-2"}), id);
});

test("checkIn appends for an expected guest on an enabled function", () => {
  const req = request();
  const plan = planJournalWrite(existing(), req);
  assert.equal(plan.kind, "append");
  if (plan.kind !== "append") return;
  assert.equal(plan.entry.journalId, journalIdFor(req));
  assert.equal(plan.entry.action, "checkIn");
  assert.equal(plan.entry.guestId, "guest-1");
});

test("checkIn appends for a noShow guest — a late arrival clears it", () => {
  const plan = planJournalWrite(
    existing({guest: state("noShow")}), request());
  assert.equal(plan.kind, "append");
});

test("checkIn rejects a guest who is already checked in", () => {
  assert.deepEqual(
    planJournalWrite(existing({guest: state("checkedIn")}), request()),
    {kind: "reject", reason: "alreadyCheckedIn"});
});

test("checkIn rejects when the function disables check-in", () => {
  assert.deepEqual(
    planJournalWrite(existing({checkInEnabled: false}), request()),
    {kind: "reject", reason: "functionCheckInDisabled"});
});

test("checkIn rejects an unlisted guest — that path is walkInCreate", () => {
  assert.deepEqual(
    planJournalWrite(existing({guest: null}), request()),
    {kind: "reject", reason: "invalidTransition"});
});

test("undoCheckIn requires a checked-in guest", () => {
  assert.deepEqual(
    planJournalWrite(existing(), request({action: "undoCheckIn"})),
    {kind: "reject", reason: "notCheckedIn"});
  assert.deepEqual(
    planJournalWrite(existing({guest: state("noShow")}),
      request({action: "undoCheckIn"})),
    {kind: "reject", reason: "notCheckedIn"});
  assert.deepEqual(
    planJournalWrite(existing({guest: null}),
      request({action: "undoCheckIn"})),
    {kind: "reject", reason: "notCheckedIn"});
  const plan = planJournalWrite(
    existing({guest: state("checkedIn")}),
    request({action: "undoCheckIn"}));
  assert.equal(plan.kind, "append");
});

test("markNoShow appends for expected but never for checkedIn", () => {
  assert.equal(
    planJournalWrite(existing(), request({action: "markNoShow"})).kind,
    "append");
  // A checked-in guest cannot be a no-show — undo first.
  assert.deepEqual(
    planJournalWrite(existing({guest: state("checkedIn")}),
      request({action: "markNoShow"})),
    {kind: "reject", reason: "invalidTransition"});
  assert.deepEqual(
    planJournalWrite(existing({guest: null}),
      request({action: "markNoShow"})),
    {kind: "reject", reason: "invalidTransition"});
});

test("walkInCreate always appends, listed or not", () => {
  assert.equal(
    planJournalWrite(existing({guest: null}),
      request({action: "walkInCreate"})).kind,
    "append");
  assert.equal(
    planJournalWrite(existing({guest: state("checkedIn")}),
      request({action: "walkInCreate"})).kind,
    "append");
  // A walk-in may carry its initial party size.
  assert.equal(
    planJournalWrite(existing({guest: null}),
      request({action: "walkInCreate", partySize: 4})).kind,
    "append");
});

test("partySizeAdjust requires expected or checkedIn", () => {
  const adjust = request({action: "partySizeAdjust", partySize: 3});
  assert.equal(planJournalWrite(existing(), adjust).kind, "append");
  assert.equal(
    planJournalWrite(existing({guest: state("checkedIn")}), adjust).kind,
    "append");
  // A no-show has no attending party to resize.
  assert.deepEqual(
    planJournalWrite(existing({guest: state("noShow")}), adjust),
    {kind: "reject", reason: "invalidTransition"});
  assert.deepEqual(
    planJournalWrite(existing({guest: null}), adjust),
    {kind: "reject", reason: "invalidTransition"});
});

test("a retried request collapses to duplicateJournalId", () => {
  const req = request();
  const first = planJournalWrite(existing(), req);
  assert.equal(first.kind, "append");
  if (first.kind !== "append") return;
  // The retry sees the appended id — and the duplicate reason wins
  // even though the guest has since checked in.
  const replay = planJournalWrite(
    existing({
      guest: state("checkedIn", {lastJournalId: first.entry.journalId}),
      journalIds: new Set([first.entry.journalId]),
    }),
    req);
  assert.deepEqual(replay, {kind: "reject", reason: "duplicateJournalId"});
});

test("programmer-level bad inputs throw RangeError", () => {
  assert.throws(
    () => journalIdFor(request({occurredAtMillis: 0})), RangeError);
  assert.throws(
    () => journalIdFor(request({guestId: ""})), RangeError);
  assert.throws(
    () => planJournalWrite(existing(),
      request({action: "partySizeAdjust"})), RangeError);
  assert.throws(
    () => planJournalWrite(existing(), request({partySize: 2})),
    RangeError);
  assert.throws(
    () => planJournalWrite(existing(),
      request({partySize: 99, action: "walkInCreate"})), RangeError);
});

test("undo after check-in restores expected in the fold", () => {
  const check = entry({occurredAtMillis: 2_000});
  const undo = entry({action: "undoCheckIn", occurredAtMillis: 3_000});
  // Out-of-order input folds identically — the later undo wins.
  const projection = projectJournal([undo, check]);
  assert.deepEqual(
    projection.guests.get(guestJournalKey("fn-1", "guest-1")),
    {
      attendanceStatus: "expected",
      partySize: null,
      lastJournalId: undo.journalId,
    });
  assert.equal(
    projection.functions.get("fn-1")?.checkedInCount, 0);
});

test("projectJournal is order-insensitive and counts walk-in heads", () => {
  const entries = [
    entry({guestId: "g1", occurredAtMillis: 100}),
    entry({guestId: "g1", action: "undoCheckIn", occurredAtMillis: 200}),
    entry({guestId: "g2", action: "walkInCreate", partySize: 4,
      occurredAtMillis: 50}),
  ];
  const forward = projectJournal(entries);
  const shuffled = projectJournal([...entries].reverse());
  const g1 = guestJournalKey("fn-1", "g1");
  assert.deepEqual(
    shuffled.guests.get(g1), forward.guests.get(g1));
  assert.deepEqual(
    [...shuffled.functions.entries()], [...forward.functions.entries()]);
  // g1 ends expected after the undo; g2 is a checked-in walk-in of 4.
  assert.equal(forward.guests.get(g1)?.attendanceStatus, "expected");
  assert.equal(
    forward.guests.get(guestJournalKey("fn-1", "g2"))?.attendanceStatus,
    "checkedIn");
  assert.equal(forward.functions.get("fn-1")?.checkedInCount, 4);
  assert.equal(forward.functions.get("fn-1")?.walkInCount, 1);
});

test("partySizeAdjust changes the party size used for head counts", () => {
  const totals = projectJournal([
    entry({guestId: "g1", occurredAtMillis: 1}),
    entry({guestId: "g1", action: "partySizeAdjust", partySize: 3,
      occurredAtMillis: 2}),
    entry({guestId: "g2", occurredAtMillis: 3}),
    entry({guestId: "g3", action: "markNoShow", occurredAtMillis: 4}),
  ]).functions.get("fn-1");
  // checkedIn: g1 (3 heads) + g2 (null partySize reads as 1) = 4.
  // noShow: g3 reads as 1.
  assert.deepEqual(totals,
    {checkedInCount: 4, noShowCount: 1, walkInCount: 0});
});

test("a partySizeAdjust while expected carries into the later check-in", () => {
  const projection = projectJournal([
    entry({guestId: "g1", action: "partySizeAdjust", partySize: 5,
      occurredAtMillis: 1}),
    entry({guestId: "g1", occurredAtMillis: 2}),
  ]);
  assert.equal(projection.functions.get("fn-1")?.checkedInCount, 5);
  assert.equal(
    projection.guests.get(guestJournalKey("fn-1", "g1"))?.partySize, 5);
});

test("lastJournalId tracks the latest entry by time, not input order", () => {
  const first = entry({occurredAtMillis: 1});
  const second = entry({action: "partySizeAdjust", partySize: 2,
    occurredAtMillis: 2});
  const projection = projectJournal([second, first]);
  assert.equal(
    projection.guests.get(guestJournalKey("fn-1", "guest-1"))
      ?.lastJournalId,
    second.journalId);
});

test("totals bucket per function; program-level entries roll into none", () => {
  const projection = projectJournal([
    entry({functionId: "fn-1", occurredAtMillis: 1}),
    entry({functionId: "fn-2", occurredAtMillis: 2}),
    entry({functionId: null, occurredAtMillis: 3}),
  ]);
  assert.equal(projection.functions.get("fn-1")?.checkedInCount, 1);
  assert.equal(projection.functions.get("fn-2")?.checkedInCount, 1);
  assert.equal(projection.functions.size, 2);
  // The program-level entry still produces guest state.
  assert.equal(
    projection.guests.get(guestJournalKey(null, "guest-1"))
      ?.attendanceStatus,
    "checkedIn");
});

test("projectJournal ignores replayed journalIds", () => {
  const a = entry({occurredAtMillis: 1});
  const projection = projectJournal([a, {...a}]);
  assert.equal(projection.functions.get("fn-1")?.checkedInCount, 1);
});

test("projectJournal refuses mixed scopes", () => {
  assert.throws(
    () => projectJournal([
      entry(), entry({scope: {kind: "event", id: "event-9"}}),
    ]),
    RangeError);
});

test("dedupeJournal collapses duplicate ids, first occurrence wins", () => {
  const a = entry({occurredAtMillis: 1});
  const b = entry({occurredAtMillis: 2});
  // Same journalId, different payload — a retry with a mutated note.
  const retried = {...a, note: "retry"};
  const result = dedupeJournal([a, b, retried, a]);
  assert.equal(result.dropped, 2);
  assert.equal(result.entries.length, 2);
  assert.equal(result.entries[0].note, null);
  assert.equal(result.entries[1].journalId, b.journalId);
});
