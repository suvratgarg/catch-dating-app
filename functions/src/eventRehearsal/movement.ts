import {practiceCheckpointReview} from "./movementCheckpoint";
import {preparePracticeCheckpointManagement} from "./movementManagement";
import {HttpsError} from "firebase-functions/v2/https";
import type {Firestore, Transaction} from "firebase-admin/firestore";
import type {EventRehearsalDocument as Session,
  EventRehearsalActorDocument as Actor} from
  "../shared/generated/firestoreAdminTypes";
import type {ControlEventRehearsalCallablePayload as Control} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import {operationContentHash as hash} from "../operations/durableActions";
import {requirePracticeGroupPermission, practiceGroupPermission,
  practiceStaffProjection} from "./groupStaff";
import {prepareDepartureDecision, prepareCheckpointObservation,
  departureConflict} from "../eventSuccess/operations/movementDecisions";
import {assertCheckpointRequestDeadline} from
  "../eventSuccess/operations/checkpointRequest";
import {practiceMovementSource, practiceDepartureRoster,
  MovementSource, Review} from
  "./movementSource";
import {readPracticeMovements, parsePracticeMovement, practiceMovementId,
  rehearsalMovements, MovementScope, MovementRecords} from "./movementRecords";
import type {PracticeCaseAuthority} from "./assistanceCases";

type Command = NonNullable<Control["movement"]>;

export function practiceMovementScope(command: Command): MovementScope {
  return {groupId: command.payload.groupId, progressRevision:
    command.payload.expectedProgressRevision +
      (command.kind === "confirmDeparture" ? 1 : 0)};
}

export async function practiceMovementReview(db: Firestore, tx: Transaction,
  sessionId: string, session: Session, actors: readonly Actor[],
  scope: MovementScope, authority: PracticeCaseAuthority): Promise<Review> {
  requirePracticeGroupPermission(sessionId, session, authority,
    scope.groupId, "readProgress");
  const source = practiceMovementSource(sessionId, session, scope.groupId);
  const records = await readPracticeMovements(db, tx, source, scope);
  return projectMovement(session, source, actors, records, authority);
}

function projectMovement(session: Session, source: MovementSource,
  actors: readonly Actor[], records: MovementRecords,
  authority: PracticeCaseAuthority): Review {
  const {current, selected} = records;
  const revision = current?.progressRevision ?? 0;
  const destination = current && current.departure.sourceHash ===
    source.sourceHash ? source.destinations.find((d) =>
      hash(d.target) === hash(current.departure.destination)) : null;
  return {sessionId: source.sessionId, organizerId: session.organizerId,
    clockId: source.context.clockId, setupRevision: session.setupRevision,
    runtimeRevision: session.runtimeRevision, actorUid: authority.actorUid,
    serverTime: source.now, groupId: source.groupId, groups: source.groups,
    staffReview: practiceStaffProjection(source.sessionId, session, authority),
    progress: {revision, sourceHash: source.sourceHash,
      eventOpen: source.eventOpen, runtimeLive: source.runtimeLive,
      destinations: source.destinations, current,
      guidance: destination && source.eventOpen && source.runtimeLive ?
        {revision, destination: destination.target,
          materialKey: hash([source.sourceHash, destination.target]),
          text: destination.text, validUntil: source.endAt} : null},
    roster: practiceDepartureRoster(session, source, actors, revision),
    selected,
    checkpoint: selected ? practiceCheckpointReview(session, source, selected,
      actors,
      authority) : null,
    history: records.page.map((record) => ({
      progressRevision: record.progressRevision,
      destination: record.departure.destination,
      confirmedAt: record.departure.confirmedAt,
      rosterSize: record.departure.roster?.members.length ?? null,
      reportRevision: record.report?.revision ?? 0,
      accountedForCount: record.report?.accountedFor.length ?? 0,
      checkpointRequest: record.departure.checkpointRequest})),
    nextBeforeRevision: records.nextBeforeRevision};
}

/** The parent owns generation, runtime revision, capacity and receipts. */
export async function preparePracticeMovementCommand(db: Firestore,
  tx: Transaction, sessionId: string, session: Session,
  actors: readonly Actor[],
  command: Command, authority: PracticeCaseAuthority, operationId: string) {
  requirePracticeGroupPermission(sessionId, session, authority,
    command.payload.groupId, command.kind === "confirmDeparture" ?
      "confirmDeparture" : "recordCheckpoint");
  if (!["running", "paused", "complete"].includes(session.status) ||
      session.actionCount >= 500 || session.runtimeRevision >= 2147483647) {
    throw new HttpsError("failed-precondition", "Practice movement is closed.");
  }
  const source = practiceMovementSource(sessionId, session,
    command.payload.groupId);
  const scope = command.kind !== "confirmDeparture" ?
    practiceMovementScope(command) : {groupId: command.payload.groupId};
  const records = await readPracticeMovements(db, tx, source, scope);
  const review = projectMovement(session, source, actors, records, authority);
  if (command.kind === "confirmDeparture") {
    const {target, selection, checkpointRequest} = prepareDepartureDecision(
      review.progress, command.payload, command.expectedSourceHash);
    if (selection && (review.roster.coverage !== "boundedSession" ||
        selection.expectedSourceHash !== review.roster.sourceHash)) {
      throw departureConflict();
    }
    const members = selection ? [...selection.attendeeIds].sort().map((id) => {
      const member = review.roster.members.find((m) => m.attendeeId === id);
      if (!member) {
        throw new HttpsError("failed-precondition",
          "Every selected guest needs a current visit and group membership.");
      }
      return member;
    }) : null;
    if (checkpointRequest) {
      const until = practiceGroupPermission(sessionId, session, authority,
        source.groupId, "recordCheckpoint",
        checkpointRequest.responsibleOperatorId);
      if (until === null) {
        throw new HttpsError("permission-denied",
          "Choose a practice operator with a current checkpoint duty.");
      }
      assertCheckpointRequestDeadline(checkpointRequest,
        until, source.now, source.endAt);
    }
    const progressRevision = review.progress.revision + 1;
    const value = parsePracticeMovement({sessionId,
      clockId: source.context.clockId, groupId: source.groupId,
      progressRevision, departure: {sourceHash: source.sourceHash,
        destination: target.target, confirmedBy: authority.actorUid,
        confirmedAt: source.now, operationId,
        roster: members ? {members, selectionHash: review.roster.sourceHash} :
          null, checkpointRequest: checkpointRequest ?? null}, report: null},
    source);
    return {confirmedDeparture: value, commit: () => tx.create(
      db.collection(rehearsalMovements).doc(
        practiceMovementId(source, progressRevision)), value)};
  }
  const record = records.selected;
  const checkpoint = review.checkpoint;
  if (!record || !checkpoint ||
      checkpoint.checkpointId !== command.payload.checkpointId) {
    throw new HttpsError("failed-precondition",
      "Choose a saved checkpoint.");
  }
  let updates: Partial<Pick<MovementRecords["page"][number],
    "report" | "assignment" | "closeout">>;
  if (command.kind === "recordCheckpoint") {
    const change = prepareCheckpointObservation({...checkpoint,
      previouslyAccountedFor: record.report?.accountedFor ?? []},
    command.payload, command.expectedSourceHash);
    updates = {report: {revision: checkpoint.revision + 1,
      rosterHash: hash(record.departure), ...change,
      reportedBy: authority.actorUid, reportedAt: source.now}};
  } else {
    updates = preparePracticeCheckpointManagement(record, checkpoint,
      source, command, authority, operationId, session);
  }
  parsePracticeMovement({...record, ...updates}, source);
  return {confirmedDeparture: null, commit: () => tx.update(
    db.collection(rehearsalMovements).doc(
      practiceMovementId(source, record.progressRevision)), updates)};
}
