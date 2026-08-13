import {assignmentConstraintPairKey} from "./assignmentConstraints";
import type {EventSuccessUnitProximity} from "./spatialLayout";

export interface SequenceParticipant {
  uid: string;
}

export interface SequencePair<T extends SequenceParticipant> {
  a: T;
  b: T;
}

export interface ScheduledSequenceMatch<T extends SequenceParticipant>
  extends SequencePair<T> {
  unitIndex: number;
  resourceUnitId: string;
  movementCost: number;
  meetingIndex: number;
}

export interface ScheduledSequenceRound<T extends SequenceParticipant> {
  roundIndex: number;
  matches: Array<ScheduledSequenceMatch<T>>;
  sitOutUids: string[];
}

export interface SequenceSchedule<T extends SequenceParticipant> {
  rounds: Array<ScheduledSequenceRound<T>>;
  unscheduledPairKeys: string[];
}

interface PairTicket<T extends SequenceParticipant> extends SequencePair<T> {
  key: string;
  ticketKey: string;
  meetingIndex: number;
}

interface ResourceAssignment<T extends SequenceParticipant>
  extends SequencePair<T> {
  unitIndex: number;
  resourceUnitId: string;
  movementCost: number;
}

/**
 * Builds a deterministic capacity-bounded sequence schedule. Every allowed
 * pair appears exactly once before an optional repeat cycle begins. Sit-out
 * selection consumes the T3 cumulative exclusion totals, and court placement
 * consumes the complete T5 unit-proximity graph.
 */
export function buildEventSuccessSequenceSchedule<
  T extends SequenceParticipant
>(params: {
  participants: T[];
  roundLimit: number;
  concurrentUnits: number;
  blockedPairKeys?: Set<string>;
  priorityPairKeys?: Set<string>;
  exclusionMinutesByUid?: ReadonlyMap<string, number>;
  exclusionIntervalMinutes: number;
  resourceUnitIds?: string[];
  unitProximity?: EventSuccessUnitProximity[];
  maxPairMeetings?: number;
}): SequenceSchedule<T> {
  const participants = uniqueParticipants(params.participants);
  const roundLimit = boundedInteger(params.roundLimit, 0, 100);
  if (participants.length < 2 || roundLimit === 0) {
    return {rounds: [], unscheduledPairKeys: []};
  }
  const resourceUnitIds = normalizedResourceUnitIds(
    params.resourceUnitIds,
    params.concurrentUnits,
    participants.length
  );
  if (resourceUnitIds.length === 0) {
    return {rounds: [], unscheduledPairKeys: allPairKeys(participants)};
  }
  const maxPairMeetings = boundedInteger(
    params.maxPairMeetings ?? 1,
    1,
    10
  );
  const blockedPairKeys = params.blockedPairKeys ?? new Set<string>();
  const priorityPairKeys = params.priorityPairKeys ?? new Set<string>();
  const remaining = pairTickets(
    participants,
    blockedPairKeys,
    maxPairMeetings
  );
  const exclusionMinutesByUid = new Map(
    participants.map((participant) => [
      participant.uid,
      finiteNonNegative(
        params.exclusionMinutesByUid?.get(participant.uid) ?? 0
      ),
    ])
  );
  const assignedRoundCountByUid = new Map(
    participants.map((participant) => [participant.uid, 0])
  );
  const lastUnitByUid = new Map<string, string>();
  const rounds: Array<ScheduledSequenceRound<T>> = [];

  for (let roundIndex = 0; roundIndex < roundLimit; roundIndex += 1) {
    const usedUids = new Set<string>();
    const selected: Array<PairTicket<T>> = [];
    while (selected.length < resourceUnitIds.length) {
      const currentMeetingIndex = remaining.reduce(
        (minimum, ticket) => Math.min(minimum, ticket.meetingIndex),
        Number.MAX_SAFE_INTEGER
      );
      const available = remaining.filter((ticket) =>
        ticket.meetingIndex === currentMeetingIndex &&
        !usedUids.has(ticket.a.uid) &&
        !usedUids.has(ticket.b.uid)
      );
      if (available.length === 0) break;
      const degrees = participantDegrees(available);
      const next = [...available].sort((a, b) =>
        comparePairTickets({
          a,
          b,
          exclusionMinutesByUid,
          assignedRoundCountByUid,
          degrees,
          priorityPairKeys,
        })
      )[0];
      selected.push(next);
      usedUids.add(next.a.uid);
      usedUids.add(next.b.uid);
      remaining.splice(remaining.findIndex(
        (ticket) => ticket.ticketKey === next.ticketKey
      ), 1);
    }
    if (selected.length === 0) break;

    const resourceAssignments = assignSequenceRoundResources({
      pairs: selected,
      resourceUnitIds,
      unitProximity: params.unitProximity,
      previousUnitByUid: lastUnitByUid,
    });
    const ticketByPairKey = new Map(
      selected.map((ticket) => [ticket.key, ticket])
    );
    const matches = resourceAssignments.map((assignment) => {
      const ticket = ticketByPairKey.get(
        assignmentConstraintPairKey(assignment.a.uid, assignment.b.uid)
      );
      if (ticket === undefined) {
        throw new Error("Sequence resource assignment lost its pair ticket.");
      }
      lastUnitByUid.set(assignment.a.uid, assignment.resourceUnitId);
      lastUnitByUid.set(assignment.b.uid, assignment.resourceUnitId);
      return {...assignment, meetingIndex: ticket.meetingIndex};
    });
    const sitOutUids = participants
      .map((participant) => participant.uid)
      .filter((uid) => !usedUids.has(uid))
      .sort();
    for (const participant of participants) {
      if (usedUids.has(participant.uid)) {
        assignedRoundCountByUid.set(
          participant.uid,
          (assignedRoundCountByUid.get(participant.uid) ?? 0) + 1
        );
      } else {
        exclusionMinutesByUid.set(
          participant.uid,
          (exclusionMinutesByUid.get(participant.uid) ?? 0) +
            finiteNonNegative(params.exclusionIntervalMinutes)
        );
      }
    }
    rounds.push({roundIndex, matches, sitOutUids});
  }

  return {
    rounds,
    unscheduledPairKeys: [...new Set(
      remaining.map((ticket) => ticket.key)
    )].sort(),
  };
}

/**
 * Assigns the selected matches to resources with deterministic movement cost.
 * Pairs with the fewest equivalent choices are placed first.
 */
export function assignSequenceRoundResources<
  T extends SequenceParticipant
>(params: {
  pairs: Array<SequencePair<T>>;
  resourceUnitIds: string[];
  previousUnitByUid: ReadonlyMap<string, string>;
  unitProximity?: EventSuccessUnitProximity[];
}): Array<ResourceAssignment<T>> {
  const resources = [...new Set(params.resourceUnitIds)];
  const distance = unitDistanceLookup(resources, params.unitProximity ?? []);
  const optionsByPair = new Map<string, Array<{
    unitIndex: number;
    resourceUnitId: string;
    movementCost: number;
  }>>();
  for (const pair of params.pairs) {
    const key = assignmentConstraintPairKey(pair.a.uid, pair.b.uid);
    optionsByPair.set(key, resources.map((resourceUnitId, unitIndex) => ({
      unitIndex,
      resourceUnitId,
      movementCost: participantMovementCost(
        pair.a.uid,
        resourceUnitId,
        params.previousUnitByUid,
        distance
      ) + participantMovementCost(
        pair.b.uid,
        resourceUnitId,
        params.previousUnitByUid,
        distance
      ),
    })).sort((a, b) =>
      a.movementCost - b.movementCost ||
      a.unitIndex - b.unitIndex ||
      a.resourceUnitId.localeCompare(b.resourceUnitId)
    ));
  }
  const orderedPairs = [...params.pairs].sort((a, b) => {
    const aOptions = optionsByPair.get(
      assignmentConstraintPairKey(a.a.uid, a.b.uid)
    ) ?? [];
    const bOptions = optionsByPair.get(
      assignmentConstraintPairKey(b.a.uid, b.b.uid)
    ) ?? [];
    const aChoiceGap = (aOptions[1]?.movementCost ?? Number.MAX_SAFE_INTEGER) -
      (aOptions[0]?.movementCost ?? 0);
    const bChoiceGap = (bOptions[1]?.movementCost ?? Number.MAX_SAFE_INTEGER) -
      (bOptions[0]?.movementCost ?? 0);
    return bChoiceGap - aChoiceGap ||
      assignmentConstraintPairKey(a.a.uid, a.b.uid).localeCompare(
        assignmentConstraintPairKey(b.a.uid, b.b.uid)
      );
  });
  const usedResources = new Set<string>();
  const assignments: Array<ResourceAssignment<T>> = [];
  for (const pair of orderedPairs) {
    const key = assignmentConstraintPairKey(pair.a.uid, pair.b.uid);
    const option = (optionsByPair.get(key) ?? []).find(
      (candidate) => !usedResources.has(candidate.resourceUnitId)
    );
    if (option === undefined) break;
    usedResources.add(option.resourceUnitId);
    assignments.push({...pair, ...option});
  }
  return assignments.sort((a, b) => a.unitIndex - b.unitIndex);
}

function comparePairTickets<T extends SequenceParticipant>(params: {
  a: PairTicket<T>;
  b: PairTicket<T>;
  exclusionMinutesByUid: ReadonlyMap<string, number>;
  assignedRoundCountByUid: ReadonlyMap<string, number>;
  degrees: ReadonlyMap<string, number>;
  priorityPairKeys: ReadonlySet<string>;
}): number {
  const aMaximumExclusion = pairMaximum(
    params.a,
    params.exclusionMinutesByUid
  );
  const bMaximumExclusion = pairMaximum(
    params.b,
    params.exclusionMinutesByUid
  );
  const aExclusionLoad = pairSum(
    params.a,
    params.exclusionMinutesByUid
  );
  const bExclusionLoad = pairSum(
    params.b,
    params.exclusionMinutesByUid
  );
  const aAssignedLoad = pairSum(
    params.a,
    params.assignedRoundCountByUid
  );
  const bAssignedLoad = pairSum(
    params.b,
    params.assignedRoundCountByUid
  );
  const aDegreeLoad = pairSum(params.a, params.degrees);
  const bDegreeLoad = pairSum(params.b, params.degrees);
  return bMaximumExclusion - aMaximumExclusion ||
    bExclusionLoad - aExclusionLoad ||
    aAssignedLoad - bAssignedLoad ||
    Number(params.priorityPairKeys.has(params.b.key)) -
      Number(params.priorityPairKeys.has(params.a.key)) ||
    aDegreeLoad - bDegreeLoad ||
    params.a.meetingIndex - params.b.meetingIndex ||
    params.a.ticketKey.localeCompare(params.b.ticketKey);
}

function pairTickets<T extends SequenceParticipant>(
  participants: T[],
  blockedPairKeys: ReadonlySet<string>,
  maxPairMeetings: number
): Array<PairTicket<T>> {
  const tickets: Array<PairTicket<T>> = [];
  for (
    let meetingIndex = 0;
    meetingIndex < maxPairMeetings;
    meetingIndex += 1
  ) {
    for (let aIndex = 0; aIndex < participants.length; aIndex += 1) {
      for (let bIndex = aIndex + 1; bIndex < participants.length; bIndex += 1) {
        const a = participants[aIndex];
        const b = participants[bIndex];
        const key = assignmentConstraintPairKey(a.uid, b.uid);
        if (blockedPairKeys.has(key)) continue;
        tickets.push({
          a,
          b,
          key,
          ticketKey: `${meetingIndex}:${key}`,
          meetingIndex,
        });
      }
    }
  }
  return tickets;
}

function uniqueParticipants<T extends SequenceParticipant>(
  participants: T[]
): T[] {
  const byUid = new Map<string, T>();
  for (const participant of participants) {
    const uid = participant.uid.trim();
    if (uid.length === 0) continue;
    if (byUid.has(uid)) {
      throw new Error(`Duplicate sequence participant: ${uid}`);
    }
    byUid.set(uid, participant);
  }
  return [...byUid.values()].sort((a, b) => a.uid.localeCompare(b.uid));
}

function normalizedResourceUnitIds(
  rawIds: string[] | undefined,
  concurrentUnits: number,
  participantCount: number
): string[] {
  const maximumUsefulUnits = Math.max(1, Math.floor(participantCount / 2));
  const limit = boundedInteger(concurrentUnits, 0, 200);
  if (limit === 0) return [];
  const provided = [...new Set((rawIds ?? [])
    .map((id) => id.trim())
    .filter((id) => id.length > 0))];
  if (provided.length > 0) {
    return provided.slice(0, Math.min(limit, maximumUsefulUnits));
  }
  return Array.from(
    {length: Math.min(limit, maximumUsefulUnits)},
    (_, index) => `resource-${index + 1}`
  );
}

function participantDegrees<T extends SequenceParticipant>(
  tickets: Array<PairTicket<T>>
): Map<string, number> {
  const degrees = new Map<string, number>();
  for (const ticket of tickets) {
    degrees.set(ticket.a.uid, (degrees.get(ticket.a.uid) ?? 0) + 1);
    degrees.set(ticket.b.uid, (degrees.get(ticket.b.uid) ?? 0) + 1);
  }
  return degrees;
}

function pairMaximum<T extends SequenceParticipant>(
  pair: SequencePair<T>,
  values: ReadonlyMap<string, number>
): number {
  return Math.max(values.get(pair.a.uid) ?? 0, values.get(pair.b.uid) ?? 0);
}

function pairSum<T extends SequenceParticipant>(
  pair: SequencePair<T>,
  values: ReadonlyMap<string, number>
): number {
  return (values.get(pair.a.uid) ?? 0) + (values.get(pair.b.uid) ?? 0);
}

function allPairKeys<T extends SequenceParticipant>(
  participants: T[]
): string[] {
  return pairTickets(participants, new Set(), 1).map((ticket) => ticket.key);
}

function unitDistanceLookup(
  resourceUnitIds: string[],
  proximity: EventSuccessUnitProximity[]
): ReadonlyMap<string, number> {
  const distance = new Map<string, number>();
  resourceUnitIds.forEach((id, index) => {
    distance.set(assignmentConstraintPairKey(id, id), 0);
    resourceUnitIds.forEach((otherId, otherIndex) => {
      if (id === otherId) return;
      distance.set(
        assignmentConstraintPairKey(id, otherId),
        Math.abs(index - otherIndex)
      );
    });
  });
  for (const edge of proximity) {
    if (!Number.isFinite(edge.distance) || edge.distance < 0) continue;
    distance.set(
      assignmentConstraintPairKey(edge.aUnitId, edge.bUnitId),
      edge.distance
    );
  }
  return distance;
}

function participantMovementCost(
  uid: string,
  destinationUnitId: string,
  previousUnitByUid: ReadonlyMap<string, string>,
  distance: ReadonlyMap<string, number>
): number {
  const previous = previousUnitByUid.get(uid);
  if (previous === undefined || previous === destinationUnitId) return 0;
  return distance.get(
    assignmentConstraintPairKey(previous, destinationUnitId)
  ) ?? Number.MAX_SAFE_INTEGER;
}

function boundedInteger(value: number, min: number, max: number): number {
  if (!Number.isFinite(value)) return min;
  return Math.max(min, Math.min(max, Math.floor(value)));
}

function finiteNonNegative(value: number): number {
  return Number.isFinite(value) ? Math.max(0, value) : 0;
}
