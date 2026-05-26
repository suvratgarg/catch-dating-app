import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {
  EventDocument,
  EventParticipationDocument,
  Gender,
  PublicProfileDocument,
  UserProfileDocument,
} from "../shared/generated/firestoreAdminTypes";
import {requireAuth} from "../shared/auth";
import {StartEventSuccessFirstHelloMissionCallablePayload} from
  "../shared/generated/startEventSuccessFirstHelloMissionCallablePayload";
import {CompleteEventSuccessFirstHelloMissionCallablePayload} from
  "../shared/generated/completeEventSuccessFirstHelloMissionCallablePayload";
import {
  validateStartEventSuccessFirstHelloMissionCallablePayload,
  validateCompleteEventSuccessFirstHelloMissionCallablePayload,
} from "../shared/generated/schemaValidators";
import {validateCallableWithAjv, requireDoc} from "../shared/validation";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {normalizeEventIdPayload} from "../events/eventPayloadNormalization";
import {cohortIdForUser, cohortIds} from "../events/eventPolicy";
import {blockDocId} from "../safety/blocking";
import {
  eventParticipationId,
  eventParticipationPatch,
} from "../shared/relationshipDocuments";
import {
  EVENT_FIRST_HELLO_MAX_DISTANCE_METERS,
  EVENT_SELF_CHECK_IN_WINDOW_AFTER_MINUTES,
  EVENT_SELF_CHECK_IN_WINDOW_BEFORE_MINUTES,
} from "../shared/businessRules";
import {buildAttendanceSignalFact} from "../marketplace/signalBuilders";
import {
  ParticipantSignalFactInput,
  recordParticipantSignalFactsBestEffort,
} from "../marketplace/participantSignals";

const FIRST_HELLO_MODULE_ID = "first_hello_check_in";
const EARTH_RADIUS_M = 6_371_000;

interface FirstHelloDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  nowMillis: () => number;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
  recordSignalFacts?: (
    db: FirebaseFirestore.Firestore,
    facts: ParticipantSignalFactInput[]
  ) => Promise<void>;
}

interface EventSuccessPlanDocument {
  eventId?: string;
  clubId?: string;
  selectedModuleIds?: unknown;
}

interface FirstHelloAnswerOption {
  id: string;
  label: string;
}

interface FirstHelloMissionDocument {
  eventId: string;
  clubId: string;
  observerUid: string;
  targetUid: string;
  targetDisplayName: string;
  targetContext: string;
  question: string;
  answerOptions: FirstHelloAnswerOption[];
  status: "active" | "completed" | "skipped";
  selectedAnswerId?: string;
  createdAt?: unknown;
  updatedAt?: unknown;
  completedAt?: unknown;
}

type FirstHelloCandidate = EventParticipationDocument & {
  uid: string;
  profile: PublicProfileDocument;
};

const defaultDeps: FirstHelloDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  nowMillis: () => Date.now(),
  checkRateLimit: defaultCheckRateLimit,
  recordSignalFacts: recordParticipantSignalFactsBestEffort,
};

const firstHelloAnswerOptions: FirstHelloAnswerOption[] = [
  {id: "people", label: "The people"},
  {id: "activity", label: "The activity"},
  {id: "venue", label: "The venue"},
  {id: "friend", label: "A friend"},
];

/**
 * Starts a server-owned First Hello arrival mission for the caller.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {FirstHelloDeps} deps Injectable dependencies for tests.
 * @return {Promise<object>} Mission id and optional attended flag.
 */
export async function startEventSuccessFirstHelloMissionHandler(
  request: CallableRequest<unknown>,
  deps: FirstHelloDeps = defaultDeps
): Promise<{missionId: string; attended?: boolean}> {
  const observerUid = requireAuth(request);
  const data = validateCallableWithAjv<
    StartEventSuccessFirstHelloMissionCallablePayload
  >(
    request,
    validateStartEventSuccessFirstHelloMissionCallablePayload,
    normalizeFirstHelloPayload
  );

  const db = deps.firestore();
  await deps.checkRateLimit?.(
    db,
    observerUid,
    "startEventSuccessFirstHelloMission"
  );

  const eventRef = db.collection("events").doc(data.eventId);
  const planRef = db.collection("eventSuccessPlans").doc(data.eventId);
  const participationRef = db
    .collection("eventParticipations")
    .doc(eventParticipationId(data.eventId, observerUid));
  const viewerRef = db.collection("users").doc(observerUid);
  const missionRef = db
    .collection("eventSuccessArrivalMissions")
    .doc(firstHelloMissionId(data.eventId, observerUid));

  const [
    eventSnap,
    planSnap,
    participationSnap,
    viewerSnap,
    existingMissionSnap,
  ] = await Promise.all([
    eventRef.get(),
    planRef.get(),
    participationRef.get(),
    viewerRef.get(),
    missionRef.get(),
  ]);

  const event = requireFirstHelloEvent(eventSnap);
  requireFirstHelloPlan(planSnap, data.eventId, event.clubId);
  const participation = requireSignedUpParticipant(
    participationSnap,
    observerUid
  );
  if (participation.status === "attended") {
    return {missionId: missionRef.id, attended: true};
  }
  requireCheckInWindow(event, deps.nowMillis());
  requireVenueProximity(event, data.latitude, data.longitude);

  if (!viewerSnap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "Complete your profile before starting First Hello."
    );
  }
  const viewer = requireDoc<UserProfileDocument>(
    viewerSnap,
    "UserProfileDocument"
  );

  if (existingMissionSnap.exists) {
    const existing = requireDoc<FirstHelloMissionDocument>(
      existingMissionSnap,
      "EventSuccessArrivalMissionDocument"
    );
    if (
      existing.eventId === data.eventId &&
      existing.observerUid === observerUid &&
      existing.status === "active"
    ) {
      return {missionId: missionRef.id};
    }
  }

  const target = await chooseFirstHelloTarget({
    db,
    eventId: data.eventId,
    observerUid,
    viewer,
  });
  const now = deps.serverTimestamp();
  const mission = buildFirstHelloMission({
    eventId: data.eventId,
    clubId: event.clubId,
    observerUid,
    target,
    now,
  });

  await missionRef.set(mission);

  logger.info(
    "[event-success] First Hello mission started",
    {eventId: data.eventId, observerUid, targetUid: target.uid}
  );

  return {missionId: missionRef.id};
}

/**
 * Completes the caller's First Hello mission and marks attendance.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {FirstHelloDeps} deps Injectable dependencies for tests.
 * @return {Promise<{attended: boolean}>} Result.
 */
export async function completeEventSuccessFirstHelloMissionHandler(
  request: CallableRequest<unknown>,
  deps: FirstHelloDeps = defaultDeps
): Promise<{attended: boolean}> {
  const observerUid = requireAuth(request);
  const data = validateCallableWithAjv<
    CompleteEventSuccessFirstHelloMissionCallablePayload
  >(
    request,
    validateCompleteEventSuccessFirstHelloMissionCallablePayload,
    normalizeFirstHelloPayload
  );

  const db = deps.firestore();
  await deps.checkRateLimit?.(
    db,
    observerUid,
    "completeEventSuccessFirstHelloMission"
  );

  const eventRef = db.collection("events").doc(data.eventId);
  const planRef = db.collection("eventSuccessPlans").doc(data.eventId);
  const participationRef = db
    .collection("eventParticipations")
    .doc(eventParticipationId(data.eventId, observerUid));
  const missionRef = db
    .collection("eventSuccessArrivalMissions")
    .doc(firstHelloMissionId(data.eventId, observerUid));

  let signalClubId: string | null = null;
  let wasMarkedAttended = false;

  await db.runTransaction(async (tx) => {
    const [
      eventSnap,
      planSnap,
      participationSnap,
      missionSnap,
    ] = await Promise.all([
      tx.get(eventRef),
      tx.get(planRef),
      tx.get(participationRef),
      tx.get(missionRef),
    ]);

    const event = requireFirstHelloEvent(eventSnap);
    requireFirstHelloPlan(planSnap, data.eventId, event.clubId);
    const participation = requireSignedUpParticipant(
      participationSnap,
      observerUid
    );
    signalClubId = event.clubId;

    if (participation.status === "attended") {
      wasMarkedAttended = false;
      return;
    }

    requireCheckInWindow(event, deps.nowMillis());
    requireVenueProximity(event, data.latitude, data.longitude);

    if (!missionSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "Start First Hello before completing check-in."
      );
    }
    const mission = requireDoc<FirstHelloMissionDocument>(
      missionSnap,
      "EventSuccessArrivalMissionDocument"
    );
    requireOwnedActiveMission(
      mission,
      data.eventId,
      observerUid,
      data.answerId
    );

    const targetParticipationRef = db
      .collection("eventParticipations")
      .doc(eventParticipationId(data.eventId, mission.targetUid));
    const observerBlocksTargetRef = db
      .collection("blocks")
      .doc(blockDocId(observerUid, mission.targetUid));
    const targetBlocksObserverRef = db
      .collection("blocks")
      .doc(blockDocId(mission.targetUid, observerUid));

    const [
      targetParticipationSnap,
      observerBlocksTargetSnap,
      targetBlocksObserverSnap,
    ] = await Promise.all([
      tx.get(targetParticipationRef),
      tx.get(observerBlocksTargetRef),
      tx.get(targetBlocksObserverRef),
    ]);

    requireAttendedTarget(targetParticipationSnap, mission.targetUid);
    if (observerBlocksTargetSnap.exists || targetBlocksObserverSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "First Hello is not available for this attendee."
      );
    }

    const now = deps.serverTimestamp();
    tx.update(eventRef, {
      checkedInCount: admin.firestore.FieldValue.increment(1),
    });
    tx.set(participationRef, eventParticipationPatch({
      exists: participationSnap.exists,
      eventId: data.eventId,
      clubId: event.clubId,
      uid: observerUid,
      status: "attended",
      genderAtSignup: participation.genderAtSignup ?? undefined,
      cohortAtSignup: participation.cohortAtSignup ?? undefined,
      paymentId: participation.paymentId ?? undefined,
    }), {merge: true});
    tx.set(missionRef, {
      ...mission,
      status: "completed",
      selectedAnswerId: data.answerId,
      completedAt: now,
      updatedAt: now,
    });
    wasMarkedAttended = true;
  });

  if (wasMarkedAttended && signalClubId != null) {
    await deps.recordSignalFacts?.(db, [
      buildAttendanceSignalFact({
        eventId: data.eventId,
        clubId: signalClubId,
        uid: observerUid,
        attended: true,
        sourceId: `first_hello_${data.eventId}_${observerUid}`,
      }),
    ]);
  }

  logger.info(
    "[event-success] First Hello mission completed",
    {eventId: data.eventId, observerUid, wasMarkedAttended}
  );

  return {attended: true};
}

export const startEventSuccessFirstHelloMission = onCall(
  appCheckCallableOptions,
  (request) => startEventSuccessFirstHelloMissionHandler(request)
);

export const completeEventSuccessFirstHelloMission = onCall(
  appCheckCallableOptions,
  (request) => completeEventSuccessFirstHelloMissionHandler(request)
);

/**
 * Picks an attended, compatible, non-blocked First Hello target.
 * @param {object} params Target selection inputs.
 * @param {FirebaseFirestore.Firestore} params.db Firestore instance.
 * @param {string} params.eventId Event id.
 * @param {string} params.observerUid Caller user id.
 * @param {UserProfileDocument} params.viewer Caller profile.
 * @return {Promise<FirstHelloCandidate>} Selected target.
 */
async function chooseFirstHelloTarget(params: {
  db: FirebaseFirestore.Firestore;
  eventId: string;
  observerUid: string;
  viewer: UserProfileDocument;
}): Promise<FirstHelloCandidate> {
  const {db, eventId, observerUid, viewer} = params;
  const participationSnap = await db
    .collection("eventParticipations")
    .where("eventId", "==", eventId)
    .where("status", "==", "attended")
    .get();
  const viewerCohortId = cohortIdForUser(viewer);
  const blockedUids = await fetchUidsBlockedWithViewer(db, observerUid);
  const candidateParticipations = participationSnap.docs
    .map((doc) => requireDoc<EventParticipationDocument>(
      doc,
      "EventParticipationDocument"
    ))
    .filter((candidate) => isEligibleFirstHelloCandidate({
      viewer,
      observerUid,
      viewerCohortId,
      candidate,
      blockedUids,
    }))
    .sort((a, b) => stableMissionRank({
      eventId,
      observerUid,
      targetUid: a.uid,
    }) - stableMissionRank({
      eventId,
      observerUid,
      targetUid: b.uid,
    }));

  const profileSnaps = await Promise.all(
    candidateParticipations.map((candidate) =>
      db.collection("publicProfiles").doc(candidate.uid).get()
    )
  );
  for (let i = 0; i < candidateParticipations.length; i++) {
    const profileSnap = profileSnaps[i];
    if (!profileSnap.exists) continue;
    const profile = requireDoc<PublicProfileDocument>(
      profileSnap,
      "PublicProfileDocument"
    );
    return {...candidateParticipations[i], profile};
  }

  throw new HttpsError(
    "failed-precondition",
    "No First Hello partner is ready yet. Use normal check-in or ask the host."
  );
}

/**
 * Loads every uid on either side of a block edge with the observer.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} observerUid Caller user id.
 * @return {Promise<Set<string>>} Blocked or blocking user ids.
 */
async function fetchUidsBlockedWithViewer(
  db: FirebaseFirestore.Firestore,
  observerUid: string
): Promise<Set<string>> {
  const [outgoing, incoming] = await Promise.all([
    db.collection("blocks").where("blockerUserId", "==", observerUid).get(),
    db.collection("blocks").where("blockedUserId", "==", observerUid).get(),
  ]);
  const blocked = new Set<string>();
  for (const doc of outgoing.docs) {
    const blockedUserId = doc.data()?.blockedUserId;
    if (typeof blockedUserId === "string") blocked.add(blockedUserId);
  }
  for (const doc of incoming.docs) {
    const blockerUserId = doc.data()?.blockerUserId;
    if (typeof blockerUserId === "string") blocked.add(blockerUserId);
  }
  return blocked;
}

/**
 * Checks whether a checked-in participant can be assigned.
 * @param {object} params Eligibility inputs.
 * @param {UserProfileDocument} params.viewer Caller profile.
 * @param {string} params.observerUid Caller user id.
 * @param {string} params.viewerCohortId Caller event cohort id.
 * @param {EventParticipationDocument} params.candidate Candidate participation.
 * @param {Set<string>} params.blockedUids Blocked user ids.
 * @return {boolean} True when assignable.
 */
function isEligibleFirstHelloCandidate(params: {
  viewer: UserProfileDocument;
  observerUid: string;
  viewerCohortId: string;
  candidate: EventParticipationDocument;
  blockedUids: Set<string>;
}): boolean {
  const candidate = params.candidate;
  const candidateGender = candidate.genderAtSignup;
  if (
    candidate.uid === params.observerUid ||
    candidate.status !== "attended" ||
    candidateGender == null ||
    params.blockedUids.has(candidate.uid)
  ) {
    return false;
  }
  if (!params.viewer.interestedInGenders.includes(candidateGender)) {
    return false;
  }

  const candidateCohortId = candidate.cohortAtSignup;
  switch (params.viewerCohortId) {
  case cohortIds.womenInterestedInMen:
    return candidateCohortId === cohortIds.menInterestedInWomen;
  case cohortIds.menInterestedInWomen:
    return candidateCohortId === cohortIds.womenInterestedInMen;
  default:
    return candidateCohortCanIncludeViewer(
      candidateCohortId,
      params.viewer.gender
    );
  }
}

/**
 * Checks whether the candidate cohort can include the viewer's gender.
 * @param {string|null|undefined} candidateCohortId Candidate cohort id.
 * @param {Gender} viewerGender Viewer gender.
 * @return {boolean} True when compatible.
 */
function candidateCohortCanIncludeViewer(
  candidateCohortId: string | null | undefined,
  viewerGender: Gender
): boolean {
  switch (candidateCohortId) {
  case cohortIds.menInterestedInWomen:
    return viewerGender === "woman";
  case cohortIds.womenInterestedInMen:
    return viewerGender === "man";
  case cohortIds.queerOrOpen:
  case cohortIds.nonBinaryOrOther:
    return true;
  default:
    return false;
  }
}

/**
 * Builds a persisted First Hello mission.
 * @param {object} params Mission inputs.
 * @param {string} params.eventId Event id.
 * @param {string} params.clubId Club id.
 * @param {string} params.observerUid Caller user id.
 * @param {FirstHelloCandidate} params.target Selected target.
 * @param {FirebaseFirestore.FieldValue} params.now Server timestamp.
 * @return {FirstHelloMissionDocument} Mission document.
 */
function buildFirstHelloMission(params: {
  eventId: string;
  clubId: string;
  observerUid: string;
  target: FirstHelloCandidate;
  now: FirebaseFirestore.FieldValue;
}): FirstHelloMissionDocument {
  return {
    eventId: params.eventId,
    clubId: params.clubId,
    observerUid: params.observerUid,
    targetUid: params.target.uid,
    targetDisplayName: params.target.profile.name,
    targetContext: "They are checked in and ready for the same room.",
    question: "Ask them: what made this event sound fun?",
    answerOptions: firstHelloAnswerOptions,
    status: "active",
    createdAt: params.now,
    updatedAt: params.now,
  };
}

/**
 * Requires an active event document.
 * @param {FirebaseFirestore.DocumentSnapshot} snap Event snapshot.
 * @return {EventDocument} Event document.
 */
function requireFirstHelloEvent(snap: FirebaseFirestore.DocumentSnapshot):
  EventDocument {
  if (!snap.exists) {
    throw new HttpsError("not-found", "Event not found.");
  }
  const event = requireDoc<EventDocument>(
    snap,
    "EventDocument"
  );
  if (event.status === "cancelled") {
    throw new HttpsError("failed-precondition", "This event is cancelled.");
  }
  return event;
}

/**
 * Requires a saved event-success plan with First Hello enabled.
 * @param {FirebaseFirestore.DocumentSnapshot} snap Plan snapshot.
 * @param {string} eventId Event id.
 * @param {string} clubId Club id.
 */
function requireFirstHelloPlan(
  snap: FirebaseFirestore.DocumentSnapshot,
  eventId: string,
  clubId: string
) {
  if (!snap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "The host has not enabled live guidance for this event."
    );
  }
  const plan = requireDoc<EventSuccessPlanDocument>(
    snap,
    "EventSuccessPlanDocument"
  );
  if (
    (plan.eventId !== undefined && plan.eventId !== eventId) ||
    (plan.clubId !== undefined && plan.clubId !== clubId) ||
    !moduleSelected(plan.selectedModuleIds, FIRST_HELLO_MODULE_ID)
  ) {
    throw new HttpsError(
      "failed-precondition",
      "First Hello is not enabled for this event."
    );
  }
}

/**
 * Requires a signed-up or already-attended participant.
 * @param {FirebaseFirestore.DocumentSnapshot} snap Participation snapshot.
 * @param {string} uid Expected uid.
 * @return {EventParticipationDocument} Participation document.
 */
function requireSignedUpParticipant(
  snap: FirebaseFirestore.DocumentSnapshot,
  uid: string
): EventParticipationDocument {
  if (!snap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "You must be signed up for this event to use First Hello."
    );
  }
  const participation = requireDoc<EventParticipationDocument>(
    snap,
    "EventParticipationDocument"
  );
  if (
    participation.uid !== uid ||
    (participation.status !== "signedUp" &&
      participation.status !== "attended")
  ) {
    throw new HttpsError(
      "failed-precondition",
      "You must be signed up for this event to use First Hello."
    );
  }
  return participation;
}

/**
 * Requires the mission target to still be checked in.
 * @param {FirebaseFirestore.DocumentSnapshot} snap Target participation snap.
 * @param {string} uid Expected target user id.
 */
function requireAttendedTarget(
  snap: FirebaseFirestore.DocumentSnapshot,
  uid: string
) {
  if (!snap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "This First Hello partner is no longer available."
    );
  }
  const participation = requireDoc<EventParticipationDocument>(
    snap,
    "EventParticipationDocument"
  );
  if (participation.uid !== uid || participation.status !== "attended") {
    throw new HttpsError(
      "failed-precondition",
      "This First Hello partner is no longer available."
    );
  }
}

/**
 * Validates mission ownership, active state, and answer option.
 * @param {FirstHelloMissionDocument} mission Mission document.
 * @param {string} eventId Expected event id.
 * @param {string} observerUid Expected observer uid.
 * @param {string} answerId Selected answer id.
 */
function requireOwnedActiveMission(
  mission: FirstHelloMissionDocument,
  eventId: string,
  observerUid: string,
  answerId: string
) {
  if (
    mission.eventId !== eventId ||
    mission.observerUid !== observerUid ||
    mission.status !== "active"
  ) {
    throw new HttpsError(
      "failed-precondition",
      "This First Hello mission is not active."
    );
  }
  if (!mission.answerOptions.some((option) => option.id === answerId)) {
    throw new HttpsError(
      "invalid-argument",
      "Choose one of the First Hello answer options."
    );
  }
}

/**
 * Enforces the shared event check-in time window.
 * @param {EventDocument} event Event document.
 * @param {number} nowMillis Current epoch millis.
 */
function requireCheckInWindow(event: EventDocument, nowMillis: number) {
  const startMillis = event.startTime.toMillis();
  const windowStartMillis = startMillis -
    EVENT_SELF_CHECK_IN_WINDOW_BEFORE_MINUTES * 60 * 1000;
  const windowEndMillis = startMillis +
    EVENT_SELF_CHECK_IN_WINDOW_AFTER_MINUTES * 60 * 1000;
  if (nowMillis < windowStartMillis) {
    throw new HttpsError(
      "failed-precondition",
      `Check-in opens ${EVENT_SELF_CHECK_IN_WINDOW_BEFORE_MINUTES} min ` +
      "before the event starts."
    );
  }
  if (nowMillis > windowEndMillis) {
    throw new HttpsError(
      "failed-precondition",
      "Check-in closed. Contact the host."
    );
  }
}

/**
 * Enforces the tighter First Hello venue radius when event coordinates exist.
 * @param {EventDocument} event Event document.
 * @param {number|null|undefined} latitude Caller latitude.
 * @param {number|null|undefined} longitude Caller longitude.
 */
function requireVenueProximity(
  event: EventDocument,
  latitude: number | null | undefined,
  longitude: number | null | undefined
) {
  const eventLat = event.meetingLocation?.latitude ?? event.startingPointLat;
  const eventLng = event.meetingLocation?.longitude ?? event.startingPointLng;
  if (eventLat == null || eventLng == null) return;
  if (latitude == null || longitude == null) {
    throw new HttpsError(
      "invalid-argument",
      "Location is required to start First Hello. Enable GPS and try again."
    );
  }
  const distance = haversineDistanceM(latitude, longitude, eventLat, eventLng);
  if (distance > EVENT_FIRST_HELLO_MAX_DISTANCE_METERS) {
    throw new HttpsError(
      "failed-precondition",
      `You must be within ${EVENT_FIRST_HELLO_MAX_DISTANCE_METERS} m ` +
      "of the meeting point to start First Hello. You appear to be " +
      `${Math.round(distance)} m away.`
    );
  }
}

/**
 * Haversine distance between two lat/lng points, in metres.
 * @param {number} lat1 First point latitude.
 * @param {number} lng1 First point longitude.
 * @param {number} lat2 Second point latitude.
 * @param {number} lng2 Second point longitude.
 * @return {number} Distance in metres.
 */
function haversineDistanceM(
  lat1: number, lng1: number,
  lat2: number, lng2: number
): number {
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
    Math.sin(dLng / 2) * Math.sin(dLng / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return EARTH_RADIUS_M * c;
}

/**
 * Converts degrees to radians.
 * @param {number} deg Angle in degrees.
 * @return {number} Angle in radians.
 */
function toRad(deg: number): number {
  return (deg * Math.PI) / 180;
}

/**
 * Checks whether a plan includes a module.
 * @param {unknown} selectedModuleIds Persisted module ids.
 * @param {string} moduleId Module id.
 * @return {boolean} True when selected.
 */
function moduleSelected(selectedModuleIds: unknown, moduleId: string): boolean {
  return Array.isArray(selectedModuleIds) &&
    selectedModuleIds.includes(moduleId);
}

/**
 * Builds the deterministic First Hello mission document id.
 * @param {string} eventId Event id.
 * @param {string} uid Observer user id.
 * @return {string} Mission document id.
 */
function firstHelloMissionId(eventId: string, uid: string): string {
  return `${eventId}_${uid}`;
}

/**
 * Builds a deterministic but distributed target ranking.
 * @param {object} params Rank inputs.
 * @param {string} params.eventId Event id.
 * @param {string} params.observerUid Observer user id.
 * @param {string} params.targetUid Candidate user id.
 * @return {number} Stable unsigned rank.
 */
function stableMissionRank(params: {
  eventId: string;
  observerUid: string;
  targetUid: string;
}): number {
  const key = `${params.eventId}:${params.observerUid}:${params.targetUid}`;
  let hash = 2166136261;
  for (let i = 0; i < key.length; i++) {
    hash ^= key.charCodeAt(i);
    hash = Math.imul(hash, 16777619);
  }
  return hash >>> 0;
}

/**
 * Normalizes First Hello callable string payload fields.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Normalized payload.
 */
function normalizeFirstHelloPayload(data: unknown): unknown {
  const normalized = normalizeEventIdPayload(data);
  if (
    typeof normalized !== "object" ||
    normalized === null ||
    Array.isArray(normalized)
  ) {
    return normalized;
  }
  const payload = {...normalized} as Record<string, unknown>;
  if (typeof payload.answerId === "string") {
    payload.answerId = payload.answerId.trim();
  }
  return payload;
}
