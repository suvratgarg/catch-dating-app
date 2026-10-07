/* eslint-disable max-len */
import {assertSalesMaterialPrivacyOpen} from "../sales/privacyBoundary";
import {randomUUID} from "node:crypto";
import type {SalesPrincipal} from "../sales/types";
import {fail, hash, id, object, requestId, revision} from "./model";
import {requireAssignment} from "../../partners/service";
import {expectRevision, type PartnerActor, type PartnerDeps} from "../../partners/model";
import {assertPersistedOutreachDraftIntegrity, buildOutreachInput, buildPartnerOutreachInput, type DraftRequest,
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
  participantScope?: {partnerUid: string; assignmentRevision: number};
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
      (row.participantScope !== undefined &&
        (!row.participantScope || row.participantScope.partnerUid !== row.actorUid ||
          !Number.isSafeInteger(row.participantScope.assignmentRevision) ||
          row.participantScope.assignmentRevision < 1)) ||
      (row.status !== "completed" && row.result !== null)) {
    return fail("failed-precondition", "Draft job state is invalid.");
  }
  return row;
}

interface DraftJobAccess {
  beforeTransaction: () => Promise<void>;
  inTransaction: (tx: FirebaseFirestore.Transaction) => Promise<void>;
  current: (sourceRequest: DraftRequest, tx: FirebaseFirestore.Transaction) => Promise<Record<string, unknown>>;
  participantScope?: {partnerUid: string; assignmentRevision: number};
}
function employeeJobAccess(deps: IntelligenceDeps, principal: SalesPrincipal): DraftJobAccess {
  return {beforeTransaction: () => deps.authorize(principal, false),
    inTransaction: () => deps.authorize(principal, false),
    current: (sourceRequest, tx) => buildOutreachInput(deps, principal, sourceRequest, tx)};
}
function participantJobAccess(deps: PartnerDeps, actor: PartnerActor,
  organizerId: string, expectedAssignmentRevision: number): DraftJobAccess {
  const expected = revision(expectedAssignmentRevision);
  return {beforeTransaction: () => deps.checkAuth(actor, false),
    inTransaction: async (tx) => {
      const assignment = await requireAssignment(deps, actor, tx, organizerId);
      expectRevision(assignment.revision, expected);
    },
    current: (sourceRequest, tx) => buildPartnerOutreachInput(deps, actor, sourceRequest, expected, tx),
    participantScope: {partnerUid: actor.uid, assignmentRevision: expected}};
}

export async function claimDraftJob(deps: IntelligenceDeps,
  principal: SalesPrincipal, payload: unknown) {
  return claimDraftJobCore(deps, principal, payload, employeeJobAccess(deps, principal));
}
export async function claimPartnerDraftJob(deps: PartnerDeps,
  actor: PartnerActor, payload: unknown) {
  const input = object(payload, ["requestId", "sourceRequest", "expectedAssignmentRevision"]);
  const parsed = parse({requestId: input.requestId, sourceRequest: input.sourceRequest});
  return claimDraftJobCore(deps, actor,
    {requestId: parsed.request, sourceRequest: parsed.sourceRequest},
    participantJobAccess(deps, actor, id(parsed.sourceRequest.organizerId),
      revision(input.expectedAssignmentRevision)));
}
async function claimDraftJobCore(deps: Pick<IntelligenceDeps, "db" | "now">,
  principal: SalesPrincipal, payload: unknown, access: DraftJobAccess): Promise<{
    job: DraftJob; claimed: boolean}> {
  const {request, sourceRequest} = parse(payload);
  const db = deps.db;
  const ref = db.collection("salesOutreachJobs").doc(jobIdFor(principal.uid, request));
  const materialHash = hash(access.participantScope ?
    {sourceRequest, participantScope: access.participantScope} : sourceRequest);
  const leaseOwner = randomUUID();
  await access.beforeTransaction();
  return db.runTransaction(async (tx) => {
    await access.inTransaction(tx);
    const raw = (await tx.get(ref)).data() as DraftJob | undefined;
    const prior = raw ? assertStoredJob(raw, ref.id) : undefined;
    const current = await access.current(sourceRequest, tx);
    if (prior) {
      if (prior.actorUid !== principal.uid ||
          hash(prior.participantScope ?? null) !== hash(access.participantScope ?? null) ||
          prior.materialHash !== materialHash ||
          prior.requestId !== request) {
        return fail("already-exists", "Draft request ID belongs to different material.");
      }
      if (prior.sourceHash !== current.sourceHash) {
        return fail("aborted", "Draft request sources changed or expired.");
      }
      if (prior.status === "completed") await assertPersistedJobResult(deps.db, tx, principal, prior, access);
      await access.inTransaction(tx);
      const now = deps.now().toISOString();
      if (Date.parse(prior.expiresAt) <= Date.parse(now)) {
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
    await access.inTransaction(tx);
    const now = deps.now().toISOString();
    const job: DraftJob = {schemaVersion: 1, classification: "sales_private",
      jobId: ref.id, actorUid: principal.uid, requestId: request,
      materialHash, sourceHash: current.sourceHash as string,
      sourceRequest, frozenBundle: current.bundle as Record<string, unknown>,
      status: "running", attemptCount: 1, leaseOwner,
      leaseUntil: new Date(Date.parse(now) + CLAIM_MS).toISOString(),
      expiresAt: new Date(Date.parse(now) + JOB_MS).toISOString(),
      createdAt: now, updatedAt: now, result: null, failure: null,
      ...(access.participantScope ? {participantScope: access.participantScope} : {})};
    tx.create(ref, job);
    return {job, claimed: true};
  });
}

export async function completeDraftJob(deps: IntelligenceDeps,
  principal: SalesPrincipal, job: DraftJob,
  result: {draftId: string; draft: {contentHash: string}}): Promise<DraftJob> {
  return completeDraftJobCore(deps, principal, job, result, employeeJobAccess(deps, principal));
}
export async function completePartnerDraftJob(deps: PartnerDeps,
  actor: PartnerActor, job: DraftJob,
  result: {draftId: string; draft: {contentHash: string}}): Promise<DraftJob> {
  if (job.participantScope?.partnerUid !== actor.uid) {
    fail("permission-denied", "Current own participant job is required.");
  }
  return completeDraftJobCore(deps, actor, job, result,
    participantJobAccess(deps, actor, id(job.sourceRequest.organizerId), job.participantScope.assignmentRevision));
}
async function completeDraftJobCore(deps: Pick<IntelligenceDeps, "db" | "now">,
  principal: SalesPrincipal, job: DraftJob,
  result: {draftId: string; draft: {contentHash: string}}, access: DraftJobAccess): Promise<DraftJob> {
  const ref = deps.db.collection("salesOutreachJobs").doc(job.jobId);
  return deps.db.runTransaction(async (tx) => {
    await access.inTransaction(tx);
    const raw = (await tx.get(ref)).data() as DraftJob | undefined;
    const currentJob = raw ? assertStoredJob(raw, ref.id) : undefined;
    if (!currentJob || currentJob.actorUid !== principal.uid ||
        hash(currentJob.participantScope ?? null) !== hash(access.participantScope ?? null) ||
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
    const source = await access.current(currentJob.sourceRequest, tx);
    if (source.sourceHash !== currentJob.sourceHash) {
      return fail("aborted", "Sales source changed before draft completion.");
    }
    const completedResult = {draftId: result.draftId, contentHash: result.draft.contentHash};
    await assertPersistedJobResult(deps.db, tx, principal, {...currentJob, result: completedResult}, access);
    await access.inTransaction(tx);
    const completedAt = deps.now().toISOString();
    if (Date.parse(currentJob.leaseUntil ?? "") <= Date.parse(completedAt) ||
        Date.parse(currentJob.expiresAt) <= Date.parse(completedAt)) {
      return fail("aborted", "Draft claim expired before completion.");
    }
    const next: DraftJob = {...currentJob, status: "completed",
      leaseOwner: null, leaseUntil: null, updatedAt: completedAt,
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
    await assertSalesMaterialPrivacyOpen(deps.db, current, tx);
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
  await assertSalesMaterialPrivacyOpen(deps.db, job);
  return {status: job.status, result: job.result, failure: job.failure,
    retryAfterSeconds: job.status === "running" ? 5 : null};
}

export async function getPartnerDraftJob(deps: PartnerDeps,
  actor: PartnerActor, payload: unknown): Promise<Record<string, unknown>> {
  const input = object(payload, ["requestId", "organizerId", "expectedAssignmentRevision"]);
  const request = requestId(input.requestId);
  const organizerId = id(input.organizerId);
  const expected = revision(input.expectedAssignmentRevision);
  const access = participantJobAccess(deps, actor, organizerId, expected);
  await access.beforeTransaction();
  return deps.db.runTransaction(async (tx) => {
    await access.inTransaction(tx);
    const expectedId = jobIdFor(actor.uid, request);
    const raw = (await tx.get(deps.db.collection("salesOutreachJobs").doc(expectedId))).data() as DraftJob | undefined;
    const job = raw ? assertStoredJob(raw, expectedId) : undefined;
    if (!job || job.actorUid !== actor.uid || job.sourceRequest.organizerId !== organizerId ||
        hash(job.participantScope ?? null) !== hash(access.participantScope)) {
      fail("not-found", "Current own participant request not found.");
    }
    const source = await access.current(job.sourceRequest, tx);
    if (source.sourceHash !== job.sourceHash) fail("aborted", "Draft request sources changed.");
    if (Date.parse(job.expiresAt) <= deps.now().getTime()) fail("failed-precondition", "Draft request expired.");
    if (job.status === "completed") await assertPersistedJobResult(deps.db, tx, actor, job, access);
    await access.inTransaction(tx);
    if (Date.parse(job.expiresAt) <= deps.now().getTime()) fail("failed-precondition", "Draft request expired.");
    return {status: job.status, result: job.result, failure: job.failure,
      retryAfterSeconds: job.status === "running" ? 5 : null};
  });
}

/** Every completed replay binds the current stored artifact, never just its pointer. */
async function assertPersistedJobResult(db: FirebaseFirestore.Firestore,
  tx: FirebaseFirestore.Transaction, principal: SalesPrincipal, job: DraftJob,
  access: DraftJobAccess): Promise<void> {
  if (!job.result) fail("failed-precondition", "Persisted Operations result is missing.");
  const draft = (await tx.get(db.collection("salesOutreachDrafts").doc(job.result.draftId))).data();
  if (!draft || draft.schemaVersion !== 1 || draft.classification !== "sales_private" ||
      draft.createdBy !== principal.uid || draft.organizerId !== job.sourceRequest.organizerId ||
      draft.draftId !== job.result.draftId || draft.draft?.draftId !== job.result.draftId ||
      (access.participantScope && (draft.participantScope?.partnerUid !== principal.uid ||
        draft.participantScope?.assignmentRevision !== access.participantScope.assignmentRevision)) ||
      (!access.participantScope && draft.participantScope !== undefined) ||
      draft.sourceHash !== job.sourceHash || draft.draft?.contentHash !== job.result.contentHash) {
    fail("failed-precondition", "Persisted Operations draft is missing or changed.");
  }
  assertPersistedOutreachDraftIntegrity(draft, job.result.draftId, job.frozenBundle);
}
