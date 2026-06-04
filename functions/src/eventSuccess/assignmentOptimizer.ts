import {
  CompatibilitySignal,
  QuestionnaireScoringMode,
  scoreDatingCompatibilityPair,
} from "./compatibilityPolicy";
import {AssignmentTopology} from "./assignmentTopology";
import {
  EventSuccessAssignmentAlgorithm,
  EventSuccessCompatibilityPolicy,
} from "./formatPrimitives";
import {
  AssignmentConstraintConfig,
  AssignmentConstraintEvaluation,
  AssignmentConstraintStatus,
  NormalizedAssignmentConstraints,
  activityGroupPlacementCost,
  activityPairScoreAdjustment,
  activityValue,
  canJoinHostConstrainedGroup,
  evaluateHostConstraints,
  hostConstrainedParticipantRank,
  hostGroupPlacementCost,
  hostPairScoreAdjustment,
  hostRequestedRepeatPairScoreAdjustment,
  isKeepApartPair,
  normalizeAssignmentConstraints,
} from "./assignmentConstraints";

export interface AssignmentParticipant {
  uid: string;
  gender?: string;
  interestedInGenders: string[];
  compatibilityAnswerIds?: string[];
  activityAttributes?: Record<string, string | number | boolean | null>;
}

export interface OptimizedPair<T extends AssignmentParticipant> {
  a: T;
  b: T;
  score: number;
  compatibility: CompatibilitySignal;
  mutualInterest: boolean;
  orientationCompatible: boolean;
}

export interface OptimizedRotationRound<T extends AssignmentParticipant> {
  roundIndex: number;
  pairs: Array<OptimizedPair<T>>;
}

export interface OptimizedGroupRound<T extends AssignmentParticipant> {
  roundIndex: number;
  groups: Array<OptimizedGroup<T>>;
}

export interface OptimizedGroup<T extends AssignmentParticipant> {
  groupIndex: number;
  participants: T[];
  score: number;
  mutualDyadCount: number;
  plausibleDyadCount: number;
}

export type AssignmentConstraintRelaxation =
  "activity_attribute_balance_relaxed" |
  "activity_attribute_cluster_relaxed" |
  "blocked_pair_violated" |
  "group_opportunity_imbalance" |
  "group_size_imbalance" |
  "hard_constraint_violation" |
  "host_anchor_relaxed" |
  "host_keep_apart_violated" |
  "host_keep_together_relaxed" |
  "insufficient_participants" |
  "orientation_fallback_used" |
  "repeated_pairs_required" |
  "rotations_not_generated" |
  "unassigned_participants";

export interface AssignmentEngineExplainability {
  participantCount: number;
  assignedParticipantCount: number;
  unassignedParticipantCount: number;
  unitKind: AssignmentTopology["unitKind"];
  targetUnitSize: number;
  targetGroupCount: number;
  rotationsEnabled: boolean;
  requestedRotationRoundCount: number;
  generatedRotationRoundCount: number;
  rotationRepeatStrategy: AssignmentRotationRepeatStrategy;
  maxPairMeetings: number;
  hostRequestedRepeatPairCount: number;
  activityBalanceAttributeCount: number;
  activityClusterAttributeCount: number;
  activityMissingAttributeValueCount: number;
  activityBalanceSkew: number;
  activityClusterMixedGroupCount: number;
  generatedGroupRoundCount: number;
  generatedStaticGroupCount: number;
  blockedPairCount: number;
  mutualDyadCount: number;
  plausibleDyadCount: number;
  repeatedPairCount: number;
  orientationFallbackPairCount: number;
  groupSizeSkew: number;
  lowOpportunityGroupCount: number;
  uncoveredParticipantAssignmentCount: number;
  groupMutualDyadSkew: number;
  groupPlausibleDyadSkew: number;
  constraintEvaluations: AssignmentConstraintEvaluation[];
  satisfiedConstraintCount: number;
  relaxedConstraintCount: number;
  violatedConstraintCount: number;
  constraintRelaxations: AssignmentConstraintRelaxation[];
}

export interface AssignmentEngineContext<T extends AssignmentParticipant> {
  participants: T[];
  blockedPairs: Set<string>;
  topology: AssignmentTopology;
  assignmentAlgorithm?: EventSuccessAssignmentAlgorithm;
  compatibilityPolicy?: EventSuccessCompatibilityPolicy;
  questionnaireMode?: QuestionnaireScoringMode;
  rotationRoundCount?: number;
  allowOrientationFallback?: boolean;
  constraints?: AssignmentConstraintConfig;
  rotationPolicy?: AssignmentRotationPolicy;
}

export type AssignmentRotationRepeatStrategy =
  "avoid" |
  "allowWhenExhausted";

export interface AssignmentRotationPolicy {
  repeatStrategy?: AssignmentRotationRepeatStrategy;
  maxPairMeetings?: number;
}

interface NormalizedAssignmentRotationPolicy {
  repeatStrategy: AssignmentRotationRepeatStrategy;
  maxPairMeetings: number;
}

export interface AssignmentEngineResult<T extends AssignmentParticipant> {
  assignmentAlgorithm: EventSuccessAssignmentAlgorithm;
  compatibilityPolicy: EventSuccessCompatibilityPolicy;
  groups: Array<OptimizedGroup<T>>;
  groupRounds: Array<OptimizedGroupRound<T>>;
  rotationRounds: Array<OptimizedRotationRound<T>>;
  explainability: AssignmentEngineExplainability;
}

export type OptimizedAssignmentPlan<T extends AssignmentParticipant> =
  AssignmentEngineResult<T>;

type AssignmentPlanCore<T extends AssignmentParticipant> =
  Omit<AssignmentEngineResult<T>, "explainability">;

interface GroupCompositionProfile {
  participantCount: number;
  mutualDyadCount: number;
  plausibleDyadCount: number;
  uncoveredParticipantCount: number;
  participantsWithMutualCount: number;
  dominantGenderShare: number;
}

interface GroupCompositionStats {
  lowOpportunityGroupCount: number;
  uncoveredParticipantAssignmentCount: number;
  groupMutualDyadSkew: number;
  groupPlausibleDyadSkew: number;
}

interface ActivityAttributeStats {
  missingAttributeValueCount: number;
  balanceMissingAttributeValueCount: number;
  clusterMissingAttributeValueCount: number;
  balanceSkew: number;
  clusterMixedGroupCount: number;
}

const GROUP_SIZE_PRESSURE = 12;
const NO_MUTUAL_GROUP_PENALTY = 25;
const LOW_OPPORTUNITY_GROUP_PENALTY = 70;
const UNCOVERED_GROUP_PARTICIPANT_PENALTY = 18;
const DOMINANT_GENDER_LOW_OPPORTUNITY_PENALTY = 35;
const REPEATED_GROUP_PAIR_PENALTY = 75;
const ROUND_CAPACITY_LOOKAHEAD_LIMIT = 200;

/**
 * Runs the primitive-driven assignment engine.
 * @param {object} params Assignment optimization inputs.
 * @return {AssignmentEngineResult<T>} Optimized plan plus explainability.
 */
export function runAssignmentEngine<
  T extends AssignmentParticipant
>(params: AssignmentEngineContext<T>): AssignmentEngineResult<T> {
  const assignmentAlgorithm = params.assignmentAlgorithm ??
    assignmentAlgorithmForTopology(params.topology);
  const compatibilityPolicy = params.compatibilityPolicy ??
    "questionnaireClueOnly";
  const questionnaireMode = questionnaireModeForPolicy(
    params.questionnaireMode ?? "icebreaker",
    compatibilityPolicy
  );
  const constraints = normalizeAssignmentConstraints(params.constraints);
  const rotationPolicy = normalizeRotationPolicy(params.rotationPolicy);
  const shouldBuildPairRotations =
    params.topology.rotationsEnabled &&
    params.topology.unitSize === 2 &&
    (params.rotationRoundCount ?? 0) > 0;

  let plan: AssignmentPlanCore<T>;
  if (shouldBuildPairRotations) {
    plan = {
      assignmentAlgorithm,
      compatibilityPolicy,
      groups: [],
      groupRounds: [],
      rotationRounds: buildRotationRoundsForOptimizer({
        participants: params.participants,
        blockedPairs: params.blockedPairs,
        roundCount: params.rotationRoundCount ?? 0,
        questionnaireMode,
        compatibilityPolicy,
        allowOrientationFallback: params.allowOrientationFallback ?? true,
        constraints,
        rotationPolicy,
      }),
    };
  } else if (
    params.topology.rotationsEnabled &&
    (params.rotationRoundCount ?? 0) > 0
  ) {
    plan = {
      assignmentAlgorithm,
      compatibilityPolicy,
      groups: [],
      groupRounds: buildGroupRoundsForOptimizer({
        participants: params.participants,
        blockedPairs: params.blockedPairs,
        groupCount: params.topology.groupCount,
        maxGroupSize: params.topology.maxGroupSize,
        questionnaireMode,
        compatibilityPolicy,
        roundCount: params.rotationRoundCount ?? 0,
        constraints,
        rotationPolicy,
      }),
      rotationRounds: [],
    };
  } else {
    plan = {
      assignmentAlgorithm,
      compatibilityPolicy,
      groups: buildGroupUnitsForOptimizer({
        participants: params.participants,
        blockedPairs: params.blockedPairs,
        groupCount: params.topology.groupCount,
        maxGroupSize: params.topology.maxGroupSize,
        questionnaireMode,
        compatibilityPolicy,
        constraints,
        rotationPolicy,
      }),
      groupRounds: [],
      rotationRounds: [],
    };
  }

  return {
    ...plan,
    explainability: buildAssignmentEngineExplainability({
      plan,
      participants: params.participants,
      blockedPairs: params.blockedPairs,
      topology: params.topology,
      questionnaireMode,
      compatibilityPolicy,
      constraints,
      rotationPolicy,
      requestedRotationRoundCount: params.rotationRoundCount ?? 0,
    }),
  };
}

/**
 * Optimizes event-success units from shared topology and format primitives.
 * The wrappers below exist for legacy callers; `runAssignmentEngine` is the
 * canonical primitive-driven path.
 * @param {object} params Assignment optimization inputs.
 * @return {OptimizedAssignmentPlan<T>} Optimized group or rotation plan.
 */
export function optimizeEventSuccessAssignments<
  T extends AssignmentParticipant
>(params: AssignmentEngineContext<T>): OptimizedAssignmentPlan<T> {
  return runAssignmentEngine(params);
}

/**
 * Builds dating-coded pair rotations with safety, fairness, and fallback tiers.
 * @param {object} params Rotation optimizer inputs.
 * @param {Array<AssignmentParticipant>} params.participants Eligible people.
 * @param {Set<string>} params.blockedPairs Safety-blocked undirected pairs.
 * @param {number} params.roundCount Maximum rotation rounds to generate.
 * @param {QuestionnaireScoringMode} params.questionnaireMode Answer weighting.
 * @param {boolean} params.allowOrientationFallback Allow fallback social pairs.
 * @return {Array<OptimizedRotationRound<T>>} Optimized rotation rounds.
 */
export function buildOptimizedRotationRounds<
  T extends AssignmentParticipant
>(params: {
  participants: T[];
  blockedPairs: Set<string>;
  roundCount: number;
  questionnaireMode?: QuestionnaireScoringMode;
  compatibilityPolicy?: EventSuccessCompatibilityPolicy;
  allowOrientationFallback?: boolean;
}): Array<OptimizedRotationRound<T>> {
  return optimizeEventSuccessAssignments({
    participants: params.participants,
    blockedPairs: params.blockedPairs,
    topology: {
      unitKind: "pairs",
      unitSize: 2,
      groupCount: Math.max(1, Math.floor(params.participants.length / 2)),
      maxGroupSize: 2,
      rotationIntervalMinutes: 15,
      rotationsEnabled: true,
    },
    assignmentAlgorithm: "pairRotations",
    compatibilityPolicy: params.compatibilityPolicy,
    questionnaireMode: params.questionnaireMode,
    rotationRoundCount: params.roundCount,
    allowOrientationFallback: params.allowOrientationFallback,
  }).rotationRounds;
}

/**
 * Builds dating-coded group units by maximizing internal romantic opportunity.
 * @param {object} params Group optimizer inputs.
 * @param {Array<AssignmentParticipant>} params.participants Eligible people.
 * @param {Set<string>} params.blockedPairs Safety-blocked undirected pairs.
 * @param {number} params.groupCount Target number of groups.
 * @param {number} params.maxGroupSize Hard group size cap when safe.
 * @param {QuestionnaireScoringMode} params.questionnaireMode Answer weighting.
 * @return {Array<Array<T>>} Optimized groups.
 */
export function buildOptimizedGroups<
  T extends AssignmentParticipant
>(params: {
  participants: T[];
  blockedPairs: Set<string>;
  groupCount: number;
  maxGroupSize?: number;
  questionnaireMode?: QuestionnaireScoringMode;
  compatibilityPolicy?: EventSuccessCompatibilityPolicy;
}): T[][] {
  const groupCount = Math.max(1, params.groupCount);
  const maxGroupSize = params.maxGroupSize ??
    Math.max(1, Math.ceil(params.participants.length / groupCount));
  return optimizeEventSuccessAssignments({
    participants: params.participants,
    blockedPairs: params.blockedPairs,
    topology: {
      unitKind: "pods",
      unitSize: maxGroupSize,
      groupCount,
      maxGroupSize,
      rotationIntervalMinutes: null,
      rotationsEnabled: false,
    },
    assignmentAlgorithm: "socialPods",
    compatibilityPolicy: params.compatibilityPolicy,
    questionnaireMode: params.questionnaireMode,
  }).groups.map((group) => group.participants);
}

/**
 * Builds a deterministic undirected pair key.
 * @param {string} uidA First uid.
 * @param {string} uidB Second uid.
 * @return {string} Pair key.
 */
export function assignmentPairKey(uidA: string, uidB: string): string {
  return [uidA, uidB].sort().join("__");
}

/**
 * Builds assignment metrics that explain engine output and relaxations.
 * @param {object} params Explainability inputs.
 * @return {AssignmentEngineExplainability} Engine output metrics.
 */
function buildAssignmentEngineExplainability<
  T extends AssignmentParticipant
>(params: {
  plan: AssignmentPlanCore<T>;
  participants: T[];
  blockedPairs: Set<string>;
  topology: AssignmentTopology;
  questionnaireMode: QuestionnaireScoringMode;
  compatibilityPolicy: EventSuccessCompatibilityPolicy;
  constraints: NormalizedAssignmentConstraints;
  rotationPolicy: NormalizedAssignmentRotationPolicy;
  requestedRotationRoundCount: number;
}): AssignmentEngineExplainability {
  const assignedUids = assignedParticipantUids(params.plan);
  const dyadStats = generatedDyadStats({
    plan: params.plan,
    questionnaireMode: params.questionnaireMode,
    compatibilityPolicy: params.compatibilityPolicy,
  });
  const unassignedParticipantCount = Math.max(
    0,
    params.participants.length - assignedUids.size
  );
  const generatedRoundCount =
    params.plan.rotationRounds.length + params.plan.groupRounds.length;
  const groupSizeSkewValue = groupSizeSkew(params.plan);
  const compositionStats = groupCompositionStats({
    plan: params.plan,
    questionnaireMode: params.questionnaireMode,
    compatibilityPolicy: params.compatibilityPolicy,
  });
  const activityStats = activityAttributeStats({
    plan: params.plan,
    constraints: params.constraints,
  });
  const constraintEvaluations = [
    ...buildCoreConstraintEvaluations({
      plan: params.plan,
      blockedPairs: params.blockedPairs,
      topology: params.topology,
      compatibilityPolicy: params.compatibilityPolicy,
      dyadStats,
      groupSizeSkew: groupSizeSkewValue,
      compositionStats,
      activityStats,
      constraints: params.constraints,
    }),
    ...evaluateHostConstraints({
      groups: allGeneratedGroupUnits(params.plan),
      pairs: allGeneratedPairUnits(params.plan),
      constraints: params.constraints,
    }),
  ];
  const constraintRelaxations = new Set<AssignmentConstraintRelaxation>();
  if (
    params.participants.length > 0 &&
    params.participants.length < params.topology.unitSize &&
    params.topology.unitKind !== "wholeGroup"
  ) {
    constraintRelaxations.add("insufficient_participants");
  }
  if (dyadStats.orientationFallbackPairCount > 0) {
    constraintRelaxations.add("orientation_fallback_used");
  }
  if (dyadStats.repeatedPairCount > 0) {
    constraintRelaxations.add("repeated_pairs_required");
  }
  if (
    params.topology.rotationsEnabled &&
    generatedRoundCount < params.requestedRotationRoundCount
  ) {
    constraintRelaxations.add("rotations_not_generated");
  }
  if (unassignedParticipantCount > 0) {
    constraintRelaxations.add("unassigned_participants");
  }
  for (const evaluation of constraintEvaluations) {
    const relaxation = constraintRelaxationForEvaluation(evaluation);
    if (relaxation !== null) {
      constraintRelaxations.add(relaxation);
    }
  }

  return {
    participantCount: params.participants.length,
    assignedParticipantCount: assignedUids.size,
    unassignedParticipantCount,
    unitKind: params.topology.unitKind,
    targetUnitSize: params.topology.unitSize,
    targetGroupCount: params.topology.groupCount,
    rotationsEnabled: params.topology.rotationsEnabled,
    requestedRotationRoundCount: params.requestedRotationRoundCount,
    generatedRotationRoundCount: params.plan.rotationRounds.length,
    rotationRepeatStrategy: params.rotationPolicy.repeatStrategy,
    maxPairMeetings: params.rotationPolicy.maxPairMeetings,
    hostRequestedRepeatPairCount: params.constraints.requestedRepeatPairs.size,
    activityBalanceAttributeCount:
      params.constraints.balanceActivityAttributes.length,
    activityClusterAttributeCount:
      params.constraints.clusterActivityAttributes.length,
    activityMissingAttributeValueCount:
      activityStats.missingAttributeValueCount,
    activityBalanceSkew: activityStats.balanceSkew,
    activityClusterMixedGroupCount: activityStats.clusterMixedGroupCount,
    generatedGroupRoundCount: params.plan.groupRounds.length,
    generatedStaticGroupCount: params.plan.groups.length,
    blockedPairCount: params.blockedPairs.size,
    mutualDyadCount: dyadStats.mutualDyadCount,
    plausibleDyadCount: dyadStats.plausibleDyadCount,
    repeatedPairCount: dyadStats.repeatedPairCount,
    orientationFallbackPairCount: dyadStats.orientationFallbackPairCount,
    groupSizeSkew: groupSizeSkewValue,
    lowOpportunityGroupCount: compositionStats.lowOpportunityGroupCount,
    uncoveredParticipantAssignmentCount:
      compositionStats.uncoveredParticipantAssignmentCount,
    groupMutualDyadSkew: compositionStats.groupMutualDyadSkew,
    groupPlausibleDyadSkew: compositionStats.groupPlausibleDyadSkew,
    constraintEvaluations,
    satisfiedConstraintCount: countConstraintStatus(
      constraintEvaluations,
      "satisfied"
    ),
    relaxedConstraintCount: countConstraintStatus(
      constraintEvaluations,
      "relaxed"
    ),
    violatedConstraintCount: countConstraintStatus(
      constraintEvaluations,
      "violated"
    ),
    constraintRelaxations: [...constraintRelaxations],
  };
}

/**
 * Builds core hard and soft constraint evaluations.
 * @param {object} params Evaluation inputs.
 * @return {AssignmentConstraintEvaluation[]} Constraint evaluations.
 */
function buildCoreConstraintEvaluations<
  T extends AssignmentParticipant
>(params: {
  plan: AssignmentPlanCore<T>;
  blockedPairs: Set<string>;
  topology: AssignmentTopology;
  compatibilityPolicy: EventSuccessCompatibilityPolicy;
  dyadStats: {
    repeatedPairCount: number;
    orientationFallbackPairCount: number;
  };
  groupSizeSkew: number;
  compositionStats: GroupCompositionStats;
  activityStats: ActivityAttributeStats;
  constraints: NormalizedAssignmentConstraints;
}): AssignmentConstraintEvaluation[] {
  return [
    {
      key: "blocked_pair",
      category: "hard",
      status: generatedBlockedPairViolationCount(
        params.plan,
        params.blockedPairs
      ) > 0 ? "violated" : "satisfied",
      subjectUids: [],
    },
    {
      key: "unit_capacity",
      category: "hard",
      status: generatedCapacityViolationCount(
        params.plan,
        params.topology.maxGroupSize
      ) > 0 ? "violated" : "satisfied",
      subjectUids: [],
    },
    {
      key: "single_round_assignment",
      category: "hard",
      status: generatedDuplicateRoundAssignmentCount(params.plan) > 0 ?
        "violated" :
        "satisfied",
      subjectUids: [],
    },
    {
      key: "mutual_orientation",
      category: "strongSoft",
      status: params.compatibilityPolicy === "none" ?
        "not_applicable" :
        params.dyadStats.orientationFallbackPairCount > 0 ?
          "relaxed" :
          "satisfied",
      subjectUids: [],
    },
    {
      key: "questionnaire_affinity",
      category: "strongSoft",
      status: params.compatibilityPolicy === "questionnaireClueOnly" ?
        "satisfied" :
        "not_applicable",
      subjectUids: [],
    },
    {
      key: "repeat_pair",
      category: "strongSoft",
      status: params.topology.rotationsEnabled ?
        params.dyadStats.repeatedPairCount > 0 ? "relaxed" : "satisfied" :
        "not_applicable",
      subjectUids: [],
    },
    {
      key: "group_size_balance",
      category: "strongSoft",
      status: allGeneratedGroupUnits(params.plan).length === 0 ?
        "not_applicable" :
        params.groupSizeSkew > 1 ? "relaxed" : "satisfied",
      subjectUids: [],
    },
    {
      key: "group_opportunity_balance",
      category: "strongSoft",
      status: params.compatibilityPolicy === "none" ?
        "not_applicable" :
        allGeneratedGroupUnits(params.plan).length === 0 ?
          "not_applicable" :
          params.compositionStats.lowOpportunityGroupCount > 0 ?
            "relaxed" :
            "satisfied",
      subjectUids: [],
    },
    {
      key: "activity_attribute_balance",
      category: "formatDefaultSoft",
      status: params.constraints.balanceActivityAttributes.length === 0 ?
        "not_applicable" :
        params.activityStats.balanceSkew > 1 ||
          params.activityStats.balanceMissingAttributeValueCount > 0 ?
          "relaxed" :
          "satisfied",
      subjectUids: [],
    },
    {
      key: "activity_attribute_cluster",
      category: "formatDefaultSoft",
      status: params.constraints.clusterActivityAttributes.length === 0 ?
        "not_applicable" :
        params.activityStats.clusterMixedGroupCount > 0 ||
          params.activityStats.clusterMissingAttributeValueCount > 0 ?
          "relaxed" :
          "satisfied",
      subjectUids: [],
    },
  ];
}

/**
 * Maps non-satisfied evaluations to legacy relaxation identifiers.
 * @param {AssignmentConstraintEvaluation} evaluation Constraint evaluation.
 * @return {AssignmentConstraintRelaxation | null} Relaxation id.
 */
function constraintRelaxationForEvaluation(
  evaluation: AssignmentConstraintEvaluation
): AssignmentConstraintRelaxation | null {
  if (evaluation.status === "satisfied" ||
    evaluation.status === "not_applicable") {
    return null;
  }
  switch (evaluation.key) {
  case "activity_attribute_balance":
    return "activity_attribute_balance_relaxed";
  case "activity_attribute_cluster":
    return "activity_attribute_cluster_relaxed";
  case "blocked_pair":
    return "blocked_pair_violated";
  case "unit_capacity":
  case "single_round_assignment":
    return "hard_constraint_violation";
  case "mutual_orientation":
    return "orientation_fallback_used";
  case "repeat_pair":
    return "repeated_pairs_required";
  case "group_size_balance":
    return "group_size_imbalance";
  case "group_opportunity_balance":
    return "group_opportunity_imbalance";
  case "host_keep_together":
    return "host_keep_together_relaxed";
  case "host_keep_apart":
    return "host_keep_apart_violated";
  case "host_anchor":
    return "host_anchor_relaxed";
  case "questionnaire_affinity":
  default:
    return null;
  }
}

/**
 * Counts evaluations with a given status.
 * @param {AssignmentConstraintEvaluation[]} evaluations Evaluations.
 * @param {AssignmentConstraintStatus} status Status to count.
 * @return {number} Matching evaluation count.
 */
function countConstraintStatus(
  evaluations: AssignmentConstraintEvaluation[],
  status: AssignmentConstraintStatus
): number {
  return evaluations.filter((evaluation) => evaluation.status === status)
    .length;
}

/**
 * Collects attendees that appear in at least one generated assignment.
 * @param {AssignmentPlanCore<T>} plan Assignment plan.
 * @return {Set<string>} Assigned participant ids.
 */
function assignedParticipantUids<T extends AssignmentParticipant>(
  plan: AssignmentPlanCore<T>
): Set<string> {
  const uids = new Set<string>();
  for (const group of allGeneratedGroups(plan)) {
    for (const participant of group) {
      uids.add(participant.uid);
    }
  }
  for (const round of plan.rotationRounds) {
    for (const pair of round.pairs) {
      uids.add(pair.a.uid);
      uids.add(pair.b.uid);
    }
  }
  return uids;
}

/**
 * Counts generated blocked-pair violations.
 * @param {AssignmentPlanCore<T>} plan Assignment plan.
 * @param {Set<string>} blockedPairs Blocked pair keys.
 * @return {number} Violation count.
 */
function generatedBlockedPairViolationCount<T extends AssignmentParticipant>(
  plan: AssignmentPlanCore<T>,
  blockedPairs: Set<string>
): number {
  let violations = 0;
  for (const group of allGeneratedGroups(plan)) {
    for (const key of groupPairKeys(group)) {
      if (blockedPairs.has(key)) violations++;
    }
  }
  for (const pair of allGeneratedPairUnits(plan)) {
    if (blockedPairs.has(assignmentPairKey(pair.a.uid, pair.b.uid))) {
      violations++;
    }
  }
  return violations;
}

/**
 * Counts generated unit-capacity violations.
 * @param {AssignmentPlanCore<T>} plan Assignment plan.
 * @param {number} maxGroupSize Maximum group size.
 * @return {number} Violation count.
 */
function generatedCapacityViolationCount<T extends AssignmentParticipant>(
  plan: AssignmentPlanCore<T>,
  maxGroupSize: number
): number {
  return allGeneratedGroups(plan)
    .filter((group) => group.length > maxGroupSize)
    .length;
}

/**
 * Counts duplicate attendee assignments inside generated rounds.
 * @param {AssignmentPlanCore<T>} plan Assignment plan.
 * @return {number} Duplicate count.
 */
function generatedDuplicateRoundAssignmentCount<
  T extends AssignmentParticipant
>(plan: AssignmentPlanCore<T>): number {
  let duplicates = 0;
  for (const round of plan.rotationRounds) {
    duplicates += duplicateUidCount(
      round.pairs.flatMap((pair) => [pair.a.uid, pair.b.uid])
    );
  }
  for (const round of plan.groupRounds) {
    duplicates += duplicateUidCount(
      round.groups.flatMap((group) =>
        group.participants.map((participant) => participant.uid)
      )
    );
  }
  return duplicates;
}

/**
 * Counts duplicate ids in a list.
 * @param {string[]} uids Uids.
 * @return {number} Duplicate count.
 */
function duplicateUidCount(uids: string[]): number {
  const seen = new Set<string>();
  let duplicates = 0;
  for (const uid of uids) {
    if (seen.has(uid)) {
      duplicates++;
    } else {
      seen.add(uid);
    }
  }
  return duplicates;
}

/**
 * Computes dyad-level output metrics across groups and pair rounds.
 * @param {object} params Generated plan and scoring inputs.
 * @return {object} Dyad metrics.
 */
function generatedDyadStats<T extends AssignmentParticipant>(params: {
  plan: AssignmentPlanCore<T>;
  questionnaireMode: QuestionnaireScoringMode;
  compatibilityPolicy: EventSuccessCompatibilityPolicy;
}): {
  mutualDyadCount: number;
  plausibleDyadCount: number;
  repeatedPairCount: number;
  orientationFallbackPairCount: number;
} {
  let mutualDyadCount = 0;
  let plausibleDyadCount = 0;
  let orientationFallbackPairCount = 0;
  const seenPairs = new Set<string>();
  let repeatedPairCount = 0;

  const recordPair = (
    a: T,
    b: T,
    mutualInterest: boolean,
    plausible: boolean,
    directPairAssignment: boolean
  ) => {
    const key = assignmentPairKey(a.uid, b.uid);
    if (seenPairs.has(key)) {
      repeatedPairCount++;
    } else {
      seenPairs.add(key);
    }
    if (mutualInterest) mutualDyadCount++;
    if (plausible) plausibleDyadCount++;
    if (
      directPairAssignment &&
      params.compatibilityPolicy !== "none" &&
      plausible &&
      !mutualInterest
    ) {
      orientationFallbackPairCount++;
    }
  };

  for (const group of allGeneratedGroups(params.plan)) {
    for (let i = 0; i < group.length; i++) {
      for (let j = i + 1; j < group.length; j++) {
        const scored = scorePairForOptimizer(group[i], group[j], {
          questionnaireMode: params.questionnaireMode,
          compatibilityPolicy: params.compatibilityPolicy,
          allowOrientationFallback: true,
        });
        recordPair(
          group[i],
          group[j],
          scored.mutualInterest,
          scored.score > 0,
          false
        );
      }
    }
  }
  for (const round of params.plan.rotationRounds) {
    for (const pair of round.pairs) {
      recordPair(pair.a, pair.b, pair.mutualInterest, pair.score > 0, true);
    }
  }

  return {
    mutualDyadCount,
    plausibleDyadCount,
    repeatedPairCount,
    orientationFallbackPairCount,
  };
}

/**
 * Flattens static and rotating group assignments.
 * @param {AssignmentPlanCore<T>} plan Assignment plan.
 * @return {Array<Array<T>>} Generated groups.
 */
function allGeneratedGroups<T extends AssignmentParticipant>(
  plan: AssignmentPlanCore<T>
): T[][] {
  return [
    ...plan.groups.map((group) => group.participants),
    ...plan.groupRounds.flatMap((round) =>
      round.groups.map((group) => group.participants)
    ),
  ];
}

/**
 * Flattens generated groups while preserving group indexes.
 * @param {AssignmentPlanCore<T>} plan Assignment plan.
 * @return {Array<object>} Generated group units.
 */
function allGeneratedGroupUnits<T extends AssignmentParticipant>(
  plan: AssignmentPlanCore<T>
): Array<{groupIndex: number; participants: T[]}> {
  return [
    ...plan.groups.map((group) => ({
      groupIndex: group.groupIndex,
      participants: group.participants,
    })),
    ...plan.groupRounds.flatMap((round) =>
      round.groups.map((group) => ({
        groupIndex: group.groupIndex,
        participants: group.participants,
      }))
    ),
  ];
}

/**
 * Flattens generated pair rotation units.
 * @param {AssignmentPlanCore<T>} plan Assignment plan.
 * @return {Array<object>} Generated pair units.
 */
function allGeneratedPairUnits<T extends AssignmentParticipant>(
  plan: AssignmentPlanCore<T>
): Array<{a: T; b: T}> {
  return plan.rotationRounds.flatMap((round) =>
    round.pairs.map((pair) => ({a: pair.a, b: pair.b}))
  );
}

/**
 * Summarizes composition balance across generated groups.
 * @param {object} params Composition inputs.
 * @return {GroupCompositionStats} Composition metrics.
 */
function groupCompositionStats<T extends AssignmentParticipant>(params: {
  plan: AssignmentPlanCore<T>;
  questionnaireMode: QuestionnaireScoringMode;
  compatibilityPolicy: EventSuccessCompatibilityPolicy;
}): GroupCompositionStats {
  const profiles = allGeneratedGroups(params.plan)
    .filter((group) => group.length > 0)
    .map((group) => groupCompositionProfile({
      group,
      questionnaireMode: params.questionnaireMode,
      compatibilityPolicy: params.compatibilityPolicy,
    }));
  return {
    lowOpportunityGroupCount: profiles.filter((profile) =>
      isLowOpportunityGroup(profile)
    ).length,
    uncoveredParticipantAssignmentCount: profiles.reduce(
      (sum, profile) => sum + profile.uncoveredParticipantCount,
      0
    ),
    groupMutualDyadSkew: numericSkew(
      profiles.map((profile) => profile.mutualDyadCount)
    ),
    groupPlausibleDyadSkew: numericSkew(
      profiles.map((profile) => profile.plausibleDyadCount)
    ),
  };
}

/**
 * Summarizes activity-attribute constraint quality across generated units.
 * @param {object} params Activity metric inputs.
 * @return {ActivityAttributeStats} Activity constraint metrics.
 */
function activityAttributeStats<T extends AssignmentParticipant>(params: {
  plan: AssignmentPlanCore<T>;
  constraints: NormalizedAssignmentConstraints;
}): ActivityAttributeStats {
  const units = allGeneratedActivityUnits(params.plan)
    .filter((group) => group.length > 0);
  const balanceMissingAttributeValueCount = missingActivityValueCount(
    units,
    params.constraints.balanceActivityAttributes
  );
  const clusterMissingAttributeValueCount = missingActivityValueCount(
    units,
    params.constraints.clusterActivityAttributes
  );
  return {
    missingAttributeValueCount:
      balanceMissingAttributeValueCount + clusterMissingAttributeValueCount,
    balanceMissingAttributeValueCount,
    clusterMissingAttributeValueCount,
    balanceSkew: activityBalanceSkew(
      units,
      params.constraints.balanceActivityAttributes
    ),
    clusterMixedGroupCount: activityClusterMixedGroupCount(
      units,
      params.constraints.clusterActivityAttributes
    ),
  };
}

/**
 * Flattens generated groups and direct pair rotations as activity units.
 * @param {AssignmentPlanCore<T>} plan Assignment plan.
 * @return {Array<Array<T>>} Generated units.
 */
function allGeneratedActivityUnits<T extends AssignmentParticipant>(
  plan: AssignmentPlanCore<T>
): T[][] {
  return [
    ...allGeneratedGroups(plan),
    ...plan.rotationRounds.flatMap((round) =>
      round.pairs.map((pair) => [pair.a, pair.b])
    ),
  ];
}

/**
 * Counts missing activity values for configured attributes.
 * @param {Array<Array<T>>} units Generated units.
 * @param {string[]} attributes Configured attribute names.
 * @return {number} Missing value count.
 */
function missingActivityValueCount<T extends AssignmentParticipant>(
  units: T[][],
  attributes: string[]
): number {
  let count = 0;
  for (const unit of units) {
    for (const participant of unit) {
      for (const attribute of attributes) {
        if (activityValue(participant, attribute) === null) count++;
      }
    }
  }
  return count;
}

/**
 * Returns the largest group-count skew for balanced activity values.
 * @param {Array<Array<T>>} units Generated units.
 * @param {string[]} attributes Configured attribute names.
 * @return {number} Max count skew.
 */
function activityBalanceSkew<T extends AssignmentParticipant>(
  units: T[][],
  attributes: string[]
): number {
  let maxSkew = 0;
  for (const attribute of attributes) {
    const observedValues = new Set<string>();
    const countsByUnit = units.map((unit) => {
      const counts = new Map<string, number>();
      for (const participant of unit) {
        const value = activityValue(participant, attribute);
        if (value === null) continue;
        observedValues.add(value);
        counts.set(value, (counts.get(value) ?? 0) + 1);
      }
      return counts;
    });
    for (const value of observedValues) {
      maxSkew = Math.max(
        maxSkew,
        numericSkew(countsByUnit.map((counts) => counts.get(value) ?? 0))
      );
    }
  }
  return maxSkew;
}

/**
 * Counts units that mix values for clustered activity attributes.
 * @param {Array<Array<T>>} units Generated units.
 * @param {string[]} attributes Configured attribute names.
 * @return {number} Mixed unit count.
 */
function activityClusterMixedGroupCount<T extends AssignmentParticipant>(
  units: T[][],
  attributes: string[]
): number {
  let count = 0;
  for (const unit of units) {
    for (const attribute of attributes) {
      const values = new Set(
        unit
          .map((participant) => activityValue(participant, attribute))
          .filter((value): value is string => value !== null)
      );
      if (values.size > 1) count++;
    }
  }
  return count;
}

/**
 * Builds a composition profile for one group.
 * @param {object} params Group composition inputs.
 * @return {GroupCompositionProfile} Group composition profile.
 */
function groupCompositionProfile<T extends AssignmentParticipant>(params: {
  group: T[];
  questionnaireMode: QuestionnaireScoringMode;
  compatibilityPolicy: EventSuccessCompatibilityPolicy;
}): GroupCompositionProfile {
  let mutualDyadCount = 0;
  let plausibleDyadCount = 0;
  const mutualCountsByUid = new Map(
    params.group.map((participant) => [participant.uid, 0])
  );
  for (let i = 0; i < params.group.length; i++) {
    for (let j = i + 1; j < params.group.length; j++) {
      const scored = scorePairForOptimizer(params.group[i], params.group[j], {
        questionnaireMode: params.questionnaireMode,
        compatibilityPolicy: params.compatibilityPolicy,
        allowOrientationFallback: true,
      });
      if (scored.mutualInterest) {
        mutualDyadCount++;
        mutualCountsByUid.set(
          params.group[i].uid,
          (mutualCountsByUid.get(params.group[i].uid) ?? 0) + 1
        );
        mutualCountsByUid.set(
          params.group[j].uid,
          (mutualCountsByUid.get(params.group[j].uid) ?? 0) + 1
        );
      }
      if (
        scored.mutualInterest ||
        scored.oneWayInterest ||
        scored.compatibility === "social"
      ) {
        plausibleDyadCount++;
      }
    }
  }
  const participantsWithMutualCount = [...mutualCountsByUid.values()]
    .filter((count) => count > 0)
    .length;
  return {
    participantCount: params.group.length,
    mutualDyadCount,
    plausibleDyadCount,
    participantsWithMutualCount,
    uncoveredParticipantCount: params.group.length -
      participantsWithMutualCount,
    dominantGenderShare: dominantGenderShare(params.group),
  };
}

/**
 * Returns whether a group has no internal mutual opportunity.
 * @param {GroupCompositionProfile} profile Group composition profile.
 * @return {boolean} Whether the group is low-opportunity.
 */
function isLowOpportunityGroup(profile: GroupCompositionProfile): boolean {
  return profile.participantCount > 1 &&
    profile.uncoveredParticipantCount > 0 &&
    profile.mutualDyadCount === 0;
}

/**
 * Returns max-min skew for a numeric series.
 * @param {number[]} values Values.
 * @return {number} Skew.
 */
function numericSkew(values: number[]): number {
  if (values.length === 0) return 0;
  return Math.max(...values) - Math.min(...values);
}

/**
 * Returns the largest gender bucket share in a group.
 * @param {Array<AssignmentParticipant>} group Group participants.
 * @return {number} Dominant gender share from 0 to 1.
 */
function dominantGenderShare(group: AssignmentParticipant[]): number {
  if (group.length === 0) return 0;
  const counts = new Map<string, number>();
  for (const participant of group) {
    const gender = participant.gender?.trim() || "unknown";
    counts.set(gender, (counts.get(gender) ?? 0) + 1);
  }
  return Math.max(...counts.values()) / group.length;
}

/**
 * Returns max-min group size skew for generated groups.
 * @param {AssignmentPlanCore<T>} plan Assignment plan.
 * @return {number} Size skew.
 */
function groupSizeSkew<T extends AssignmentParticipant>(
  plan: AssignmentPlanCore<T>
): number {
  const sizes = allGeneratedGroups(plan)
    .map((group) => group.length)
    .filter((size) => size > 0);
  if (sizes.length === 0) return 0;
  return Math.max(...sizes) - Math.min(...sizes);
}

/**
 * Derives a default assignment primitive from topology when callers omit one.
 * @param {AssignmentTopology} topology Resolved group topology.
 * @return {EventSuccessAssignmentAlgorithm} Assignment primitive.
 */
function assignmentAlgorithmForTopology(
  topology: AssignmentTopology
): EventSuccessAssignmentAlgorithm {
  if (topology.rotationsEnabled && topology.unitSize === 2) {
    return "pairRotations";
  }
  switch (topology.unitKind) {
  case "pairs":
    return "pairRotations";
  case "teams":
    return "teamBalancer";
  case "tables":
    return "tableSeating";
  case "pods":
    return "socialPods";
  case "wholeGroup":
  default:
    return "none";
  }
}

/**
 * Applies questionnaire policy to caller-provided scoring mode.
 * @param {QuestionnaireScoringMode} requested Requested questionnaire mode.
 * @param {EventSuccessCompatibilityPolicy} policy Compatibility primitive.
 * @return {QuestionnaireScoringMode} Effective questionnaire mode.
 */
function questionnaireModeForPolicy(
  requested: QuestionnaireScoringMode,
  policy: EventSuccessCompatibilityPolicy
): QuestionnaireScoringMode {
  if (policy === "none") {
    return "icebreaker";
  }
  return requested;
}

/**
 * Normalizes repeat policy defaults.
 * @param {AssignmentRotationPolicy} policy Requested repeat policy.
 * @return {NormalizedAssignmentRotationPolicy} Normalized policy.
 */
function normalizeRotationPolicy(
  policy?: AssignmentRotationPolicy
): NormalizedAssignmentRotationPolicy {
  return {
    repeatStrategy: policy?.repeatStrategy ?? "avoid",
    maxPairMeetings: Math.max(
      1,
      Math.floor(policy?.maxPairMeetings ?? 2)
    ),
  };
}

/**
 * Scores a pair according to the event-success compatibility primitive.
 * @param {AssignmentParticipant} a First participant.
 * @param {AssignmentParticipant} b Second participant.
 * @param {object} options Scoring options.
 * @return {object} Pair score.
 */
function scorePairForOptimizer(
  a: AssignmentParticipant,
  b: AssignmentParticipant,
  options: {
    questionnaireMode: QuestionnaireScoringMode;
    compatibilityPolicy: EventSuccessCompatibilityPolicy;
    allowOrientationFallback: boolean;
  }
): ReturnType<typeof scoreDatingCompatibilityPair> {
  if (options.compatibilityPolicy === "none") {
    return {
      score: 1,
      compatibility: "social",
      mutualInterest: false,
      oneWayInterest: false,
      orientationCompatible: false,
      sharedAnswerCount: 0,
    };
  }
  return scoreDatingCompatibilityPair(a, b, {
    questionnaireMode: questionnaireModeForPolicy(
      options.questionnaireMode,
      options.compatibilityPolicy
    ),
    allowOrientationFallback: options.allowOrientationFallback,
  });
}

/**
 * Builds pair-rotation rounds for the unified optimizer.
 * @param {object} params Pair rotation inputs.
 * @return {Array<OptimizedRotationRound<T>>} Rotation rounds.
 */
function buildRotationRoundsForOptimizer<
  T extends AssignmentParticipant
>(params: {
  participants: T[];
  blockedPairs: Set<string>;
  roundCount: number;
  questionnaireMode: QuestionnaireScoringMode;
  compatibilityPolicy: EventSuccessCompatibilityPolicy;
  allowOrientationFallback: boolean;
  constraints: NormalizedAssignmentConstraints;
  rotationPolicy: NormalizedAssignmentRotationPolicy;
}): Array<OptimizedRotationRound<T>> {
  if (params.participants.length < 2 || params.roundCount <= 0) return [];
  const seenPairs = new Set<string>();
  const pairMeetingCounts = new Map<string, number>();
  const meetingCounts = new Map(
    params.participants.map((participant) => [participant.uid, 0])
  );
  const breakCounts = new Map(
    params.participants.map((participant) => [participant.uid, 0])
  );
  const rounds: Array<OptimizedRotationRound<T>> = [];

  for (let roundIndex = 0; roundIndex < params.roundCount; roundIndex++) {
    const usedUids = new Set<string>();
    const roundPairs: Array<OptimizedPair<T>> = [];
    const candidatePairs = allCandidatePairs({
      participants: params.participants,
      blockedPairs: params.blockedPairs,
      questionnaireMode: params.questionnaireMode,
      compatibilityPolicy: params.compatibilityPolicy,
      allowOrientationFallback: params.allowOrientationFallback,
      constraints: params.constraints,
      pairMeetingCounts,
      rotationPolicy: params.rotationPolicy,
      candidateMode: "uniqueOnly",
    });
    selectPairsByCompatibilityTier({
      candidates: candidatePairs.filter((pair) => pair.mutualInterest),
      usedUids,
      roundPairs,
      seenPairs,
      pairMeetingCounts,
      meetingCounts,
      breakCounts,
    });
    if (params.allowOrientationFallback) {
      selectPairsByCompatibilityTier({
        candidates: candidatePairs.filter((pair) =>
          !pair.mutualInterest && pair.compatibility !== "social"
        ),
        usedUids,
        roundPairs,
        seenPairs,
        pairMeetingCounts,
        meetingCounts,
        breakCounts,
      });
      selectPairsByCompatibilityTier({
        candidates: candidatePairs.filter((pair) =>
          pair.compatibility === "social" &&
          pairNeedsFirstConnection(pair, meetingCounts)
        ),
        usedUids,
        roundPairs,
        seenPairs,
        pairMeetingCounts,
        meetingCounts,
        breakCounts,
      });
    }
    const repeatCandidates = allCandidatePairs({
      participants: params.participants,
      blockedPairs: params.blockedPairs,
      questionnaireMode: params.questionnaireMode,
      compatibilityPolicy: params.compatibilityPolicy,
      allowOrientationFallback: params.allowOrientationFallback,
      constraints: params.constraints,
      pairMeetingCounts,
      rotationPolicy: params.rotationPolicy,
      candidateMode: "repeatOnly",
    });
    selectPairsByCompatibilityTier({
      candidates: repeatCandidates.filter((pair) => pair.mutualInterest),
      usedUids,
      roundPairs,
      seenPairs,
      pairMeetingCounts,
      meetingCounts,
      breakCounts,
    });
    if (params.allowOrientationFallback) {
      selectPairsByCompatibilityTier({
        candidates: repeatCandidates.filter((pair) =>
          !pair.mutualInterest && pair.compatibility !== "social"
        ),
        usedUids,
        roundPairs,
        seenPairs,
        pairMeetingCounts,
        meetingCounts,
        breakCounts,
      });
      selectPairsByCompatibilityTier({
        candidates: repeatCandidates.filter((pair) =>
          pair.compatibility === "social"
        ),
        usedUids,
        roundPairs,
        seenPairs,
        pairMeetingCounts,
        meetingCounts,
        breakCounts,
      });
    }
    if (roundPairs.length === 0) break;
    for (const participant of params.participants) {
      if (!usedUids.has(participant.uid)) {
        breakCounts.set(
          participant.uid,
          (breakCounts.get(participant.uid) ?? 0) + 1
        );
      }
    }
    rounds.push({roundIndex, pairs: roundPairs});
  }
  return rounds;
}

/**
 * Builds group units for the unified optimizer.
 * @param {object} params Group assignment inputs.
 * @return {Array<OptimizedGroup<T>>} Optimized groups with score metadata.
 */
function buildGroupUnitsForOptimizer<
  T extends AssignmentParticipant
>(params: {
  participants: T[];
  blockedPairs: Set<string>;
  groupCount: number;
  maxGroupSize: number;
  questionnaireMode: QuestionnaireScoringMode;
  compatibilityPolicy: EventSuccessCompatibilityPolicy;
  seenPairs?: Set<string>;
  constraints: NormalizedAssignmentConstraints;
  rotationPolicy: NormalizedAssignmentRotationPolicy;
  pairMeetingCounts?: Map<string, number>;
}): Array<OptimizedGroup<T>> {
  if (params.participants.length === 0) return [];
  const groups = Array.from(
    {length: params.groupCount},
    () => [] as T[]
  );
  const orderedParticipants = constrainedParticipantsFirst(
    params.participants,
    params.blockedPairs,
    params.questionnaireMode,
    params.compatibilityPolicy,
    params.constraints
  );

  for (const participant of orderedParticipants) {
    const candidates = groups
      .map((group, index) => ({group, index}))
      .sort((a, b) =>
        groupPlacementCost({
          participant,
          group: a.group,
          blockedPairs: params.blockedPairs,
          questionnaireMode: params.questionnaireMode,
          compatibilityPolicy: params.compatibilityPolicy,
          seenPairs: params.seenPairs,
          maxGroupSize: params.maxGroupSize,
          constraints: params.constraints,
          rotationPolicy: params.rotationPolicy,
          pairMeetingCounts: params.pairMeetingCounts,
          groupIndex: a.index,
          groups,
        }) -
        groupPlacementCost({
          participant,
          group: b.group,
          blockedPairs: params.blockedPairs,
          questionnaireMode: params.questionnaireMode,
          compatibilityPolicy: params.compatibilityPolicy,
          seenPairs: params.seenPairs,
          maxGroupSize: params.maxGroupSize,
          constraints: params.constraints,
          rotationPolicy: params.rotationPolicy,
          pairMeetingCounts: params.pairMeetingCounts,
          groupIndex: b.index,
          groups,
        }) ||
        a.index - b.index
      );
    const selected = candidates.find(({group}) =>
      canJoinGroup(
        participant,
        group,
        params.blockedPairs,
        params.constraints
      ) &&
      group.length < params.maxGroupSize
    );
    if (selected === undefined) {
      groups.push([participant]);
    } else {
      selected.group.push(participant);
    }
  }

  return groups
    .map((group, index) => groupSummary({
      group,
      index,
      questionnaireMode: params.questionnaireMode,
      compatibilityPolicy: params.compatibilityPolicy,
    }))
    .filter((group) => group.participants.length > 0);
}

/**
 * Builds rotating group units while penalizing repeated pair co-membership.
 * @param {object} params Group rotation inputs.
 * @return {Array<OptimizedGroupRound<T>>} Group rounds.
 */
function buildGroupRoundsForOptimizer<
  T extends AssignmentParticipant
>(params: {
  participants: T[];
  blockedPairs: Set<string>;
  groupCount: number;
  maxGroupSize: number;
  questionnaireMode: QuestionnaireScoringMode;
  compatibilityPolicy: EventSuccessCompatibilityPolicy;
  roundCount: number;
  constraints: NormalizedAssignmentConstraints;
  rotationPolicy: NormalizedAssignmentRotationPolicy;
}): Array<OptimizedGroupRound<T>> {
  if (params.participants.length === 0 || params.roundCount <= 0) return [];
  const seenPairs = new Set<string>();
  const pairMeetingCounts = new Map<string, number>();
  const rounds: Array<OptimizedGroupRound<T>> = [];
  for (let roundIndex = 0; roundIndex < params.roundCount; roundIndex++) {
    const groups = buildGroupUnitsForOptimizer({
      participants: params.participants,
      blockedPairs: params.blockedPairs,
      groupCount: params.groupCount,
      maxGroupSize: params.maxGroupSize,
      questionnaireMode: params.questionnaireMode,
      compatibilityPolicy: params.compatibilityPolicy,
      seenPairs,
      constraints: params.constraints,
      rotationPolicy: params.rotationPolicy,
      pairMeetingCounts,
    });
    if (groups.length === 0) break;
    for (const group of groups) {
      for (const key of groupPairKeys(group.participants)) {
        seenPairs.add(key);
        pairMeetingCounts.set(key, (pairMeetingCounts.get(key) ?? 0) + 1);
      }
    }
    rounds.push({roundIndex, groups});
  }
  return rounds;
}

/**
 * Selects compatible candidate pairs for one rotation tier.
 * @param {object} params Selection inputs.
 */
function selectPairsByCompatibilityTier<T extends AssignmentParticipant>(
  params: {
  candidates: Array<OptimizedPair<T>>;
  usedUids: Set<string>;
  roundPairs: Array<OptimizedPair<T>>;
  seenPairs: Set<string>;
  pairMeetingCounts: Map<string, number>;
  meetingCounts: Map<string, number>;
  breakCounts: Map<string, number>;
}): void {
  let available = params.candidates.filter((pair) =>
    !params.usedUids.has(pair.a.uid) &&
    !params.usedUids.has(pair.b.uid)
  );
  while (available.length > 0) {
    const pair = available.sort((a, b) =>
      compareRotationPairsForRound({
        a,
        b,
        candidates: available,
        usedUids: params.usedUids,
        meetingCounts: params.meetingCounts,
        breakCounts: params.breakCounts,
      })
    )[0];
    params.roundPairs.push(pair);
    params.usedUids.add(pair.a.uid);
    params.usedUids.add(pair.b.uid);
    const pairKey = assignmentPairKey(pair.a.uid, pair.b.uid);
    params.seenPairs.add(pairKey);
    params.pairMeetingCounts.set(
      pairKey,
      (params.pairMeetingCounts.get(pairKey) ?? 0) + 1
    );
    params.meetingCounts.set(
      pair.a.uid,
      (params.meetingCounts.get(pair.a.uid) ?? 0) + 1
    );
    params.meetingCounts.set(
      pair.b.uid,
      (params.meetingCounts.get(pair.b.uid) ?? 0) + 1
    );
    available = params.candidates.filter((candidate) =>
      !params.usedUids.has(candidate.a.uid) &&
      !params.usedUids.has(candidate.b.uid)
    );
  }
}

/**
 * Builds all candidate pairs for one optimization pass.
 * @param {object} params Candidate generation inputs.
 * @return {Array<OptimizedPair<T>>} Candidate pairs.
 */
function allCandidatePairs<T extends AssignmentParticipant>(params: {
  participants: T[];
  blockedPairs: Set<string>;
  questionnaireMode: QuestionnaireScoringMode;
  compatibilityPolicy: EventSuccessCompatibilityPolicy;
  allowOrientationFallback: boolean;
  constraints: NormalizedAssignmentConstraints;
  pairMeetingCounts: Map<string, number>;
  rotationPolicy: NormalizedAssignmentRotationPolicy;
  candidateMode: "uniqueOnly" | "repeatOnly";
}): Array<OptimizedPair<T>> {
  const pairs: Array<OptimizedPair<T>> = [];
  for (let i = 0; i < params.participants.length; i++) {
    for (let j = i + 1; j < params.participants.length; j++) {
      const a = params.participants[i];
      const b = params.participants[j];
      const key = assignmentPairKey(a.uid, b.uid);
      if (params.blockedPairs.has(key)) continue;
      if (isKeepApartPair(a.uid, b.uid, params.constraints)) continue;
      const previousMeetingCount = params.pairMeetingCounts.get(key) ?? 0;
      if (
        !canUsePairForCandidateMode({
          key,
          previousMeetingCount,
          mode: params.candidateMode,
          constraints: params.constraints,
          rotationPolicy: params.rotationPolicy,
        })
      ) {
        continue;
      }
      const scored = scorePairForOptimizer(a, b, {
        questionnaireMode: params.questionnaireMode,
        compatibilityPolicy: params.compatibilityPolicy,
        allowOrientationFallback: params.allowOrientationFallback,
      });
      if (scored.score <= 0) continue;
      pairs.push({
        a,
        b,
        score: scored.score +
          hostPairScoreAdjustment(a.uid, b.uid, params.constraints) +
          activityPairScoreAdjustment({
            a,
            b,
            constraints: params.constraints,
          }) +
          repeatPairScoreAdjustment({
            uidA: a.uid,
            uidB: b.uid,
            previousMeetingCount,
            constraints: params.constraints,
          }),
        compatibility: scored.compatibility,
        mutualInterest: scored.mutualInterest,
        orientationCompatible: scored.orientationCompatible,
      });
    }
  }
  return pairs;
}

/**
 * Returns whether a pair is eligible for the candidate pass.
 * @param {object} params Candidate mode inputs.
 * @return {boolean} Whether the pair can be considered.
 */
function canUsePairForCandidateMode(params: {
  key: string;
  previousMeetingCount: number;
  mode: "uniqueOnly" | "repeatOnly";
  constraints: NormalizedAssignmentConstraints;
  rotationPolicy: NormalizedAssignmentRotationPolicy;
}): boolean {
  if (params.mode === "uniqueOnly") {
    return params.previousMeetingCount === 0;
  }
  if (params.previousMeetingCount === 0) return false;
  if (params.previousMeetingCount >= params.rotationPolicy.maxPairMeetings) {
    return false;
  }
  if (params.constraints.requestedRepeatPairs.has(params.key)) {
    return true;
  }
  return params.rotationPolicy.repeatStrategy === "allowWhenExhausted";
}

/**
 * Scores repeat candidates below fresh candidates unless host-requested.
 * @param {object} params Repeat score inputs.
 * @return {number} Score adjustment.
 */
function repeatPairScoreAdjustment(params: {
  uidA: string;
  uidB: string;
  previousMeetingCount: number;
  constraints: NormalizedAssignmentConstraints;
}): number {
  if (params.previousMeetingCount === 0) return 0;
  return -140 * params.previousMeetingCount +
    hostRequestedRepeatPairScoreAdjustment(
      params.uidA,
      params.uidB,
      params.constraints
    );
}

/**
 * Scores repeated group co-membership under the rotation repeat policy.
 * @param {object} params Repeat placement inputs.
 * @return {number} Cost where lower is better.
 */
function groupRepeatPairPlacementPenalty(params: {
  uidA: string;
  uidB: string;
  previousMeetingCount: number;
  constraints: NormalizedAssignmentConstraints;
  rotationPolicy: NormalizedAssignmentRotationPolicy;
}): number {
  const basePenalty = params.rotationPolicy.repeatStrategy ===
    "allowWhenExhausted" ?
    30 :
    REPEATED_GROUP_PAIR_PENALTY;
  return Math.max(
    0,
    basePenalty * params.previousMeetingCount -
      hostRequestedRepeatPairScoreAdjustment(
        params.uidA,
        params.uidB,
        params.constraints
      )
  );
}

/**
 * Orders candidate pairs using fairness before score.
 * @param {object} params Comparison inputs.
 * @return {number} Sort comparison.
 */
function compareRotationPairsForRound<T extends AssignmentParticipant>(params: {
  a: OptimizedPair<T>;
  b: OptimizedPair<T>;
  candidates: Array<OptimizedPair<T>>;
  usedUids: Set<string>;
  meetingCounts: Map<string, number>;
  breakCounts: Map<string, number>;
}): number {
  const capacityDelta = params.candidates.length <=
    ROUND_CAPACITY_LOOKAHEAD_LIMIT ?
    remainingRoundCapacity(params.b, params.candidates, params.usedUids) -
      remainingRoundCapacity(params.a, params.candidates, params.usedUids) :
    0;
  return capacityDelta ||
    pairMinMeetings(params.a, params.meetingCounts) -
    pairMinMeetings(params.b, params.meetingCounts) ||
    params.b.score - params.a.score ||
    pairBreakLoad(params.b, params.breakCounts) -
    pairBreakLoad(params.a, params.breakCounts) ||
    pairLoad(params.a, params.meetingCounts) -
    pairLoad(params.b, params.meetingCounts) ||
    assignmentPairKey(params.a.a.uid, params.a.b.uid)
      .localeCompare(assignmentPairKey(params.b.a.uid, params.b.b.uid));
}

/**
 * Estimates how many more non-overlapping pairs remain after choosing a pair.
 * @param {OptimizedPair<T>} selected Pair being considered.
 * @param {Array<OptimizedPair<T>>} candidates Same-tier candidate pool.
 * @param {Set<string>} usedUids Uids already used in this round.
 * @return {number} Additional pair capacity.
 */
function remainingRoundCapacity<T extends AssignmentParticipant>(
  selected: OptimizedPair<T>,
  candidates: Array<OptimizedPair<T>>,
  usedUids: Set<string>
): number {
  const unavailableUids = new Set(usedUids);
  unavailableUids.add(selected.a.uid);
  unavailableUids.add(selected.b.uid);
  let capacity = 0;
  let available = candidates.filter((pair) =>
    !unavailableUids.has(pair.a.uid) &&
    !unavailableUids.has(pair.b.uid)
  );
  while (available.length > 0) {
    const degrees = participantPairDegrees(available);
    const pair = available.sort((a, b) =>
      pairDegreeLoad(a, degrees) - pairDegreeLoad(b, degrees) ||
      b.score - a.score ||
      assignmentPairKey(a.a.uid, a.b.uid)
        .localeCompare(assignmentPairKey(b.a.uid, b.b.uid))
    )[0];
    unavailableUids.add(pair.a.uid);
    unavailableUids.add(pair.b.uid);
    capacity++;
    available = candidates.filter((candidate) =>
      !unavailableUids.has(candidate.a.uid) &&
      !unavailableUids.has(candidate.b.uid)
    );
  }
  return capacity;
}

/**
 * Counts available candidate-pair degree by participant.
 * @param {Array<OptimizedPair<T>>} candidates Candidate pairs.
 * @return {Map<string, number>} Pair degrees by uid.
 */
function participantPairDegrees<T extends AssignmentParticipant>(
  candidates: Array<OptimizedPair<T>>
): Map<string, number> {
  const degrees = new Map<string, number>();
  for (const pair of candidates) {
    degrees.set(pair.a.uid, (degrees.get(pair.a.uid) ?? 0) + 1);
    degrees.set(pair.b.uid, (degrees.get(pair.b.uid) ?? 0) + 1);
  }
  return degrees;
}

/**
 * Returns a pair's degree load in the current candidate graph.
 * @param {OptimizedPair<T>} pair Candidate pair.
 * @param {Map<string, number>} degrees Candidate degree by uid.
 * @return {number} Degree load.
 */
function pairDegreeLoad<T extends AssignmentParticipant>(
  pair: OptimizedPair<T>,
  degrees: Map<string, number>
): number {
  return (degrees.get(pair.a.uid) ?? 0) +
    (degrees.get(pair.b.uid) ?? 0);
}

/**
 * Returns the lower exposure count inside a candidate pair.
 * @param {OptimizedPair<T>} pair Candidate pair.
 * @param {Map<string, number>} meetingCounts Meeting counts by uid.
 * @return {number} Lower meeting count.
 */
function pairMinMeetings<T extends AssignmentParticipant>(
  pair: OptimizedPair<T>,
  meetingCounts: Map<string, number>
): number {
  return Math.min(
    meetingCounts.get(pair.a.uid) ?? 0,
    meetingCounts.get(pair.b.uid) ?? 0
  );
}

/**
 * Returns the pair's current break load.
 * @param {OptimizedPair<T>} pair Candidate pair.
 * @param {Map<string, number>} breakCounts Break counts by uid.
 * @return {number} Pair break load.
 */
function pairBreakLoad<T extends AssignmentParticipant>(
  pair: OptimizedPair<T>,
  breakCounts: Map<string, number>
): number {
  return (breakCounts.get(pair.a.uid) ?? 0) +
    (breakCounts.get(pair.b.uid) ?? 0);
}

/**
 * Returns the pair's current meeting load.
 * @param {OptimizedPair<T>} pair Candidate pair.
 * @param {Map<string, number>} meetingCounts Meeting counts by uid.
 * @return {number} Pair load.
 */
function pairLoad<T extends AssignmentParticipant>(
  pair: OptimizedPair<T>,
  meetingCounts: Map<string, number>
): number {
  return (meetingCounts.get(pair.a.uid) ?? 0) +
    (meetingCounts.get(pair.b.uid) ?? 0);
}

/**
 * Returns true when a social fallback would give someone a first connection.
 * @param {OptimizedPair<T>} pair Candidate pair.
 * @param {Map<string, number>} meetingCounts Meeting counts by uid.
 * @return {boolean} Whether this pair prevents a zero-connection attendee.
 */
function pairNeedsFirstConnection<T extends AssignmentParticipant>(
  pair: OptimizedPair<T>,
  meetingCounts: Map<string, number>
): boolean {
  return (meetingCounts.get(pair.a.uid) ?? 0) === 0 ||
    (meetingCounts.get(pair.b.uid) ?? 0) === 0;
}

/**
 * Places low-opportunity attendees first so sparse orientations are preserved.
 * @param {Array<T>} participants Participants to sort.
 * @param {Set<string>} blockedPairs Safety-blocked undirected pairs.
 * @param {QuestionnaireScoringMode} questionnaireMode Answer weighting.
 * @param {EventSuccessCompatibilityPolicy} compatibilityPolicy Pair policy.
 * @param {NormalizedAssignmentConstraints} constraints Constraint lookups.
 * @return {Array<T>} Sorted participants.
 */
function constrainedParticipantsFirst<T extends AssignmentParticipant>(
  participants: T[],
  blockedPairs: Set<string>,
  questionnaireMode: QuestionnaireScoringMode,
  compatibilityPolicy: EventSuccessCompatibilityPolicy,
  constraints: NormalizedAssignmentConstraints
): T[] {
  return [...participants].sort((a, b) =>
    hostConstrainedParticipantRank(a.uid, constraints) -
    hostConstrainedParticipantRank(b.uid, constraints) ||
    mutualPeerCount(
      a,
      participants,
      blockedPairs,
      questionnaireMode,
      compatibilityPolicy,
      constraints
    ) -
    mutualPeerCount(
      b,
      participants,
      blockedPairs,
      questionnaireMode,
      compatibilityPolicy,
      constraints
    ) ||
    a.uid.localeCompare(b.uid)
  );
}

/**
 * Counts safety-allowed mutual romantic opportunities for one attendee.
 * @param {T} participant Participant being measured.
 * @param {Array<T>} participants All participants.
 * @param {Set<string>} blockedPairs Safety-blocked undirected pairs.
 * @param {QuestionnaireScoringMode} questionnaireMode Answer weighting.
 * @param {EventSuccessCompatibilityPolicy} compatibilityPolicy Pair policy.
 * @param {NormalizedAssignmentConstraints} constraints Constraint lookups.
 * @return {number} Mutual peer count.
 */
function mutualPeerCount<T extends AssignmentParticipant>(
  participant: T,
  participants: T[],
  blockedPairs: Set<string>,
  questionnaireMode: QuestionnaireScoringMode,
  compatibilityPolicy: EventSuccessCompatibilityPolicy,
  constraints: NormalizedAssignmentConstraints
): number {
  return participants.filter((peer) => {
    if (peer.uid === participant.uid) return false;
    if (blockedPairs.has(assignmentPairKey(participant.uid, peer.uid))) {
      return false;
    }
    if (isKeepApartPair(participant.uid, peer.uid, constraints)) {
      return false;
    }
    return scorePairForOptimizer(participant, peer, {
      questionnaireMode,
      compatibilityPolicy,
      allowOrientationFallback: false,
    }).mutualInterest;
  }).length;
}

/**
 * Scores how costly it is to add one attendee to a group.
 * @param {object} params Placement inputs.
 * @return {number} Lower placement cost is better.
 */
function groupPlacementCost<T extends AssignmentParticipant>(params: {
  participant: T;
  group: T[];
  blockedPairs: Set<string>;
  questionnaireMode: QuestionnaireScoringMode;
  compatibilityPolicy: EventSuccessCompatibilityPolicy;
  seenPairs?: Set<string>;
  maxGroupSize: number;
  constraints: NormalizedAssignmentConstraints;
  rotationPolicy: NormalizedAssignmentRotationPolicy;
  pairMeetingCounts?: Map<string, number>;
  groupIndex: number;
  groups: T[][];
}): number {
  if (
    !canJoinGroup(
      params.participant,
      params.group,
      params.blockedPairs,
      params.constraints
    )
  ) {
    return Number.POSITIVE_INFINITY;
  }
  if (params.group.length >= params.maxGroupSize) {
    return Number.POSITIVE_INFINITY;
  }
  const hostPlacementCost = hostGroupPlacementCost({
    uid: params.participant.uid,
    group: params.group,
    groupIndex: params.groupIndex,
    groups: params.groups,
    constraints: params.constraints,
  });
  const activityPlacementCost = activityGroupPlacementCost({
    participant: params.participant,
    group: params.group,
    constraints: params.constraints,
  });
  if (params.group.length === 0) {
    return hostPlacementCost + activityPlacementCost;
  }

  let opportunityScore = 0;
  let mutualCount = 0;
  let repeatedPairPenalty = 0;
  for (const member of params.group) {
    const pairKey = assignmentPairKey(params.participant.uid, member.uid);
    const scored = scorePairForOptimizer(params.participant, member, {
      questionnaireMode: params.questionnaireMode,
      compatibilityPolicy: params.compatibilityPolicy,
      allowOrientationFallback: true,
    });
    opportunityScore += scored.score;
    if (scored.mutualInterest) mutualCount++;
    if (
      params.seenPairs?.has(
        pairKey
      ) === true
    ) {
      repeatedPairPenalty += groupRepeatPairPlacementPenalty({
        uidA: params.participant.uid,
        uidB: member.uid,
        previousMeetingCount: params.pairMeetingCounts?.get(pairKey) ?? 1,
        constraints: params.constraints,
        rotationPolicy: params.rotationPolicy,
      });
    }
  }
  const compositionCost = groupCompositionPlacementCost({
    group: [...params.group, params.participant],
    questionnaireMode: params.questionnaireMode,
    compatibilityPolicy: params.compatibilityPolicy,
  });
  const noMutualPenalty =
    params.compatibilityPolicy !== "none" && mutualCount === 0 ?
      NO_MUTUAL_GROUP_PENALTY :
      0;
  return params.group.length * GROUP_SIZE_PRESSURE +
    repeatedPairPenalty +
    activityPlacementCost +
    compositionCost +
    noMutualPenalty -
    opportunityScore +
    hostPlacementCost;
}

/**
 * Scores projected group composition after adding a participant.
 * @param {object} params Group composition inputs.
 * @return {number} Cost where lower is better.
 */
function groupCompositionPlacementCost<T extends AssignmentParticipant>(
  params: {
    group: T[];
    questionnaireMode: QuestionnaireScoringMode;
    compatibilityPolicy: EventSuccessCompatibilityPolicy;
  }
): number {
  if (params.compatibilityPolicy === "none") return 0;
  if (params.group.length < 2) return 0;
  const profile = groupCompositionProfile({
    group: params.group,
    questionnaireMode: params.questionnaireMode,
    compatibilityPolicy: params.compatibilityPolicy,
  });
  const lowOpportunityPenalty = isLowOpportunityGroup(profile) ?
    LOW_OPPORTUNITY_GROUP_PENALTY :
    0;
  const dominantGenderPenalty =
    profile.dominantGenderShare === 1 && profile.mutualDyadCount === 0 ?
      DOMINANT_GENDER_LOW_OPPORTUNITY_PENALTY :
      0;
  return lowOpportunityPenalty +
    dominantGenderPenalty +
    profile.uncoveredParticipantCount * UNCOVERED_GROUP_PARTICIPANT_PENALTY;
}

/**
 * Builds all undirected pair keys inside a group.
 * @param {Array<T>} group Group participants.
 * @return {string[]} Pair keys.
 */
function groupPairKeys<T extends AssignmentParticipant>(group: T[]): string[] {
  const keys: string[] = [];
  for (let i = 0; i < group.length; i++) {
    for (let j = i + 1; j < group.length; j++) {
      keys.push(assignmentPairKey(group[i].uid, group[j].uid));
    }
  }
  return keys;
}

/**
 * Summarizes an optimized group for test/debug explainability.
 * @param {object} params Group summary inputs.
 * @return {OptimizedGroup<T>} Group plus score metadata.
 */
function groupSummary<T extends AssignmentParticipant>(params: {
  group: T[];
  index: number;
  questionnaireMode: QuestionnaireScoringMode;
  compatibilityPolicy: EventSuccessCompatibilityPolicy;
}): OptimizedGroup<T> {
  let score = 0;
  let mutualDyadCount = 0;
  let plausibleDyadCount = 0;
  for (let i = 0; i < params.group.length; i++) {
    for (let j = i + 1; j < params.group.length; j++) {
      const scored = scorePairForOptimizer(params.group[i], params.group[j], {
        questionnaireMode: params.questionnaireMode,
        compatibilityPolicy: params.compatibilityPolicy,
        allowOrientationFallback: true,
      });
      score += scored.score;
      if (scored.mutualInterest) mutualDyadCount++;
      if (
        scored.mutualInterest ||
        scored.oneWayInterest ||
        scored.compatibility === "social"
      ) {
        plausibleDyadCount++;
      }
    }
  }
  return {
    groupIndex: params.index,
    participants: params.group,
    score,
    mutualDyadCount,
    plausibleDyadCount,
  };
}

/**
 * Returns true when adding a participant will not violate block safety.
 * @param {T} participant Candidate participant.
 * @param {Array<T>} group Current group.
 * @param {Set<string>} blockedPairs Safety-blocked undirected pairs.
 * @param {NormalizedAssignmentConstraints} constraints Constraint lookups.
 * @return {boolean} Whether the participant can join the group.
 */
function canJoinGroup<T extends AssignmentParticipant>(
  participant: T,
  group: T[],
  blockedPairs: Set<string>,
  constraints: NormalizedAssignmentConstraints
): boolean {
  return group.every((member) =>
    !blockedPairs.has(assignmentPairKey(participant.uid, member.uid))
  ) && canJoinHostConstrainedGroup(participant.uid, group, constraints);
}
