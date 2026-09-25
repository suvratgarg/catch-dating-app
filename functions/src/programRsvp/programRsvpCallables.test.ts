import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {deps, request, now} from "../shared/testing/programFixtures";
import {FakeFirestore, type FakeData} from
  "../shared/testing/programFirestore";
import {
  applyProgramFunctionInvitationsHandler,
  recordProgramFunctionRsvpHandler,
} from "./programRsvpCallables";

const FUTURE = now.toMillis() + 86_400_000;

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
  invitationMode: "allGuests",
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
  rsvpStatus: "pending",
  source: "manual",
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
  "programGuests/g-3": guest("g-3", {invitationStatus: "notInvited"}),
  "programStaffGrants/program-1__staff-1":
    grant("staff-1", [duty("guestRelations")]),
  "programStaffGrants/program-1__staff-2":
    grant("staff-2", [duty("functionLead", ["fn-mehndi"])]),
  "programStaffGrants/program-1__staff-3":
    grant("staff-3", [duty("communications")]),
});

const applyInvites = (db: FakeFirestore, uid: string,
  data: Record<string, unknown>) =>
  applyProgramFunctionInvitationsHandler(request({
    programId: "program-1", functionId: "fn-sangeet",
    invitationMode: "selectedGuests", selectedGuestIds: [],
    expectedRevision: 1, ...data,
  }, uid), deps(db));

const recordRsvp = (db: FakeFirestore, uid: string,
  data: Record<string, unknown> = {}) =>
  recordProgramFunctionRsvpHandler(request({
    programId: "program-1", functionId: "fn-sangeet",
    guestId: "g-1", rsvpStatus: "attending", ...data,
  }, uid), deps(db));

const row = (db: FakeFirestore, key: string) =>
  db.getDoc(`programFunctionGuests/${key}`);

test("selectedGuests apply creates invited rows and revokes drops",
  async () => {
    const db = new FakeFirestore(seed());
    const first = await applyInvites(db, "manager-1",
      {selectedGuestIds: ["g-1", "g-2", "ghost"]});
    assert.deepEqual(
      {c: first.createdCount, r: first.revokedCount, k: first.keptCount},
      {c: 2, r: 0, k: 0});
    assert.equal(db.getDoc("programFunctions/fn-sangeet")!.invitationMode,
      "selectedGuests");
    assert.equal(row(db, "fn-sangeet_g-1")!.invited, true);
    assert.equal(row(db, "fn-sangeet_g-1")!.rsvpStatus, "pending");
    // Unknown program guests are ignored, never planned.
    assert.equal(row(db, "fn-sangeet_ghost"), undefined);
    const fnRevision = db.getDoc("programFunctions/fn-sangeet")!.revision;
    const second = await applyInvites(db, "manager-1",
      {selectedGuestIds: ["g-2"], expectedRevision: fnRevision});
    assert.deepEqual(
      {c: second.createdCount, r: second.revokedCount,
        k: second.keptCount},
      {c: 0, r: 1, k: 1});
    assert.equal(row(db, "fn-sangeet_g-1")!.invited, false);
  });

test("allGuests apply writes no rows and revokes stale invited rows",
  async () => {
    const db = new FakeFirestore({...seed(),
      "programFunctionGuests/fn-sangeet_g-3": {
        programId: "program-1", organizerId: "org-1",
        functionId: "fn-sangeet", guestId: "g-3",
        invited: true, rsvpStatus: "attending",
        attendanceStatus: "expected", partySize: 2,
        responseNote: null, respondedAt: now, responseSource: "staff",
        recordedByUid: "staff-1",
        createdAt: now, updatedAt: now, revision: 1,
      },
      "programFunctions/fn-sangeet": fn("fn-sangeet",
        {expectedCount: 2}),
    });
    const out = await applyInvites(db, "manager-1",
      {invitationMode: "allGuests", expectedRevision: 1});
    // g-3 is program-level notInvited: its stale invited row revokes.
    assert.deepEqual({c: out.createdCount, r: out.revokedCount},
      {c: 0, r: 1});
    assert.equal(row(db, "fn-sangeet_g-3")!.invited, false);
    // The revoked attending row stops counting toward expected.
    assert.equal(db.getDoc("programFunctions/fn-sangeet")!.expectedCount, 0);
    assert.equal(db.getDoc("programGuests/g-3")!.rsvpStatus, "declined");
  });

const denied = (err: unknown) =>
  (err as {code?: string}).code === "permission-denied";
const precondition = (err: unknown) =>
  (err as {code?: string}).code === "failed-precondition";

test("invitation apply needs coordinator duty and a live function",
  async () => {
    const db = new FakeFirestore(seed());
    await assert.rejects(
      applyInvites(db, "staff-3", {selectedGuestIds: ["g-1"]}), denied);
    await assert.rejects(
      applyInvites(db, "staff-1", {selectedGuestIds: ["g-1"]}), denied);
    db.updateDoc("programFunctions/fn-mehndi", {status: "cancelled"});
    await assert.rejects(
      applyInvites(db, "manager-1", {functionId: "fn-mehndi"}),
      precondition);
  });

test("staff record RSVP derives guest rollup and function counters",
  async () => {
    const db = new FakeFirestore(seed());
    const out = await recordRsvp(db, "staff-1",
      {partySize: 4, responseNote: "Kids included"});
    assert.equal(out.entityId, "fn-sangeet_g-1");
    assert.equal(out.guestRsvpStatus, "attending");
    const doc = row(db, "fn-sangeet_g-1")!;
    assert.equal(doc.rsvpStatus, "attending");
    assert.equal(doc.attendanceStatus, "expected");
    assert.equal(doc.responseSource, "staff");
    assert.equal(doc.recordedByUid, "staff-1");
    assert.equal(db.getDoc("programFunctions/fn-sangeet")!.expectedCount, 4);
    assert.equal(db.getDoc("programGuests/g-1")!.rsvpStatus, "attending");
    assert.equal(db.getDoc("programGuests/g-1")!.invitationStatus,
      "responded");
  });

test("selectedGuests function rejects uninvited unless overridden",
  async () => {
    const db = new FakeFirestore({...seed(),
      "programFunctions/fn-sangeet": fn("fn-sangeet",
        {invitationMode: "selectedGuests"}),
    });
    await assert.rejects(recordRsvp(db, "staff-1"),
      /notInvited/);
    const out = await recordRsvp(db, "staff-1", {allowUninvited: true});
    assert.equal(row(db, "fn-sangeet_g-1")!.invited, true);
    assert.equal(out.guestRsvpStatus, "attending");
  });

test("re-response preserves attendance state; rollup spans functions",
  async () => {
    const db = new FakeFirestore({...seed(),
      "programFunctionGuests/fn-sangeet_g-1": {
        programId: "program-1", organizerId: "org-1",
        functionId: "fn-sangeet", guestId: "g-1",
        invited: true, rsvpStatus: "attending",
        attendanceStatus: "checkedIn", partySize: 2,
        responseNote: null, respondedAt: now, responseSource: "staff",
        recordedByUid: "staff-1",
        createdAt: now, updatedAt: now, revision: 1,
      },
      "programFunctions/fn-sangeet": fn("fn-sangeet",
        {expectedCount: 2, checkedInCount: 2}),
    });
    await recordRsvp(db, "staff-1", {rsvpStatus: "declined"});
    const doc = row(db, "fn-sangeet_g-1")!;
    assert.equal(doc.rsvpStatus, "declined");
    // Door state survives a re-response; expected count drains.
    assert.equal(doc.attendanceStatus, "checkedIn");
    assert.equal(db.getDoc("programFunctions/fn-sangeet")!.expectedCount, 0);
    // checkedIn rows still count toward checkedInCount (they arrived).
    assert.equal(
      db.getDoc("programFunctions/fn-sangeet")!.checkedInCount, 2);
    assert.equal(db.getDoc("programGuests/g-1")!.rsvpStatus, "declined");
  });

test("function-scoped leads write only their functions; others denied",
  async () => {
    const db = new FakeFirestore(seed());
    // staff-2 holds functionLead scoped to fn-mehndi only.
    const out = await recordRsvp(db, "staff-2",
      {functionId: "fn-mehndi", guestId: "g-2"});
    assert.equal(out.entityId, "fn-mehndi_g-2");
    await assert.rejects(recordRsvp(db, "staff-2"), denied);
    await assert.rejects(recordRsvp(db, "staff-3"), denied);
  });
