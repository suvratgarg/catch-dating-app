import {createHash} from "node:crypto";
import {
  requireMillis,
  sameScope,
  type AnchorFacts,
  type MomentDefinition,
  type RunRecord,
} from "./momentModel";

export type TravelLegEvent = {
  /** Authoritative CloudEvent identity; never reconstructed from status. */
  source: string;
  eventId: string;
} & ({
  kind: "travelLegReadinessChanged";
  legId: string;
  programId: string;
  previousReadiness: string;
  readiness: string;
  observedAtMillis: number;
} | {
  kind: "travelLegFlightStatusChanged";
  legId: string;
  programId: string;
  previousFlightStatus: string;
  flightStatus: string;
  observedAtMillis: number;
});

export type ConditionResult = {
  kind: "fire";
  run: RunRecord;
} | {
  kind: "noFire";
  reason: "notTriggered" | "notArmed" | "scopeMismatch" |
    "eventNotMatching" | "noCurrentFunction" | "functionNotStarted" |
      "functionCancelled";
};

const DISRUPTED_FLIGHT_STATUSES = new Set(["cancelled", "diverted"]);

export function evaluateCondition(
  moment: MomentDefinition,
  event: TravelLegEvent,
  facts: AnchorFacts,
  nowMillis: number,
): ConditionResult {
  requireMillis(nowMillis);
  requireMillis(event.observedAtMillis);
  if (!event.source.trim() || !event.eventId.trim()) {
    throw new Error("Travel event requires authoritative identity");
  }
  if (moment.initiation.kind !== "triggered") {
    return {kind: "noFire", reason: "notTriggered"};
  }
  if (moment.status !== "armed") {
    return {kind: "noFire", reason: "notArmed"};
  }
  if (!sameScope(moment.scope,
    {kind: "program", programId: event.programId})) {
    return {kind: "noFire", reason: "scopeMismatch"};
  }
  if (moment.initiation.triggerKind === "lateArrivalAtHotel") {
    return evaluateLateArrival(moment, event, facts, event.observedAtMillis);
  }
  return evaluateFlightDisruption(moment, event, facts, event.observedAtMillis);
}

function evaluateLateArrival(
  moment: MomentDefinition,
  event: TravelLegEvent,
  facts: AnchorFacts,
  nowMillis: number,
): ConditionResult {
  if (event.kind !== "travelLegReadinessChanged" ||
      event.readiness !== "arrived" ||
      event.previousReadiness === "arrived") {
    return {kind: "noFire", reason: "eventNotMatching"};
  }
  const trigger = moment.initiation as {functionId: string | null};
  const target = trigger.functionId !== null ?
    (facts.functions[trigger.functionId] === undefined ? null : {
      functionId: trigger.functionId,
      ...facts.functions[trigger.functionId],
    }) : currentFunction(facts, event.observedAtMillis);
  if (!target) return {kind: "noFire", reason: "noCurrentFunction"};
  if (target.cancelled) {
    return {kind: "noFire", reason: "functionCancelled"};
  }
  requireMillis(target.startsAtMillis);
  requireMillis(target.endsAtMillis);
  if (nowMillis <= target.startsAtMillis) {
    return {kind: "noFire", reason: "functionNotStarted"};
  }
  return {
    kind: "fire",
    run: {
      runId: travelOccurrenceId(moment, event),
      momentId: moment.momentId,
      dueAtMillis: nowMillis,
      anchorRevision: target.revision,
      status: "planned",
      targetFunctionId: target.functionId,
      subjectId: event.legId,
    },
  };
}

function evaluateFlightDisruption(
  moment: MomentDefinition,
  event: TravelLegEvent,
  facts: AnchorFacts,
  nowMillis: number,
): ConditionResult {
  if (event.kind !== "travelLegFlightStatusChanged" ||
      !DISRUPTED_FLIGHT_STATUSES.has(event.flightStatus) ||
      DISRUPTED_FLIGHT_STATUSES.has(event.previousFlightStatus)) {
    return {kind: "noFire", reason: "eventNotMatching"};
  }
  const trigger = moment.initiation as {functionId: string | null};
  const revision = trigger.functionId === null ?
    0 : facts.functions[trigger.functionId]?.revision ?? 0;
  return {
    kind: "fire",
    run: {
      runId: travelOccurrenceId(moment, event),
      momentId: moment.momentId,
      dueAtMillis: nowMillis,
      anchorRevision: revision,
      status: "planned",
      subjectId: event.legId,
      ...(trigger.functionId === null ?
        {} : {targetFunctionId: trigger.functionId}),
    },
  };
}

function currentFunction(
  facts: AnchorFacts,
  nowMillis: number,
): {functionId: string; startsAtMillis: number; endsAtMillis: number;
    revision: number; cancelled: boolean} | null {
  let best: {
    functionId: string;
    startsAtMillis: number;
    endsAtMillis: number;
    revision: number;
    cancelled: boolean;
  } | null = null;
  for (const [functionId, fn] of Object.entries(facts.functions)) {
    if (fn.cancelled) continue;
    if (fn.startsAtMillis > nowMillis || fn.endsAtMillis <= nowMillis) {
      continue;
    }
    if (best === null || fn.startsAtMillis < best.startsAtMillis) {
      best = {functionId, ...fn};
    }
  }
  return best;
}

/** Stable across delivery retries and later edits to the Moment. */
export function travelOccurrenceId(
  moment: MomentDefinition, event: TravelLegEvent,
): string {
  const hash = createHash("sha256").update(JSON.stringify([
    event.source, event.eventId, event.kind, event.programId, event.legId,
    moment.momentId,
  ])).digest("hex");
  return `travel_v1_${hash}`;
}

export function isTravelOccurrence(runId: string): boolean {
  return /^travel_v1_[a-f0-9]{64}$/.test(runId);
}
