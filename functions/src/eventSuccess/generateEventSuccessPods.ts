import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {EventDoc, ClubDoc, BlockDoc, UserProfileDoc} from "../shared/firestore";
import {requireAuth} from "../shared/auth";
import {EventIdCallablePayload} from
  "../shared/generated/eventIdCallablePayload";
import {validateEventIdCallablePayload} from
  "../shared/generated/schemaValidators";
import {validateCallableWithAjv, requireDoc} from "../shared/validation";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {normalizeEventIdPayload} from "../events/eventPayloadNormalization";
import {isClubHost} from "../shared/clubHosts";
import {assertMicroPodStrategy} from "./assignmentStrategies";
import {scoreCompatibilityPair} from "./compatibilityPolicy";

const MICRO_PODS_MODULE_ID = "micro_pods";
const DEFAULT_TARGET_POD_SIZE = 5;
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

interface EventSuccessPlanDoc {
  eventId?: string;
  clubId?: string;
  selectedModuleIds?: unknown;
  structureConfig?: {
    unitKind?: unknown;
    unitSize?: unknown;
    unitCount?: unknown;
  };
}

interface EventParticipationDoc {
  uid?: string;
  status?: string;
}

interface EventSuccessPreferenceDoc {
  uid?: string;
  microPodsOptedOut?: boolean;
}

interface ActiveParticipant {
  uid: string;
  status: typeof ACTIVE_STATUSES[number];
  gender?: string;
  interestedInGenders: string[];
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
  source: string;
  createdAt: FirebaseFirestore.FieldValue;
  updatedAt: FirebaseFirestore.FieldValue;
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
      "Only the club host can generate event pods.");
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
  if (!moduleSelected(plan.selectedModuleIds, MICRO_PODS_MODULE_ID)) {
    throw new HttpsError("failed-precondition",
      "Micro-pods are not enabled for this event.");
  }
  assertMicroPodStrategy(plan);

  const participationsSnap = await db
    .collection("eventParticipations")
    .where("eventId", "==", eventId)
    .where("status", "in", [...ACTIVE_STATUSES])
    .get();
  const optedOutUids = await fetchMicroPodsOptOutUids(db, eventId);
  const participants = participationsSnap.docs
    .map((doc) => doc.data() as EventParticipationDoc)
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
  const groups = buildPods(eligibleParticipants, blockedPairs, plan);
  const assignments = buildAssignments({
    eventId,
    clubId: event.clubId,
    groups,
    now: deps.serverTimestamp(),
  });
  await writeAssignments(db, eventId, assignments);

  return {
    assignmentCount: assignments.size,
    podCount: groups.length,
  };
}

export const generateEventSuccessPods = onCall(
  appCheckCallableOptions,
  (request) => generateEventSuccessPodsHandler(request)
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
 * Converts a participation edge into an active pod candidate.
 * @param {EventParticipationDoc} data Participation document data.
 * @return {ActiveParticipant | null} Active participant or null.
 */
function toActiveParticipant(
  data: EventParticipationDoc
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
    const preference = doc.data() as EventSuccessPreferenceDoc;
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
    const profile = snaps[index].data() as Partial<UserProfileDoc> | undefined;
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
 * Splits active participants into deterministic micro-pods.
 * @param {Array<ActiveParticipant>} participants Active participant list.
 * @param {Set<string>} blockedPairs Undirected blocked pair keys.
 * @param {EventSuccessPlanDoc} plan Persisted event-success plan.
 * @return {Array<Array<ActiveParticipant>>} Pod groups.
 */
function buildPods(
  participants: ActiveParticipant[],
  blockedPairs: Set<string>,
  plan: EventSuccessPlanDoc
): ActiveParticipant[][] {
  if (participants.length === 0) return [];
  const podCount = groupCountForPlan(plan, participants.length);
  const groups = Array.from(
    {length: podCount},
    () => [] as ActiveParticipant[]
  );
  for (const participant of participants) {
    const candidates = groups
      .map((group, index) => ({group, index}))
      .sort((a, b) =>
        podCandidateScore(participant, a.group, blockedPairs) -
        podCandidateScore(participant, b.group, blockedPairs) ||
        a.index - b.index
      );
    const safeCandidate = candidates.find(({group}) =>
      canJoinPod(participant, group, blockedPairs)
    );
    if (safeCandidate !== undefined) {
      safeCandidate.group.push(participant);
    } else {
      groups.push([participant]);
    }
  }
  return groups.filter((group) => group.length > 0);
}

/**
 * Scores how suitable a pod is for adding one attendee.
 * @param {ActiveParticipant} participant Candidate attendee.
 * @param {ActiveParticipant[]} group Current group.
 * @param {Set<string>} blockedPairs Undirected blocked pair keys.
 * @return {number} Lower score is better.
 */
function podCandidateScore(
  participant: ActiveParticipant,
  group: ActiveParticipant[],
  blockedPairs: Set<string>
): number {
  if (!canJoinPod(participant, group, blockedPairs)) {
    return Number.POSITIVE_INFINITY;
  }
  return group.length * 100 +
    sameGenderCount(participant, group) * 10 -
    socialCompatibilityBonus(participant, group);
}

/**
 * Counts current pod members with the same known gender.
 * @param {ActiveParticipant} participant Candidate attendee.
 * @param {ActiveParticipant[]} group Current group.
 * @return {number} Same-gender count.
 */
function sameGenderCount(
  participant: ActiveParticipant,
  group: ActiveParticipant[]
): number {
  if (participant.gender === undefined) return 0;
  return group.filter((member) => member.gender === participant.gender).length;
}

/**
 * Gives a small tie-breaker to socially compatible pod placements.
 * @param {ActiveParticipant} participant Candidate attendee.
 * @param {ActiveParticipant[]} group Current group.
 * @return {number} Compatibility bonus.
 */
function socialCompatibilityBonus(
  participant: ActiveParticipant,
  group: ActiveParticipant[]
): number {
  return group.reduce(
    (sum, member) =>
      sum + scoreCompatibilityPair(participant, member, false).score,
    0
  );
}

/**
 * Resolves the group count from saved structure, falling back to target size.
 * @param {EventSuccessPlanDoc} plan Persisted event-success plan.
 * @param {number} participantCount Eligible participant count.
 * @return {number} Number of groups to seed.
 */
function groupCountForPlan(
  plan: EventSuccessPlanDoc,
  participantCount: number
): number {
  if (plan.structureConfig?.unitKind === "wholeGroup") return 1;
  const configuredCount = boundedInteger(
    plan.structureConfig?.unitCount,
    1,
    200
  );
  if (configuredCount !== null) return configuredCount;
  const targetSize = boundedInteger(
    plan.structureConfig?.unitSize,
    2,
    50
  ) ?? DEFAULT_TARGET_POD_SIZE;
  return Math.max(1, Math.ceil(participantCount / targetSize));
}

/**
 * Returns an integer in range from a possibly-untyped Firestore value.
 * @param {unknown} value Raw numeric value.
 * @param {number} min Minimum accepted value.
 * @param {number} max Maximum accepted value.
 * @return {number|null} Clamped integer or null.
 */
function boundedInteger(
  value: unknown,
  min: number,
  max: number
): number | null {
  if (typeof value !== "number" || !Number.isFinite(value)) return null;
  return Math.max(min, Math.min(max, Math.floor(value)));
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
      const block = doc.data() as Partial<BlockDoc>;
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
 * Returns true when adding a participant will not violate block safety.
 * @param {ActiveParticipant} participant Candidate participant.
 * @param {ActiveParticipant[]} group Current pod members.
 * @param {Set<string>} blockedPairs Undirected blocked pair keys.
 * @return {boolean} Whether the participant can join the pod.
 */
function canJoinPod(
  participant: ActiveParticipant,
  group: ActiveParticipant[],
  blockedPairs: Set<string>
): boolean {
  return group.every((member) =>
    !blockedPairs.has(blockedPairKey(participant.uid, member.uid))
  );
}

/**
 * Builds a deterministic undirected pair key.
 * @param {string} uidA First uid.
 * @param {string} uidB Second uid.
 * @return {string} Pair key.
 */
function blockedPairKey(uidA: string, uidB: string): string {
  return [uidA, uidB].sort().join("__");
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
 * @param {Array<Array<ActiveParticipant>>} params.groups Pod groups.
 * @param {FirebaseFirestore.FieldValue} params.now Server timestamp field.
 * @return {Map<string, GeneratedAssignment>} Assignment docs by id.
 */
function buildAssignments(params: {
  eventId: string;
  clubId: string;
  groups: ActiveParticipant[][];
  now: FirebaseFirestore.FieldValue;
}): Map<string, GeneratedAssignment> {
  const assignments = new Map<string, GeneratedAssignment>();
  params.groups.forEach((group, index) => {
    const label = podLabel(index);
    const groupUids = group.map((participant) => participant.uid);
    for (const participant of group) {
      const docId = assignmentId(params.eventId, participant.uid);
      assignments.set(docId, {
        eventId: params.eventId,
        clubId: params.clubId,
        uid: participant.uid,
        moduleId: MICRO_PODS_MODULE_ID,
        label,
        displayTitle: label,
        displaySubtitle: podSubtitle(group.length),
        peerUids: groupUids.filter((peerUid) => peerUid !== participant.uid),
        source: "server_v1",
        createdAt: params.now,
        updatedAt: params.now,
      });
    }
  });
  return assignments;
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

/**
 * Builds attendee-facing pod size copy.
 * @param {number} groupSize Number of people in the pod.
 * @return {string} Display subtitle.
 */
function podSubtitle(groupSize: number): string {
  return `${groupSize} ${groupSize === 1 ? "person" : "people"} ` +
    "in this event pod.";
}

/**
 * Builds a compact host and attendee-facing pod label.
 * @param {number} index Zero-based pod index.
 * @return {string} Pod label.
 */
function podLabel(index: number): string {
  const base = String.fromCharCode(65 + (index % 26));
  const suffix = index >= 26 ? `${Math.floor(index / 26) + 1}` : "";
  return `Pod ${base}${suffix}`;
}
