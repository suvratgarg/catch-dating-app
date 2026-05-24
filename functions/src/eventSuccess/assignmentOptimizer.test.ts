/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {
  AssignmentParticipant,
  buildOptimizedGroups,
  buildOptimizedRotationRounds,
  optimizeEventSuccessAssignments,
} from "./assignmentOptimizer";

test("groups sparse mutual-orientation attendees together", () => {
  const groups = buildOptimizedGroups({
    participants: [
      participant("gay-man-1", "man", ["man"]),
      participant("gay-man-2", "man", ["man"]),
      participant("straight-man-1", "man", ["woman"]),
      participant("straight-man-2", "man", ["woman"]),
      participant("straight-woman-1", "woman", ["man"]),
      participant("straight-woman-2", "woman", ["man"]),
    ],
    blockedPairs: new Set(),
    groupCount: 2,
    maxGroupSize: 3,
  });

  assert.equal(groups.length, 2);
  assert.ok(
    groups.some((group) =>
      group.map((item) => item.uid).includes("gay-man-1") &&
      group.map((item) => item.uid).includes("gay-man-2")
    )
  );
});

test("rotation rounds use mutual pairs before fallback pairings", () => {
  const rounds = buildOptimizedRotationRounds({
    participants: [
      participant("man-1", "man", ["woman"]),
      participant("woman-1", "woman", ["man"]),
      participant("nb-1", "nonbinary", ["woman"]),
      participant("woman-2", "woman", ["man"]),
    ],
    blockedPairs: new Set(),
    roundCount: 1,
    allowOrientationFallback: true,
  });

  assert.equal(rounds.length, 1);
  assert.equal(rounds[0].pairs.length, 2);
  assert.equal(rounds[0].pairs[0].mutualInterest, true);
  assert.equal(rounds[0].pairs[0].compatibility, "mutual_interest");
  assert.equal(rounds[0].pairs[1].mutualInterest, false);
});

test("questionnaire mode controls whether answers affect ranking", () => {
  const participants = [
    participant("man-1", "man", ["woman"], ["shared"]),
    participant("woman-1", "woman", ["man"], ["different"]),
    participant("woman-2", "woman", ["man"], ["shared"]),
  ];
  const icebreakerRounds = buildOptimizedRotationRounds({
    participants,
    blockedPairs: new Set(),
    roundCount: 1,
    questionnaireMode: "icebreaker",
    allowOrientationFallback: false,
  });
  const compatibilityRounds = buildOptimizedRotationRounds({
    participants,
    blockedPairs: new Set(),
    roundCount: 1,
    questionnaireMode: "light",
    allowOrientationFallback: false,
  });

  assert.equal(icebreakerRounds[0].pairs[0].b.uid, "woman-1");
  assert.equal(compatibilityRounds[0].pairs[0].b.uid, "woman-2");
  assert.equal(
    compatibilityRounds[0].pairs[0].compatibility,
    "questionnaire_match"
  );
});

test("unified optimizer uses topology primitives for pair rotations", () => {
  const plan = optimizeEventSuccessAssignments({
    participants: [
      participant("man-1", "man", ["woman"]),
      participant("woman-1", "woman", ["man"]),
      participant("man-2", "man", ["woman"]),
      participant("woman-2", "woman", ["man"]),
    ],
    blockedPairs: new Set(),
    topology: {
      unitKind: "pairs",
      unitSize: 2,
      groupCount: 2,
      maxGroupSize: 2,
      rotationIntervalMinutes: 15,
      rotationsEnabled: true,
    },
    assignmentAlgorithm: "pairRotations",
    compatibilityPolicy: "mutualInterestOnly",
    rotationRoundCount: 2,
  });

  assert.equal(plan.groups.length, 0);
  assert.equal(plan.rotationRounds.length, 2);
  assert.equal(plan.rotationRounds[0].pairs[0].mutualInterest, true);
});

test("unified optimizer uses topology and primitives for teams", () => {
  const plan = optimizeEventSuccessAssignments({
    participants: [
      participant("gay-man-1", "man", ["man"]),
      participant("gay-man-2", "man", ["man"]),
      participant("straight-man-1", "man", ["woman"]),
      participant("straight-man-2", "man", ["woman"]),
      participant("straight-woman-1", "woman", ["man"]),
      participant("straight-woman-2", "woman", ["man"]),
    ],
    blockedPairs: new Set(),
    topology: {
      unitKind: "teams",
      unitSize: 3,
      groupCount: 2,
      maxGroupSize: 3,
      rotationIntervalMinutes: null,
      rotationsEnabled: false,
    },
    assignmentAlgorithm: "teamBalancer",
    compatibilityPolicy: "mutualInterestOnly",
  });

  assert.equal(plan.rotationRounds.length, 0);
  assert.equal(plan.groups.length, 2);
  assert.ok(
    plan.groups.some((group) =>
      group.participants.map((item) => item.uid).includes("gay-man-1") &&
      group.participants.map((item) => item.uid).includes("gay-man-2")
    )
  );
  assert.ok(plan.groups.every((group) => group.mutualDyadCount > 0));
});

test("unified optimizer rotates larger topology units", () => {
  const plan = optimizeEventSuccessAssignments({
    participants: [
      participant("man-1", "man", ["woman"]),
      participant("man-2", "man", ["woman"]),
      participant("man-3", "man", ["woman"]),
      participant("woman-1", "woman", ["man"]),
      participant("woman-2", "woman", ["man"]),
      participant("woman-3", "woman", ["man"]),
    ],
    blockedPairs: new Set(),
    topology: {
      unitKind: "tables",
      unitSize: 3,
      groupCount: 2,
      maxGroupSize: 3,
      rotationIntervalMinutes: 20,
      rotationsEnabled: true,
    },
    assignmentAlgorithm: "tableSeating",
    compatibilityPolicy: "mutualInterestOnly",
    rotationRoundCount: 2,
  });

  assert.equal(plan.groups.length, 0);
  assert.equal(plan.rotationRounds.length, 0);
  assert.equal(plan.groupRounds.length, 2);
  assert.notDeepEqual(
    roundMembership(plan.groupRounds[0]),
    roundMembership(plan.groupRounds[1])
  );
});

test("fallback rotations pair socially when no romantic dyad exists", () => {
  const rounds = buildOptimizedRotationRounds({
    participants: [
      participant("man-1", "man", ["woman"]),
      participant("man-2", "man", ["woman"]),
    ],
    blockedPairs: new Set(),
    roundCount: 1,
    compatibilityPolicy: "mutualInterestOnly",
    allowOrientationFallback: true,
  });

  assert.equal(rounds.length, 1);
  assert.equal(rounds[0].pairs[0].compatibility, "social");
  assert.equal(rounds[0].pairs[0].mutualInterest, false);
});

function roundMembership(round: {
  groups: Array<{participants: AssignmentParticipant[]}>;
}) {
  return round.groups
    .map((group) => group.participants.map((item) => item.uid).sort())
    .sort((a, b) => a.join(",").localeCompare(b.join(",")));
}

function participant(
  uid: string,
  gender: string,
  interestedInGenders: string[],
  compatibilityAnswerIds: string[] = []
): AssignmentParticipant {
  return {uid, gender, interestedInGenders, compatibilityAnswerIds};
}
