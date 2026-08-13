import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {EventDocument, BlockDocument} from
  "../shared/generated/firestoreAdminTypes";
import {requireAuth} from "../shared/auth";
import {PrepareEventSuccessRotationDraftCallablePayload} from
  "../shared/generated/prepareEventSuccessRotationDraftCallablePayload";
import {OverrideEventSuccessRotationsCallablePayload} from
  "../shared/generated/overrideEventSuccessRotationsCallablePayload";
import {
  validatePrepareEventSuccessRotationDraftCallablePayload,
  validateOverrideEventSuccessRotationsCallablePayload,
} from
  "../shared/generated/schemaValidators";
import {validateCallableWithAjv, requireDoc} from "../shared/validation";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {normalizeEventIdPayload} from "../events/eventPayloadNormalization";
import {
  eventOrganizerRef,
  isEventOrganizerManager,
  requireEventOrganizer,
} from "../shared/eventOrganizers";
import {
  AssignmentParticipant,
  assignmentPairKey,
  AssignmentRotationPolicy,
  OptimizedPair,
  runAssignmentEngine,
} from "./assignmentOptimizer";
import {AssignmentConstraintConfig} from "./assignmentConstraints";
import {
  EventSuccessUnitKind,
  assertPairRotationTopology,
  resolveRotationIntervalMinutes,
  rotationRoundCountForDuration,
} from "./assignmentTopology";
import {
  CompatibilitySignal,
  QuestionnaireScoringMode,
} from "./compatibilityPolicy";
import {
  EventSuccessAssignmentAlgorithm,
  EventSuccessCompatibilityPolicy,
  EventSuccessMatchingObjective,
  eventSuccessPrimitivesFor,
} from "./formatPrimitives";
import {
  activityAttributesForProfile,
  assignmentConstraintsForStructureConfig,
  AssignmentPrimitiveStructureConfig,
  rotationPolicyForStructureConfig,
} from "./assignmentPrimitiveControls";
import {loadEventSuccessRoster} from "./eventSuccessRoster";
import {
  applyEventSuccessSpatialLayout,
  assignmentConstraintsForSpatialPlan,
  loadSelectedEventSuccessLayout,
  persistentSpatialPlanFields,
} from "./spatialLayout";

const GUIDED_ROTATIONS_MODULE_ID = "guided_rotations";
const COMPATIBILITY_QUESTIONNAIRE_MODULE_ID = "compatibility_questionnaire";
const ROUND_LENGTH_MINUTES = 15;
const MAX_IN_FILTER_VALUES = 30;
type ActiveStatus = "attended" | "signedUp";

interface EventSuccessRotationsDeps {
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
  compatibilityAffectsRanking?: unknown;
  liveControlRevision?: unknown;
  assignmentDraftRevision?: unknown;
  publishedRotationRoundIndex?: unknown;
  layoutId?: string | null;
  affinityConstraints?: Array<{
    aUid: string;
    bUid: string;
    value: "mustPair" | "mustSplit" | "avoidRepeat" | "neutral";
    scope: "thisRound" | "pinned";
  }>;
  spatialOverrides?: Array<{
    uid: string;
    targetPeerUid: string;
    layoutUnitId: string;
    scope: "thisRound" | "pinned";
  }>;
  structureConfig?: {
    unitKind?: unknown;
    unitSize?: unknown;
    unitCount?: unknown;
    rotationIntervalMinutes?: unknown;
  } & AssignmentPrimitiveStructureConfig;
}

interface EventSuccessPreferenceDocument {
  uid?: string;
  guidedRotationsOptedOut?: boolean;
}

interface EventSuccessCompatibilityResponseDocument {
  uid?: string;
  eventId?: string;
  answerIds?: unknown;
}

interface RotationParticipant extends AssignmentParticipant {
  uid: string;
  status: ActiveStatus;
  gender?: string;
  interestedInGenders: string[];
  compatibilityAnswerIds: string[];
}

interface RotationPair {
  a: RotationParticipant;
  b: RotationParticipant;
  score: number;
  compatibility: CompatibilitySignal | "host_override";
}

interface RotationRound {
  roundIndex: number;
  pairs: RotationPair[];
}

type AssignmentWhyCode =
  "host_override" |
  "mutual_interest" |
  "one_way_interest" |
  "questionnaire_match" |
  "social_fallback" |
  "fresh_peer" |
  "repeat_peer" |
  "sit_out" |
  "pair_slot";

interface RotationFairnessSummary {
  assignedRoundCount: number;
  sitOutRoundCount: number;
  uniquePeerCount: number;
  repeatPeerCount: number;
}

interface GeneratedRotationSlot {
  slotId?: string;
  roundIndex: number;
  label: string;
  startsAt: FirebaseFirestore.Timestamp;
  endsAt: FirebaseFirestore.Timestamp;
  peerUid: string;
  unitKind?: EventSuccessUnitKind;
  unitIndex?: number;
  peerCount?: number;
  compatibility: RotationPair["compatibility"];
  whySummary?: string;
  whyCodes?: AssignmentWhyCode[];
}

interface GeneratedSitOutSlot {
  roundIndex: number;
  label: string;
  startsAt: FirebaseFirestore.Timestamp;
  endsAt: FirebaseFirestore.Timestamp;
  whySummary: string;
  whyCodes: AssignmentWhyCode[];
}

interface GeneratedAssignment {
  eventId: string;
  clubId: string;
  organizerId: string;
  uid: string;
  moduleId: string;
  label: string;
  displayTitle: string;
  displaySubtitle: string;
  peerUids: string[];
  unitKind?: EventSuccessUnitKind;
  unitLabel?: string;
  layoutUnitId?: string;
  confirmedLayoutUnitId?: string | null;
  whySummary?: string;
  whyCodes?: AssignmentWhyCode[];
  rotationFairness?: RotationFairnessSummary;
  rotationSlots: GeneratedRotationSlot[];
  sitOutSlots?: GeneratedSitOutSlot[];
  source: string;
  createdAt: FirebaseFirestore.FieldValue;
  updatedAt: FirebaseFirestore.FieldValue;
}

const defaultDeps: EventSuccessRotationsDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  checkRateLimit: defaultCheckRateLimit,
};

/**
 * Generates guided one-to-one rotation schedules for a hosted event.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {EventSuccessRotationsDeps} deps Injectable dependencies for tests.
 * @return {Promise<{assignmentCount: number, roundCount: number}>} Summary.
 */
export async function generateEventSuccessRotationsHandler(
  request: CallableRequest<unknown>,
  deps: EventSuccessRotationsDeps = defaultDeps
): Promise<{assignmentCount: number; roundCount: number}> {
  const uid = requireAuth(request);
  const payload =
    validateCallableWithAjv<PrepareEventSuccessRotationDraftCallablePayload>(
      request,
      validatePrepareEventSuccessRotationDraftCallablePayload,
      normalizeEventIdPayload
    );

  const db = deps.firestore();
  await deps.checkRateLimit?.(db, uid, "generateEventSuccessRotations");

  return prepareEventSuccessRotationDraft({
    eventId: payload.eventId,
    expectedRevision: payload.expectedRevision,
    managerUid: uid,
  }, deps);
}

/**
 * Pre-computes the next unpublished round and stores it in the Host-only
 * draft collection. This function is also used by the asynchronous plan
 * trigger after a publish; beat transitions never import or invoke it.
 * @param {object} input Preparation fence and optional manager authorization.
 * @param {EventSuccessRotationsDeps} deps Injectable dependencies for tests.
 * @return {Promise<object>} Prepared round summary.
 */
export async function prepareEventSuccessRotationDraft(
  input: {
    eventId: string;
    expectedRevision: number;
    managerUid?: string;
  },
  deps: EventSuccessRotationsDeps = defaultDeps
): Promise<{assignmentCount: number; roundCount: number}> {
  const db = deps.firestore();

  const {
    event,
    plan,
    rotationIntervalMinutes,
    questionnaireMode,
    constraints,
    rotationPolicy,
  } =
    await loadRotationEventContext(db, input.eventId, input.managerUid);
  const liveControlRevision = nonNegativeInteger(plan.liveControlRevision);
  if (liveControlRevision !== input.expectedRevision) {
    throw staleLiveControlError();
  }
  const primitives = eventSuccessPrimitivesFor(event.eventFormat);
  if (primitives.assignmentResolution.status === "unsupported") {
    throw new HttpsError(
      "failed-precondition",
      primitives.assignmentResolution.reason
    );
  }
  const {participants, blockedPairs} =
    await loadEligibleRotationParticipants(
      db,
      input.eventId,
      questionnaireMode !== "icebreaker"
    );
  const rounds = buildRotationRounds({
    participants,
    blockedPairs,
    eventStartMillis: event.startTime.toMillis(),
    eventEndMillis: event.endTime.toMillis(),
    rotationIntervalMinutes,
    questionnaireMode,
    assignmentAlgorithm: primitives.assignmentAlgorithm,
    compatibilityPolicy: primitives.compatibilityPolicy,
    matchingObjective: primitives.matchingObjective,
    constraints,
    rotationPolicy,
  });
  const publishedRoundIndex = integerOr(
    plan.publishedRotationRoundIndex,
    -1
  );
  const targetRoundIndex = publishedRoundIndex + 1;
  const hasTargetRound = rounds.some(
    (round) => round.roundIndex === targetRoundIndex
  );
  const assignments = hasTargetRound ? buildAssignments({
    eventId: input.eventId,
    clubId: event.clubId,
    organizerId: event.organizerId ?? event.clubId,
    participants,
    rounds,
    eventStartMillis: event.startTime.toMillis(),
    rotationIntervalMinutes,
    source: "server_v1",
    now: deps.serverTimestamp(),
  }) : new Map<string, GeneratedAssignment>();
  const layout = await loadSelectedEventSuccessLayout(
    db,
    event.organizerId ?? event.clubId,
    plan
  );
  applyEventSuccessSpatialLayout(
    assignments,
    layout,
    plan,
    targetRoundIndex
  );
  await writeAssignmentDrafts({
    db,
    eventId: input.eventId,
    expectedRevision: input.expectedRevision,
    expectedPublishedRoundIndex: publishedRoundIndex,
    targetRoundIndex,
    assignments,
    now: deps.serverTimestamp(),
  });

  return {
    assignmentCount: assignments.size,
    roundCount: rounds.length,
  };
}

export const generateEventSuccessRotations = onCall(
  appCheckCallableOptions,
  (request) => generateEventSuccessRotationsHandler(request)
);

/**
 * Applies host-authored guided rotation pairings for a hosted event.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {EventSuccessRotationsDeps} deps Injectable dependencies for tests.
 * @return {Promise<{assignmentCount: number, roundCount: number}>} Summary.
 */
export async function overrideEventSuccessRotationsHandler(
  request: CallableRequest<unknown>,
  deps: EventSuccessRotationsDeps = defaultDeps
): Promise<{assignmentCount: number; roundCount: number}> {
  const uid = requireAuth(request);
  const payload =
    validateCallableWithAjv<OverrideEventSuccessRotationsCallablePayload>(
      request,
      validateOverrideEventSuccessRotationsCallablePayload
    );

  const db = deps.firestore();
  await deps.checkRateLimit?.(db, uid, "overrideEventSuccessRotations");

  const {event, plan, rotationIntervalMinutes} =
    await loadRotationEventContext(db, payload.eventId, uid);
  const liveControlRevision = nonNegativeInteger(plan.liveControlRevision);
  if (liveControlRevision !== payload.expectedRevision) {
    throw staleLiveControlError();
  }
  const {participants, blockedPairs} =
    await loadEligibleRotationParticipants(db, payload.eventId, false);
  const rounds = buildOverrideRounds({
    inputRounds: payload.rounds,
    participants,
    blockedPairs,
    eventStartMillis: event.startTime.toMillis(),
    eventEndMillis: event.endTime.toMillis(),
    rotationIntervalMinutes,
  });
  const assignments = buildAssignments({
    eventId: payload.eventId,
    clubId: event.clubId,

    organizerId: event.organizerId ?? event.clubId,
    participants,
    rounds,
    eventStartMillis: event.startTime.toMillis(),
    rotationIntervalMinutes,
    source: "host_override_v1",
    now: deps.serverTimestamp(),
  });
  const publishedRoundIndex = integerOr(
    plan.publishedRotationRoundIndex,
    -1
  );
  const targetRoundIndex = publishedRoundIndex + 1;
  if (!rounds.some((round) => round.roundIndex === targetRoundIndex)) {
    throw new HttpsError("failed-precondition",
      "The override must include the next unpublished round.");
  }
  const layout = await loadSelectedEventSuccessLayout(
    db,
    event.organizerId ?? event.clubId,
    plan
  );
  applyEventSuccessSpatialLayout(
    assignments,
    layout,
    plan,
    targetRoundIndex
  );
  await writeAssignmentDrafts({
    db,
    eventId: payload.eventId,
    expectedRevision: payload.expectedRevision,
    expectedPublishedRoundIndex: publishedRoundIndex,
    targetRoundIndex,
    assignments,
    now: deps.serverTimestamp(),
  });

  return {
    assignmentCount: assignments.size,
    roundCount: rounds.length,
  };
}

export const overrideEventSuccessRotations = onCall(
  appCheckCallableOptions,
  (request) => overrideEventSuccessRotationsHandler(request)
);

/**
 * Loads and authorizes the event-success guided rotation context.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} eventId Event id.
 * @param {string} uid Requesting user id.
 * @return {Promise<object>} Authorized event context.
 */
async function loadRotationEventContext(
  db: FirebaseFirestore.Firestore,
  eventId: string,
  uid?: string
): Promise<{
  event: EventDocument;
  plan: EventSuccessPlanDocument;
  rotationIntervalMinutes: number;
  questionnaireMode: QuestionnaireScoringMode;
  constraints: AssignmentConstraintConfig;
  rotationPolicy: AssignmentRotationPolicy;
}> {
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

  if (uid !== undefined) {
    const organizerSnap = await eventOrganizerRef(db, event).get();
    const organizer = requireEventOrganizer(organizerSnap, event);
    if (!isEventOrganizerManager(organizer, event, uid)) {
      throw new HttpsError("permission-denied",
        "Only an organizer manager can manage event rotations.");
    }
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
  if (!moduleSelected(plan.selectedModuleIds, GUIDED_ROTATIONS_MODULE_ID)) {
    throw new HttpsError("failed-precondition",
      "Guided rotations are not enabled for this event.");
  }
  assertPairRotationTopology(plan);

  return {
    event,
    plan,
    rotationIntervalMinutes:
      resolveRotationIntervalMinutes(plan) ?? ROUND_LENGTH_MINUTES,
    questionnaireMode:
      moduleSelected(
        plan.selectedModuleIds,
        COMPATIBILITY_QUESTIONNAIRE_MODULE_ID
      ) && plan.compatibilityAffectsRanking === true ?
        "light" :
        "icebreaker",
    constraints: assignmentConstraintsForSpatialPlan(
      assignmentConstraintsForStructureConfig(plan.structureConfig),
      plan
    ),
    rotationPolicy: rotationPolicyForStructureConfig(plan.structureConfig),
  };
}

/**
 * Loads eligible, opt-in participants and current safety block edges.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} eventId Event id.
 * @param {boolean} compatibilityAffectsRanking Whether answers can rank pairs.
 * @return {Promise<object>} Eligible participants and blocked pair keys.
 */
async function loadEligibleRotationParticipants(
  db: FirebaseFirestore.Firestore,
  eventId: string,
  compatibilityAffectsRanking: boolean
): Promise<{
  participants: RotationParticipant[];
  blockedPairs: Set<string>;
}> {
  const [roster, optedOutUids] = await Promise.all([
    loadEventSuccessRoster(db, eventId),
    fetchGuidedRotationOptOutUids(db, eventId),
  ]);
  const activeEdges = roster
    .filter((participant) => !optedOutUids.has(participant.uid));
  const eligibleEdges = preferCheckedInParticipants(activeEdges);
  let participants = eligibleEdges.map((participant): RotationParticipant => ({
    uid: participant.uid,
    status: participant.status,
    gender: participant.gender,
    interestedInGenders: participant.interestedInGenders,
    arrivalGroup: participant.arrivalGroup,
    compatibilityAnswerIds: [],
    activityAttributes: activityAttributesForProfile(participant.profile),
  }));
  if (compatibilityAffectsRanking) {
    const answerIdsByUid = await fetchCompatibilityAnswerIdsByUid(db, eventId);
    participants = participants.map((participant) => ({
      ...participant,
      compatibilityAnswerIds: answerIdsByUid.get(participant.uid) ?? [],
    }));
  }
  const blockedPairs = await fetchBlockedPairs(db, participants);
  return {participants, blockedPairs};
}

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
 * Uses checked-in attendees when at least two are present.
 * @param {Array<object>} edges Active participation edges.
 * @return {Array<object>} Rotation input.
 */
function preferCheckedInParticipants<
  T extends {uid: string; status: ActiveStatus}
>(edges: T[]): T[] {
  const attended = edges.filter((edge) => edge.status === "attended");
  return attended.length >= 2 ? attended : edges;
}

/**
 * Loads attendee guided-rotation opt-outs for the event.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} eventId Event id.
 * @return {Promise<Set<string>>} Uids excluded from rotations.
 */
async function fetchGuidedRotationOptOutUids(
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
      preference.guidedRotationsOptedOut === true &&
      typeof preference.uid === "string" &&
      preference.uid.length > 0
    ) {
      optedOut.add(preference.uid);
    }
  }
  return optedOut;
}

/**
 * Loads attendee questionnaire answers for optional ranking boosts.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} eventId Event id.
 * @return {Promise<Map<string, string[]>>} Answer ids keyed by uid.
 */
async function fetchCompatibilityAnswerIdsByUid(
  db: FirebaseFirestore.Firestore,
  eventId: string
): Promise<Map<string, string[]>> {
  const snap = await db
    .collection("eventSuccessCompatibilityResponses")
    .where("eventId", "==", eventId)
    .get();
  const answerIdsByUid = new Map<string, string[]>();
  for (const doc of snap.docs) {
    const response = doc.data() as EventSuccessCompatibilityResponseDocument;
    if (
      typeof response.uid !== "string" ||
      response.uid.length === 0 ||
      !Array.isArray(response.answerIds)
    ) {
      continue;
    }
    answerIdsByUid.set(
      response.uid,
      response.answerIds.filter((answerId) => typeof answerId === "string")
    );
  }
  return answerIdsByUid;
}

/**
 * Loads block edges among the rotation participants in either direction.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {RotationParticipant[]} participants Rotation participants.
 * @return {Promise<Set<string>>} Undirected blocked pair keys.
 */
async function fetchBlockedPairs(
  db: FirebaseFirestore.Firestore,
  participants: RotationParticipant[]
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
      pairs.add(pairKey(block.blockerUserId, block.blockedUserId));
    }
  }
  return pairs;
}

/**
 * Builds scored, non-repeating rotation rounds.
 * @param {object} params Rotation inputs.
 * @param {Array<object>} params.participants Participants.
 * @param {object} params.blockedPairs Blocked pair keys.
 * @param {number} params.eventStartMillis Event start time in millis.
 * @param {number} params.eventEndMillis Event end time in millis.
 * @param {number} params.rotationIntervalMinutes Round length in minutes.
 * @param {QuestionnaireScoringMode} params.questionnaireMode Answer weighting.
 * @param {EventSuccessAssignmentAlgorithm} params.assignmentAlgorithm Format.
 * @param {EventSuccessCompatibilityPolicy} params.compatibilityPolicy Scoring.
 * @return {RotationRound[]} Pairings by round.
 */
function buildRotationRounds(params: {
  participants: RotationParticipant[];
  blockedPairs: Set<string>;
  eventStartMillis: number;
  eventEndMillis: number;
  rotationIntervalMinutes: number;
  questionnaireMode: QuestionnaireScoringMode;
  assignmentAlgorithm: EventSuccessAssignmentAlgorithm;
  compatibilityPolicy: EventSuccessCompatibilityPolicy;
  matchingObjective: EventSuccessMatchingObjective;
  constraints?: AssignmentConstraintConfig;
  rotationPolicy?: AssignmentRotationPolicy;
}): RotationRound[] {
  if (params.participants.length < 2) return [];
  const requestedRounds = rotationRoundCountForDuration({
    eventStartMillis: params.eventStartMillis,
    eventEndMillis: params.eventEndMillis,
    rotationIntervalMinutes: params.rotationIntervalMinutes,
  });
  const maxRounds = params.participants.length % 2 === 0 ?
    params.participants.length - 1 :
    params.participants.length;
  const roundCount = params.rotationPolicy?.repeatStrategy ===
    "allowWhenExhausted" ?
    requestedRounds :
    Math.min(requestedRounds, maxRounds);
  return runAssignmentEngine({
    participants: params.participants,
    blockedPairs: params.blockedPairs,
    topology: {
      unitKind: "pairs",
      unitSize: 2,
      groupCount: Math.max(1, Math.floor(params.participants.length / 2)),
      maxGroupSize: 2,
      rotationIntervalMinutes: params.rotationIntervalMinutes,
      rotationsEnabled: true,
    },
    assignmentAlgorithm: params.assignmentAlgorithm,
    compatibilityPolicy: params.compatibilityPolicy,
    matchingObjective: params.matchingObjective,
    questionnaireMode: params.questionnaireMode,
    rotationRoundCount: roundCount,
    allowOrientationFallback: true,
    constraints: params.constraints,
    rotationPolicy: params.rotationPolicy,
  }).rotationRounds.map((round) => ({
    roundIndex: round.roundIndex,
    pairs: round.pairs.map(toRotationPair),
  }));
}

/**
 * Builds host-authored rotation rounds after safety and eligibility checks.
 * @param {object} params Override inputs.
 * @param {Array<object>} params.inputRounds Host-authored rounds.
 * @param {RotationParticipant[]} params.participants Eligible participants.
 * @param {Set<string>} params.blockedPairs Blocked pair keys.
 * @param {number} params.eventStartMillis Event start time in millis.
 * @param {number} params.eventEndMillis Event end time in millis.
 * @param {number} params.rotationIntervalMinutes Round length in minutes.
 * @return {RotationRound[]} Validated host-authored rounds.
 */
function buildOverrideRounds(params: {
  inputRounds: OverrideEventSuccessRotationsCallablePayload["rounds"];
  participants: RotationParticipant[];
  blockedPairs: Set<string>;
  eventStartMillis: number;
  eventEndMillis: number;
  rotationIntervalMinutes: number;
}): RotationRound[] {
  const maxRoundCount = rotationRoundCountForDuration({
    eventStartMillis: params.eventStartMillis,
    eventEndMillis: params.eventEndMillis,
    rotationIntervalMinutes: params.rotationIntervalMinutes,
  });
  const participantsByUid = new Map(
    params.participants.map((participant) => [participant.uid, participant])
  );
  const seenRoundIndexes = new Set<number>();
  const rounds: RotationRound[] = [];

  for (const inputRound of params.inputRounds) {
    if (seenRoundIndexes.has(inputRound.roundIndex)) {
      throw new HttpsError("invalid-argument",
        "Each rotation round can be overridden only once.");
    }
    seenRoundIndexes.add(inputRound.roundIndex);
    if (inputRound.roundIndex >= maxRoundCount) {
      throw new HttpsError("invalid-argument",
        "Rotation round is outside the event duration.");
    }

    const usedInRound = new Set<string>();
    const pairs: RotationPair[] = [];
    for (const pairing of inputRound.pairings) {
      if (pairing.uidA === pairing.uidB) {
        throw new HttpsError("invalid-argument",
          "A participant cannot be paired with themselves.");
      }
      const participantA = participantsByUid.get(pairing.uidA);
      const participantB = participantsByUid.get(pairing.uidB);
      if (participantA === undefined || participantB === undefined) {
        throw new HttpsError("failed-precondition",
          "One or more attendees are no longer eligible for rotations.");
      }
      if (usedInRound.has(pairing.uidA) || usedInRound.has(pairing.uidB)) {
        throw new HttpsError("invalid-argument",
          "A participant can have only one partner per round.");
      }
      if (params.blockedPairs.has(pairKey(pairing.uidA, pairing.uidB))) {
        throw new HttpsError("failed-precondition",
          "Blocked attendees cannot be paired.");
      }
      usedInRound.add(pairing.uidA);
      usedInRound.add(pairing.uidB);
      pairs.push({
        a: participantA,
        b: participantB,
        score: 0,
        compatibility: "host_override",
      });
    }
    if (pairs.length > 0) {
      rounds.push({roundIndex: inputRound.roundIndex, pairs});
    }
  }

  if (rounds.length === 0) {
    throw new HttpsError("invalid-argument",
      "Add at least one rotation pair.");
  }

  return rounds.sort((a, b) => a.roundIndex - b.roundIndex);
}

/**
 * Converts optimizer pair metadata into persisted rotation pair shape.
 * @param {OptimizedPair<RotationParticipant>} pair Optimizer pair.
 * @return {RotationPair} Scored pair.
 */
function toRotationPair(
  pair: OptimizedPair<RotationParticipant>
): RotationPair {
  return {
    a: pair.a,
    b: pair.b,
    score: pair.score,
    compatibility: pair.compatibility,
  };
}

/**
 * Builds assignment documents from rotation rounds.
 * @param {object} params Assignment inputs.
 * @param {string} params.eventId Event id.
 * @param {string} params.clubId Club id.
 * @param {Array<object>} params.participants Participants.
 * @param {Array<object>} params.rounds Rotation rounds.
 * @param {number} params.eventStartMillis Event start time in millis.
 * @param {number} params.rotationIntervalMinutes Round length in minutes.
 * @param {string} params.source Assignment source.
 * @param {FirebaseFirestore.FieldValue} params.now Server timestamp.
 * @return {Map<string, GeneratedAssignment>} Assignment docs by id.
 */
function buildAssignments(params: {
  eventId: string;
  clubId: string;
  organizerId?: string;
  participants: RotationParticipant[];
  rounds: RotationRound[];
  eventStartMillis: number;
  rotationIntervalMinutes: number;
  source: string;
  now: FirebaseFirestore.FieldValue;
}): Map<string, GeneratedAssignment> {
  const slotsByUid = new Map<string, GeneratedRotationSlot[]>(
    params.participants.map((participant) => [participant.uid, []])
  );
  const sitOutSlotsByUid = new Map<string, GeneratedSitOutSlot[]>(
    params.participants.map((participant) => [participant.uid, []])
  );
  const seenPeersByUid = new Map<string, Set<string>>(
    params.participants.map((participant) => [participant.uid, new Set()])
  );
  params.rounds.forEach((round) => {
    const startsAt = admin.firestore.Timestamp.fromMillis(
      params.eventStartMillis +
        round.roundIndex * params.rotationIntervalMinutes * 60000
    );
    const endsAt = admin.firestore.Timestamp.fromMillis(
      startsAt.toMillis() + params.rotationIntervalMinutes * 60000
    );
    const usedUids = new Set<string>();
    for (const [unitIndex, pair] of round.pairs.entries()) {
      const label = `Round ${round.roundIndex + 1}`;
      const repeatedForA =
        seenPeersByUid.get(pair.a.uid)?.has(pair.b.uid) === true;
      const repeatedForB =
        seenPeersByUid.get(pair.b.uid)?.has(pair.a.uid) === true;
      const slotA = {
        slotId: `round-${round.roundIndex}-pair-${unitIndex}`,
        roundIndex: round.roundIndex,
        label,
        startsAt,
        endsAt,
        peerUid: pair.b.uid,
        unitKind: "pairs" as const,
        unitIndex,
        peerCount: 1,
        compatibility: pair.compatibility,
        whySummary: rotationWhySummary({
          compatibility: pair.compatibility,
          peerLabel: "partner",
          source: params.source,
          repeatedPeer: repeatedForA,
        }),
        whyCodes: rotationWhyCodes({
          compatibility: pair.compatibility,
          source: params.source,
          repeatedPeer: repeatedForA,
        }),
      };
      const slotB = {
        slotId: `round-${round.roundIndex}-pair-${unitIndex}`,
        roundIndex: round.roundIndex,
        label,
        startsAt,
        endsAt,
        peerUid: pair.a.uid,
        unitKind: "pairs" as const,
        unitIndex,
        peerCount: 1,
        compatibility: pair.compatibility,
        whySummary: rotationWhySummary({
          compatibility: pair.compatibility,
          peerLabel: "partner",
          source: params.source,
          repeatedPeer: repeatedForB,
        }),
        whyCodes: rotationWhyCodes({
          compatibility: pair.compatibility,
          source: params.source,
          repeatedPeer: repeatedForB,
        }),
      };
      slotsByUid.get(pair.a.uid)?.push(slotA);
      slotsByUid.get(pair.b.uid)?.push(slotB);
      seenPeersByUid.get(pair.a.uid)?.add(pair.b.uid);
      seenPeersByUid.get(pair.b.uid)?.add(pair.a.uid);
      usedUids.add(pair.a.uid);
      usedUids.add(pair.b.uid);
    }
    for (const participant of params.participants) {
      if (usedUids.has(participant.uid)) continue;
      sitOutSlotsByUid.get(participant.uid)?.push({
        roundIndex: round.roundIndex,
        label: `Round ${round.roundIndex + 1}`,
        startsAt,
        endsAt,
        whySummary: "Planned break to keep rotation counts fair.",
        whyCodes: ["sit_out"],
      });
    }
  });

  const assignments = new Map<string, GeneratedAssignment>();
  for (const [uid, slots] of slotsByUid.entries()) {
    const sitOutSlots = sitOutSlotsByUid.get(uid) ?? [];
    if (slots.length === 0 && sitOutSlots.length === 0) continue;
    const peerUids = [...new Set(slots.map((slot) => slot.peerUid))].sort();
    const fairness = rotationFairnessSummary(slots, sitOutSlots);
    const breakLabel = sitOutSlots.length === 0 ?
      "" :
      ` · ${sitOutSlots.length} ` +
        `break${sitOutSlots.length === 1 ? "" : "s"}`;
    const docId = assignmentId(params.eventId, uid);
    assignments.set(docId, {
      eventId: params.eventId,
      clubId: params.clubId,
      organizerId: params.organizerId ?? params.clubId,
      uid,
      moduleId: GUIDED_ROTATIONS_MODULE_ID,
      label: "Guided rotations",
      displayTitle: `${slots.length} guided rotations`,
      displaySubtitle: `${params.rotationIntervalMinutes} min each · ` +
        `${peerUids.length} ${peerUids.length === 1 ? "person" : "people"}` +
        breakLabel,
      peerUids,
      unitKind: "pairs",
      unitLabel: "Guided rotations",
      whySummary: `${slots.length} partner rounds with ` +
        `${peerUids.length} unique ${peerUids.length === 1 ?
          "person" :
          "people"}.`,
      whyCodes: uniqueWhyCodes([
        ...slots.flatMap((slot) => slot.whyCodes ?? []),
        ...sitOutSlots.flatMap((slot) => slot.whyCodes),
      ]),
      rotationFairness: fairness,
      rotationSlots: slots,
      ...(sitOutSlots.length > 0 ? {sitOutSlots} : {}),
      source: params.source,
      createdAt: params.now,
      updatedAt: params.now,
    });
  }
  return assignments;
}

/**
 * Builds a short reason summary for a rotation slot.
 * @param {object} params Slot metadata inputs.
 * @return {string} Human-readable slot reason.
 */
function rotationWhySummary(params: {
  compatibility: RotationPair["compatibility"];
  peerLabel: string;
  source: string;
  repeatedPeer: boolean;
}): string {
  if (params.source === "host_override_v1") {
    return `Host override selected this ${params.peerLabel}.`;
  }
  const freshness = params.repeatedPeer ? "repeat" : "new";
  switch (params.compatibility) {
  case "mutual_interest":
    return `Matched with a ${freshness} ${params.peerLabel}.`;
  case "questionnaire_match":
    return `Matched with a ${freshness} ${params.peerLabel} by answers.`;
  case "one_way_interest":
    return `Fallback ${params.peerLabel} with one-way interest.`;
  case "social":
  default:
    return `Social fallback with a ${freshness} ${params.peerLabel}.`;
  }
}

/**
 * Builds machine-safe reason codes for a rotation slot.
 * @param {object} params Slot metadata inputs.
 * @return {AssignmentWhyCode[]} Stable reason codes.
 */
function rotationWhyCodes(params: {
  compatibility: RotationPair["compatibility"];
  source: string;
  repeatedPeer: boolean;
}): AssignmentWhyCode[] {
  const codes: AssignmentWhyCode[] = [
    "pair_slot",
    params.repeatedPeer ? "repeat_peer" : "fresh_peer",
  ];
  if (params.source === "host_override_v1") {
    codes.push("host_override");
  } else {
    switch (params.compatibility) {
    case "mutual_interest":
      codes.push("mutual_interest");
      break;
    case "questionnaire_match":
      codes.push("questionnaire_match");
      break;
    case "one_way_interest":
      codes.push("one_way_interest");
      break;
    case "social":
    default:
      codes.push("social_fallback");
      break;
    }
  }
  return uniqueWhyCodes(codes);
}

/**
 * Builds fairness metadata from rotation slots and sit-outs.
 * @param {GeneratedRotationSlot[]} slots Assigned rotation slots.
 * @param {GeneratedSitOutSlot[]} sitOutSlots Sit-out slots.
 * @return {RotationFairnessSummary} Fairness counts.
 */
function rotationFairnessSummary(
  slots: GeneratedRotationSlot[],
  sitOutSlots: GeneratedSitOutSlot[]
): RotationFairnessSummary {
  const peerCounts = new Map<string, number>();
  for (const slot of slots) {
    peerCounts.set(slot.peerUid, (peerCounts.get(slot.peerUid) ?? 0) + 1);
  }
  return {
    assignedRoundCount: slots.length,
    sitOutRoundCount: sitOutSlots.length,
    uniquePeerCount: peerCounts.size,
    repeatPeerCount: [...peerCounts.values()].reduce(
      (sum, count) => sum + Math.max(0, count - 1),
      0
    ),
  };
}

/**
 * Deduplicates reason codes while preserving first-seen order.
 * @param {AssignmentWhyCode[]} codes Raw reason codes.
 * @return {AssignmentWhyCode[]} Unique codes.
 */
function uniqueWhyCodes(codes: AssignmentWhyCode[]): AssignmentWhyCode[] {
  return [...new Set(codes)];
}

/**
 * Replaces stale guided rotation assignment docs for this event.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} eventId Event id.
 * @param {Map<string, GeneratedAssignment>} assignments New assignments.
 */
async function writeAssignmentDrafts(params: {
  db: FirebaseFirestore.Firestore;
  eventId: string;
  expectedRevision: number;
  expectedPublishedRoundIndex: number;
  targetRoundIndex: number;
  assignments: Map<string, GeneratedAssignment>;
  now: FirebaseFirestore.FieldValue;
}): Promise<{revision: number; assignmentRevision: number}> {
  const planRef = params.db.collection("eventSuccessPlans").doc(params.eventId);
  const draftQuery = params.db.collection("eventSuccessAssignmentDrafts")
    .where("eventId", "==", params.eventId)
    .where("moduleId", "==", GUIDED_ROTATIONS_MODULE_ID);
  return params.db.runTransaction(async (transaction) => {
    const [planSnap, existingSnap] = await Promise.all([
      transaction.get(planRef),
      transaction.get(draftQuery),
    ]);
    if (!planSnap.exists) {
      throw new HttpsError("failed-precondition",
        "Event-success setup has not been saved.");
    }
    const plan = planSnap.data() as EventSuccessPlanDocument;
    const currentRevision = nonNegativeInteger(plan.liveControlRevision);
    const publishedRoundIndex = integerOr(
      plan.publishedRotationRoundIndex,
      -1
    );
    if (
      currentRevision !== params.expectedRevision ||
      publishedRoundIndex !== params.expectedPublishedRoundIndex
    ) {
      throw staleLiveControlError();
    }
    const revision = nextLiveControlRevision(currentRevision);
    const assignmentRevision = nextLiveControlRevision(
      nonNegativeInteger(plan.assignmentDraftRevision)
    );
    for (const doc of existingSnap.docs) {
      transaction.delete(doc.ref);
    }
    for (const [docId, assignment] of params.assignments.entries()) {
      transaction.set(
        params.db.collection("eventSuccessAssignmentDrafts").doc(docId),
        {
          eventId: params.eventId,
          clubId: assignment.clubId,
          organizerId: assignment.organizerId,
          uid: assignment.uid,
          moduleId: GUIDED_ROTATIONS_MODULE_ID,
          roundIndex: params.targetRoundIndex,
          baseAssignmentRevision: assignmentRevision,
          assignment,
          createdAt: params.now,
          updatedAt: params.now,
        }
      );
    }
    transaction.update(planRef, {
      ...persistentSpatialPlanFields(plan),
      liveControlRevision: revision,
      assignmentDraftRevision: assignmentRevision,
      updatedAt: params.now,
    });
    return {revision, assignmentRevision};
  });
}

/**
 * Returns the deterministic guided-rotation assignment document id.
 * @param {string} eventId Event id.
 * @param {string} uid User id.
 * @return {string} Assignment document id.
 */
function assignmentId(eventId: string, uid: string): string {
  return `${eventId}_${GUIDED_ROTATIONS_MODULE_ID}_${uid}`;
}

/**
 * Builds a deterministic undirected pair key.
 * @param {string} uidA First uid.
 * @param {string} uidB Second uid.
 * @return {string} Pair key.
 */
function pairKey(uidA: string, uidB: string): string {
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

function staleLiveControlError(): HttpsError {
  return new HttpsError("aborted",
    "The live event guide changed on another device. Refresh and retry.");
}

function nextLiveControlRevision(current: number): number {
  if (current >= 2147483647) {
    throw new HttpsError("resource-exhausted",
      "The live-control revision limit has been reached.");
  }
  return current + 1;
}

function nonNegativeInteger(value: unknown): number {
  return Number.isInteger(value) && (value as number) >= 0 ?
    value as number : 0;
}

function integerOr(value: unknown, fallback: number): number {
  return Number.isInteger(value) ? value as number : fallback;
}
