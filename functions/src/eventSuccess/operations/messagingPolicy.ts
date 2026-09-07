import type {EventAssistanceMessageIntent as MessageIntent} from
  "../../shared/generated/eventAssistanceMessageIntent";
import type {EventAssistanceDeliveryAttempt as DeliveryAttempt} from
  "../../shared/generated/eventAssistanceDeliveryAttempt";

export type EventServiceRouteId = MessageIntent["permittedRoutes"][number];
export type LiveSenderBinding = Extract<
  DeliveryAttempt, {mode: "live"}
>["binding"];
export type DispatchCandidate =
  | {mode: "live"; binding: LiveSenderBinding}
  | {mode: "rehearsal"; routeId: EventServiceRouteId};
export type RouteReadiness = {
  routeId: EventServiceRouteId;
  state:
    | {kind: "eligible"; checkedAt: number; validUntil: number;
      permissionRevision: string; candidate: DispatchCandidate}
    | {kind: "blocked"; reason: "notProvisioned" | "channelUnavailable" |
      "missingPermission" | "suppressed" | "policyBlocked" |
      "templateUnavailable" | "budgetExceeded"};
};
export type StopReason = "responded" | "cancelled" | "superseded" |
  "expired" | "eventClosed" | "permissionRevoked" | "guestPresent" |
  "guestDeclined" | "notAdmitted" | "hostStopped";
export type MessageLifecycle = "active" | "responded" | "cancelled" |
  "superseded";
export type DispatchGate =
  | {kind: "allow"; checkedAt: number; validUntil: number;
    instructionRevision: number}
  | {kind: "stop"; reason: StopReason};
export interface DeliveryEvaluationInput {
  intent: MessageIntent;
  lifecycle: MessageLifecycle;
  attempts: readonly DeliveryAttempt[];
  routes: readonly RouteReadiness[];
  gate: DispatchGate;
  now: number;
}
export type DeliveryDecision =
  | {kind: "stop"; reason: StopReason}
  | {kind: "delivered"; attemptIds: string[]}
  | {kind: "reconcile"; attemptIds: string[]; notBefore: number}
  | {kind: "refreshFacts"; reason: "eventFactsStale" | "routeFactsStale"}
  | {kind: "wait"; notBefore: number; reason: "retryBackoff"}
  | {kind: "hostDecision"; reason: "noEligibleRoute" | "attemptLimit" |
      "policyRejected" | "recipientNeedsReview" | "providerOwnsFallback" |
      "conflictingDeliveryEvidence"}
  | {kind: "dispatch"; ordinal: number; candidate: DispatchCandidate;
    authorization: DeliveryAttempt["authorization"]};

/** Pure selection. The trusted worker reserves before any provider call. */
export function evaluateMessageDelivery(input: DeliveryEvaluationInput):
  DeliveryDecision {
  const {intent, lifecycle, gate, now} = input;
  assertDeliveryHistory(input);
  if (lifecycle !== "active") return {kind: "stop", reason: lifecycle};
  if (now >= intent.expiresAt) return {kind: "stop", reason: "expired"};
  if (gate.kind === "stop") return {kind: "stop", reason: gate.reason};
  if (!fresh(gate, now)) {
    return {kind: "refreshFacts", reason: "eventFactsStale"};
  }
  const revision = intent.kind === "joiningUpdate" ?
    intent.guidance.revision : intent.instructionRevision;
  if (gate.instructionRevision !== revision) {
    return {kind: "stop", reason: "superseded"};
  }
  const delivered = input.attempts.filter((attempt) =>
    classifyAttempt(attempt.state) === "delivered");
  if (delivered.length > 0) {
    return {kind: "delivered", attemptIds: delivered.map((a) => a.attemptId)};
  }
  const unresolved = input.attempts.filter((attempt) =>
    classifyAttempt(attempt.state) === "pending");
  if (unresolved.length > 0) {
    return {kind: "reconcile", attemptIds: unresolved.map((a) => a.attemptId),
      notBefore: Math.min(...unresolved.map((attempt) =>
        "reconcileAfter" in attempt.state ?
          attempt.state.reconcileAfter : now))};
  }
  for (const attempt of input.attempts) {
    if (attempt.state.kind === "notDispatched") {
      if (attempt.state.reason === "reservationExpired" ||
          attempt.state.reason === "permitExpired") continue;
      return {kind: "stop", reason: attempt.state.reason};
    }
    if (attempt.state.kind === "failed") {
      switch (attempt.state.classification) {
      case "policy":
      case "suppressed":
        return {kind: "hostDecision", reason: "policyRejected"};
      case "invalidRecipient":
        return {kind: "hostDecision", reason: "recipientNeedsReview"};
      case "technical":
        break;
      default:
        return unhandled(attempt.state.classification);
      }
    }
    if (attempt.mode === "live" &&
      attempt.binding.fallbackOwner === "provider") {
      return {kind: "hostDecision", reason: "providerOwnsFallback"};
    }
  }
  if (input.attempts.length >= intent.deliveryPolicy.maxAttempts) {
    return {kind: "hostDecision", reason: "attemptLimit"};
  }
  const latest = [...input.attempts].sort((a, b) => b.ordinal - a.ordinal)[0];
  if (latest) {
    const retryAt = latest.state.at +
      intent.deliveryPolicy.minimumRetrySeconds * 1000 *
      2 ** (input.attempts.length - 1);
    if (now < retryAt) {
      return {kind: "wait", notBefore: Math.min(retryAt, intent.expiresAt),
        reason: "retryBackoff"};
    }
  }
  const counts = new Map<EventServiceRouteId, number>();
  for (const attempt of input.attempts) {
    // Proven unsent reservations still consume the total recovery ceiling,
    // but cannot exhaust a channel's submission allowance.
    if (attempt.state.kind === "notDispatched") continue;
    const route = attemptRouteId(attempt);
    counts.set(route, (counts.get(route) ?? 0) + 1);
  }
  const candidates = intent.permittedRoutes.map((id) =>
    input.routes.find((route) => route.routeId === id)).filter(
    (route): route is RouteReadiness => route !== undefined
  );
  let staleRoute = false;
  const eligible = candidates.filter((route) => {
    if (route.state.kind !== "eligible") return false;
    if (!fresh(route.state, now)) {
      staleRoute = true;
      return false;
    }
    return (counts.get(route.routeId) ?? 0) <
      intent.deliveryPolicy.maxAttemptsPerRoute;
  });
  // Try an eligible untried channel before repeating a confirmed failed one.
  eligible.sort((a, b) => Number((counts.get(a.routeId) ?? 0) > 0) -
    Number((counts.get(b.routeId) ?? 0) > 0));
  const selected = eligible[0];
  if (!selected || selected.state.kind !== "eligible") {
    return staleRoute ? {kind: "refreshFacts", reason: "routeFactsStale"} :
      {kind: "hostDecision", reason: "noEligibleRoute"};
  }
  return {kind: "dispatch", ordinal: input.attempts.length + 1,
    candidate: selected.state.candidate,
    authorization: {
      permissionRevision: selected.state.permissionRevision,
      checkedAt: Math.min(gate.checkedAt, selected.state.checkedAt),
      validUntil: Math.min(gate.validUntil, selected.state.validUntil,
        intent.expiresAt),
      instructionRevision: revision,
    }};
}

export function attemptRouteId(attempt: DeliveryAttempt): EventServiceRouteId {
  return attempt.mode === "live" ? attempt.binding.routeId : attempt.routeId;
}

function classifyAttempt(state: DeliveryAttempt["state"]):
  "delivered" | "pending" | "nonDelivery" | "notDispatched" {
  switch (state.kind) {
  case "reserved":
  case "unknown":
  case "accepted":
    return "pending";
  case "delivered":
  case "read":
    return "delivered";
  case "failed":
  case "revoked":
    return "nonDelivery";
  case "notDispatched":
    return "notDispatched";
  default:
    return unhandled(state);
  }
}

function unhandled(value: never): never {
  void value;
  throw new Error("Unhandled messaging variant");
}

function fresh(value: {checkedAt: number; validUntil: number}, now: number) {
  return Number.isSafeInteger(value.checkedAt) &&
    value.checkedAt >= 0 &&
    Number.isSafeInteger(value.validUntil) &&
    value.checkedAt <= now && value.validUntil > now;
}

/** Wire adapters also validate each record against the generated schemas. */
function assertDeliveryHistory(input: DeliveryEvaluationInput): void {
  const {intent, attempts, routes, now} = input;
  if (!Number.isSafeInteger(now) || now < intent.createdAt) {
    throw new Error("Invalid delivery evaluation time");
  }
  const attemptIds = new Set<string>();
  const ordinals = new Set<number>();
  for (const attempt of attempts) {
    if (attempt.intentId !== intent.intentId ||
        attempt.intentRevision !== intent.revision ||
        attempt.authorization.instructionRevision !==
          (intent.kind === "joiningUpdate" ? intent.guidance.revision :
            intent.instructionRevision) ||
        !sameMessageContext(attempt.context, intent.context) ||
        attempt.createdAt < intent.createdAt || attempt.createdAt > now ||
        attempt.state.at < attempt.createdAt || attempt.state.at > now ||
        !intent.permittedRoutes.includes(attemptRouteId(attempt)) ||
        attemptIds.has(attempt.attemptId) || ordinals.has(attempt.ordinal)) {
      throw new Error("Delivery attempt is outside the intent or history");
    }
    attemptIds.add(attempt.attemptId);
    ordinals.add(attempt.ordinal);
  }
  for (let ordinal = 1; ordinal <= attempts.length; ordinal++) {
    if (!ordinals.has(ordinal)) throw new Error("Incomplete delivery history");
  }
  const routeIds = new Set<string>();
  for (const route of routes) {
    if (routeIds.has(route.routeId)) {
      throw new Error("Duplicate route readiness");
    }
    routeIds.add(route.routeId);
    if (route.state.kind !== "eligible") continue;
    const candidate = route.state.candidate;
    const candidateRoute = candidate.mode === "live" ?
      candidate.binding.routeId : candidate.routeId;
    if (candidate.mode !== intent.context.mode ||
        candidateRoute !== route.routeId ||
        route.state.permissionRevision.trim().length === 0) {
      throw new Error("Dispatch candidate is outside the intent context");
    }
  }
}

export function sameMessageContext(
  left: MessageIntent["context"], right: MessageIntent["context"]
): boolean {
  if (left.mode === "live") {
    return right.mode === "live" && left.eventId === right.eventId &&
      left.organizerId === right.organizerId;
  }
  return right.mode === "rehearsal" &&
    left.rehearsalId === right.rehearsalId &&
    left.virtualEventId === right.virtualEventId &&
      left.clockId === right.clockId;
}
