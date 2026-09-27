/* eslint-disable max-len */
import {randomUUID} from "node:crypto";
import type {SalesPrincipal} from "../sales/types";
import {fail, hash, object, requestId} from "./model";
import {buildOutreachInput, type DraftRequest,
  type IntelligenceDeps} from "./service";

const CLAIM_MS = 60_000;
const JOB_MS = 10 * 60_000;
const MAX_ATTEMPTS = 3;
export interface DraftJob {
  schemaVersion: 1; classification: "sales_private";
  jobId: string; actorUid: string; requestId: string;
  materialHash: string; sourceHash: string;
  sourceRequest: DraftRequest; frozenBundle: Record<string, unknown>;
  status: "running" | "completed" | "failed";
  attemptCount: number; leaseOwner: string | null;
  leaseUntil: string | null; expiresAt: string;
  createdAt: string; updatedAt: string;
  result: {draftId: string; contentHash: string} | null;
  failure: string | null;
}

function parse(value: unknown): {request: string; sourceRequest: DraftRequest} {
  const input = object(value, ["requestId", "sourceRequest"]);
  const request = requestId(input.requestId);
  const sourceRequest = object(input.sourceRequest, ["organizerId", "contactId",
    "opportunityId", "observationIds", "capabilityIds", "referenceIds",
    "ctaIds", "channel", "purpose", "priorActivityId"]);
  // buildOutreachInput performs the bounded and authority-sensitive validation.
  return {request, sourceRequest: sourceRequest as unknown as DraftRequest};
}

export function jobIdFor(actorUid: string, request: string): string {
  return `outreach-job-${hash([actorUid, request]).slice(0, 32)}`;
}

function assertStoredJob(row: DraftJob | undefined, expectedId: string): DraftJob {
  if (!row || row.schemaVersion !== 1 ||
      row.classification !== "sales_private" || row.jobId !== expectedId ||
      !["running", "completed", "failed"].includes(row.status) ||
      !Number.isInteger(row.attemptCount) || row.attemptCount < 1 ||
      row.attemptCount > MAX_ATTEMPTS ||
      !Number.isFinite(Date.parse(row.createdAt)) ||
      !Number.isFinite(Date.parse(row.expiresAt)) ||
      (row.status === "running" && (!row.leaseOwner ||
        !Number.isFinite(Date.parse(row.leaseUntil ?? "")))) ||
      (row.status === "completed" && (!row.result ||
        row.result.draftId.length === 0)) ||
      (row.status !== "completed" && row.result !== null)) {
    return fail("failed-precondition", "Draft job state is invalid.");
  }
  return row;
}

export async function claimDraftJob(deps: IntelligenceDeps,
  principal: SalesPrincipal, payload: unknown): Promise<{
    job: DraftJob; claimed: boolean}> {
  const {request, sourceRequest} = parse(payload);
  const db = deps.db;
  const ref = db.collection("salesOutreachJobs").doc(jobIdFor(principal.uid, request));
  const materialHash = hash(sourceRequest);
  const leaseOwner = randomUUID();
  await deps.authorize(principal, false);
  return db.runTransaction(async (tx) => {
    await deps.authorize(principal, false);
    const raw = (await tx.get(ref)).data() as DraftJob | undefined;
    const prior = raw ? assertStoredJob(raw, ref.id) : undefined;
    const current = await buildOutreachInput(deps, principal, sourceRequest, tx);
    const now = deps.now().toISOString();
    if (prior) {
      if (prior.actorUid !== principal.uid || prior.materialHash !== materialHash ||
          prior.requestId !== request) {
        return fail("already-exists", "Draft request ID belongs to different material.");
      }
      if (prior.sourceHash !== current.sourceHash ||
          Date.parse(prior.expiresAt) <= Date.parse(now)) {
        return fail("aborted", "Draft request sources changed or expired.");
      }
      if (prior.status === "completed" || prior.status === "failed" ||
          Date.parse(prior.leaseUntil ?? "") > Date.parse(now)) {
        return {job: prior, claimed: false};
      }
      if (prior.attemptCount >= MAX_ATTEMPTS) {
        return fail("resource-exhausted", "Draft retry limit reached.");
      }
      const next: DraftJob = {...prior, attemptCount: prior.attemptCount + 1,
        leaseOwner, leaseUntil: new Date(Date.parse(now) + CLAIM_MS).toISOString(),
        updatedAt: now};
      tx.set(ref, next);
      return {job: next, claimed: true};
    }
    const job: DraftJob = {schemaVersion: 1, classification: "sales_private",
      jobId: ref.id, actorUid: principal.uid, requestId: request,
      materialHash, sourceHash: current.sourceHash as string,
      sourceRequest, frozenBundle: current.bundle as Record<string, unknown>,
      status: "running", attemptCount: 1, leaseOwner,
      leaseUntil: new Date(Date.parse(now) + CLAIM_MS).toISOString(),
      expiresAt: new Date(Date.parse(now) + JOB_MS).toISOString(),
      createdAt: now, updatedAt: now, result: null, failure: null};
    tx.create(ref, job);
    return {job, claimed: true};
  });
}

export async function completeDraftJob(deps: IntelligenceDeps,
  principal: SalesPrincipal, job: DraftJob,
  result: {draftId: string; draft: {contentHash: string}}): Promise<DraftJob> {
  const ref = deps.db.collection("salesOutreachJobs").doc(job.jobId);
  return deps.db.runTransaction(async (tx) => {
    await deps.authorize(principal, false);
    const raw = (await tx.get(ref)).data() as DraftJob | undefined;
    const currentJob = raw ? assertStoredJob(raw, ref.id) : undefined;
    if (!currentJob || currentJob.actorUid !== principal.uid ||
        currentJob.materialHash !== job.materialHash ||
        currentJob.leaseOwner !== job.leaseOwner ||
        currentJob.status !== "running") {
      return fail("aborted", "Draft claim changed before completion.");
    }
    const now = deps.now().toISOString();
    if (Date.parse(currentJob.leaseUntil ?? "") <= Date.parse(now) ||
        Date.parse(currentJob.expiresAt) <= Date.parse(now)) {
      return fail("aborted", "Draft claim expired before completion.");
    }
    const source = await buildOutreachInput(deps, principal,
      currentJob.sourceRequest, tx);
    if (source.sourceHash !== currentJob.sourceHash) {
      return fail("aborted", "Sales source changed before draft completion.");
    }
    const draft = (await tx.get(deps.db.collection("salesOutreachDrafts")
      .doc(result.draftId))).data();
    if (!draft || draft.createdBy !== principal.uid ||
        draft.sourceHash !== currentJob.sourceHash ||
        draft.draft?.contentHash !== result.draft.contentHash) {
      return fail("failed-precondition", "Persisted Operations draft is missing or changed.");
    }
    const next: DraftJob = {...currentJob, status: "completed",
      leaseOwner: null, leaseUntil: null, updatedAt: now,
      result: {draftId: result.draftId,
        contentHash: result.draft.contentHash}, failure: null};
    tx.set(ref, next);
    return next;
  });
}

export async function failDraftJob(deps: IntelligenceDeps,
  principal: SalesPrincipal, job: DraftJob, reason: string): Promise<void> {
  const ref = deps.db.collection("salesOutreachJobs").doc(job.jobId);
  await deps.db.runTransaction(async (tx) => {
    await deps.authorize(principal, false);
    const raw = (await tx.get(ref)).data() as DraftJob | undefined;
    const current = raw ? assertStoredJob(raw, ref.id) : undefined;
    if (!current || current.actorUid !== principal.uid ||
        current.leaseOwner !== job.leaseOwner || current.status !== "running") {
      return;
    }
    const now = deps.now().toISOString();
    tx.set(ref, {...current, status: "failed", leaseOwner: null,
      leaseUntil: null, updatedAt: now, failure: reason, result: null});
  });
}

export async function getDraftJob(deps: IntelligenceDeps,
  principal: SalesPrincipal, payload: unknown): Promise<Record<string, unknown>> {
  const input = object(payload, ["requestId"]);
  const request = requestId(input.requestId);
  await deps.authorize(principal, false);
  const expectedId = jobIdFor(principal.uid, request);
  const raw = (await deps.db.collection("salesOutreachJobs")
    .doc(expectedId).get()).data() as DraftJob | undefined;
  const job = raw ? assertStoredJob(raw, expectedId) : undefined;
  if (!job || job.actorUid !== principal.uid) {
    return fail("not-found", "Draft request not found.");
  }
  const source = await buildOutreachInput(deps, principal, job.sourceRequest);
  await deps.authorize(principal, false);
  if (source.sourceHash !== job.sourceHash) {
    return fail("aborted", "Draft request sources changed.");
  }
  if (Date.parse(job.expiresAt) <= deps.now().getTime()) {
    return fail("failed-precondition", "Draft request expired.");
  }
  return {status: job.status, result: job.result, failure: job.failure,
    retryAfterSeconds: job.status === "running" ? 5 : null};
}
