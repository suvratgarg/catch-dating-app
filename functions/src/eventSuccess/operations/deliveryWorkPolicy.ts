import {operationContentHash} from "../../operations/durableActions";
import type {DeliveryCheckpoint, DeliveryWork} from "./deliveryWorkRecords";
import type {DeliveryDecision} from "./messagingPolicy";
import type {MessageRecord} from "./messageOutbox";
import type {EventMessageWorkerResult} from "./messageWorker";

export type DeliveryExecution = EventMessageWorkerResult |
  {kind: "unavailable"};

/** Recorded outcomes can be reconciled after source/permission changes. */
export function observedDeliveryDecision(message: MessageRecord, now: number):
  DeliveryDecision | null {
  if (now >= message.intent.expiresAt) {
    return {kind: "stop", reason: "expired"};
  }
  if (message.deliveryConflict) {
    return {kind: "hostDecision",
      reason: "conflictingDeliveryEvidence"};
  }
  if (message.lifecycle !== "active") {
    return {kind: "stop", reason: message.lifecycle};
  }
  const delivered = message.attempts.filter((a) =>
    a.state.kind === "delivered" || a.state.kind === "read");
  if (delivered.length) {
    return {kind: "delivered",
      attemptIds: delivered.map((a) => a.attemptId)};
  }
  const pending = message.attempts.filter((a) =>
    a.state.kind === "unknown" || a.state.kind === "accepted" ||
    a.state.kind === "reserved");
  if (pending.some((a) => a.state.kind !== "reserved")) {
    return {kind: "reconcile", attemptIds: pending.map((a) => a.attemptId),
      notBefore: Math.min(...pending.map((a) =>
        "reconcileAfter" in a.state ? a.state.reconcileAfter : now))};
  }
  return null;
}

/** Checkpoint advice only: the outbox remains the send/retry authority. */
export function nextDeliveryCheckpoint(payload: DeliveryWork,
  message: MessageRecord, decision: DeliveryDecision,
  execution: DeliveryExecution | null, now: number,
  policyDeferred = false): DeliveryCheckpoint {
  const prior = payload.checkpoint;
  const base = {...prior, messageRevision: message.revision,
    messageHash: operationContentHash(message),
    evaluations: Math.min(100, prior.evaluations + 1)};
  const complete = (reason: Extract<DeliveryCheckpoint,
    {phase: "complete"}>["reason"]): DeliveryCheckpoint =>
    ({...base, phase: "complete", reason, dueAt: null, failures: 0});
  const review = (reason: Extract<DeliveryCheckpoint,
    {phase: "review"}>["reason"]): DeliveryCheckpoint =>
    ({...base, phase: "review", reason, dueAt: payload.expiresAt});
  const retry = (reason: Extract<DeliveryCheckpoint,
    {phase: "retry"}>["reason"], dueAt: number):
    DeliveryCheckpoint => ({...base, phase: "retry", reason,
    dueAt: Math.min(payload.expiresAt, Math.max(now + 1000, dueAt))});
  if (now >= payload.expiresAt) return complete("expired");
  if (decision.kind === "stop") return complete(decision.reason);
  if (decision.kind === "delivered") return complete("delivered");
  if (prior.evaluations >= 100) return review("recoveryLimit");
  if (decision.kind === "reconcile") {
    const pending = message.attempts.filter((a) =>
      decision.attemptIds.includes(a.attemptId));
    if (pending.every((a) => a.state.kind === "reserved")) {
      if (execution?.kind === "unavailable" ||
          execution?.kind === "withheld") {
        base.failures = Math.min(5, prior.failures + 1);
        if (base.failures >= 5) return review("workerUnavailable");
      }
      return retry("retryBackoff", Math.min(...pending.map((a) =>
        a.authorization.validUntil)) + 5000 * 2 ** base.failures);
    }
    // One bounded wait for receipts. Missing evidence then becomes an owned
    // reconciliation issue; elapsed time never proves nondelivery.
    if (prior.phase === "receipt" &&
        prior.messageHash === operationContentHash(message)) {
      return review("providerPending");
    }
    return {...base, phase: "receipt", reason: "providerPending", failures: 0,
      dueAt: Math.min(payload.expiresAt,
        Math.max(now + 120_000, decision.notBefore))};
  }
  if (decision.kind === "wait") {
    return {...retry(decision.reason, decision.notBefore), failures: 0};
  }
  if (decision.kind === "refreshFacts") {
    base.failures = Math.min(5, prior.failures + 1);
    return base.failures >= 5 ? review(decision.reason) :
      retry(decision.reason, now + 5000 * 2 ** (base.failures - 1));
  }
  if (decision.kind === "hostDecision" &&
      (policyDeferred || decision.reason !== "noEligibleRoute")) {
    return review(decision.reason);
  }
  if (execution?.kind === "waiting") {
    const d = execution.decision;
    if (d.kind === "hostDecision") return review(d.reason);
    // A stopped/delivered worker result is rechecked from current source facts
    // above. A changed snapshot is retried rather than declaring completion.
    if (d.kind === "wait") return retry(d.reason, d.notBefore);
  }
  if (execution?.kind === "unavailable" || execution?.kind === "withheld") {
    base.failures = Math.min(5, prior.failures + 1);
    return base.failures >= 5 ? review("workerUnavailable") :
      retry("workerUnavailable", now + 5000 * 2 ** (base.failures - 1));
  }
  return retry("routeFactsStale", now + 5000);
}
