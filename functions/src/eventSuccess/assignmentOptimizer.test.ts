import assert from "node:assert/strict";
import test from "node:test";
import {
  AssignmentParticipant,
  buildOptimizedGroups,
  buildOptimizedRotationRounds,
  optimizeEventSuccessAssignments,
  runAssignmentEngine,
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

test("assignment engine is primitive-driven and exposes metrics", () => {
  const plan = runAssignmentEngine({
    participants: [
      participant("man-1", "man", ["woman"]),
      participant("woman-1", "woman", ["man"]),
      participant("man-2", "man", ["woman"]),
      participant("woman-2", "woman", ["man"]),
    ],
    blockedPairs: new Set(),
    topology: {
      unitKind: "tables",
      unitSize: 4,
      groupCount: 1,
      maxGroupSize: 4,
      rotationIntervalMinutes: null,
      rotationsEnabled: false,
    },
    compatibilityPolicy: "mutualInterestOnly",
  });

  assert.equal(plan.assignmentAlgorithm, "tableSeating");
  assert.equal(plan.groups.length, 1);
  assert.equal(plan.explainability.unitKind, "tables");
  assert.equal(plan.explainability.targetUnitSize, 4);
  assert.equal(plan.explainability.targetGroupCount, 1);
  assert.equal(plan.explainability.participantCount, 4);
  assert.equal(plan.explainability.assignedParticipantCount, 4);
  assert.equal(plan.explainability.unassignedParticipantCount, 0);
  assert.equal(plan.explainability.generatedStaticGroupCount, 1);
  assert.equal(plan.explainability.mutualDyadCount, 4);
  assert.deepEqual(plan.explainability.constraintRelaxations, []);
});

test("table groups balance straight dyads across equal-sized groups", () => {
  const plan = runAssignmentEngine({
    participants: [
      participant("man-1", "man", ["woman"]),
      participant("man-2", "man", ["woman"]),
      participant("man-3", "man", ["woman"]),
      participant("man-4", "man", ["woman"]),
      participant("man-5", "man", ["woman"]),
      participant("man-6", "man", ["woman"]),
      participant("woman-1", "woman", ["man"]),
      participant("woman-2", "woman", ["man"]),
      participant("woman-3", "woman", ["man"]),
      participant("woman-4", "woman", ["man"]),
      participant("woman-5", "woman", ["man"]),
      participant("woman-6", "woman", ["man"]),
    ],
    blockedPairs: new Set(),
    topology: {
      unitKind: "tables",
      unitSize: 6,
      groupCount: 2,
      maxGroupSize: 6,
      rotationIntervalMinutes: null,
      rotationsEnabled: false,
    },
    compatibilityPolicy: "mutualInterestOnly",
  });

  assert.equal(plan.groups.length, 2);
  for (const group of plan.groups) {
    assert.equal(group.participants.length, 6);
    assert.equal(countGender(group.participants, "man"), 3);
    assert.equal(countGender(group.participants, "woman"), 3);
  }
  assert.equal(plan.explainability.groupSizeSkew, 0);
  assert.equal(plan.explainability.unassignedParticipantCount, 0);
});

test("group composition distributes imbalanced mutual opportunity", () => {
  const plan = runAssignmentEngine({
    participants: [
      participant("man-1", "man", ["woman"]),
      participant("man-2", "man", ["woman"]),
      participant("man-3", "man", ["woman"]),
      participant("man-4", "man", ["woman"]),
      participant("woman-1", "woman", ["man"]),
      participant("woman-2", "woman", ["man"]),
    ],
    blockedPairs: new Set(),
    topology: {
      unitKind: "tables",
      unitSize: 3,
      groupCount: 2,
      maxGroupSize: 3,
      rotationIntervalMinutes: null,
      rotationsEnabled: false,
    },
    compatibilityPolicy: "mutualInterestOnly",
  });

  assert.equal(plan.groups.length, 2);
  for (const group of plan.groups) {
    assert.equal(group.participants.length, 3);
    assert.equal(countGender(group.participants, "woman"), 1);
    assert.ok(group.mutualDyadCount > 0);
  }
  assert.equal(plan.explainability.lowOpportunityGroupCount, 0);
  assert.equal(
    constraintStatus(plan, "group_opportunity_balance", []),
    "satisfied"
  );
  assert.ok(!plan.explainability.constraintRelaxations.includes(
    "group_opportunity_imbalance"
  ));
});

test("group composition explainability reports unavoidable imbalance", () => {
  const plan = runAssignmentEngine({
    participants: [
      participant("man-1", "man", ["woman"]),
      participant("man-2", "man", ["woman"]),
      participant("man-3", "man", ["woman"]),
      participant("man-4", "man", ["woman"]),
      participant("man-5", "man", ["woman"]),
      participant("woman-1", "woman", ["man"]),
    ],
    blockedPairs: new Set(),
    topology: {
      unitKind: "tables",
      unitSize: 3,
      groupCount: 2,
      maxGroupSize: 3,
      rotationIntervalMinutes: null,
      rotationsEnabled: false,
    },
    compatibilityPolicy: "mutualInterestOnly",
  });

  assert.equal(plan.groups.length, 2);
  assert.equal(plan.explainability.lowOpportunityGroupCount, 1);
  assert.ok(plan.explainability.uncoveredParticipantAssignmentCount > 0);
  assert.equal(
    constraintStatus(plan, "group_opportunity_balance", []),
    "relaxed"
  );
  assert.ok(plan.explainability.constraintRelaxations.includes(
    "group_opportunity_imbalance"
  ));
});

test("host constraints steer group placement and explain satisfaction", () => {
  const plan = runAssignmentEngine({
    participants: [
      participant("man-1", "man", ["woman"]),
      participant("woman-1", "woman", ["man"]),
      participant("man-2", "man", ["woman"]),
      participant("woman-2", "woman", ["man"]),
    ],
    blockedPairs: new Set(),
    topology: {
      unitKind: "tables",
      unitSize: 2,
      groupCount: 2,
      maxGroupSize: 2,
      rotationIntervalMinutes: null,
      rotationsEnabled: false,
    },
    compatibilityPolicy: "mutualInterestOnly",
    constraints: {
      host: {
        anchorUidsByGroupIndex: {"1": ["man-1"]},
        keepTogetherPairs: [{aUid: "man-1", bUid: "woman-2"}],
        keepApartPairs: [{aUid: "man-1", bUid: "woman-1"}],
      },
    },
  });

  assert.equal(groupIndexForUid(plan.groups, "man-1"), 1);
  assert.equal(sameGroup(plan.groups, "man-1", "woman-2"), true);
  assert.equal(sameGroup(plan.groups, "man-1", "woman-1"), false);
  assert.equal(
    constraintStatus(plan, "host_anchor", ["man-1"]),
    "satisfied"
  );
  assert.equal(
    constraintStatus(plan, "host_keep_together", ["man-1", "woman-2"]),
    "satisfied"
  );
  assert.equal(
    constraintStatus(plan, "host_keep_apart", ["man-1", "woman-1"]),
    "satisfied"
  );
  assert.equal(plan.explainability.violatedConstraintCount, 0);
  assert.ok(!plan.explainability.constraintRelaxations.includes(
    "host_keep_together_relaxed"
  ));
});

test("host constraint relaxations are explicit when impossible", () => {
  const plan = runAssignmentEngine({
    participants: [
      participant("man-1", "man", ["woman"]),
      participant("woman-1", "woman", ["man"]),
    ],
    blockedPairs: new Set(),
    topology: {
      unitKind: "tables",
      unitSize: 1,
      groupCount: 2,
      maxGroupSize: 1,
      rotationIntervalMinutes: null,
      rotationsEnabled: false,
    },
    compatibilityPolicy: "mutualInterestOnly",
    constraints: {
      host: {
        keepTogetherPairs: [{aUid: "man-1", bUid: "woman-1"}],
      },
    },
  });

  assert.equal(plan.groups.length, 2);
  assert.equal(sameGroup(plan.groups, "man-1", "woman-1"), false);
  assert.equal(
    constraintStatus(plan, "host_keep_together", ["man-1", "woman-1"]),
    "relaxed"
  );
  assert.ok(plan.explainability.constraintRelaxations.includes(
    "host_keep_together_relaxed"
  ));
  assert.equal(plan.explainability.relaxedConstraintCount, 1);
});

test("activity balance attributes distribute skill across teams", () => {
  const plan = runAssignmentEngine({
    participants: [
      participant("advanced-1", "person", [], [], {skillBand: "advanced"}),
      participant("advanced-2", "person", [], [], {skillBand: "advanced"}),
      participant("beginner-1", "person", [], [], {skillBand: "beginner"}),
      participant("beginner-2", "person", [], [], {skillBand: "beginner"}),
    ],
    blockedPairs: new Set(),
    topology: {
      unitKind: "teams",
      unitSize: 2,
      groupCount: 2,
      maxGroupSize: 2,
      rotationIntervalMinutes: null,
      rotationsEnabled: false,
    },
    compatibilityPolicy: "none",
    constraints: {
      activity: {
        balanceAttributes: ["skillBand"],
      },
    },
  });

  assert.equal(plan.groups.length, 2);
  for (const group of plan.groups) {
    assert.equal(countActivityValue(group.participants, "skillBand",
      "advanced"), 1);
    assert.equal(countActivityValue(group.participants, "skillBand",
      "beginner"), 1);
  }
  assert.equal(plan.explainability.activityBalanceAttributeCount, 1);
  assert.equal(plan.explainability.activityBalanceSkew, 0);
  assert.equal(plan.explainability.activityMissingAttributeValueCount, 0);
  assert.equal(
    constraintStatus(plan, "activity_attribute_balance", []),
    "satisfied"
  );
  assert.equal(
    constraintStatus(plan, "group_opportunity_balance", []),
    "not_applicable"
  );
});

test("activity cluster attributes group similar pace bands", () => {
  const plan = runAssignmentEngine({
    participants: [
      participant("fast-1", "person", [], [], {paceBand: "fast"}),
      participant("fast-2", "person", [], [], {paceBand: "fast"}),
      participant("social-1", "person", [], [], {paceBand: "social"}),
      participant("social-2", "person", [], [], {paceBand: "social"}),
    ],
    blockedPairs: new Set(),
    topology: {
      unitKind: "pods",
      unitSize: 2,
      groupCount: 2,
      maxGroupSize: 2,
      rotationIntervalMinutes: null,
      rotationsEnabled: false,
    },
    compatibilityPolicy: "none",
    constraints: {
      activity: {
        clusterAttributes: ["paceBand"],
      },
    },
  });

  assert.equal(plan.groups.length, 2);
  for (const group of plan.groups) {
    assert.equal(uniqueActivityValues(group.participants, "paceBand").size, 1);
  }
  assert.equal(plan.explainability.activityClusterAttributeCount, 1);
  assert.equal(plan.explainability.activityClusterMixedGroupCount, 0);
  assert.equal(
    constraintStatus(plan, "activity_attribute_cluster", []),
    "satisfied"
  );
});

test("activity cluster attributes steer pair rotations", () => {
  const plan = runAssignmentEngine({
    participants: [
      participant("fast-1", "person", [], [], {paceBand: "fast"}),
      participant("fast-2", "person", [], [], {paceBand: "fast"}),
      participant("social-1", "person", [], [], {paceBand: "social"}),
      participant("social-2", "person", [], [], {paceBand: "social"}),
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
    compatibilityPolicy: "none",
    rotationRoundCount: 1,
    constraints: {
      activity: {
        clusterAttributes: ["paceBand"],
      },
    },
  });

  assert.equal(plan.rotationRounds.length, 1);
  assert.equal(plan.rotationRounds[0].pairs.length, 2);
  for (const pair of plan.rotationRounds[0].pairs) {
    assert.equal(pair.a.activityAttributes?.paceBand,
      pair.b.activityAttributes?.paceBand);
  }
  assert.equal(plan.explainability.activityClusterMixedGroupCount, 0);
});

test("activity attributes report missing data relaxations", () => {
  const plan = runAssignmentEngine({
    participants: [
      participant("advanced-1", "person", [], [], {skillBand: "advanced"}),
      participant("unknown-1", "person", [], []),
    ],
    blockedPairs: new Set(),
    topology: {
      unitKind: "teams",
      unitSize: 2,
      groupCount: 1,
      maxGroupSize: 2,
      rotationIntervalMinutes: null,
      rotationsEnabled: false,
    },
    compatibilityPolicy: "none",
    constraints: {
      activity: {
        balanceAttributes: ["skillBand"],
      },
    },
  });

  assert.equal(plan.explainability.activityMissingAttributeValueCount, 1);
  assert.equal(
    constraintStatus(plan, "activity_attribute_balance", []),
    "relaxed"
  );
  assert.ok(plan.explainability.constraintRelaxations.includes(
    "activity_attribute_balance_relaxed"
  ));
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

test("rotation metrics show requested rounds and avoid repeats", () => {
  const plan = runAssignmentEngine({
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
      unitKind: "pairs",
      unitSize: 2,
      groupCount: 3,
      maxGroupSize: 2,
      rotationIntervalMinutes: 15,
      rotationsEnabled: true,
    },
    compatibilityPolicy: "mutualInterestOnly",
    rotationRoundCount: 3,
  });

  assert.equal(plan.rotationRounds.length, 3);
  assert.equal(plan.explainability.requestedRotationRoundCount, 3);
  assert.equal(plan.explainability.generatedRotationRoundCount, 3);
  assert.equal(plan.explainability.repeatedPairCount, 0);
  assert.equal(plan.explainability.orientationFallbackPairCount, 0);
  assert.equal(plan.explainability.mutualDyadCount, 9);
  assert.deepEqual(plan.explainability.constraintRelaxations, []);
});

test("rotation metrics explain infeasible extra rounds", () => {
  const plan = runAssignmentEngine({
    participants: [
      participant("man-1", "man", ["woman"]),
      participant("man-2", "man", ["woman"]),
      participant("woman-1", "woman", ["man"]),
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
    compatibilityPolicy: "mutualInterestOnly",
    rotationRoundCount: 5,
  });

  assert.equal(plan.rotationRounds.length, 2);
  assert.equal(plan.explainability.requestedRotationRoundCount, 5);
  assert.equal(plan.explainability.generatedRotationRoundCount, 2);
  assert.equal(plan.explainability.repeatedPairCount, 0);
  assert.ok(
    plan.explainability.constraintRelaxations.includes(
      "rotations_not_generated"
    )
  );
});

test("rotation policy fills exhausted rounds with bounded repeats", () => {
  const plan = runAssignmentEngine({
    participants: [
      participant("man-1", "man", ["woman"]),
      participant("man-2", "man", ["woman"]),
      participant("woman-1", "woman", ["man"]),
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
    compatibilityPolicy: "mutualInterestOnly",
    rotationRoundCount: 3,
    rotationPolicy: {
      repeatStrategy: "allowWhenExhausted",
      maxPairMeetings: 2,
    },
  });

  assert.equal(plan.rotationRounds.length, 3);
  assert.equal(
    plan.explainability.rotationRepeatStrategy,
    "allowWhenExhausted"
  );
  assert.equal(plan.explainability.maxPairMeetings, 2);
  assert.equal(plan.explainability.repeatedPairCount, 2);
  assert.ok(plan.explainability.constraintRelaxations.includes(
    "repeated_pairs_required"
  ));
});

test("host requested repeat pair overrides default repeat avoidance", () => {
  const plan = runAssignmentEngine({
    participants: [
      participant("man-1", "man", ["woman"]),
      participant("woman-1", "woman", ["man"]),
    ],
    blockedPairs: new Set(),
    topology: {
      unitKind: "pairs",
      unitSize: 2,
      groupCount: 1,
      maxGroupSize: 2,
      rotationIntervalMinutes: 15,
      rotationsEnabled: true,
    },
    compatibilityPolicy: "mutualInterestOnly",
    rotationRoundCount: 2,
    constraints: {
      host: {
        requestedRepeatPairs: [{aUid: "man-1", bUid: "woman-1"}],
      },
    },
  });

  assert.equal(plan.rotationRounds.length, 2);
  assert.equal(plan.explainability.rotationRepeatStrategy, "avoid");
  assert.equal(plan.explainability.hostRequestedRepeatPairCount, 1);
  assert.equal(plan.explainability.repeatedPairCount, 1);
  assert.ok(plan.explainability.constraintRelaxations.includes(
    "repeated_pairs_required"
  ));
});

function roundMembership(round: {
  groups: Array<{participants: AssignmentParticipant[]}>;
}) {
  return round.groups
    .map((group) => group.participants.map((item) => item.uid).sort())
    .sort((a, b) => a.join(",").localeCompare(b.join(",")));
}

function countGender(
  participants: AssignmentParticipant[],
  gender: string
): number {
  return participants.filter((participant) => participant.gender === gender)
    .length;
}

function countActivityValue(
  participants: AssignmentParticipant[],
  attribute: string,
  value: string
): number {
  return participants.filter((participant) =>
    participant.activityAttributes?.[attribute] === value
  ).length;
}

function uniqueActivityValues(
  participants: AssignmentParticipant[],
  attribute: string
): Set<unknown> {
  return new Set(
    participants.map((participant) =>
      participant.activityAttributes?.[attribute]
    )
  );
}

function groupIndexForUid(
  groups: Array<{groupIndex: number; participants: AssignmentParticipant[]}>,
  uid: string
): number | null {
  for (const group of groups) {
    if (group.participants.some((participant) => participant.uid === uid)) {
      return group.groupIndex;
    }
  }
  return null;
}

function sameGroup(
  groups: Array<{participants: AssignmentParticipant[]}>,
  uidA: string,
  uidB: string
): boolean {
  return groups.some((group) =>
    group.participants.some((participant) => participant.uid === uidA) &&
    group.participants.some((participant) => participant.uid === uidB)
  );
}

function constraintStatus(
  plan: {
    explainability: {
      constraintEvaluations: Array<{
        key: string;
        status: string;
        subjectUids: string[];
      }>;
    };
  },
  key: string,
  subjectUids: string[]
): string | null {
  const expected = [...subjectUids].sort().join(",");
  return plan.explainability.constraintEvaluations.find((evaluation) =>
    evaluation.key === key &&
    [...evaluation.subjectUids].sort().join(",") === expected
  )?.status ?? null;
}

function participant(
  uid: string,
  gender: string,
  interestedInGenders: string[],
  compatibilityAnswerIds: string[] = [],
  activityAttributes?: Record<string, string | number | boolean | null>
): AssignmentParticipant {
  return {
    uid,
    gender,
    interestedInGenders,
    compatibilityAnswerIds,
    activityAttributes,
  };
}
