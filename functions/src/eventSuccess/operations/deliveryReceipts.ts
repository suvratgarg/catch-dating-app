import type {EventAssistanceDeliveryAttempt as DeliveryAttempt} from
  "../../shared/generated/eventAssistanceDeliveryAttempt";
import {parseDeliveryAttempt} from "./messageProtocol";

type LiveAttempt = Extract<DeliveryAttempt, {mode: "live"}>;
type ConfirmedState = Exclude<DeliveryAttempt["state"],
  {kind: "reserved" | "unknown" | "notDispatched"}>;
export interface VerifiedDeliveryReceipt {
  attemptId: string;
  senderId: string;
  bindingRevision: number;
  recipientEndpointId: string;
  routeId: LiveAttempt["binding"]["routeId"];
  providerEventId: string;
  receivedAt: number;
  /** Normalized provider evidence; `at` uses the server receipt clock. */
  state: ConfirmedState;
}
export type DeliveryReceiptResult = {
  attempt: LiveAttempt;
  disposition: "applied" | "duplicateOrOlder" | "conflictingEvidence";
};

/** Invoke only after authenticating and correlating the provider callback. */
export function mergeDeliveryReceipt(
  attempt: LiveAttempt, receipt: VerifiedDeliveryReceipt
): DeliveryReceiptResult {
  parseDeliveryAttempt(attempt);
  if (attempt.mode !== "live" || receipt.attemptId !== attempt.attemptId ||
      receipt.senderId !== attempt.binding.senderId ||
      receipt.bindingRevision !== attempt.binding.bindingRevision ||
      receipt.recipientEndpointId !== attempt.binding.recipientEndpointId ||
      receipt.routeId !== attempt.binding.routeId ||
      typeof receipt.providerEventId !== "string" ||
      receipt.providerEventId.length === 0 ||
        receipt.providerEventId.length > 512 ||
      !Number.isSafeInteger(receipt.receivedAt) ||
      receipt.receivedAt < attempt.createdAt ||
      receipt.state.at !== receipt.receivedAt ||
      !["accepted", "delivered", "read", "failed", "revoked"]
        .includes(receipt.state.kind)) {
    throw new Error("Delivery receipt scope or evidence is invalid");
  }
  const previous = attempt.state;
  const previousId = "providerMessageId" in previous ?
    previous.providerMessageId : null;
  const nextId = receipt.state.providerMessageId;
  if (previousId !== null && nextId !== null && previousId !== nextId) {
    throw new Error("Provider message identity mismatch");
  }
  const next: ConfirmedState = {
    ...receipt.state,
    providerMessageId: nextId ?? previousId,
  } as ConfirmedState;
  parseDeliveryAttempt({...attempt, state: next});
  const delivered = (state: DeliveryAttempt["state"]) =>
    state.kind === "delivered" || state.kind === "read";
  const nonDelivery = (state: DeliveryAttempt["state"]) =>
    state.kind === "failed" || state.kind === "revoked" ||
    state.kind === "notDispatched";
  if (delivered(previous) && nonDelivery(next)) {
    return {attempt, disposition: "conflictingEvidence"};
  }
  if (nonDelivery(previous) && delivered(next)) {
    return {attempt: {...attempt, state: next},
      disposition: "conflictingEvidence"};
  }
  if (previous.kind === "notDispatched") {
    return {attempt: {...attempt, state: next},
      disposition: "conflictingEvidence"};
  }
  if (previous.kind === "read" ||
      (previous.kind === "delivered" && next.kind === "accepted") ||
      ((previous.kind === "failed" || previous.kind === "revoked") &&
       next.kind === "accepted")) {
    return {attempt, disposition: "duplicateOrOlder"};
  }
  if (previous.kind === "failed" && next.kind === "failed" &&
      previous.classification !== next.classification) {
    const restricted = previous.classification === "policy" ||
      previous.classification === "suppressed";
    return {attempt: restricted ? attempt : {...attempt, state: next},
      disposition: "conflictingEvidence"};
  }
  if (previous.kind === next.kind) {
    return {attempt, disposition: "duplicateOrOlder"};
  }
  if (previous.kind === "failed" && next.kind === "revoked" &&
      previous.classification !== "technical") {
    return {attempt, disposition: "conflictingEvidence"};
  }
  return {attempt: {...attempt, state: next}, disposition: "applied"};
}
