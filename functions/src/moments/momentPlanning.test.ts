import assert from "node:assert/strict";
import test from "node:test";
import {
  planRun,
  replan,
  resolveAnchor,
  resolveFireDisposition,
  selectDueRuns,
  shiftLocalCalendar,
} from "./momentPlanning";
import {buildTravelContext} from "./momentTravel";
import type {
  AnchorFacts,
  MomentDefinition,
  RunRecord,
} from "./momentModel";

const facts: AnchorFacts = {
  scope: {
    startsAtMillis: 1_000_000,
    endsAtMillis: 2_500_000,
    cancelled: false,
    rsvpDeadlineAtMillis: 500_000,
    revision: 3,
    messagingEnabled: true,
  },
  functions: {
    sangeet: {
      startsAtMillis: 2_000_000,
      endsAtMillis: 2_400_000,
      revision: 7,
      cancelled: false,
    },
    haldi: {
      startsAtMillis: 1_500_000,
      endsAtMillis: 1_800_000,
      revision: 2,
      cancelled: true,
    },
  },
  travelLegs: {
    udrT1: {atMillis: 1_700_000, revision: 4},
  },
};

const baseMoment: MomentDefinition = {
  momentId: "m1",
  scope: {kind: "program", programId: "prog"},
  name: "Sangeet starts soon",
  sense: "audience",
  initiation: {
    kind: "anchored",
    anchorKind: "functionStart",
    anchorId: "sangeet",
    offsetMinutes: -15,
  },
  audience: {
    kind: "functionGuests",
    functionId: "sangeet",
    rsvp: ["attending", "maybe"],
    householdDedupe: true, travelTimeLead: false,
  },
  action: {
    kind: "sendTemplate",
    connectionId: "conn1",
    templateId: "tpl",
    variables: {},
  },
  status: "armed",
  approval: {approvedByUid: "mgr", approvedAtMillis: 1},
  origin: "organizer",
  revision: 1,
};

test("functionStart minus 15 minutes plans a deterministic run", () => {
  const result = planRun(baseMoment, facts, 0);
  assert.equal(result.kind, "planned");
  assert.deepEqual(result.kind === "planned" && result.run, {
    runId: "m1_7_1100000",
    momentId: "m1",
    dueAtMillis: 1_100_000,
    // Scheduled occurrence time and the anchor-bound expiry are separate
    // identity axes from the mutable wake time.
    nominalDueAtMillis: 1_100_000,
    expiresAtMillis: 2_000_000,
    occurrenceVersion: 2,
    anchorRevision: 7,
    status: "planned",
  });
});

test("functionEnd, programStart, rsvpDeadline and departure anchors", () => {
  const cases: Array<[MomentDefinition["initiation"], number, number]> = [
    [{kind: "anchored", anchorKind: "functionEnd", anchorId: "sangeet",
      offsetMinutes: 30}, 4_200_000, 7],
    [{kind: "anchored", anchorKind: "scopeStart", anchorId: null,
      offsetMinutes: 0}, 1_000_000, 3],
    [{kind: "anchored", anchorKind: "rsvpDeadline", anchorId: null,
      offsetMinutes: 0}, 500_000, 3],
    [{kind: "anchored", anchorKind: "travelLegTime",
      anchorId: "udrT1", offsetMinutes: -10}, 1_100_000, 4],
  ];
  for (const [initiation, dueAtMillis, revision] of cases) {
    const result = planRun({...baseMoment, initiation}, facts, 0);
    assert.equal(result.kind, "planned");
    if (result.kind === "planned") {
      assert.equal(result.run.dueAtMillis, dueAtMillis);
      assert.equal(result.run.anchorRevision, revision);
    }
  }
});

test("missing anchors resolve explicitly", () => {
  assert.deepEqual(resolveAnchor({kind: "anchored",
    anchorKind: "functionStart", anchorId: "nope", offsetMinutes: 0}, facts), {
    kind: "unresolved", reason: "missingAnchor",
  });
  const noDeadline: AnchorFacts = {...facts, scope: {
    ...facts.scope, rsvpDeadlineAtMillis: null,
  }};
  assert.deepEqual(resolveAnchor({kind: "anchored",
    anchorKind: "rsvpDeadline", anchorId: null, offsetMinutes: 0},
  noDeadline), {kind: "unresolved", reason: "missingAnchor"});
  assert.deepEqual(planRun({...baseMoment, initiation: {
    kind: "anchored", anchorKind: "functionStart", anchorId: "haldi",
    offsetMinutes: 0,
  }}, facts, 0), {kind: "unplannable", reason: "anchorCancelled"});
  assert.deepEqual(planRun({...baseMoment, initiation: {
    kind: "triggered", triggerKind: "lateArrivalAtHotel",
    functionId: null,
  }}, facts, 0), {kind: "unplannable", reason: "triggeredInitiation"});
});

test("draft and paused moments never plan", () => {
  for (const status of ["draft", "paused", "done"] as const) {
    assert.deepEqual(planRun({...baseMoment, status}, facts, 0),
      {kind: "unplannable", reason: "notArmed"});
  }
});

test("dueInPast respects the grace boundary exactly", () => {
  // dueAt = 1_100_000; grace 5 min -> dueInPast once now > 1_400_000.
  assert.equal(planRun(baseMoment, facts, 1_400_000).kind, "planned");
  assert.deepEqual(planRun(baseMoment, facts, 1_400_001),
    {kind: "unplannable", reason: "dueInPast"});
  assert.equal(planRun(baseMoment, facts, 2_000_000,
    {graceMillis: 900_000}).kind, "planned");
});

test("invalid millis and overflowing due times fail", () => {
  for (const invalid of [-1, NaN, Infinity, 0.5]) {
    assert.throws(() => planRun(baseMoment, facts, invalid), RangeError);
    assert.throws(() => planRun(baseMoment, facts, 0,
      {graceMillis: invalid}), RangeError);
  }
  assert.throws(() => planRun({...baseMoment, initiation: {
    kind: "anchored", anchorKind: "functionStart", anchorId: "sangeet",
    offsetMinutes: -34_000_000_000,
  }}, facts, 0), RangeError);
});

function run(partial: Partial<RunRecord>): RunRecord {
  return {
    runId: "r", momentId: "m1", dueAtMillis: 1_100_000,
    anchorRevision: 7, status: "planned", ...partial,
  };
}

test("replan keeps an identical run and supersedes moved anchors", () => {
  const existing = run({runId: "m1_7_1100000"});
  assert.deepEqual(replan(baseMoment, facts, [existing], 0), {
    supersede: [], create: null, keep: ["m1_7_1100000"],
    reschedule: [],
  });
  const moved: AnchorFacts = {...facts, functions: {...facts.functions,
    sangeet: {...facts.functions.sangeet, startsAtMillis: 2_060_000,
      revision: 8}}};
  const next = replan(baseMoment, moved, [existing], 0);
  assert.deepEqual(next.supersede, ["m1_7_1100000"]);
  assert.deepEqual(next.keep, []);
  assert.equal(next.create?.runId, "m1_8_1160000");
  assert.equal(next.create?.anchorRevision, 8);
});

test("replan never touches non-planned runs", () => {
  const settled = [
    run({runId: "d1", status: "dispatched"}),
    run({runId: "f1", status: "failed"}),
    run({runId: "s1", status: "skipped"}),
    run({runId: "x1", status: "superseded"}),
    run({runId: "other_moment_1_1", momentId: "other"}),
  ];
  const moved: AnchorFacts = {...facts, functions: {...facts.functions,
    sangeet: {...facts.functions.sangeet, startsAtMillis: 2_060_000,
      revision: 8}}};
  const next = replan(baseMoment, moved, [...settled,
    run({runId: "old"})], 0);
  assert.deepEqual(next.supersede, ["old"]);
});

test("unplannable replan supersedes all planned runs with a reason", () => {
  const paused = {...baseMoment, status: "paused" as const};
  assert.deepEqual(replan(paused, facts, [run({runId: "a"}),
    run({runId: "b"})], 0), {
    supersede: ["a", "b"], create: null, keep: [], reschedule: [],
    unplannableReason: "notArmed",
  });
});

test("selectDueRuns sorts by due time then id and caps at limit", () => {
  const runs = [
    run({runId: "b", dueAtMillis: 10}),
    run({runId: "a", dueAtMillis: 10}),
    run({runId: "c", dueAtMillis: 5}),
    run({runId: "future", dueAtMillis: 100}),
    run({runId: "done", dueAtMillis: 1, status: "dispatched"}),
  ];
  assert.deepEqual(selectDueRuns(runs, 50, 10).map((r) => r.runId),
    ["c", "a", "b"]);
  assert.deepEqual(selectDueRuns(runs, 50, 2).map((r) => r.runId),
    ["c", "a"]);
  for (const bad of [0, -1, 1.5, NaN]) {
    assert.throws(() => selectDueRuns(runs, 50, bad), RangeError);
  }
});

test("resolveFireDisposition checks each guard in order", () => {
  const good = run({runId: "m1_7_1100000"});
  assert.equal(resolveFireDisposition(good, baseMoment, facts), "dispatch");
  assert.equal(resolveFireDisposition(good, {...baseMoment,
    status: "paused"}, facts), "skip:momentNotArmed");
  const silent: AnchorFacts = {...facts, scope: {...facts.scope,
    messagingEnabled: false}};
  assert.equal(resolveFireDisposition(good, baseMoment, silent),
    "skip:messagingDisabled");
  // staffAttention dispatches even with messaging disabled.
  const attention: MomentDefinition = {...baseMoment, action: {
    kind: "staffAttention", duty: "functionCheckIn", severity: "warning",
    titleTemplate: "late",
  }};
  assert.equal(resolveFireDisposition(good, attention, silent), "dispatch");
  // Cancelled audience function skips even when armed.
  const cancelledFn = {...baseMoment, initiation: {
    kind: "anchored" as const, anchorKind: "scopeStart" as const,
    anchorId: null, offsetMinutes: 0,
  }, audience: {...baseMoment.audience, functionId: "haldi"}};
  const haldiRun = run({anchorRevision: 3});
  assert.equal(resolveFireDisposition(haldiRun, cancelledFn, facts),
    "skip:functionCancelled");
  // Anchor revision moved since planning -> stale.
  const moved: AnchorFacts = {...facts, functions: {...facts.functions,
    sangeet: {...facts.functions.sangeet, revision: 8}}};
  assert.equal(resolveFireDisposition(good, baseMoment, moved),
    "skip:staleAnchor");
});

test("travelTimeLead wakes the run early by the farthest hotel's lead",
  () => {
    const venue = {latitude: 26.9, longitude: 75.8};
    const travelFacts: AnchorFacts = {...facts, functions: {
      ...facts.functions,
      sangeet: {...facts.functions.sangeet, venueLocation: venue},
    }, travel: {
      groupHotelIds: {sideA: "hotelFar"},
      hotelLocations: {hotelFar: {latitude: 27.5, longitude: 76.4}},
    }};
    const leadMoment: MomentDefinition = {...baseMoment, audience: {
      kind: "functionGuests", functionId: "sangeet",
      rsvp: ["attending", "maybe"], householdDedupe: true,
      travelTimeLead: true,
    }};
    const travel = buildTravelContext(leadMoment, travelFacts, () => 10);
    // nominal = 2_000_000 - 900_000 = 1_100_000; due = nominal - 10m.
    const result = planRun(leadMoment, travelFacts, 0, {travel});
    assert.deepEqual(result.kind === "planned" && result.run, {
      runId: "m1_7_1100000",
      momentId: "m1", dueAtMillis: 500_000,
      nominalDueAtMillis: 1_100_000, expiresAtMillis: 2_000_000,
      occurrenceVersion: 2,
      plannedWakeAtMillis: 500_000, anchorRevision: 7,
      status: "planned",
    });
    // The occurrence id is stable while the wake moves with the estimate.
    const planned = [result.kind === "planned" ? result.run : run({})];
    const nearer = planRun(leadMoment, travelFacts, 0,
      {travel: buildTravelContext(leadMoment, travelFacts, () => 5)});
    const move = replan(leadMoment, travelFacts, planned, 0,
      {travel: buildTravelContext(leadMoment, travelFacts, () => 5),
        travelPlanHash: "changed"});
    assert.equal(nearer.kind === "planned" && nearer.run.dueAtMillis,
      800_000);
    assert.deepEqual(move.supersede, []);
    assert.deepEqual(move.reschedule, [{
      runId: "m1_7_1100000", dueAtMillis: 800_000,
      plannedWakeAtMillis: 800_000, travelPlanHash: "changed",
    }]);
    // The flag-off twin ignores the same context.
    const off = planRun(baseMoment, travelFacts, 0, {travel});
    assert.equal(off.kind === "planned" && off.run.dueAtMillis, 1_100_000);
  });

test("condition runs ignore the stale-anchor fence", () => {
  const condition: MomentDefinition = {...baseMoment, initiation: {
    kind: "triggered", triggerKind: "lateArrivalAtHotel",
    functionId: null,
  }, audience: {kind: "staffDuty", duty: "functionCheckIn",
    scopeIds: null}, action: {kind: "staffAttention",
    duty: "functionCheckIn", severity: "warning",
    titleTemplate: "late"}};
  // anchorRevision 3 while every fact entity sits at a newer revision.
  const eventRun = run({anchorRevision: 3});
  assert.equal(resolveFireDisposition(eventRun, condition, facts),
    "dispatch");
  const cancelledAudience: MomentDefinition = {...condition, audience: {
    kind: "functionGuests", functionId: "haldi",
    rsvp: ["attending"], householdDedupe: true, travelTimeLead: false,
  }};
  assert.equal(resolveFireDisposition(eventRun, cancelledAudience, facts),
    "skip:functionCancelled");
  const silent: AnchorFacts = {...facts, scope: {...facts.scope,
    messagingEnabled: false}};
  assert.equal(resolveFireDisposition(eventRun, condition, silent),
    "dispatch"); // staffAttention is not a message
  const conditionTemplate: MomentDefinition = {...condition,
    action: baseMoment.action};
  assert.equal(resolveFireDisposition(eventRun, conditionTemplate, silent),
    "skip:messagingDisabled");
});

// --- Long-horizon scheduling ------------------------------------------------

test("calendar offsets shift the wall clock, not the elapsed time", () => {
  // Sangeet at 2026-02-14 18:30 in Asia/Kolkata (UTC+5:30, no DST).
  const sangeetAt = Date.UTC(2026, 1, 14, 13, 0, 0);
  const kolkata: AnchorFacts = {...facts, scope: {...facts.scope,
    timeZone: "Asia/Kolkata"}, functions: {...facts.functions,
    sangeet: {...facts.functions.sangeet, startsAtMillis: sangeetAt}}};
  const threeMonths = planRun({...baseMoment, initiation: {
    kind: "anchored", anchorKind: "functionStart", anchorId: "sangeet",
    offsetMinutes: 0, offsetMonths: -3,
  }}, kolkata, 0);
  // Three calendar months before: 2025-11-14 18:30 IST — same wall clock.
  assert.equal(threeMonths.kind === "planned" &&
    threeMonths.run.nominalDueAtMillis, Date.UTC(2025, 10, 14, 13, 0, 0));
  const ninetyDays = planRun({...baseMoment, initiation: {
    kind: "anchored", anchorKind: "functionStart", anchorId: "sangeet",
    offsetMinutes: 0, offsetDays: -90,
  }}, kolkata, 0);
  // Ninety calendar days before: 2025-11-16 18:30 IST.
  assert.equal(ninetyDays.kind === "planned" &&
    ninetyDays.run.nominalDueAtMillis, Date.UTC(2025, 10, 16, 13, 0, 0));
});

test("calendar months clamp the day and preserve time across DST", () => {
  // Jan 31 minus one month -> Dec 31; plus one month -> Feb 28.
  const jan31 = Date.UTC(2026, 0, 31, 10, 0, 0);
  assert.equal(shiftLocalCalendar(jan31, -1, 0, "UTC"),
    Date.UTC(2025, 11, 31, 10, 0, 0));
  assert.equal(shiftLocalCalendar(jan31, 1, 0, "UTC"),
    Date.UTC(2026, 1, 28, 10, 0, 0));
  // 2026-03-10 09:00 EDT minus three days -> 2026-03-07 09:00 EST: the
  // local wall clock holds while the UTC instant shifts an hour across
  // the spring-forward boundary.
  const afterSpringForward = Date.UTC(2026, 2, 10, 13, 0, 0);
  assert.equal(
    shiftLocalCalendar(afterSpringForward, 0, -3, "America/New_York"),
    Date.UTC(2026, 2, 7, 14, 0, 0));
});

test("replan keeps a live run past planning grace", () => {
  // The reproduced defect: a quiet-hours-deferred run whose nominal due
  // passed the five-minute grace used to be superseded into oblivion.
  // Expiry — not planning grace — decides whether it still fires.
  const deferred = run({runId: "m1_7_1100000", dueAtMillis: 1_700_000,
    nominalDueAtMillis: 1_100_000, expiresAtMillis: 2_000_000});
  const result = replan(baseMoment, facts, [deferred], 1_600_000);
  assert.deepEqual(result.supersede, []);
  assert.deepEqual(result.keep, ["m1_7_1100000"]);
  assert.equal(result.create, null);
  // An occurrence that never materialized is still not created late.
  const fresh = replan(baseMoment, facts, [], 1_600_000);
  assert.equal(fresh.create, null);
  assert.equal(fresh.unplannableReason, "dueInPast");
});

test("expiry is explicit per run: pre-anchor dies at the anchor", () => {
  const before = planRun(baseMoment, facts, 0);
  assert.equal(before.kind === "planned" &&
    before.run.expiresAtMillis, 2_000_000);
  // A post-anchor send stays useful up to a day late.
  const after = planRun({...baseMoment, initiation: {kind: "anchored",
    anchorKind: "functionEnd", anchorId: "sangeet", offsetMinutes: 30}},
  facts, 0);
  assert.equal(after.kind === "planned" && after.run.expiresAtMillis,
    2_400_000 + 30 * 60_000 + 86_400_000);
  // Fixed-date sends get the same bounded late window.
  const scheduled: MomentDefinition = {...baseMoment, initiation: {
    kind: "scheduled", atMillis: 1_100_000,
  }};
  const fixed = planRun(scheduled, facts, 0);
  assert.equal(fixed.kind === "planned" && fixed.run.expiresAtMillis,
    1_100_000 + 86_400_000);
});

test("a run past its expiry reports expired, not dispatched", () => {
  const expired = run({expiresAtMillis: 1_000});
  assert.equal(resolveFireDisposition(expired, baseMoment, facts, 2_000),
    "skip:expired");
  // Runs planned before the field existed keep the old anchor checks.
  const legacy = run({});
  assert.equal(resolveFireDisposition(legacy, baseMoment, facts, 2_000),
    "dispatch");
});

test("anchorPassed judges the net offset, not just offsetMinutes", () => {
  // Calendar parts can make a non-positive minute offset net-positive:
  // -1 day - 30 minutes still dies at the anchor, while -1 day + 2 hours
  // lands after it (post-anchor sends stay valid when late).
  const beforeAnchor: MomentDefinition = {...baseMoment, initiation: {
    kind: "anchored", anchorKind: "functionStart", anchorId: "sangeet",
    offsetMinutes: -30, offsetDays: -1,
  }};
  const lateRun = run({anchorRevision: 7});
  assert.equal(resolveFireDisposition(lateRun, beforeAnchor, facts,
    2_100_000), "skip:anchorPassed");
  const afterAnchor: MomentDefinition = {...baseMoment, initiation: {
    kind: "anchored", anchorKind: "functionStart", anchorId: "sangeet",
    offsetMinutes: 120, offsetDays: -1,
  }};
  // Nominal = anchor -22h — still before the anchor: a late wake skips.
  assert.equal(resolveFireDisposition(lateRun, afterAnchor, facts,
    2_100_000), "skip:anchorPassed");
  const postAnchor: MomentDefinition = {...baseMoment, initiation: {
    kind: "anchored", anchorKind: "functionStart", anchorId: "sangeet",
    offsetMinutes: 120, offsetDays: 0,
  }};
  assert.equal(resolveFireDisposition(lateRun, postAnchor, facts,
    2_100_000), "dispatch");
  // Offset-0 is boundary: nominal == anchor counts as pre-anchor, so a
  // run that reached pass 2 after the anchor still skips — stale "starts
  // now" copy is worse than silence (momentDefaults pins this too).
  const atAnchor: MomentDefinition = {...baseMoment, initiation: {
    kind: "anchored", anchorKind: "functionStart", anchorId: "sangeet",
    offsetMinutes: 0,
  }};
  assert.equal(resolveFireDisposition(lateRun, atAnchor, facts,
    2_000_000), "skip:anchorPassed");
});
