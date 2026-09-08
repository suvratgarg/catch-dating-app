import {HttpsError} from "firebase-functions/v2/https";
import type {EventRehearsalDocument as Session,
  EventRehearsalActorDocument as Actor} from
  "../shared/generated/firestoreAdminTypes";
import type {EventRehearsalMessageDocument as PracticeMessage} from
  "../shared/generated/eventRehearsalMessageDocument";
import type {EventAssistanceLateJoinInput as LateJoinInput} from
  "../shared/generated/eventAssistanceLateJoinInput";
import {validateEventRehearsalMessageDocument} from
  "../shared/generated/validators/eventRehearsalMessageDocument";
import {operationContentHash as hash} from "../operations/durableActions";
import {destinationAllowed, evaluateLateJoin, parseLateJoinInput} from
  "../eventSuccess/operations/lateJoin";
import {projectLateJoinMessageHistory} from
  "../eventSuccess/operations/lateJoinHistoryProjection";
import {newMessageRecord, parseMessageRecord, OutboxFacts} from
  "../eventSuccess/operations/messageOutbox";
import {parseMessageIntent} from "../eventSuccess/operations/messageProtocol";
import {prepareRehearsalLateJoin} from "./assistanceMessages";

export type {PracticeMessage};
export type PracticePlan = PracticeMessage["plan"];
export class PracticeHistoryUnavailable extends HttpsError {
  constructor() {
    super("failed-precondition", "Practice message history needs review.");
  }
}
export const rehearsalMessages = "eventRehearsalMessages";
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
export function practiceMessageDocumentId(sessionId: string,
  messageId: string) {
  if (!/^[A-Za-z0-9_-]+$/u.test(sessionId) ||
      !/^outbox:[a-f0-9]{64}$/u.test(messageId)) {
    fail("Invalid practice message.");
  }
  return sessionId + "_" + messageId;
}

/**
 * Rebuild operational facts from the current synthetic actor and virtual clock.
 */
export function practiceInput(session: Session, actor: Actor,
  plan: PracticePlan,
  records: readonly PracticeMessage[],
  current?: PracticeMessage): LateJoinInput {
  const context = practiceContext(session, actor);
  const now = session.virtualNow.toMillis();
  const history = projectLateJoinMessageHistory({context,
    attendeeId: actor.actorId, episodeId: practiceEpisode(session, actor)},
  records.map((m) => readPracticeMessage(m, session, actor).record), now,
  current?.record.intent);
  if (history.kind !== "ready") {
    throw new PracticeHistoryUnavailable();
  }
  const end = session.virtualStartedAt.toMillis() +
    session.setup.durationMinutes * 60000;
  return parseLateJoinInput({context, eventId: context.virtualEventId,
    eventOpen: ["running", "paused"].includes(session.status) && now < end,
    departureConfirmed: plan.departureConfirmed, now,
    setting: {kind: "enabled", authority: "executeWithinPolicy",
      policyVersion: "rehearsal:v1"}, policy: plan.policy,
    guest: {attendeeId: actor.actorId,
      episodeId: practiceEpisode(session, actor),
      admission: ["walkIn", "ambiguousClaim"].includes(actor.status) ?
        "pending" : "admitted",
      participation: ["departed", "noShow"].includes(actor.status) ?
        "departed" : "active",
      attendance: actor.status === "disconnected" ?
        {kind: "unknown", reason: "notConfirmed"} : {
          kind: "known", value: {
            checkedIn: ["present", "late", "returned"].includes(actor.status)},
          revision: session.runtimeRevision, observedAt: now, source: "host"},
      intention: practiceState(actor).intention,
      deliveryEligibility: "eligible"},
    guidance: {kind: "known", value: plan.guidance,
      revision: plan.guidance.revision, observedAt: now, source: "host"},
    ...history.facts,
    ...(plan.responseDeadline === null ? {} :
      {responseDeadline: plan.responseDeadline})});
}

export function readPracticeMessage(value: unknown, session: Session,
  actor: Actor): PracticeMessage {
  if (!validateEventRehearsalMessageDocument(value)) {
    fail("Invalid practice record.");
  }
  if (Buffer.byteLength(JSON.stringify(value), "utf8") > 900_000) {
    throw new HttpsError("resource-exhausted",
      "Practice message is too large.");
  }
  const record = parseMessageRecord(value.record);
  const context = practiceContext(session, actor);
  const intent = record.intent;
  if (value.sessionId !== actor.sessionId || value.actorId !== actor.actorId ||
      hash(intent.context) !== hash(context) ||
      intent.eventId !== context.virtualEventId ||
      intent.attendeeId !== actor.actorId ||
      intent.episodeId !== practiceEpisode(session, actor) ||
      intent.kind !== "joiningUpdate" || intent.automation ||
      record.attempts.some((a) => a.mode !== "rehearsal") ||
      record.response && record.response.source.kind !== "simulation" ||
      record.updatedAt > session.virtualNow.toMillis()) {
    fail("Practice scope changed.");
  }
  if (intent.kind !== "joiningUpdate") fail("Invalid practice message kind.");
  if (hash(intent.guidance) !== hash(value.plan.guidance) ||
      hash(intent.permittedRoutes) !== hash(value.plan.routes) ||
      hash(intent.deliveryPolicy) !== hash(value.plan.deliveryPolicy)) {
    fail("Practice message material changed.");
  }
  return value;
}

/** Publish a practice message only from an explicit Host-reviewed plan. */
export function requirePracticePlan(session: Session, plan: PracticePlan) {
  const now = session.virtualNow.toMillis();
  const end = session.virtualStartedAt.toMillis() +
    session.setup.durationMinutes * 60000;
  if (plan.guidance.validUntil <= now || plan.guidance.validUntil > end ||
      plan.responseDeadline !== null && plan.responseDeadline > end ||
      plan.policy.cutoff.kind === "time" && plan.policy.cutoff.at > end ||
      new Set((plan.laterChoices ?? []).map((c) => hash(c.target))).size !==
        (plan.laterChoices ?? []).length) {
    fail("Review the practice plan and window.");
  }
}

export function publishPracticeMessage(session: Session, actor: Actor,
  plan: PracticePlan, history: readonly PracticeMessage[]) {
  requirePracticePlan(session, plan);
  const now = session.virtualNow.toMillis();
  const input = practiceInput(session, actor, plan, history);
  const prepared = prepareRehearsalLateJoin(input, practiceContext(session,
    actor), {
    occurrenceId: "lateJoin", permittedRoutes: plan.routes,
    deliveryPolicy: plan.deliveryPolicy,
    laterChoices: plan.laterChoices?.filter((choice) =>
      destinationAllowed(plan.policy.destination, choice.target))});
  if (!prepared.message) {
    fail("Practice outreach is held: " + prepared.decision.kind);
  }
  const base = prepared.message.intent;
  const intent = parseMessageIntent({...base, intentId: "message:" +
    hash([{...base, createdAt: 0}, plan])});
  const record = newMessageRecord(intent, now);
  const existing = history.find((m) => m.record.messageId === record.messageId);
  const message: PracticeMessage = existing ?? {sessionId: actor.sessionId,
    actorId: actor.actorId, plan, record};
  readPracticeMessage(message, session, actor);
  return {message, exists: Boolean(existing), actor: {...actor,
    assistance: {...practiceState(actor), latestMessageId: record.messageId}}};
}

/**
 * Policy is re-evaluated at dispatch and response time.
 */
export function practiceFacts(session: Session, actor: Actor,
  message: PracticeMessage, history: readonly PracticeMessage[],
  forReply = false):
  OutboxFacts {
  readPracticeMessage(message, session, actor);
  const input = practiceInput(session, actor, message.plan, history, message);
  const decision = evaluateLateJoin(input);
  const current = practiceState(actor).latestMessageId ===
    message.record.messageId;
  const allowed = current && decision.kind === "update" &&
    (forReply || decision.shouldSend);
  const validUntil = Math.min(message.record.intent.expiresAt,
    session.virtualStartedAt.toMillis() +
      session.setup.durationMinutes * 60000);
  return {gate: allowed ? {kind: "allow", checkedAt: input.now, validUntil,
    instructionRevision: message.plan.guidance.revision} :
    {kind: "stop", reason: !input.eventOpen ? "eventClosed" :
      current ? "hostStopped" : "superseded"},
  routes: message.plan.routes.map((routeId) => ({routeId, state: {
    kind: "eligible", checkedAt: input.now, validUntil,
    permissionRevision: "simulation", candidate: {mode: "rehearsal",
      routeId}}}))};
}

export function practiceMessageView(session: Session, actor: Actor,
  message: PracticeMessage | null) {
  if (!message) return null;
  readPracticeMessage(message, session, actor);
  const {record} = message;
  if (record.intent.kind !== "joiningUpdate") {
    fail("Invalid practice message kind.");
  }
  const eligible = ["expected"].includes(actor.status) &&
    practiceState(actor).intention.kind !== "notComing";
  return {messageId: record.messageId, intentId: record.intent.intentId,
    intentRevision: record.intent.revision, text: record.intent.guidance.text,
    choices: record.intent.choices.map(({choiceId, label}) => ({choiceId,
      label})),
    lifecycle: record.lifecycle, expiresAt: record.intent.expiresAt,
    canRespond: eligible && record.lifecycle === "active" &&
      ["running", "paused"].includes(session.status) &&
      session.virtualNow.toMillis() < record.intent.expiresAt &&
      !(message.plan.policy.unanswered === "hostReviewAtDeadline" &&
        practiceState(actor).intention.kind === "unknown" &&
        session.virtualNow.toMillis() >= (
          message.plan.responseDeadline ?? 0)) &&
      practiceState(actor).latestMessageId === record.messageId,
    responseChoiceId: record.response?.choiceId ?? null};
}

export function practiceDeliveryView(message: PracticeMessage | null) {
  if (!message) return null;
  return {conflictingEvidence: message.record.deliveryConflict,
    attempts: message.record.attempts.map((attempt) => {
      if (attempt.mode !== "rehearsal") fail("Live attempt in practice view.");
      return {attemptId: attempt.attemptId, routeId: attempt.routeId,
        status: attempt.state.kind};
    })};
}

function fail(message: string): never {
  throw new HttpsError("failed-precondition", message);
}
