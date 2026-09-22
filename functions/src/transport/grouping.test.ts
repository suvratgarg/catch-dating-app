import assert from "node:assert/strict";
import test from "node:test";
import {suggestTransportGroups, type TransportParty,
  type VehicleClass} from "./grouping";

const vehicles: VehicleClass[] = [
  {id: "sedan", passengerCapacity: 4, luggageCapacity: 3, capabilities: []},
  {id: "mpv", passengerCapacity: 6, luggageCapacity: 6, capabilities: []},
  {id: "accessible", passengerCapacity: 6, luggageCapacity: 6,
    capabilities: ["wheelchair"]},
];
const policy = {windowMillis: 45, maxReadyWaitMillis: 20, nowMillis: 100};
const party = (id: string, changes: Partial<TransportParty> = {}):
TransportParty => ({id, programId: "wedding", pickupPointId: "airport-t1",
  destinationId: "hotel-a", readiness: "expected", availableAtMillis: 100,
  passengers: 1, luggageUnits: 1, requiredCapabilities: [],
  dedicatedVehicle: false, ...changes});
const suggest = (parties: TransportParty[], vehicleClasses = vehicles,
  changes: Partial<typeof policy> = {}) => suggestTransportGroups({
  parties, vehicleClasses, ...policy, ...changes,
});

test("same destination and time band share the smallest fitting class", () => {
  const result = suggest([party("a"), party("b"), party("c")]);
  assert.deepEqual(result.unassigned, []);
  assert.equal(result.groups.length, 1);
  assert.deepEqual(result.groups[0].partyIds, ["a", "b", "c"]);
  assert.equal(result.groups[0].vehicleClassId, "sedan");
  assert.equal(result.groups[0].passengers, 3);
  assert.equal(result.groups[0].luggageUnits, 3);
  assert.equal(result.groups[0].dispatchByMillis, null);
});

test("program, pickup, hotel and readiness are separate scopes", () => {
  const result = suggest([
    party("base"), party("other-program", {programId: "offsite"}),
    party("other-terminal", {pickupPointId: "airport-t2"}),
    party("other-airport", {pickupPointId: "other-airport"}),
    party("other-hotel", {destinationId: "hotel-b"}),
    party("ready", {readiness: "ready"}),
  ]);
  assert.equal(result.groups.length, 6);
  assert.ok(result.groups.every((group) => group.partyIds.length === 1));
});

test("windows are anchored, not transitively chained", () => {
  const result = suggest([party("a"), party("b", {availableAtMillis: 140}),
    party("c", {availableAtMillis: 180})]);
  assert.deepEqual(result.groups.map((group) => group.partyIds),
    [["a", "b"], ["c"]]);
  assert.equal(result.groups[0].earliestAtMillis, 100);
  assert.equal(result.groups[0].latestAtMillis, 140);
});

test("exact time-band boundaries are included", () => {
  const result = suggest([party("a"), party("b", {availableAtMillis: 145}),
    party("c", {availableAtMillis: 146})]);
  assert.deepEqual(result.groups.map((group) => group.partyIds),
    [["a", "b"], ["c"]]);
});

test("ready parties respect maximum wait even within a wider band", () => {
  const result = suggest([party("a", {readiness: "ready"}),
    party("b", {readiness: "ready", availableAtMillis: 120}),
    party("c", {readiness: "ready", availableAtMillis: 121})], vehicles,
  {nowMillis: 130});
  assert.deepEqual(result.groups.map((group) => group.partyIds),
    [["a", "b"], ["c"]]);
  assert.equal(result.groups[0].dispatchByMillis, 120);
  assert.equal(result.groups[0].waitOverdue, true);
  assert.equal(result.groups[1].waitOverdue, false);
});

test("a ready deadline reached now is flagged", () => {
  assert.equal(suggest([party("a", {readiness: "ready"})], vehicles,
    {nowMillis: 120}).groups[0].waitOverdue, true);
});

test("parties remain intact and oversized parties require review", () => {
  const result = suggest([party("family", {passengers: 5, luggageUnits: 4}),
    party("too-large", {passengers: 7})]);
  assert.equal(result.groups.length, 1);
  assert.deepEqual(result.groups[0].partyIds, ["family"]);
  assert.equal(result.groups[0].passengers, 5);
  assert.equal(result.groups[0].vehicleClassId, "mpv");
  assert.deepEqual(result.unassigned,
    [{partyId: "too-large", reason: "noSuitableVehicle"}]);
});

test("combined groups grow only while a class fits", () => {
  const result = suggest([party("a", {passengers: 3}),
    party("b", {passengers: 3}), party("c")]);
  assert.deepEqual(result.groups.map((group) => group.partyIds),
    [["a", "b"], ["c"]]);
  assert.equal(result.groups[0].passengers, 6);
});

test("luggage can require a larger class even with spare seats", () => {
  const result = suggest([party("a", {luggageUnits: 4})]);
  assert.equal(result.groups[0].luggageUnits, 4);
  assert.notEqual(result.groups[0].vehicleClassId, "sedan");
  assert.deepEqual(suggest([party("b", {luggageUnits: 7})]).unassigned,
    [{partyId: "b", reason: "noSuitableVehicle"}]);
});

test("vehicle capabilities are required, not preference hints", () => {
  const result = suggest([party("a", {requiredCapabilities: ["wheelchair"]})]);
  assert.equal(result.groups[0].vehicleClassId, "accessible");
  assert.deepEqual(suggest([party("b", {
    requiredCapabilities: ["wheelchair", "child-seat"],
  })]).unassigned, [{partyId: "b", reason: "noSuitableVehicle"}]);
});

test("dedicated vehicle parties cannot collect other passengers", () => {
  const result = suggest([party("a"),
    party("b", {dedicatedVehicle: true}), party("c")]);
  const dedicated = result.groups.find((group) => group.partyIds.includes("b"));
  assert.deepEqual(dedicated?.partyIds, ["b"]);
});

test("missing timing and unavailable fleet stay explicitly unassigned", () => {
  assert.deepEqual(suggest([party("a", {availableAtMillis: null})]).unassigned,
    [{partyId: "a", reason: "missingTime"}]);
  assert.deepEqual(suggest([party("b")], []).unassigned,
    [{partyId: "b", reason: "noSuitableVehicle"}]);
  assert.deepEqual(suggest([], []), {groups: [], unassigned: []});
});

test("equal inputs have stable output independent of input ordering", () => {
  const parties = [party("c"), party("a"), party("b"),
    party("d", {destinationId: "hotel-b"})];
  const original = structuredClone({parties, vehicles});
  assert.deepEqual(suggest(parties),
    suggest([...parties].reverse(), [...vehicles].reverse()));
  assert.deepEqual({parties, vehicles}, original);
});

test("invalid numbers, duplicate ids and empty scopes are rejected", () => {
  for (const value of [-1, NaN, Infinity, 0.5, Number.MAX_SAFE_INTEGER + 1]) {
    assert.throws(() => suggest([party("a", {passengers: value})]), RangeError);
    assert.throws(() => suggest([party("a", {luggageUnits: value})]),
      RangeError);
    assert.throws(() => suggest([party("a", {availableAtMillis: value})]),
      RangeError);
    assert.throws(() => suggest([], vehicles, {windowMillis: value}),
      RangeError);
    assert.throws(() => suggest([], vehicles, {maxReadyWaitMillis: value}),
      RangeError);
    assert.throws(() => suggest([], vehicles, {nowMillis: value}), RangeError);
  }
  assert.throws(() => suggest([party("a", {passengers: 0})]), RangeError);
  assert.throws(() => suggest([party("a"), party("a")]), TypeError);
  assert.throws(() => suggest([], [vehicles[0], vehicles[0]]), TypeError);
  assert.throws(() => suggest([party("a", {programId: ""})]), TypeError);
  assert.throws(() => suggest([party("a", {pickupPointId: " "})]), TypeError);
  assert.throws(() => suggest([party("a")], [{...vehicles[0],
    passengerCapacity: 0}]), RangeError);
});

test("future ready observations and overflowing deadlines fail", () => {
  assert.throws(() => suggest([party("a", {readiness: "ready",
    availableAtMillis: 101})]), RangeError);
  assert.throws(() => suggest([party("a", {readiness: "ready",
    availableAtMillis: Number.MAX_SAFE_INTEGER})], vehicles,
  {nowMillis: Number.MAX_SAFE_INTEGER}), RangeError);
});

test("zero wait groups only simultaneously ready parties", () => {
  const result = suggest([party("a", {readiness: "ready"}),
    party("b", {readiness: "ready", availableAtMillis: 101})], vehicles,
  {nowMillis: 101, maxReadyWaitMillis: 0});
  assert.equal(result.groups.length, 2);
  assert.ok(result.groups.every((group) => group.waitOverdue));
});

test("planning refuses inputs larger than its declared bounds", () => {
  assert.throws(() => suggest(Array.from({length: 5001}, (_, i) =>
    party(`party-${i}`))), RangeError);
  assert.throws(() => suggest([], Array.from({length: 65}, (_, i) =>
    ({...vehicles[0], id: `vehicle-${i}`}))), RangeError);
});

test("generated manifests preserve parties and capacity invariants", () => {
  const parties = Array.from({length: 250}, (_, i) => party(`party-${i}`, {
    programId: `program-${i % 2}`, pickupPointId: `airport-${i % 3}`,
    destinationId: `hotel-${i % 4}`, passengers: i % 7 + 1,
    luggageUnits: i % 8, availableAtMillis: 100 + i % 90,
    dedicatedVehicle: i % 11 === 0,
    requiredCapabilities: i % 9 === 0 ? ["wheelchair"] : [],
  }));
  const result = suggest(parties);
  const ids = [...result.groups.flatMap((group) => group.partyIds),
    ...result.unassigned.map((row) => row.partyId)];
  assert.equal(new Set(ids).size, parties.length);
  assert.equal(ids.length, parties.length);
  for (const group of result.groups) {
    const members = parties.filter((row) => group.partyIds.includes(row.id));
    const vehicle = vehicles.find((row) => row.id === group.vehicleClassId)!;
    assert.ok(group.passengers <= vehicle.passengerCapacity);
    assert.ok(group.luggageUnits <= vehicle.luggageCapacity);
    assert.ok(group.latestAtMillis - group.earliestAtMillis <= 45);
    assert.equal(group.passengers,
      members.reduce((sum, row) => sum + row.passengers, 0));
    for (const member of members) {
      assert.equal(member.programId, group.programId);
      assert.equal(member.pickupPointId, group.pickupPointId);
      assert.equal(member.destinationId, group.destinationId);
      assert.ok(member.requiredCapabilities.every((capability) =>
        vehicle.capabilities.includes(capability)));
      if (member.dedicatedVehicle) assert.equal(members.length, 1);
    }
  }
});

test("a late-ready party member never resets the first member's wait", () => {
  const result = suggest([party("together", {readiness: "ready",
    availableAtMillis: 100, earliestReadyAtMillis: 60})]);
  assert.equal(result.groups[0].dispatchByMillis, 80);
  assert.equal(result.groups[0].waitOverdue, true);
});

test("an older observation advances the combined group deadline", () => {
  const result = suggest([party("first", {readiness: "ready",
    availableAtMillis: 90}), party("second", {readiness: "ready",
    availableAtMillis: 100, earliestReadyAtMillis: 50})]);
  assert.equal(result.groups.length, 1);
  assert.equal(result.groups[0].dispatchByMillis, 70);
  assert.equal(result.groups[0].waitOverdue, true);
});

test("large vehicles still obey the 50-journey dispatch contract", () => {
  const bus = {id: "bus", passengerCapacity: 200, luggageCapacity: 500,
    capabilities: []};
  const result = suggest(Array.from({length: 110}, (_, i) => party(`p-${i}`)),
    [bus]);
  assert.deepEqual(result.groups.map((group) => group.partyIds.length),
    [50, 50, 10]);
  const grouped = suggest([party("a", {legCount: 30, passengers: 30}),
    party("b", {legCount: 30, passengers: 30})], [bus]);
  assert.equal(grouped.groups.length, 2);
});
