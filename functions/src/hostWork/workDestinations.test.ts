import assert from "node:assert/strict";
import test from "node:test";
import {
  mapEventRoleToDuty,
  resolveScopeDestinations,
  WORK_DESTINATIONS,
  type WorkScope,
} from "./workDestinations";

const programA: WorkScope = {kind: "program", id: "program-a"};
const eventA: WorkScope = {kind: "event", id: "event-a"};

test("a single duty resolves to its destinations in canonical order", () => {
  assert.deepEqual(resolveScopeDestinations(programA, [
    {duty: "functionCheckIn"},
  ]), {
    destinations: ["door", "walkIns"],
    overflow: [],
    shellMode: "tabs",
  });
  assert.deepEqual(resolveScopeDestinations(programA, [
    {duty: "stakeholderViewer"},
  ]), {
    destinations: ["overview"],
    overflow: [],
    shellMode: "task",
  });
});

test("no duties means no shell", () => {
  assert.deepEqual(resolveScopeDestinations(programA, []), {
    destinations: [],
    overflow: [],
    shellMode: "none",
  });
  assert.deepEqual(resolveScopeDestinations(eventA, [
    {duty: "someFutureDuty"},
  ]), {
    destinations: [],
    overflow: [],
    shellMode: "none",
  });
});

test("combined duties union destinations in canonical order", () => {
  const duties = [
    {duty: "guestRelations"},
    {duty: "hotelDesk"},
    {duty: "functionCheckIn"},
  ];
  const resolved = resolveScopeDestinations(programA, duties);
  assert.deepEqual(resolved.destinations, [
    "inbound", "rooms", "door", "walkIns", "guests", "rsvpInbox", "imports",
  ]);
  // More than three destinations: the bar keeps the first three and the
  // rest are reported as overflow for the assignment menu.
  assert.deepEqual(resolved.overflow, [
    "walkIns", "guests", "rsvpInbox", "imports",
  ]);
  assert.equal(resolved.shellMode, "tabs");
  // Duty order never changes the result.
  assert.deepEqual(
    resolveScopeDestinations(programA, [...duties].reverse()).destinations,
    resolved.destinations);
});

test("airportGreeter only reaches dispatch with a dispatcher grant", () => {
  assert.deepEqual(resolveScopeDestinations(programA, [
    {duty: "airportGreeter"},
  ]), {
    destinations: ["arrivals"],
    overflow: [],
    shellMode: "task",
  });
  assert.deepEqual(resolveScopeDestinations(programA, [
    {duty: "airportGreeter"}, {duty: "transportDispatcher"},
  ]), {
    destinations: ["arrivals", "dispatch"],
    overflow: [],
    shellMode: "tabs",
  });
  assert.deepEqual(resolveScopeDestinations(programA, [
    {duty: "transportDispatcher"},
  ]).destinations, ["arrivals", "dispatch"]);
});

test("programCoordinator switches to the program workspace shell", () => {
  assert.deepEqual(resolveScopeDestinations(programA, [
    {duty: "programCoordinator"},
  ]), {
    destinations: [],
    overflow: [],
    shellMode: "programWorkspace",
  });
  // The workspace is program-locked; extra duties still leave the bar empty.
  assert.deepEqual(resolveScopeDestinations(programA, [
    {duty: "programCoordinator"}, {duty: "hotelDesk"},
  ]), {
    destinations: [],
    overflow: [],
    shellMode: "programWorkspace",
  });
});

test("scopeIds restrict a duty to the named scopes", () => {
  const duties = [
    {duty: "hotelDesk", scopeIds: ["program-b"]},
    {duty: "functionCheckIn", scopeIds: ["program-a"]},
    {duty: "stakeholderViewer", scopeIds: []},
  ];
  assert.deepEqual(resolveScopeDestinations(programA, duties).destinations, [
    "door", "walkIns", "overview",
  ]);
  assert.deepEqual(resolveScopeDestinations(
    {kind: "program", id: "program-b"}, duties).destinations, [
    "inbound", "rooms", "overview",
  ]);
});

test("event scopes share the duty union", () => {
  assert.deepEqual(resolveScopeDestinations(eventA, [
    {duty: "functionCheckIn"},
  ]).destinations, ["door", "walkIns"]);
  assert.deepEqual(resolveScopeDestinations(eventA, [
    {duty: "eventLead"},
  ]), {
    destinations: ["nowNext", "door", "attention"],
    overflow: [],
    shellMode: "tabs",
  });
});

test("functionLead and eventLead share the lead destinations", () => {
  const lead = ["nowNext", "door", "attention"];
  assert.deepEqual(resolveScopeDestinations(programA, [
    {duty: "functionLead"},
  ]).destinations, lead);
  assert.deepEqual(resolveScopeDestinations(eventA, [
    {duty: "eventLead"},
  ]).destinations, lead);
});

test("wide multi-duty scopes keep all destinations plus overflow", () => {
  const resolved = resolveScopeDestinations(programA, [
    {duty: "functionLead"}, {duty: "reconciliationViewer"},
  ]);
  assert.deepEqual(resolved.destinations, [
    "nowNext", "door", "attention", "trips", "exceptions", "export",
  ]);
  assert.deepEqual(resolved.overflow, ["trips", "exceptions", "export"]);
  assert.equal(resolved.shellMode, "tabs");
});

test("mapEventRoleToDuty maps known roles and drops the rest", () => {
  assert.equal(mapEventRoleToDuty("checkInOperator"), "functionCheckIn");
  assert.equal(mapEventRoleToDuty("eventOperator"), "eventLead");
  assert.equal(mapEventRoleToDuty("organizerManager"), null);
  assert.equal(mapEventRoleToDuty(""), null);
});

test("canonical order covers every destination exactly once", () => {
  assert.equal(new Set(WORK_DESTINATIONS).size, WORK_DESTINATIONS.length);
});
