import {
  requireMillis,
  type AnchorFacts,
  type MomentDefinition,
  type MomentTrigger,
  type RunRecord,
} from "./momentModel";

export type ResolvedAnchor = {
  kind: "resolved";
  atMillis: number;
  anchorRevision: number;
} | {
  kind: "unresolved";
  reason: "missingAnchor" | "anchorCancelled" | "conditionTrigger";
};

export type UnplannableReason =
  "notArmed" | "missingAnchor" | "anchorCancelled" | "conditionTrigger" |
    "dueInPast";

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
    "skip:functionCancelled" | "skip:staleAnchor";

const DEFAULT_GRACE_MILLIS = 5 * 60_000;

export function resolveAnchor(
  trigger: MomentTrigger,
  facts: AnchorFacts,
): ResolvedAnchor {
  if (trigger.kind !== "timeAnchor") {
    return {kind: "unresolved", reason: "conditionTrigger"};
  }
  switch (trigger.anchorKind) {
  case "functionStart":
  case "functionEnd": {
    const fn = trigger.anchorId === null ?
      undefined : facts.functions[trigger.anchorId];
    if (!fn) return {kind: "unresolved", reason: "missingAnchor"};
    requireMillis(fn.startsAtMillis);
    requireMillis(fn.endsAtMillis);
    if (fn.cancelled) {
      return {kind: "unresolved", reason: "anchorCancelled"};
    }
    return {
      kind: "resolved",
      atMillis: trigger.anchorKind === "functionStart" ?
        fn.startsAtMillis : fn.endsAtMillis,
      anchorRevision: fn.revision,
    };
  }
  case "programStart": {
    requireMillis(facts.program.startsAtMillis);
    return {
      kind: "resolved",
      atMillis: facts.program.startsAtMillis,
      anchorRevision: facts.program.revision,
    };
  }
  case "rsvpDeadline": {
    const deadline = facts.program.rsvpDeadlineAtMillis;
    if (deadline === null) {
      return {kind: "unresolved", reason: "missingAnchor"};
    }
    requireMillis(deadline);
    return {
      kind: "resolved",
      atMillis: deadline,
      anchorRevision: facts.program.revision,
    };
  }
  case "transportPlanDeparture": {
    const plan = trigger.anchorId === null ?
      undefined : facts.transportPlans[trigger.anchorId];
    if (!plan) return {kind: "unresolved", reason: "missingAnchor"};
    requireMillis(plan.departureAtMillis);
    return {
      kind: "resolved",
      atMillis: plan.departureAtMillis,
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
  const anchor = resolveAnchor(moment.trigger, facts);
  if (anchor.kind !== "resolved" ||
      moment.trigger.kind !== "timeAnchor") {
    return {kind: "unplannable", reason: anchor.kind === "resolved" ?
      "conditionTrigger" : anchor.reason};
  }
  const dueAtMillis =
    anchor.atMillis + moment.trigger.offsetMinutes * 60_000;
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
): FireDisposition {
  if (moment.status !== "armed") return "skip:momentNotArmed";
  if (moment.action.kind === "sendTemplate" &&
      !facts.program.messagingEnabled) {
    return "skip:messagingDisabled";
  }
  const functionIds = new Set<string>();
  if (moment.trigger.kind === "timeAnchor" &&
      (moment.trigger.anchorKind === "functionStart" ||
       moment.trigger.anchorKind === "functionEnd") &&
      moment.trigger.anchorId !== null) {
    functionIds.add(moment.trigger.anchorId);
  }
  if (moment.trigger.kind === "conditionAnchor" &&
      moment.trigger.functionId !== null) {
    functionIds.add(moment.trigger.functionId);
  }
  if (moment.audience.kind === "functionGuests") {
    functionIds.add(moment.audience.functionId);
  }
  for (const functionId of functionIds) {
    if (facts.functions[functionId]?.cancelled) {
      return "skip:functionCancelled";
    }
  }
  const currentRevision = currentAnchorRevision(moment.trigger, facts);
  if (currentRevision === null || currentRevision !== run.anchorRevision) {
    return "skip:staleAnchor";
  }
  return "dispatch";
}

function currentAnchorRevision(
  trigger: MomentTrigger,
  facts: AnchorFacts,
): number | null {
  if (trigger.kind === "conditionAnchor") {
    if (trigger.functionId === null) return 0;
    return facts.functions[trigger.functionId]?.revision ?? null;
  }
  switch (trigger.anchorKind) {
  case "functionStart":
  case "functionEnd":
    return trigger.anchorId === null ?
      null : facts.functions[trigger.anchorId]?.revision ?? null;
  case "programStart":
  case "rsvpDeadline":
    return facts.program.revision;
  case "transportPlanDeparture":
    return trigger.anchorId === null ?
      null : facts.transportPlans[trigger.anchorId]?.revision ?? null;
  }
}
