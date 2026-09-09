import {operationContentHash as hash} from "../operations/durableActions";
import {isOrganizerManager} from "../shared/organizerHosts";
import {checkpointCloseoutDecisionState, checkpointCloseoutEligibility} from
  "../eventSuccess/operations/checkpointManagementDecisions";
import type {EventRehearsalDocument as Session,
  EventRehearsalActorDocument as Actor} from
  "../shared/generated/firestoreAdminTypes";
import {practiceAccountabilityView} from "./accountability";
import {practiceCheckpointVisits, MovementSource, Movement, Review} from
  "./movementSource";
import {practiceMovementId} from "./movementRecords";
import type {PracticeCaseAuthority} from "./assistanceCases";

type Checkpoint = NonNullable<Review["checkpoint"]>;
type Ready = Extract<Checkpoint["availability"], {kind: "ready"}>;
type Member = Ready["members"][number];

/** Resolution is scoped to the original physical visit and departure. */
function disposition(session: Session, source: MovementSource, record: Movement,
  member: Member, actors: readonly Actor[]
): NonNullable<Member["disposition"]> {
  if (member.visit.kind !== "current") return member.visit;
  const actor = actors.find((a) => a.actorId === member.attendeeId)!;
  const review = practiceAccountabilityView(session, actor);
  if (review.disposition === "unresolved") return {kind: "unresolved"};
  const resolution = actor.visit!.resolution!;
  if (resolution.resolvedAtMillis < record.departure.confirmedAt) {
    return {kind: "unavailable", reason: "beforeDeparture"};
  }
  return {kind: "resolved", disposition: review.disposition,
    revision: review.revision, resolvedAt: resolution.resolvedAtMillis,
    resolvedBy: resolution.resolvedBy,
    sourceHash: hash([source.context, source.groupId, record.progressRevision,
      record.departure, member.attendeeId, review.sourceHash, resolution])};
}

export function practiceCheckpointReview(session: Session,
  source: MovementSource, record: Movement, actors: readonly Actor[],
  authority: PracticeCaseAuthority): Checkpoint | null {
  const {departure, report} = record;
  const target = departure.destination;
  const checkpointId = target.kind === "itineraryStop" ? target.stopId :
    target.kind === "groupCheckpoint" ? target.checkpointId : null;
  if (checkpointId === null) return null;
  const visits = practiceCheckpointVisits(session, source, record, actors);
  const destination = source.destinations.find((d) =>
    hash(d.target) === hash(target));
  const availability: Checkpoint["availability"] =
    !departure.roster ? {kind: "unavailable", reason: "rosterNotRecorded"} :
      departure.sourceHash !== source.sourceHash || !destination ?
        {kind: "unavailable", reason: "setupChanged"} :
        {kind: "ready", rosterId: practiceMovementId(source,
          record.progressRevision), label: destination.label,
        reportStatus: !report ? "unreported" :
          report.accountedFor.length === departure.roster.members.length ?
            "complete" : "partial", members: visits.map((member) => ({...member,
          disposition: disposition(session, source, record, member, actors)}))};
  // Keep the existing arrival-review hash stable across management decisions.
  const sourceHash = hash([source.context, source.groupId, source.sourceHash,
    {sessionId: record.sessionId, clockId: record.clockId,
      groupId: record.groupId, progressRevision: record.progressRevision,
      departure, report}, visits]);
  const original = departure.checkpointRequest;
  const assignment = !original ? null : {
    revision: record.assignment?.revision ?? 0,
    change: record.assignment ?? null,
    sourceHash: hash([sourceHash, original, record.assignment ?? null])};
  const evidence = {availability, report,
    rosterIds: departure.roster?.members.map((m) => m.attendeeId) ?? []};
  const state = checkpointCloseoutDecisionState(evidence,
    record.closeout?.decision ?? null);
  const closeout = !original ? null : {
    revision: record.closeout?.revision ?? 0,
    change: record.closeout ?? null, state,
    eligibility: checkpointCloseoutEligibility(evidence, state),
    sourceHash: hash([sourceHash, availability, original,
      record.assignment ?? null, record.closeout ?? null])};
  const request = original ? {...original, responsibleOperatorId:
    record.assignment?.responsibleOperatorId ??
      original.responsibleOperatorId} :
    null;
  const complete = !!report &&
    report.accountedFor.length === departure.roster?.members.length;
  return {progressRevision: record.progressRevision, checkpointId, sourceHash,
    revision: report?.revision ?? 0, report, availability, departure,
    assignment, closeout,
    request: !request ? null : complete ? {...request, state: "complete",
      ownerAvailability: "notRequired"} : state.kind === "closedOut" ?
      {...request, state: "closedOut", ownerAvailability: "notRequired"} :
      {...request, state: availability.kind !== "ready" ? "sourceUnavailable" :
        report ? "discrepancy" : source.now >= request.dueAt ? "overdue" :
          "awaitingReport", ownerAvailability: isOrganizerManager(
        authority.organizer, request.responsibleOperatorId) ?
        "current" : "needsReassignment"}};
}
