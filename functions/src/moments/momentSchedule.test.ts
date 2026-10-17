import assert from "node:assert/strict";
import test, {mock} from "node:test";
import {ingestTravelFacts, programTravelLegMoments, travelLegChangeEvents}
  from "./momentSchedule";
import * as runner from "./momentRunner";
import * as wiring from "./momentWiring";
import type {TravelLegEvent} from "./momentConditions";

const identity = {source: "travel", eventId: "event-1"};

test("travelLegChangeEvents diffs readiness and flight status", () => {
  const events = travelLegChangeEvents("leg-1",
    {programId: "prog", readiness: "expected", flightStatus: "onTime"},
    {programId: "prog", readiness: "arrived", flightStatus: "cancelled"},
    1000, {source: "travel", eventId: "event-1"});
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
    travelLegChangeEvents("leg-1", leg, leg, 1000, identity).length, 0);
  assert.equal(
    travelLegChangeEvents("leg-1", leg, undefined, 1000, identity).length, 0);
  assert.equal(
    travelLegChangeEvents("leg-1", undefined,
      {readiness: "arrived"}, 1000, identity).length, 0);
});

test("a create (no before) emits facts with empty previous state", () => {
  const events = travelLegChangeEvents("leg-1", undefined,
    {programId: "prog", flightStatus: "cancelled"}, 1000, identity);
  assert.equal(events.length, 1);
  assert.equal(events[0].kind, "travelLegFlightStatusChanged");
  assert.equal(events[0].previousFlightStatus, "");
});

for (const failKind of ["travelLegReadinessChanged",
  "travelLegFlightStatusChanged"]) {
  test(`both facts attempted after ${failKind} fails`, async () => {
    const facts = travelLegChangeEvents("leg-1", undefined,
      {programId: "prog", readiness: "arrived", flightStatus: "cancelled"},
      1000, {source: "travel", eventId: "event-1"});
    const attempted: string[] = [];
    await assert.rejects(ingestTravelFacts(facts, async (fact) => {
      attempted.push(fact.kind);
      if (fact.kind === failKind) throw new Error("persistence unavailable");
    }), /Travel fact ingestion incomplete/);
    assert.deepEqual(attempted, facts.map((fact) => fact.kind));
    const recovered: string[] = [];
    await ingestTravelFacts(facts, async (fact) => {
      recovered.push(fact.kind);
    });
    assert.deepEqual(recovered, attempted);
  });
}

test("exported trigger forwards immutable CloudEvent facts and rejects failure",
  async () => {
    const facts: TravelLegEvent[] = [];
    const deps = {} as runner.MomentRunnerDeps;
    const build = mock.method(wiring, "buildMomentRunnerDeps", () => deps);
    const ingest = mock.method(runner, "ingestTravelLegEvent",
      async (received: runner.MomentRunnerDeps, fact: TravelLegEvent) => {
        assert.equal(received, deps);
        facts.push(fact);
        if (fact.kind === "travelLegReadinessChanged") {
          throw new Error("pre-run persistence unavailable");
        }
        return {firedRuns: 1};
      });
    try {
      await assert.rejects(programTravelLegMoments.run({
        id: "cloud-event-id", source: "//firestore/projects/synthetic",
        time: "2026-10-17T00:00:00.000Z", params: {legId: "leg-1"},
        data: {before: {data: () => ({programId: "prog"})},
          after: {data: () => ({programId: "prog", readiness: "arrived",
            flightStatus: "cancelled"})}},
      } as never), /Travel fact ingestion incomplete/);
      assert.equal(facts.length, 2);
      assert.deepEqual(facts.map((fact) => [fact.source, fact.eventId,
        fact.observedAtMillis]), Array(2).fill([
        "//firestore/projects/synthetic", "cloud-event-id",
        Date.parse("2026-10-17T00:00:00.000Z"),
      ]));
    } finally {
      ingest.mock.restore();
      build.mock.restore();
    }
  });
