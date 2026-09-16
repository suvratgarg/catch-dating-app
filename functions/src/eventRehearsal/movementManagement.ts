import {HttpsError} from "firebase-functions/v2/https";
import {practiceIsManager, practiceGroupPermission} from "./groupStaff";
import type {EventRehearsalDocument as Session} from
  "../shared/generated/firestoreAdminTypes";
import {prepareCheckpointReassignment, prepareCheckpointCloseout,
  currentCheckpointCloseout} from
  "../eventSuccess/operations/checkpointManagementDecisions";
import type {ControlEventRehearsalCallablePayload as Control} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import type {Movement, MovementSource, Review} from "./movementSource";
import type {PracticeCaseAuthority} from "./assistanceCases";

type Command = Extract<NonNullable<Control["movement"]>,
  {kind: "reassignCheckpointReporter" | "setCheckpointCloseout"}>;

/** Parent action receipts bind the exact command; no live work is created. */
export function preparePracticeCheckpointManagement(record: Movement,
  checkpoint: NonNullable<Review["checkpoint"]>, source: MovementSource,
  command: Command, authority: PracticeCaseAuthority, operationId: string,
  session: Session
): Pick<Movement, "assignment" | "closeout"> {
  if (!checkpoint.assignment || !checkpoint.closeout || !checkpoint.request) {
    throw new HttpsError("failed-precondition",
      "This departure has no checkpoint request.");
  }
  if (command.kind === "reassignCheckpointReporter") {
    if (!practiceIsManager(authority)) {
      throw new HttpsError("permission-denied",
        "Only the rehearsal Host can reassign checkpoint responsibility.");
    }
    prepareCheckpointReassignment({...checkpoint,
      assignment: checkpoint.assignment}, command.payload,
    command.expectedSourceHash);
    const until = practiceGroupPermission(source.sessionId, session, authority,
      source.groupId, "recordCheckpoint",
      command.payload.responsibleOperatorId);
    if (until === null || until <= Math.max(source.now,
      checkpoint.request.dueAt)) {
      throw new HttpsError("permission-denied",
        "Choose a practice operator whose duty covers the original deadline.");
    }
    return {assignment: {revision: checkpoint.assignment.revision + 1,
      operationId, assignedBy: authority.actorUid, assignedAt: source.now,
      reason: command.payload.reason.trim(),
      responsibleOperatorId: command.payload.responsibleOperatorId,
      previousResponsibleOperatorId: checkpoint.request.responsibleOperatorId}};
  }
  if (!practiceIsManager(authority) &&
      checkpoint.request.responsibleOperatorId !== authority.actorUid) {
    throw new HttpsError("permission-denied",
      "Only the assigned reporter or rehearsal Host can close this request.");
  }
  prepareCheckpointCloseout({request: checkpoint.request,
    closeout: checkpoint.closeout}, command.payload,
  command.expectedSourceHash);
  const decision = command.payload.decision === "reopen" ?
    {kind: "reopen" as const} : currentCheckpointCloseout({
      report: record.report,
      availability: checkpoint.availability,
      rosterIds: record.departure.roster!.members.map((m) => m.attendeeId)});
  if (!decision) {
    throw new HttpsError("aborted", "Checkpoint evidence changed.");
  }
  return {closeout: {revision: checkpoint.closeout.revision + 1,
    previousRevision: checkpoint.closeout.revision,
    operationId, changedBy: authority.actorUid, changedAt: source.now,
    reason: command.payload.reason.trim(), decision}};
}
