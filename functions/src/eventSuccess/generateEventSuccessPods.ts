import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {
  BlockDocument,
  ClubDocument,
  EventDocument,
  UserProfileDocument,
} from "../shared/generated/firestoreAdminTypes";
import {requireAuth} from "../shared/auth";
import {EventIdCallablePayload} from
  "../shared/generated/eventIdCallablePayload";
import {OverrideEventSuccessGroupsCallablePayload} from
  "../shared/generated/overrideEventSuccessGroupsCallablePayload";
import {
  validateEventIdCallablePayload,
  validateOverrideEventSuccessGroupsCallablePayload,
} from
  "../shared/generated/schemaValidators";
import {validateCallableWithAjv, requireDoc} from "../shared/validation";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {normalizeEventIdPayload} from "../events/eventPayloadNormalization";
import {isClubHost} from "../shared/clubHosts";
import {
  AssignmentParticipant,
  assignmentPairKey,
  optimizeEventSuccessAssignments,
  OptimizedGroup,
  OptimizedRotationRound,
} from "./assignmentOptimizer";
import {
  AssignmentTopology,
  EventSuccessUnitKind,
  resolveAssignmentTopology,
  rotationRoundCountForDuration,
  unitLabel,
  unitSingularLabel,
  unitSubtitle,
} from "./assignmentTopology";
import {
  EventSuccessAssignmentAlgorithm,
  EventSuccessCompatibilityPolicy,
  eventSuccessPrimitivesFor,
} from "./formatPrimitives";

const MICRO_PODS_MODULE_ID = "micro_pods";
const DEFAULT_TARGET_UNIT_SIZE = 5;
const MAX_IN_FILTER_VALUES = 30;
const ACTIVE_STATUSES = ["attended", "signedUp"] as const;

interface EventSuccessPodsDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

interface EventSuccessPlanDocument {
  eventId?: string;
  clubId?: string;
  selectedModuleIds?: unknown;
  structureConfig?: {
    unitKind?: unknown;
    unitSize?: unknown;
    unitCount?: unknown;
    rotationIntervalMinutes?: unknown;
  };
}

interface EventParticipationDocument {
  uid?: string;
  status?: string;
}

interface EventSuccessPreferenceDocument {
  uid?: string;
  microPodsOptedOut?: boolean;
}

interface ActiveParticipant extends AssignmentParticipant {
  uid: string;
  status: typeof ACTIVE_STATUSES[number];
  gender?: string;
  interestedInGenders: string[];
}

type GroupCompatibilitySignal =
  "mutual_interest" |
  "one_way_interest" |
  "questionnaire_match" |
  "social" |
  "mixed" |
  "host_override";

interface GeneratedGroupRotationSlot {
  roundIndex: number;
  label: string;
  unitLabel: string;
  startsAt: FirebaseFirestore.Timestamp;
  endsAt: FirebaseFirestore.Timestamp;
  peerUids: string[];
  compatibility: GroupCompatibilitySignal;
}

interface GeneratedAssignment {
  eventId: string;
  clubId: string;
  uid: string;
  moduleId: string;
  label: string;
  displayTitle: string;
  displaySubtitle: string;
  peerUids: string[];
  groupRotationSlots?: GeneratedGroupRotationSlot[];
  source: string;
  createdAt: FirebaseFirestore.FieldValue;
  updatedAt: FirebaseFirestore.FieldValue;
}

interface AssignmentGroup extends OptimizedGroup<ActiveParticipant> {
  label?: string;
}

interface AssignmentGroupRound {
  roundIndex: number;
  groups: AssignmentGroup[];
}

interface BuiltPods {
  groups: AssignmentGroup[];
  groupRounds: AssignmentGroupRound[];
  podCount: number;
}

interface EventTiming {
  startMillis: number;
  endMillis: number;
}

const defaultDeps: EventSuccessPodsDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  checkRateLimit: defaultCheckRateLimit,
};

/**
 * Generates deterministic V1 micro-pod assignment docs for a hosted event.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {EventSuccessPodsDeps} deps Injectable dependencies for tests.
 * @return {Promise<{assignmentCount: number, podCount: number}>} Summary.
 */
export async function generateEventSuccessPodsHandler(
  request: CallableRequest<unknown>,
  deps: EventSuccessPodsDeps = defaultDeps
): Promise<{assignmentCount: number; podCount: number}> {
  const uid = requireAuth(request);
  const {eventId} = validateCallableWithAjv<EventIdCallablePayload>(
    request,
    validateEventIdCallablePayload,
    normalizeEventIdPayload
  );

  const db = deps.firestore();
  await deps.checkRateLimit?.(db, uid, "generateEventSuccessPods");

  const eventRef = db.collection("events").doc(eventId);
  const planRef = db.collection("eventSuccessPlans").doc(eventId);
  const [eventSnap, planSnap] = await Promise.all([
    eventRef.get(),
    planRef.get(),
  ]);

  if (!eventSnap.exists) {
    throw new HttpsError("not-found", "Event not found.");
  }
  if (!planSnap.exists) {
    throw new HttpsError("failed-precondition",
      "Event-success setup has not been saved.");
  }

  const event = requireDoc<EventDocument>(

    eventSnap,

    "EventDocument"

  );
  if (event.status === "cancelled") {
    throw new HttpsError("failed-precondition",
      "This event has been cancelled.");
  }

  const clubSnap = await db.collection("clubs").doc(event.clubId).get();
  if (!clubSnap.exists) {
    throw new HttpsError("not-found", "Club not found.");
  }
  const club = requireDoc<ClubDocument>(
    clubSnap,
    "ClubDocument"
  );
  if (!isClubHost(club, uid)) {
    throw new HttpsError("permission-denied",
      "Only the club host can generate event pods.");
  }

  const plan = requireDoc<EventSuccessPlanDocument>(
    planSnap,
    "EventSuccessPlanDocument"
  );
  if (plan.eventId !== undefined && plan.eventId !== eventId) {
    throw new HttpsError("failed-precondition",
      "Event-success plan does not match this event.");
  }
  if (plan.clubId !== undefined && plan.clubId !== event.clubId) {
    throw new HttpsError("failed-precondition",
      "Event-success plan does not match this club.");
  }
  if (!moduleSelected(plan.selectedModuleIds, MICRO_PODS_MODULE_ID)) {
    throw new HttpsError("failed-precondition",
      "Micro-pods are not enabled for this event.");
  }

  const participationsSnap = await db
    .collection("eventParticipations")
    .where("eventId", "==", eventId)
    .where("status", "in", [...ACTIVE_STATUSES])
    .get();
  const optedOutUids = await fetchMicroPodsOptOutUids(db, eventId);
  const participants = participationsSnap.docs
    .map((doc) => doc.data() as EventParticipationDocument)
    .map(toActiveParticipant)
    .filter((participant): participant is ActiveParticipant =>
      participant !== null
    )
    .filter((participant) => !optedOutUids.has(participant.uid))
    .sort(compareParticipants);
  const eligibleParticipants = await hydrateParticipants(
    db,
    preferCheckedInParticipants(participants)
  );

  const blockedPairs = await fetchBlockedPairs(db, eligibleParticipants);
  const primitives = eventSuccessPrimitivesFor(event.eventFormat);
  const topology = resolveAssignmentTopology(
    plan,
    eligibleParticipants.length,
    {
      defaultUnitKind: "pods",
      defaultUnitSize: DEFAULT_TARGET_UNIT_SIZE,
    }
  );
  const timing = topology.rotationsEnabled ? eventTimingFor(event) : undefined;
  const builtPods = buildPods({
    participants: eligibleParticipants,
    blockedPairs,
    topology,
    assignmentAlgorithm: primitives.assignmentAlgorithm,
    compatibilityPolicy: primitives.compatibilityPolicy,
    timing,
  });
  const assignments = buildAssignments({
    eventId,
    clubId: event.clubId,
    unitKind: topology.unitKind,
    groups: builtPods.groups,
    groupRounds: builtPods.groupRounds,
    rotationIntervalMinutes: topology.rotationIntervalMinutes,
    eventStartMillis: timing?.startMillis,
    source: "server_v1",
    now: deps.serverTimestamp(),
  });
  await writeAssignments(db, eventId, assignments);

  return {
    assignmentCount: assignments.size,
    podCount: builtPods.podCount,
  };
}

export const generateEventSuccessPods = onCall(
  appCheckCallableOptions,
  (request) => generateEventSuccessPodsHandler(request)
);

/**
 * Applies host-authored group, table, team, or pod assignments.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {EventSuccessPodsDeps} deps Injectable dependencies for tests.
 * @return {Promise<{assignmentCount: number, roundCount: number}>} Summary.
 */
export async function overrideEventSuccessGroupsHandler(
  request: CallableRequest<unknown>,
  deps: EventSuccessPodsDeps = defaultDeps
): Promise<{
  assignmentCount: number;
  roundCount: number;
  groupCount: number;
}> {
  const uid = requireAuth(request);
  const payload =
    validateCallableWithAjv<OverrideEventSuccessGroupsCallablePayload>(
      request,
      validateOverrideEventSuccessGroupsCallablePayload
    );

  const db = deps.firestore();
  await deps.checkRateLimit?.(db, uid, "overrideEventSuccessGroups");

  const {event, plan} = await loadGroupEventContext(db, payload.eventId, uid);
  const participationsSnap = await db
    .collection("eventParticipations")
    .where("eventId", "==", payload.eventId)
    .where("status", "in", [...ACTIVE_STATUSES])
    .get();
  const optedOutUids = await fetchMicroPodsOptOutUids(db, payload.eventId);
  const participants = participationsSnap.docs
    .map((doc) => doc.data() as EventParticipationDocument)
    .map(toActiveParticipant)
    .filter((participant): participant is ActiveParticipant =>
      participant !== null
    )
    .filter((participant) => !optedOutUids.has(participant.uid))
    .sort(compareParticipants);
  const eligibleParticipants = await hydrateParticipants(
    db,
    preferCheckedInParticipants(participants)
  );
  const blockedPairs = await fetchBlockedPairs(db, eligibleParticipants);
  const topology = resolveAssignmentTopology(
    plan,
    eligibleParticipants.length,
    {
      defaultUnitKind: "pods",
      defaultUnitSize: DEFAULT_TARGET_UNIT_SIZE,
    }
  );
  const timing = topology.rotationsEnabled ? eventTimingFor(event) : undefined;
  const rounds = buildOverrideGroupRounds({
    inputRounds: payload.rounds,
    participants: eligibleParticipants,
    blockedPairs,
    topology,
    timing,
  });
  const assignments = buildAssignments({
    eventId: payload.eventId,
    clubId: event.clubId,
    unitKind: topology.unitKind,
    groups: topology.rotationsEnabled ? [] : rounds[0].groups,
    groupRounds: topology.rotationsEnabled ? rounds : [],
    rotationIntervalMinutes: topology.rotationIntervalMinutes,
    eventStartMillis: timing?.startMillis,
    source: "host_override_v1",
    now: deps.serverTimestamp(),
  });
  await writeAssignments(db, payload.eventId, assignments);

  return {
    assignmentCount: assignments.size,
    roundCount: rounds.length,
    groupCount: rounds.reduce((count, round) => count + round.groups.length, 0),
  };
}

export const overrideEventSuccessGroups = onCall(
  appCheckCallableOptions,
  (request) => overrideEventSuccessGroupsHandler(request)
);

/**
 * Checks whether the saved event-success plan includes a module.
 * @param {unknown} selectedModuleIds Persisted selected module ids.
 * @param {string} moduleId Module id to check.
 * @return {boolean} True when selected.
 */
function moduleSelected(selectedModuleIds: unknown, moduleId: string): boolean {
  return Array.isArray(selectedModuleIds) &&
    selectedModuleIds.includes(moduleId);
}

/**
 * Loads and authorizes the group assignment context for a hosted event.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} eventId Event id.
 * @param {string} uid Requesting user id.
 * @return {Promise<object>} Authorized event and saved plan.
 */
async function loadGroupEventContext(
  db: FirebaseFirestore.Firestore,
  eventId: string,
  uid: string
): Promise<{event: EventDocument; plan: EventSuccessPlanDocument}> {
  const eventRef = db.collection("events").doc(eventId);
  const planRef = db.collection("eventSuccessPlans").doc(eventId);
  const [eventSnap, planSnap] = await Promise.all([
    eventRef.get(),
    planRef.get(),
  ]);

  if (!eventSnap.exists) {
    throw new HttpsError("not-found", "Event not found.");
  }
  if (!planSnap.exists) {
    throw new HttpsError("failed-precondition",
      "Event-success setup has not been saved.");
  }

  const event = requireDoc<EventDocument>(

    eventSnap,

    "EventDocument"

  );
  if (event.status === "cancelled") {
    throw new HttpsError("failed-precondition",
      "This event has been cancelled.");
  }

  const clubSnap = await db.collection("clubs").doc(event.clubId).get();
  if (!clubSnap.exists) {
    throw new HttpsError("not-found", "Club not found.");
  }
  const club = requireDoc<ClubDocument>(
    clubSnap,
    "ClubDocument"
  );
  if (!isClubHost(club, uid)) {
    throw new HttpsError("permission-denied",
      "Only the club host can manage event groups.");
  }

  const plan = requireDoc<EventSuccessPlanDocument>(
    planSnap,
    "EventSuccessPlanDocument"
  );
  if (plan.eventId !== undefined && plan.eventId !== eventId) {
    throw new HttpsError("failed-precondition",
      "Event-success plan does not match this event.");
  }
  if (plan.clubId !== undefined && plan.clubId !== event.clubId) {
    throw new HttpsError("failed-precondition",
      "Event-success plan does not match this club.");
  }
  if (!moduleSelected(plan.selectedModuleIds, MICRO_PODS_MODULE_ID)) {
    throw new HttpsError("failed-precondition",
      "Micro-pods are not enabled for this event.");
  }

  return {event, plan};
}

/**
 * Converts a participation edge into an active pod candidate.
 * @param {EventParticipationDocument} data Participation document data.
 * @return {ActiveParticipant | null} Active participant or null.
 */
function toActiveParticipant(
  data: EventParticipationDocument
): ActiveParticipant | null {
  if (typeof data.uid !== "string" || data.uid.length === 0) return null;
  if (data.status !== "attended" && data.status !== "signedUp") return null;
  return {uid: data.uid, status: data.status, interestedInGenders: []};
}

/**
 * Loads attendee micro-pod opt-outs for the event.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} eventId Event id.
 * @return {Promise<Set<string>>} Uids excluded from micro-pod generation.
 */
async function fetchMicroPodsOptOutUids(
  db: FirebaseFirestore.Firestore,
  eventId: string
): Promise<Set<string>> {
  const snap = await db
    .collection("eventSuccessPreferences")
    .where("eventId", "==", eventId)
    .get();
  const optedOut = new Set<string>();
  for (const doc of snap.docs) {
    const preference = doc.data() as EventSuccessPreferenceDocument;
    if (
      preference.microPodsOptedOut === true &&
      typeof preference.uid === "string" &&
      preference.uid.length > 0
    ) {
      optedOut.add(preference.uid);
    }
  }
  return optedOut;
}

/**
 * Sorts active participants into deterministic pod input order.
 * @param {ActiveParticipant} a First participant.
 * @param {ActiveParticipant} b Second participant.
 * @return {number} Sort comparison value.
 */
function compareParticipants(
  a: ActiveParticipant,
  b: ActiveParticipant
): number {
  const byStatus = statusRank(a.status) - statusRank(b.status);
  if (byStatus !== 0) return byStatus;
  return a.uid.localeCompare(b.uid);
}

/**
 * Ranks checked-in attendees ahead of signed-up attendees.
 * @param {string} status Participation status.
 * @return {number} Sort rank.
 */
function statusRank(status: ActiveParticipant["status"]): number {
  return status === "attended" ? 0 : 1;
}

/**
 * Uses checked-in attendees once a live pod can be formed.
 * Falls back to signed-up attendees for pre-arrival planning.
 * @param {ActiveParticipant[]} participants Active participation edges.
 * @return {ActiveParticipant[]} Pod input.
 */
function preferCheckedInParticipants(
  participants: ActiveParticipant[]
): ActiveParticipant[] {
  const attended = participants.filter((participant) =>
    participant.status === "attended"
  );
  return attended.length >= 2 ? attended : participants;
}

/**
 * Adds optional profile cohort data without dropping active participants.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {ActiveParticipant[]} participants Active participants.
 * @return {Promise<ActiveParticipant[]>} Hydrated participants.
 */
async function hydrateParticipants(
  db: FirebaseFirestore.Firestore,
  participants: ActiveParticipant[]
): Promise<ActiveParticipant[]> {
  const snaps = await Promise.all(
    participants.map((participant) =>
      db.collection("users").doc(participant.uid).get()
    )
  );
  return participants.map((participant, index) => {
    const profile = snaps[index].data() as
      | Partial<UserProfileDocument>
      | undefined;
    if (profile === undefined) return participant;
    return {
      ...participant,
      gender: typeof profile.gender === "string" ?
        profile.gender :
        undefined,
      interestedInGenders: Array.isArray(profile.interestedInGenders) ?
        profile.interestedInGenders.filter((gender) =>
          typeof gender === "string"
        ) :
        [],
    };
  });
}

/**
 * Reads event timing for rotating group assignments.
 * @param {EventDocument} event Firestore event document.
 * @return {EventTiming} Event start and end in millis.
 */
function eventTimingFor(event: EventDocument): EventTiming {
  const startMillis = timestampMillis(event.startTime, "startTime");
  const endMillis = timestampMillis(event.endTime, "endTime");
  if (endMillis <= startMillis) {
    throw new HttpsError("failed-precondition",
      "Event end time must be after the start time.");
  }
  return {startMillis, endMillis};
}

/**
 * Converts a Firestore timestamp-like value to millis.
 * @param {unknown} value Raw timestamp-like value.
 * @param {string} field Field name for error copy.
 * @return {number} Milliseconds since epoch.
 */
function timestampMillis(value: unknown, field: string): number {
  if (
    value !== null &&
    typeof value === "object" &&
    "toMillis" in value &&
    typeof value.toMillis === "function"
  ) {
    const millis = value.toMillis();
    if (typeof millis === "number" && Number.isFinite(millis)) return millis;
  }
  throw new HttpsError("failed-precondition",
    `Event is missing ${field} for rotating groups.`);
}

/**
 * Splits active participants into deterministic topology-driven units.
 * @param {object} params Pod-build inputs.
 * @return {BuiltPods} Assignment groups and optional group rounds.
 */
function buildPods(params: {
  participants: ActiveParticipant[];
  blockedPairs: Set<string>;
  topology: AssignmentTopology;
  assignmentAlgorithm: EventSuccessAssignmentAlgorithm;
  compatibilityPolicy: EventSuccessCompatibilityPolicy;
  timing?: EventTiming;
}): BuiltPods {
  if (params.participants.length === 0) {
    return {groups: [], groupRounds: [], podCount: 0};
  }
  const rotationIntervalMinutes = params.topology.rotationIntervalMinutes;
  const rotationRoundCount = rotationIntervalMinutes === null ?
    0 :
    rotationRoundCountForDuration({
      eventStartMillis: params.timing?.startMillis ?? 0,
      eventEndMillis: params.timing?.endMillis ?? 0,
      rotationIntervalMinutes,
    });
  const plan = optimizeEventSuccessAssignments({
    participants: params.participants,
    blockedPairs: params.blockedPairs,
    topology: params.topology,
    assignmentAlgorithm: params.assignmentAlgorithm,
    compatibilityPolicy: params.compatibilityPolicy,
    questionnaireMode: "icebreaker",
    rotationRoundCount,
  });
  const groupRounds = [
    ...plan.groupRounds,
    ...plan.rotationRounds.map(pairRoundToGroupRound),
  ];
  if (groupRounds.length > 0) {
    return {
      groups: [],
      groupRounds,
      podCount: groupRounds[0]?.groups.length ?? 0,
    };
  }
  const groups = plan.groups.map((group) => ({
    ...group,
    label: unitLabel(params.topology.unitKind, group.groupIndex),
  }));
  return {groups, groupRounds: [], podCount: groups.length};
}

/**
 * Adapts pair-sized optimizer rounds into the group-slot payload shape.
 * @param {OptimizedRotationRound<ActiveParticipant>} round Pair round.
 * @return {AssignmentGroupRound} Group-compatible round.
 */
function pairRoundToGroupRound(
  round: OptimizedRotationRound<ActiveParticipant>
): AssignmentGroupRound {
  return {
    roundIndex: round.roundIndex,
    groups: round.pairs.map((pair, index) => ({
      groupIndex: index,
      participants: [pair.a, pair.b],
      score: pair.score,
      mutualDyadCount: pair.mutualInterest ? 1 : 0,
      plausibleDyadCount: pair.compatibility === "social" ? 0 : 1,
    })),
  };
}

/**
 * Builds host-authored group rounds after safety and eligibility checks.
 * @param {object} params Override inputs.
 * @return {AssignmentGroupRound[]} Validated host-authored group rounds.
 */
function buildOverrideGroupRounds(params: {
  inputRounds: OverrideEventSuccessGroupsCallablePayload["rounds"];
  participants: ActiveParticipant[];
  blockedPairs: Set<string>;
  topology: AssignmentTopology;
  timing?: EventTiming;
}): AssignmentGroupRound[] {
  const participantsByUid = new Map(
    params.participants.map((participant) => [participant.uid, participant])
  );
  const maxRoundCount = overrideMaxRoundCount({
    topology: params.topology,
    timing: params.timing,
  });
  const seenRoundIndexes = new Set<number>();
  const rounds: AssignmentGroupRound[] = [];

  for (const inputRound of params.inputRounds) {
    if (seenRoundIndexes.has(inputRound.roundIndex)) {
      throw new HttpsError("invalid-argument",
        "Each group round can be overridden only once.");
    }
    seenRoundIndexes.add(inputRound.roundIndex);
    if (inputRound.roundIndex >= maxRoundCount) {
      throw new HttpsError("invalid-argument",
        "Group round is outside the event format.");
    }

    const usedInRound = new Set<string>();
    const groups: AssignmentGroup[] = [];
    for (const [groupIndex, inputGroup] of inputRound.groups.entries()) {
      const participants = inputGroup.participantUids.map((memberUid) => {
        const participant = participantsByUid.get(memberUid);
        if (participant === undefined) {
          throw new HttpsError("failed-precondition",
            "One or more attendees are no longer eligible for groups.");
        }
        if (!usedInRound.add(memberUid)) {
          throw new HttpsError("invalid-argument",
            "Each attendee can appear once per group round.");
        }
        return participant;
      });
      assertGroupHasNoBlockedPair(participants, params.blockedPairs);
      groups.push({
        groupIndex,
        label: inputGroup.label.trim() ||
          unitLabel(params.topology.unitKind, groupIndex),
        participants,
        score: 0,
        mutualDyadCount: 0,
        plausibleDyadCount: 0,
      });
    }
    if (groups.length > 0) {
      rounds.push({roundIndex: inputRound.roundIndex, groups});
    }
  }

  if (rounds.length === 0) {
    throw new HttpsError("invalid-argument", "Add at least one group.");
  }

  return rounds.sort((a, b) => a.roundIndex - b.roundIndex);
}

/**
 * Computes the maximum number of override rounds for this topology.
 * @param {object} params Topology and timing inputs.
 * @return {number} Maximum override round count.
 */
function overrideMaxRoundCount(params: {
  topology: AssignmentTopology;
  timing?: EventTiming;
}): number {
  const rotationIntervalMinutes = params.topology.rotationIntervalMinutes;
  if (!params.topology.rotationsEnabled || rotationIntervalMinutes === null) {
    return 1;
  }
  if (params.timing === undefined) return 0;
  return rotationRoundCountForDuration({
    eventStartMillis: params.timing.startMillis,
    eventEndMillis: params.timing.endMillis,
    rotationIntervalMinutes,
  });
}

/**
 * Rejects a host group that contains a blocked pair.
 * @param {ActiveParticipant[]} participants Participants in one group.
 * @param {Set<string>} blockedPairs Undirected blocked pair keys.
 */
function assertGroupHasNoBlockedPair(
  participants: ActiveParticipant[],
  blockedPairs: Set<string>
): void {
  for (let i = 0; i < participants.length; i++) {
    for (let j = i + 1; j < participants.length; j++) {
      if (blockedPairs.has(blockedPairKey(
        participants[i].uid,
        participants[j].uid
      ))) {
        throw new HttpsError("failed-precondition",
          "Blocked attendees cannot share a group.");
      }
    }
  }
}

/**
 * Loads block edges among the active participants in either direction.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {ActiveParticipant[]} participants Active participants.
 * @return {Promise<Set<string>>} Undirected blocked pair keys.
 */
async function fetchBlockedPairs(
  db: FirebaseFirestore.Firestore,
  participants: ActiveParticipant[]
): Promise<Set<string>> {
  const participantUids = [...new Set(
    participants.map((participant) => participant.uid)
  )];
  if (participantUids.length < 2) return new Set();

  const participantSet = new Set(participantUids);
  const chunks = chunk(participantUids, MAX_IN_FILTER_VALUES);
  const snaps = await Promise.all(
    chunks.map((uids) =>
      db
        .collection("blocks")
        .where("blockerUserId", "in", uids)
        .get()
    )
  );

  const pairs = new Set<string>();
  for (const snap of snaps) {
    for (const doc of snap.docs) {
      const block = doc.data() as Partial<BlockDocument>;
      if (
        typeof block.blockerUserId !== "string" ||
        typeof block.blockedUserId !== "string" ||
        !participantSet.has(block.blockerUserId) ||
        !participantSet.has(block.blockedUserId)
      ) {
        continue;
      }
      pairs.add(blockedPairKey(block.blockerUserId, block.blockedUserId));
    }
  }
  return pairs;
}

/**
 * Builds a deterministic undirected pair key.
 * @param {string} uidA First uid.
 * @param {string} uidB Second uid.
 * @return {string} Pair key.
 */
function blockedPairKey(uidA: string, uidB: string): string {
  return assignmentPairKey(uidA, uidB);
}

/**
 * Splits an array into chunks for Firestore `in` query limits.
 * @template T
 * @param {Array<T>} values Values to chunk.
 * @param {number} size Chunk size.
 * @return {Array<Array<T>>} Chunks.
 */
function chunk<T>(values: T[], size: number): T[][] {
  const chunks: T[][] = [];
  for (let index = 0; index < values.length; index += size) {
    chunks.push(values.slice(index, index + size));
  }
  return chunks;
}

/**
 * Builds assignment documents for each participant in each generated pod.
 * @param {object} params Assignment build params.
 * @param {string} params.eventId Event id.
 * @param {string} params.clubId Club id.
 * @param {AssignmentGroup[]} params.groups Pod groups.
 * @param {AssignmentGroupRound[]} params.groupRounds Rotations.
 * @param {FirebaseFirestore.FieldValue} params.now Server timestamp field.
 * @return {Map<string, GeneratedAssignment>} Assignment docs by id.
 */
function buildAssignments(params: {
  eventId: string;
  clubId: string;
  unitKind: EventSuccessUnitKind;
  groups: AssignmentGroup[];
  groupRounds: AssignmentGroupRound[];
  rotationIntervalMinutes: number | null;
  eventStartMillis?: number;
  source: string;
  now: FirebaseFirestore.FieldValue;
}): Map<string, GeneratedAssignment> {
  if (
    params.groupRounds.length > 0 &&
    params.rotationIntervalMinutes !== null &&
    params.eventStartMillis !== undefined
  ) {
    return buildGroupRotationAssignments({
      eventId: params.eventId,
      clubId: params.clubId,
      unitKind: params.unitKind,
      groupRounds: params.groupRounds,
      rotationIntervalMinutes: params.rotationIntervalMinutes,
      eventStartMillis: params.eventStartMillis,
      source: params.source,
      now: params.now,
    });
  }
  const assignments = new Map<string, GeneratedAssignment>();
  params.groups.forEach((group, index) => {
    const label = group.label ?? unitLabel(params.unitKind, index);
    const groupUids = group.participants.map((participant) => participant.uid);
    for (const participant of group.participants) {
      const docId = assignmentId(params.eventId, participant.uid);
      assignments.set(docId, {
        eventId: params.eventId,
        clubId: params.clubId,
        uid: participant.uid,
        moduleId: MICRO_PODS_MODULE_ID,
        label,
        displayTitle: label,
        displaySubtitle: unitSubtitle(
          params.unitKind,
          group.participants.length
        ),
        peerUids: groupUids.filter((peerUid) => peerUid !== participant.uid),
        source: params.source,
        createdAt: params.now,
        updatedAt: params.now,
      });
    }
  });
  return assignments;
}

/**
 * Builds attendee assignment docs for rotating group units.
 * @param {object} params Assignment build params.
 * @return {Map<string, GeneratedAssignment>} Assignment docs by id.
 */
function buildGroupRotationAssignments(params: {
  eventId: string;
  clubId: string;
  unitKind: EventSuccessUnitKind;
  groupRounds: AssignmentGroupRound[];
  rotationIntervalMinutes: number;
  eventStartMillis: number;
  source: string;
  now: FirebaseFirestore.FieldValue;
}): Map<string, GeneratedAssignment> {
  const slotsByUid = new Map<string, GeneratedGroupRotationSlot[]>();
  const participantUids = new Set<string>();
  for (const round of params.groupRounds) {
    for (const group of round.groups) {
      const groupUids = group.participants.map((participant) => {
        participantUids.add(participant.uid);
        return participant.uid;
      });
      const slotStartsAtMillis = params.eventStartMillis +
        round.roundIndex * params.rotationIntervalMinutes * 60000;
      const slotEndsAtMillis = slotStartsAtMillis +
        params.rotationIntervalMinutes * 60000;
      for (const participant of group.participants) {
        const slot: GeneratedGroupRotationSlot = {
          roundIndex: round.roundIndex,
          label: `Round ${round.roundIndex + 1}`,
          unitLabel: group.label ??
            unitLabel(params.unitKind, group.groupIndex),
          startsAt: admin.firestore.Timestamp.fromMillis(slotStartsAtMillis),
          endsAt: admin.firestore.Timestamp.fromMillis(slotEndsAtMillis),
          peerUids: groupUids.filter((uid) => uid !== participant.uid),
          compatibility: params.source === "host_override_v1" ?
            "host_override" :
            groupCompatibilitySignal(group),
        };
        const slotsForUid = slotsByUid.get(participant.uid);
        if (slotsForUid === undefined) {
          slotsByUid.set(participant.uid, [slot]);
        } else {
          slotsForUid.push(slot);
        }
      }
    }
  }

  const assignments = new Map<string, GeneratedAssignment>();
  for (const uid of [...participantUids].sort()) {
    const slots = (slotsByUid.get(uid) ?? [])
      .sort((a, b) => a.roundIndex - b.roundIndex);
    const peerUids = uniqueSorted(
      slots.flatMap((slot) => slot.peerUids)
    );
    const rotationNoun = unitSingularLabel(params.unitKind).toLowerCase();
    const title =
      `${slots.length} ${rotationNoun} ` +
      `rotation${slots.length === 1 ? "" : "s"}`;
    const intervalLabel =
      `${params.rotationIntervalMinutes}-minute ${rotationNoun}s`;
    const peerCountLabel =
      `${peerUids.length} ${peerUids.length === 1 ? "person" : "people"}`;
    const docId = assignmentId(params.eventId, uid);
    assignments.set(docId, {
      eventId: params.eventId,
      clubId: params.clubId,
      uid,
      moduleId: MICRO_PODS_MODULE_ID,
      label: `${unitSingularLabel(params.unitKind)} rotations`,
      displayTitle: title,
      displaySubtitle:
        `${intervalLabel} with ${peerCountLabel} across the event.`,
      peerUids,
      groupRotationSlots: slots,
      source: params.source,
      createdAt: params.now,
      updatedAt: params.now,
    });
  }
  return assignments;
}

/**
 * Summarizes group compatibility into the assignment contract enum.
 * @param {OptimizedGroup<ActiveParticipant>} group Optimized group summary.
 * @return {GroupCompatibilitySignal} Group compatibility label.
 */
function groupCompatibilitySignal(
  group: OptimizedGroup<ActiveParticipant>
): GroupCompatibilitySignal {
  if (group.mutualDyadCount > 0 && group.plausibleDyadCount > 1) {
    return "mixed";
  }
  if (group.mutualDyadCount > 0) return "mutual_interest";
  if (group.plausibleDyadCount > 0) return "social";
  return "mixed";
}

/**
 * Returns sorted unique values.
 * @param {string[]} values Raw values.
 * @return {string[]} Stable unique list.
 */
function uniqueSorted(values: string[]): string[] {
  return [...new Set(values)].sort();
}

/**
 * Replaces stale generated assignment docs for this event and module.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} eventId Event id.
 * @param {Map<string, GeneratedAssignment>} assignments New assignments.
 */
async function writeAssignments(
  db: FirebaseFirestore.Firestore,
  eventId: string,
  assignments: Map<string, GeneratedAssignment>
): Promise<void> {
  const existingSnap = await db
    .collection("eventSuccessAssignments")
    .where("eventId", "==", eventId)
    .where("moduleId", "==", MICRO_PODS_MODULE_ID)
    .get();
  const batch = db.batch();
  for (const doc of existingSnap.docs) {
    if (!assignments.has(doc.id)) {
      batch.delete(doc.ref);
    }
  }
  for (const [docId, assignment] of assignments.entries()) {
    batch.set(
      db.collection("eventSuccessAssignments").doc(docId),
      assignment,
      {merge: true}
    );
  }
  await batch.commit();
}

/**
 * Returns the deterministic micro-pod assignment document id.
 * @param {string} eventId Event id.
 * @param {string} uid User id.
 * @return {string} Assignment document id.
 */
function assignmentId(eventId: string, uid: string): string {
  return `${eventId}_${MICRO_PODS_MODULE_ID}_${uid}`;
}
