import assert from "node:assert/strict";
import test from "node:test";
import {assignmentConstraintPairKey} from "./assignmentConstraints";
import {
  assignSequenceRoundResources,
  buildEventSuccessSequenceSchedule,
} from "./sequenceScheduler";

interface Participant {
  uid: string;
}

test("sequence schedule completes one round robin", () => {
  const participants = people(6);
  const schedule = buildEventSuccessSequenceSchedule({
    participants,
    roundLimit: 20,
    concurrentUnits: 3,
    exclusionIntervalMinutes: 15,
  });
  const pairKeys = schedule.rounds.flatMap((round) =>
    round.matches.map((match) => pairKey(match.a, match.b))
  );

  assert.equal(schedule.rounds.length, 5);
  assert.equal(pairKeys.length, 15);
  assert.equal(new Set(pairKeys).size, 15);
  assert.deepEqual(schedule.unscheduledPairKeys, []);
  assert.ok(schedule.rounds.every((round) => round.matches.length === 3));
});

test("sequence schedule never exceeds configured court count", () => {
  const schedule = buildEventSuccessSequenceSchedule({
    participants: people(8),
    roundLimit: 7,
    concurrentUnits: 2,
    exclusionIntervalMinutes: 12,
  });

  assert.equal(schedule.rounds.length, 7);
  assert.ok(schedule.rounds.every((round) => round.matches.length <= 2));
  assert.ok(schedule.rounds.every((round) =>
    new Set(round.matches.flatMap((match) => [match.a.uid, match.b.uid]))
      .size === round.matches.length * 2
  ));
});

test("capacity sit-outs stay within the fairness bound", () => {
  const schedule = buildEventSuccessSequenceSchedule({
    participants: people(8),
    roundLimit: 8,
    concurrentUnits: 2,
    exclusionIntervalMinutes: 10,
  });
  const sitOutCounts = new Map(people(8).map((person) => [person.uid, 0]));
  for (const round of schedule.rounds) {
    for (const uid of round.sitOutUids) {
      sitOutCounts.set(uid, (sitOutCounts.get(uid) ?? 0) + 1);
    }
  }
  const counts = [...sitOutCounts.values()];

  assert.ok(Math.max(...counts) - Math.min(...counts) <= 1);
});

test("odd participant round robin gives every attendee exactly one bye", () => {
  const schedule = buildEventSuccessSequenceSchedule({
    participants: people(5),
    roundLimit: 10,
    concurrentUnits: 2,
    exclusionIntervalMinutes: 15,
  });
  const byes = new Map(people(5).map((person) => [person.uid, 0]));
  for (const round of schedule.rounds) {
    for (const uid of round.sitOutUids) {
      byes.set(uid, (byes.get(uid) ?? 0) + 1);
    }
  }

  assert.equal(schedule.rounds.length, 5);
  assert.deepEqual([...byes.values()].sort(), [1, 1, 1, 1, 1]);
  assert.deepEqual(schedule.unscheduledPairKeys, []);
});

test("T3 exclusion totals take precedence when capacity is scarce", () => {
  const schedule = buildEventSuccessSequenceSchedule({
    participants: people(4),
    roundLimit: 1,
    concurrentUnits: 1,
    exclusionIntervalMinutes: 15,
    exclusionMinutesByUid: new Map([["p4", 45]]),
  });

  assert.ok(schedule.rounds[0].matches.some((match) =>
    match.a.uid === "p4" || match.b.uid === "p4"
  ));
  assert.ok(!schedule.rounds[0].sitOutUids.includes("p4"));
});

test("resource assignment minimizes T5 proximity movement", () => {
  const [a, b, c, d] = people(4);
  const assignments = assignSequenceRoundResources({
    pairs: [{a, b}, {a: c, b: d}],
    resourceUnitIds: ["near", "far"],
    previousUnitByUid: new Map([
      [a.uid, "near"],
      [b.uid, "near"],
      [c.uid, "far"],
      [d.uid, "far"],
    ]),
    unitProximity: [{
      aUnitId: "far",
      bUnitId: "near",
      distance: 9,
    }],
  });

  assert.deepEqual(assignments.map((match) => [
    pairKey(match.a, match.b),
    match.resourceUnitId,
    match.movementCost,
  ]), [
    ["p1__p2", "near", 0],
    ["p3__p4", "far", 0],
  ]);
});

test("blocked pairs are never scheduled", () => {
  const participants = people(4);
  const blocked = assignmentConstraintPairKey("p1", "p2");
  const schedule = buildEventSuccessSequenceSchedule({
    participants,
    roundLimit: 10,
    concurrentUnits: 2,
    exclusionIntervalMinutes: 15,
    blockedPairKeys: new Set([blocked]),
  });
  const pairKeys = schedule.rounds.flatMap((round) =>
    round.matches.map((match) => pairKey(match.a, match.b))
  );

  assert.ok(!pairKeys.includes(blocked));
  assert.equal(new Set(pairKeys).size, 5);
});

test("repeat meetings start only after every allowed pair meets once", () => {
  const schedule = buildEventSuccessSequenceSchedule({
    participants: people(4),
    roundLimit: 6,
    concurrentUnits: 2,
    exclusionIntervalMinutes: 15,
    maxPairMeetings: 2,
  });
  const matches = schedule.rounds.flatMap((round) => round.matches);
  const firstRepeatIndex = matches.findIndex((match) => match.meetingIndex > 0);

  assert.equal(firstRepeatIndex, 6);
  assert.equal(
    new Set(matches.slice(0, firstRepeatIndex).map((match) =>
      pairKey(match.a, match.b)
    )).size,
    6
  );
});

function people(count: number): Participant[] {
  return Array.from({length: count}, (_, index) => ({uid: `p${index + 1}`}));
}

function pairKey(a: Participant, b: Participant): string {
  return assignmentConstraintPairKey(a.uid, b.uid);
}
