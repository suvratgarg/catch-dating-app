import assert from "node:assert/strict";
import test from "node:test";
import {
  evaluateCondition,
  type TravelLegEvent,
} from "./momentConditions";
import type {AnchorFacts, MomentDefinition} from "./momentModel";

const facts: AnchorFacts = {
  scope: {
    startsAtMillis: 1_000_000,
    endsAtMillis: null,
    cancelled: false,
    rsvpDeadlineAtMillis: null,
    revision: 1,
    messagingEnabled: true,
  },
  functions: {
    haldi: {
      startsAtMillis: 1_500_000,
      endsAtMillis: 1_800_000,
      revision: 2,
      cancelled: false,
    },
    sangeet: {
      startsAtMillis: 2_000_000,
      endsAtMillis: 2_400_000,
      revision: 7,
      cancelled: false,
    },
    mehendi: {
      startsAtMillis: 1_900_000,
      endsAtMillis: 2_100_000,
      revision: 5,
      cancelled: true,
    },
  },
  travelLegs: {},
};

const lateArrival: MomentDefinition = {
  momentId: "mLate",
  scope: {kind: "program", programId: "prog"},
  name: "Late arrival alert",
  sense: "individual",
  initiation: {
    kind: "triggered",
    triggerKind: "lateArrivalAtHotel",
    functionId: "sangeet",
  },
  audience: {kind: "staffDuty", duty: "functionCheckIn", scopeIds: null},
  action: {
    kind: "staffAttention",
    duty: "functionCheckIn",
    severity: "warning",
    titleTemplate: "Meet at gate",
  },
  status: "armed",
  approval: {approvedByUid: "mgr", approvedAtMillis: 1},
  origin: "organizer",
  revision: 1,
};

const arrived: TravelLegEvent = {
  kind: "travelLegReadinessChanged",
  legId: "leg1",
  programId: "prog",
  previousReadiness: "enRoute",
  readiness: "arrived",
  observedAtMillis: 2_100_000,
};

test("late arrival fires inside the targeted function window", () => {
  const result = evaluateCondition(lateArrival, arrived, facts, 2_100_000);
  assert.equal(result.kind, "fire");
  assert.deepEqual(result.kind === "fire" && result.run, {
    runId: "mLate_leg1_arrived",
    momentId: "mLate",
    dueAtMillis: 2_100_000,
    anchorRevision: 7,
    status: "planned",
    targetFunctionId: "sangeet",
    subjectId: "leg1",
  });
});

test("null functionId resolves the current function", () => {
  const floating = {...lateArrival, initiation: {
    kind: "triggered" as const,
    triggerKind: "lateArrivalAtHotel" as const,
    functionId: null,
  }};
  const result = evaluateCondition(floating, arrived, facts, 2_100_000);
  // sangeet 2_000_000-2_400_000 is the only live window; mehendi cancelled.
  assert.equal(result.kind, "fire");
  if (result.kind === "fire") {
    assert.equal(result.run.anchorRevision, 7);
    assert.equal(result.run.targetFunctionId, "sangeet");
  }
});

test("arrival before start, with no live function, or cancelled", () => {
  assert.deepEqual(evaluateCondition(lateArrival, arrived, facts,
    1_950_000), {kind: "noFire", reason: "functionNotStarted"});
  const floating = {...lateArrival, initiation: {
    kind: "triggered" as const,
    triggerKind: "lateArrivalAtHotel" as const,
    functionId: null,
  }};
  assert.deepEqual(evaluateCondition(floating, arrived, facts, 900_000),
    {kind: "noFire", reason: "noCurrentFunction"});
  const deadFn = {...lateArrival, initiation: {
    kind: "triggered" as const,
    triggerKind: "lateArrivalAtHotel" as const,
    functionId: "mehendi",
  }};
  assert.deepEqual(evaluateCondition(deadFn, arrived, facts, 2_000_000),
    {kind: "noFire", reason: "functionCancelled"});
});

test("arrived to arrived and wrong program never fire", () => {
  assert.deepEqual(evaluateCondition(lateArrival, {...arrived,
    previousReadiness: "arrived"}, facts, 2_100_000),
  {kind: "noFire", reason: "eventNotMatching"});
  assert.deepEqual(evaluateCondition(lateArrival, {...arrived,
    programId: "other"}, facts, 2_100_000),
  {kind: "noFire", reason: "scopeMismatch"});
  assert.deepEqual(evaluateCondition(lateArrival, {...arrived,
    kind: "travelLegFlightStatusChanged", previousFlightStatus: "x",
    flightStatus: "y"} as TravelLegEvent, facts, 2_100_000),
  {kind: "noFire", reason: "eventNotMatching"});
});

test("flight disruption fires only on transition into the bad set", () => {
  const flightMoment: MomentDefinition = {...lateArrival, initiation: {
    kind: "triggered",
    triggerKind: "flightDisrupted",
    functionId: null,
  }};
  for (const flightStatus of ["cancelled", "diverted"] as const) {
    const event: TravelLegEvent = {
      kind: "travelLegFlightStatusChanged", legId: "leg9",
      programId: "prog", previousFlightStatus: "delayed",
      flightStatus, observedAtMillis: 2_100_000,
    };
    const result = evaluateCondition(flightMoment, event, facts, 2_100_000);
    assert.equal(result.kind, "fire");
    if (result.kind === "fire") {
      assert.equal(result.run.runId, `mLate_leg9_${flightStatus}`);
      assert.equal(result.run.anchorRevision, 0);
      assert.equal(result.run.targetFunctionId, undefined);
    }
  }
  const delayed: TravelLegEvent = {
    kind: "travelLegFlightStatusChanged", legId: "leg9",
    programId: "prog", previousFlightStatus: "scheduled",
    flightStatus: "delayed", observedAtMillis: 2_100_000,
  };
  assert.deepEqual(evaluateCondition(flightMoment, delayed, facts,
    2_100_000), {kind: "noFire", reason: "eventNotMatching"});
  const churn: TravelLegEvent = {...delayed,
    previousFlightStatus: "cancelled", flightStatus: "diverted"};
  assert.deepEqual(evaluateCondition(flightMoment, churn, facts, 2_100_000),
    {kind: "noFire", reason: "eventNotMatching"});
});

test("time-anchored and unarmed moments never fire on events", () => {
  const timed: MomentDefinition = {...lateArrival, initiation: {
    kind: "anchored", anchorKind: "functionStart", anchorId: "sangeet",
    offsetMinutes: 0,
  }};
  assert.deepEqual(evaluateCondition(timed, arrived, facts, 2_100_000),
    {kind: "noFire", reason: "notTriggered"});
  assert.deepEqual(evaluateCondition({...lateArrival, status: "draft"},
    arrived, facts, 2_100_000), {kind: "noFire", reason: "notArmed"});
});

test("condition runs are deterministic across evaluations", () => {
  const first = evaluateCondition(lateArrival, arrived, facts, 2_100_000);
  const second = evaluateCondition(lateArrival, arrived, facts, 2_100_000);
  assert.deepEqual(first, second);
});
