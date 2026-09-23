import assert from "node:assert/strict";
import test from "node:test";
import {
  planInvitationDiff,
  resolveEffectiveInviteSet,
  type FunctionGuestRowLike,
  type FunctionLike,
  type ProgramGuestLike,
} from "./functionInvitation";

function guest(
  guestId: string,
  partial?: Partial<ProgramGuestLike>,
): ProgramGuestLike {
  return {
    guestId,
    invitationStatus: "invited",
    rsvpStatus: "pending",
    ...partial,
  };
}

function row(
  guestId: string,
  partial?: Partial<FunctionGuestRowLike>,
): FunctionGuestRowLike {
  return {
    functionId: "sangeet",
    guestId,
    invited: true,
    rsvpStatus: "pending",
    attendanceStatus: "expected",
    ...partial,
  };
}

function fn(partial?: Partial<FunctionLike>): FunctionLike {
  return {functionId: "sangeet", status: "scheduled", ...partial};
}

const guests: ProgramGuestLike[] = [
  guest("a"),
  guest("b", {invitationStatus: "delivered"}),
  guest("c", {invitationStatus: "responded"}),
  guest("d", {invitationStatus: "notInvited"}),
];

test("resolveEffectiveInviteSet defaults to all invited program guests", () => {
  const invited = resolveEffectiveInviteSet(fn(), guests, []);
  assert.deepEqual([...invited].sort(), ["a", "b", "c"]);
});

test("resolveEffectiveInviteSet honors explicit allGuests mode", () => {
  const invited = resolveEffectiveInviteSet(
    fn({invitationMode: "allGuests"}), guests, []);
  assert.deepEqual([...invited].sort(), ["a", "b", "c"]);
});

test("resolveEffectiveInviteSet reads invited rows on selectedGuests", () => {
  const rows = [
    row("a"),
    // A selectedGuests row invites even a notInvited program guest.
    row("d"),
    // Revoked rows and rows for other functions never count.
    row("z", {invited: false}),
    row("q", {functionId: "haldi"}),
  ];
  const invited = resolveEffectiveInviteSet(
    fn({invitationMode: "selectedGuests"}), guests, rows);
  assert.deepEqual([...invited].sort(), ["a", "d"]);
});

test("resolveEffectiveInviteSet is empty for cancelled functions", () => {
  assert.equal(
    resolveEffectiveInviteSet(fn({status: "cancelled"}), guests, []).size,
    0);
  assert.equal(resolveEffectiveInviteSet(
    fn({status: "cancelled", invitationMode: "selectedGuests"}),
    guests, [row("a")]).size, 0);
});

test("planInvitationDiff creates, keeps, and revokes in sorted order", () => {
  const current = [
    row("b"), // stays invited
    row("c"), // falls off the desired list
    row("e", {invited: false}), // tombstone re-invited through toCreate
  ];
  const plan = planInvitationDiff(
    fn({invitationMode: "selectedGuests"}), current,
    ["e", "b", "a", "ghost"], ["a", "b", "c", "d", "e"]);
  // "ghost" is not in the program and is ignored; output is sorted.
  assert.deepEqual(plan.toCreate, ["a", "e"]);
  assert.deepEqual(plan.toKeep.map((r) => r.guestId), ["b"]);
  assert.deepEqual(plan.toRevoke.map((r) => r.guestId), ["c"]);
});

test("planInvitationDiff ignores rows for other functions", () => {
  const plan = planInvitationDiff(fn(),
    [row("x", {functionId: "haldi"})], ["a"], ["a", "x"]);
  assert.deepEqual(plan.toCreate, ["a"]);
  assert.deepEqual(plan.toKeep, []);
  assert.deepEqual(plan.toRevoke, []);
});

test("planInvitationDiff returns an empty plan for cancelled functions", () => {
  const plan = planInvitationDiff(fn({status: "cancelled"}),
    [row("a")], ["a", "b"], ["a", "b"]);
  assert.deepEqual(plan, {toCreate: [], toRevoke: [], toKeep: []});
});

test("planInvitationDiff with no desired guests revokes everything", () => {
  const plan = planInvitationDiff(fn(), [row("a"), row("b")], [],
    ["a", "b"]);
  assert.deepEqual(plan.toCreate, []);
  assert.deepEqual(plan.toKeep, []);
  assert.deepEqual(plan.toRevoke.map((r) => r.guestId), ["a", "b"]);
});
