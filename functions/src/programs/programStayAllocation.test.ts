import assert from "node:assert/strict";
import {describe, it} from "node:test";

import {
  blockRemainingRooms,
  staysConsumingBlock,
  suggestStayBlock,
  unplacedGuests,
  type RoomBlockRow,
  type StayGuestRow,
  type StayRow,
} from "./programStayAllocation";

const block = (
  roomBlockId: string,
  patch: Partial<RoomBlockRow> = {},
): RoomBlockRow => ({
  roomBlockId, hotelId: "hotel-1", label: roomBlockId,
  totalRooms: 2, assignedCount: 0, heldForGroupIds: [], ...patch,
});

const stay = (
  stayId: string,
  guestId: string,
  patch: Partial<StayRow> = {},
): StayRow => ({
  stayId, guestId, hotelId: "hotel-1",
  roomBlockId: null, roomLabel: null, status: "confirmed", ...patch,
});

const guest = (
  guestId: string,
  groupIds: string[] = [],
): StayGuestRow => ({guestId, groupIds});

describe("blockRemainingRooms", () => {
  it("subtracts the assigned rollup and never overbooks on drift", () => {
    const b = block("b-1", {totalRooms: 3, assignedCount: 2});
    assert.equal(blockRemainingRooms(b, []), 1);
    // Live stays exceed the stale rollup — live count wins.
    const stays = [
      stay("s-1", "g-1", {roomBlockId: "b-1"}),
      stay("s-2", "g-2", {roomBlockId: "b-1"}),
      stay("s-3", "g-3", {roomBlockId: "b-1"}),
    ];
    assert.equal(blockRemainingRooms(b, stays), 0);
  });

  it("cancelled and checkedOut stays do not consume capacity", () => {
    const b = block("b-1", {totalRooms: 2, assignedCount: 0});
    const stays = [
      stay("s-1", "g-1", {roomBlockId: "b-1", status: "cancelled"}),
      stay("s-2", "g-2", {roomBlockId: "b-1", status: "checkedOut"}),
      stay("s-3", "g-3", {roomBlockId: "b-1"}),
    ];
    assert.equal(staysConsumingBlock(stays, "b-1").length, 1);
    assert.equal(blockRemainingRooms(b, stays), 1);
  });
});

describe("unplacedGuests", () => {
  it("excludes guests with any live stay, re-includes checkedOut", () => {
    const guests = [guest("g-1"), guest("g-2"), guest("g-3")];
    const stays = [
      stay("s-1", "g-1"),
      stay("s-2", "g-2", {status: "checkedOut"}),
    ];
    assert.deepEqual(
      unplacedGuests(guests, stays).map((g) => g.guestId),
      ["g-2", "g-3"]);
  });
});

describe("suggestStayBlock", () => {
  it("prefers a block held for the guest's group", () => {
    const blocks = [
      block("general", {label: "General"}),
      block("bride", {label: "Bride", heldForGroupIds: ["grp-bride"]}),
    ];
    const pick = suggestStayBlock(guest("g-1", ["grp-bride"]),
      "hotel-1", blocks, []);
    assert.equal(pick?.roomBlockId, "bride");
  });

  it("falls back to general inventory for ungrouped guests", () => {
    const blocks = [
      block("bride", {label: "Bride", heldForGroupIds: ["grp-bride"]}),
      block("general", {label: "General"}),
    ];
    const pick = suggestStayBlock(guest("g-1"), "hotel-1", blocks, []);
    assert.equal(pick?.roomBlockId, "general");
  });

  it("skips the held block when it is full", () => {
    const blocks = [
      block("bride", {label: "Bride", totalRooms: 1,
        heldForGroupIds: ["grp-bride"]}),
      block("general", {label: "General"}),
    ];
    const stays = [stay("s-1", "g-9", {roomBlockId: "bride"})];
    const pick = suggestStayBlock(guest("g-1", ["grp-bride"]),
      "hotel-1", blocks, stays);
    assert.equal(pick?.roomBlockId, "general");
  });

  it("never suggests a block at a different hotel", () => {
    const blocks = [block("b-1", {hotelId: "hotel-2"})];
    assert.equal(
      suggestStayBlock(guest("g-1"), "hotel-1", blocks, []), null);
  });

  it("returns null when the hotel is fully booked", () => {
    const blocks = [block("b-1", {totalRooms: 1})];
    const stays = [stay("s-1", "g-9", {roomBlockId: "b-1"})];
    assert.equal(
      suggestStayBlock(guest("g-1"), "hotel-1", blocks, stays), null);
  });
});
