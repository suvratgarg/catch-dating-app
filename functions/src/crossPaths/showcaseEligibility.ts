import {createHash} from "node:crypto";
import type {CrossPathsShowcaseEligibilityDocument} from
  "../shared/generated/firestoreAdminTypes";

export const crossPathsShowcaseRuleVersion = 1;

export type CrossPathsShowcaseReasonCode =
  CrossPathsShowcaseEligibilityDocument["reasonCodes"][number];

export interface CrossPathsShowcaseReadiness {
  automaticStatus: "ready" | "blocked";
  reasonCodes: CrossPathsShowcaseReasonCode[];
  profileFingerprint: string;
}

export interface EffectiveCrossPathsShowcaseEligibility {
  status: CrossPathsShowcaseEligibilityDocument["status"];
  reasonCodes: CrossPathsShowcaseReasonCode[];
}

/**
 * Evaluates objective, activity-neutral profile readiness for Cross Paths.
 * This deliberately does not rank attractiveness or desirability.
 * @param {unknown} profile Public profile projection.
 * @return {CrossPathsShowcaseReadiness} Coarse blockers and stable hash.
 */
export function evaluateCrossPathsShowcaseReadiness(
  profile: unknown
): CrossPathsShowcaseReadiness {
  const reasonCodes: CrossPathsShowcaseReasonCode[] = [];
  const data = recordOrNull(profile);
  if (!data || !hasValidIdentity(data)) {
    reasonCodes.push("public_profile_missing");
  }

  const photos = Array.isArray(data?.profilePhotos) ?
    data.profilePhotos : [];
  const usablePhotos = photos.filter(isUsableApprovedPhoto);
  if (usablePhotos.length < 3) reasonCodes.push("insufficient_photos");
  if (photos.some(hasBrokenPhotoMedia)) reasonCodes.push("broken_media");
  if (photos.some(hasPendingPhotoModeration)) {
    reasonCodes.push("photo_moderation_pending");
  }
  if (photos.some(hasRejectedPhotoModeration)) {
    reasonCodes.push("photo_moderation_rejected");
  }

  const prompts = Array.isArray(data?.profilePrompts) ?
    data.profilePrompts : [];
  if (prompts.filter(isCompletePrompt).length < 3) {
    reasonCodes.push("incomplete_prompts");
  }
  if (!nonEmptyString(data?.relationshipGoal)) {
    reasonCodes.push("missing_relationship_goal");
  }

  return {
    automaticStatus: reasonCodes.length === 0 ? "ready" : "blocked",
    reasonCodes,
    profileFingerprint: crossPathsProfileFingerprint(data),
  };
}

/**
 * Resolves stored review state against the current profile fingerprint.
 * @param {CrossPathsShowcaseReadiness} readiness Current objective readiness.
 * @param {CrossPathsShowcaseEligibilityDocument|undefined} stored Review.
 * @return {EffectiveCrossPathsShowcaseEligibility} Effective state.
 */
export function effectiveCrossPathsShowcaseEligibility(
  readiness: CrossPathsShowcaseReadiness,
  stored: CrossPathsShowcaseEligibilityDocument | undefined
): EffectiveCrossPathsShowcaseEligibility {
  if (!stored) {
    return {status: "needsReview", reasonCodes: readiness.reasonCodes};
  }
  const reasons = [...readiness.reasonCodes];
  const changed = stored.profileFingerprint !== readiness.profileFingerprint ||
    stored.ruleVersion !== crossPathsShowcaseRuleVersion;
  if (changed) reasons.push("profile_changed");
  if (stored.status === "paused") {
    reasons.push("manual_pause");
    return {status: "paused", reasonCodes: uniqueReasons(reasons)};
  }
  if (stored.status !== "eligible") {
    reasons.push("reviewer_hold");
    return {status: "needsReview", reasonCodes: uniqueReasons(reasons)};
  }
  if (readiness.automaticStatus !== "ready" || changed) {
    return {status: "needsReview", reasonCodes: uniqueReasons(reasons)};
  }
  return {status: "eligible", reasonCodes: []};
}

/**
 * Hashes the complete current public projection with deterministic key order.
 * @param {unknown} profile Public profile projection.
 * @return {string} SHA-256 fingerprint.
 */
export function crossPathsProfileFingerprint(profile: unknown): string {
  return createHash("sha256")
    .update(JSON.stringify(canonicalize(profile)))
    .digest("hex");
}

function hasValidIdentity(data: Record<string, unknown>): boolean {
  return nonEmptyString(data.name) &&
    typeof data.age === "number" &&
    Number.isInteger(data.age) &&
    data.age >= 18 &&
    data.age <= 99 &&
    nonEmptyString(data.gender);
}

function isUsableApprovedPhoto(value: unknown): boolean {
  const photo = recordOrNull(value);
  const moderation = recordOrNull(photo?.moderation);
  return Boolean(photo) &&
    validHttpUrl(photo?.url) &&
    validHttpUrl(photo?.thumbnailUrl) &&
    nonEmptyString(photo?.storagePath) &&
    nonEmptyString(photo?.thumbnailStoragePath) &&
    moderation?.status === "approved";
}

function hasBrokenPhotoMedia(value: unknown): boolean {
  const photo = recordOrNull(value);
  return !photo ||
    !validHttpUrl(photo.url) ||
    !validHttpUrl(photo.thumbnailUrl) ||
    !nonEmptyString(photo.storagePath) ||
    !nonEmptyString(photo.thumbnailStoragePath);
}

function hasPendingPhotoModeration(value: unknown): boolean {
  const photo = recordOrNull(value);
  const moderation = recordOrNull(photo?.moderation);
  return moderation?.status !== "approved" &&
    moderation?.status !== "rejected";
}

function hasRejectedPhotoModeration(value: unknown): boolean {
  const photo = recordOrNull(value);
  return recordOrNull(photo?.moderation)?.status === "rejected";
}

function isCompletePrompt(value: unknown): boolean {
  const prompt = recordOrNull(value);
  return nonEmptyString(prompt?.prompt) && nonEmptyString(prompt?.answer);
}

function validHttpUrl(value: unknown): boolean {
  if (!nonEmptyString(value)) return false;
  try {
    const parsed = new URL(value);
    return parsed.protocol === "https:" || parsed.protocol === "http:";
  } catch {
    return false;
  }
}

function nonEmptyString(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}

function recordOrNull(value: unknown): Record<string, unknown> | null {
  return value !== null && typeof value === "object" && !Array.isArray(value) ?
    value as Record<string, unknown> : null;
}

function uniqueReasons(
  reasons: CrossPathsShowcaseReasonCode[]
): CrossPathsShowcaseReasonCode[] {
  return [...new Set(reasons)];
}

function canonicalize(value: unknown): unknown {
  if (value === null || typeof value !== "object") return value;
  if (typeof (value as {toMillis?: unknown}).toMillis === "function") {
    return (value as {toMillis: () => number}).toMillis();
  }
  if (Array.isArray(value)) return value.map(canonicalize);
  return Object.fromEntries(
    Object.entries(value as Record<string, unknown>)
      .sort(([left], [right]) => left.localeCompare(right))
      .map(([key, nested]) => [key, canonicalize(nested)])
  );
}
