import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {
  EventDocument,
  MatchDocument,
} from "../shared/generated/firestoreAdminTypes";
import {buildFeedbackSignalFact} from "./signalBuilders";
import {
  recordParticipantSignalFactsBestEffort,
} from "./participantSignals";

const eventSuccessFeedbackCollection = "eventSuccessFeedback";
const eventSuccessScorecardsCollection = "eventSuccessScorecards";
const eventSafetyReportsCollection = "eventSafetyReports";
const MIN_FEEDBACK_FOR_HOST_SAFETY_COUNT = 5;

interface EventSuccessFeedbackDocument {
  eventId: string;
  clubId: string;
  uid: string;
  welcomeRating: number;
  structureRating: number;
  metNewPeopleCount: number;
  safetyConcern: boolean;
  privateNote?: string | null;
  createdAt?: FirebaseFirestore.Timestamp;
  updatedAt?: FirebaseFirestore.Timestamp;
}

export interface EventSuccessScorecardDocument {
  eventId: string;
  clubId: string;
  bookedCount: number;
  checkedInCount: number;
  feedbackCount: number;
  attendeesWhoMetTwoPlusPeople: number;
  mutualMatchCount: number;
  chatStartedCount: number;
  averageWelcomeRating: number;
  averageStructureRating: number;
  safetyIncidentCount: number;
  updatedAt: FirebaseFirestore.FieldValue | FirebaseFirestore.Timestamp;
}

interface EventSuccessScorecardDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
}

const defaultDeps: EventSuccessScorecardDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
};

/**
 * Recomputes an event scorecard from canonical event, feedback, and match docs.
 * This is intentionally idempotent so duplicate Firestore trigger deliveries
 * cannot inflate metrics.
 * @param {string} eventId Event id to refresh.
 * @param {EventSuccessScorecardDeps} deps Injectable Firebase dependencies.
 */
export async function refreshEventSuccessScorecard(
  eventId: string,
  deps: EventSuccessScorecardDeps = defaultDeps
): Promise<void> {
  const db = deps.firestore();
  const eventSnap = await db.collection("events").doc(eventId).get();
  if (!eventSnap.exists) return;

  const event = eventSnap.data() as EventDocument;
  const [feedbackSnap, matchesSnap] = await Promise.all([
    db
      .collection(eventSuccessFeedbackCollection)
      .where("eventId", "==", eventId)
      .get(),
    db.collection("matches").where("eventIds", "array-contains", eventId).get(),
  ]);

  const feedback = feedbackSnap.docs.map(
    (doc) => doc.data() as EventSuccessFeedbackDocument
  );
  const matches = matchesSnap.docs.map((doc) => doc.data() as MatchDocument);
  const scorecard = buildEventSuccessScorecard({
    eventId,
    event,
    feedback,
    matches,
    updatedAt: deps.serverTimestamp(),
  });

  await db
    .collection(eventSuccessScorecardsCollection)
    .doc(eventId)
    .set(scorecard, {merge: true});
}

/**
 * Builds an event-success scorecard document from loaded source data.
 * @param {object} params Source event, feedback, and match data.
 * @return {EventSuccessScorecardDocument} Scorecard payload.
 */
export function buildEventSuccessScorecard(params: {
  eventId: string;
  event: EventDocument;
  feedback: EventSuccessFeedbackDocument[];
  matches: MatchDocument[];
  updatedAt: FirebaseFirestore.FieldValue | FirebaseFirestore.Timestamp;
}): EventSuccessScorecardDocument {
  const {eventId, event, feedback, matches, updatedAt} = params;
  const feedbackCount = feedback.length;
  const safetyIncidentCount = feedback.filter((item) => item.safetyConcern)
    .length;
  return {
    eventId,
    clubId: event.clubId,
    bookedCount: event.bookedCount ?? 0,
    checkedInCount: event.checkedInCount ?? 0,
    feedbackCount,
    attendeesWhoMetTwoPlusPeople: feedback.filter(
      (item) => item.metNewPeopleCount >= 2
    ).length,
    mutualMatchCount: matches.length,
    chatStartedCount: matches.filter((match) => match.lastMessageAt != null)
      .length,
    averageWelcomeRating: average(feedback.map((item) => item.welcomeRating)),
    averageStructureRating: average(
      feedback.map((item) => item.structureRating)
    ),
    safetyIncidentCount: feedbackCount >= MIN_FEEDBACK_FOR_HOST_SAFETY_COUNT ?
      safetyIncidentCount :
      0,
    updatedAt,
  };
}

/**
 * Handles feedback writes by refreshing the scorecard and recording one
 * participant feedback fact for future participant-momentum analysis.
 * @param {string} feedbackId Feedback document id.
 * @param {EventSuccessFeedbackDocument | undefined} before Previous feedback
 * doc.
 * @param {EventSuccessFeedbackDocument | undefined} after New feedback doc.
 * @param {EventSuccessScorecardDeps} deps Injectable Firebase dependencies.
 */
export async function onEventSuccessFeedbackWrittenHandler(
  feedbackId: string,
  before: EventSuccessFeedbackDocument | undefined,
  after: EventSuccessFeedbackDocument | undefined,
  deps: EventSuccessScorecardDeps = defaultDeps
): Promise<void> {
  const eventIds = new Set<string>();
  if (before?.eventId) eventIds.add(before.eventId);
  if (after?.eventId) eventIds.add(after.eventId);

  await Promise.all(
    Array.from(eventIds).map((eventId) =>
      refreshEventSuccessScorecard(eventId, deps)
    )
  );

  if (after) {
    await Promise.all([
      recordParticipantSignalFactsBestEffort(deps.firestore(), [
        buildFeedbackSignalFact(feedbackId, after),
      ]),
      writeEventSafetyReportIfNeeded(feedbackId, after, deps),
    ]);
  }
}

export const onEventSuccessFeedbackWritten = onDocumentWritten(
  "eventSuccessFeedback/{feedbackId}",
  async (event) => {
    const feedbackId = event.params.feedbackId;
    const before = event.data?.before.data() as
      | EventSuccessFeedbackDocument
      | undefined;
    const after = event.data?.after.data() as
      | EventSuccessFeedbackDocument
      | undefined;
    await onEventSuccessFeedbackWrittenHandler(feedbackId, before, after);
  }
);

/**
 * Computes an average while ignoring missing/zero ratings.
 * @param {number[]} values Rating values.
 * @return {number} Average rating, or zero when there are no valid ratings.
 */
/**
 * Computes the average of positive finite ratings.
 * @param {number[]} values Raw rating values.
 * @return {number} Average rating, or zero when no rating exists.
 */
function average(values: number[]): number {
  const valid = values.filter((value) => Number.isFinite(value) && value > 0);
  if (valid.length === 0) return 0;
  return valid.reduce((sum, value) => sum + value, 0) / valid.length;
}

/**
 * Materializes a Catch-private safety review item for event feedback concerns.
 * @param {string} feedbackId Feedback document id.
 * @param {EventSuccessFeedbackDocument} feedback Feedback document.
 * @param {EventSuccessScorecardDeps} deps Injectable Firebase dependencies.
 */
export async function writeEventSafetyReportIfNeeded(
  feedbackId: string,
  feedback: EventSuccessFeedbackDocument,
  deps: EventSuccessScorecardDeps
): Promise<void> {
  if (feedback.safetyConcern !== true) return;

  const note = feedback.privateNote?.trim();
  await deps.firestore()
    .collection(eventSafetyReportsCollection)
    .doc(feedbackId)
    .set({
      eventId: feedback.eventId,
      clubId: feedback.clubId,
      reporterUserId: feedback.uid,
      feedbackId,
      source: "event_success_feedback",
      status: "open",
      createdAt: feedback.createdAt ?? deps.serverTimestamp(),
      updatedAt: deps.serverTimestamp(),
      ...(note && {note}),
    }, {merge: true});
}
