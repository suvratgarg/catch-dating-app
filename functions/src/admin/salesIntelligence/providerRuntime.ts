/* eslint-disable max-len */
import path from "node:path";
import {pathToFileURL} from "node:url";
import type {SalesPrincipal} from "../sales/types";
import type {PartnerActor, PartnerDeps} from "../../partners/model";
import {validateSalesOutreachJobsDocument} from "../../shared/generated/validators/salesOutreachJobsDocument";
import {buildOutreachInput, buildPartnerOutreachInput, type IntelligenceDeps} from "./service";
import {jobIdFor, type DraftJob} from "./job";
import {fail, hash, id} from "./model";
import {checkedProviderBudget, checkProviderDispatch, completeProviderAttempt,
  reserveProviderAttempt, type CurrentProviderAttempt, type PreparationCache,
  type ProviderBudget, type WritingPreparation} from "./providerAttempt";

interface StagePolicy {
  executionMode: string; providerId: string; modelId: string; prompt: string;
  promptVersion: string; billingSourceId: string; budget: ProviderBudget;
}
interface FrozenPolicy {
  policy: {writing: StagePolicy}; policyHash: string;
  stageHashes: {writing: string};
}
interface Activation {
  status: "active"; ownerUid: string; stage: "writing"; policyHash: string;
  stageHash: string; billingSourceId: string; authorizationId: string; expiresAt: string;
}
export interface PublicWritingClause {
  dataClassification: "reviewed_public"; approved: true;
  id: string; kind: "observation" | "capability" | "reference" | "cta"; text: string;
}
/** Mandatory trusted server read port. Approval/citation alone is insufficient. */
export interface WritingAuthority {
  policy: unknown; ownerUid: string; activation: Activation;
  monthlyLimits: ProviderBudget; monthlyLimitsVersion: string;
  inputTokenCeiling: number;
  publicReview: {reviewId: string; reviewedByUid: string; expiresAt: string;
    dataClassification: "reviewed_public"; promptHash: string;
    clauses: PublicWritingClause[]};
}
export type WritingAccess = {
  kind: "employee"; actor: SalesPrincipal; deps: IntelligenceDeps;
} | {
  kind: "participant"; actor: PartnerActor; deps: PartnerDeps;
  expectedAssignmentRevision: number;
};
export interface WritingWorkerOptions {
  enabled?: boolean; access: WritingAccess;
  authority: {read: (tx: FirebaseFirestore.Transaction,
    binding: {job: DraftJob; bundle: Record<string, unknown>}) => Promise<WritingAuthority>};
  provider: {
    serverSecretRef: string;
    resolveSecret: (ref: string, options: {signal: AbortSignal}) => Promise<string>;
    transport: (url: string, options: RequestInit) => Promise<Response>;
    timeoutMs: number;
  };
}
interface PreparationModule {
  createSalesPreparationAdapter: (options: Record<string, unknown>) => {
    run: (request: Record<string, unknown>) => Promise<WritingPreparation>;
  };
}
interface PolicyModule {
  freezeSalesPreparationPolicy: (policy: unknown) => FrozenPolicy;
  authorizePreparationStage: (input: Record<string, unknown>) => Promise<{providerAuthority: boolean}>;
}
interface BudgetModule {BudgetLedger: new (options: {limits: ProviderBudget}) => unknown}
interface NativeModule { [key: string]: (options: Record<string, unknown>) => unknown }
async function packagedPreparation() {
  const load = (relative: string) => import(pathToFileURL(path.resolve(__dirname,
    "../../operations/src", relative)).href);
  const [preparation, policy, budget, deepseek, openai, anthropic] = await Promise.all([
    load("workflows/outreach-drafting/preparation-adapter.mjs"),
    load("workflows/outreach-drafting/preparation-policy.mjs"), load("platform/budget.mjs"),
    load("platform/model/deepseek-provider.mjs"), load("platform/model/openai-provider.mjs"),
    load("platform/model/anthropic-provider.mjs"),
  ]);
  return {preparation: preparation as PreparationModule, policy: policy as PolicyModule,
    budget: budget as BudgetModule, factories: {
      createDeepSeekProvider: (deepseek as NativeModule).createDeepSeekProvider,
      createOpenAIProvider: (openai as NativeModule).createOpenAIProvider,
      createAnthropicProvider: (anthropic as NativeModule).createAnthropicProvider,
    }};
}

/** Internal source composition only. No callable, trigger, default ports or billing activation. */
export function createSalesWritingPreparationWorker(options?: WritingWorkerOptions) {
  return {async run(request: {jobId: string; leaseOwner: string; signal?: AbortSignal}) {
    if (options?.enabled !== true) fail("failed-precondition", "Sales providers are disabled.");
    try {
      return await runWriting(options, request);
    } catch (error) {
      // Never expose raw port/provider/Firestore errors, details, cause or payload.
      const code = error && typeof error === "object" && "code" in error ? error.code : null;
      const safe = code === "aborted" || code === "permission-denied" ||
        code === "resource-exhausted" || code === "already-exists" || code === "not-found" ? code :
        "failed-precondition";
      return fail(safe, "Sales writing preparation stopped before a current validated result was available.");
    }
  }};
}

async function runWriting(options: WritingWorkerOptions,
  request: {jobId: string; leaseOwner: string; signal?: AbortSignal}) {
  const access = {...options.access, actor: structuredClone(options.access.actor)} as WritingAccess;
  const {db, now} = access.deps;
  const jobId = id(request.jobId);
  const leaseOwner = request.leaseOwner;
  const callerSignal = request.signal;
  if (typeof leaseOwner !== "string" || !leaseOwner || leaseOwner.length > 64 ||
      (callerSignal !== undefined && !(callerSignal instanceof AbortSignal)) ||
      !Number.isSafeInteger(options.provider.timeoutMs) || options.provider.timeoutMs < 1 ||
      options.provider.timeoutMs > 30_000 || !options.authority?.read ||
      !options.provider.resolveSecret || !options.provider.transport) {
    fail("failed-precondition", "Explicit trusted writing worker ports are required.");
  }
  const provider = {...options.provider};
  const authorityPort = options.authority.read;
  const modules = await packagedPreparation();
  const cancelled = (signal = callerSignal) => {
    if (signal?.aborted) fail("aborted", "Writing preparation was cancelled.");
  };
  cancelled();
  const read = async (tx: FirebaseFirestore.Transaction) => {
    cancelled();
    const raw = (await tx.get(db.collection("salesOutreachJobs").doc(jobId))).data();
    if (!validateSalesOutreachJobsDocument(raw)) fail("failed-precondition", "Current draft job is invalid.");
    const job = raw as unknown as DraftJob;
    if (job.jobId !== jobId || job.jobId !== jobIdFor(access.actor.uid, job.requestId) ||
        job.actorUid !== access.actor.uid || job.status !== "running" || job.leaseOwner !== leaseOwner ||
        (access.kind === "employee" && job.participantScope !== undefined) ||
        (access.kind === "participant" && (job.participantScope?.partnerUid !== access.actor.uid ||
          job.participantScope.assignmentRevision !== access.expectedAssignmentRevision))) {
      fail("permission-denied", "Current own drafting job and scope are required.");
    }
    const source = access.kind === "employee" ?
      await buildOutreachInput(access.deps, access.actor, job.sourceRequest, tx) :
      await buildPartnerOutreachInput(access.deps, access.actor, job.sourceRequest,
        access.expectedAssignmentRevision, tx);
    const bundle = source.bundle as Record<string, unknown>;
    if (source.sourceHash !== job.sourceHash ||
        hash({...bundle, evaluatedAt: null}) !== hash({...job.frozenBundle, evaluatedAt: null})) {
      fail("aborted", "Current writing sources changed.");
    }
    const authority = structuredClone(await authorityPort(tx, {job, bundle}));
    const frozen = modules.policy.freezeSalesPreparationPolicy(authority.policy);
    const setting = frozen.policy.writing;
    const approved = await modules.policy.authorizePreparationStage({frozen,
      currentPolicy: authority.policy, ownerUid: authority.ownerUid, stage: "writing", clock: now,
      activationPort: {current: async () => authority.activation}});
    if (!approved.providerAuthority) fail("failed-precondition", "Writing API authority is inactive.");
    const runLimits = checkedProviderBudget(setting.budget);
    const monthlyLimits = checkedProviderBudget(authority.monthlyLimits);
    const publicReview = authority.publicReview;
    id(authority.ownerUid); id(authority.activation.authorizationId); id(publicReview.reviewId);
    id(authority.monthlyLimitsVersion);
    if (publicReview.dataClassification !== "reviewed_public" ||
        publicReview.reviewedByUid !== authority.ownerUid || publicReview.promptHash !== hash(setting.prompt) ||
        !Number.isSafeInteger(authority.inputTokenCeiling) || authority.inputTokenCeiling <= 0 ||
        authority.inputTokenCeiling > runLimits.modelInputTokens || runLimits.modelCalls < 1 ||
        runLimits.networkRequests < 1 || !Array.isArray(publicReview.clauses) ||
        publicReview.clauses.length > 100) {
      fail("failed-precondition", "Fresh exact public disclosure and request ceiling review are required.");
    }
    const expected = new Map<string, {text: unknown; kind: string}>();
    for (const [name, kind] of [["observations", "observation"], ["capabilities", "capability"],
      ["references", "reference"], ["ctas", "cta"]]) {
      for (const row of bundle[name] as Array<{id: string; text: string}>) expected.set(row.id, {text: row.text, kind});
    }
    const publicClauses = publicReview.clauses.map((row) => {
      if (row.dataClassification !== "reviewed_public" || row.approved !== true ||
          expected.get(row.id)?.text !== row.text || expected.get(row.id)?.kind !== row.kind) {
        fail("failed-precondition", "Public writing review differs from canonical clauses.");
      }
      return {dataClassification: row.dataClassification, approved: row.approved,
        id: row.id, kind: row.kind, text: row.text};
    });
    if (publicClauses.length !== expected.size || new Set(publicClauses.map((row) => row.id)).size !== expected.size) {
      fail("failed-precondition", "Public writing review must cover the exact current clauses.");
    }
    const deadline = Math.min(Date.parse(job.leaseUntil ?? ""), Date.parse(job.expiresAt),
      Date.parse(authority.activation.expiresAt), Date.parse(publicReview.expiresAt));
    if (!Number.isFinite(deadline) || deadline <= now().getTime()) fail("aborted", "Writing authority or claim expired.");
    cancelled();
    const current: CurrentProviderAttempt = {jobId, actorUid: access.actor.uid,
      organizerId: job.sourceRequest.organizerId, leaseOwner, deadline,
      month: now().toISOString().slice(0, 7), billingScopeHash: hash(setting.billingSourceId),
      binding: {materialHash: job.materialHash, sourceHash: job.sourceHash,
        publicMaterialHash: hash({wireVersion: "sales-writing-v1", publicClauses, prompt: setting.prompt}),
        policyHash: frozen.policyHash, stageHash: frozen.stageHashes.writing,
        providerId: setting.providerId as CurrentProviderAttempt["binding"]["providerId"],
        modelId: setting.modelId, promptVersion: setting.promptVersion, ownerUid: authority.ownerUid,
        authorizationId: authority.activation.authorizationId, publicReviewId: publicReview.reviewId,
        participantScope: job.participantScope ?? null, runLimitsHash: hash(runLimits),
        monthlyLimitsHash: hash({limits: monthlyLimits, version: authority.monthlyLimitsVersion}),
        inputTokenCeiling: authority.inputTokenCeiling},
      reservation: {modelCalls: 1, networkRequests: 1, modelInputTokens: authority.inputTokenCeiling,
        modelOutputTokens: runLimits.modelOutputTokens, modelCostMicros: runLimits.modelCostMicros},
      runLimits, monthlyLimits};
    return {current, authority, frozen, publicClauses, job};
  };
  const initial = await db.runTransaction(read);
  const fresh = async (tx: FirebaseFirestore.Transaction) => {
    const next = await read(tx);
    if (hash(next.current.binding) !== hash(initial.current.binding)) {
      fail("aborted", "Frozen writing provider or public authority changed.");
    }
    return next;
  };
  const deps = {db, now, current: async (tx: FirebaseFirestore.Transaction) => (await fresh(tx)).current};
  const {attempt, dispatch} = await reserveProviderAttempt(deps);
  if (!dispatch && attempt.status !== "completed") {
    fail("failed-precondition", "Uncertain provider intent cannot automatically resubmit.");
  }
  const remaining = Math.min(provider.timeoutMs, initial.current.deadline - now().getTime() - 250);
  if (!Number.isSafeInteger(remaining) || remaining < 1) fail("aborted", "Insufficient worker deadline remains.");
  const signal = AbortSignal.any([AbortSignal.timeout(remaining), ...(callerSignal ? [callerSignal] : [])]);
  let buffered: PreparationCache | null = null;
  const adapter = modules.preparation.createSalesPreparationAdapter({enabled: true,
    factories: modules.factories, clock: now, monthlyWindow: initial.current.month,
    // This local validation ledger covers this worker's already-durable grant.
    // It is never the shared accounting authority or persisted monthly balance.
    monthlyBudget: new modules.budget.BudgetLedger({limits: initial.current.reservation}),
    activationPort: {current: async () => {
      cancelled(signal);
      const next = await db.runTransaction(fresh);
      cancelled(signal);
      return next.authority.activation;
    }},
    cache: {
      get: async (key: string) => {
        if (attempt.status !== "completed") return null;
        if (!attempt.cache || attempt.cache.provenance.cacheKey !== key) {
          fail("failed-precondition", "Stored preparation cache identity differs.");
        }
        return structuredClone(attempt.cache);
      },
      put: async (key: string, record: PreparationCache) => {
        if (!dispatch || record.provenance.cacheKey !== key) fail("aborted", "Writing cache identity changed.");
        buffered = structuredClone(record);
      },
    },
    providerOptions: {serverSecretRef: provider.serverSecretRef,
      resolveSecret: provider.resolveSecret, timeoutMs: remaining,
      transport: async (url: string, input: RequestInit) => {
        cancelled(signal);
        await checkProviderDispatch(deps, attempt);
        cancelled(signal);
        return provider.transport(url, input);
      }},
  });
  const prepared = await adapter.run({stage: "writing", frozen: initial.frozen,
    currentPolicy: initial.authority.policy, ownerUid: initial.authority.ownerUid,
    context: {organizerId: initial.job.sourceRequest.organizerId,
      contactId: initial.job.sourceRequest.contactId, opportunityId: initial.job.sourceRequest.opportunityId},
    publicClauses: initial.publicClauses,
    estimatedInputTokens: initial.authority.inputTokenCeiling, signal});
  const result: WritingPreparation = {selection: prepared.selection,
    selectionHash: prepared.selectionHash, policyHash: prepared.policyHash,
    stageHash: prepared.stageHash, stage: "writing", authorizationId: prepared.authorizationId,
    sendAuthority: false};
  if (dispatch) {
    if (!buffered) fail("failed-precondition", "Validated provider cache is missing.");
    await completeProviderAttempt(deps, attempt, buffered, result);
  } else if (hash(result) !== hash(attempt.result)) {
    fail("failed-precondition", "Canonical cached writing result differs.");
  }
  await db.runTransaction(fresh);
  cancelled(signal);
  const cache = dispatch ? buffered : attempt.cache;
  if (!cache) fail("failed-precondition", "Validated provider result is missing.");
  return {status: "completed" as const, attemptId: attempt.attemptId,
    preparation: result, cacheHit: !dispatch,
    usage: cache.provenance.usage, metadata: cache.provenance.metadata};
}
