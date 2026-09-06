import type {EventAssistanceMessageDocument as MessageRecord} from
  "../../shared/generated/eventAssistanceMessageDocument";
import {validateEventAssistanceMessageDocument} from
  "../../shared/generated/validators/eventAssistanceMessageDocument";
import {operationContentHash} from "../../operations/durableActions";
import {
  parseMessageIntent, planMessageDelivery,
} from "./messageProtocol";
import type {
  DeliveryDecision, DeliveryEvaluationInput, DispatchCandidate,
} from "./messagingPolicy";

export type {MessageRecord};
export type OutboxFacts = Pick<DeliveryEvaluationInput, "gate" | "routes">;
export type LiveAttempt = Extract<MessageRecord["attempts"][number],
  {mode: "live"}>;

export function assistanceMessageId(intent: MessageRecord["intent"]): string {
  return "outbox:" + operationContentHash([
    intent.context, intent.intentId, intent.revision,
  ]);
}

export function parseMessageRecord(value: unknown): MessageRecord {
  if (!validateEventAssistanceMessageDocument(value)) {
    throw new Error("Invalid event message record");
  }
  parseMessageIntent(value.intent);
  if (value.messageId !== assistanceMessageId(value.intent) ||
      value.createdAt < value.intent.createdAt ||
      value.updatedAt < value.createdAt ||
      value.attempts.some((attempt) => attempt.createdAt < value.createdAt) ||
      value.attempts.length > value.intent.deliveryPolicy.maxAttempts) {
    throw new Error("Event message identity or history is invalid");
  }
  // Validate complete history even when a message no longer needs dispatch.
  planMessageDelivery({intent: value.intent, attempts: value.attempts,
    lifecycle: value.lifecycle, now: value.updatedAt,
    gate: {kind: "stop", reason: "hostStopped"}, routes: []});
  return value;
}

export function evaluateOutbox(
  record: MessageRecord, facts: OutboxFacts, now: number
): DeliveryDecision {
  if (record.deliveryConflict) {
    return {kind: "hostDecision", reason: "conflictingDeliveryEvidence"};
  }
  return planMessageDelivery({...facts, intent: record.intent,
    attempts: record.attempts, lifecycle: record.lifecycle, now});
}

/** Permission for one provider attempt, returned only after commit. */
export interface LiveDispatchPermit {
  messageId: string;
  intent: MessageRecord["intent"];
  attempt: LiveAttempt;
  validUntil: number;
}
export type PermitResult =
  | {kind: "claimed"; record: MessageRecord; permit: LiveDispatchPermit}
  | {kind: "withheld"; record: MessageRecord;
      reason: "notReserved" | "rehearsal" | "authorityChanged" |
        "authorizationExpired" | "deliveryConflict"};

/**
 * Remove just the unsent reservation when re-evaluating fresh authority. Its
 * immutable sender and permission must still be the selected route. A changed
 * channel never silently repurposes the old attempt id.
 */
export function canClaimLiveAttempt(
  record: MessageRecord, attemptId: string, facts: OutboxFacts, now: number
): {kind: "allow"; attempt: LiveAttempt; validUntil: number} |
  {kind: "withheld"; reason: Extract<PermitResult,
    {kind: "withheld"}>["reason"]} {
  const attempt = record.attempts.find((a) => a.attemptId === attemptId);
  if (!attempt || attempt.state.kind !== "reserved") {
    return {kind: "withheld", reason: "notReserved"};
  }
  if (attempt.mode !== "live") {
    return {kind: "withheld", reason: "rehearsal"};
  }
  if (record.deliveryConflict) {
    return {kind: "withheld", reason: "deliveryConflict"};
  }
  if (attempt.authorization.validUntil <= now) {
    return {kind: "withheld", reason: "authorizationExpired"};
  }
  const decision = planMessageDelivery({...facts,
    intent: record.intent, lifecycle: record.lifecycle, now,
    attempts: record.attempts.filter((a) => a.attemptId !== attemptId)});
  const candidate: DispatchCandidate = {mode: "live", binding: attempt.binding};
  if (decision.kind !== "dispatch" || decision.ordinal !== attempt.ordinal ||
      operationContentHash(decision.candidate) !==
        operationContentHash(candidate) ||
      decision.authorization.permissionRevision !==
        attempt.authorization.permissionRevision ||
      decision.authorization.instructionRevision !==
        attempt.authorization.instructionRevision) {
    return {kind: "withheld", reason: "authorityChanged"};
  }
  return {kind: "allow", attempt,
    validUntil: Math.min(attempt.authorization.validUntil,
      decision.authorization.validUntil)};
}
