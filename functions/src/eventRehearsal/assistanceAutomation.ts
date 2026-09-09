import {PracticeDepartures, resolvePracticeGuidance, practiceRecipeKey,
  practiceGuidanceMaterial} from "./movementGuidance";
import {HttpsError} from "firebase-functions/v2/https";
import type {EventRehearsalDocument as Session,
  EventRehearsalActorDocument as Actor} from
  "../shared/generated/firestoreAdminTypes";
import {operationContentHash as hash} from "../operations/durableActions";
import {evaluateLateJoin} from "../eventSuccess/operations/lateJoin";
import {parseMessageRecord} from
  "../eventSuccess/operations/messageOutbox";
import {PracticeHistoryUnavailable, PracticeMessage, PracticePlan,
  practiceContext, practiceFacts, practiceInput, practiceState,
  publishPracticeMessage, requirePracticePlan, dispatchPracticeMessage,
  practiceDeliveryDecision, readPracticeMessage} from "./assistanceRuntime";

type Automation = NonNullable<Actor["assistanceAutomation"]>;
type Evaluation = NonNullable<Automation["evaluation"]>;
export type PracticeAutomationResult = {actor: Actor;
  messages: PracticeMessage[]};

/** An explicit Host recipe. No timetable, position or outcome is inferred. */
export function configurePracticeAutomation(session: Session, actor: Actor,
  plan: PracticePlan, outcomes: Automation["outcomes"],
  history: readonly PracticeMessage[],
  departures: PracticeDepartures = new Map()): PracticeAutomationResult {
  plan = resolvePracticeGuidance(session, actor, plan,
    departures)?.plan ?? plan;
  requirePracticePlan(session, plan);
  if (!outcomes.length || outcomes.length > 6) {
    throw new HttpsError("invalid-argument",
      "Choose a bounded delivery script.");
  }
  // Validate the plan even when departure or entry policy currently holds it.
  practiceInput(session, actor, plan, history, undefined, departures);
  let nextActor = actor;
  let messages = [...history];
  const currentId = practiceState(actor).latestMessageId;
  const previous = messages.find((m) => m.record.messageId === currentId);
  if (previous && hash(previous.plan) !== hash(plan)) {
    messages = messages.map((message) => message === previous ?
      closeMessage(session, actor, message, "superseded") : message);
    nextActor = {...actor, assistance: {...practiceState(actor),
      latestMessageId: null}};
  }
  return evaluatePracticeAutomation(session, {...nextActor,
    assistanceAutomation: {clockId: practiceContext(session, actor).clockId,
      status: "enabled", plan: structuredClone(plan),
      outcomes: structuredClone(outcomes), nextOutcomeIndex: 0,
      evaluation: null}}, messages, departures);
}

export function pausePracticeAutomation(session: Session,
  actor: Actor): Actor {
  if (!actor.assistanceAutomation) return actor;
  return {...actor, assistanceAutomation: {...actor.assistanceAutomation,
    status: "paused", evaluation: {at: session.virtualNow.toMillis(),
      policy: null, delivery: {kind: "paused"}}}};
}

/**
 * One evaluation at the observed virtual time, after all crossed actor cues.
 * Missed wall-clock opportunities are never replayed as historical sends.
 * At most one scripted attempt is consumed per committed transition.
 */
export function evaluatePracticeAutomation(session: Session, actor: Actor,
  history: readonly PracticeMessage[],
  departures: PracticeDepartures = new Map()): PracticeAutomationResult {
  let automation = actor.assistanceAutomation;
  if (!automation || automation.status === "paused") {
    return {actor, messages: [...history]};
  }
  const now = session.virtualNow.toMillis();
  let messages = [...history];
  let nextActor = actor;
  if (automation.clockId !== practiceContext(session, actor).clockId ||
      automation.nextOutcomeIndex > automation.outcomes.length) {
    return unavailablePracticeAutomation(session, actor, messages);
  }
  try {
    let message = messages.find((m) => m.record.messageId ===
      practiceState(actor).latestMessageId);
    if (message &&
      practiceRecipeKey(message.plan) !== practiceRecipeKey(automation.plan)) {
      // An independently published instruction owns the page until reviewed.
      return {actor: pausePracticeAutomation(session, actor), messages};
    }
    if (message?.handoff) {
      readPracticeMessage(message, session, actor);
      // Receipt conflicts stay visible in delivery evidence; ownership still
      // stops this message before policy history can request another action.
      return {actor: {...actor, assistanceAutomation: {...automation,
        evaluation: {at: now, policy: null,
          delivery: {kind: "stop", reason: "hostStopped"}}}}, messages};
    }
    const confirmed = resolvePracticeGuidance(session, actor,
      automation.plan, departures);
    if (confirmed) {
      automation = {...automation, plan: confirmed.plan};
      if (message && (!message.movementBinding ||
          practiceGuidanceMaterial(message.plan) !==
            practiceGuidanceMaterial(confirmed.plan))) {
        messages = replace(messages,
          closeMessage(session, actor, message, "superseded"));
        nextActor = {...actor, assistance: {...practiceState(actor),
          latestMessageId: null}};
        message = undefined;
      }
    }
    let policy = evaluateLateJoin(practiceInput(session, nextActor,
      automation.plan, messages, message, departures));
    if (!message && policy.kind === "update") {
      const published = publishPracticeMessage(session, nextActor,
        automation.plan, messages, departures);
      message = published.message;
      nextActor = published.actor;
      if (!published.exists) messages.push(message);
      policy = evaluateLateJoin(practiceInput(session, nextActor,
        automation.plan, messages, message, departures));
    }
    let delivery: Evaluation["delivery"] = {kind: "notApplicable"};
    let consumed = automation.nextOutcomeIndex;
    if (message) {
      const terminal = ["resolved", "cancelled", "expired"].includes(
        policy.kind) || now >= message.record.intent.expiresAt;
      if (terminal) {
        message = closeMessage(session, nextActor, message, "cancelled");
        messages = replace(messages, message);
      }
      const facts = practiceFacts(session, nextActor, message, messages,
        false, departures);
      const decision = practiceDeliveryDecision(message, facts, now);
      if (decision.kind === "dispatch") {
        const outcome = automation.outcomes[consumed];
        if (!outcome) {
          delivery = {kind: "scriptExhausted"};
        } else {
          const result = dispatchPracticeMessage(session, nextActor,
            message, messages, outcome, departures);
          if (result.decision.kind !== "dispatch" ||
              result.record.attempts.length !==
                message.record.attempts.length + 1) {
            throw new Error("Practice dispatch decision drift");
          }
          message = readPracticeMessage({...message, record: result.record},
            session, nextActor);
          messages = replace(messages, message);
          consumed++;
          const after = practiceDeliveryDecision(message,
            practiceFacts(session, nextActor, message, messages,
              false, departures), now);
          if (after.kind === "dispatch") {
            throw new Error("Duplicate practice dispatch at the same instant");
          }
          delivery = after;
        }
      } else {
        delivery = decision;
      }
    }
    return {actor: {...nextActor, assistanceAutomation: {...automation,
      nextOutcomeIndex: consumed, evaluation: {at: now, policy, delivery}}},
    messages};
  } catch (error) {
    if (!(error instanceof PracticeHistoryUnavailable)) throw error;
    return unavailablePracticeAutomation(session, actor, history);
  }
}

/** Unusable history holds assistance and preserves physical actions. */
export function unavailablePracticeAutomation(session: Session, actor: Actor,
  messages: readonly PracticeMessage[] = []): PracticeAutomationResult {
  if (!actor.assistanceAutomation) return {actor, messages: [...messages]};
  return {actor: {...actor,
    assistanceAutomation: {...actor.assistanceAutomation,
      evaluation: {at: session.virtualNow.toMillis(), policy: null,
        delivery: {kind: "hostDecision", reason: "historyUnavailable"}}}},
  messages: [...messages]};
}

function replace(messages: PracticeMessage[], message: PracticeMessage) {
  return messages.map((m) => m.record.messageId === message.record.messageId ?
    message : m);
}

function closeMessage(session: Session, actor: Actor, message: PracticeMessage,
  lifecycle: "cancelled" | "superseded"): PracticeMessage {
  if (message.record.lifecycle !== "active") return message;
  return readPracticeMessage({...message,
    record: parseMessageRecord({...message.record, lifecycle,
      updatedAt: session.virtualNow.toMillis(),
      revision: message.record.revision + 1})}, session, actor);
}
