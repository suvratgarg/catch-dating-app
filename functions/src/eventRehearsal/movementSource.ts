import {HttpsError} from "firebase-functions/v2/https";
import type {EventRehearsalDocument as Session,
  EventRehearsalActorDocument as Actor} from
  "../shared/generated/firestoreAdminTypes";
import type {EventRehearsalMovementCallableResponse as Review} from
  "../shared/generated/eventRehearsalMovementCallableResponse";
import type {EventRehearsalMovementDocument as Movement} from
  "../shared/generated/eventRehearsalMovementDocument";
import {operationContentHash as hash} from "../operations/durableActions";
import {timestampEvidence, invalidSource} from
  "../eventSuccess/operations/groupProgressSource";
import {practiceContext} from "./assistanceIdentity";
import {practiceMembershipSource, practiceMembershipEpisode} from
  "./membershipSource";
import {validPracticeParticipation} from "./participation";
import {practiceAttendance, validPracticeVisit} from "./visitState";

export type {Review, Movement};
type Candidate = Review["roster"]["members"][number];

export function practiceMovementSource(sessionId: string, session: Session,
  groupId: string) {
  const context = practiceContext(session, {sessionId});
  const movement = session.setup.movementSimulation;
  const route = movement?.routePlan;
  const itinerary = movement?.itinerary ?? [];
  const groups = [{groupId: "event:whole", label: "Whole event"},
    ...(route?.groupStrategy === "paceGroups" ?
      (route.paceGroups ?? []).map((g) => ({groupId: g.id, label: g.label})) :
      [])];
  if (new Set(groups.map((g) => g.groupId)).size !== groups.length ||
      new Set(itinerary.map((s) => s.id)).size !== itinerary.length) {
    throw invalidSource();
  }
  if (!groups.some((g) => g.groupId === groupId)) {
    throw new HttpsError("failed-precondition",
      "This group is not configured.");
  }
  const destinations: Review["progress"]["destinations"] = [];
  if (groupId === "event:whole" && session.setup.locationName.trim()) {
    destinations.push({target: {kind: "fixedPlace", placeId: "meeting",
      lateEntry: "allowed"}, label: session.setup.locationName,
    text: "Join us at " + session.setup.locationName + "."});
  }
  for (const stop of itinerary) {
    if (!stop.location) continue;
    const target = groupId === "event:whole" &&
      route?.groupStrategy !== "paceGroups" ?
      {kind: "itineraryStop" as const,
        itineraryId: context.virtualEventId + ":itinerary", stopId: stop.id} :
      groupId !== "event:whole" && route?.path && route.path.length >= 2 ?
        {kind: "groupCheckpoint" as const,
          routeId: context.virtualEventId + ":route", groupId,
          checkpointId: stop.id} : null;
    if (target) {
      destinations.push({target, label: stop.title,
        text: ["Join us at " + stop.location.name + ".", stop.location.address,
          stop.location.notes].filter(Boolean).join("\n")});
    }
  }
  const now = session.virtualNow.toMillis();
  const endAt = session.virtualStartedAt.toMillis() +
    session.setup.durationMinutes * 60000;
  return {sessionId, context, groupId, groups, destinations, now, endAt,
    startAt: session.virtualStartedAt.toMillis(),
    sourceHash: hash([context, groupId, session.setup.locationName,
      itinerary, route ?? null, session.setup.durationMinutes]),
    eventOpen: ["running", "paused"].includes(session.status) && now < endAt,
    runtimeLive: ["running", "paused"].includes(session.status)};
}
export type MovementSource = ReturnType<typeof practiceMovementSource>;

export function practiceDepartureVisitHash(actor: Actor) {
  return hash([actor.sessionId, actor.actorId,
    timestampEvidence(actor.createdAt),
    actor.visit?.attendanceRevision, actor.visit?.checkedInAtMillis]);
}

/** Complete synthetic roster coverage; a candidate is never an observation. */
export function practiceDepartureRoster(session: Session,
  source: MovementSource, actors: readonly Actor[], revision: number):
  Review["roster"] {
  if (actors.length !== session.actorCount || actors.length > 50 ||
      new Set(actors.map((a) => a.actorId)).size !== actors.length ||
      actors.some((a) => a.sessionId !== source.sessionId)) {
    throw new HttpsError("failed-precondition", "Practice roster changed.");
  }
  const members: Candidate[] = [];
  const unavailable: Review["roster"]["unavailable"] = [];
  for (const actor of [...actors].sort((a, b) =>
    a.actorId.localeCompare(b.actorId))) {
    const candidate = departureCandidate(session, source, actor);
    if (typeof candidate === "string") {
      unavailable.push({attendeeId: actor.actorId, reason: candidate});
    } else members.push(candidate);
  }
  return {members, unavailable, coverage: "boundedSession",
    sourceHash: hash([source.context, source.groupId, source.sourceHash,
      revision, members, unavailable])};
}

function departureCandidate(session: Session, source: MovementSource,
  actor: Actor): Candidate | Review["roster"]["unavailable"][number]["reason"] {
  if (!actor.visit || !validPracticeVisit(actor.visit,
    session.virtualStartedAt.toMillis(), source.now)) return "invalidSource";
  if (practiceAttendance(actor) !== "checkedIn" ||
      actor.visit.checkedInAtMillis === null) return "notCheckedIn";
  if (!validPracticeParticipation(actor) ||
      actor.participation!.state !== "active") {
    return "participationUnavailable";
  }
  let membershipHash: string | null = null;
  if (source.groupId !== "event:whole") {
    try {
      const s = practiceMembershipSource(session, actor);
      if (!s.current || s.membership?.accepted?.groupId !== source.groupId) {
        return "membershipUnavailable";
      }
      membershipHash = hash([s.membership.revision, s.membership.accepted]);
    } catch (error) {
      if (!(error instanceof HttpsError)) throw error;
      return "invalidSource";
    }
  }
  return {attendeeId: actor.actorId, displayName: actor.displayName,
    visitHash: practiceDepartureVisitHash(actor),
    episodeId: practiceMembershipEpisode(session, actor), membershipHash};
}

/** Changed visits stay in the denominator without new arrival proof. */
export function practiceCheckpointVisits(session: Session,
  source: MovementSource, record: Movement, actors: readonly Actor[]) {
  return (record.departure.roster?.members ?? []).map((member) => {
    const actor = actors.find((a) => a.actorId === member.attendeeId);
    let reason: "registrationMissing" | "invalidSource" | "notCheckedIn" |
      "visitChanged" | null = null;
    if (!actor) reason = "registrationMissing";
    else if (!actor.visit || !validPracticeVisit(actor.visit,
      session.virtualStartedAt.toMillis(), source.now)) {
      reason = "invalidSource";
    } else if (practiceAttendance(actor) !== "checkedIn") {
      reason = "notCheckedIn";
    } else if (practiceDepartureVisitHash(actor) !== member.visitHash) {
      reason = "visitChanged";
    }
    return {attendeeId: member.attendeeId,
      visit: reason ? {kind: "unavailable" as const, reason} :
        {kind: "current" as const},
      observation: record.report?.accountedFor.includes(member.attendeeId) ?
        "accountedFor" as const : "unconfirmed" as const};
  });
}
