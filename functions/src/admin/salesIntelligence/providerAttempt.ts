/* eslint-disable max-len */
import {randomUUID} from "node:crypto";
import type {SalesProviderAttemptDocument} from "../../shared/generated/salesProviderAttemptDocument";
import type {SalesProviderBudgetDocument} from "../../shared/generated/salesProviderBudgetDocument";
import {validateSalesProviderAttemptDocument} from "../../shared/generated/validators/salesProviderAttemptDocument";
import {validateSalesProviderBudgetDocument} from "../../shared/generated/validators/salesProviderBudgetDocument";
import {fail, hash} from "./model";

export type ProviderAttempt = SalesProviderAttemptDocument;
export type ProviderBudget = SalesProviderBudgetDocument["limits"];
export type PreparationCache = NonNullable<ProviderAttempt["cache"]>;
export type WritingPreparation = NonNullable<ProviderAttempt["result"]>;
export const PROVIDER_BUDGET_KEYS = ["modelCalls", "networkRequests",
  "modelInputTokens", "modelOutputTokens", "modelCostMicros"] as const;

/** A trusted worker rebuilds this under current source/authority reads in tx. */
export interface CurrentProviderAttempt {
  jobId: string; actorUid: string; organizerId: string;
  leaseOwner: string; deadline: number; month: string;
  binding: ProviderAttempt["binding"];
  reservation: ProviderBudget; runLimits: ProviderBudget;
  monthlyLimits: ProviderBudget; billingScopeHash: string;
}
export interface ProviderAttemptDeps {
  db: FirebaseFirestore.Firestore; now: () => Date;
  current: (tx: FirebaseFirestore.Transaction) => Promise<CurrentProviderAttempt>;
}

/** Binding drift must not create a second paid identity for the same stage. */
export function providerAttemptId(jobId: string): string {
  return `provider-attempt-${hash([jobId, "writing"]).slice(0, 40)}`;
}
export function providerBudgetIds(current: CurrentProviderAttempt) {
  return {
    run: `provider-run-${hash([current.jobId, "writing"]).slice(0, 40)}`,
    month: `provider-month-${hash([current.billingScopeHash, current.month]).slice(0, 40)}`,
  };
}
export function checkedProviderBudget(value: unknown): ProviderBudget {
  if (!value || typeof value !== "object" || Array.isArray(value) ||
      Object.keys(value).length !== PROVIDER_BUDGET_KEYS.length) {
    fail("failed-precondition", "Explicit provider budget dimensions are required.");
  }
  const row = value as ProviderBudget;
  for (const key of PROVIDER_BUDGET_KEYS) {
    if (!Number.isSafeInteger(row[key]) || row[key] < 0 || row[key] > 1_000_000_000_000) {
      fail("failed-precondition", "Provider budget is invalid.");
    }
  }
  return {...row};
}
function bindingHash(current: CurrentProviderAttempt): string {
  return hash({jobId: current.jobId, actorUid: current.actorUid,
    organizerId: current.organizerId, stage: "writing", binding: current.binding});
}
function assertCurrent(current: CurrentProviderAttempt, now: Date): void {
  checkedProviderBudget(current.reservation);
  checkedProviderBudget(current.runLimits);
  checkedProviderBudget(current.monthlyLimits);
  if (!Number.isFinite(now.getTime()) || current.deadline <= now.getTime() ||
      current.month !== now.toISOString().slice(0, 7) ||
      current.reservation.modelCalls !== 1 || current.reservation.networkRequests !== 1 ||
      current.reservation.modelInputTokens !== current.binding.inputTokenCeiling ||
      current.binding.runLimitsHash !== hash(current.runLimits)) {
    fail("aborted", "Current provider authority, fence or budget window changed.");
  }
}
function checkedAttempt(raw: unknown, current: CurrentProviderAttempt): ProviderAttempt {
  if (!validateSalesProviderAttemptDocument(raw) ||
      raw.attemptId !== providerAttemptId(current.jobId) ||
      raw.bindingHash !== bindingHash(current) ||
      raw.bindingHash !== hash({jobId: raw.jobId, actorUid: raw.actorUid,
        organizerId: raw.organizerId, stage: raw.stage, binding: raw.binding})) {
    fail("aborted", "Provider preparation identity or frozen material changed.");
  }
  return raw;
}
function bucket(raw: unknown, current: CurrentProviderAttempt,
  kind: "run" | "month", now: string): SalesProviderBudgetDocument {
  const ids = providerBudgetIds(current);
  const limits = kind === "run" ? current.runLimits : current.monthlyLimits;
  const limitsHash = kind === "run" ? current.binding.runLimitsHash : current.binding.monthlyLimitsHash;
  const scopeHash = kind === "run" ? hash([current.jobId, "writing"]) : current.billingScopeHash;
  const month = kind === "month" ? current.month : null;
  if (raw !== undefined) {
    if (!validateSalesProviderBudgetDocument(raw) || raw.bucketId !== ids[kind] ||
        raw.kind !== kind || raw.scopeHash !== scopeHash || raw.month !== month ||
        raw.limitsHash !== limitsHash || hash(raw.limits) !== hash(limits) ||
        PROVIDER_BUDGET_KEYS.some((key) => raw.consumed[key] > raw.limits[key])) {
      fail("failed-precondition", "Stored provider budget binding is invalid.");
    }
    return raw;
  }
  return {schemaVersion: 1, classification: "sales_private", bucketId: ids[kind],
    kind, scopeHash, month, limitsHash, limits,
    consumed: {modelCalls: 0, networkRequests: 0, modelInputTokens: 0,
      modelOutputTokens: 0, modelCostMicros: 0}, updatedAt: now};
}
function reserve(row: SalesProviderBudgetDocument, reservation: ProviderBudget,
  now: string): SalesProviderBudgetDocument {
  const consumed = {...row.consumed};
  for (const key of PROVIDER_BUDGET_KEYS) {
    if (reservation[key] > row.limits[key] - consumed[key]) {
      fail("resource-exhausted", "Provider run or monthly ceiling is exhausted.");
    }
    consumed[key] += reservation[key];
  }
  return {...row, consumed, updatedAt: now};
}

/** Commit intent and both reservations together. Never perform I/O in tx. */
export async function reserveProviderAttempt(deps: ProviderAttemptDeps): Promise<{
  attempt: ProviderAttempt; dispatch: boolean;
}> {
  const submissionNonce = randomUUID();
  return deps.db.runTransaction(async (tx) => {
    const current = await deps.current(tx);
    const ref = deps.db.collection("salesProviderAttempts").doc(providerAttemptId(current.jobId));
    const prior = (await tx.get(ref)).data();
    if (prior) {
      const attempt = checkedAttempt(prior, current);
      assertCurrent(current, deps.now());
      return {attempt, dispatch: false};
    }
    const ids = providerBudgetIds(current);
    const runRef = deps.db.collection("salesProviderBudgets").doc(ids.run);
    const monthRef = deps.db.collection("salesProviderBudgets").doc(ids.month);
    const [run, month] = await Promise.all([tx.get(runRef), tx.get(monthRef)]);
    assertCurrent(current, deps.now());
    const now = deps.now().toISOString();
    const attempt: ProviderAttempt = {schemaVersion: 1, classification: "sales_private",
      attemptId: ref.id, jobId: current.jobId, actorUid: current.actorUid,
      organizerId: current.organizerId, stage: "writing", bindingHash: bindingHash(current),
      binding: current.binding, status: "intent", submissionNonce,
      leaseOwner: current.leaseOwner, month: current.month,
      runBucketId: ids.run, monthlyBucketId: ids.month, reservation: current.reservation,
      createdAt: now, updatedAt: now, cache: null, result: null};
    if (!validateSalesProviderAttemptDocument(attempt)) {
      fail("failed-precondition", "Provider intent does not satisfy its contract.");
    }
    const nextRun = reserve(bucket(run.data(), current, "run", now), current.reservation, now);
    const nextMonth = reserve(bucket(month.data(), current, "month", now), current.reservation, now);
    tx.set(runRef, nextRun);
    tx.set(monthRef, nextMonth);
    tx.create(ref, attempt);
    return {attempt, dispatch: true};
  });
}

/** A returned reservation alone is insufficient after a wait or lease change. */
export async function checkProviderDispatch(deps: ProviderAttemptDeps,
  attempt: ProviderAttempt): Promise<void> {
  await deps.db.runTransaction(async (tx) => {
    const current = await deps.current(tx);
    const row = checkedAttempt((await tx.get(deps.db.collection("salesProviderAttempts")
      .doc(attempt.attemptId))).data(), current);
    assertCurrent(current, deps.now());
    if (row.status !== "intent" || row.submissionNonce !== attempt.submissionNonce ||
        row.leaseOwner !== current.leaseOwner || row.month !== current.month) {
      fail("aborted", "Provider submission fence changed.");
    }
  });
}

function checkedUsage(attempt: ProviderAttempt, cache: PreparationCache,
  result: WritingPreparation): ProviderBudget {
  const {provenance} = cache;
  const {binding, reservation} = attempt;
  if (provenance.providerId !== binding.providerId || provenance.modelId !== binding.modelId ||
      provenance.task !== `sales-writing-${binding.stageHash}` ||
      provenance.promptVersion !== binding.promptVersion || provenance.monthlyWindow !== attempt.month ||
      provenance.request.estimatedInputTokens !== binding.inputTokenCeiling ||
      provenance.request.maxOutputTokens !== reservation.modelOutputTokens ||
      provenance.request.maxCostMicros !== reservation.modelCostMicros ||
      provenance.metadata.providerId !== binding.providerId || provenance.metadata.modelId !== binding.modelId ||
      provenance.metadata.tokens.inputTotal !== provenance.usage.inputTokens ||
      provenance.metadata.tokens.outputTotal !== provenance.usage.outputTokens ||
      provenance.usage.costMicros !== reservation.modelCostMicros ||
      result.policyHash !== binding.policyHash || result.stageHash !== binding.stageHash ||
      result.authorizationId !== binding.authorizationId ||
      result.selection.organizerId !== attempt.organizerId || result.selectionHash !== hash(result.selection)) {
    fail("failed-precondition", "Validated provider result or usage binding is invalid.");
  }
  const actual: ProviderBudget = {modelCalls: 1, networkRequests: 1,
    modelInputTokens: provenance.usage.inputTokens,
    modelOutputTokens: provenance.usage.outputTokens,
    modelCostMicros: provenance.usage.costMicros};
  if (PROVIDER_BUDGET_KEYS.some((key) => actual[key] > reservation[key])) {
    fail("resource-exhausted", "Provider usage exceeds its reservation.");
  }
  return actual;
}
function reconcile(row: SalesProviderBudgetDocument, reserved: ProviderBudget,
  actual: ProviderBudget, now: string): SalesProviderBudgetDocument {
  const consumed = {...row.consumed};
  for (const key of PROVIDER_BUDGET_KEYS) {
    if (consumed[key] < reserved[key]) fail("failed-precondition", "Provider reservation is missing.");
    consumed[key] = consumed[key] - reserved[key] + actual[key];
  }
  return {...row, consumed, updatedAt: now};
}

/** Canonical result, cache, terminal marker and accounting share one commit. */
export async function completeProviderAttempt(deps: ProviderAttemptDeps,
  attempt: ProviderAttempt, cache: PreparationCache,
  result: WritingPreparation): Promise<ProviderAttempt> {
  return deps.db.runTransaction(async (tx) => {
    const current = await deps.current(tx);
    const ref = deps.db.collection("salesProviderAttempts").doc(attempt.attemptId);
    const prior = checkedAttempt((await tx.get(ref)).data(), current);
    assertCurrent(current, deps.now());
    if (prior.submissionNonce !== attempt.submissionNonce || prior.leaseOwner !== current.leaseOwner) {
      fail("aborted", "Provider completion fence changed.");
    }
    if (prior.status === "completed") {
      if (hash(prior.cache) !== hash(cache) || hash(prior.result) !== hash(result)) {
        fail("already-exists", "Provider completion receipt differs.");
      }
      return prior;
    }
    if (prior.month !== current.month) fail("aborted", "Provider budget window changed.");
    const now = deps.now().toISOString();
    const next: ProviderAttempt = {...prior, status: "completed", updatedAt: now, cache, result};
    if (!validateSalesProviderAttemptDocument(next)) {
      fail("failed-precondition", "Provider completion does not satisfy its contract.");
    }
    const actual = checkedUsage(prior, cache, result);
    const runRef = deps.db.collection("salesProviderBudgets").doc(prior.runBucketId);
    const monthRef = deps.db.collection("salesProviderBudgets").doc(prior.monthlyBucketId);
    const [run, month] = await Promise.all([tx.get(runRef), tx.get(monthRef)]);
    if (!run.exists || !month.exists) fail("failed-precondition", "Provider budget state is missing.");
    assertCurrent(current, deps.now());
    const nextRun = reconcile(bucket(run.data(), current, "run", now), prior.reservation, actual, now);
    const nextMonth = reconcile(bucket(month.data(), current, "month", now), prior.reservation, actual, now);
    tx.set(ref, next);
    tx.set(runRef, nextRun);
    tx.set(monthRef, nextMonth);
    return next;
  });
}
