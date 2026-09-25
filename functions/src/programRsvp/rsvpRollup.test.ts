import assert from "node:assert/strict";
import test from "node:test";
import type {
  FunctionGuestRowLike,
  FunctionLike,
} from "./functionInvitation";
import {
  functionCountPatch,
  rollupGuestRsvp,
  rollupGuestRsvpForFunctions,
} from "./rsvpRollup";

function row(
  functionId: string,
  rsvpStatus: FunctionGuestRowLike["rsvpStatus"],
  partial?: Partial<FunctionGuestRowLike>,
): FunctionGuestRowLike {
  return {
    functionId,
    guestId: "g",
    invited: true,
    rsvpStatus,
    attendanceStatus: "expected",
    ...partial,
  };
}

function fn(partial?: Partial<FunctionLike>): FunctionLike {
  return {functionId: "f", status: "scheduled", ...partial};
}

test("rollupGuestRsvp precedence is attending > maybe > pending", () => {
  assert.equal(rollupGuestRsvp([
    row("f1", "declined"),
    row("f2", "attending"),
    row("f3", "maybe"),
  ]), "attending");
  assert.equal(rollupGuestRsvp([
    row("f1", "declined"),
    row("f2", "maybe"),
    row("f3", "pending"),
  ]), "maybe");
  assert.equal(rollupGuestRsvp([
    row("f1", "declined"),
    row("f2", "pending"),
  ]), "pending");
});

test("rollupGuestRsvp declines when all declined or empty", () => {
  assert.equal(rollupGuestRsvp(
    [row("f1", "declined"), row("f2", "declined")]), "declined");
  assert.equal(rollupGuestRsvp([]), "declined");
});

test("rollupGuestRsvpForFunctions drops cancelled and missing", () => {
  const functions: FunctionLike[] = [
    {functionId: "live", status: "scheduled"},
    {functionId: "done", status: "completed"},
    {functionId: "axed", status: "cancelled"},
  ];
  // The attending rows sit on cancelled and unknown functions, so only
  // the live pending and completed declined rows feed the rollup.
  assert.equal(rollupGuestRsvpForFunctions([
    row("live", "pending"),
    row("done", "declined"),
    row("axed", "attending"),
    row("ghost", "attending"),
  ], functions), "pending");
});

test("rollupGuestRsvpForFunctions accepts a functions map", () => {
  const functions = new Map<string, FunctionLike>([
    ["axed", {functionId: "axed", status: "cancelled"}],
    ["done", {functionId: "done", status: "completed"}],
  ]);
  assert.equal(rollupGuestRsvpForFunctions([
    row("axed", "attending"),
    row("done", "maybe"),
  ], functions), "maybe");
});

test("functionCountPatch sums attending party sizes", () => {
  const patch = functionCountPatch(fn(), [
    row("f", "attending", {partySize: 4}),
    // Absent and null partySize both read as 1.
    row("f", "attending"),
    row("f", "attending", {partySize: null}),
    // Declined rows and rows for other functions never count.
    row("f", "declined", {partySize: 9}),
    row("g", "attending", {partySize: 7}),
  ]);
  assert.deepEqual(patch, {expectedCount: 6, checkedInCount: 0});
});

test("functionCountPatch sums checked-in party sizes", () => {
  const patch = functionCountPatch(fn({expectedCount: 3}), [
    row("f", "attending",
      {partySize: 2, attendanceStatus: "checkedIn"}),
    row("f", "attending", {attendanceStatus: "checkedIn"}),
    row("f", "attending", {partySize: 5, attendanceStatus: "noShow"}),
  ]);
  assert.deepEqual(patch, {expectedCount: 8, checkedInCount: 3});
});

test("functionCountPatch returns null when counts already match", () => {
  assert.equal(functionCountPatch(
    fn({expectedCount: 3, checkedInCount: 1}), [
      row("f", "attending", {partySize: 2}),
      row("f", "attending", {attendanceStatus: "checkedIn"}),
    ]), null);
});

test("functionCountPatch treats absent counters as zero", () => {
  assert.equal(functionCountPatch(fn(), []), null);
  assert.equal(functionCountPatch(fn({expectedCount: 0}), []), null);
  // A stale non-zero counter still produces a corrective patch.
  assert.deepEqual(functionCountPatch(fn({expectedCount: 4}), []),
    {expectedCount: 0, checkedInCount: 0});
});

test("functionCountPatch freezes cancelled functions", () => {
  assert.equal(functionCountPatch(fn({status: "cancelled"}),
    [row("f", "attending", {partySize: 3})]), null);
});
