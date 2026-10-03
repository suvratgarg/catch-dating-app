import assert from "node:assert/strict";
import {test} from "node:test";
import {nightInterval, peakRoomOccupancy, validateRoomOccupancy} from
  "./programRoomOccupancy";
import type {RoomBlockRow, StayRow} from "./programStayAllocation";

const day = (n: number) => Date.UTC(2026, 9, n);
const stay = (id: string, start: number, end: number,
  patch: Partial<StayRow> = {}): StayRow => ({
  stayId: id, guestId: id, hotelId: "hotel", roomBlockId: "block",
  roomLabel: "Same label", status: "confirmed",
  startsAtMillis: day(start), endsAtMillis: day(end), ...patch,
});
const block: RoomBlockRow = {
  roomBlockId: "block", hotelId: "hotel", label: "Rooms", totalRooms: 2,
  assignedCount: 99, heldForGroupIds: [], maxOccupantsPerRoom: 2,
  startsAtMillis: day(1), endsAtMillis: day(8),
};

test("explicit roommates count once; same labels never imply sharing", () => {
  const rows = [stay("a", 1, 3), stay("b", 1, 3)];
  assert.equal(peakRoomOccupancy(rows), 2);
  rows[0].roomOccupancyId = rows[1].roomOccupancyId = "room-party";
  assert.equal(peakRoomOccupancy(rows), 1);
  rows[1].roomLabel = "Renamed";
  assert.equal(peakRoomOccupancy(rows), 1);
});

test("turnover, differing roommate dates and gaps conserve room nights", () => {
  assert.equal(peakRoomOccupancy([stay("a", 1, 3), stay("b", 3, 5)]), 1);
  const rows = [stay("a", 1, 3, {roomOccupancyId: "shared"}),
    stay("b", 5, 7, {roomOccupancyId: "shared"}), stay("c", 3, 5)];
  assert.equal(peakRoomOccupancy(rows), 1);
  rows.push(stay("d", 2, 6, {roomOccupancyId: "shared"}));
  assert.equal(peakRoomOccupancy(rows), 2);
});

test("unknown and malformed legacy dates never release capacity", () => {
  assert.equal(peakRoomOccupancy([stay("a", 3, 2), stay("b", 5, 7)]), 2);
  assert.equal(peakRoomOccupancy([stay("a", 1, 3,
    {startsAtMillis: null}), stay("b", 5, 7)]), 2);
  assert.deepEqual(validateRoomOccupancy([stay("a", 3, 2)], [block], "UTC"),
    ["invalidDates"]);
});

test("local nights survive daylight saving and time-of-day differences", () => {
  const a = {startsAtMillis: Date.parse("2026-03-07T15:00:00-05:00"),
    endsAtMillis: Date.parse("2026-03-09T11:00:00-04:00")};
  const interval = nightInterval(a, "America/New_York");
  assert.equal(interval[1] - interval[0], 2 * 86400000);
  const rows = [stay("a", 1, 2, a), stay("b", 1, 2, {
    startsAtMillis: Date.parse("2026-03-09T08:00:00-04:00"),
    endsAtMillis: Date.parse("2026-03-10T11:00:00-04:00"),
  })];
  assert.equal(peakRoomOccupancy(rows, "America/New_York"), 1);
});

test("independent validator rejects overlapping guests across hotels", () => {
  const rows = [stay("a", 1, 4), stay("b", 3, 5,
    {guestId: "a", hotelId: "other", roomBlockId: null})];
  assert.ok(validateRoomOccupancy(rows, [block], "UTC")
    .includes("duplicateGuest"));
  rows[1].startsAtMillis = day(4);
  assert.deepEqual(validateRoomOccupancy(rows, [block], "UTC"), []);
});

test("contract dates, occupancy and room quotas are hard constraints", () => {
  assert.ok(validateRoomOccupancy([stay("a", 1, 9)], [block], "UTC")
    .includes("outsideBlockDates"));
  const rows = ["a", "b", "c"].map((id) => stay(id, 1, 3));
  assert.ok(validateRoomOccupancy(rows, [block], "UTC")
    .includes("blockCapacity"));
  for (const row of rows) row.roomOccupancyId = "shared";
  assert.ok(validateRoomOccupancy(rows, [block], "UTC")
    .includes("roomCapacity"));
  rows[2].status = "cancelled";
  assert.deepEqual(validateRoomOccupancy(rows, [block], "UTC"), []);
  assert.ok(validateRoomOccupancy(rows,
    [{...block, maxOccupantsPerRoom: undefined}], "UTC")
    .includes("roomCapacity"));
});

test("an occupancy cannot occupy separate hotel or block identities", () => {
  const rows = [stay("a", 1, 3, {roomOccupancyId: "shared"}),
    stay("b", 3, 5, {roomOccupancyId: "shared", hotelId: "other"})];
  assert.ok(validateRoomOccupancy(rows, [block], "UTC")
    .includes("occupancyLocationConflict"));
});

test("tiny schedules agree with independent nightly enumeration", () => {
  const windows = [[1, 2], [1, 3], [2, 3], [2, 4], [3, 4]];
  const schedules = windows.flatMap((a) => windows.flatMap((b) =>
    windows.map((c) => [a, b, c])));
  for (const schedule of schedules) {
    for (let mask = 0; mask < 8; mask++) {
      const rows = schedule.map(([start, end], i) =>
        stay(String(i), start, end, {
          roomOccupancyId: (mask & (1 << i)) ? "shared" : `room-${i}`,
        }));
      const expected = Math.max(...[1, 2, 3].map((night) => new Set(rows
        .filter((row) => row.startsAtMillis! <= day(night) &&
          row.endsAtMillis! > day(night))
        .map((row) => row.roomOccupancyId)).size));
      assert.equal(peakRoomOccupancy(rows), expected);
    }
  }
});
