import assert from "node:assert/strict";
import test from "node:test";
import {
  classifyArrival,
  detectScheduleIssues,
  groupFunctionsByDay,
  orderFunctions,
  resolveLiveFunction,
  type ProgramFunctionLike,
} from "./programTimeline";

function fn(
  functionId: string,
  partial?: Partial<ProgramFunctionLike>,
): ProgramFunctionLike {
  return {
    functionId,
    name: functionId,
    startsAt: 1_000_000,
    endsAt: 2_000_000,
    venueName: "Venue",
    status: "scheduled",
    revision: 1,
    ...partial,
  };
}

test("orderFunctions sorts by startsAt and keeps ties stable", () => {
  const input = [
    fn("a", {startsAt: 10}),
    fn("b", {startsAt: 5}),
    fn("c", {startsAt: 10}),
    fn("d", {startsAt: 1}),
  ];
  assert.deepEqual(orderFunctions(input).map((f) => f.functionId),
    ["d", "b", "a", "c"]);
  // The input array is left untouched.
  assert.deepEqual(input.map((f) => f.functionId), ["a", "b", "c", "d"]);
});

test("detectScheduleIssues reports overlapping pairs", () => {
  const issues = detectScheduleIssues([
    fn("a", {startsAt: 0, endsAt: 400}),
    fn("b", {startsAt: 100, endsAt: 200}),
    fn("c", {startsAt: 300, endsAt: 500}),
    fn("d", {startsAt: 600, endsAt: 700}),
  ]);
  assert.deepEqual(issues, [
    {kind: "overlap", functionId: "a", otherFunctionId: "b",
      overlapMillis: 100},
    {kind: "overlap", functionId: "a", otherFunctionId: "c",
      overlapMillis: 100},
  ]);
});

test("detectScheduleIssues flags gaps below the buffer", () => {
  const functions = [
    fn("a", {startsAt: 0, endsAt: 1_000_000}),
    fn("b", {startsAt: 1_900_000, endsAt: 2_000_000}),
    fn("c", {startsAt: 2_200_000, endsAt: 3_000_000}),
  ];
  assert.deepEqual(detectScheduleIssues(functions,
    {minBufferMinutes: 30}), [
    {kind: "shortGap", functionId: "a", nextFunctionId: "b",
      gapMillis: 900_000},
    {kind: "shortGap", functionId: "b", nextFunctionId: "c",
      gapMillis: 200_000},
  ]);
  // A gap exactly at the buffer is not flagged.
  assert.deepEqual(detectScheduleIssues(functions,
    {minBufferMinutes: 15}), [
    {kind: "shortGap", functionId: "b", nextFunctionId: "c",
      gapMillis: 200_000},
  ]);
  // No buffer configured means no gap checks.
  assert.deepEqual(detectScheduleIssues(functions), []);
});

test("detectScheduleIssues flags window, venue and duration problems",
  () => {
    const issues = detectScheduleIssues([
      fn("early", {startsAt: 50, endsAt: 500}),
      fn("late", {startsAt: 900, endsAt: 1_500}),
      fn("novenue", {startsAt: 600, endsAt: 700, venueName: "  "}),
      // Degenerate windows inside "early" must not add overlap noise.
      fn("flat", {startsAt: 300, endsAt: 300}),
      fn("backwards", {startsAt: 400, endsAt: 350, venueName: null}),
    ], {programStart: 100, programEnd: 1_000});
    // Issues are emitted in schedule order.
    assert.deepEqual(issues, [
      {kind: "outsideProgramWindow", functionId: "early"},
      {kind: "nonPositiveDuration", functionId: "flat"},
      {kind: "nonPositiveDuration", functionId: "backwards"},
      {kind: "missingVenue", functionId: "backwards"},
      {kind: "missingVenue", functionId: "novenue"},
      {kind: "outsideProgramWindow", functionId: "late"},
    ]);
  });

test("cancelled functions skip pair checks but keep their own issues",
  () => {
    const issues = detectScheduleIssues([
      fn("a", {startsAt: 0, endsAt: 1_000}),
      fn("gone", {startsAt: 500, endsAt: 600, status: "cancelled"}),
      fn("b", {startsAt: 1_100, endsAt: 2_000}),
    ], {minBufferMinutes: 30});
    assert.deepEqual(issues, [
      {kind: "shortGap", functionId: "a", nextFunctionId: "b",
        gapMillis: 100},
    ]);
  });

const KOLKATA = "Asia/Kolkata";

test("groupFunctionsByDay buckets by the program timezone", () => {
  const functions = [
    // 2026-05-02 09:30 IST.
    fn("brunch", {startsAt: Date.UTC(2026, 4, 2, 4, 0)}),
    // 2026-05-01 15:30 IST.
    fn("mehendi", {startsAt: Date.UTC(2026, 4, 1, 10, 0)}),
    // 2026-05-02 00:30 IST — same Kolkata day as brunch.
    fn("sangeet", {startsAt: Date.UTC(2026, 4, 1, 19, 0)}),
  ];
  assert.deepEqual(groupFunctionsByDay(functions, KOLKATA), [
    {
      dayKey: "2026-05-01",
      label: "Friday, May 1, 2026",
      functions: [functions[1]],
    },
    {
      dayKey: "2026-05-02",
      label: "Saturday, May 2, 2026",
      functions: [functions[2], functions[0]],
    },
  ]);
});

test("groupFunctionsByDay shifts boundaries with the timezone", () => {
  const functions = [
    fn("a", {startsAt: Date.UTC(2026, 4, 1, 19, 0)}),
    fn("b", {startsAt: Date.UTC(2026, 4, 2, 4, 0)}),
  ];
  const groups = groupFunctionsByDay(functions, "America/Los_Angeles");
  // Both instants land on 2026-05-01 in Pacific Daylight Time.
  assert.equal(groups.length, 1);
  assert.equal(groups[0].dayKey, "2026-05-01");
  assert.deepEqual(groups[0].functions.map((f) => f.functionId),
    ["a", "b"]);
});

test("resolveLiveFunction reports live and next with minute offsets",
  () => {
    const functions = [
      fn("a", {startsAt: 0, endsAt: 600_000}),
      fn("b", {startsAt: 900_000, endsAt: 1_500_000}),
    ];
    assert.deepEqual(resolveLiveFunction(functions, 300_000), {
      live: functions[0],
      next: functions[1],
      minutesUntilNextStart: 10,
      minutesSinceLiveStart: 5,
    });
    assert.deepEqual(resolveLiveFunction(functions, 750_000), {
      live: null,
      next: functions[1],
      minutesUntilNextStart: 2.5,
      minutesSinceLiveStart: null,
    });
    assert.deepEqual(resolveLiveFunction(functions, 2_000_000), {
      live: null,
      next: null,
      minutesUntilNextStart: null,
      minutesSinceLiveStart: null,
    });
  });

test("resolveLiveFunction ignores cancelled functions", () => {
  const functions = [
    fn("gone", {startsAt: 0, endsAt: 600_000, status: "cancelled"}),
    fn("b", {startsAt: 900_000, endsAt: 1_500_000}),
  ];
  const resolution = resolveLiveFunction(functions, 300_000);
  assert.equal(resolution.live, null);
  assert.equal(resolution.next?.functionId, "b");
});

test("classifyArrival covers every phase of the schedule", () => {
  const functions = [
    fn("a", {startsAt: 600_000, endsAt: 1_800_000}),
    fn("b", {startsAt: 2_400_000, endsAt: 4_800_000}),
  ];
  assert.deepEqual(classifyArrival(functions, 300_000), {
    kind: "beforeFirst", next: functions[0],
  });
  assert.deepEqual(classifyArrival(functions, 600_000), {
    kind: "onTime", function: functions[0],
  });
  // Arrival exactly at the start plus the default 10-minute grace is
  // still on time.
  assert.deepEqual(classifyArrival(functions, 1_200_000), {
    kind: "onTime", function: functions[0],
  });
  assert.deepEqual(classifyArrival(functions, 1_260_000), {
    kind: "late", liveFunction: functions[0], minutesLate: 11,
  });
  assert.deepEqual(classifyArrival(functions, 2_100_000), {
    kind: "betweenFunctions", next: functions[1],
  });
  assert.deepEqual(classifyArrival(functions, 4_800_000),
    {kind: "afterLast"});
  assert.deepEqual(classifyArrival(functions, 3_600_000), {
    kind: "late", liveFunction: functions[1], minutesLate: 20,
  });
});

test("classifyArrival honours grace and skips cancelled functions",
  () => {
    const functions = [
      fn("gone", {startsAt: 600_000, endsAt: 1_800_000,
        status: "cancelled"}),
      fn("b", {startsAt: 2_400_000, endsAt: 3_000_000}),
    ];
    assert.deepEqual(classifyArrival(functions, 700_000), {
      kind: "beforeFirst", next: functions[1],
    });
    const running = [fn("a", {startsAt: 600_000, endsAt: 1_800_000})];
    assert.equal(
      classifyArrival(running, 1_200_000, {graceMinutes: 5}).kind,
      "late");
    assert.equal(
      classifyArrival(running, 1_200_000, {graceMinutes: 15}).kind,
      "onTime");
    assert.deepEqual(classifyArrival([], 1_200_000),
      {kind: "afterLast"});
  });

test("invalid millisecond inputs fail fast", () => {
  const functions = [fn("a")];
  for (const bad of [-1, NaN, Infinity, 0.5]) {
    assert.throws(() => resolveLiveFunction(functions, bad),
      RangeError);
    assert.throws(() => classifyArrival(functions, bad), RangeError);
  }
});
