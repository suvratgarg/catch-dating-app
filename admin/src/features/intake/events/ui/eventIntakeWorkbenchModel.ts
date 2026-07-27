import type {
  EventIntakeCandidate,
  EventIntakeSourceResult,
} from "../../../../shared/types/adminTypes";

export type EventWorkbenchStage =
  | "incoming"
  | "verify"
  | "resolve"
  | "ready";

export type EventCandidateStage =
  | Exclude<EventWorkbenchStage, "incoming">
  | "passed";

export type EventWorkbenchRecord =
  | {kind: "source"; value: EventIntakeSourceResult}
  | {kind: "candidate"; value: EventIntakeCandidate};

export interface EventCandidateCheck {
  id: string;
  label: string;
  meta: string;
  passed: boolean;
}

export type EventIntakeEditDiff = Record<
  string,
  {before: unknown; after: unknown}
>;

const dayMs = 86_400_000;

export function candidateChecks(
  candidate: EventIntakeCandidate,
  now = new Date()
): EventCandidateCheck[] {
  const hasNotPassed = !eventCandidateHasPassed(candidate, now);
  return [
    {
      id: "event_has_not_passed",
      label: "Event has not passed",
      meta: candidate.expiresAt ?
        `expires ${formatTimestamp(candidate.expiresAt)}` :
        "Operations expiry is required",
      passed: Boolean(candidate.expiresAt) && hasNotPassed,
    },
    {
      id: "organizer",
      label: "Canonical organizer attributed",
      meta: "Open the generated organizer lead and attach the canonical organizer",
      passed: candidate.attribution?.state === "attributed" &&
        Boolean(candidate.attribution.match.matchedEntityId),
    },
    {
      id: "source",
      label: "Official source URL attached",
      meta: "Attach a current official event source",
      passed: Boolean(candidate.sourceUrl),
    },
    {
      id: "date",
      label: "Date and time recorded",
      meta: "Enter the public start date and time",
      passed: Boolean(candidate.startDate && candidate.time),
    },
    {
      id: "venue",
      label: "Venue or meeting point recorded",
      meta: "Enter the venue and neighborhood",
      passed: Boolean(candidate.venue && candidate.neighborhood),
    },
    {
      id: "copy",
      label: "Owner-safe public copy reviewed",
      meta: "Review the member-facing description",
      passed: Boolean(candidate.publicDescription),
    },
    {
      id: "rights",
      label: "External hosting and rights boundary clear",
      meta: "Confirm the source and copy do not imply Catch hosts this event",
      passed: candidate.sourceStatus !== "missing_source_url",
    },
    {
      id: "dedupe",
      label: "Duplicate candidates reviewed",
      meta: "Compare the duplicate set and keep one candidate",
      passed: (candidate.dedupe?.duplicateCandidateIds ?? []).length === 0,
    },
  ];
}

export function sourceChecks(
  source: EventIntakeSourceResult
): EventCandidateCheck[] {
  return [
    {
      id: "url",
      label: "Source URL captured",
      meta: "Attach the official source",
      passed: Boolean(source.url),
    },
    {
      id: "observed",
      label: "Observation timestamp recorded",
      meta: "Refresh the source capture",
      passed: Boolean(source.observedAt),
    },
    {
      id: "profile",
      label: "Source profile linked",
      meta: "Link a governed source profile",
      passed: Boolean(source.sourceProfileId),
    },
    {
      id: "query",
      label: "Discovery query recorded",
      meta: "Link the discovery plan",
      passed: Boolean(source.queryTemplateId),
    },
    {
      id: "placeholder",
      label: "Result is not placeholder evidence",
      meta: "Replace placeholder evidence with an official source",
      passed: !source.riskFlags.includes("placeholder_result"),
    },
  ];
}

export function eventCandidateHasPassed(
  candidate: EventIntakeCandidate,
  now = new Date()
): boolean {
  if (!candidate.expiresAt) return false;
  const expiry = Date.parse(candidate.expiresAt);
  return Number.isFinite(expiry) && expiry < now.getTime();
}

export function eventCandidateStage(
  candidate: EventIntakeCandidate,
  now = new Date()
): EventCandidateStage {
  if (eventCandidateHasPassed(candidate, now)) return "passed";
  if (candidateChecks(candidate, now).some((check) => !check.passed)) {
    return "resolve";
  }
  if (
    candidate.reviewState === "approved" ||
    candidate.reviewState === "rejected"
  ) {
    return "ready";
  }
  return "verify";
}

export function recordsForStage(
  sources: EventIntakeSourceResult[],
  candidates: EventIntakeCandidate[],
  stage: EventWorkbenchStage,
  now = new Date()
): EventWorkbenchRecord[] {
  if (stage === "incoming") {
    return sources.map((value) => ({kind: "source", value}));
  }
  return candidates
    .filter((candidate) => eventCandidateStage(candidate, now) === stage)
    .sort(compareUpcomingCandidates)
    .map((value) => ({kind: "candidate", value}));
}

export function passedEventRecords(
  candidates: EventIntakeCandidate[],
  now = new Date()
): EventWorkbenchRecord[] {
  return candidates
    .filter((candidate) => eventCandidateHasPassed(candidate, now))
    .sort((left, right) =>
      timestampForCandidate(right) - timestampForCandidate(left) ||
      left.title.localeCompare(right.title))
    .map((value) => ({kind: "candidate", value}));
}

export function compareUpcomingCandidates(
  left: EventIntakeCandidate,
  right: EventIntakeCandidate
): number {
  return timestampForCandidate(left) - timestampForCandidate(right) ||
    left.title.localeCompare(right.title) ||
    left.id.localeCompare(right.id);
}

export function eventWhenLabel(
  candidate: EventIntakeCandidate,
  now = new Date()
): string {
  const absolute = [
    candidate.startDate,
    candidate.time,
  ].filter(Boolean).join(" · ");
  if (!candidate.expiresAt) return absolute || "Expiry missing";
  const expiry = Date.parse(candidate.expiresAt);
  if (!Number.isFinite(expiry)) return `${absolute} · invalid expiry`;
  const delta = expiry - now.getTime();
  const days = Math.max(0, Math.ceil(Math.abs(delta) / dayMs));
  const relative = delta < 0 ?
    `passed ${days === 0 ? "today" : `${days}d ago`}` :
    days === 0 ?
      "today" :
      days === 1 ?
        "tomorrow" :
        `in ${days}d`;
  return absolute ? `${absolute} · ${relative}` : relative;
}

export function buildEventIntakeEditDiff(
  before: Record<string, unknown>,
  after: Record<string, unknown>,
  allowedFields: readonly string[]
): EventIntakeEditDiff {
  return Object.fromEntries(allowedFields.flatMap((field) => {
    if (Object.is(before[field], after[field])) return [];
    return [[field, {before: before[field] ?? null, after: after[field] ?? null}]];
  }));
}

export function bridgeIsStale(
  generatedAt: string | null | undefined,
  lookaheadDays: number,
  now = new Date()
): boolean {
  if (!generatedAt) return true;
  const generated = Date.parse(generatedAt);
  if (!Number.isFinite(generated)) return true;
  const allowedAge = Math.max(1, lookaheadDays) * dayMs;
  return now.getTime() - generated > allowedAge;
}

export function formatTimestamp(value: string | null | undefined) {
  return value ?
    value.replace("T", " ").replace(/\.\d{3}Z$/u, "Z") :
    "n/a";
}

function timestampForCandidate(candidate: EventIntakeCandidate): number {
  const expiry = candidate.expiresAt ? Date.parse(candidate.expiresAt) : NaN;
  if (Number.isFinite(expiry)) return expiry;
  const start = Date.parse(candidate.startDate);
  return Number.isFinite(start) ? start : Number.POSITIVE_INFINITY;
}
