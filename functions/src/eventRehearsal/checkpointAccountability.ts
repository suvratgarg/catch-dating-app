import {HttpsError} from "firebase-functions/v2/https";
import type {EventRehearsalDocument as Session,
  EventRehearsalActorDocument as Actor} from
  "../shared/generated/firestoreAdminTypes";
import type {ControlEventRehearsalCallablePayload as Control} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import {operationContentHash as hash} from "../operations/durableActions";
import {practiceVisitEvidence, applyPracticeVisitDisposition} from
  "./accountability";
import {practiceGroupPermission} from "./groupStaff";
import {practiceDepartureVisitHash} from "./movementSource";
import type {Movement, MovementSource, Review} from "./movementSource";
import type {PracticeCaseAuthority} from "./assistanceCases";

type Checkpoint = NonNullable<Review["checkpoint"]>;
type Row = NonNullable<Checkpoint["accountabilityReviews"]>[number];
type Command = Extract<NonNullable<Control["movement"]>,
  {kind: "resolveAccountability"}>;

/** Choices retain the original departure visit after transfers. */
export function practiceCheckpointAccountability(session: Session,
  source: MovementSource, record: Movement, actors: readonly Actor[],
  availability: Checkpoint["availability"], authority: PracticeCaseAuthority
): Row[] {
  const permission = practiceGroupPermission(source.sessionId, session,
    authority, source.groupId, "resolveAccountability") !== null;
  return (record.departure.roster?.members ?? []).map((member) => {
    const actor = actors.find((a) => a.actorId === member.attendeeId);
    const current = actor ? practiceVisitEvidence(session, actor) : null;
    const currentVisitHash = actor?.visit ?
      practiceDepartureVisitHash(actor) : null;
    const visit = availability.kind === "ready" ?
      availability.members.find((m) => m.attendeeId === member.attendeeId) :
      null;
    const reason = availability.kind !== "ready" ? "setupChanged" :
      !actor || !visit || currentVisitHash !== member.visitHash ?
        "visitChanged" :
        visit.visit.kind !== "current" ?
          visit.visit.reason === "notCheckedIn" ? "notCheckedIn" :
            "visitChanged" :
          current?.availability.kind !== "ready" ? "notApplicable" : null;
    return {attendeeId: member.attendeeId, visitHash: member.visitHash,
      revision: current?.revision ?? 0,
      disposition: reason ? "unresolved" : current!.disposition,
      availability: reason ? {kind: "unavailable", reason} : {kind: "ready"},
      sourceHash: hash([source.context, source.groupId, record.progressRevision,
        source.sourceHash, record.departure, member.attendeeId,
        currentVisitHash,
        current?.sourceHash ?? null, authority.actorUid]),
      canResolve: reason === null && permission && current!.canResolve &&
        session.runtimeRevision < 2147483647};
  });
}

/** Visit outcomes create no arrival observation or message. */
export function preparePracticeCheckpointVisit(session: Session,
  checkpoint: Checkpoint, actors: readonly Actor[], command: Command,
  authority: PracticeCaseAuthority): Actor {
  const row = checkpoint.accountabilityReviews?.find((r) =>
    r.attendeeId === command.payload.attendeeId);
  if (!row || row.sourceHash !== command.expectedSourceHash ||
      row.revision !== command.payload.expectedAccountabilityRevision) {
    throw new HttpsError("aborted",
      "Review the original departure visit again.");
  }
  if (!row.canResolve) {
    throw new HttpsError("failed-precondition",
      "This original departure visit cannot be changed.");
  }
  const actor = actors.find((a) => a.actorId === row.attendeeId)!;
  return applyPracticeVisitDisposition(session, actor,
    command.payload.disposition, authority.actorUid);
}
