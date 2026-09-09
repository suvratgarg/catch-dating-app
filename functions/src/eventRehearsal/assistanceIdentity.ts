import type {EventRehearsalDocument as Session,
  EventRehearsalActorDocument as Actor} from
  "../shared/generated/firestoreAdminTypes";
import {operationContentHash as hash} from "../operations/durableActions";

export const practiceState = (actor: Actor): NonNullable<Actor["assistance"]> =>
  actor.assistance ?? {intention: {kind: "unknown"}, latestMessageId: null};

export function practiceContext(session: Session,
  actor: Pick<Actor, "sessionId">) {
  return {mode: "rehearsal" as const, rehearsalId: actor.sessionId,
    virtualEventId: "practice:" + hash(actor.sessionId),
    clockId: "clock:" + hash([actor.sessionId,
      session.virtualStartedAt.toMillis(), session.setupRevision])};
}
export function practiceEpisode(session: Session, actor: Actor) {
  return "episode:" + hash([practiceContext(session, actor), actor.actorId]);
}
