import type {Firestore, Transaction} from "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import type {MessageRecord} from "./messageOutbox";
import {readLiveLateJoinEvaluation} from "./liveLateJoinEvaluation";
import type {DispatchGate, EventServiceRouteId} from "./messagingPolicy";
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
  intent: MessageRecord["intent"], now: number):
  Promise<DispatchGate | null> {
  if (intent.kind !== "joiningUpdate" || !intent.automation) return null;
  const binding = intent.automation;
  const stop = (): DispatchGate => ({kind: "stop", reason: "hostStopped"});
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
      evaluation.input.guest.episodeId !== intent.episodeId ||
      evaluation.decision.kind !== "update" ||
      !evaluation.decision.shouldSend ||
      operationContentHash(evaluation.decision.guidance) !==
        operationContentHash(intent.guidance)) return stop();
  const {input} = evaluation;
  const validUntil = Math.min(now + 30_000, intent.expiresAt,
    evaluation.runtimeConfiguration?.expiresAt ?? intent.expiresAt,
    input.policy.cutoff.kind === "time" ? input.policy.cutoff.at :
      intent.expiresAt,
    input.policy.unanswered === "hostReviewAtDeadline" &&
      input.guest.intention.kind === "unknown" ?
      binding.responseDeadline ?? now : intent.expiresAt);
  return {kind: "allow", checkedAt: now, validUntil,
    instructionRevision: intent.guidance.revision};
}
