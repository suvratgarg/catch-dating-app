import {
  EventFormatSnapshot,
  EventSuccessFormatPrimitives,
} from "../shared/generated/firestoreAdminTypes";

export type EventSuccessAssignmentAlgorithm = NonNullable<
  EventSuccessFormatPrimitives["assignmentAlgorithm"]
>;

export type EventSuccessPhoneAvailability = NonNullable<
  EventSuccessFormatPrimitives["phoneAvailability"]
>;

export type EventSuccessRotationSuitability = NonNullable<
  EventSuccessFormatPrimitives["rotationSuitability"]
>;

export type EventSuccessCompatibilityPolicy = NonNullable<
  EventSuccessFormatPrimitives["compatibilityPolicy"]
>;

export interface ResolvedEventSuccessPrimitives {
  assignmentAlgorithm: EventSuccessAssignmentAlgorithm;
  compatibilityPolicy: EventSuccessCompatibilityPolicy;
}

/**
 * Resolves optional contract primitives from the event format.
 * @param {EventFormatSnapshot} eventFormat Persisted event format.
 * @return {ResolvedEventSuccessPrimitives} Resolved behavior primitives.
 */
export function eventSuccessPrimitivesFor(
  eventFormat: EventFormatSnapshot | undefined
): ResolvedEventSuccessPrimitives {
  const format = eventFormat ?? {
    version: 1,
    activityKind: "openActivity",
    interactionModel: "openFormat",
  };
  const raw = format.eventSuccessPrimitives;
  const defaultAssignment = defaultAssignmentAlgorithmFor(
    format.interactionModel
  );
  const assignmentAlgorithm =
    isEventSuccessAssignmentAlgorithm(raw?.assignmentAlgorithm) ?
      raw.assignmentAlgorithm :
      defaultAssignment;
  const interactionModel = effectiveInteractionModelFor(
    format.interactionModel,
    assignmentAlgorithm
  );
  const compatibilityPolicy =
    isEventSuccessCompatibilityPolicy(raw?.compatibilityPolicy) ?
      raw.compatibilityPolicy :
      defaultCompatibilityPolicyFor(format, interactionModel);
  return {assignmentAlgorithm, compatibilityPolicy};
}

/**
 * Returns the effective interaction model after assignment primitive overrides.
 * @param {string} interactionModel Saved interaction model.
 * @param {EventSuccessAssignmentAlgorithm} assignmentAlgorithm Assignment kind.
 * @return {string} Effective interaction model.
 */
export function effectiveInteractionModelFor(
  interactionModel: EventFormatSnapshot["interactionModel"],
  assignmentAlgorithm: EventSuccessAssignmentAlgorithm
): EventFormatSnapshot["interactionModel"] {
  switch (assignmentAlgorithm) {
  case "pacePods":
    return "pacePods";
  case "pairRotations":
    return "pairedRotations";
  case "teamBalancer":
    return "teamRotations";
  case "tableSeating":
    return "seatedTable";
  case "socialPods":
    return "freeFormMixer";
  case "none":
    return interactionModel;
  }
}

/**
 * Returns the default assignment primitive for an interaction model.
 * @param {string} interactionModel Event interaction model.
 * @return {EventSuccessAssignmentAlgorithm} Assignment primitive.
 */
export function defaultAssignmentAlgorithmFor(
  interactionModel: EventFormatSnapshot["interactionModel"]
): EventSuccessAssignmentAlgorithm {
  switch (interactionModel) {
  case "pacePods":
    return "pacePods";
  case "pairedRotations":
    return "pairRotations";
  case "teamRotations":
    return "teamBalancer";
  case "seatedTable":
    return "tableSeating";
  case "freeFormMixer":
    return "socialPods";
  case "hostLedProgram":
  case "openFormat":
  default:
    return "none";
  }
}

/**
 * Returns the default compatibility primitive for a format.
 * @param {EventFormatSnapshot} eventFormat Persisted event format.
 * @param {string} interactionModel Effective interaction model.
 * @return {EventSuccessCompatibilityPolicy} Compatibility primitive.
 */
export function defaultCompatibilityPolicyFor(
  eventFormat: EventFormatSnapshot,
  interactionModel: EventFormatSnapshot["interactionModel"]
): EventSuccessCompatibilityPolicy {
  switch (interactionModel) {
  case "freeFormMixer":
    return eventFormat.activityKind === "singlesMixer" ?
      "mutualInterestOnly" :
      "questionnaireClueOnly";
  case "pairedRotations":
  case "teamRotations":
  case "seatedTable":
    return "questionnaireClueOnly";
  case "pacePods":
    return "socialCohortBalance";
  case "hostLedProgram":
  case "openFormat":
  default:
    return "none";
  }
}

/**
 * Checks assignment primitive membership.
 * @param {unknown} value Raw value.
 * @return {boolean} Whether the value is supported.
 */
export function isEventSuccessAssignmentAlgorithm(
  value: unknown
): value is EventSuccessAssignmentAlgorithm {
  return value === "none" ||
    value === "pacePods" ||
    value === "socialPods" ||
    value === "pairRotations" ||
    value === "teamBalancer" ||
    value === "tableSeating";
}

/**
 * Checks compatibility primitive membership.
 * @param {unknown} value Raw value.
 * @return {boolean} Whether the value is supported.
 */
export function isEventSuccessCompatibilityPolicy(
  value: unknown
): value is EventSuccessCompatibilityPolicy {
  return value === "none" ||
    value === "socialCohortBalance" ||
    value === "mutualInterestOnly" ||
    value === "questionnaireClueOnly";
}

/**
 * Checks phone-availability primitive membership.
 * @param {unknown} value Raw value.
 * @return {boolean} Whether the value is supported.
 */
export function isEventSuccessPhoneAvailability(
  value: unknown
): value is EventSuccessPhoneAvailability {
  return value === "continuous" ||
    value === "plannedPauses" ||
    value === "arrivalAndPostEventOnly" ||
    value === "hostOnlyLive" ||
    value === "noneDuringActivity";
}

/**
 * Checks rotation-suitability primitive membership.
 * @param {unknown} value Raw value.
 * @return {boolean} Whether the value is supported.
 */
export function isEventSuccessRotationSuitability(
  value: unknown
): value is EventSuccessRotationSuitability {
  return value === "none" ||
    value === "plannedBreaks" ||
    value === "continuousRounds";
}
