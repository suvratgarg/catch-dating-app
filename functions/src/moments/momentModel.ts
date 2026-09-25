/**
 * Unified send model. Every organizer-initiated or system-initiated message
 * — a one-off blast, a scheduled announcement, a T-15m reminder, a
 * "flight disrupted → alert the greeter" rule — is a Moment. Three
 * orthogonal axes describe it:
 *
 * - initiation: how it fires (manual | scheduled | anchored | triggered)
 * - sense: whether the message is about one recipient's own fact
 *   (individual) or resolved as a set at fire time (audience)
 * - action: the channel (WhatsApp template | push | staff attention)
 *
 * A Moment is scoped to either a Catch event or a private program; the
 * anchors and audiences legal for each scope differ and are enforced by
 * `validateMomentDefinition`.
 */

export type MomentScope = {
  kind: "event";
  eventId: string;
} | {
  kind: "program";
  programId: string;
};

export type MomentScopeKind = MomentScope["kind"];

export type MomentAnchorKind =
  "scopeStart" | "scopeEnd" | "functionStart" | "functionEnd" |
    "rsvpDeadline" | "transportPlanDeparture";

export type MomentTriggerKind = "lateArrivalAtHotel" | "flightDisrupted";

export type MomentInitiation = {
  kind: "manual";
} | {
  kind: "scheduled";
  atMillis: number;
} | {
  kind: "anchored";
  anchorKind: MomentAnchorKind;
  anchorId: string | null;
  offsetMinutes: number;
} | {
  kind: "triggered";
  triggerKind: MomentTriggerKind;
  functionId: string | null;
};

export type MomentInitiationKind = MomentInitiation["kind"];

export type MomentSense = "individual" | "audience";

export type MomentAudience = {
  /** The subject of the triggering fact; legal only with `triggered`. */
  kind: "subject";
} | {
  /** Booked participants of a Catch event. */
  kind: "eventParticipants";
  statuses: ReadonlyArray<"signedUp">;
} | {
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

export type MomentAudienceKind = MomentAudience["kind"];

export type MomentAction = {
  kind: "sendTemplate";
  connectionId: string;
  templateId: string;
  variables: Readonly<Record<string, string>>;
} | {
  /** App push + activity item; copy derives from the scope at fire time. */
  kind: "push";
  notificationType: string;
  preferenceKey: string;
} | {
  kind: "staffAttention";
  duty: string;
  severity: "info" | "warning" | "urgent";
  titleTemplate: string;
};

export type MomentActionKind = MomentAction["kind"];

export type MomentStatus = "draft" | "armed" | "paused" | "done";

export type MomentOrigin = "organizer" | "systemDefault";

export interface MomentApproval {
  approvedByUid: string;
  approvedAtMillis: number;
}

export interface MomentDefinition {
  momentId: string;
  scope: MomentScope;
  name: string;
  initiation: MomentInitiation;
  sense: MomentSense;
  audience: MomentAudience;
  action: MomentAction;
  status: MomentStatus;
  /** Approve-the-rule-once: required to be non-null while `armed`. */
  approval: MomentApproval | null;
  origin: MomentOrigin;
  revision: number;
}

export interface AnchorFacts {
  scope: {
    startsAtMillis: number;
    endsAtMillis: number | null;
    rsvpDeadlineAtMillis: number | null;
    revision: number;
    messagingEnabled: boolean;
    cancelled: boolean;
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
  /** Subject of a triggered run, when the fact names one. */
  subjectId?: string;
}

export function requireMillis(value: number): void {
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new RangeError(
      "Moment timing must be non-negative safe milliseconds.");
  }
}

export function scopeId(scope: MomentScope): string {
  return scope.kind === "event" ? scope.eventId : scope.programId;
}

export function sameScope(a: MomentScope, b: MomentScope): boolean {
  return a.kind === b.kind && scopeId(a) === scopeId(b);
}

const PROGRAM_ONLY_ANCHORS: ReadonlySet<MomentAnchorKind> = new Set([
  "functionStart", "functionEnd", "rsvpDeadline", "transportPlanDeparture",
]);

const AUDIENCE_SCOPES: Readonly<Record<MomentAudienceKind,
  ReadonlyArray<MomentScopeKind> | null>> = {
    subject: null,
    eventParticipants: ["event"],
    functionGuests: ["program"],
    households: ["program"],
    staffDuty: ["event", "program"],
  };

export type MomentInvariantViolation =
  "subjectRequiresTriggered" | "triggeredRequiresProgramScope" |
    "anchorNotLegalForScope" | "audienceNotLegalForScope" |
    "audienceSenseMismatch" | "armedRequiresApproval" |
    "manualRequiresAudienceSense";

/**
 * Returns every axis invariant the definition violates. Empty means valid.
 * Pure; callables translate the list into an invalid-argument error.
 */
export function validateMomentDefinition(
  moment: MomentDefinition,
): MomentInvariantViolation[] {
  const violations: MomentInvariantViolation[] = [];
  const {initiation, audience, scope, sense} = moment;
  if (audience.kind === "subject" && initiation.kind !== "triggered") {
    violations.push("subjectRequiresTriggered");
  }
  if (initiation.kind === "triggered" && scope.kind !== "program") {
    violations.push("triggeredRequiresProgramScope");
  }
  if (initiation.kind === "anchored" &&
      PROGRAM_ONLY_ANCHORS.has(initiation.anchorKind) &&
      scope.kind !== "program") {
    violations.push("anchorNotLegalForScope");
  }
  const legalScopes = AUDIENCE_SCOPES[audience.kind];
  if (legalScopes !== null && !legalScopes.includes(scope.kind)) {
    violations.push("audienceNotLegalForScope");
  }
  if (audience.kind === "subject" && sense !== "individual") {
    violations.push("audienceSenseMismatch");
  }
  if (initiation.kind === "manual" && sense !== "audience") {
    violations.push("manualRequiresAudienceSense");
  }
  if (moment.status === "armed" && moment.approval === null) {
    violations.push("armedRequiresApproval");
  }
  return violations;
}

export type LifecycleResult = {
  kind: "ok";
  moment: MomentDefinition;
} | {
  kind: "rejected";
  reason: "invalidDefinition" | "notArmable" | "notPausable" |
    "notResumable" | "alreadyDone";
  violations?: MomentInvariantViolation[];
};

/**
 * Approve-the-rule-once: arming records who approved and when. Once armed,
 * individual (transactional) runs fire without further approval; audience
 * runs materialize pre-approved.
 */
export function armMoment(
  moment: MomentDefinition,
  approval: MomentApproval,
): LifecycleResult {
  requireMillis(approval.approvedAtMillis);
  if (moment.status === "done") {
    return {kind: "rejected", reason: "alreadyDone"};
  }
  if (moment.status === "armed") {
    return {kind: "rejected", reason: "notArmable"};
  }
  const next: MomentDefinition = {
    ...moment,
    status: "armed",
    approval,
    revision: moment.revision + 1,
  };
  const violations = validateMomentDefinition(next);
  if (violations.length > 0) {
    return {kind: "rejected", reason: "invalidDefinition", violations};
  }
  return {kind: "ok", moment: next};
}

export function pauseMoment(moment: MomentDefinition): LifecycleResult {
  if (moment.status !== "armed") {
    return {kind: "rejected", reason: "notPausable"};
  }
  return {
    kind: "ok",
    moment: {...moment, status: "paused", revision: moment.revision + 1},
  };
}

/** Resuming keeps the original approval — the rule itself did not change. */
export function resumeMoment(moment: MomentDefinition): LifecycleResult {
  if (moment.status !== "paused" || moment.approval === null) {
    return {kind: "rejected", reason: "notResumable"};
  }
  return {
    kind: "ok",
    moment: {...moment, status: "armed", revision: moment.revision + 1},
  };
}

/**
 * Any edit to when/who/what invalidates the standing approval: the moment
 * drops back to draft and must be re-armed.
 */
export function reviseMoment(
  moment: MomentDefinition,
  patch: Partial<Pick<MomentDefinition,
    "name" | "initiation" | "sense" | "audience" | "action">>,
): LifecycleResult {
  if (moment.status === "done") {
    return {kind: "rejected", reason: "alreadyDone"};
  }
  const next: MomentDefinition = {
    ...moment,
    ...patch,
    status: "draft",
    approval: null,
    revision: moment.revision + 1,
  };
  const violations = validateMomentDefinition(next);
  if (violations.length > 0) {
    return {kind: "rejected", reason: "invalidDefinition", violations};
  }
  return {kind: "ok", moment: next};
}
