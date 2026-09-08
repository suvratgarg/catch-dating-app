import {HttpsError} from "firebase-functions/v2/https";
import type {EventRehearsalDocument as Session,
  EventRehearsalActorDocument as Actor} from
  "../shared/generated/firestoreAdminTypes";
import {operationContentHash as hash} from "../operations/durableActions";
import {evaluateLateJoin} from "../eventSuccess/operations/lateJoin";
import {evaluateOutbox, parseMessageRecord} from
  "../eventSuccess/operations/messageOutbox";
import {dispatchRehearsalMessage} from "./assistanceMessages";
import {PracticeHistoryUnavailable, PracticeMessage, PracticePlan,
  practiceContext, practiceFacts, practiceInput, practiceState,
  publishPracticeMessage, requirePracticePlan} from "./assistanceRuntime";

type Automation = NonNullable<Actor["assistanceAutomation"]>;
type Evaluation = NonNullable<Automation["evaluation"]>;
export type PracticeAutomationResult = {actor: Actor;
  messages: PracticeMessage[]};

/** An explicit Host recipe. No timetable, position or outcome is inferred. */
export function configurePracticeAutomation(session: Session, actor: Actor,
  plan: PracticePlan, outcomes: Automation["outcomes"],
  history: readonly PracticeMessage[]): PracticeAutomationResult {
  requirePracticePlan(session, plan);
  if (!outcomes.length || outcomes.length > 6) {
    throw new HttpsError("invalid-argument",
      "Choose a bounded delivery script.");
  }
  // Validate the plan even when departure or entry policy currently holds it.
  practiceInput(session, actor, plan, history);
  let nextActor = actor;
  let messages = [...history];
  const currentId = practiceState(actor).latestMessageId;
  const previous = messages.find((m) => m.record.messageId === currentId);
  if (previous && hash(previous.plan) !== hash(plan)) {
    messages = messages.map((message) => message === previous ?
      closeMessage(session, message, "superseded") : message);
    nextActor = {...actor, assistance: {...practiceState(actor),
      latestMessageId: null}};
  }
  return evaluatePracticeAutomation(session, {...nextActor,
    assistanceAutomation: {clockId: practiceContext(session, actor).clockId,
      status: "enabled", plan: structuredClone(plan),
      outcomes: structuredClone(outcomes), nextOutcomeIndex: 0,
      evaluation: null}}, messages);
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
  history: readonly PracticeMessage[]): PracticeAutomationResult {
  const automation = actor.assistanceAutomation;
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
    if (message && hash(message.plan) !== hash(automation.plan)) {
      // An independently published instruction owns the page until reviewed.
      return {actor: pausePracticeAutomation(session, actor), messages};
    }
    let policy = evaluateLateJoin(practiceInput(session, actor,
      automation.plan, messages, message));
    if (!message && policy.kind === "update") {
      const published = publishPracticeMessage(session, actor,
        automation.plan, messages);
      message = published.message;
      nextActor = published.actor;
      if (!published.exists) messages.push(message);
      policy = evaluateLateJoin(practiceInput(session, nextActor,
        automation.plan, messages, message));
    }
    let delivery: Evaluation["delivery"] = {kind: "notApplicable"};
    let consumed = automation.nextOutcomeIndex;
    if (message) {
      const terminal = ["resolved", "cancelled", "expired"].includes(
        policy.kind) || now >= message.record.intent.expiresAt;
      if (terminal) {
        message = closeMessage(session, message, "cancelled");
        messages = replace(messages, message);
      }
      const facts = practiceFacts(session, nextActor, message, messages);
      const decision = evaluateOutbox(message.record, facts, now);
      if (decision.kind === "dispatch") {
        const outcome = automation.outcomes[consumed];
        if (!outcome) {
          delivery = {kind: "scriptExhausted"};
        } else {
          const result = dispatchRehearsalMessage({record: message.record,
            context: practiceContext(session, actor), facts, now, outcome});
          if (result.decision.kind !== "dispatch" ||
              result.record.attempts.length !==
                message.record.attempts.length + 1) {
            throw new Error("Practice dispatch decision drift");
          }
          message = {...message, record: result.record};
          messages = replace(messages, message);
          consumed++;
          const after = evaluateOutbox(message.record,
            practiceFacts(session, nextActor, message, messages), now);
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

function closeMessage(session: Session, message: PracticeMessage,
  lifecycle: "cancelled" | "superseded"): PracticeMessage {
  if (message.record.lifecycle !== "active") return message;
  return {...message, record: parseMessageRecord({...message.record, lifecycle,
    updatedAt: session.virtualNow.toMillis(),
    revision: message.record.revision + 1})};
}
