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

export interface AssignmentParticipant {
  uid: string;
  gender?: string;
  interestedInGenders: string[];
  compatibilityAnswerIds?: string[];
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

export interface OptimizedAssignmentPlan<T extends AssignmentParticipant> {
  assignmentAlgorithm: EventSuccessAssignmentAlgorithm;
  compatibilityPolicy: EventSuccessCompatibilityPolicy;
  groups: Array<OptimizedGroup<T>>;
  groupRounds: Array<OptimizedGroupRound<T>>;
  rotationRounds: Array<OptimizedRotationRound<T>>;
}

const GROUP_SIZE_PRESSURE = 12;
const NO_MUTUAL_GROUP_PENALTY = 25;
const REPEATED_GROUP_PAIR_PENALTY = 75;

/**
 * Optimizes event-success units from shared topology and format primitives.
 * The wrappers below exist for legacy callers; this is the canonical path.
 * @param {object} params Assignment optimization inputs.
 * @return {OptimizedAssignmentPlan<T>} Optimized group or rotation plan.
 */
export function optimizeEventSuccessAssignments<
  T extends AssignmentParticipant
>(params: {
  participants: T[];
  blockedPairs: Set<string>;
  topology: AssignmentTopology;
  assignmentAlgorithm?: EventSuccessAssignmentAlgorithm;
  compatibilityPolicy?: EventSuccessCompatibilityPolicy;
  questionnaireMode?: QuestionnaireScoringMode;
  rotationRoundCount?: number;
  allowOrientationFallback?: boolean;
}): OptimizedAssignmentPlan<T> {
  const assignmentAlgorithm = params.assignmentAlgorithm ??
    assignmentAlgorithmForTopology(params.topology);
  const compatibilityPolicy = params.compatibilityPolicy ??
    "questionnaireClueOnly";
  const questionnaireMode = questionnaireModeForPolicy(
    params.questionnaireMode ?? "icebreaker",
    compatibilityPolicy
  );
  const shouldBuildPairRotations =
    params.topology.rotationsEnabled &&
    params.topology.unitSize === 2 &&
    (params.rotationRoundCount ?? 0) > 0;

  if (shouldBuildPairRotations) {
    return {
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
      }),
    };
  }

  if (
    params.topology.rotationsEnabled &&
    (params.rotationRoundCount ?? 0) > 0
  ) {
    return {
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
      }),
      rotationRounds: [],
    };
  }

  return {
    assignmentAlgorithm,
    compatibilityPolicy,
    groups: buildGroupUnitsForOptimizer({
      participants: params.participants,
      blockedPairs: params.blockedPairs,
      groupCount: params.topology.groupCount,
      maxGroupSize: params.topology.maxGroupSize,
      questionnaireMode,
      compatibilityPolicy,
    }),
    groupRounds: [],
    rotationRounds: [],
  };
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
}): Array<OptimizedRotationRound<T>> {
  if (params.participants.length < 2 || params.roundCount <= 0) return [];
  const seenPairs = new Set<string>();
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
      seenPairs,
      questionnaireMode: params.questionnaireMode,
      compatibilityPolicy: params.compatibilityPolicy,
      allowOrientationFallback: params.allowOrientationFallback,
    });
    selectPairsForRound({
      candidates: candidatePairs.filter((pair) => pair.mutualInterest),
      usedUids,
      roundPairs,
      seenPairs,
      meetingCounts,
      breakCounts,
    });
    if (params.allowOrientationFallback) {
      selectPairsForRound({
        candidates: candidatePairs.filter((pair) =>
          !pair.mutualInterest && pair.compatibility !== "social"
        ),
        usedUids,
        roundPairs,
        seenPairs,
        meetingCounts,
        breakCounts,
      });
      selectPairsForRound({
        candidates: candidatePairs.filter((pair) =>
          pair.compatibility === "social" &&
          pairNeedsFirstConnection(pair, meetingCounts)
        ),
        usedUids,
        roundPairs,
        seenPairs,
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
    params.compatibilityPolicy
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
        }) -
        groupPlacementCost({
          participant,
          group: b.group,
          blockedPairs: params.blockedPairs,
          questionnaireMode: params.questionnaireMode,
          compatibilityPolicy: params.compatibilityPolicy,
          seenPairs: params.seenPairs,
          maxGroupSize: params.maxGroupSize,
        }) ||
        a.index - b.index
      );
    const selected = candidates.find(({group}) =>
      canJoinGroup(participant, group, params.blockedPairs) &&
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
}): Array<OptimizedGroupRound<T>> {
  if (params.participants.length === 0 || params.roundCount <= 0) return [];
  const seenPairs = new Set<string>();
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
    });
    if (groups.length === 0) break;
    for (const group of groups) {
      for (const key of groupPairKeys(group.participants)) {
        seenPairs.add(key);
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
function selectPairsForRound<T extends AssignmentParticipant>(params: {
  candidates: Array<OptimizedPair<T>>;
  usedUids: Set<string>;
  roundPairs: Array<OptimizedPair<T>>;
  seenPairs: Set<string>;
  meetingCounts: Map<string, number>;
  breakCounts: Map<string, number>;
}): void {
  const sorted = [...params.candidates].sort((a, b) =>
    compareRotationPairsForRound(a, b, params.meetingCounts, params.breakCounts)
  );
  for (const pair of sorted) {
    if (params.usedUids.has(pair.a.uid) || params.usedUids.has(pair.b.uid)) {
      continue;
    }
    params.roundPairs.push(pair);
    params.usedUids.add(pair.a.uid);
    params.usedUids.add(pair.b.uid);
    params.seenPairs.add(assignmentPairKey(pair.a.uid, pair.b.uid));
    params.meetingCounts.set(
      pair.a.uid,
      (params.meetingCounts.get(pair.a.uid) ?? 0) + 1
    );
    params.meetingCounts.set(
      pair.b.uid,
      (params.meetingCounts.get(pair.b.uid) ?? 0) + 1
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
  seenPairs: Set<string>;
  questionnaireMode: QuestionnaireScoringMode;
  compatibilityPolicy: EventSuccessCompatibilityPolicy;
  allowOrientationFallback: boolean;
}): Array<OptimizedPair<T>> {
  const pairs: Array<OptimizedPair<T>> = [];
  for (let i = 0; i < params.participants.length; i++) {
    for (let j = i + 1; j < params.participants.length; j++) {
      const a = params.participants[i];
      const b = params.participants[j];
      const key = assignmentPairKey(a.uid, b.uid);
      if (params.blockedPairs.has(key) || params.seenPairs.has(key)) continue;
      const scored = scorePairForOptimizer(a, b, {
        questionnaireMode: params.questionnaireMode,
        compatibilityPolicy: params.compatibilityPolicy,
        allowOrientationFallback: params.allowOrientationFallback,
      });
      if (scored.score <= 0) continue;
      pairs.push({
        a,
        b,
        score: scored.score,
        compatibility: scored.compatibility,
        mutualInterest: scored.mutualInterest,
        orientationCompatible: scored.orientationCompatible,
      });
    }
  }
  return pairs;
}

/**
 * Orders candidate pairs using fairness before score.
 * @param {OptimizedPair<T>} a First pair.
 * @param {OptimizedPair<T>} b Second pair.
 * @param {Map<string, number>} meetingCounts Meeting counts by uid.
 * @param {Map<string, number>} breakCounts Break counts by uid.
 * @return {number} Sort comparison.
 */
function compareRotationPairsForRound<T extends AssignmentParticipant>(
  a: OptimizedPair<T>,
  b: OptimizedPair<T>,
  meetingCounts: Map<string, number>,
  breakCounts: Map<string, number>
): number {
  return pairMinMeetings(a, meetingCounts) -
    pairMinMeetings(b, meetingCounts) ||
    b.score - a.score ||
    pairBreakLoad(b, breakCounts) - pairBreakLoad(a, breakCounts) ||
    pairLoad(a, meetingCounts) - pairLoad(b, meetingCounts) ||
    assignmentPairKey(a.a.uid, a.b.uid)
      .localeCompare(assignmentPairKey(b.a.uid, b.b.uid));
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
 * @return {Array<T>} Sorted participants.
 */
function constrainedParticipantsFirst<T extends AssignmentParticipant>(
  participants: T[],
  blockedPairs: Set<string>,
  questionnaireMode: QuestionnaireScoringMode,
  compatibilityPolicy: EventSuccessCompatibilityPolicy
): T[] {
  return [...participants].sort((a, b) =>
    mutualPeerCount(
      a,
      participants,
      blockedPairs,
      questionnaireMode,
      compatibilityPolicy
    ) -
    mutualPeerCount(
      b,
      participants,
      blockedPairs,
      questionnaireMode,
      compatibilityPolicy
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
 * @return {number} Mutual peer count.
 */
function mutualPeerCount<T extends AssignmentParticipant>(
  participant: T,
  participants: T[],
  blockedPairs: Set<string>,
  questionnaireMode: QuestionnaireScoringMode,
  compatibilityPolicy: EventSuccessCompatibilityPolicy
): number {
  return participants.filter((peer) => {
    if (peer.uid === participant.uid) return false;
    if (blockedPairs.has(assignmentPairKey(participant.uid, peer.uid))) {
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
}): number {
  if (!canJoinGroup(params.participant, params.group, params.blockedPairs)) {
    return Number.POSITIVE_INFINITY;
  }
  if (params.group.length >= params.maxGroupSize) {
    return Number.POSITIVE_INFINITY;
  }
  if (params.group.length === 0) return 0;

  let opportunityScore = 0;
  let mutualCount = 0;
  let repeatedPairPenalty = 0;
  for (const member of params.group) {
    const scored = scorePairForOptimizer(params.participant, member, {
      questionnaireMode: params.questionnaireMode,
      compatibilityPolicy: params.compatibilityPolicy,
      allowOrientationFallback: true,
    });
    opportunityScore += scored.score;
    if (scored.mutualInterest) mutualCount++;
    if (
      params.seenPairs?.has(
        assignmentPairKey(params.participant.uid, member.uid)
      ) === true
    ) {
      repeatedPairPenalty += REPEATED_GROUP_PAIR_PENALTY;
    }
  }
  const noMutualPenalty = mutualCount === 0 ? NO_MUTUAL_GROUP_PENALTY : 0;
  return params.group.length * GROUP_SIZE_PRESSURE +
    repeatedPairPenalty +
    noMutualPenalty -
    opportunityScore;
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
 * @return {boolean} Whether the participant can join the group.
 */
function canJoinGroup<T extends AssignmentParticipant>(
  participant: T,
  group: T[],
  blockedPairs: Set<string>
): boolean {
  return group.every((member) =>
    !blockedPairs.has(assignmentPairKey(participant.uid, member.uid))
  );
}
