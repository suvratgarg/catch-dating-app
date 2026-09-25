import assert from "node:assert/strict";
import test from "node:test";
import {travelLegChangeEvents} from "./momentSchedule";

test("travelLegChangeEvents diffs readiness and flight status", () => {
  const events = travelLegChangeEvents("leg-1",
    {programId: "prog", readiness: "expected", flightStatus: "onTime"},
    {programId: "prog", readiness: "arrived", flightStatus: "cancelled"},
    1000);
  assert.equal(events.length, 2);
  assert.equal(events[0].kind, "travelLegReadinessChanged");
  assert.equal(events[0].readiness, "arrived");
  assert.equal(events[1].kind, "travelLegFlightStatusChanged");
  assert.equal(events[1].flightStatus, "cancelled");
  assert.equal(events[1].previousFlightStatus, "onTime");
});

test("unchanged fields and deletes produce no facts", () => {
  const leg = {programId: "prog", readiness: "arrived"};
  assert.equal(
    travelLegChangeEvents("leg-1", leg, leg, 1000).length, 0);
  assert.equal(
    travelLegChangeEvents("leg-1", leg, undefined, 1000).length, 0);
  assert.equal(
    travelLegChangeEvents("leg-1", undefined,
      {readiness: "arrived"}, 1000).length, 0);
});

test("a create (no before) emits facts with empty previous state", () => {
  const events = travelLegChangeEvents("leg-1", undefined,
    {programId: "prog", flightStatus: "cancelled"}, 1000);
  assert.equal(events.length, 1);
  assert.equal(events[0].kind, "travelLegFlightStatusChanged");
  assert.equal(events[0].previousFlightStatus, "");
});
