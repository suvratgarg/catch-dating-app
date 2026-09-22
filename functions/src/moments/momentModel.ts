export type MomentAnchorKind =
  "functionStart" | "functionEnd" | "programStart" | "rsvpDeadline" |
    "transportPlanDeparture";

export type MomentConditionKind = "lateArrivalAtHotel" | "flightDisrupted";

export type MomentTrigger = {
  kind: "timeAnchor";
  anchorKind: MomentAnchorKind;
  anchorId: string | null;
  offsetMinutes: number;
} | {
  kind: "conditionAnchor";
  conditionKind: MomentConditionKind;
  functionId: string | null;
};

export type MomentAudience = {
  kind: "functionGuests";
  functionId: string;
  rsvp: ReadonlyArray<"attending" | "maybe">;
  householdDedupe: boolean;
} | {
  kind: "households";
  rsvpPendingOnly: boolean;
} | {
  kind: "staffDuty";
  duty: string;
  scopeIds: ReadonlyArray<string> | null;
};

export type MomentAction = {
  kind: "sendTemplate";
  connectionId: string;
  templateId: string;
  variables: Readonly<Record<string, string>>;
} | {
  kind: "staffAttention";
  duty: string;
  severity: "info" | "warning" | "urgent";
  titleTemplate: string;
};

export type MomentStatus = "draft" | "armed" | "paused" | "done";

export interface MomentDefinition {
  momentId: string;
  programId: string;
  name: string;
  trigger: MomentTrigger;
  audience: MomentAudience;
  action: MomentAction;
  status: MomentStatus;
  revision: number;
}

export interface AnchorFacts {
  program: {
    startsAtMillis: number;
    rsvpDeadlineAtMillis: number | null;
    revision: number;
    messagingEnabled: boolean;
  };
  functions: Readonly<Record<string, {
    startsAtMillis: number;
    endsAtMillis: number;
    revision: number;
    cancelled: boolean;
  }>>;
  transportPlans: Readonly<Record<string, {
    departureAtMillis: number;
    revision: number;
  }>>;
}

export type RunStatus =
  "planned" | "resolving" | "dispatched" | "skipped" | "superseded" |
    "failed";

export interface RunRecord {
  runId: string;
  momentId: string;
  dueAtMillis: number;
  anchorRevision: number;
  status: RunStatus;
  targetFunctionId?: string;
}

export function requireMillis(value: number): void {
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new RangeError(
      "Moment timing must be non-negative safe milliseconds.");
  }
}
