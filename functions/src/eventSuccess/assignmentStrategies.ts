import {HttpsError} from "firebase-functions/v2/https";

export type EventSuccessUnitKind =
  "wholeGroup" | "pods" | "pairs" | "teams" | "tables";

export interface AssignmentStrategyPlan {
  structureConfig?: {
    unitKind?: unknown;
  };
}

/**
 * Keeps the V1 guided-rotation callable limited to one-to-one pair structures.
 * @param {AssignmentStrategyPlan} plan Persisted event-success plan.
 */
export function assertGuidedRotationStrategy(
  plan: AssignmentStrategyPlan
): void {
  const unitKind = normalizedUnitKind(plan);
  if (unitKind === undefined || unitKind === "pairs") return;
  throw new HttpsError("failed-precondition",
    guidedRotationUnavailableMessage(unitKind));
}

/**
 * Keeps the V1 micro-pod callable scoped to group/team-style structures.
 * @param {AssignmentStrategyPlan} plan Persisted event-success plan.
 */
export function assertMicroPodStrategy(
  plan: AssignmentStrategyPlan
): void {
  const unitKind = normalizedUnitKind(plan);
  if (
    unitKind === undefined ||
    unitKind === "wholeGroup" ||
    unitKind === "pods" ||
    unitKind === "teams"
  ) {
    return;
  }
  throw new HttpsError("failed-precondition",
    microPodUnavailableMessage(unitKind));
}

/**
 * Reads a supported unit kind from a plan.
 * @param {AssignmentStrategyPlan} plan Persisted event-success plan.
 * @return {EventSuccessUnitKind|undefined} Unit kind when supported.
 */
export function normalizedUnitKind(
  plan: AssignmentStrategyPlan
): EventSuccessUnitKind | undefined {
  const unitKind = plan.structureConfig?.unitKind;
  if (
    unitKind === "wholeGroup" ||
    unitKind === "pods" ||
    unitKind === "pairs" ||
    unitKind === "teams" ||
    unitKind === "tables"
  ) {
    return unitKind;
  }
  return undefined;
}

/**
 * Describes the missing guided-rotation engine for a non-pair topology.
 * @param {EventSuccessUnitKind} unitKind Saved structure unit kind.
 * @return {string} Host-facing precondition copy.
 */
function guidedRotationUnavailableMessage(
  unitKind: EventSuccessUnitKind
): string {
  switch (unitKind) {
  case "teams":
    return "Team assignment engine is not available yet. " +
      "Use guided rotations only for pair-based event formats.";
  case "tables":
    return "Table seating engine is not available yet. " +
      "Use guided rotations only for pair-based event formats.";
  case "pods":
    return "Pod assignment uses micro-pods, not guided pair rotations.";
  case "wholeGroup":
    return "Guided rotations require pair structure for this event.";
  case "pairs":
    return "Guided rotations require pair structure for this event.";
  }
}

/**
 * Describes the missing micro-pod engine for pair/table structures.
 * @param {EventSuccessUnitKind} unitKind Saved structure unit kind.
 * @return {string} Host-facing precondition copy.
 */
function microPodUnavailableMessage(unitKind: EventSuccessUnitKind): string {
  switch (unitKind) {
  case "pairs":
    return "Pair rotation assignment uses guided rotations, not micro-pods.";
  case "tables":
    return "Table seating engine is not available yet. " +
      "Use micro-pods only for pod or team formats.";
  case "wholeGroup":
  case "pods":
  case "teams":
    return "Micro-pods require a pod or team structure for this event.";
  }
}
