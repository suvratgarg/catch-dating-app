import type {UserProfileDocument} from
  "../shared/generated/firestoreAdminTypes";
import {runningPreferencesFromUserProfileDoc} from
  "../shared/profileProjection";
import type {AssignmentConstraintConfig} from "./assignmentConstraints";
import type {
  AssignmentRotationPolicy,
  AssignmentRotationRepeatStrategy,
} from "./assignmentOptimizer";

export type AssignmentPrimitiveActivityAttribute =
  "paceBand" | "skillBand" | "roleBand";

export interface AssignmentPrimitiveStructureConfig {
  rotationRepeatStrategy?: unknown;
  maxPairMeetings?: unknown;
  balanceActivityAttributes?: unknown;
  clusterActivityAttributes?: unknown;
}

const VALID_ACTIVITY_ATTRIBUTES =
  new Set<AssignmentPrimitiveActivityAttribute>([
    "paceBand",
    "skillBand",
    "roleBand",
  ]);
const DEFAULT_MAX_PAIR_MEETINGS = 2;
const CURRENT_RUN_PREFERENCES_VERSION = 1;
const DEFAULT_PACE_MIN_SECS_PER_KM = 300;
const DEFAULT_PACE_MAX_SECS_PER_KM = 420;

/**
 * Maps saved structure controls to optimizer rotation policy.
 * @param {AssignmentPrimitiveStructureConfig} config Saved structure config.
 * @return {AssignmentRotationPolicy} Optimizer rotation policy.
 */
export function rotationPolicyForStructureConfig(
  config?: AssignmentPrimitiveStructureConfig
): AssignmentRotationPolicy {
  return {
    repeatStrategy: repeatStrategyFor(config?.rotationRepeatStrategy),
    maxPairMeetings: boundedInteger(
      config?.maxPairMeetings,
      1,
      10
    ) ?? DEFAULT_MAX_PAIR_MEETINGS,
  };
}

/**
 * Maps saved structure controls to optimizer assignment constraints.
 * @param {AssignmentPrimitiveStructureConfig} config Saved structure config.
 * @return {AssignmentConstraintConfig} Optimizer constraints.
 */
export function assignmentConstraintsForStructureConfig(
  config?: AssignmentPrimitiveStructureConfig
): AssignmentConstraintConfig {
  const balanceAttributes = sanitizeActivityAttributes(
    config?.balanceActivityAttributes
  );
  const clusterAttributes = sanitizeActivityAttributes(
    config?.clusterActivityAttributes,
    new Set(balanceAttributes)
  );
  if (balanceAttributes.length === 0 && clusterAttributes.length === 0) {
    return {};
  }
  return {
    activity: {
      balanceAttributes,
      clusterAttributes,
    },
  };
}

/**
 * Extracts assignment-visible activity attributes from a user profile.
 * @param {Partial<UserProfileDocument>} profile User profile data.
 * @return {Record<string, string | number | boolean | null>} Attributes.
 */
export function activityAttributesForProfile(
  profile: Partial<UserProfileDocument>
): Record<string, string | number | boolean | null> {
  const attributes: Record<string, string | number | boolean | null> = {};
  const running = runningPreferencesFromUserProfileDoc(
    profile as UserProfileDocument
  );
  if (hasRunPreferenceSignal(running)) {
    const paceBand = paceBandForRange(
      running.paceMinSecsPerKm,
      running.paceMaxSecsPerKm
    );
    if (paceBand !== undefined) {
      attributes.paceBand = paceBand;
    }
  }
  return attributes;
}

/**
 * Buckets a running pace range into optimizer-friendly pace bands.
 * @param {number} minSecsPerKm Lower pace bound in seconds per kilometer.
 * @param {number} maxSecsPerKm Upper pace bound in seconds per kilometer.
 * @return {string | undefined} Pace band when the range is usable.
 */
export function paceBandForRange(
  minSecsPerKm: number,
  maxSecsPerKm: number
): "competitive" | "fast" | "moderate" | "easy" | undefined {
  if (
    !Number.isFinite(minSecsPerKm) ||
    !Number.isFinite(maxSecsPerKm) ||
    minSecsPerKm <= 0 ||
    maxSecsPerKm <= 0
  ) {
    return undefined;
  }
  const average = (minSecsPerKm + maxSecsPerKm) / 2;
  if (average <= 300) return "competitive";
  if (average <= 360) return "fast";
  if (average <= 420) return "moderate";
  return "easy";
}

/**
 * Returns whether a supported activity attribute key was selected.
 * @param {unknown} value Raw attribute key.
 * @return {boolean} Whether the key is supported.
 */
function isActivityAttribute(
  value: unknown
): value is AssignmentPrimitiveActivityAttribute {
  const candidate = value as AssignmentPrimitiveActivityAttribute;
  return typeof value === "string" &&
    VALID_ACTIVITY_ATTRIBUTES.has(candidate);
}

/**
 * Sanitizes a raw activity attribute list for optimizer use.
 * @param {unknown} raw Raw Firestore value.
 * @param {Set<string>} excluded Attribute names already claimed.
 * @return {string[]} Sanitized attributes.
 */
function sanitizeActivityAttributes(
  raw: unknown,
  excluded: Set<string> = new Set()
): string[] {
  if (!Array.isArray(raw)) return [];
  const seen = new Set<string>();
  const attributes: string[] = [];
  for (const item of raw) {
    if (!isActivityAttribute(item) || excluded.has(item) || seen.has(item)) {
      continue;
    }
    seen.add(item);
    attributes.push(item);
  }
  return attributes;
}

/**
 * Normalizes repeat policy names.
 * @param {unknown} value Raw saved repeat strategy.
 * @return {AssignmentRotationRepeatStrategy} Supported repeat strategy.
 */
function repeatStrategyFor(value: unknown): AssignmentRotationRepeatStrategy {
  return value === "allowWhenExhausted" ? "allowWhenExhausted" : "avoid";
}

/**
 * Returns an integer in range from a raw saved value.
 * @param {unknown} value Raw numeric value.
 * @param {number} min Minimum accepted value.
 * @param {number} max Maximum accepted value.
 * @return {number | null} Bounded integer.
 */
function boundedInteger(
  value: unknown,
  min: number,
  max: number
): number | null {
  if (typeof value !== "number" || !Number.isFinite(value)) return null;
  return Math.max(min, Math.min(max, Math.floor(value)));
}

/**
 * Treats default run preferences as missing rather than assignment signal.
 * @param {object} running Normalized running preferences.
 * @return {boolean} Whether the runner supplied meaningful preferences.
 */
function hasRunPreferenceSignal(
  running: ReturnType<typeof runningPreferencesFromUserProfileDoc>
): boolean {
  return Boolean(
    running.version >= CURRENT_RUN_PREFERENCES_VERSION ||
    running.preferredDistances.length ||
    running.runningReasons.length ||
    running.preferredRunTimes.length ||
    running.paceMinSecsPerKm !== DEFAULT_PACE_MIN_SECS_PER_KM ||
    running.paceMaxSecsPerKm !== DEFAULT_PACE_MAX_SECS_PER_KM
  );
}
