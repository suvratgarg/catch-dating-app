import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import type {CallableRequest} from "firebase-functions/v2/https";
import {deps, request, now} from "../shared/testing/programFixtures";
import {FakeFirestore, type FakeData} from
  "../shared/testing/programFirestore";
import {journalIdFor} from "./journalPlan";
import {recordProgramDoorJournalHandler} from
  "./recordProgramDoorJournal";

const FUTURE = now.toMillis() + 86_400_000;
const T0 = now.toMillis() + 1_000;

const fn = (id: string, patch: FakeData = {}): FakeData => ({
  programId: "program-1",
  organizerId: "org-1",
  name: id,
  startsAt: admin.firestore.Timestamp.fromMillis(1_800_600_000_000),
  endsAt: admin.firestore.Timestamp.fromMillis(1_800_603_000_000),
  venueName: "Venue",
  venueNotes: null,
  venueLocation: null,
  dressCode: null,
  instructions: null,
  invitationMode: "selectedGuests",
  checkInEnabled: true,
  expectedCount: 0,
  checkedInCount: 0,
  status: "scheduled",
  createdAt: now,
  updatedAt: now,
  revision: 1,
  ...patch,
});

const guest = (id: string, patch: FakeData = {}): FakeData => ({
  programId: "program-1",
  organizerId: "org-1",
  displayName: id,
  householdId: null,
  contactId: null,
  phoneE164: null,
  email: null,
  externalReference: null,
  invitationStatus: "invited",
  rsvpStatus: "attending",
  source: "manual",
  createdAt: now,
  updatedAt: now,
  revision: 1,
  ...patch,
});

const join = (functionId: string, guestId: string,
  patch: FakeData = {}): FakeData => ({
  programId: "program-1",
  organizerId: "org-1",
  functionId,
  guestId,
  invited: true,
  rsvpStatus: "attending",
  attendanceStatus: "expected",
  partySize: null,
  respondedAt: now,
  responseNote: null,
  responseSource: "household",
  recordedByUid: null,
  createdAt: now,
  updatedAt: now,
  revision: 1,
  ...patch,
});

const grant = (uid: string, duties: FakeData[]): FakeData => ({
  organizerId: "org-1",
  programId: "program-1",
  uid,
  displayName: "Staff",
  phoneLastFour: "0000",
  duties,
  status: "active",
  createdBy: "manager-1",
  createdAt: now,
  expiresAt: admin.firestore.Timestamp.fromMillis(FUTURE),
  revokedBy: null,
  revokedAt: null,
  updatedAt: now,
  revision: 1,
});

const duty = (name: string, functionIds?: string[]): FakeData => ({
  duty: name,
  pickupPointIds: [],
  hotelIds: [],
  ...(functionIds === undefined ? {} : {functionIds}),
  expiresAtMillis: FUTURE,
});

const seed = (): Record<string, FakeData> => ({
  "organizers/org-1": {
    hostUserId: "manager-1", ownerUserId: "manager-1",
    hostUserIds: ["manager-1"], hostProfiles: [],
  },
  "organizerPrograms/program-1": {
    organizerId: "org-1", kind: "wedding", title: "Wedding",
    timezone: "Asia/Kolkata", status: "active", capabilities: [],
    transportSettings: {vehicleClasses: []},
    startsAt: admin.firestore.Timestamp.fromMillis(1_800_600_000_000),
    endsAt: admin.firestore.Timestamp.fromMillis(1_800_900_000_000),
    createdBy: "manager-1", createdAt: now, updatedAt: now, revision: 1,
  },
  "programFunctions/fn-sangeet": fn("fn-sangeet"),
  "programFunctions/fn-mehndi": fn("fn-mehndi"),
  "programGuests/g-1": guest("g-1"),
  "programGuests/g-2": guest("g-2"),
  "programGuests/g-3": guest("g-3"),
  "programGuests/w-1": guest("w-1", {invitationStatus: "notInvited"}),
  "programFunctionGuests/fn-sangeet_g-1": join("fn-sangeet", "g-1"),
  "programFunctionGuests/fn-sangeet_g-2": join("fn-sangeet", "g-2"),
  "programFunctionGuests/fn-mehndi_g-2": join("fn-mehndi", "g-2"),
  "programStaffGrants/program-1__door-1":
    grant("door-1", [duty("functionCheckIn")]),
  "programStaffGrants/program-1__door-scoped":
    grant("door-scoped", [duty("functionCheckIn", ["fn-mehndi"])]),
  "programStaffGrants/program-1__lead-1":
    grant("lead-1", [duty("functionLead")]),
  "programStaffGrants/program-1__coord-1":
    grant("coord-1", [duty("programCoordinator")]),
  "programStaffGrants/program-1__staff-other":
    grant("staff-other", [duty("guestRelations")]),
});

const op = (guestId: string, action: string, extra: FakeData = {}) => ({
  guestId,
  action,
  occurredAtMillis: T0,
  ...extra,
});

const record = (db: FakeFirestore, uid: string,
  data: Record<string, unknown>) =>
  recordProgramDoorJournalHandler(request({
    programId: "program-1", functionId: "fn-sangeet",
    operations: [op("g-1", "checkIn")],
    ...data,
  }, uid), deps(db));

const journalKey = (functionId: string, guestId: string, action: string,
  occurredAtMillis: number, actorUid: string) =>
  journalIdFor({
    scope: {kind: "program", id: "program-1"},
    functionId, guestId,
    action: action as "checkIn",
    occurredAtMillis, actorUid,
  });

const denied = (err: unknown) =>
  (err as {code?: string}).code === "permission-denied";
const notFound = (err: unknown) =>
  (err as {code?: string}).code === "not-found";
const precondition = (err: unknown) =>
  (err as {code?: string}).code === "failed-precondition";

test("check-in requires auth and door authority", async () => {
  const db = new FakeFirestore(seed());
  await assert.rejects(
    recordProgramDoorJournalHandler(
      {data: {programId: "program-1", functionId: "fn-sangeet",
        operations: [op("g-1", "checkIn")]},
      rawRequest: {}} as CallableRequest<unknown>, deps(db)),
    (err) => (err as {code?: string}).code === "unauthenticated");
  await assert.rejects(record(db, "staff-other", {}), denied);
  // door-scoped covers fn-mehndi only, not fn-sangeet.
  await assert.rejects(record(db, "door-scoped", {}), denied);
  const ok = await record(db, "door-scoped",
    {functionId: "fn-mehndi",
      operations: [op("g-2", "checkIn")]});
  assert.equal(ok.results[0].outcome, "appended");
  // functionLead and programCoordinator are also door-capable.
  assert.equal((await record(db, "lead-1", {})).results[0].outcome,
    "appended");
  assert.equal((await record(db, "coord-1",
    {operations: [op("g-2", "checkIn")]})).results[0].outcome,
  "appended");
});

test("missing, foreign-program, and cancelled functions reject", async () => {
  const db = new FakeFirestore({...seed(),
    "programFunctions/fn-other": fn("fn-other", {programId: "program-2"}),
    "programFunctions/fn-cancelled": fn("fn-cancelled",
      {status: "cancelled"}),
  });
  await assert.rejects(record(db, "manager-1",
    {functionId: "fn-ghost"}), notFound);
  await assert.rejects(record(db, "manager-1",
    {functionId: "fn-other"}), notFound);
  await assert.rejects(record(db, "manager-1",
    {functionId: "fn-cancelled"}), precondition);
});

test("checkIn appends journal, updates row and function headcount",
  async () => {
    const db = new FakeFirestore(seed());
    const out = await record(db, "door-1",
      {operations: [op("g-1", "checkIn", {occurredAtMillis: T0})]});
    assert.equal(out.entityId, "fn-sangeet");
    assert.equal(out.appendedCount, 1);
    assert.equal(out.results[0].outcome, "appended");
    const jid = journalKey("fn-sangeet", "g-1", "checkIn", T0, "door-1");
    assert.equal(out.results[0].journalId, jid);
    const entry = db.getDoc(`programDoorJournal/${jid}`)!;
    assert.equal(entry.action, "checkIn");
    assert.equal(entry.actorUid, "door-1");
    assert.equal(entry.programId, "program-1");
    assert.equal(entry.occurredAtMillis, T0);
    const rowDoc = db.getDoc("programFunctionGuests/fn-sangeet_g-1")!;
    assert.equal(rowDoc.attendanceStatus, "checkedIn");
    // partySize null reads as one head.
    assert.equal(db.getDoc("programFunctions/fn-sangeet")!.checkedInCount, 1);
  });

test("transition rules reject per operation, not the batch", async () => {
  const db = new FakeFirestore({...seed(),
    "programFunctionGuests/fn-sangeet_g-2":
      join("fn-sangeet", "g-2", {attendanceStatus: "checkedIn",
        partySize: 3}),
    "programFunctions/fn-sangeet": fn("fn-sangeet", {checkedInCount: 3}),
  });
  const out = await record(db, "door-1", {operations: [
    op("g-1", "checkIn", {occurredAtMillis: T0}),
    // Already in: rejected but the batch still commits g-1.
    op("g-2", "checkIn", {occurredAtMillis: T0 + 1}),
    // Unlisted: checkIn is never a walk-in.
    op("g-3", "checkIn", {occurredAtMillis: T0 + 2}),
    // Unlisted undo reads as notCheckedIn.
    op("g-3", "undoCheckIn", {occurredAtMillis: T0 + 3}),
    // Listed expected undo: also notCheckedIn.
    op("g-1", "undoCheckIn", {occurredAtMillis: T0 + 4}),
  ]});
  assert.deepEqual(out.results.map((r) => r.outcome), [
    "appended", "rejected", "rejected", "rejected", "appended"]);
  assert.equal(out.results[1].reason, "alreadyCheckedIn");
  assert.equal(out.results[2].reason, "invalidTransition");
  assert.equal(out.results[3].reason, "notCheckedIn");
  assert.equal(out.results[4].reason, null);
  assert.equal(out.appendedCount, 2);
  assert.equal(out.rejectedCount, 3);
  // g-1 checked in then undone inside one batch; g-2 stayed at 3 heads.
  assert.equal(db.getDoc("programFunctions/fn-sangeet")!.checkedInCount, 3);
  assert.equal(db.getDoc("programFunctionGuests/fn-sangeet_g-1")!
    .attendanceStatus, "expected");
});

test("disabled check-in rejects checkIn but other actions still apply",
  async () => {
    const db = new FakeFirestore({...seed(),
      "programFunctions/fn-sangeet": fn("fn-sangeet",
        {checkInEnabled: false}),
      "programFunctionGuests/fn-sangeet_g-2":
        join("fn-sangeet", "g-2", {attendanceStatus: "checkedIn",
          partySize: 2}),
    });
    db.updateDoc("programFunctions/fn-sangeet", {checkedInCount: 2});
    const out = await record(db, "door-1", {operations: [
      op("g-1", "checkIn"),
      op("g-2", "undoCheckIn", {occurredAtMillis: T0 + 1}),
      op("g-1", "markNoShow", {occurredAtMillis: T0 + 2}),
    ]});
    assert.deepEqual(out.results.map((r) => [r.outcome, r.reason]), [
      ["rejected", "functionCheckInDisabled"],
      ["appended", null],
      ["appended", null],
    ]);
    assert.equal(db.getDoc("programFunctionGuests/fn-sangeet_g-1")!
      .attendanceStatus, "noShow");
    assert.equal(db.getDoc("programFunctions/fn-sangeet")!.checkedInCount, 0);
  });

test("no-show guest may still check in late", async () => {
  const db = new FakeFirestore({...seed(),
    "programFunctionGuests/fn-sangeet_g-1":
      join("fn-sangeet", "g-1", {attendanceStatus: "noShow"}),
  });
  const out = await record(db, "door-1", {});
  assert.equal(out.results[0].outcome, "appended");
  assert.equal(db.getDoc("programFunctionGuests/fn-sangeet_g-1")!
    .attendanceStatus, "checkedIn");
  assert.equal(db.getDoc("programFunctions/fn-sangeet")!.checkedInCount, 1);
});

test("markNoShow rejects checked-in and unlisted guests", async () => {
  const db = new FakeFirestore({...seed(),
    "programFunctionGuests/fn-sangeet_g-2":
      join("fn-sangeet", "g-2", {attendanceStatus: "checkedIn"}),
  });
  const out = await record(db, "door-1", {operations: [
    op("g-1", "markNoShow"),
    op("g-2", "markNoShow", {occurredAtMillis: T0 + 1}),
    op("g-3", "markNoShow", {occurredAtMillis: T0 + 2}),
  ]});
  assert.deepEqual(out.results.map((r) => r.outcome),
    ["appended", "rejected", "rejected"]);
  assert.equal(out.results[1].reason, "invalidTransition");
  assert.equal(out.results[2].reason, "invalidTransition");
  assert.equal(db.getDoc("programFunctionGuests/fn-sangeet_g-1")!
    .attendanceStatus, "noShow");
});

test("walkInCreate needs a programGuests record and sizes heads",
  async () => {
    const db = new FakeFirestore(seed());
    const out = await record(db, "door-1", {operations: [
      // w-1 exists in programGuests but has no join row.
      op("w-1", "walkInCreate", {partySize: 3, note: "Cousins arrived"}),
      // ghost names no programGuests record at all.
      op("ghost", "walkInCreate", {occurredAtMillis: T0 + 1}),
    ]});
    assert.deepEqual(out.results.map((r) => r.outcome),
      ["appended", "rejected"]);
    assert.equal(out.results[1].reason, "invalidTransition");
    const rowDoc = db.getDoc("programFunctionGuests/fn-sangeet_w-1")!;
    assert.equal(rowDoc.invited, false);
    assert.equal(rowDoc.attendanceStatus, "checkedIn");
    assert.equal(rowDoc.partySize, 3);
    assert.equal(db.getDoc("programFunctions/fn-sangeet")!.checkedInCount, 3);
    assert.equal(db.getDoc("programFunctionGuests/fn-sangeet_ghost"),
      undefined);
  });

test("partySizeAdjust rides only on expected or checked-in guests",
  async () => {
    const db = new FakeFirestore({...seed(),
      "programFunctionGuests/fn-sangeet_g-2":
        join("fn-sangeet", "g-2", {attendanceStatus: "checkedIn",
          partySize: 1}),
      "programFunctionGuests/fn-sangeet_g-3":
        join("fn-sangeet", "g-3", {attendanceStatus: "noShow"}),
      "programFunctions/fn-sangeet": fn("fn-sangeet", {checkedInCount: 1}),
    });
    const out = await record(db, "door-1", {operations: [
      // Checked-in resize: heads move 1 -> 4.
      op("g-2", "partySizeAdjust", {partySize: 4}),
      // Expected resize: still zero heads.
      op("g-1", "partySizeAdjust", {partySize: 2,
        occurredAtMillis: T0 + 1}),
      // No-show cannot resize.
      op("g-3", "partySizeAdjust", {partySize: 2,
        occurredAtMillis: T0 + 2}),
      // Missing partySize is malformed.
      op("g-1", "partySizeAdjust", {occurredAtMillis: T0 + 3}),
      // partySize on a checkIn is malformed too.
      op("g-1", "checkIn", {partySize: 2, occurredAtMillis: T0 + 4}),
    ]});
    assert.deepEqual(out.results.map((r) => [r.outcome, r.reason]), [
      ["appended", null],
      ["appended", null],
      ["rejected", "invalidTransition"],
      ["rejected", "invalidTransition"],
      ["rejected", "invalidTransition"],
    ]);
    assert.equal(db.getDoc("programFunctionGuests/fn-sangeet_g-2")!
      .partySize, 4);
    assert.equal(db.getDoc("programFunctionGuests/fn-sangeet_g-1")!
      .partySize, 2);
    assert.equal(db.getDoc("programFunctions/fn-sangeet")!.checkedInCount, 4);
  });

test("replayed batch collapses to duplicates with alreadyApplied",
  async () => {
    const db = new FakeFirestore(seed());
    const operations = [
      op("g-1", "checkIn", {occurredAtMillis: T0}),
      op("g-2", "checkIn", {occurredAtMillis: T0 + 1}),
    ];
    const first = await record(db, "door-1", {operations});
    assert.equal(first.appendedCount, 2);
    const journalSize = [...db.docs.keys()]
      .filter((k) => k.startsWith("programDoorJournal/")).length;
    const second = await record(db, "door-1", {operations});
    assert.equal(second.appendedCount, 0);
    assert.equal(second.duplicateCount, 2);
    assert.equal(second.alreadyApplied, true);
    assert.deepEqual(second.results.map((r) => r.outcome),
      ["duplicate", "duplicate"]);
    assert.equal(second.results[0].journalId,
      journalKey("fn-sangeet", "g-1", "checkIn", T0, "door-1"));
    // No second fact, no double count.
    assert.equal([...db.docs.keys()]
      .filter((k) => k.startsWith("programDoorJournal/")).length,
    journalSize);
    assert.equal(db.getDoc("programFunctions/fn-sangeet")!.checkedInCount, 2);
  });

test("identical ops inside one batch dedupe by journal id", async () => {
  const db = new FakeFirestore(seed());
  const out = await record(db, "door-1", {operations: [
    op("g-1", "checkIn", {occurredAtMillis: T0}),
    op("g-1", "checkIn", {occurredAtMillis: T0}),
  ]});
  assert.deepEqual(out.results.map((r) => r.outcome),
    ["appended", "duplicate"]);
  assert.equal(out.results[1].reason, "duplicateJournalId");
  assert.equal(db.getDoc("programFunctions/fn-sangeet")!.checkedInCount, 1);
});

test("transaction retry re-plans against fresh state", async () => {
  const db = new FakeFirestore({...seed(),
    "programFunctionGuests/fn-sangeet_g-1":
      join("fn-sangeet", "g-1", {attendanceStatus: "checkedIn"}),
    "programFunctions/fn-sangeet": fn("fn-sangeet", {checkedInCount: 2}),
  });
  let flipped = false;
  db.beforeCommit = async () => {
    if (flipped) return;
    flipped = true;
    // Simulate another device checking g-1 out mid-transaction.
    db.updateDoc("programFunctionGuests/fn-sangeet_g-1",
      {attendanceStatus: "expected"});
    db.updateDoc("programFunctions/fn-sangeet", {checkedInCount: 0});
  };
  const out = await record(db, "door-1", {operations: [
    op("g-1", "checkIn", {occurredAtMillis: T0}),
  ]});
  // First attempt saw checkedIn and rejected; the retry re-reads and
  // appends against the fresh expected state.
  assert.equal(out.results[0].outcome, "appended");
  assert.equal(db.getDoc("programFunctionGuests/fn-sangeet_g-1")!
    .attendanceStatus, "checkedIn");
  assert.equal(db.getDoc("programFunctions/fn-sangeet")!.checkedInCount, 1);
});

test("empty-ish responses still validate the payload first", async () => {
  const db = new FakeFirestore(seed());
  await assert.rejects(record(db, "door-1",
    {operations: []}), /operations/);
  await assert.rejects(record(db, "door-1",
    {operations: [op("g-1", "teleport")]}), /action/);
});
