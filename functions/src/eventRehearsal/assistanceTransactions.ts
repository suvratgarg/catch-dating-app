import type {Firestore, Transaction} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import type {EventRehearsalDocument as Session,
  EventRehearsalActorDocument as Actor} from
  "../shared/generated/firestoreAdminTypes";
import type {ControlEventRehearsalCallablePayload} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import {operationContentHash as hash} from "../operations/durableActions";
import {MAX_LATE_JOIN_HISTORY} from
  "../eventSuccess/operations/lateJoinHistoryProjection";
import {recordRehearsalMessageOutcome,
  respondToRehearsalMessage} from "./assistanceMessages";
import {practiceContext, practiceEpisode, practiceFacts,
  practiceMessageDocumentId, practiceState, publishPracticeMessage,
  readPracticeMessage, rehearsalMessages, PracticeMessage,
  PracticeHistoryUnavailable, dispatchPracticeMessage} from
  "./assistanceRuntime";
import {configurePracticeAutomation, evaluatePracticeAutomation,
  pausePracticeAutomation, unavailablePracticeAutomation,
  PracticeAutomationResult} from "./assistanceAutomation";

import {preparePracticeHelp, resolvePracticeHelp, PracticeCaseAuthority} from
  "./assistanceCases";
import {repairPracticeDelivery} from "./assistanceDelivery";

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
  // Transport errors above remain transaction failures. Invalid stored history
  // below can hold automation without rolling back an independent check-in.
  if (snapshots.size > MAX_LATE_JOIN_HISTORY) {
    throw new PracticeHistoryUnavailable();
  }
  try {
    const history = snapshots.docs.map((snap) => {
      const value = readPracticeMessage(snap.data(), session, actor);
      if (snap.id !== practiceMessageDocumentId(actor.sessionId,
        value.record.messageId)) throw new Error("Practice identity changed");
      return value;
    });
    const currentId = practiceState(actor).latestMessageId;
    if (currentId && !history.some((m) => m.record.messageId === currentId)) {
      throw new Error("Practice history omitted its current message");
    }
    return history;
  } catch {
    throw new PracticeHistoryUnavailable();
  }
}

function persistMessages(db: Firestore, tx: Transaction, session: Session,
  actor: Actor, before: readonly PracticeMessage[],
  after: readonly PracticeMessage[]) {
  const originals = new Map(before.map((m) => [m.record.messageId, m]));
  for (const message of after) {
    readPracticeMessage(message, session, actor);
    const original = originals.get(message.record.messageId);
    if (original && hash(original) === hash(message)) continue;
    const ref = db.collection(rehearsalMessages).doc(
      practiceMessageDocumentId(actor.sessionId, message.record.messageId));
    if (original) tx.set(ref, message);
    else tx.create(ref, message);
  }
}

/** All actor histories are read before any writes in the parent transaction. */
export async function applyPracticeAutomations(db: Firestore, tx: Transaction,
  session: Session, actors: readonly Actor[]): Promise<Actor[]> {
  const changes = await Promise.all(actors.map(async (actor) => {
    if (actor.assistanceAutomation?.status !== "enabled") {
      return {before: [], result: {actor, messages: []}};
    }
    try {
      const before = await readHistory(db, tx, session, actor);
      return {before, result: evaluatePracticeAutomation(session, actor,
        before)};
    } catch (error) {
      if (!(error instanceof PracticeHistoryUnavailable)) throw error;
      return {before: [],
        result: unavailablePracticeAutomation(session, actor)};
    }
  }));
  for (const {before, result} of changes) {
    persistMessages(db, tx, session, result.actor, before, result.messages);
  }
  return changes.map(({result}) => result.actor);
}

/** Called before any writes in the existing Host rehearsal transaction. */
export async function applyPracticeHostCommand(db: Firestore, tx: Transaction,
  session: Session, actor: Actor, command: PracticeCommand,
  authority?: PracticeCaseAuthority & {operationId?: string}): Promise<Actor> {
  if (command.actorId !== actor.actorId ||
      (!(["running", "paused"].includes(session.status)) &&
        !(["receipt", "resolveAssistance"].includes(command.kind) &&
          session.status === "complete"))) {
    throw new HttpsError("failed-precondition",
      "Practice command is unavailable.");
  }
  if (command.kind === "resolveAssistance") {
    if (!authority) {
      throw new HttpsError("permission-denied",
        "Current Host authority is required.");
    }
    return resolvePracticeHelp(db, tx, session, actor, command.payload,
      command.expectedSourceHash, authority);
  }
  if (command.kind === "pauseAutomation") {
    return pausePracticeAutomation(session, actor);
  }
  const history = await readHistory(db, tx, session, actor);
  let next: PracticeAutomationResult;
  if (command.kind === "repairDelivery") {
    if (!authority?.operationId) {
      throw new HttpsError("permission-denied",
        "Current Host authority and operation identity are required.");
    }
    const message = history.find((m) =>
      m.record.messageId === command.payload.deliveryId);
    if (!message) {
      throw new HttpsError("not-found", "Practice message not found.");
    }
    const updated = repairPracticeDelivery(session, actor, message, command,
      authority.organizer, authority.actorUid, authority.operationId);
    next = evaluatePracticeAutomation(session, actor,
      history.map((m) => m === message ? updated : m));
  } else if (command.kind === "configureAutomation") {
    next = configurePracticeAutomation(session, actor, command.plan,
      command.outcomes, history);
  } else if (command.kind === "resumeAutomation") {
    if (!actor.assistanceAutomation) {
      throw new HttpsError("failed-precondition",
        "Configure practice assistance first.");
    }
    const current = history.find((m) => m.record.messageId ===
      practiceState(actor).latestMessageId);
    if (current &&
        hash(current.plan) !== hash(actor.assistanceAutomation.plan)) {
      throw new HttpsError("failed-precondition",
        "Review the practice plan before resuming automation.");
    }
    next = evaluatePracticeAutomation(session, {...actor,
      assistanceAutomation: {...actor.assistanceAutomation,
        status: "enabled"}}, history);
  } else if (command.kind === "publish") {
    const published = publishPracticeMessage(session, actor, command.plan,
      history);
    next = {actor: pausePracticeAutomation(session, published.actor),
      messages: published.exists ? history : [...history, published.message]};
  } else {
    const message = history.find((m) =>
      m.record.messageId === command.messageId);
    if (!message) {
      throw new HttpsError("not-found",
        "Practice message not found.");
    }
    const context = practiceContext(session, actor);
    const now = session.virtualNow.toMillis();
    const result = command.kind === "dispatch" ? dispatchPracticeMessage(
      session, actor, message, history, command.outcome) :
      recordRehearsalMessageOutcome({context, record: message.record,
        now, attemptId: command.attemptId, outcome: command.outcome});
    const messages = history.map((m) => m === message ?
      readPracticeMessage({...message, record: result.record},
        session, actor) : m);
    next = command.kind === "dispatch" ?
      {actor: pausePracticeAutomation(session, actor), messages} :
      evaluatePracticeAutomation(session, actor, messages);
  }
  persistMessages(db, tx, session, next.actor, history, next.messages);
  return next.actor;
}

/** The parent authenticates the guest slot and commits the actor. */
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
  if (effect.kind === "requestHelp" && effect.category === "comfortSafety") {
    throw new HttpsError("failed-precondition",
      "Restricted help needs its separate rehearsal workflow.");
  }
  const changedActor = {...actor, assistance: {...practiceState(actor),
    intention: effect.kind === "joinIntent" ? effect.intention :
      practiceState(actor).intention}};
  const help = effect.kind === "requestHelp" &&
    effect.category !== "comfortSafety" ?
    await preparePracticeHelp(db, tx, session, changedActor,
      {kind: "messageResponse", messageId: message.record.messageId,
        responseId: result.result.response.responseId}, effect.category) :
    null;
  const messages = history.map((m) => m === message ?
    readPracticeMessage({...message, record: result.record},
      session, actor) : m);
  const next = evaluatePracticeAutomation(session,
    help?.actor ?? changedActor, messages);
  persistMessages(db, tx, session, next.actor, history, next.messages);
  help?.commit();
  return next.actor;
}
