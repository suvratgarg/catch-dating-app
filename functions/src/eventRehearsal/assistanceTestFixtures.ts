import {Timestamp} from "firebase-admin/firestore";
import type {EventRehearsalDocument as Session} from
  "../shared/generated/firestoreAdminTypes";
import type {PracticePlan} from "./assistanceRuntime";

export function practiceSession(now = Date.now()): Session {
  const time = Timestamp.fromMillis(now);
  return {organizerId: "organizer-1", clubId: "organizer-1", ownerUid: "host-1",
    sourceEventId: null, sourceEventRevision: null,
    publicRehearsalId: "practicepublic1234567890",
    viewerTokenHash: "a".repeat(64),
    scenarioId: "lateAndNoShow", seed: 1, actorCount: 2, actionCount: 0,
    status: "running", setup: {title: "Practice",
      locationName: "Practice venue",
      durationMinutes: 120, hostGoal: "Learn", attendeePrompt: "Say hello",
      moduleIds: ["arrival"]}, setupRevision: 0, runtimeRevision: 1,
    activeStepIndex: 1, virtualStartedAt: time, virtualNow: time,
    faultId: "none", faultConsumed: false, createdAt: time, updatedAt: time,
    expiresAt: Timestamp.fromMillis(now + 86400000), completedAt: null};
}
export function practicePlan(now: number): PracticePlan {
  return {policy: {destination: {kind: "fixedPlace", placeId: "venue",
    lateEntry: "allowed"}, cutoff: {kind: "eventEnd"}, maxMessagesPerEpisode: 4,
  minimumMinutesBetweenMessages: 5, updateOn: "materialGuidanceChange",
  unanswered: "keepUnknownUntilCutoff"}, guidance: {revision: 1,
    destination: {kind: "fixedPlace", placeId: "venue", lateEntry: "allowed"},
    materialKey: "venue-1", text: "Meet us at the practice venue.",
    validUntil: now + 7200000}, departureConfirmed: true,
  responseDeadline: null, routes: ["organizerEventWhatsapp", "catchEventSms"],
  deliveryPolicy: {maxAttempts: 3, maxAttemptsPerRoute: 2,
    minimumRetrySeconds: 1}};
}
