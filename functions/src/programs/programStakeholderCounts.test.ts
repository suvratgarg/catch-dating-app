import assert from "node:assert/strict";
import {describe, it} from "node:test";

import {
  computeStakeholderCounts,
  type StakeholderFunctionGuestRow,
  type StakeholderFunctionRow,
  type StakeholderGuestRow,
  type StakeholderLegRow,
} from "./programStakeholderCounts";

const guest = (
  guestId: string,
  householdId: string | null = null,
): StakeholderGuestRow =>
  ({guestId, householdId, invitationStatus: "invited"});

const fn = (
  functionId: string,
  invitationMode: "allGuests" | "selectedGuests" | null = "allGuests",
  status: "scheduled" | "completed" | "cancelled" = "scheduled",
): StakeholderFunctionRow => ({functionId, invitationMode, status});

const fg = (
  functionId: string,
  guestId: string,
  patch: Partial<StakeholderFunctionGuestRow> = {},
): StakeholderFunctionGuestRow => ({
  functionId, guestId, invited: true, rsvpStatus: "pending",
  attendanceStatus: "expected", partySize: null, ...patch,
});

const leg = (
  legId: string,
  guestId: string,
  destinationHotelId: string | null,
  patch: Partial<StakeholderLegRow> = {},
): StakeholderLegRow => ({
  legId, guestId, destinationHotelId, passengers: 1,
  readiness: "expected", ...patch,
});

describe("computeStakeholderCounts", () => {
  it("counts allGuests functions against every program guest", () => {
    const counts = computeStakeholderCounts({
      guests: [guest("g-1"), guest("g-2"), guest("g-3")],
      households: [{householdId: "hh-1"}],
      functions: [fn("fn-1")],
      functionGuests: [fg("fn-1", "g-1", {rsvpStatus: "attending"})],
      legs: [],
    });
    const row = counts.functions[0];
    assert.equal(row.invitedCount, 3);
    // g-2/g-3 have no functionGuests row: pending, not dropped.
    assert.equal(row.rsvpPending, 2);
    assert.equal(row.rsvpAttending, 1);
    assert.equal(row.expectedHeads, 1);
  });

  it("counts selectedGuests functions only against invited rows", () => {
    const counts = computeStakeholderCounts({
      guests: [guest("g-1"), guest("g-2"), guest("g-3")],
      households: [],
      functions: [fn("fn-1", "selectedGuests")],
      functionGuests: [
        fg("fn-1", "g-1", {rsvpStatus: "attending", partySize: 3}),
        fg("fn-1", "g-2", {invited: false, rsvpStatus: "declined"}),
      ],
      legs: [],
    });
    const row = counts.functions[0];
    assert.equal(row.invitedCount, 1);
    assert.equal(row.rsvpAttending, 1);
    // g-2's row is not invited — excluded from the invited cohort entirely.
    assert.equal(row.rsvpDeclined, 0);
    assert.equal(row.expectedHeads, 3);
  });

  it("sums partySize heads for attending and checked-in guests", () => {
    const counts = computeStakeholderCounts({
      guests: [guest("g-1"), guest("g-2")],
      households: [],
      functions: [fn("fn-1", "selectedGuests")],
      functionGuests: [
        fg("fn-1", "g-1",
          {rsvpStatus: "attending", attendanceStatus: "checkedIn",
            partySize: 4}),
        fg("fn-1", "g-2", {rsvpStatus: "attending"}),
      ],
      legs: [],
    });
    const row = counts.functions[0];
    assert.equal(row.expectedHeads, 5); // 4 + (null → 1)
    assert.equal(row.checkedInHeads, 4);
  });

  it("reports noShow as a guest count, not heads", () => {
    const counts = computeStakeholderCounts({
      guests: [guest("g-1")],
      households: [],
      functions: [fn("fn-1", "selectedGuests")],
      functionGuests: [fg("fn-1", "g-1",
        {rsvpStatus: "attending", attendanceStatus: "noShow",
          partySize: 6})],
      legs: [],
    });
    const row = counts.functions[0];
    assert.equal(row.noShowCount, 1);
    assert.equal(row.checkedInHeads, 0);
  });

  it("emits a cancelled function's counts untouched", () => {
    const counts = computeStakeholderCounts({
      guests: [guest("g-1")],
      households: [],
      functions: [fn("fn-1", "selectedGuests", "cancelled")],
      functionGuests: [fg("fn-1", "g-1", {rsvpStatus: "attending"})],
      legs: [],
    });
    assert.equal(counts.functions[0].status, "cancelled");
    assert.equal(counts.functions[0].rsvpAttending, 1);
  });

  it("counts distinct guests per hotel and dedupes multi-leg guests", () => {
    const counts = computeStakeholderCounts({
      guests: [guest("g-1"), guest("g-2"), guest("g-3")],
      households: [],
      functions: [],
      functionGuests: [],
      legs: [
        leg("l-1", "g-1", "hotel-a"),
        // g-1's ground transfer to the same hotel counts once.
        leg("l-2", "g-1", "hotel-a", {readiness: "arrived"}),
        leg("l-3", "g-2", "hotel-a", {readiness: "arrived"}),
        leg("l-4", "g-3", "hotel-b"),
        // A leg with a free-text destination lands on no hotel.
        leg("l-5", "g-3", null),
      ],
    });
    const a = counts.hotels.find((h) => h.hotelId === "hotel-a")!;
    assert.equal(a.routedGuestCount, 2);
    assert.equal(a.arrivedGuestCount, 2);
    assert.equal(a.legCount, 3);
    const b = counts.hotels.find((h) => h.hotelId === "hotel-b")!;
    assert.equal(b.routedGuestCount, 1);
    assert.equal(b.arrivedGuestCount, 0);
  });

  it("sorts hotels by id and counts households and guests", () => {
    const counts = computeStakeholderCounts({
      guests: [guest("g-1", "hh-1"), guest("g-2", "hh-2")],
      households: [{householdId: "hh-2"}, {householdId: "hh-1"}],
      functions: [],
      functionGuests: [],
      legs: [leg("l-1", "g-1", "z-hotel"), leg("l-2", "g-2", "a-hotel")],
    });
    assert.equal(counts.guestCount, 2);
    assert.equal(counts.householdCount, 2);
    assert.deepEqual(
      counts.hotels.map((h) => h.hotelId), ["a-hotel", "z-hotel"]);
  });

  it("emits no name, phone, or note fields anywhere in the output", () => {
    const counts = computeStakeholderCounts({
      guests: [guest("g-1")],
      households: [{householdId: "hh-1"}],
      functions: [fn("fn-1")],
      functionGuests: [fg("fn-1", "g-1", {rsvpStatus: "attending"})],
      legs: [leg("l-1", "g-1", "hotel-a")],
    });
    const forbidden = /displayName|phone|email|note|label/i;
    assert.equal(forbidden.test(JSON.stringify(counts)), false);
  });
});
