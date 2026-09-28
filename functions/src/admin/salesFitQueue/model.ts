/* eslint-disable max-len */
import {HttpsError} from "firebase-functions/v2/https";
import {hash, type Assessment, type IntelligencePolicy,
  type ScoreSnapshot} from "../salesIntelligence/model";
import type {SalesAccount} from "../sales/types";

export type FitQueueView = "ranked" | "needs_research" |
  "outreach_review_candidate";
export interface FitQueueEntry {
  schemaVersion: 1;
  classification: "sales_private";
  organizerId: string;
  policyId: string;
  policyRevision: number;
  policyVersion: string;
  sourceHash: string;
  accountRevision: number;
  qualificationPolicyHash: string | null;
  status: ScoreSnapshot["status"];
  score: number | null;
  priority: ScoreSnapshot["priority"];
  eligibleForOutreachReview: boolean;
  suppressionStatus: SalesAccount["suppressionStatus"];
  duplicateReviewRequired: boolean;
  researchStatus: SalesAccount["researchStatus"];
  name: string;
  city: string | null;
  assignedOwnerUid: string | null;
  expiresAt: string | null;
  evaluatedAt: string;
}
export interface FitQueueCursor {
  view: FitQueueView;
  policyRevision: number;
  qualificationPolicyHash: string | null;
  generation: number;
  lastId: string;
  lastScore: number | null;
}

export function invalid(message: string): never {
  throw new HttpsError("invalid-argument", message);
}
export function failed(message: string): never {
  throw new HttpsError("failed-precondition", message);
}
export function identifier(value: unknown): string {
  if (typeof value !== "string" ||
      !/^[A-Za-z0-9][A-Za-z0-9._:-]{0,95}$/u.test(value)) {
    invalid("A valid organizer identifier is required.");
  }
  return value as string;
}
export function boundedLimit(value: unknown, maximum: number,
  fallback: number): number {
  if (value === undefined) return fallback;
  if (!Number.isInteger(value) || (value as number) < 1 ||
      (value as number) > maximum) {
    invalid(`Limit must be between 1 and ${maximum}.`);
  }
  return value as number;
}
export function stableRequestId(value: unknown): string {
  if (typeof value !== "string" ||
      !/^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$/u.test(value)) {
    invalid("A stable request ID is required.");
  }
  return value as string;
}
export function exactFields(value: unknown, keys: readonly string[]):
  Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value) ||
      Object.keys(value).some((key) => !keys.includes(key))) {
    invalid("Invalid fit queue request fields.");
  }
  return value as Record<string, unknown>;
}
export function viewOf(value: unknown): FitQueueView {
  if (value !== "ranked" && value !== "needs_research" &&
      value !== "outreach_review_candidate") {
    invalid("Invalid fit queue view.");
  }
  return value as FitQueueView;
}

/** Expiry is exclusive; a rank never outlives any evidence used to produce it. */
export function scoreExpiry(policy: IntelligencePolicy,
  snapshot: ScoreSnapshot, assessments: Assessment[],
  evidence: Array<Record<string, unknown>>): string | null {
  if (snapshot.status !== "complete") return null;
  const byId = new Map(evidence.map((row) => [String(row.evidenceId), row]));
  const byFactor = new Map(assessments.map((row) => [row.factorId, row]));
  let minimum = Infinity;
  for (const factor of policy.factors) {
    const assessment = byFactor.get(factor.id);
    if (!assessment || assessment.state !== "known") {
      failed("Complete score lacks a known assessment.");
    }
    for (const evidenceId of assessment!.evidenceIds) {
      const row = byId.get(evidenceId);
      if (!row) failed("Complete score lacks source evidence.");
      const observedAt = Date.parse(String(row!.observedAt));
      if (!Number.isFinite(observedAt)) failed("Score source date is invalid.");
      minimum = Math.min(minimum, observedAt + factor.maxAgeDays * 86_400_000 + 1);
      if (typeof row!.validThrough === "string") {
        const through = Date.parse(row!.validThrough);
        if (!Number.isFinite(through)) failed("Score source validity is invalid.");
        minimum = Math.min(minimum, through + 1);
      }
    }
  }
  if (!Number.isFinite(minimum)) failed("Complete score has no expiry bound.");
  return new Date(minimum).toISOString();
}

export function projectScore(account: SalesAccount,
  policy: IntelligencePolicy, snapshot: ScoreSnapshot,
  assessments: Assessment[], evidence: Array<Record<string, unknown>>,
  currentQualificationHash: string | null): FitQueueEntry {
  const qualificationPolicyHash = account.qualificationPolicy?.policyHash ?? null;
  return {schemaVersion: 1, classification: "sales_private",
    organizerId: account.organizerId, policyId: policy.policyId,
    policyRevision: policy.revision, policyVersion: policy.version,
    sourceHash: snapshot.sourceHash, accountRevision: account.revision,
    qualificationPolicyHash, status: snapshot.status,
    score: snapshot.score, priority: snapshot.priority,
    eligibleForOutreachReview: snapshot.status === "complete" &&
      account.researchStatus === "qualified" &&
      account.suppressionStatus === "clear" &&
      !account.duplicateReviewRequired && currentQualificationHash !== null &&
      qualificationPolicyHash === currentQualificationHash,
    suppressionStatus: account.suppressionStatus,
    duplicateReviewRequired: account.duplicateReviewRequired,
    researchStatus: account.researchStatus,
    name: account.name, city: account.city,
    assignedOwnerUid: account.assignedOwnerUid,
    expiresAt: scoreExpiry(policy, snapshot, assessments, evidence),
    evaluatedAt: snapshot.evaluatedAt};
}

export function entryVisible(row: FitQueueEntry, view: FitQueueView,
  policyRevision: number, qualificationHash: string | null,
  now: string): boolean {
  if (row.policyRevision !== policyRevision ||
      row.classification !== "sales_private") return false;
  if (view === "needs_research") {
    return row.score === null &&
    row.status !== "complete";
  }
  if (row.status !== "complete" || row.score === null ||
      row.expiresAt === null || row.expiresAt <= now) return false;
  return view === "ranked" ||
    row.eligibleForOutreachReview && qualificationHash !== null &&
    row.qualificationPolicyHash === qualificationHash &&
    row.suppressionStatus === "clear" &&
    !row.duplicateReviewRequired && row.researchStatus === "qualified";
}

export function encodeCursor(cursor: FitQueueCursor): string {
  return Buffer.from(JSON.stringify(cursor)).toString("base64url");
}
export function decodeCursor(value: unknown, expected: Omit<FitQueueCursor,
  "lastId" | "lastScore">): FitQueueCursor | null {
  if (value === undefined) return null;
  if (typeof value !== "string" || value.length > 600) {
    invalid("Fit queue cursor is invalid.");
  }
  let raw: unknown;
  try {
    raw = JSON.parse(Buffer.from(value as string, "base64url").toString("utf8"));
  } catch {
    invalid("Fit queue cursor is invalid.");
  }
  const cursor = raw as Partial<FitQueueCursor>;
  if (!cursor || typeof cursor !== "object" ||
      Object.keys(cursor).length !== 6 ||
      cursor.view !== expected.view ||
      cursor.policyRevision !== expected.policyRevision ||
      cursor.qualificationPolicyHash !== expected.qualificationPolicyHash ||
      cursor.generation !== expected.generation ||
      typeof cursor.lastId !== "string" ||
      !/^[A-Za-z0-9][A-Za-z0-9._:-]{0,95}$/u.test(cursor.lastId) ||
      (cursor.lastScore !== null &&
        (typeof cursor.lastScore !== "number" ||
          !Number.isFinite(cursor.lastScore)))) {
    throw new HttpsError("aborted", "Fit queue changed; restart at the first page.");
  }
  return cursor as FitQueueCursor;
}

export function receiptId(actorUid: string, requestId: string): string {
  return `fit-${hash([actorUid, requestId]).slice(0, 32)}`;
}
