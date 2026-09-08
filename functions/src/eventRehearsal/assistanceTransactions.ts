import type {Firestore, Transaction} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import type {EventRehearsalDocument as Session,
  EventRehearsalActorDocument as Actor} from
  "../shared/generated/firestoreAdminTypes";
import type {ControlEventRehearsalCallablePayload} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import {MAX_LATE_JOIN_HISTORY} from
  "../eventSuccess/operations/lateJoinHistoryProjection";
import {dispatchRehearsalMessage, recordRehearsalMessageOutcome,
  respondToRehearsalMessage} from "./assistanceMessages";
import {practiceContext, practiceEpisode, practiceFacts,
  practiceMessageDocumentId, practiceState, publishPracticeMessage,
  readPracticeMessage, rehearsalMessages, PracticeMessage} from
  "./assistanceRuntime";

export type PracticeCommand = NonNullable<
  ControlEventRehearsalCallablePayload["assistance"]>;

async function readHistory(db: Firestore, tx: Transaction, session: Session,
  actor: Actor): Promise<PracticeMessage[]> {
  const snapshots = await tx.get(db.collection(rehearsalMessages)
    .where("sessionId", "==", actor.sessionId)
    .where("actorId", "==", actor.actorId)
    .where("record.intent.context.clockId", "==",
      practiceContext(session, actor).clockId)
    .limit(MAX_LATE_JOIN_HISTORY + 1));
  if (snapshots.size > MAX_LATE_JOIN_HISTORY) {
    throw new HttpsError("resource-exhausted",
      "Reset this practice message history.");
  }
  return snapshots.docs.map((snap) => {
    const value = readPracticeMessage(snap.data(), session, actor);
    if (snap.id !== practiceMessageDocumentId(actor.sessionId,
      value.record.messageId)) {
      throw new HttpsError("failed-precondition",
        "Practice message identity changed.");
    }
    return value;
  });
}

/** Called before any writes in the existing Host rehearsal transaction. */
export async function applyPracticeHostCommand(db: Firestore, tx: Transaction,
  session: Session, actor: Actor, command: PracticeCommand): Promise<Actor> {
  if (command.actorId !== actor.actorId ||
      (!(["running", "paused"].includes(session.status)) &&
        !(command.kind === "receipt" && session.status === "complete"))) {
    throw new HttpsError("failed-precondition",
      "Practice command is unavailable.");
  }
  const history = await readHistory(db, tx, session, actor);
  if (command.kind === "publish") {
    const next = publishPracticeMessage(session, actor, command.plan, history);
    const ref = db.collection(rehearsalMessages).doc(
      practiceMessageDocumentId(actor.sessionId,
        next.message.record.messageId));
    if (!next.exists) tx.create(ref, next.message);
    return next.actor;
  }
  const message = history.find((m) => m.record.messageId === command.messageId);
  if (!message) {
    throw new HttpsError("not-found",
      "Practice message not found.");
  }
  const context = practiceContext(session, actor);
  const now = session.virtualNow.toMillis();
  const result = command.kind === "dispatch" ? dispatchRehearsalMessage({
    context, record: message.record, now, outcome: command.outcome,
    facts: practiceFacts(session, actor, message, history)}) :
    recordRehearsalMessageOutcome({context, record: message.record,
      now, attemptId: command.attemptId, outcome: command.outcome});
  const next = {...message, record: result.record};
  readPracticeMessage(next, session, actor);
  tx.set(db.collection(rehearsalMessages).doc(
    practiceMessageDocumentId(actor.sessionId, next.record.messageId)), next);
  return actor;
}

/**
 * The parent authenticates the anonymous slot and commits the returned actor.
 */
export async function applyPracticeGuestReply(db: Firestore, tx: Transaction,
  session: Session, actor: Actor, submission: {
    messageId: string; intentRevision: number; choiceId: string;
    requestId: string; actionId: string;
  }): Promise<Actor> {
  const history = await readHistory(db, tx, session, actor);
  const message = history.find((m) =>
    m.record.messageId === submission.messageId);
  if (!message) {
    throw new HttpsError("not-found",
      "Practice message not found.");
  }
  const context = practiceContext(session, actor);
  const result = respondToRehearsalMessage({context, record: message.record,
    now: session.virtualNow.toMillis(),
    scope: {context, eventId: context.virtualEventId, attendeeId: actor.actorId,
      episodeId: practiceEpisode(session, actor),
      validUntil: session.virtualStartedAt.toMillis() +
        session.setup.durationMinutes * 60000,
      source: {kind: "simulation", actionId: submission.actionId}},
    submission: {intentId: message.record.intent.intentId,
      intentRevision: submission.intentRevision, choiceId: submission.choiceId,
      requestId: submission.requestId},
    gate: practiceFacts(session, actor, message, history, true).gate});
  if (result.result.kind === "rejected") {
    throw new HttpsError("failed-precondition",
      "Practice response rejected: " + result.result.reason);
  }
  const effect = result.result.response.value;
  if (effect.kind !== "joinIntent" && effect.kind !== "requestHelp") {
    throw new HttpsError("failed-precondition",
      "Unsupported practice response.");
  }
  tx.set(db.collection(rehearsalMessages).doc(
    practiceMessageDocumentId(actor.sessionId, message.record.messageId)),
  {...message, record: result.record});
  return {...actor, assistance: {...practiceState(actor),
    intention: effect.kind === "joinIntent" ? effect.intention :
      practiceState(actor).intention},
  helpRequested: actor.helpRequested || effect.kind === "requestHelp"};
}
