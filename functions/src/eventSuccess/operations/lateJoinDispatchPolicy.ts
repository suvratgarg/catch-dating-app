import type {Firestore, Transaction} from "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import type {MessageRecord} from "./messageOutbox";
import {readLiveLateJoinEvaluation} from "./liveLateJoinEvaluation";
import type {DeliveryDecision, DispatchGate, EventServiceRouteId} from
  "./messagingPolicy";
import {ASSISTANCE_POLICY_VERSION} from "./policySettings";

/** Another ready sender cannot replace the automatic selection. */
export function messageAllowsSender(intent: MessageRecord["intent"],
  routeId: EventServiceRouteId, senderId: string): boolean {
  if (intent.kind !== "joiningUpdate" || !intent.automation) return true;
  return intent.automation.routes.some((route) =>
    route.routeId === routeId && "senderId" in route &&
      route.senderId === senderId);
}

/** Recheck current policy at reservation and final claim. */
export async function readLateJoinDispatchPolicy(db: Firestore, tx: Transaction,
  intent: MessageRecord["intent"], now: number): Promise<DispatchGate | null> {
  return (await readLateJoinDispatchState(db, tx, intent, now)).gate;
}

/** Scheduling hints never grant permission to reserve or claim a send. */
export async function readLateJoinDispatchState(db: Firestore, tx: Transaction,
  intent: MessageRecord["intent"], now: number): Promise<{
    gate: DispatchGate | null;
    deferred: Extract<DeliveryDecision, {kind: "wait" | "hostDecision"}> | null;
  }> {
  if (intent.kind !== "joiningUpdate" || !intent.automation) {
    return {gate: null, deferred: null};
  }
  const binding = intent.automation;
  const stop = (): {gate: DispatchGate; deferred: null} =>
    ({gate: {kind: "stop", reason: "hostStopped"}, deferred: null});
  if (intent.context.mode !== "live" ||
      !binding.runtimeBinding ||
      binding.policyVersion !== ASSISTANCE_POLICY_VERSION) return stop();
  const evaluation = await readLiveLateJoinEvaluation(db, tx,
    {context: intent.context, attendeeId: intent.attendeeId},
    {...binding, deliveryPolicy: intent.deliveryPolicy}, now,
    intent);
  if (evaluation.kind !== "evaluated" ||
      operationContentHash(evaluation.binding) !== operationContentHash({
        groupId: binding.groupId, settingId: binding.settingId,
        settingRevision: binding.settingRevision}) ||
      evaluation.input.guest.episodeId !== intent.episodeId) return stop();
  const decision = evaluation.decision;
  if (decision.kind === "hostDecision" && decision.reason === "unreachable") {
    return {...stop(), deferred: {kind: "hostDecision",
      reason: "noEligibleRoute"}};
  }
  if (decision.kind !== "update" ||
      operationContentHash(decision.guidance) !==
        operationContentHash(intent.guidance)) return stop();
  if (!decision.shouldSend) {
    return {...stop(), deferred: decision.nextEvaluationAt !== null &&
        decision.nextEvaluationAt > now ? {kind: "wait", reason: "retryBackoff",
        notBefore: decision.nextEvaluationAt} : null};
  }
  const {input} = evaluation;
  const validUntil = Math.min(now + 30_000, intent.expiresAt,
    evaluation.runtimeConfiguration?.expiresAt ?? intent.expiresAt,
    input.policy.cutoff.kind === "time" ? input.policy.cutoff.at :
      intent.expiresAt,
    input.policy.unanswered === "hostReviewAtDeadline" &&
      input.guest.intention.kind === "unknown" ?
      binding.responseDeadline ?? now : intent.expiresAt);
  return {gate: {kind: "allow", checkedAt: now, validUntil,
    instructionRevision: intent.guidance.revision}, deferred: null};
}
