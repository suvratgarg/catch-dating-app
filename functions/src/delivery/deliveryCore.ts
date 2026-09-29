import {operationContentHash} from "../operations/durableActions";

/**
 * Shared messaging delivery core — the single owner of send execution for
 * Event Assistance, program Moments, and (later) campaigns.
 *
 * The lifecycle is source-agnostic: a durable intent (what/who/where a send
 * is allowed), a bounded attempt history, and a CAS outbox that reserves
 * before provider I/O, claims atomically, treats interrupted submissions as
 * `unknown` outcomes requiring reconciliation, and merges verified receipts.
 * What is *not* generic — intent validation, instruction revisions, context
 * equality, the record's extra evidence — lives behind a typed
 * `DeliverySourceAdapter` per producer. Producers keep their own collections
 * and generated contracts; they do not fabricate another domain's rows.
 */

// --- Core document shapes ----------------------------------------------------

export type DeliveryLifecycle =
  "active" | "responded" | "cancelled" | "superseded";

export type DeliveryAttemptState =
  | {kind: "reserved"; at: number; reconcileAfter: number}
  | {kind: "unknown"; at: number; providerMessageId: string | null;
    reason: string; reconcileAfter: number}
  | {kind: "accepted"; at: number; providerMessageId: string | null}
  | {kind: "delivered"; at: number; providerMessageId: string | null}
  | {kind: "read"; at: number; providerMessageId: string | null}
  | {kind: "failed"; at: number; providerMessageId: string | null;
    classification: string; evidenceId: string | null}
  | {kind: "revoked"; at: number; providerMessageId: string | null;
    evidenceId: string | null}
  | {kind: "notDispatched"; at: number; reason: string};

export interface DeliveryAuthorization {
  permissionRevision: string;
  checkedAt: number;
  validUntil: number;
  /** Frozen fact revision the reservation was authorized under. */
  instructionRevision: number;
}

interface AttemptBase {
  schemaVersion: number;
  attemptId: string;
  intentId: string;
  intentRevision: number;
  ordinal: number;
  createdAt: number;
  state: DeliveryAttemptState;
  authorization: DeliveryAuthorization;
}

/** The sender/endpoint authority frozen at reservation time. */
export interface LiveDeliveryBinding {
  routeId: string;
  senderId: string;
  bindingRevision: number;
  recipientEndpointId: string;
  /** "provider" means the channel owns channel-internal fallback. */
  fallbackOwner?: string;
}

export interface LiveDeliveryAttempt<B = LiveDeliveryBinding>
  extends AttemptBase {
  mode: "live";
  binding: B;
}

export interface RehearsalDeliveryAttempt extends AttemptBase {
  mode: "rehearsal";
  routeId: string;
}

export type DeliveryCoreAttempt<C = unknown, B = LiveDeliveryBinding> =
  (LiveDeliveryAttempt<B> | RehearsalDeliveryAttempt) & {context: C};

export type LiveCoreAttempt<A> = Extract<A, {mode: "live"}>;

export interface DeliveryPolicySpec {
  maxAttempts: number;
  maxAttemptsPerRoute: number;
  minimumRetrySeconds: number;
}

export interface DeliveryCoreIntent<C = unknown> {
  intentId: string;
  revision: number;
  context: C;
  createdAt: number;
  expiresAt: number;
  permittedRoutes: readonly string[];
  deliveryPolicy: DeliveryPolicySpec;
}

export interface DeliveryCoreRecord<
  I extends DeliveryCoreIntent,
  A extends DeliveryCoreAttempt,
> {
  schemaVersion: number;
  messageId: string;
  revision: number;
  intent: I;
  lifecycle: DeliveryLifecycle;
  attempts: A[];
  deliveryConflict: boolean;
  createdAt: number;
  updatedAt: number;
}

// --- Facts and decisions

export type DeliveryDispatchGate =
  | {kind: "allow"; checkedAt: number; validUntil: number;
    instructionRevision: number}
  | {kind: "stop"; reason: string};

export type DeliveryDispatchCandidate<B = LiveDeliveryBinding> =
  | {mode: "live"; binding: B}
  | {mode: "rehearsal"; routeId: string};

export type DeliveryRouteReadiness<B = LiveDeliveryBinding> = {
  routeId: string;
  state:
    | {kind: "eligible"; checkedAt: number; validUntil: number;
      permissionRevision: string;
      candidate: DeliveryDispatchCandidate<B>}
    | {kind: "blocked"; reason: string};
};

export interface DeliveryCoreFacts<B = LiveDeliveryBinding> {
  gate: DeliveryDispatchGate;
  routes: readonly DeliveryRouteReadiness<B>[];
}

export type DeliveryDecision<B = LiveDeliveryBinding> =
  | {kind: "stop"; reason: string}
  | {kind: "delivered"; attemptIds: string[]}
  | {kind: "reconcile"; attemptIds: string[]; notBefore: number}
  | {kind: "refreshFacts"; reason: "eventFactsStale" | "routeFactsStale"}
  | {kind: "wait"; notBefore: number; reason: "retryBackoff"}
  | {kind: "hostDecision"; reason: "noEligibleRoute" | "attemptLimit" |
    "policyRejected" | "recipientNeedsReview" | "providerOwnsFallback" |
    "conflictingDeliveryEvidence"}
  | {kind: "dispatch"; ordinal: number;
    candidate: DeliveryDispatchCandidate<B>;
    authorization: DeliveryAuthorization};

export interface DeliveryEvaluationInput<
  C = unknown,
  B = LiveDeliveryBinding,
> {
  intent: DeliveryCoreIntent<C>;
  lifecycle: DeliveryLifecycle;
  attempts: readonly DeliveryCoreAttempt<C, B>[];
  routes: readonly DeliveryRouteReadiness<B>[];
  gate: DeliveryDispatchGate;
  now: number;
}

// --- Source adapter

/**
 * What a messaging producer must supply to ride the shared lifecycle.
 * Parse functions own the source's generated contract validators; identity
 * and revision hooks keep source semantics inside the generic engine.
 */
export interface DeliverySourceAdapter<
  C,
  B extends LiveDeliveryBinding,
  I extends DeliveryCoreIntent<C>,
  A extends DeliveryCoreAttempt<C, B>,
  R extends DeliveryCoreRecord<I, A>,
> {
  /** Private collection this source's records live in. */
  readonly collection: string;
  /** Deterministic record identity from the immutable intent. */
  messageId(intent: I): string;
  parseIntent(value: unknown): I;
  parseAttempt(value: unknown): A;
  parseRecord(value: unknown): R;
  /** Builds the empty record for a new, unexpired intent. */
  newRecord(intent: I, now: number): R;
  /**
   * The frozen fact revision a reservation is authorized under — e.g. EA's
   * guidance/instruction revision. Replay safety: an attempt authorized under
   * a stale revision can never be claimed.
   */
  instructionRevisionOf(intent: I): number;
  sameContext(left: C, right: C): boolean;
  /** Source-specific record-level stop (e.g. a host handoff). */
  recordStopReason(record: R): string | null;
  /** Route id used for per-route attempt counting and selection. */
  routeIdOf(attempt: A): string;
  /**
   * Validate a route's dispatch candidate shape against the source's
   * generated contract (binding fields, rehearsal route id). Authority is
   * frozen only on selection; this only proves the candidate is well-formed.
   */
  assertDispatchCandidate(
    candidate: DeliveryDispatchCandidate<B>, intent: I, now: number
  ): void;
  /** Update a record inside the transaction (the adapter returns the next
   *  record; the outbox owns revision/updatedAt stamping). */
  withAttempts(record: R, attempts: A[]): R;
  withLifecycle(record: R, lifecycle: DeliveryLifecycle): R;
  withDeliveryConflict(record: R, conflict: boolean): R;
}

// --- Policy evaluation

export function attemptStateDisposition(state: DeliveryAttemptState):
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

export function liveBindingRouteId(binding: LiveDeliveryBinding): string {
  return binding.routeId;
}

function coreAttemptRouteId(attempt: DeliveryCoreAttempt): string {
  return attempt.mode === "live" ? attempt.binding.routeId : attempt.routeId;
}

function fresh(value: {checkedAt: number; validUntil: number}, now: number) {
  return Number.isSafeInteger(value.checkedAt) &&
    value.checkedAt >= 0 &&
    Number.isSafeInteger(value.validUntil) &&
    value.checkedAt <= now && value.validUntil > now;
}

type DeliveryEvaluationAdapter<C, B extends LiveDeliveryBinding,
  I extends DeliveryCoreIntent<C>, A extends DeliveryCoreAttempt<C, B>> =
  Pick<DeliverySourceAdapter<C, B, I, A, DeliveryCoreRecord<I, A>>,
    "instructionRevisionOf" | "sameContext" | "assertDispatchCandidate">;

/**
 * Pure route/authority selection — ported verbatim from Event Assistance's
 * `evaluateMessageDelivery`. Source semantics enter only through the adapter
 * hooks (`instructionRevisionOf`, `sameContext`).
 */
export function evaluateDelivery<
  C,
  B extends LiveDeliveryBinding,
  I extends DeliveryCoreIntent<C>,
  A extends DeliveryCoreAttempt<C, B>,
>(
  input: DeliveryEvaluationInput<C, B> & {intent: I; attempts: readonly A[]},
  adapter: DeliveryEvaluationAdapter<C, B, I, A>,
): DeliveryDecision<B> {
  const {intent, lifecycle, gate, now} = input;
  assertDeliveryHistory(input, adapter);
  if (lifecycle !== "active") return {kind: "stop", reason: lifecycle};
  if (now >= intent.expiresAt) return {kind: "stop", reason: "expired"};
  if (gate.kind === "stop") return {kind: "stop", reason: gate.reason};
  if (!fresh(gate, now)) {
    return {kind: "refreshFacts", reason: "eventFactsStale"};
  }
  const revision = adapter.instructionRevisionOf(intent);
  if (gate.instructionRevision !== revision) {
    return {kind: "stop", reason: "superseded"};
  }
  const delivered = input.attempts.filter((attempt) =>
    attemptStateDisposition(attempt.state) === "delivered");
  if (delivered.length > 0) {
    return {kind: "delivered", attemptIds: delivered.map((a) => a.attemptId)};
  }
  const unresolved = input.attempts.filter((attempt) =>
    attemptStateDisposition(attempt.state) === "pending");
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
        throw new Error("Unhandled delivery failure classification");
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
  const counts = new Map<string, number>();
  for (const attempt of input.attempts) {
    // Proven unsent reservations still consume the total recovery ceiling,
    // but cannot exhaust a channel's submission allowance.
    if (attempt.state.kind === "notDispatched") continue;
    const route = coreAttemptRouteId(attempt);
    counts.set(route, (counts.get(route) ?? 0) + 1);
  }
  const candidates = intent.permittedRoutes.map((id) =>
    input.routes.find((route) => route.routeId === id)).filter(
    (route): route is DeliveryRouteReadiness<B> => route !== undefined
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

/** History legality shared by the wire adapters' generated validators. */
function assertDeliveryHistory<C, B extends LiveDeliveryBinding,
  I extends DeliveryCoreIntent<C>, A extends DeliveryCoreAttempt<C, B>>(
  input: DeliveryEvaluationInput<C, B> & {intent: I; attempts: readonly A[]},
  adapter: DeliveryEvaluationAdapter<C, B, I, A>,
): void {
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
          adapter.instructionRevisionOf(intent) ||
        !adapter.sameContext(attempt.context, intent.context) ||
        attempt.createdAt < intent.createdAt || attempt.createdAt > now ||
        attempt.state.at < attempt.createdAt || attempt.state.at > now ||
        !intent.permittedRoutes.includes(coreAttemptRouteId(attempt)) ||
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
    if (route.state.permissionRevision.trim().length === 0 ||
        candidateRoute !== route.routeId) {
      throw new Error("Dispatch candidate is outside the intent context");
    }
    if (candidate.mode !==
        (intent.context as {mode?: string} | null)?.mode) {
      throw new Error("Dispatch candidate is outside the intent context");
    }
    adapter.assertDispatchCandidate(candidate, input.intent, now);
  }
}

/**
 * Deterministic reservation. Persistence must win before a provider call.
 * The adapter builds/validates the source-typed attempt; the core supplies
 * ordinal, identity, authorization, and the reconcile clock.
 */
export function prepareCoreDeliveryAttempt<
  C,
  B extends LiveDeliveryBinding,
  I extends DeliveryCoreIntent<C>,
  A extends DeliveryCoreAttempt<C, B>,
>(
  input: DeliveryEvaluationInput<C, B> & {intent: I; attempts: readonly A[]},
  adapter: DeliveryEvaluationAdapter<C, B, I, A>,
): A | null {
  const decision = evaluateDelivery(input, adapter);
  if (decision.kind !== "dispatch") return null;
  const {intent, now} = input;
  const candidate = decision.candidate;
  const routeId = candidate.mode === "live" ?
    candidate.binding.routeId : candidate.routeId;
  const base = {
    schemaVersion: 1,
    attemptId: "attempt:" + operationContentHash([
      intent.context, intent.intentId, intent.revision,
      routeId, decision.ordinal,
    ]),
    intentId: intent.intentId,
    intentRevision: intent.revision,
    ordinal: decision.ordinal,
    createdAt: now,
    state: {kind: "reserved" as const, at: now, reconcileAfter:
      Math.min(now + 120_000, decision.authorization.validUntil)},
    authorization: decision.authorization,
  };
  const raw = candidate.mode === "live" ? {
    ...base, mode: "live" as const, context: intent.context,
    binding: candidate.binding,
  } : {...base, mode: "rehearsal" as const, context: intent.context,
    routeId};
  return raw as A;
}

export type DeliveryPermitResult<A, R> =
  | {kind: "claimed"; record: R;
    attempt: LiveCoreAttempt<A>; validUntil: number}
  | {kind: "withheld"; record: R;
    reason: "notReserved" | "rehearsal" | "authorityChanged" |
      "authorizationExpired" | "deliveryConflict" | "resourceUnavailable"};

/**
 * Remove just the unsent reservation when re-evaluating fresh authority. Its
 * immutable sender and permission must still be the selected route. A changed
 * channel never silently repurposes the old attempt id.
 */
export function canClaimCoreAttempt<
  C,
  B extends LiveDeliveryBinding,
  I extends DeliveryCoreIntent<C>,
  A extends DeliveryCoreAttempt<C, B>,
  R extends DeliveryCoreRecord<I, A>,
>(
  record: R, attemptId: string, facts: DeliveryCoreFacts<B>, now: number,
  adapter: DeliverySourceAdapter<C, B, I, A, R>,
): {kind: "allow"; attempt: LiveCoreAttempt<A>; validUntil: number} |
  {kind: "withheld"; reason: Extract<DeliveryPermitResult<A, R>,
    {kind: "withheld"}>["reason"]} {
  const attempt = record.attempts.find((a) => a.attemptId === attemptId);
  if (adapter.recordStopReason(record) !== null) {
    return {kind: "withheld", reason: "authorityChanged"};
  }
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
  const decision = evaluateDelivery({...facts,
    intent: record.intent, lifecycle: record.lifecycle, now,
    attempts: record.attempts.filter((a) => a.attemptId !== attemptId)},
  adapter);
  const candidate: DeliveryDispatchCandidate<B> =
    {mode: "live", binding: attempt.binding};
  if (decision.kind !== "dispatch" || decision.ordinal !== attempt.ordinal ||
      operationContentHash(decision.candidate) !==
        operationContentHash(candidate) ||
      decision.authorization.permissionRevision !==
        attempt.authorization.permissionRevision ||
      decision.authorization.instructionRevision !==
        attempt.authorization.instructionRevision) {
    return {kind: "withheld", reason: "authorityChanged"};
  }
  return {kind: "allow", attempt: attempt as LiveCoreAttempt<A>,
    validUntil: Math.min(attempt.authorization.validUntil,
      decision.authorization.validUntil)};
}

function unhandled(value: never): never {
  void value;
  throw new Error("Unhandled delivery variant");
}

// --- Provider receipts

/** Confirmed provider evidence — never a raw HTTP body. */
export type ConfirmedDeliveryState = Extract<DeliveryAttemptState,
  {kind: "accepted" | "delivered" | "read" | "failed" | "revoked"}>;

export interface VerifiedCoreReceipt<B = LiveDeliveryBinding> {
  attemptId: string;
  senderId: string;
  bindingRevision: number;
  recipientEndpointId: string;
  routeId: B extends LiveDeliveryBinding ? B["routeId"] : string;
  providerEventId: string;
  receivedAt: number;
  /** Normalized provider evidence; `at` uses the server receipt clock. */
  state: ConfirmedDeliveryState;
}

export type DeliveryReceiptMerge<A> = {
  attempt: LiveCoreAttempt<A>;
  disposition: "applied" | "duplicateOrOlder" | "conflictingEvidence";
};

/** Pure evidence ordering, shared by verified live receipts and simulation. */
export function mergeCoreConfirmedState<
  C, B extends LiveDeliveryBinding,
  A extends DeliveryCoreAttempt<C, B>,
>(
  attempt: A, state: ConfirmedDeliveryState,
  parseAttempt: (value: unknown) => A,
): {attempt: A; disposition: "applied" | "duplicateOrOlder" |
    "conflictingEvidence"} {
  parseAttempt(attempt);
  if (!["accepted", "delivered", "read", "failed", "revoked"]
    .includes(state.kind)) {
    throw new Error("Invalid confirmed delivery state");
  }
  const previous = attempt.state;
  const previousId = "providerMessageId" in previous ?
    previous.providerMessageId : null;
  const nextId = state.providerMessageId;
  if (previousId !== null && nextId !== null && previousId !== nextId) {
    throw new Error("Provider message identity mismatch");
  }
  const next: DeliveryAttemptState = {
    ...state,
    providerMessageId: nextId ?? previousId,
  } as DeliveryAttemptState;
  parseAttempt({...attempt, state: next});
  const delivered = (s: DeliveryAttemptState) =>
    s.kind === "delivered" || s.kind === "read";
  const nonDelivery = (s: DeliveryAttemptState) =>
    s.kind === "failed" || s.kind === "revoked" ||
    s.kind === "notDispatched";
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

/**
 * Invoke only after authenticating and correlating the provider callback.
 * The receipt must match the claimed attempt's frozen binding.
 */
export function mergeCoreDeliveryReceipt<
  C, B extends LiveDeliveryBinding,
  A extends DeliveryCoreAttempt<C, B>,
>(
  attempt: A, receipt: VerifiedCoreReceipt<B>,
  parseAttempt: (value: unknown) => A,
): DeliveryReceiptMerge<A> {
  parseAttempt(attempt);
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
  const merged = mergeCoreConfirmedState(attempt, receipt.state,
    parseAttempt);
  if (merged.attempt.mode !== "live") {
    throw new Error("Live receipt changed execution mode");
  }
  return {attempt: merged.attempt as LiveCoreAttempt<A>,
    disposition: merged.disposition};
}
