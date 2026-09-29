import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {baseSeed, deps, request, now} from "../shared/testing/programFixtures";
import {FakeFirestore, type FakeData} from
  "../shared/testing/programFirestore";
import {getProgramAttendanceReportHandler} from "./attendanceReportView";

const DAY = 86_400_000;

const grant = (uid: string, duty: string): FakeData => ({
  organizerId: "org-1",
  programId: "program-1",
  uid,
  displayName: "Reconciler",
  phoneLastFour: "0088",
  duties: [{
    duty, expiresAtMillis: 1_800_000_000_000 + DAY,
    pickupPointIds: [], hotelIds: [],
  }],
  status: "active",
  createdBy: "manager-1",
  createdAt: now,
  expiresAt: admin.firestore.Timestamp.fromMillis(1_800_000_000_000 + DAY),
  revokedBy: null,
  revokedAt: null,
  updatedAt: now,
  revision: 1,
});

const fn = (id: string, startsAtMillis: number): FakeData => ({
  programId: "program-1",
  organizerId: "org-1",
  name: `Function ${id}`,
  status: "scheduled",
  invitationMode: "allGuests",
  checkInEnabled: true,
  startsAt: admin.firestore.Timestamp.fromMillis(startsAtMillis),
  endsAt: admin.firestore.Timestamp.fromMillis(startsAtMillis + 3_600_000),
  venueName: null,
  venueNotes: null,
  dressCode: null,
  instructions: null,
  expectedCount: 0,
  checkedInCount: 0,
  createdAt: now,
  updatedAt: now,
  revision: 1,
});

const joinRow = (functionId: string, guestId: string,
  patch: Record<string, unknown> = {}): FakeData => ({
  programId: "program-1",
  organizerId: "org-1",
  functionId,
  guestId,
  invited: true,
  rsvpStatus: "pending",
  attendanceStatus: "expected",
  partySize: null,
  respondedAt: null,
  responseNote: null,
  responseSource: null,
  recordedByUid: null,
  createdAt: now,
  updatedAt: now,
  revision: 1,
  ...patch,
});

const seed = () => ({
  ...baseSeed(),
  "programFunctions/fn-early": fn("fn-early", 1_800_100_000_000),
  "programFunctions/fn-late": fn("fn-late", 1_800_200_000_000),
  "programFunctionGuests/fn-early_guest-1": joinRow("fn-early", "guest-1",
    {rsvpStatus: "attending", partySize: 2,
      attendanceStatus: "checkedIn"}),
  "programFunctionGuests/fn-early_walkin-1": joinRow("fn-early",
    "walkin-1", {invited: false, attendanceStatus: "checkedIn"}),
  "programFunctionGuests/fn-late_guest-2": joinRow("fn-late", "guest-2",
    {rsvpStatus: "declined", attendanceStatus: "checkedIn"}),
  "programStaffGrants/program-1__reconciler-1": grant(
    "reconciler-1", "reconciliationViewer"),
});

const report = (db: FakeFirestore, uid = "reconciler-1") =>
  getProgramAttendanceReportHandler(
    request({programId: "program-1"}, uid), deps(db));

test("reconciliationViewer gets the program report in start order",
  async () => {
    const res = await report(new FakeFirestore(seed()));
    assert.equal(res.programId, "program-1");
    assert.deepEqual(
      res.functions.map((f) => f.functionId), ["fn-early", "fn-late"]);

    const early = res.functions[0];
    assert.equal(early.invitedGuests, 1);
    assert.equal(early.attendingHeads, 2);
    // Guest + walk-in both checked in.
    assert.equal(early.checkedInGuests, 2);
    assert.equal(early.checkedInHeads, 3);
    assert.equal(early.walkInGuests, 1);
    assert.deepEqual(early.exceptions.walkInGuestIds, ["walkin-1"]);

    const late = res.functions[1];
    assert.equal(late.declinedGuests, 1);
    assert.deepEqual(
      late.exceptions.declinedCheckedInGuestIds, ["guest-2"]);

    // Program uniqueness dedupes across functions.
    assert.equal(res.programCheckedInGuests, 3);
    assert.equal(res.programInvitedGuests, 2);
    assert.equal(res.accessExpiresAtMillis, 1_800_000_000_000 + DAY);
  });

test("managers and program coordinators read the report", async () => {
  const db = new FakeFirestore({...seed(),
    "programStaffGrants/program-1__coordinator-1": grant(
      "coordinator-1", "programCoordinator")});
  const managerRes = await report(db, "manager-1");
  assert.equal(managerRes.accessExpiresAtMillis, null);
  const coordRes = await report(db, "coordinator-1");
  assert.equal(coordRes.functions.length, 2);
});

test("staff without the reconciliationViewer duty are denied", async () => {
  await assert.rejects(report(new FakeFirestore(seed()), "greeter-1"),
    (error: unknown) => (error as {code?: string}).code ===
      "permission-denied");
  await assert.rejects(report(new FakeFirestore(seed()), "outsider-1"),
    (error: unknown) => (error as {code?: string}).code ===
      "permission-denied");
});

test("rows from other programs never leak", async () => {
  const db = new FakeFirestore({...seed(),
    "programFunctionGuests/foreign": joinRow("fn-early", "guest-9",
      {programId: "program-9", attendanceStatus: "checkedIn"})});
  const res = await report(db);
  assert.equal(res.programCheckedInGuests, 3);
  assert.equal(res.functions[0].checkedInGuests, 2);
});
