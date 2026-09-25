import assert from "node:assert/strict";
import {describe, it} from "node:test";

import type {
  FunctionGuestRowLike,
  FunctionLike,
} from "./functionInvitation";
import {
  resolveProgramSelection,
  type SelectionGuest,
} from "./programSelection";

const guest = (
  guestId: string,
  householdId: string | null = null,
  phoneE164: string | null = `+1555${guestId.padStart(4, "0")}`,
  invitationStatus:
    "notInvited" | "invited" | "delivered" | "responded" = "invited",
): SelectionGuest => ({guestId, householdId, phoneE164, invitationStatus});

const fn = (
  functionId: string,
  invitationMode?: "allGuests" | "selectedGuests",
  status: "scheduled" | "completed" | "cancelled" = "scheduled",
): FunctionLike => ({functionId, invitationMode, status});

const row = (
  functionId: string,
  guestId: string,
  rsvpStatus: "pending" | "attending" | "declined" | "maybe",
  invited = true,
): FunctionGuestRowLike => ({
  functionId, guestId, invited, rsvpStatus, attendanceStatus: "expected",
});

const FUNCTIONS: FunctionLike[] = [
  fn("f1"), fn("f2", "selectedGuests"), fn("f3"), fn("f4", "allGuests",
    "cancelled"),
];
const GUESTS: SelectionGuest[] = [
  guest("g1", "h1"), guest("g2", "h1"), guest("g3", "h2"),
  guest("g4", null), guest("g5", "h3", null),
  guest("g6", "h4", "+15550666", "notInvited"),
];

describe("resolveProgramSelection", () => {
  it("allGuests functions treat absent rows as pending", () => {
    const out = resolveProgramSelection(
      {functionIds: ["f1"], rsvpStatuses: ["pending"],
        householdDedupe: false},
      FUNCTIONS, GUESTS, [],
    );
    assert.deepEqual(
      out.recipients.map((r) => r.recipientKey),
      ["guest:g1", "guest:g2", "guest:g3", "guest:g4"],
    );
    // g5 qualifies then drops via noPhone; only g6 (program notInvited)
    // qualifies on no function.
    assert.equal(out.excluded.noPhone, 1);
    assert.equal(out.excluded.notSelected, 1);
  });

  it("selectedGuests functions only invite marked rows", () => {
    const out = resolveProgramSelection(
      {functionIds: ["f2"], rsvpStatuses: ["attending"],
        householdDedupe: false},
      FUNCTIONS, GUESTS,
      [row("f2", "g1", "attending"), row("f2", "g3", "attending")],
    );
    assert.deepEqual(
      out.recipients.map((r) => r.recipientKey),
      ["guest:g1", "guest:g3"],
    );
  });

  it("unions guests across selected functions and dedupes households", () => {
    const out = resolveProgramSelection(
      {functionIds: null, rsvpStatuses: ["attending"],
        householdDedupe: true},
      FUNCTIONS, GUESTS,
      [
        row("f1", "g1", "attending"),
        row("f1", "g2", "attending"),
        row("f3", "g2", "attending"),
        row("f3", "g4", "attending"),
      ],
    );
    assert.deepEqual(
      out.recipients.map((r) => r.recipientKey),
      ["guest:g4", "household:h1"],
    );
    // Both members ride one household recipient; g4 stays a guest key.
    assert.deepEqual(
      out.recipients.find((r) => r.recipientKey === "household:h1")?.guestIds,
      ["g1", "g2"],
    );
  });

  it("skips cancelled functions and unknown ids", () => {
    const out = resolveProgramSelection(
      {functionIds: ["f4", "missing"], rsvpStatuses: ["pending"],
        householdDedupe: false},
      FUNCTIONS, GUESTS, [],
    );
    assert.deepEqual(out.recipients, []);
  });

  it("counts filtered pairs across functions", () => {
    const out = resolveProgramSelection(
      {functionIds: ["f1", "f3"], rsvpStatuses: ["attending"],
        householdDedupe: false},
      FUNCTIONS, GUESTS,
      [
        row("f1", "g1", "declined"),
        row("f1", "g2", "attending"),
        row("f3", "g1", "attending"),
      ],
    );
    // Every (function, invitee) pair outside the filter counts: f1
    // misses g1/g3/g4/g5, f3 misses g2/g3/g4/g5 (pending counts too).
    assert.equal(out.excluded.rsvpFiltered, 8);
    assert.deepEqual(
      out.recipients.map((r) => r.recipientKey),
      ["guest:g1", "guest:g2"],
    );
  });

  it("household dedupe drops groups with no phone", () => {
    const out = resolveProgramSelection(
      {functionIds: ["f1"], rsvpStatuses: ["attending"],
        householdDedupe: true},
      FUNCTIONS,
      [guest("a1", "hx", null), guest("a2", "hx", null),
        guest("b1", "hy", "+15550001")],
      [row("f1", "a1", "attending"), row("f1", "a2", "attending"),
        row("f1", "b1", "attending")],
    );
    assert.deepEqual(
      out.recipients.map((r) => r.recipientKey),
      ["household:hy"],
    );
    assert.equal(out.excluded.noPhone, 1);
  });

  it("empty rsvpStatuses yields no recipients", () => {
    const out = resolveProgramSelection(
      {functionIds: null, rsvpStatuses: [], householdDedupe: false},
      FUNCTIONS, GUESTS,
      [row("f1", "g1", "attending")],
    );
    assert.deepEqual(out.recipients, []);
  });

  it("picks the first non-null household phone deterministically", () => {
    const guests: SelectionGuest[] = [
      guest("z2", "hz", "+15550002"),
      guest("z1", "hz", "+15550001"),
    ];
    const out = resolveProgramSelection(
      {functionIds: ["f1"], rsvpStatuses: ["attending"],
        householdDedupe: true},
      FUNCTIONS, guests,
      [row("f1", "z1", "attending"), row("f1", "z2", "attending")],
    );
    // Members sorted by guestId, so z1's phone wins.
    assert.equal(out.recipients[0].phoneE164, "+15550001");
    assert.deepEqual(out.recipients[0].guestIds, ["z1", "z2"]);
  });
});
