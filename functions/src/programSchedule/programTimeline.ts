const MILLIS_PER_MINUTE = 60_000;

export type ProgramFunctionStatus =
  "scheduled" | "completed" | "cancelled";

export interface ProgramFunctionLike {
  functionId: string;
  name: string;
  // Epoch milliseconds in UTC.
  startsAt: number;
  // Epoch milliseconds in UTC.
  endsAt: number;
  venueName?: string | null;
  status: ProgramFunctionStatus;
  revision: number;
}

export type ScheduleIssue = {
  kind: "overlap";
  functionId: string;
  otherFunctionId: string;
  overlapMillis: number;
} | {
  kind: "shortGap";
  functionId: string;
  nextFunctionId: string;
  gapMillis: number;
} | {
  kind: "outsideProgramWindow";
  functionId: string;
} | {
  kind: "missingVenue";
  functionId: string;
} | {
  kind: "nonPositiveDuration";
  functionId: string;
};

export interface ScheduleIssueOptions {
  // Gaps shorter than this are flagged; omit or pass 0 to disable.
  minBufferMinutes?: number;
  // Epoch milliseconds. When set, functions outside the window are flagged.
  programStart?: number;
  programEnd?: number;
}

export interface ProgramDayGroup {
  // Sortable YYYY-MM-DD day in the program timezone.
  dayKey: string;
  label: string;
  functions: ProgramFunctionLike[];
}

export interface LiveFunctionResolution {
  live: ProgramFunctionLike | null;
  next: ProgramFunctionLike | null;
  minutesUntilNextStart: number | null;
  minutesSinceLiveStart: number | null;
}

export type ArrivalClassification = {
  kind: "beforeFirst";
  next: ProgramFunctionLike;
} | {
  kind: "onTime";
  function: ProgramFunctionLike;
} | {
  kind: "late";
  liveFunction: ProgramFunctionLike;
  minutesLate: number;
} | {
  kind: "betweenFunctions";
  next: ProgramFunctionLike;
} | {
  kind: "afterLast";
};

const DEFAULT_ARRIVAL_GRACE_MINUTES = 10;

export function requireMillis(value: number, label: string): void {
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new RangeError(
      `${label} must be a non-negative safe integer of milliseconds.`);
  }
}

export function isCancelledFunction(fn: ProgramFunctionLike): boolean {
  return fn.status === "cancelled";
}

export function orderFunctions<T extends ProgramFunctionLike>(
  functions: ReadonlyArray<T>,
): T[] {
  // Array.prototype.sort is stable, so equal startsAt keeps input order.
  return [...functions].sort((a, b) => a.startsAt - b.startsAt);
}

export function detectScheduleIssues(
  functions: ReadonlyArray<ProgramFunctionLike>,
  options?: ScheduleIssueOptions,
): ScheduleIssue[] {
  const issues: ScheduleIssue[] = [];
  const ordered = orderFunctions(functions);
  for (const fn of ordered) {
    if (fn.endsAt <= fn.startsAt) {
      issues.push({kind: "nonPositiveDuration", functionId: fn.functionId});
    }
    if (fn.venueName === undefined || fn.venueName === null ||
        fn.venueName.trim() === "") {
      issues.push({kind: "missingVenue", functionId: fn.functionId});
    }
    if ((options?.programStart !== undefined &&
         fn.startsAt < options.programStart) ||
        (options?.programEnd !== undefined &&
         fn.endsAt > options.programEnd)) {
      issues.push(
        {kind: "outsideProgramWindow", functionId: fn.functionId});
    }
  }
  // Cancelled and non-positive-duration functions never participate
  // in overlap or gap checks; degenerate windows carry no interval.
  const active = ordered.filter((fn) =>
    !isCancelledFunction(fn) && fn.endsAt > fn.startsAt);
  for (let i = 0; i < active.length; i++) {
    for (let j = i + 1; j < active.length; j++) {
      if (active[j].startsAt >= active[i].endsAt) break;
      issues.push({
        kind: "overlap",
        functionId: active[i].functionId,
        otherFunctionId: active[j].functionId,
        overlapMillis:
          Math.min(active[i].endsAt, active[j].endsAt) - active[j].startsAt,
      });
    }
  }
  const minBufferMinutes = options?.minBufferMinutes;
  if (minBufferMinutes !== undefined && minBufferMinutes > 0) {
    const minBufferMillis = minBufferMinutes * MILLIS_PER_MINUTE;
    for (let i = 0; i + 1 < active.length; i++) {
      const gapMillis = active[i + 1].startsAt - active[i].endsAt;
      if (gapMillis >= 0 && gapMillis < minBufferMillis) {
        issues.push({
          kind: "shortGap",
          functionId: active[i].functionId,
          nextFunctionId: active[i + 1].functionId,
          gapMillis,
        });
      }
    }
  }
  return issues;
}

export function groupFunctionsByDay(
  functions: ReadonlyArray<ProgramFunctionLike>,
  timeZone: string,
): ProgramDayGroup[] {
  const keyFormat = new Intl.DateTimeFormat("en-US", {
    timeZone, year: "numeric", month: "2-digit", day: "2-digit",
  });
  const labelFormat = new Intl.DateTimeFormat("en-US", {
    timeZone, weekday: "long", month: "long", day: "numeric",
    year: "numeric",
  });
  const groups = new Map<string, ProgramDayGroup>();
  for (const fn of orderFunctions(functions)) {
    const dayKey = dayKeyFor(keyFormat, fn.startsAt);
    let group = groups.get(dayKey);
    if (!group) {
      group = {
        dayKey,
        label: labelFormat.format(fn.startsAt),
        functions: [],
      };
      groups.set(dayKey, group);
    }
    group.functions.push(fn);
  }
  return [...groups.values()].sort((a, b) =>
    a.dayKey < b.dayKey ? -1 : a.dayKey > b.dayKey ? 1 : 0);
}

export function resolveLiveFunction(
  functions: ReadonlyArray<ProgramFunctionLike>,
  now: number,
): LiveFunctionResolution {
  requireMillis(now, "now");
  const active = orderFunctions(
    functions.filter((fn) => !isCancelledFunction(fn)));
  const live = active.find(
    (fn) => fn.startsAt <= now && now < fn.endsAt) ?? null;
  const next = active.find((fn) => fn.startsAt > now) ?? null;
  return {
    live,
    next,
    minutesUntilNextStart: next === null ?
      null : (next.startsAt - now) / MILLIS_PER_MINUTE,
    minutesSinceLiveStart: live === null ?
      null : (now - live.startsAt) / MILLIS_PER_MINUTE,
  };
}

export function classifyArrival(
  functions: ReadonlyArray<ProgramFunctionLike>,
  arrivedAt: number,
  options?: {graceMinutes?: number},
): ArrivalClassification {
  requireMillis(arrivedAt, "arrivedAt");
  const graceMillis =
    (options?.graceMinutes ?? DEFAULT_ARRIVAL_GRACE_MINUTES) *
      MILLIS_PER_MINUTE;
  const active = orderFunctions(
    functions.filter((fn) => !isCancelledFunction(fn)));
  // No scheduled functions at all is reported the same as arriving
  // after the last one: nothing remains to attend.
  if (active.length === 0) return {kind: "afterLast"};
  if (arrivedAt < active[0].startsAt) {
    return {kind: "beforeFirst", next: active[0]};
  }
  const live = active.find(
    (fn) => fn.startsAt <= arrivedAt && arrivedAt < fn.endsAt);
  if (live) {
    if (arrivedAt <= live.startsAt + graceMillis) {
      return {kind: "onTime", function: live};
    }
    return {
      kind: "late",
      liveFunction: live,
      minutesLate: (arrivedAt - live.startsAt) / MILLIS_PER_MINUTE,
    };
  }
  const next = active.find((fn) => fn.startsAt > arrivedAt);
  return next === undefined ?
    {kind: "afterLast"} : {kind: "betweenFunctions", next};
}

function dayKeyFor(format: Intl.DateTimeFormat, millis: number): string {
  let year = "";
  let month = "";
  let day = "";
  for (const part of format.formatToParts(millis)) {
    if (part.type === "year") year = part.value;
    if (part.type === "month") month = part.value;
    if (part.type === "day") day = part.value;
  }
  return `${year}-${month}-${day}`;
}
