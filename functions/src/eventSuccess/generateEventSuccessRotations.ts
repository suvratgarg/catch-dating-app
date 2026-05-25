import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {EventDoc, ClubDoc, BlockDoc, UserProfileDoc} from
  "../shared/generated/firestoreAdminTypes";
import {requireAuth} from "../shared/auth";
import {EventIdCallablePayload} from
  "../shared/generated/eventIdCallablePayload";
import {OverrideEventSuccessRotationsCallablePayload} from
  "../shared/generated/overrideEventSuccessRotationsCallablePayload";
import {
  validateEventIdCallablePayload,
  validateOverrideEventSuccessRotationsCallablePayload,
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
  OptimizedPair,
  optimizeEventSuccessAssignments,
} from "./assignmentOptimizer";
import {
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
  eventSuccessPrimitivesFor,
} from "./formatPrimitives";

const GUIDED_ROTATIONS_MODULE_ID = "guided_rotations";
const COMPATIBILITY_QUESTIONNAIRE_MODULE_ID = "compatibility_questionnaire";
const ROUND_LENGTH_MINUTES = 15;
const MAX_IN_FILTER_VALUES = 30;
const ACTIVE_STATUSES = ["attended", "signedUp"] as const;

interface EventSuccessRotationsDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

interface EventSuccessPlanDoc {
  eventId?: string;
  clubId?: string;
  selectedModuleIds?: unknown;
  compatibilityAffectsRanking?: unknown;
  structureConfig?: {
    unitKind?: unknown;
    unitSize?: unknown;
    unitCount?: unknown;
    rotationIntervalMinutes?: unknown;
  };
}

interface EventParticipationDoc {
  uid?: string;
  status?: string;
}

interface EventSuccessPreferenceDoc {
  uid?: string;
  guidedRotationsOptedOut?: boolean;
}

interface EventSuccessCompatibilityResponseDoc {
  uid?: string;
  eventId?: string;
  answerIds?: unknown;
}

interface RotationParticipant extends AssignmentParticipant {
  uid: string;
  status: typeof ACTIVE_STATUSES[number];
  gender: string;
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

interface GeneratedRotationSlot {
  roundIndex: number;
  label: string;
  startsAt: FirebaseFirestore.Timestamp;
  endsAt: FirebaseFirestore.Timestamp;
  peerUid: string;
  compatibility: RotationPair["compatibility"];
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
  rotationSlots: GeneratedRotationSlot[];
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
  const {eventId} = validateCallableWithAjv<EventIdCallablePayload>(
    request,
    validateEventIdCallablePayload,
    normalizeEventIdPayload
  );

  const db = deps.firestore();
  await deps.checkRateLimit?.(db, uid, "generateEventSuccessRotations");

  const {event, rotationIntervalMinutes, questionnaireMode} =
    await loadRotationEventContext(db, eventId, uid);
  const {participants, blockedPairs} =
    await loadEligibleRotationParticipants(
      db,
      eventId,
      questionnaireMode !== "icebreaker"
    );
  const primitives = eventSuccessPrimitivesFor(event.eventFormat);
  const rounds = buildRotationRounds({
    participants,
    blockedPairs,
    eventStartMillis: event.startTime.toMillis(),
    eventEndMillis: event.endTime.toMillis(),
    rotationIntervalMinutes,
    questionnaireMode,
    assignmentAlgorithm: primitives.assignmentAlgorithm,
    compatibilityPolicy: primitives.compatibilityPolicy,
  });
  const assignments = buildAssignments({
    eventId,
    clubId: event.clubId,
    participants,
    rounds,
    eventStartMillis: event.startTime.toMillis(),
    rotationIntervalMinutes,
    source: "server_v1",
    now: deps.serverTimestamp(),
  });
  await writeAssignments(db, eventId, assignments);

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

  const {event, rotationIntervalMinutes} =
    await loadRotationEventContext(db, payload.eventId, uid);
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
    participants,
    rounds,
    eventStartMillis: event.startTime.toMillis(),
    rotationIntervalMinutes,
    source: "host_override_v1",
    now: deps.serverTimestamp(),
  });
  await writeAssignments(db, payload.eventId, assignments);

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
  uid: string
): Promise<{
  event: EventDoc;
  rotationIntervalMinutes: number;
  questionnaireMode: QuestionnaireScoringMode;
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

  const event = requireDoc<EventDoc>(eventSnap, "EventDoc");
  if (event.status === "cancelled") {
    throw new HttpsError("failed-precondition",
      "This event has been cancelled.");
  }

  const clubSnap = await db.collection("clubs").doc(event.clubId).get();
  if (!clubSnap.exists) {
    throw new HttpsError("not-found", "Club not found.");
  }
  const club = requireDoc<ClubDoc>(clubSnap, "ClubDoc");
  if (!isClubHost(club, uid)) {
    throw new HttpsError("permission-denied",
      "Only the club host can manage event rotations.");
  }

  const plan = requireDoc<EventSuccessPlanDoc>(
    planSnap,
    "EventSuccessPlanDoc"
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
    rotationIntervalMinutes:
      resolveRotationIntervalMinutes(plan) ?? ROUND_LENGTH_MINUTES,
    questionnaireMode:
      moduleSelected(
        plan.selectedModuleIds,
        COMPATIBILITY_QUESTIONNAIRE_MODULE_ID
      ) && plan.compatibilityAffectsRanking === true ?
        "light" :
        "icebreaker",
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
  const [participationsSnap, optedOutUids] = await Promise.all([
    db
      .collection("eventParticipations")
      .where("eventId", "==", eventId)
      .where("status", "in", [...ACTIVE_STATUSES])
      .get(),
    fetchGuidedRotationOptOutUids(db, eventId),
  ]);
  const activeEdges = participationsSnap.docs
    .map((doc) => doc.data() as EventParticipationDoc)
    .map(toActiveParticipant)
    .filter((participant): participant is {
      uid: string;
      status: typeof ACTIVE_STATUSES[number];
    } => participant !== null)
    .filter((participant) => !optedOutUids.has(participant.uid));
  const eligibleEdges = preferCheckedInParticipants(activeEdges);
  let participants = await hydrateParticipants(db, eligibleEdges);
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
 * Converts a participation edge into an active rotation candidate.
 * @param {EventParticipationDoc} data Participation document data.
 * @return {?object} Active candidate or null.
 */
function toActiveParticipant(
  data: EventParticipationDoc
): {uid: string; status: typeof ACTIVE_STATUSES[number]} | null {
  if (typeof data.uid !== "string" || data.uid.length === 0) return null;
  if (data.status !== "attended" && data.status !== "signedUp") return null;
  return {uid: data.uid, status: data.status};
}

/**
 * Uses checked-in attendees when at least two are present.
 * @param {Array<object>} edges Active participation edges.
 * @return {Array<object>} Rotation input.
 */
function preferCheckedInParticipants(
  edges: Array<{uid: string; status: typeof ACTIVE_STATUSES[number]}>
): Array<{uid: string; status: typeof ACTIVE_STATUSES[number]}> {
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
    const preference = doc.data() as EventSuccessPreferenceDoc;
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
 * Loads user profile preference data for active participants.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {Array<object>} edges Participation edges.
 * @return {Promise<Array<object>>} Hydrated participants.
 */
async function hydrateParticipants(
  db: FirebaseFirestore.Firestore,
  edges: Array<{uid: string; status: typeof ACTIVE_STATUSES[number]}>
): Promise<RotationParticipant[]> {
  const participants: RotationParticipant[] = [];
  const sortedEdges = [...edges].sort((a, b) => a.uid.localeCompare(b.uid));
  const snaps = await Promise.all(
    sortedEdges.map((edge) => db.collection("users").doc(edge.uid).get())
  );
  snaps.forEach((snap, index) => {
    if (!snap.exists) return;
    const profile = snap.data() as Partial<UserProfileDoc>;
    if (
      typeof profile.gender !== "string" ||
      !Array.isArray(profile.interestedInGenders)
    ) {
      return;
    }
    participants.push({
      uid: sortedEdges[index].uid,
      status: sortedEdges[index].status,
      gender: profile.gender,
      interestedInGenders: profile.interestedInGenders.filter(
        (gender) => typeof gender === "string"
      ),
      compatibilityAnswerIds: [],
    });
  });
  return participants;
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
    const response = doc.data() as EventSuccessCompatibilityResponseDoc;
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
      const block = doc.data() as Partial<BlockDoc>;
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
  const roundCount = Math.min(requestedRounds, maxRounds);
  return optimizeEventSuccessAssignments({
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
    questionnaireMode: params.questionnaireMode,
    rotationRoundCount: roundCount,
    allowOrientationFallback: true,
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
  params.rounds.forEach((round) => {
    const startsAt = admin.firestore.Timestamp.fromMillis(
      params.eventStartMillis +
        round.roundIndex * params.rotationIntervalMinutes * 60000
    );
    const endsAt = admin.firestore.Timestamp.fromMillis(
      startsAt.toMillis() + params.rotationIntervalMinutes * 60000
    );
    for (const pair of round.pairs) {
      const label = `Round ${round.roundIndex + 1}`;
      const slotA = {
        roundIndex: round.roundIndex,
        label,
        startsAt,
        endsAt,
        peerUid: pair.b.uid,
        compatibility: pair.compatibility,
      };
      const slotB = {
        roundIndex: round.roundIndex,
        label,
        startsAt,
        endsAt,
        peerUid: pair.a.uid,
        compatibility: pair.compatibility,
      };
      slotsByUid.get(pair.a.uid)?.push(slotA);
      slotsByUid.get(pair.b.uid)?.push(slotB);
    }
  });

  const assignments = new Map<string, GeneratedAssignment>();
  for (const [uid, slots] of slotsByUid.entries()) {
    if (slots.length === 0) continue;
    const peerUids = [...new Set(slots.map((slot) => slot.peerUid))].sort();
    const docId = assignmentId(params.eventId, uid);
    assignments.set(docId, {
      eventId: params.eventId,
      clubId: params.clubId,
      uid,
      moduleId: GUIDED_ROTATIONS_MODULE_ID,
      label: "Guided rotations",
      displayTitle: `${slots.length} guided rotations`,
      displaySubtitle: `${params.rotationIntervalMinutes} min each · ` +
        `${peerUids.length} ${peerUids.length === 1 ? "person" : "people"}`,
      peerUids,
      rotationSlots: slots,
      source: params.source,
      createdAt: params.now,
      updatedAt: params.now,
    });
  }
  return assignments;
}

/**
 * Replaces stale guided rotation assignment docs for this event.
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
    .where("moduleId", "==", GUIDED_ROTATIONS_MODULE_ID)
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
