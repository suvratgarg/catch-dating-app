import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {
  EventDoc,
  EventParticipationDoc,
  Gender,
  PublicProfileDoc,
  UserProfileDoc,
} from "../shared/generated/firestoreAdminTypes";
import {requireAuth} from "../shared/auth";
import {EventIdCallablePayload} from
  "../shared/generated/eventIdCallablePayload";
import {SubmitEventSuccessWingmanRequestCallablePayload} from
  "../shared/generated/submitEventSuccessWingmanRequestCallablePayload";
import {
  validateEventIdCallablePayload,
  validateSubmitEventSuccessWingmanRequestCallablePayload,
} from "../shared/generated/schemaValidators";
import {validateCallableWithAjv, requireDoc} from "../shared/validation";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {normalizeEventIdPayload} from "../events/eventPayloadNormalization";
import {cohortIdForUser, cohortIds} from "../events/eventPolicy";
import {blockDocId} from "../safety/blocking";

const WINGMAN_REQUESTS_MODULE_ID = "wingman_requests";

interface WingmanRequestDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  nowMillis: () => number;
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
  wingmanRequestsEnabled?: boolean;
}

interface ExistingWingmanRequestDoc {
  eventId?: string;
  requesterUid?: string;
  targetUid?: string;
  hostVisibleConsent?: boolean;
  note?: string | null;
  createdAt?: unknown;
}

type WingmanCandidateProfile = PublicProfileDoc & {uid: string};

const defaultDeps: WingmanRequestDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  nowMillis: () => Date.now(),
  checkRateLimit: defaultCheckRateLimit,
};

/**
 * Fetches host-help candidates for the caller from server-owned eligibility.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {WingmanRequestDeps} deps Injectable dependencies for tests.
 * @return {Promise<{profiles: WingmanCandidateProfile[]}>} Candidate profiles.
 */
export async function fetchEventSuccessWingmanCandidatesHandler(
  request: CallableRequest<unknown>,
  deps: WingmanRequestDeps = defaultDeps
): Promise<{profiles: WingmanCandidateProfile[]}> {
  const viewerUid = requireAuth(request);
  const data = validateCallableWithAjv<EventIdCallablePayload>(
    request,
    validateEventIdCallablePayload,
    normalizeEventIdPayload
  );

  const db = deps.firestore();
  await deps.checkRateLimit?.(
    db,
    viewerUid,
    "fetchEventSuccessWingmanCandidates"
  );

  const [
    eventSnap,
    planSnap,
    viewerParticipationSnap,
    viewerSnap,
  ] = await Promise.all([
    db.collection("events").doc(data.eventId).get(),
    db.collection("eventSuccessPlans").doc(data.eventId).get(),
    db
      .collection("eventParticipations")
      .doc(eventParticipationId(data.eventId, viewerUid))
      .get(),
    db.collection("users").doc(viewerUid).get(),
  ]);

  const event = requireActiveWingmanEvent(eventSnap, deps.nowMillis());
  requireWingmanPlan(planSnap, data.eventId, event.clubId);
  requireAttendedParticipant(viewerParticipationSnap, viewerUid);
  if (!viewerSnap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "Complete your profile before asking the host for help."
    );
  }
  const viewer = requireDoc<UserProfileDoc>(viewerSnap, "UserProfileDoc");
  const viewerCohortId = cohortIdForUser(viewer);

  const participationSnap = await db
    .collection("eventParticipations")
    .where("eventId", "==", data.eventId)
    .where("status", "==", "attended")
    .get();
  const candidateIds = participationSnap.docs
    .map((doc) => requireDoc<EventParticipationDoc>(
      doc,
      "EventParticipationDoc"
    ))
    .filter((candidate) => isEligibleWingmanRequestCandidate({
      viewer,
      viewerUid,
      viewerCohortId,
      candidate,
    }))
    .map((candidate) => candidate.uid)
    .filter((uid, index, all) => all.indexOf(uid) === index)
    .sort();

  const blockedUids = await fetchUidsBlockedWithViewer(db, viewerUid);
  const visibleIds = candidateIds.filter((uid) => !blockedUids.has(uid));
  const profiles = await fetchCandidateProfiles(db, visibleIds);

  return {profiles};
}

/**
 * Loads every uid on either side of a block edge with the viewer using two
 * queries, instead of a per-candidate pair of document reads.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} viewerUid Caller user id.
 * @return {Promise<Set<string>>} Uids the viewer blocks or is blocked by.
 */
async function fetchUidsBlockedWithViewer(
  db: FirebaseFirestore.Firestore,
  viewerUid: string
): Promise<Set<string>> {
  const [outgoing, incoming] = await Promise.all([
    db.collection("blocks").where("blockerUserId", "==", viewerUid).get(),
    db.collection("blocks").where("blockedUserId", "==", viewerUid).get(),
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
 * Loads candidate public profiles with one parallel read per uid, instead of
 * a sequential per-candidate await.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string[]} uids Visible candidate uids.
 * @return {Promise<WingmanCandidateProfile[]>} Existing candidate profiles.
 */
async function fetchCandidateProfiles(
  db: FirebaseFirestore.Firestore,
  uids: string[]
): Promise<WingmanCandidateProfile[]> {
  const snaps = await Promise.all(
    uids.map((uid) => db.collection("publicProfiles").doc(uid).get())
  );
  const profiles: WingmanCandidateProfile[] = [];
  snaps.forEach((snap, index) => {
    if (!snap.exists) return;
    const profile = requireDoc<PublicProfileDoc>(snap, "PublicProfileDoc");
    profiles.push({uid: uids[index], ...profile});
  });
  return profiles;
}

/**
 * Creates or updates a host-visible wingman request for the caller.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {WingmanRequestDeps} deps Injectable dependencies for tests.
 * @return {Promise<{saved: boolean}>} Operation result.
 */
export async function submitEventSuccessWingmanRequestHandler(
  request: CallableRequest<unknown>,
  deps: WingmanRequestDeps = defaultDeps
): Promise<{saved: boolean}> {
  const requesterUid = requireAuth(request);
  const data =
    validateCallableWithAjv<SubmitEventSuccessWingmanRequestCallablePayload>(
      request,
      validateSubmitEventSuccessWingmanRequestCallablePayload,
      normalizeSubmitWingmanPayload
    );
  if (data.targetUid === requesterUid) {
    throw new HttpsError(
      "invalid-argument",
      "Choose another attendee for host help."
    );
  }

  const db = deps.firestore();
  await deps.checkRateLimit?.(
    db,
    requesterUid,
    "submitEventSuccessWingmanRequest"
  );

  const requestRef = db
    .collection("eventSuccessWingmanRequests")
    .doc(wingmanRequestId(data.eventId, requesterUid));
  const eventRef = db.collection("events").doc(data.eventId);
  const planRef = db.collection("eventSuccessPlans").doc(data.eventId);
  const requesterParticipationRef = db
    .collection("eventParticipations")
    .doc(eventParticipationId(data.eventId, requesterUid));
  const targetParticipationRef = db
    .collection("eventParticipations")
    .doc(eventParticipationId(data.eventId, data.targetUid));
  const requesterBlocksTargetRef = db
    .collection("blocks")
    .doc(blockDocId(requesterUid, data.targetUid));
  const targetBlocksRequesterRef = db
    .collection("blocks")
    .doc(blockDocId(data.targetUid, requesterUid));

  await db.runTransaction(async (tx) => {
    const [
      eventSnap,
      planSnap,
      requesterParticipationSnap,
      targetParticipationSnap,
      requesterBlocksTargetSnap,
      targetBlocksRequesterSnap,
      existingRequestSnap,
    ] = await Promise.all([
      tx.get(eventRef),
      tx.get(planRef),
      tx.get(requesterParticipationRef),
      tx.get(targetParticipationRef),
      tx.get(requesterBlocksTargetRef),
      tx.get(targetBlocksRequesterRef),
      tx.get(requestRef),
    ]);

    const event = requireActiveWingmanEvent(
      eventSnap,
      deps.nowMillis()
    );
    requireWingmanPlan(planSnap, data.eventId, event.clubId);
    requireAttendedParticipant(requesterParticipationSnap, requesterUid);
    requireAttendedParticipant(targetParticipationSnap, data.targetUid);
    if (requesterBlocksTargetSnap.exists || targetBlocksRequesterSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "Host help is not available for this attendee."
      );
    }

    const existing = existingRequestSnap.exists ?
      existingRequestSnap.data() as ExistingWingmanRequestDoc :
      null;
    const now = deps.serverTimestamp();
    tx.set(requestRef, {
      eventId: data.eventId,
      clubId: event.clubId,
      requesterUid,
      targetUid: data.targetUid,
      status: "active",
      hostVisibleConsent: true,
      note: normalizeNullableString(data.note),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    });
  });

  return {saved: true};
}

/**
 * Withdraws the caller's wingman request for an event.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {WingmanRequestDeps} deps Injectable dependencies for tests.
 * @return {Promise<{withdrawn: boolean}>} Operation result.
 */
export async function withdrawEventSuccessWingmanRequestHandler(
  request: CallableRequest<unknown>,
  deps: WingmanRequestDeps = defaultDeps
): Promise<{withdrawn: boolean}> {
  const requesterUid = requireAuth(request);
  const data = validateCallableWithAjv<EventIdCallablePayload>(
    request,
    validateEventIdCallablePayload,
    normalizeEventIdPayload
  );

  const db = deps.firestore();
  await deps.checkRateLimit?.(
    db,
    requesterUid,
    "withdrawEventSuccessWingmanRequest"
  );

  const requestRef = db
    .collection("eventSuccessWingmanRequests")
    .doc(wingmanRequestId(data.eventId, requesterUid));
  let withdrawn = false;
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(requestRef);
    if (!snap.exists) return;
    const existing = snap.data() as ExistingWingmanRequestDoc;
    if (existing.eventId !== data.eventId ||
      existing.requesterUid !== requesterUid) {
      throw new HttpsError(
        "permission-denied",
        "You can only withdraw your own host-help request."
      );
    }
    tx.set(requestRef, {
      ...existing,
      eventId: data.eventId,
      requesterUid,
      targetUid: existing.targetUid,
      status: "withdrawn",
      hostVisibleConsent: existing.hostVisibleConsent ?? true,
      note: existing.note ?? null,
      createdAt: existing.createdAt ?? deps.serverTimestamp(),
      updatedAt: deps.serverTimestamp(),
    });
    withdrawn = true;
  });

  return {withdrawn};
}

export const submitEventSuccessWingmanRequest = onCall(
  appCheckCallableOptions,
  (request) => submitEventSuccessWingmanRequestHandler(request)
);

export const withdrawEventSuccessWingmanRequest = onCall(
  appCheckCallableOptions,
  (request) => withdrawEventSuccessWingmanRequestHandler(request)
);

export const fetchEventSuccessWingmanCandidates = onCall(
  appCheckCallableOptions,
  (request) => fetchEventSuccessWingmanCandidatesHandler(request)
);

/**
 * Normalizes submit-wingman callable payload strings.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Normalized payload.
 */
function normalizeSubmitWingmanPayload(data: unknown): unknown {
  if (typeof data !== "object" || data === null || Array.isArray(data)) {
    return data;
  }
  const payload = {...data} as Record<string, unknown>;
  if (typeof payload.eventId === "string") {
    payload.eventId = payload.eventId.trim();
  }
  if (typeof payload.targetUid === "string") {
    payload.targetUid = payload.targetUid.trim();
  }
  if (typeof payload.note === "string") {
    payload.note = payload.note.trim();
  }
  return payload;
}

/**
 * Requires an active event that has not ended.
 * @param {FirebaseFirestore.DocumentSnapshot} snap Event snapshot.
 * @param {number} nowMillis Current epoch millis.
 * @return {EventDoc} Event document.
 */
function requireActiveWingmanEvent(
  snap: FirebaseFirestore.DocumentSnapshot,
  nowMillis: number
): EventDoc {
  if (!snap.exists) {
    throw new HttpsError("not-found", "Event not found.");
  }
  const event = requireDoc<EventDoc>(snap, "EventDoc");
  if (event.status === "cancelled") {
    throw new HttpsError("failed-precondition", "This event is cancelled.");
  }
  if (event.endTime.toMillis() <= nowMillis) {
    throw new HttpsError(
      "failed-precondition",
      "Host help is only available while the event is live."
    );
  }
  return event;
}

/**
 * Requires a saved event-success plan with wingman requests enabled.
 * @param {FirebaseFirestore.DocumentSnapshot} snap Plan snapshot.
 * @param {string} eventId Event id.
 * @param {string} clubId Club id.
 */
function requireWingmanPlan(
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
  const plan = requireDoc<EventSuccessPlanDoc>(snap, "EventSuccessPlanDoc");
  if (
    (plan.eventId !== undefined && plan.eventId !== eventId) ||
    (plan.clubId !== undefined && plan.clubId !== clubId) ||
    plan.wingmanRequestsEnabled === false ||
    !moduleSelected(plan.selectedModuleIds, WINGMAN_REQUESTS_MODULE_ID)
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Host help is not enabled for this event."
    );
  }
}

/**
 * Requires an attended event participation for a user.
 * @param {FirebaseFirestore.DocumentSnapshot} snap Participation snapshot.
 * @param {string} uid Expected uid.
 */
function requireAttendedParticipant(
  snap: FirebaseFirestore.DocumentSnapshot,
  uid: string
) {
  if (!snap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "Host help is only available to checked-in attendees."
    );
  }
  const participation = requireDoc<EventParticipationDoc>(
    snap,
    "EventParticipationDoc"
  );
  if (participation.uid !== uid || participation.status !== "attended") {
    throw new HttpsError(
      "failed-precondition",
      "Host help is only available to checked-in attendees."
    );
  }
}

/**
 * Checks whether a checked-in participant can be shown as a host-help target.
 * @param {Object} params Eligibility inputs.
 * @param {UserProfileDoc} params.viewer Caller profile.
 * @param {string} params.viewerUid Caller user id.
 * @param {string} params.viewerCohortId Caller event cohort id.
 * @param {EventParticipationDoc} params.candidate Candidate participation.
 * @return {boolean} True when eligible.
 */
function isEligibleWingmanRequestCandidate(params: {
  viewer: UserProfileDoc;
  viewerUid: string;
  viewerCohortId: string;
  candidate: EventParticipationDoc;
}): boolean {
  const candidate = params.candidate;
  const candidateGender = candidate.genderAtSignup;
  if (
    candidate.uid === params.viewerUid ||
    candidate.status !== "attended" ||
    candidateGender == null
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
 * Builds the deterministic event participation document id.
 * @param {string} eventId Event id.
 * @param {string} uid User id.
 * @return {string} Document id.
 */
function eventParticipationId(eventId: string, uid: string): string {
  return `${eventId}_${uid}`;
}

/**
 * Builds the deterministic wingman request document id.
 * @param {string} eventId Event id.
 * @param {string} uid Requester user id.
 * @return {string} Document id.
 */
function wingmanRequestId(eventId: string, uid: string): string {
  return `${eventId}_${uid}`;
}

/**
 * Normalizes nullable note text.
 * @param {unknown} value Raw note.
 * @return {string|null} Normalized note.
 */
function normalizeNullableString(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const normalized = value.trim();
  return normalized.length === 0 ? null : normalized;
}
