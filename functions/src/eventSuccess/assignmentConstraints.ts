export type AssignmentConstraintCategory =
  "hard" |
  "strongSoft" |
  "formatDefaultSoft" |
  "host";

export type AssignmentConstraintStatus =
  "satisfied" |
  "relaxed" |
  "violated" |
  "not_applicable";

export type AssignmentConstraintKey =
  "blocked_pair" |
  "unit_capacity" |
  "single_round_assignment" |
  "mutual_orientation" |
  "questionnaire_affinity" |
  "repeat_pair" |
  "group_size_balance" |
  "group_opportunity_balance" |
  "activity_attribute_balance" |
  "activity_attribute_cluster" |
  "host_keep_together" |
  "host_keep_apart" |
  "host_anchor";

export interface AssignmentConstraintEvaluation {
  key: AssignmentConstraintKey;
  category: AssignmentConstraintCategory;
  status: AssignmentConstraintStatus;
  subjectUids: string[];
  scoreDelta?: number;
  note?: string;
}

export interface AssignmentPairConstraint {
  aUid: string;
  bUid: string;
}

export interface AssignmentHostConstraints {
  keepTogetherPairs?: AssignmentPairConstraint[];
  keepApartPairs?: AssignmentPairConstraint[];
  anchorUidsByGroupIndex?: Record<string, string[]>;
  requestedRepeatPairs?: AssignmentPairConstraint[];
}

export interface AssignmentActivityConstraints {
  balanceAttributes?: string[];
  clusterAttributes?: string[];
}

export interface AssignmentConstraintConfig {
  host?: AssignmentHostConstraints;
  activity?: AssignmentActivityConstraints;
}

export interface AssignmentConstraintParticipant {
  uid: string;
  activityAttributes?: Record<string, string | number | boolean | null>;
}

export interface AssignmentConstraintGroup<
  T extends AssignmentConstraintParticipant
> {
  groupIndex: number;
  participants: T[];
}

export interface AssignmentConstraintPair<
  T extends AssignmentConstraintParticipant
> {
  a: T;
  b: T;
}

export interface NormalizedAssignmentConstraints {
  keepTogetherPairs: Set<string>;
  keepApartPairs: Set<string>;
  requestedRepeatPairs: Set<string>;
  keepTogetherPeersByUid: Map<string, Set<string>>;
  anchorGroupByUid: Map<string, number>;
  anchorUidsByGroupIndex: Map<number, Set<string>>;
  balanceActivityAttributes: string[];
  clusterActivityAttributes: string[];
}

const HOST_ANCHOR_MATCH_REWARD = -120;
const HOST_ANCHOR_MISMATCH_PENALTY = 450;
const HOST_KEEP_TOGETHER_MATCH_REWARD = -180;
const HOST_KEEP_TOGETHER_SPLIT_PENALTY = 260;
const HOST_KEEP_TOGETHER_PAIR_SCORE = 150;
const HOST_REQUESTED_REPEAT_PAIR_SCORE = 260;
const ACTIVITY_BALANCE_SAME_VALUE_PENALTY = 55;
const ACTIVITY_CLUSTER_MISMATCH_PENALTY = 95;
const ACTIVITY_CLUSTER_MATCH_REWARD = 35;
const ACTIVITY_MISSING_VALUE_PENALTY = 12;

/**
 * Builds a deterministic undirected pair key for constraint lookups.
 * @param {string} uidA First uid.
 * @param {string} uidB Second uid.
 * @return {string} Pair key.
 */
export function assignmentConstraintPairKey(
  uidA: string,
  uidB: string
): string {
  return [uidA, uidB].sort().join("__");
}

/**
 * Normalizes optional engine constraints into lookup-friendly structures.
 * @param {AssignmentConstraintConfig} config Raw constraint config.
 * @return {NormalizedAssignmentConstraints} Normalized constraints.
 */
export function normalizeAssignmentConstraints(
  config?: AssignmentConstraintConfig
): NormalizedAssignmentConstraints {
  const keepTogetherPairs = new Set<string>();
  const keepApartPairs = new Set<string>();
  const requestedRepeatPairs = new Set<string>();
  const keepTogetherPeersByUid = new Map<string, Set<string>>();
  const anchorGroupByUid = new Map<string, number>();
  const anchorUidsByGroupIndex = new Map<number, Set<string>>();
  const balanceActivityAttributes = normalizeAttributeNames(
    config?.activity?.balanceAttributes
  );
  const clusterActivityAttributes = normalizeAttributeNames(
    config?.activity?.clusterAttributes
  );

  for (const pair of config?.host?.keepTogetherPairs ?? []) {
    if (pair.aUid === pair.bUid) continue;
    keepTogetherPairs.add(assignmentConstraintPairKey(pair.aUid, pair.bUid));
    addPeer(keepTogetherPeersByUid, pair.aUid, pair.bUid);
    addPeer(keepTogetherPeersByUid, pair.bUid, pair.aUid);
  }
  for (const pair of config?.host?.keepApartPairs ?? []) {
    if (pair.aUid === pair.bUid) continue;
    keepApartPairs.add(assignmentConstraintPairKey(pair.aUid, pair.bUid));
  }
  for (const pair of config?.host?.requestedRepeatPairs ?? []) {
    if (pair.aUid === pair.bUid) continue;
    requestedRepeatPairs.add(
      assignmentConstraintPairKey(pair.aUid, pair.bUid)
    );
  }
  for (
    const [rawGroupIndex, uids] of Object.entries(
      config?.host?.anchorUidsByGroupIndex ?? {}
    )
  ) {
    const groupIndex = Number.parseInt(rawGroupIndex, 10);
    if (!Number.isInteger(groupIndex) || groupIndex < 0) continue;
    const anchorUids = new Set<string>();
    for (const uid of uids) {
      anchorUids.add(uid);
      anchorGroupByUid.set(uid, groupIndex);
    }
    if (anchorUids.size > 0) {
      anchorUidsByGroupIndex.set(groupIndex, anchorUids);
    }
  }

  return {
    keepTogetherPairs,
    keepApartPairs,
    requestedRepeatPairs,
    keepTogetherPeersByUid,
    anchorGroupByUid,
    anchorUidsByGroupIndex,
    balanceActivityAttributes,
    clusterActivityAttributes,
  };
}

/**
 * Returns whether any host constraint is active.
 * @param {NormalizedAssignmentConstraints} constraints Normalized constraints.
 * @return {boolean} Whether constraints are non-empty.
 */
export function hasHostConstraints(
  constraints: NormalizedAssignmentConstraints
): boolean {
  return constraints.keepTogetherPairs.size > 0 ||
    constraints.keepApartPairs.size > 0 ||
    constraints.requestedRepeatPairs.size > 0 ||
    constraints.anchorGroupByUid.size > 0;
}

/**
 * Returns true when a hard keep-apart pair would be violated.
 * @param {string} uidA First uid.
 * @param {string} uidB Second uid.
 * @param {NormalizedAssignmentConstraints} constraints Constraint lookups.
 * @return {boolean} Whether the pair is disallowed.
 */
export function isKeepApartPair(
  uidA: string,
  uidB: string,
  constraints: NormalizedAssignmentConstraints
): boolean {
  return constraints.keepApartPairs.has(
    assignmentConstraintPairKey(uidA, uidB)
  );
}

/**
 * Returns whether a participant can join a group under hard host constraints.
 * @param {string} uid Candidate uid.
 * @param {Array<AssignmentConstraintParticipant>} group Current group.
 * @param {NormalizedAssignmentConstraints} constraints Constraint lookups.
 * @return {boolean} Whether the participant can join.
 */
export function canJoinHostConstrainedGroup(
  uid: string,
  group: AssignmentConstraintParticipant[],
  constraints: NormalizedAssignmentConstraints
): boolean {
  return group.every((member) =>
    !isKeepApartPair(uid, member.uid, constraints)
  );
}

/**
 * Ranks constrained participants ahead of unconstrained participants.
 * @param {string} uid Participant uid.
 * @param {NormalizedAssignmentConstraints} constraints Constraint lookups.
 * @return {number} Lower rank sorts earlier.
 */
export function hostConstrainedParticipantRank(
  uid: string,
  constraints: NormalizedAssignmentConstraints
): number {
  if (constraints.anchorGroupByUid.has(uid)) return 0;
  if (constraints.keepTogetherPeersByUid.has(uid)) return 1;
  return 2;
}

/**
 * Scores host constraints for adding one participant to a group.
 * @param {object} params Placement inputs.
 * @return {number} Cost delta where lower is better.
 */
export function hostGroupPlacementCost(params: {
  uid: string;
  group: AssignmentConstraintParticipant[];
  groupIndex: number;
  groups: AssignmentConstraintParticipant[][];
  constraints: NormalizedAssignmentConstraints;
}): number {
  let cost = 0;
  const anchorGroupIndex = params.constraints.anchorGroupByUid.get(params.uid);
  if (anchorGroupIndex !== undefined) {
    cost += anchorGroupIndex === params.groupIndex ?
      HOST_ANCHOR_MATCH_REWARD :
      HOST_ANCHOR_MISMATCH_PENALTY;
  }

  for (
    const peerUid of params.constraints.keepTogetherPeersByUid.get(
      params.uid
    ) ?? []
  ) {
    if (params.group.some((member) => member.uid === peerUid)) {
      cost += HOST_KEEP_TOGETHER_MATCH_REWARD;
      continue;
    }
    const peerGroupIndex = groupIndexForUid(peerUid, params.groups);
    if (
      peerGroupIndex !== null &&
      peerGroupIndex !== params.groupIndex
    ) {
      cost += HOST_KEEP_TOGETHER_SPLIT_PENALTY;
    }
  }
  return cost;
}

/**
 * Scores activity attributes for adding a participant to a group.
 * @param {object} params Placement inputs.
 * @return {number} Cost delta where lower is better.
 */
export function activityGroupPlacementCost<
  T extends AssignmentConstraintParticipant
>(params: {
  participant: T;
  group: T[];
  constraints: NormalizedAssignmentConstraints;
}): number {
  let cost = 0;
  for (const attribute of params.constraints.balanceActivityAttributes) {
    const value = activityValue(params.participant, attribute);
    if (value === null) {
      cost += ACTIVITY_MISSING_VALUE_PENALTY;
      continue;
    }
    const sameValueCount = params.group.filter((member) =>
      activityValue(member, attribute) === value
    ).length;
    cost += sameValueCount * ACTIVITY_BALANCE_SAME_VALUE_PENALTY;
  }
  for (const attribute of params.constraints.clusterActivityAttributes) {
    const value = activityValue(params.participant, attribute);
    if (value === null) {
      cost += ACTIVITY_MISSING_VALUE_PENALTY;
      continue;
    }
    const sameValueCount = params.group.filter((member) =>
      activityValue(member, attribute) === value
    ).length;
    const mismatchedCount = params.group.filter((member) => {
      const memberValue = activityValue(member, attribute);
      return memberValue !== null && memberValue !== value;
    }).length;
    cost += mismatchedCount * ACTIVITY_CLUSTER_MISMATCH_PENALTY -
      sameValueCount * ACTIVITY_CLUSTER_MATCH_REWARD;
  }
  return cost;
}

/**
 * Scores activity attributes for a direct pair assignment.
 * @param {object} params Pair scoring inputs.
 * @return {number} Score delta where higher is better.
 */
export function activityPairScoreAdjustment<
  T extends AssignmentConstraintParticipant
>(params: {
  a: T;
  b: T;
  constraints: NormalizedAssignmentConstraints;
}): number {
  let score = 0;
  for (const attribute of params.constraints.balanceActivityAttributes) {
    const aValue = activityValue(params.a, attribute);
    const bValue = activityValue(params.b, attribute);
    if (aValue === null || bValue === null) {
      score -= ACTIVITY_MISSING_VALUE_PENALTY;
    } else if (aValue === bValue) {
      score -= ACTIVITY_BALANCE_SAME_VALUE_PENALTY;
    } else {
      score += Math.floor(ACTIVITY_BALANCE_SAME_VALUE_PENALTY / 2);
    }
  }
  for (const attribute of params.constraints.clusterActivityAttributes) {
    const aValue = activityValue(params.a, attribute);
    const bValue = activityValue(params.b, attribute);
    if (aValue === null || bValue === null) {
      score -= ACTIVITY_MISSING_VALUE_PENALTY;
    } else if (aValue === bValue) {
      score += ACTIVITY_CLUSTER_MATCH_REWARD;
    } else {
      score -= ACTIVITY_CLUSTER_MISMATCH_PENALTY;
    }
  }
  return score;
}

/**
 * Returns score adjustment for pair-level host constraints.
 * @param {string} uidA First uid.
 * @param {string} uidB Second uid.
 * @param {NormalizedAssignmentConstraints} constraints Constraint lookups.
 * @return {number} Score delta where higher is better.
 */
export function hostPairScoreAdjustment(
  uidA: string,
  uidB: string,
  constraints: NormalizedAssignmentConstraints
): number {
  if (
    constraints.keepTogetherPairs.has(
      assignmentConstraintPairKey(uidA, uidB)
    )
  ) {
    return HOST_KEEP_TOGETHER_PAIR_SCORE;
  }
  return 0;
}

/**
 * Returns true when a repeated pair was explicitly requested by a host.
 * @param {string} uidA First uid.
 * @param {string} uidB Second uid.
 * @param {NormalizedAssignmentConstraints} constraints Constraint lookups.
 * @return {boolean} Whether the repeat pair was requested.
 */
export function isHostRequestedRepeatPair(
  uidA: string,
  uidB: string,
  constraints: NormalizedAssignmentConstraints
): boolean {
  return constraints.requestedRepeatPairs.has(
    assignmentConstraintPairKey(uidA, uidB)
  );
}

/**
 * Returns pair score adjustment for a host-requested repeat.
 * @param {string} uidA First uid.
 * @param {string} uidB Second uid.
 * @param {NormalizedAssignmentConstraints} constraints Constraint lookups.
 * @return {number} Score delta where higher is better.
 */
export function hostRequestedRepeatPairScoreAdjustment(
  uidA: string,
  uidB: string,
  constraints: NormalizedAssignmentConstraints
): number {
  return isHostRequestedRepeatPair(uidA, uidB, constraints) ?
    HOST_REQUESTED_REPEAT_PAIR_SCORE :
    0;
}

/**
 * Evaluates host-authored constraints against generated assignments.
 * @param {object} params Evaluation inputs.
 * @return {AssignmentConstraintEvaluation[]} Constraint evaluations.
 */
export function evaluateHostConstraints<
  T extends AssignmentConstraintParticipant
>(params: {
  groups: Array<AssignmentConstraintGroup<T>>;
  pairs: Array<AssignmentConstraintPair<T>>;
  constraints: NormalizedAssignmentConstraints;
}): AssignmentConstraintEvaluation[] {
  if (!hasHostConstraints(params.constraints)) return [];
  return [
    ...evaluateKeepTogetherConstraints(params),
    ...evaluateKeepApartConstraints(params),
    ...evaluateAnchorConstraints(params),
  ];
}

/**
 * Returns a normalized activity attribute value.
 * @param {AssignmentConstraintParticipant} participant Participant.
 * @param {string} attribute Attribute name.
 * @return {string | null} Normalized value.
 */
export function activityValue(
  participant: AssignmentConstraintParticipant,
  attribute: string
): string | null {
  const value = participant.activityAttributes?.[attribute];
  if (value === undefined || value === null || value === "") return null;
  return String(value).trim();
}

/**
 * Adds a peer edge to a uid map.
 * @param {Map<string, Set<string>>} peersByUid Peer map.
 * @param {string} uid Source uid.
 * @param {string} peerUid Peer uid.
 */
function addPeer(
  peersByUid: Map<string, Set<string>>,
  uid: string,
  peerUid: string
): void {
  const existing = peersByUid.get(uid) ?? new Set<string>();
  existing.add(peerUid);
  peersByUid.set(uid, existing);
}

/**
 * Normalizes attribute names and removes duplicates.
 * @param {string[]} attributes Raw attribute names.
 * @return {string[]} Normalized names.
 */
function normalizeAttributeNames(attributes?: string[]): string[] {
  return [...new Set(
    (attributes ?? [])
      .map((attribute) => attribute.trim())
      .filter((attribute) => attribute.length > 0)
  )].sort();
}

/**
 * Returns the current group index for a uid.
 * @param {string} uid Participant uid.
 * @param {Array<Array<AssignmentConstraintParticipant>>} groups Groups.
 * @return {number | null} Group index or null.
 */
function groupIndexForUid(
  uid: string,
  groups: AssignmentConstraintParticipant[][]
): number | null {
  for (const [index, group] of groups.entries()) {
    if (group.some((member) => member.uid === uid)) return index;
  }
  return null;
}

/**
 * Evaluates keep-together constraints.
 * @param {object} params Evaluation inputs.
 * @return {AssignmentConstraintEvaluation[]} Evaluations.
 */
function evaluateKeepTogetherConstraints<
  T extends AssignmentConstraintParticipant
>(params: {
  groups: Array<AssignmentConstraintGroup<T>>;
  pairs: Array<AssignmentConstraintPair<T>>;
  constraints: NormalizedAssignmentConstraints;
}): AssignmentConstraintEvaluation[] {
  const evaluations: AssignmentConstraintEvaluation[] = [];
  for (const pairKey of params.constraints.keepTogetherPairs) {
    const [aUid, bUid] = pairKey.split("__");
    evaluations.push({
      key: "host_keep_together",
      category: "host",
      status: assignedTogether(aUid, bUid, params.groups, params.pairs) ?
        "satisfied" :
        "relaxed",
      subjectUids: [aUid, bUid],
    });
  }
  return evaluations;
}

/**
 * Evaluates keep-apart constraints.
 * @param {object} params Evaluation inputs.
 * @return {AssignmentConstraintEvaluation[]} Evaluations.
 */
function evaluateKeepApartConstraints<
  T extends AssignmentConstraintParticipant
>(params: {
  groups: Array<AssignmentConstraintGroup<T>>;
  pairs: Array<AssignmentConstraintPair<T>>;
  constraints: NormalizedAssignmentConstraints;
}): AssignmentConstraintEvaluation[] {
  const evaluations: AssignmentConstraintEvaluation[] = [];
  for (const pairKey of params.constraints.keepApartPairs) {
    const [aUid, bUid] = pairKey.split("__");
    evaluations.push({
      key: "host_keep_apart",
      category: "host",
      status: assignedTogether(aUid, bUid, params.groups, params.pairs) ?
        "violated" :
        "satisfied",
      subjectUids: [aUid, bUid],
    });
  }
  return evaluations;
}

/**
 * Evaluates anchor constraints.
 * @param {object} params Evaluation inputs.
 * @return {AssignmentConstraintEvaluation[]} Evaluations.
 */
function evaluateAnchorConstraints<
  T extends AssignmentConstraintParticipant
>(params: {
  groups: Array<AssignmentConstraintGroup<T>>;
  constraints: NormalizedAssignmentConstraints;
}): AssignmentConstraintEvaluation[] {
  const evaluations: AssignmentConstraintEvaluation[] = [];
  for (const [uid, groupIndex] of params.constraints.anchorGroupByUid) {
    evaluations.push({
      key: "host_anchor",
      category: "host",
      status: assignedToGroup(uid, groupIndex, params.groups) ?
        "satisfied" :
        "relaxed",
      subjectUids: [uid],
    });
  }
  return evaluations;
}

/**
 * Returns true if two attendees share any generated unit.
 * @param {string} aUid First uid.
 * @param {string} bUid Second uid.
 * @param {Array<AssignmentConstraintGroup<T>>} groups Generated groups.
 * @param {Array<AssignmentConstraintPair<T>>} pairs Generated pairs.
 * @return {boolean} Whether they are assigned together.
 */
function assignedTogether<T extends AssignmentConstraintParticipant>(
  aUid: string,
  bUid: string,
  groups: Array<AssignmentConstraintGroup<T>>,
  pairs: Array<AssignmentConstraintPair<T>>
): boolean {
  return groups.some((group) =>
    group.participants.some((participant) => participant.uid === aUid) &&
    group.participants.some((participant) => participant.uid === bUid)
  ) ||
    pairs.some((pair) =>
      assignmentConstraintPairKey(pair.a.uid, pair.b.uid) ===
        assignmentConstraintPairKey(aUid, bUid)
    );
}

/**
 * Returns true if a uid is anchored into the requested group.
 * @param {string} uid Participant uid.
 * @param {number} groupIndex Target group index.
 * @param {Array<AssignmentConstraintGroup<T>>} groups Generated groups.
 * @return {boolean} Whether the anchor was satisfied.
 */
function assignedToGroup<T extends AssignmentConstraintParticipant>(
  uid: string,
  groupIndex: number,
  groups: Array<AssignmentConstraintGroup<T>>
): boolean {
  return groups.some((group) =>
    group.groupIndex === groupIndex &&
    group.participants.some((participant) => participant.uid === uid)
  );
}
