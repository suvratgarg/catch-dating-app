import {PracticeDepartures, resolvePracticeGuidance,
  practiceGuidanceMaterial} from "./movementGuidance";
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
import {evaluateOutbox, newMessageRecord, parseMessageRecord, OutboxFacts} from
  "../eventSuccess/operations/messageOutbox";
import {parseMessageIntent} from "../eventSuccess/operations/messageProtocol";
import {dispatchRehearsalMessage, prepareRehearsalLateJoin,
  RehearsalMessageOutcome} from "./assistanceMessages";

import {practiceContext, practiceEpisode, practiceState} from
  "./assistanceIdentity";
import {practiceGuidanceBinding} from "./membershipSource";
export {practiceContext, practiceEpisode, practiceState} from
  "./assistanceIdentity";

export type {PracticeMessage};
export type PracticePlan = PracticeMessage["plan"];
export class PracticeHistoryUnavailable extends HttpsError {
  constructor() {
    super("failed-precondition", "Practice message history needs review.");
  }
}
export const rehearsalMessages = "eventRehearsalMessages";
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
  current?: PracticeMessage,
  departures: PracticeDepartures = new Map()): LateJoinInput {
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
  const confirmed = resolvePracticeGuidance(session, actor, plan, departures);
  return parseLateJoinInput({context, eventId: context.virtualEventId,
    eventOpen: ["running", "paused"].includes(session.status) && now < end,
    departureConfirmed: !!confirmed, now,
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
    guidance: practiceGuidanceIsCurrent(session, actor, plan, current,
      departures) ?
      {kind: "known", value: confirmed!.plan.guidance,
        revision: confirmed!.plan.guidance.revision,
        observedAt: now, source: "host"} :
      {kind: "unknown", reason: "sourceUnavailable"},
    ...history.facts,
    ...(plan.responseDeadline === null ? {} :
      {responseDeadline: plan.responseDeadline})});
}

/** Historical records stay readable; only current acceptance authorizes use. */
export function practiceGuidanceIsCurrent(session: Session, actor: Actor,
  plan: PracticePlan, message?: PracticeMessage,
  departures: PracticeDepartures = new Map()): boolean {
  const confirmed = resolvePracticeGuidance(session, actor, plan, departures);
  if (!confirmed) return false;
  if (message && (!message.movementBinding ||
      message.movementBinding.groupId !== confirmed.binding.groupId ||
      message.movementBinding.sourceHash !== confirmed.binding.sourceHash ||
      message.movementBinding.progressRevision >
        confirmed.binding.progressRevision ||
      practiceGuidanceMaterial(message.plan) !==
        practiceGuidanceMaterial(confirmed.plan))) return false;
  const binding = practiceGuidanceBinding(session, actor,
    plan.guidance.destination);
  if (binding === null) return false;
  if (!message) return true;
  return binding === undefined ? message.membershipBinding === undefined :
    !!message.membershipBinding &&
      hash(binding) === hash(message.membershipBinding);
}

function boundIntentId(intent: ReturnType<typeof parseMessageIntent>,
  plan: PracticePlan,
  binding: PracticeMessage["membershipBinding"],
  movement?: PracticeMessage["movementBinding"]) {
  return "message:" + hash([{...intent, intentId: "", createdAt: 0},
    plan, binding ?? null, ...(movement ? [movement] : [])]);
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
  if (value.handoff && (record.revision < 1 ||
      value.handoff.at < record.createdAt ||
      value.handoff.at > record.updatedAt)) {
    fail("Invalid practice handoff evidence.");
  }
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
  const movement = value.movementBinding;
  if (movement && (movement.groupId !==
      (intent.guidance.destination.kind === "groupCheckpoint" ?
        intent.guidance.destination.groupId : "event:whole") ||
      movement.progressRevision !== intent.guidance.revision ||
      intent.intentId !== boundIntentId(intent, value.plan,
        value.membershipBinding, movement))) {
    fail("Practice movement binding changed.");
  }
  const binding = value.membershipBinding;
  if (binding && (intent.guidance.destination.kind !== "groupCheckpoint" ||
      binding.groupId !== intent.guidance.destination.groupId ||
      intent.intentId !== boundIntentId(intent, value.plan, binding,
        movement))) {
    fail("Practice membership binding changed.");
  }
  return value;
}

/** Validate the reviewed policy and recipe window. Movement is server-owned. */
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
  plan: PracticePlan, history: readonly PracticeMessage[],
  departures: PracticeDepartures = new Map()) {
  const confirmed = resolvePracticeGuidance(session, actor, plan, departures);
  if (!confirmed) fail("Practice outreach is held: departureNotConfirmed");
  plan = confirmed.plan;
  requirePracticePlan(session, plan);
  const now = session.virtualNow.toMillis();
  const input = practiceInput(session, actor, plan, history, undefined,
    departures);
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
  const membershipBinding = practiceGuidanceBinding(session, actor,
    plan.guidance.destination);
  if (membershipBinding === null) fail("Practice group needs review.");
  const intent = parseMessageIntent({...base, intentId:
    boundIntentId(base, plan, membershipBinding, confirmed.binding)});
  const record = newMessageRecord(intent, now);
  const existing = history.find((m) => m.record.messageId === record.messageId);
  const message = readPracticeMessage(existing ?? {sessionId: actor.sessionId,
    actorId: actor.actorId, plan, record, movementBinding: confirmed.binding,
    ...(membershipBinding ? {membershipBinding} : {})}, session, actor);
  return {message, exists: Boolean(existing), actor: {...actor,
    assistance: {...practiceState(actor), latestMessageId: record.messageId}}};
}

/**
 * Policy is re-evaluated at dispatch and response time.
 */
export function practiceFacts(session: Session, actor: Actor,
  message: PracticeMessage, history: readonly PracticeMessage[],
  forReply = false, departures: PracticeDepartures = new Map()):
  OutboxFacts {
  readPracticeMessage(message, session, actor);
  const input = practiceInput(session, actor, message.plan, history, message,
    departures);
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

/** Manual ownership stops attempts; the reply gate remains independent. */
export function practiceDeliveryDecision(message: PracticeMessage,
  facts: OutboxFacts, now: number): ReturnType<typeof evaluateOutbox> {
  return message.handoff ? {kind: "stop", reason: "hostStopped"} :
    evaluateOutbox(message.record, facts, now);
}

export function dispatchPracticeMessage(session: Session, actor: Actor,
  message: PracticeMessage, history: readonly PracticeMessage[],
  outcome: RehearsalMessageOutcome,
  departures: PracticeDepartures = new Map()) {
  readPracticeMessage(message, session, actor);
  if (message.handoff) {
    return {record: message.record,
      decision: {kind: "stop" as const, reason: "hostStopped" as const}};
  }
  const facts = practiceFacts(session, actor, message, history, false,
    departures);
  const now = session.virtualNow.toMillis();
  const decision = practiceDeliveryDecision(message, facts, now);
  if (decision.kind !== "dispatch") return {record: message.record, decision};
  return dispatchRehearsalMessage({context: practiceContext(session, actor),
    record: message.record, facts, now, outcome});
}

export function practiceMessageView(session: Session, actor: Actor,
  message: PracticeMessage | null,
  departures: PracticeDepartures = new Map()) {
  if (!message) return null;
  readPracticeMessage(message, session, actor);
  if (!practiceGuidanceIsCurrent(session, actor, message.plan, message,
    departures)) {
    return null;
  }
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
