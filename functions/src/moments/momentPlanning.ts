import {
  requireMillis,
  type AnchorFacts,
  type MomentDefinition,
  type MomentInitiation,
  type RunRecord,
} from "./momentModel";

export type ResolvedAnchor = {
  kind: "resolved";
  atMillis: number;
  anchorRevision: number;
} | {
  kind: "unresolved";
  reason: "missingAnchor" | "anchorCancelled" | "notTimeBased";
};

export type UnplannableReason =
  "notArmed" | "missingAnchor" | "anchorCancelled" | "manualInitiation" |
    "triggeredInitiation" | "dueInPast";

export type PlanResult = {
  kind: "planned";
  run: RunRecord;
} | {
  kind: "unplannable";
  reason: UnplannableReason;
};

export interface ReplanResult {
  supersede: string[];
  create: RunRecord | null;
  keep: string[];
  unplannableReason?: UnplannableReason;
}

export type FireDisposition =
  "dispatch" | "skip:momentNotArmed" | "skip:messagingDisabled" |
    "skip:scopeCancelled" | "skip:functionCancelled" | "skip:staleAnchor" |
    "skip:anchorPassed";

const DEFAULT_GRACE_MILLIS = 5 * 60_000;

/** Scheduled runs do not depend on a mutable anchor; revision is fixed. */
const SCHEDULED_ANCHOR_REVISION = 0;

/**
 * Resolves the absolute time an initiation refers to (before offset).
 * Manual and triggered initiations are not time-based.
 */
export function resolveAnchor(
  initiation: MomentInitiation,
  facts: AnchorFacts,
): ResolvedAnchor {
  if (initiation.kind === "scheduled") {
    requireMillis(initiation.atMillis);
    return {
      kind: "resolved",
      atMillis: initiation.atMillis,
      anchorRevision: SCHEDULED_ANCHOR_REVISION,
    };
  }
  if (initiation.kind !== "anchored") {
    return {kind: "unresolved", reason: "notTimeBased"};
  }
  switch (initiation.anchorKind) {
  case "functionStart":
  case "functionEnd": {
    const fn = initiation.anchorId === null ?
      undefined : facts.functions[initiation.anchorId];
    if (!fn) return {kind: "unresolved", reason: "missingAnchor"};
    requireMillis(fn.startsAtMillis);
    requireMillis(fn.endsAtMillis);
    if (fn.cancelled) {
      return {kind: "unresolved", reason: "anchorCancelled"};
    }
    return {
      kind: "resolved",
      atMillis: initiation.anchorKind === "functionStart" ?
        fn.startsAtMillis : fn.endsAtMillis,
      anchorRevision: fn.revision,
    };
  }
  case "scopeStart": {
    requireMillis(facts.scope.startsAtMillis);
    if (facts.scope.cancelled) {
      return {kind: "unresolved", reason: "anchorCancelled"};
    }
    return {
      kind: "resolved",
      atMillis: facts.scope.startsAtMillis,
      anchorRevision: facts.scope.revision,
    };
  }
  case "scopeEnd": {
    const end = facts.scope.endsAtMillis;
    if (end === null) return {kind: "unresolved", reason: "missingAnchor"};
    requireMillis(end);
    if (facts.scope.cancelled) {
      return {kind: "unresolved", reason: "anchorCancelled"};
    }
    return {
      kind: "resolved",
      atMillis: end,
      anchorRevision: facts.scope.revision,
    };
  }
  case "rsvpDeadline": {
    const deadline = facts.scope.rsvpDeadlineAtMillis;
    if (deadline === null) {
      return {kind: "unresolved", reason: "missingAnchor"};
    }
    requireMillis(deadline);
    return {
      kind: "resolved",
      atMillis: deadline,
      anchorRevision: facts.scope.revision,
    };
  }
  case "travelLegTime": {
    const plan = initiation.anchorId === null ?
      undefined : facts.travelLegs[initiation.anchorId];
    if (!plan) return {kind: "unresolved", reason: "missingAnchor"};
    requireMillis(plan.atMillis);
    return {
      kind: "resolved",
      atMillis: plan.atMillis,
      anchorRevision: plan.revision,
    };
  }
  }
}

export function planRun(
  moment: MomentDefinition,
  facts: AnchorFacts,
  nowMillis: number,
  options?: {graceMillis?: number},
): PlanResult {
  const graceMillis = options?.graceMillis ?? DEFAULT_GRACE_MILLIS;
  requireMillis(nowMillis);
  requireMillis(graceMillis);
  if (moment.status !== "armed") {
    return {kind: "unplannable", reason: "notArmed"};
  }
  const {initiation} = moment;
  if (initiation.kind === "manual") {
    return {kind: "unplannable", reason: "manualInitiation"};
  }
  if (initiation.kind === "triggered") {
    return {kind: "unplannable", reason: "triggeredInitiation"};
  }
  const anchor = resolveAnchor(initiation, facts);
  if (anchor.kind !== "resolved") {
    return {
      kind: "unplannable",
      reason: anchor.reason === "notTimeBased" ?
        "manualInitiation" : anchor.reason,
    };
  }
  const offsetMillis = initiation.kind === "anchored" ?
    initiation.offsetMinutes * 60_000 : 0;
  const dueAtMillis = anchor.atMillis + offsetMillis;
  requireMillis(dueAtMillis);
  if (dueAtMillis < nowMillis - graceMillis) {
    return {kind: "unplannable", reason: "dueInPast"};
  }
  return {
    kind: "planned",
    run: {
      runId: `${moment.momentId}_${anchor.anchorRevision}_${dueAtMillis}`,
      momentId: moment.momentId,
      dueAtMillis,
      anchorRevision: anchor.anchorRevision,
      status: "planned",
    },
  };
}

export function replan(
  moment: MomentDefinition,
  facts: AnchorFacts,
  existingRuns: ReadonlyArray<RunRecord>,
  nowMillis: number,
): ReplanResult {
  const planned = existingRuns.filter(
    (run) => run.momentId === moment.momentId && run.status === "planned");
  const result = planRun(moment, facts, nowMillis);
  if (result.kind !== "planned") {
    return {
      supersede: planned.map((run) => run.runId),
      create: null,
      keep: [],
      unplannableReason: result.reason,
    };
  }
  const keep = planned
    .filter((run) => run.runId === result.run.runId)
    .map((run) => run.runId);
  const supersede = planned
    .filter((run) => run.runId !== result.run.runId)
    .map((run) => run.runId);
  return {supersede, create: keep.length > 0 ? null : result.run, keep};
}

/**
 * A manual moment fires exactly when the organizer says so. The run id is
 * keyed on the request's idempotency token so a retried "send now" cannot
 * double-send.
 */
export function planManualRun(
  moment: MomentDefinition,
  requestKey: string,
  nowMillis: number,
): PlanResult {
  requireMillis(nowMillis);
  if (moment.status !== "armed") {
    return {kind: "unplannable", reason: "notArmed"};
  }
  if (moment.initiation.kind !== "manual") {
    return {kind: "unplannable", reason: "triggeredInitiation"};
  }
  if (typeof requestKey !== "string" || requestKey.trim().length === 0) {
    throw new RangeError("Manual run request key must be non-empty.");
  }
  return {
    kind: "planned",
    run: {
      runId: `${moment.momentId}_manual_${requestKey}`,
      momentId: moment.momentId,
      dueAtMillis: nowMillis,
      anchorRevision: SCHEDULED_ANCHOR_REVISION,
      status: "planned",
    },
  };
}

export function selectDueRuns(
  runs: ReadonlyArray<RunRecord>,
  nowMillis: number,
  limit: number,
): RunRecord[] {
  requireMillis(nowMillis);
  if (!Number.isSafeInteger(limit) || limit <= 0) {
    throw new RangeError("Due-run limit must be a positive safe integer.");
  }
  return runs
    .filter((run) => run.status === "planned" && run.dueAtMillis <= nowMillis)
    .sort((a, b) => a.dueAtMillis - b.dueAtMillis ||
      a.runId.localeCompare(b.runId))
    .slice(0, limit);
}

export function resolveFireDisposition(
  run: RunRecord,
  moment: MomentDefinition,
  facts: AnchorFacts,
  nowMillis?: number,
): FireDisposition {
  if (moment.status !== "armed") return "skip:momentNotArmed";
  if (facts.scope.cancelled) return "skip:scopeCancelled";
  if (moment.action.kind === "sendTemplate" &&
      !facts.scope.messagingEnabled) {
    return "skip:messagingDisabled";
  }
  const functionIds = new Set<string>();
  const {initiation} = moment;
  if (initiation.kind === "anchored" &&
      (initiation.anchorKind === "functionStart" ||
       initiation.anchorKind === "functionEnd") &&
      initiation.anchorId !== null) {
    functionIds.add(initiation.anchorId);
  }
  if (initiation.kind === "triggered" && initiation.functionId !== null) {
    functionIds.add(initiation.functionId);
  }
  if (moment.audience.kind === "functionGuests") {
    functionIds.add(moment.audience.functionId);
  }
  if (run.targetFunctionId !== undefined) {
    functionIds.add(run.targetFunctionId);
  }
  for (const functionId of functionIds) {
    if (facts.functions[functionId]?.cancelled) {
      return "skip:functionCancelled";
    }
  }
  if (initiation.kind !== "anchored") {
    return "dispatch";
  }
  const currentRevision = currentAnchorRevision(initiation, facts);
  if (currentRevision === null || currentRevision !== run.anchorRevision) {
    return "skip:staleAnchor";
  }
  // A "before the anchor" send is pointless once the anchor has passed —
  // a T-15m reminder delivered after the event started is worse than
  // none. Post-anchor sends (positive offsets) stay valid when late.
  if (nowMillis !== undefined && initiation.offsetMinutes <= 0) {
    const anchor = resolveAnchor(initiation, facts);
    if (anchor.kind === "resolved" && anchor.atMillis <= nowMillis) {
      return "skip:anchorPassed";
    }
  }
  return "dispatch";
}

function currentAnchorRevision(
  initiation: Extract<MomentInitiation, {kind: "anchored"}>,
  facts: AnchorFacts,
): number | null {
  switch (initiation.anchorKind) {
  case "functionStart":
  case "functionEnd":
    return initiation.anchorId === null ?
      null : facts.functions[initiation.anchorId]?.revision ?? null;
  case "scopeStart":
  case "scopeEnd":
  case "rsvpDeadline":
    return facts.scope.revision;
  case "travelLegTime":
    return initiation.anchorId === null ?
      null : facts.travelLegs[initiation.anchorId]?.revision ?? null;
  }
}
