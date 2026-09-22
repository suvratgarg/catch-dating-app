import {
  requireMillis,
  type AnchorFacts,
  type MomentDefinition,
  type RunRecord,
} from "./momentModel";

export type TravelLegEvent = {
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
};

export type ConditionResult = {
  kind: "fire";
  run: RunRecord;
} | {
  kind: "noFire";
  reason: "notConditionTrigger" | "notArmed" | "programMismatch" |
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
  if (moment.trigger.kind !== "conditionAnchor") {
    return {kind: "noFire", reason: "notConditionTrigger"};
  }
  if (moment.status !== "armed") {
    return {kind: "noFire", reason: "notArmed"};
  }
  if (event.programId !== moment.programId) {
    return {kind: "noFire", reason: "programMismatch"};
  }
  if (moment.trigger.conditionKind === "lateArrivalAtHotel") {
    return evaluateLateArrival(moment, event, facts, nowMillis);
  }
  return evaluateFlightDisruption(moment, event, facts, nowMillis);
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
  const trigger = moment.trigger as {functionId: string | null};
  const target = trigger.functionId !== null ?
    facts.functions[trigger.functionId] : currentFunction(facts, nowMillis);
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
      runId: `${moment.momentId}_${event.legId}_${event.readiness}`,
      momentId: moment.momentId,
      dueAtMillis: nowMillis,
      anchorRevision: target.revision,
      status: "planned",
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
  const trigger = moment.trigger as {functionId: string | null};
  const revision = trigger.functionId === null ?
    0 : facts.functions[trigger.functionId]?.revision ?? 0;
  return {
    kind: "fire",
    run: {
      runId: `${moment.momentId}_${event.legId}_${event.flightStatus}`,
      momentId: moment.momentId,
      dueAtMillis: nowMillis,
      anchorRevision: revision,
      status: "planned",
    },
  };
}

function currentFunction(
  facts: AnchorFacts,
  nowMillis: number,
): {startsAtMillis: number; endsAtMillis: number; revision: number;
    cancelled: boolean} | null {
  let best: {
    startsAtMillis: number;
    endsAtMillis: number;
    revision: number;
    cancelled: boolean;
  } | null = null;
  for (const fn of Object.values(facts.functions)) {
    if (fn.cancelled) continue;
    if (fn.startsAtMillis > nowMillis || fn.endsAtMillis <= nowMillis) {
      continue;
    }
    if (best === null || fn.startsAtMillis < best.startsAtMillis) {
      best = fn;
    }
  }
  return best;
}
