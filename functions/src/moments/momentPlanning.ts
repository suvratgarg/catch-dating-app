import {
  requireMillis,
  type AnchorFacts,
  type MomentDefinition,
  type MomentInitiation,
  type RunRecord,
} from "./momentModel";
import {
  maxTravelLeadMinutes,
  type TravelEstimateContext,
} from "./momentTravel";

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
  reschedule: Array<{runId: string; dueAtMillis: number;
    plannedWakeAtMillis: number; travelPlanHash: string}>;
  unplannableReason?: UnplannableReason;
}

export type FireDisposition =
  "dispatch" | "skip:momentNotArmed" | "skip:messagingDisabled" |
    "skip:scopeCancelled" | "skip:functionCancelled" | "skip:staleAnchor" |
    "skip:anchorPassed" | "skip:expired";

const DEFAULT_GRACE_MILLIS = 5 * 60_000;

/** Product default zone for calendar offsets when a scope doc carries no
 *  timezone; mirrors the quiet-hours default in momentWiring. */
export const DEFAULT_SCOPE_TIMEZONE = "Asia/Kolkata";

/** A post-anchor or fixed-date send may still be useful up to a day late;
 *  beyond that a missed run expires instead of firing stale copy. */
export const LATE_FIRE_WINDOW_MILLIS = 24 * 60 * 60_000;

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

interface CivilParts {
  year: number; month: number; day: number;
  hour: number; minute: number; second: number; ms: number;
}

function civilPartsAt(epochMs: number, timeZone: string): CivilParts {
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone, hourCycle: "h23", year: "numeric", month: "2-digit",
    day: "2-digit", hour: "2-digit", minute: "2-digit", second: "2-digit",
  }).formatToParts(new Date(epochMs));
  const get = (type: string) =>
    Number(parts.find((p) => p.type === type)?.value ?? 0);
  return {
    year: get("year"), month: get("month"), day: get("day"),
    hour: get("hour") % 24, minute: get("minute"), second: get("second"),
    ms: epochMs - Math.floor(epochMs / 1000) * 1000,
  };
}

function daysInMonth(year: number, month: number): number {
  return new Date(Date.UTC(year, month, 0)).getUTCDate();
}

/**
 * Converts a civil ("wall-clock") instant in `timeZone` back to epoch ms.
 * The zone offset depends on the answer, so iterate: offset(guess) =
 * civil-as-UTC minus guess converges within three passes because the
 * offset is piecewise-constant around the result. DST gaps resolve to the
 * edge the formatter reports; folds resolve deterministically.
 */
function localToEpoch(civilUtc: number, timeZone: string): number {
  let instant = civilUtc;
  for (let i = 0; i < 3; i += 1) {
    const p = civilPartsAt(instant, timeZone);
    const offset = Date.UTC(p.year, p.month - 1, p.day,
      p.hour, p.minute, p.second, p.ms) - instant;
    instant = civilUtc - offset;
  }
  return instant;
}

/**
 * Wall-clock shift in the scope's timezone: `months` first, then `days`,
 * preserving the anchor's local time-of-day. The day-of-month clamps to
 * the target month's length (Jan 31 − 1 month → Dec 31, +1 month → Feb
 * 28/29); days then shift the resulting civil date. Returns the anchor
 * unchanged when both shifts are zero.
 */
export function shiftLocalCalendar(
  atMillis: number,
  months: number,
  days: number,
  timeZone: string,
): number {
  if (!Number.isSafeInteger(months) || !Number.isSafeInteger(days)) {
    throw new RangeError("Calendar offsets must be whole units.");
  }
  if (months === 0 && days === 0) return atMillis;
  const p = civilPartsAt(atMillis, timeZone);
  const monthTotal = p.year * 12 + (p.month - 1) + months;
  const year = Math.floor(monthTotal / 12);
  const month = (monthTotal % 12) + 1;
  const day = Math.min(p.day, daysInMonth(year, month));
  return localToEpoch(
    Date.UTC(year, month - 1, day + days,
      p.hour, p.minute, p.second, p.ms),
    timeZone);
}

/**
 * The anchor-plus-offsets instant for an anchored initiation: calendar
 * months/days shift the local wall clock in the scope zone; minutes then
 * apply as an absolute-time shift (DST-accurate).
 */
export function effectiveDueAtMillis(
  initiation: Extract<MomentInitiation, {kind: "anchored"}>,
  anchorAtMillis: number,
  timeZone: string,
): number {
  const shifted = shiftLocalCalendar(anchorAtMillis,
    initiation.offsetMonths ?? 0, initiation.offsetDays ?? 0, timeZone);
  return shifted + initiation.offsetMinutes * 60_000;
}

/**
 * The instant past which a run may no longer fire. A before-the-anchor
 * reminder is meaningless once the anchored fact exists — it dies at the
 * anchor (matching the anchorPassed disposition); post-anchor and
 * fixed-date sends get a bounded late window.
 */
function runExpiryAtMillis(
  initiation: MomentInitiation,
  anchor: Extract<ResolvedAnchor, {kind: "resolved"}>,
  nominalDue: number,
): number {
  if (initiation.kind === "anchored" && nominalDue <= anchor.atMillis) {
    return anchor.atMillis;
  }
  return nominalDue + LATE_FIRE_WINDOW_MILLIS;
}

export function planRun(
  moment: MomentDefinition,
  facts: AnchorFacts,
  nowMillis: number,
  options?: {
    graceMillis?: number;
    /** Distance-lead context; the run wakes early enough for the farthest
     *  hotel-linked guest, without changing its occurrence identity. */
    travel?: TravelEstimateContext | null;
    /** Runner override from the resolved audience; avoids unrelated groups. */
    travelLeadMinutes?: number;
  },
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
  const timeZone = facts.scope.timeZone ?? DEFAULT_SCOPE_TIMEZONE;
  const nominalDue = initiation.kind === "anchored" ?
    effectiveDueAtMillis(initiation, anchor.atMillis, timeZone) :
    anchor.atMillis;
  const wantsLead = moment.audience.kind === "functionGuests" &&
    moment.audience.travelTimeLead === true;
  const travelLeadMinutes = wantsLead && options?.travel ?
    options.travelLeadMinutes ?? maxTravelLeadMinutes(options.travel) : 0;
  if (!Number.isSafeInteger(travelLeadMinutes) || travelLeadMinutes < 0) {
    throw new RangeError("Travel lead must be non-negative whole minutes.");
  }
  const travelLeadMillis = travelLeadMinutes * 60_000;
  requireMillis(nominalDue);
  const dueAtMillis = nominalDue - travelLeadMillis;
  requireMillis(dueAtMillis);
  // The send window is nominal-relative: the lead only moves the wake-up,
  // so staleness is judged on the nominal due. A deferred run mid-flight
  // keeps planning until every recipient's own due has passed.
  if (nominalDue < nowMillis - graceMillis) {
    return {kind: "unplannable", reason: "dueInPast"};
  }
  return {
    kind: "planned",
    run: {
      runId: `${moment.momentId}_${anchor.anchorRevision}_${nominalDue}`,
      momentId: moment.momentId,
      dueAtMillis,
      nominalDueAtMillis: nominalDue,
      expiresAtMillis: runExpiryAtMillis(initiation, anchor, nominalDue),
      occurrenceVersion: 2,
      ...(wantsLead && options?.travel ?
        {plannedWakeAtMillis: dueAtMillis} : {}),
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
  options?: {travel?: TravelEstimateContext | null;
    travelLeadMinutes?: number;
    travelPlanHash?: string},
): ReplanResult {
  const planned = existingRuns.filter(
    (run) => run.momentId === moment.momentId && run.status === "planned");
  const result = planRun(moment, facts, nowMillis, {
    travel: options?.travel,
    travelLeadMinutes: options?.travelLeadMinutes,
  });
  if (result.kind !== "planned") {
    // Planning grace is a create-time gate only. A run that already
    // materialized stays live past its nominal due — expiry and
    // anchor-passed checks decide whether it still fires; superseding it
    // here would silently erase a quiet-hours-deferred occurrence.
    let retained: string | null = null;
    if (result.reason === "dueInPast") {
      const identity = planRun(moment, facts, nowMillis, {
        travel: options?.travel,
        travelLeadMinutes: options?.travelLeadMinutes,
        graceMillis: Number.MAX_SAFE_INTEGER,
      });
      if (identity.kind === "planned" &&
          planned.some((run) => run.runId === identity.run.runId)) {
        retained = identity.run.runId;
      }
    }
    return {
      supersede: planned.map((run) => run.runId)
        .filter((runId) => runId !== retained),
      create: null,
      keep: retained === null ? [] : [retained],
      reschedule: [],
      unplannableReason: result.reason,
    };
  }
  const keep = planned
    .filter((run) => run.runId === result.run.runId)
    .map((run) => run.runId);
  const supersede = planned
    .filter((run) => run.runId !== result.run.runId)
    .map((run) => run.runId);
  const matching = planned.find((run) => run.runId === result.run.runId);
  const reschedule = matching && result.run.plannedWakeAtMillis !== undefined &&
      options?.travelPlanHash &&
      matching.travelPlanHash !== options.travelPlanHash ? [{
      runId: matching.runId,
      dueAtMillis: result.run.plannedWakeAtMillis,
      plannedWakeAtMillis: result.run.plannedWakeAtMillis,
      travelPlanHash: options.travelPlanHash,
    }] : [];
  const create = keep.length > 0 ? null : {
    ...result.run,
    ...(options?.travelPlanHash ?
      {travelPlanHash: options.travelPlanHash} : {}),
  };
  return {supersede, create, keep, reschedule};
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

/**
 * The anchor+offset time a travel-lead run counts down from. Recipients
 * fire at `nominal − theirLead`; the run's own dueAt is nominal minus the
 * cohort max. Triggered/manual runs and unresolvable anchors have no
 * nominal — the run's dueAt stands in so every recipient fires at once.
 */
export function nominalDueAtMillis(
  moment: MomentDefinition,
  run: RunRecord,
  facts: AnchorFacts,
): number {
  if (moment.initiation.kind === "scheduled") {
    return moment.initiation.atMillis;
  }
  if (moment.initiation.kind === "anchored") {
    const anchor = resolveAnchor(moment.initiation, facts);
    if (anchor.kind === "resolved") {
      return effectiveDueAtMillis(moment.initiation, anchor.atMillis,
        facts.scope.timeZone ?? DEFAULT_SCOPE_TIMEZONE);
    }
  }
  return run.dueAtMillis;
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
  // A materialized run past its expiry is dead regardless of the current
  // anchor state — the remaining checks only re-derive the same truth.
  if (run.expiresAtMillis !== undefined && nowMillis !== undefined &&
      nowMillis > run.expiresAtMillis) {
    return "skip:expired";
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
  // none. Post-anchor sends (net positive offset, including calendar
  // parts) stay valid when late.
  if (nowMillis !== undefined) {
    const anchor = resolveAnchor(initiation, facts);
    if (anchor.kind === "resolved") {
      const nominal = effectiveDueAtMillis(initiation, anchor.atMillis,
        facts.scope.timeZone ?? DEFAULT_SCOPE_TIMEZONE);
      if (nominal <= anchor.atMillis && anchor.atMillis <= nowMillis) {
        return "skip:anchorPassed";
      }
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
