import assert from "node:assert/strict";
import test from "node:test";
import {
  buildAttendanceReport,
  type AttendanceGuestRow,
} from "./programAttendanceReport";

const row = (functionId: string, guestId: string,
  patch: Partial<AttendanceGuestRow> = {}): AttendanceGuestRow => ({
  functionId,
  guestId,
  invited: true,
  rsvpStatus: "pending",
  attendanceStatus: "expected",
  partySize: null,
  ...patch,
});

test("function report separates RSVP truth from door truth", () => {
  const report = buildAttendanceReport(["sangeet"], [
    row("sangeet", "g-1", {rsvpStatus: "attending", partySize: 3,
      attendanceStatus: "checkedIn"}),
    row("sangeet", "g-2", {rsvpStatus: "attending"}),
    row("sangeet", "g-3", {rsvpStatus: "maybe"}),
    row("sangeet", "g-4", {rsvpStatus: "declined"}),
    row("sangeet", "g-5"),
    row("sangeet", "g-6", {rsvpStatus: "attending",
      attendanceStatus: "noShow"}),
  ]);
  const fn = report.functions[0];
  assert.equal(fn.invitedGuests, 6);
  assert.equal(fn.respondedGuests, 5);
  assert.equal(fn.attendingGuests, 3);
  assert.equal(fn.attendingHeads, 5); // 3 + 1 + 1
  assert.equal(fn.maybeGuests, 1);
  assert.equal(fn.declinedGuests, 1);
  assert.equal(fn.noResponseGuests, 1);
  assert.equal(fn.checkedInGuests, 1);
  assert.equal(fn.checkedInHeads, 3);
  assert.equal(fn.noShowGuests, 1);
  assert.equal(fn.expectedGuests, 4);
  assert.deepEqual(fn.exceptions.noShowGuestIds, ["g-6"]);
  assert.deepEqual(fn.exceptions.invitedNoResponseGuestIds, ["g-5"]);
  assert.deepEqual(fn.exceptions.walkInGuestIds, []);
});

test("walk-ins and declined check-ins surface as exceptions", () => {
  const report = buildAttendanceReport(["mehndi"], [
    // Walk-in: no invite row fields set, door journal created the row.
    row("mehndi", "w-1", {invited: false, rsvpStatus: "pending",
      attendanceStatus: "checkedIn", partySize: 2}),
    // Declined but arrived.
    row("mehndi", "g-1", {rsvpStatus: "declined",
      attendanceStatus: "checkedIn"}),
    row("mehndi", "g-2", {rsvpStatus: "attending",
      attendanceStatus: "checkedIn"}),
  ]);
  const fn = report.functions[0];
  assert.equal(fn.invitedGuests, 2);
  assert.equal(fn.checkedInGuests, 3);
  assert.equal(fn.walkInGuests, 1);
  assert.equal(fn.walkInHeads, 2);
  assert.deepEqual(fn.exceptions.walkInGuestIds, ["w-1"]);
  assert.deepEqual(fn.exceptions.declinedCheckedInGuestIds, ["g-1"]);
});

test("unlisted functions are ignored and empty functions report zeroes",
  () => {
    const report = buildAttendanceReport(["haldi", "bidaai"], [
      row("sangeet", "g-1", {rsvpStatus: "attending"}),
      row("haldi", "g-2", {rsvpStatus: "attending",
        attendanceStatus: "checkedIn"}),
    ]);
    assert.deepEqual(report.functions.map((fn) => fn.functionId),
      ["haldi", "bidaai"]);
    assert.equal(report.functions[0].checkedInGuests, 1);
    assert.equal(report.functions[1].invitedGuests, 0);
    assert.equal(report.functions[1].checkedInGuests, 0);
  });

test("program rollup counts each guest once across functions", () => {
  const report = buildAttendanceReport(["sangeet", "mehndi"], [
    row("sangeet", "g-1", {rsvpStatus: "attending",
      attendanceStatus: "checkedIn"}),
    row("mehndi", "g-1", {rsvpStatus: "attending",
      attendanceStatus: "checkedIn"}),
    row("sangeet", "g-2", {rsvpStatus: "attending"}),
    row("mehndi", "g-3", {rsvpStatus: "declined",
      attendanceStatus: "noShow"}),
    // A guest known to the program but not on this function's list is
    // still a program guest row — rows only exist per function.
    row("sangeet", "w-1", {invited: false,
      attendanceStatus: "checkedIn"}),
  ]);
  assert.equal(report.programGuests, 4);
  assert.equal(report.programInvitedGuests, 3);
  assert.equal(report.programAttendingGuests, 2);
  assert.equal(report.programCheckedInGuests, 2);
  assert.equal(report.programNoShowGuests, 1);
});

test("exception lists are deduplicated and sorted", () => {
  const report = buildAttendanceReport(["fn"], [
    row("fn", "z-9", {rsvpStatus: "pending"}),
    row("fn", "a-1", {rsvpStatus: "pending"}),
    row("fn", "m-5", {rsvpStatus: "pending"}),
  ]);
  assert.deepEqual(report.functions[0].exceptions.invitedNoResponseGuestIds,
    ["a-1", "m-5", "z-9"]);
});

test("report carries no guest identity beyond ids", () => {
  const report = buildAttendanceReport(["fn"], [
    row("fn", "g-1", {rsvpStatus: "attending",
      attendanceStatus: "checkedIn"}),
  ]);
  const serialized = JSON.stringify(report);
  for (const banned of ["displayName", "phone", "email", "notes",
    "responseNote", "contactId"]) {
    assert.ok(!serialized.includes(banned),
      `report leaked ${banned}`);
  }
});
