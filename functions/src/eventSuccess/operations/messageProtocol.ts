import type {EventAssistanceMessageIntent as MessageIntent} from
  "../../shared/generated/eventAssistanceMessageIntent";
import type {EventAssistanceDeliveryAttempt as DeliveryAttempt} from
  "../../shared/generated/eventAssistanceDeliveryAttempt";
import type {EventAssistanceGuestResponse as GuestResponse} from
  "../../shared/generated/eventAssistanceGuestResponse";
import type {EventAssistanceLateJoinInput as LateJoinInput} from
  "../../shared/generated/eventAssistanceLateJoinInput";
import {validateEventAssistanceMessageIntent} from
  "../../shared/generated/validators/eventAssistanceMessageIntent";
import {validateEventAssistanceDeliveryAttempt} from
  "../../shared/generated/validators/eventAssistanceDeliveryAttempt";
import {validateEventAssistanceGuestResponse} from
  "../../shared/generated/validators/eventAssistanceGuestResponse";
import {operationContentHash} from "../../operations/durableActions";
import {destinationAllowed, evaluateLateJoin} from "./lateJoin";
import {
  DeliveryEvaluationInput,
  DispatchGate,
  evaluateMessageDelivery,
  MessageLifecycle,
  sameMessageContext,
} from "./messagingPolicy";

export function parseMessageIntent(value: unknown): MessageIntent {
  if (!validateEventAssistanceMessageIntent(value)) {
    throw new Error("Invalid message intent");
  }
  const eventId = value.context.mode === "live" ?
    value.context.eventId : value.context.virtualEventId;
  if (eventId !== value.eventId || value.expiresAt <= value.createdAt ||
      (value.kind === "joiningUpdate" &&
       value.expiresAt > value.guidance.validUntil)) {
    throw new Error("Message intent scope or expiry mismatch");
  }
  const ids = new Set<string>();
  for (const choice of value.choices) {
    if (ids.has(choice.choiceId)) throw new Error("Duplicate response choice");
    ids.add(choice.choiceId);
    if (value.kind === "operationalNotice" &&
        choice.value.kind === "acknowledge" &&
        choice.value.instructionRevision !== value.instructionRevision) {
      throw new Error("Acknowledgement refers to another instruction revision");
    }
  }
  return value;
}

export function parseDeliveryAttempt(value: unknown): DeliveryAttempt {
  if (!validateEventAssistanceDeliveryAttempt(value)) {
    throw new Error("Invalid delivery attempt");
  }
  if (value.state.at < value.createdAt ||
      value.createdAt < value.authorization.checkedAt ||
      value.createdAt >= value.authorization.validUntil ||
      ("reconcileAfter" in value.state &&
       value.state.reconcileAfter < value.state.at)) {
    throw new Error("Invalid delivery attempt timeline");
  }
  return value;
}

export function planMessageDelivery(input: DeliveryEvaluationInput) {
  parseMessageIntent(input.intent);
  input.attempts.forEach(parseDeliveryAttempt);
  for (const route of input.routes) {
    if (route.state.kind !== "eligible") continue;
    const candidate = route.state.candidate;
    parseDeliveryAttempt({
      schemaVersion: 1, attemptId: "binding-validation",
      intentId: input.intent.intentId, intentRevision: input.intent.revision,
      ordinal: 1, createdAt: input.now,
      state: {kind: "reserved", at: input.now, reconcileAfter: input.now},
      // Binding shape validation; actual authority is frozen only on selection.
      authorization: {permissionRevision: "binding-validation",
        checkedAt: input.now, validUntil: input.now + 1,
        instructionRevision: 0},
      mode: candidate.mode, context: input.intent.context,
      ...(candidate.mode === "live" ? {binding: candidate.binding} :
        {routeId: candidate.routeId}),
    });
  }
  return evaluateMessageDelivery(input);
}

type LaterChoice = {
  label: string;
  target: Extract<LateJoinInput["guest"]["intention"],
    {kind: "joinLater"}>["target"];
};
export interface LateJoinMessageOptions {
  occurrenceId: string;
  permittedRoutes: MessageIntent["permittedRoutes"];
  deliveryPolicy: MessageIntent["deliveryPolicy"];
  laterChoices?: readonly LaterChoice[];
}

/** Produces a proposal only when the shared event policy permits outreach. */
export function buildLateJoinMessageIntent(
  input: LateJoinInput, options: LateJoinMessageOptions
): MessageIntent | null {
  const decision = evaluateLateJoin(input);
  if (decision.kind !== "update" || !decision.shouldSend) return null;
  const choices: Extract<MessageIntent, {kind: "joiningUpdate"}>["choices"] = [
    {choiceId: "on-my-way", label: "I'm on my way",
      value: {kind: "joinIntent", intention: {kind: "onMyWay",
        claimedEta: null}}},
    {choiceId: "not-coming", label: "I can't make it",
      value: {kind: "joinIntent", intention: {kind: "notComing"}}},
    {choiceId: "need-help", label: "I need help",
      value: {kind: "requestHelp", category: "eventLogistics"}},
  ];
  for (const later of options.laterChoices ?? []) {
    if (!destinationAllowed(input.policy.destination, later.target)) {
      throw new Error("Later joining choice is outside the approved plan");
    }
    choices.push({choiceId: "join-" + operationContentHash(later.target),
      label: later.label,
      value: {kind: "joinIntent", intention: {
        kind: "joinLater", target: structuredClone(later.target),
      }}});
  }
  return parseMessageIntent({
    schemaVersion: 1,
    intentId: "message:" + operationContentHash(decision.messageKey),
    revision: 1,
    context: input.context,
    eventId: input.eventId,
    attendeeId: input.guest.attendeeId,
    episodeId: input.guest.episodeId,
    workflow: {kind: "lateJoin", occurrenceId: options.occurrenceId},
    createdAt: input.now,
    expiresAt: Math.min(decision.guidance.validUntil,
      input.policy.cutoff.kind === "time" ? input.policy.cutoff.at :
        decision.guidance.validUntil),
    permittedRoutes: options.permittedRoutes,
    deliveryPolicy: options.deliveryPolicy,
    kind: "joiningUpdate",
    guidance: decision.guidance,
    choices,
  });
}

/** A deterministic reservation. Persistence must win before a provider call. */
export function prepareDeliveryAttempt(input: DeliveryEvaluationInput):
  DeliveryAttempt | null {
  const decision = planMessageDelivery(input);
  if (decision.kind !== "dispatch") return null;
  const {intent, now} = input;
  const candidate = decision.candidate;
  const routeId = candidate.mode === "live" ?
    candidate.binding.routeId : candidate.routeId;
  const base = {
    schemaVersion: 1,
    attemptId: "attempt:" + operationContentHash([
      intent.intentId, intent.revision, routeId, decision.ordinal,
    ]),
    intentId: intent.intentId,
    intentRevision: intent.revision,
    ordinal: decision.ordinal,
    createdAt: now,
    state: {kind: "reserved", at: now, reconcileAfter: now + 120_000},
    authorization: decision.authorization,
  };
  return parseDeliveryAttempt(candidate.mode === "live" ? {
    ...base, mode: "live", context: intent.context, binding: candidate.binding,
  } : {...base, mode: "rehearsal", context: intent.context, routeId});
}

export interface ResolvedGuestScope {
  context: MessageIntent["context"];
  eventId: string;
  attendeeId: string;
  episodeId: string;
  validUntil: number;
  source: GuestResponse["source"];
}
export interface GuestChoiceSubmission {
  intentId: string;
  intentRevision: number;
  choiceId: string;
  requestId: string;
}
export type GuestChoiceResult =
  | {kind: "accepted" | "replayed"; response: GuestResponse}
  | {kind: "rejected"; reason: "scopeMismatch" | "staleIntent" |
    "invalidChoice" | "expired" | "alreadyResponded" | "noLongerNeeded" |
    "factsStale"};

/**
 * Scope comes from a resolved bearer grant or verified provider correlation,
 * never from the submitted body. The owner must atomically persist this
 * response with its domain effect, using the current participation revision.
 */
export function resolveGuestChoice(input: {
  intent: MessageIntent;
  lifecycle: MessageLifecycle;
  submission: GuestChoiceSubmission;
  scope: ResolvedGuestScope;
  gate: DispatchGate;
  now: number;
  existingResponse?: GuestResponse | null;
}): GuestChoiceResult {
  const {intent, scope, submission, now, gate} = input;
  parseMessageIntent(intent);
  if (!Number.isSafeInteger(now) || now < intent.createdAt ||
      !Number.isSafeInteger(scope.validUntil) || scope.validUntil < 0 ||
      typeof submission.requestId !== "string" ||
      submission.requestId.length < 1 || submission.requestId.length > 512) {
    throw new Error("Invalid response submission");
  }
  if (!sameMessageContext(intent.context, scope.context) ||
      intent.eventId !== scope.eventId ||
        intent.attendeeId !== scope.attendeeId ||
      intent.episodeId !== scope.episodeId) {
    return {kind: "rejected", reason: "scopeMismatch"};
  }
  if (intent.intentId !== submission.intentId ||
      intent.revision !== submission.intentRevision) {
    return {kind: "rejected", reason: "staleIntent"};
  }
  const choice = intent.choices.find((c) => c.choiceId === submission.choiceId);
  if (!choice) return {kind: "rejected", reason: "invalidChoice"};
  if (now >= scope.validUntil) {
    return {kind: "rejected", reason: "expired"};
  }
  const responseId = "response:" + operationContentHash([
    intent.intentId, intent.revision, scope.source.kind, submission.requestId,
  ]);
  const existing = input.existingResponse;
  if (existing) {
    if (!validateEventAssistanceGuestResponse(existing) ||
        existing.intentId !== intent.intentId ||
        existing.intentRevision !== intent.revision ||
        existing.eventId !== intent.eventId ||
        existing.attendeeId !== intent.attendeeId ||
        existing.episodeId !== intent.episodeId ||
        !sameMessageContext(existing.context, intent.context)) {
      throw new Error("Stored response is outside the intent");
    }
    const sameValue = operationContentHash(existing.value) ===
      operationContentHash(choice.value);
    const sameSource = operationContentHash(existing.source) ===
      operationContentHash(scope.source);
    if (existing.responseId === responseId &&
        existing.choiceId === submission.choiceId &&
        sameValue && sameSource) {
      return {kind: "replayed", response: existing};
    }
    return {kind: "rejected", reason: "alreadyResponded"};
  }
  if (now >= intent.expiresAt) {
    return {kind: "rejected", reason: "expired"};
  }
  if (input.lifecycle !== "active" || gate.kind === "stop") {
    return {kind: "rejected", reason: "noLongerNeeded"};
  }
  if (!Number.isSafeInteger(gate.checkedAt) || gate.checkedAt < 0 ||
      !Number.isSafeInteger(gate.validUntil) ||
      gate.checkedAt > now || gate.validUntil <= now) {
    return {kind: "rejected", reason: "factsStale"};
  }
  const revision = intent.kind === "joiningUpdate" ?
    intent.guidance.revision : intent.instructionRevision;
  if (revision !== gate.instructionRevision) {
    return {kind: "rejected", reason: "staleIntent"};
  }
  const response = {
    schemaVersion: 1, responseId, intentId: intent.intentId,
    intentRevision: intent.revision, eventId: intent.eventId,
    attendeeId: intent.attendeeId, episodeId: intent.episodeId,
    context: intent.context, choiceId: choice.choiceId, receivedAt: now,
    value: choice.value, source: scope.source,
  };
  if (!validateEventAssistanceGuestResponse(response)) {
    return {kind: "rejected", reason: "scopeMismatch"};
  }
  return {kind: "accepted", response};
}
