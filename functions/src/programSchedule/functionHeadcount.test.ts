import assert from "node:assert/strict";
import test from "node:test";
import {countFunctionHeads} from "./functionHeadcount";
import type {
  FunctionRsvpLike,
  ProgramGuestLike,
} from "./guestItinerary";

function guest(
  guestId: string,
  partial?: Partial<ProgramGuestLike>,
): ProgramGuestLike {
  return {
    guestId,
    displayName: guestId,
    invitationStatus: "invited",
    rsvpStatus: "pending",
    ...partial,
  };
}

const guests: ProgramGuestLike[] = [
  guest("a", {rsvpStatus: "attending"}),
  guest("b", {rsvpStatus: "declined"}),
  guest("c", {rsvpStatus: "pending"}),
  guest("d", {rsvpStatus: "maybe"}),
  guest("e", {invitationStatus: "notInvited", rsvpStatus: "attending"}),
  guest("f", {invitationStatus: "delivered", rsvpStatus: "attending"}),
  guest("g", {invitationStatus: "responded", rsvpStatus: "declined"}),
];

test("countFunctionHeads buckets invited guests by rsvp", () => {
  assert.deepEqual(countFunctionHeads("sangeet", guests, []), {
    invited: 6,
    attending: 2,
    declined: 2,
    // "pending" and "maybe" both land in pending.
    pending: 2,
  });
});

test("per-function overrides adjust the count", () => {
  const overrides: FunctionRsvpLike[] = [
    {functionId: "sangeet", guestId: "c", rsvpStatus: "attending"},
    {functionId: "sangeet", guestId: "e", rsvpStatus: "declined"},
    // Overrides for other functions are ignored.
    {functionId: "haldi", guestId: "a", rsvpStatus: "declined"},
  ];
  assert.deepEqual(countFunctionHeads("sangeet", guests, overrides), {
    invited: 6,
    attending: 3,
    declined: 2,
    pending: 1,
  });
  // An override for a notInvited guest never pulls them in.
  assert.deepEqual(countFunctionHeads("haldi", guests, overrides), {
    invited: 6,
    attending: 1,
    declined: 3,
    pending: 2,
  });
});

test("empty guest lists produce a zero headcount", () => {
  assert.deepEqual(countFunctionHeads("sangeet", [], []), {
    invited: 0,
    attending: 0,
    declined: 0,
    pending: 0,
  });
});
