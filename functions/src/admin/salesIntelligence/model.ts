/* eslint-disable max-len */
import {createHash} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";

export type ClaimKey = "identity" | "recurrence" | "operation" | "stack" | "other";
export type ClauseKind = "observation" | "capability" | "reference" | "cta";
export const ID = /^[A-Za-z0-9][A-Za-z0-9._:-]{0,95}$/u;
export const REQUEST_ID = /^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$/u;

export interface Factor {id: string; weight: number; claimKeys: ClaimKey[]; maxAgeDays: number}
export interface IntelligencePolicy {
  schemaVersion: 1; classification: "sales_private"; policyRecordId: "current";
  policyId: string;
  revision: number; version: string; status: "active" | "paused";
  factors: Factor[]; priorityBands: {high: number; medium: number};
  promptVersion: string; playbookVersion: string;
  updatedAt: string; updatedBy: string;
}
export interface Assessment {
  schemaVersion: 1; classification: "sales_private"; assessmentId: string;
  organizerId: string; factorId: string; revision: number;
  state: "known" | "unknown" | "disputed"; value: number | null;
  evidenceIds: string[]; reason: string | null;
  reviewedAt: string; reviewerUid: string;
}
export interface Clause {
  schemaVersion: 1; classification: "sales_private"; clauseId: string;
  organizerId: string; revision: number; kind: ClauseKind; text: string;
  state: "draft" | "approved" | "withdrawn";
  evidenceIds: string[]; validUntil: string;
  permission: "not_required" | "private_mention" | "withdrawn";
  reviewedAt: string | null; reviewedBy: string | null;
  updatedAt: string; updatedBy: string;
}
export interface ScoreSnapshot {
  schemaVersion: 1; classification: "sales_private"; snapshotId: string;
  organizerId: string; accountRevision: number; policyId: string;
  policyRevision: number; policyVersion: string; sourceHash: string;
  status: "complete" | "needs_research" | "review_required";
  score: number | null; priority: "high" | "medium" | "low" | "unranked";
  factors: Array<{factorId: string; state: Assessment["state"];
    value: number | null; evidenceIds: string[]; reason: string | null}>;
  evaluatedAt: string;
}

export function fail(code: "invalid-argument" | "failed-precondition" |
  "aborted" | "permission-denied" | "not-found" | "already-exists" |
  "resource-exhausted", message: string): never {
  throw new HttpsError(code, message);
}
export function object(value: unknown, keys: string[]): Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value) ||
      Object.keys(value).some((key) => !keys.includes(key))) {
    return fail("invalid-argument", "Invalid Sales intelligence request fields.");
  }
  return value as Record<string, unknown>;
}
export function id(value: unknown): string {
  if (typeof value !== "string" || !ID.test(value) ||
      ["__proto__", "prototype", "constructor"].includes(value)) {
    return fail("invalid-argument", "Invalid identifier.");
  }
  return value;
}
export function requestId(value: unknown): string {
  if (typeof value !== "string" || !REQUEST_ID.test(value)) {
    return fail("invalid-argument", "Stable requestId required.");
  }
  return value;
}
export function revision(value: unknown): number {
  if (!Number.isSafeInteger(value) || (value as number) < 0 ||
      (value as number) > 1_000_000) {
    return fail("invalid-argument", "Expected revision required.");
  }
  return value as number;
}
export function text(value: unknown, max = 500): string {
  if (typeof value !== "string" || value.length < 1 || value.length > max ||
      [...value].some((part) => part.charCodeAt(0) < 32 ||
        part.charCodeAt(0) === 127) || value !== value.trim()) {
    return fail("invalid-argument", "Invalid reviewed text.");
  }
  return value;
}
export function iso(value: unknown): string {
  if (typeof value !== "string" || !/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z$/u.test(value) ||
      !Number.isFinite(Date.parse(value)) || new Date(value).toISOString() !== value) {
    return fail("invalid-argument", "UTC timestamp required.");
  }
  return value;
}
export function uniqueIds(value: unknown, max: number): string[] {
  if (!Array.isArray(value) || value.length > max ||
      value.some((entry) => typeof entry !== "string" || !ID.test(entry)) ||
      new Set(value).size !== value.length) {
    return fail("invalid-argument", "Invalid bounded identifier list.");
  }
  return value as string[];
}
function sorted(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(sorted);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value).sort(([a], [b]) => a.localeCompare(b))
        .map(([key, entry]) => [key, sorted(entry)]));
  }
  return value;
}
export function hash(value: unknown): string {
  return createHash("sha256").update(JSON.stringify(sorted(value))).digest("hex");
}
export function parsePolicy(value: unknown): Omit<IntelligencePolicy,
  "schemaVersion" | "classification" | "policyRecordId" | "revision" |
  "updatedAt" | "updatedBy"> {
  const row = object(value, ["policyId", "version", "status", "factors",
    "priorityBands", "promptVersion", "playbookVersion"]);
  const factors = row.factors;
  if (!Array.isArray(factors) || factors.length !== 7) {
    return fail("invalid-argument", "Exactly seven configured factors required.");
  }
  const parsed = factors.map((entry) => {
    const factor = object(entry, ["id", "weight", "claimKeys", "maxAgeDays"]);
    const claimKeys = factor.claimKeys;
    if (!Array.isArray(claimKeys) || claimKeys.length < 1 || claimKeys.length > 5 ||
        new Set(claimKeys).size !== claimKeys.length ||
        claimKeys.some((key) => !["identity", "recurrence", "operation", "stack", "other"].includes(key))) {
      return fail("invalid-argument", "Factor evidence mapping is invalid.");
    }
    if (!Number.isInteger(factor.weight) || (factor.weight as number) < 1 ||
        (factor.weight as number) > 100 || !Number.isInteger(factor.maxAgeDays) ||
        (factor.maxAgeDays as number) < 1 || (factor.maxAgeDays as number) > 365) {
      return fail("invalid-argument", "Factor weight or freshness is invalid.");
    }
    return {id: id(factor.id), weight: factor.weight as number,
      claimKeys: claimKeys as ClaimKey[], maxAgeDays: factor.maxAgeDays as number};
  });
  const bands = object(row.priorityBands, ["high", "medium"]);
  if (new Set(parsed.map((factor) => factor.id)).size !== 7 ||
      parsed.reduce((sum, factor) => sum + factor.weight, 0) !== 100 ||
      typeof bands.high !== "number" || typeof bands.medium !== "number" ||
      !Number.isFinite(bands.high) || !Number.isFinite(bands.medium) ||
      bands.high > 100 || bands.high <= bands.medium || bands.medium < 0 ||
      (row.status !== "active" && row.status !== "paused")) {
    return fail("invalid-argument", "Invalid versioned intelligence policy.");
  }
  return {policyId: id(row.policyId), version: id(row.version),
    status: row.status, factors: parsed,
    priorityBands: {high: bands.high, medium: bands.medium},
    promptVersion: id(row.promptVersion), playbookVersion: id(row.playbookVersion)};
}

export function evaluateScore(policy: IntelligencePolicy, organizerId: string,
  accountRevision: number, assessments: Assessment[], evidence: Array<Record<string, unknown>>,
  now: string): ScoreSnapshot {
  if (policy.status !== "active") return fail("failed-precondition", "Intelligence policy is paused.");
  if (new Set(assessments.map((row) => row.factorId)).size !== assessments.length ||
      assessments.some((row) => row.organizerId !== organizerId ||
        row.classification !== "sales_private" ||
        (row.state === "known" && (!Number.isInteger(row.value) ||
          (row.value as number) < 0 || (row.value as number) > 5)))) {
    return fail("failed-precondition", "Reviewed assessment data is inconsistent.");
  }
  const byId = new Map(evidence.map((row) => [row.evidenceId, row]));
  const byFactor = new Map(assessments.map((row) => [row.factorId, row]));
  const at = Date.parse(now);
  const factors = policy.factors.map((factor) => {
    const assessment = byFactor.get(factor.id);
    if (!assessment || assessment.state === "unknown") {
      return {
        factorId: factor.id, state: "unknown" as const, value: null,
        evidenceIds: assessment?.evidenceIds ?? [], reason: assessment?.reason ?? "No reviewed assessment."};
    }
    if (assessment.state === "disputed") {
      return {
        factorId: factor.id, state: "disputed" as const, value: null,
        evidenceIds: assessment.evidenceIds, reason: assessment.reason};
    }
    const valid = assessment.evidenceIds.length > 0 && assessment.evidenceIds.every((evidenceId) => {
      const row = byId.get(evidenceId);
      return row?.classification === "sales_private" && row.organizerId === organizerId &&
        typeof row.reviewedAt === "string" &&
        Number.isFinite(Date.parse(row.reviewedAt)) &&
        Date.parse(row.reviewedAt) <= at &&
        typeof row.reviewerUid === "string" && row.reviewerUid.length > 0 &&
        factor.claimKeys.includes(row.claimKey as ClaimKey) &&
        typeof row.observedAt === "string" && Number.isFinite(Date.parse(row.observedAt)) &&
        Date.parse(row.observedAt) <= at &&
        at - Date.parse(row.observedAt) <= factor.maxAgeDays * 86_400_000 &&
        (row.validThrough === null || row.validThrough === undefined ||
          (typeof row.validThrough === "string" && Date.parse(row.validThrough) >= at));
    });
    return valid ? {factorId: factor.id, state: "known" as const,
      value: assessment.value, evidenceIds: assessment.evidenceIds, reason: null} :
      {factorId: factor.id, state: "unknown" as const, value: null,
        evidenceIds: assessment.evidenceIds, reason: "Evidence stale, missing or ineligible."};
  });
  const disputed = factors.some((factor) => factor.state === "disputed");
  const complete = factors.every((factor) => factor.state === "known");
  const score = complete ? Math.round(policy.factors.reduce((sum, factor) => {
    const row = factors.find((entry) => entry.factorId === factor.id);
    return sum + factor.weight * Number(row?.value) / 5;
  }, 0) * 100) / 100 : null;
  const priority = score === null ? "unranked" : score >= policy.priorityBands.high ?
    "high" : score >= policy.priorityBands.medium ? "medium" : "low";
  const sourceHash = hash({policy, accountRevision, factors,
    assessments: [...assessments].sort((a, b) =>
      a.assessmentId.localeCompare(b.assessmentId)),
    evidence: [...evidence].sort((a, b) =>
      String(a.evidenceId).localeCompare(String(b.evidenceId)))});
  return {schemaVersion: 1, classification: "sales_private",
    snapshotId: `score-${hash([organizerId, sourceHash, now]).slice(0, 32)}`,
    organizerId, accountRevision, policyId: policy.policyId,
    policyRevision: policy.revision, policyVersion: policy.version, sourceHash,
    status: disputed ? "review_required" : complete ? "complete" : "needs_research",
    score, priority, factors, evaluatedAt: now};
}
