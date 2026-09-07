import {operationContentHash} from "../../operations/durableActions";
import type {OperationRun, OperationWorkItem} from "../../operations/models";
import {validateOperationRun, validateOperationWorkItem} from
  "../../operations/validation";
import type {EventAssistanceSourceWork as SourceWork} from
  "../../shared/generated/eventAssistanceSourceWork";
import {validateEventAssistanceSourceWork} from
  "../../shared/generated/validators/eventAssistanceSourceWork";
import {guestIdentity, requireDocumentId} from "./guestRecords";
import {ASSISTANCE_POLICY_VERSION} from "./policySettings";
import {ASSISTANCE_WORKFLOW, invalidWork} from "./liveWorkRecords";
import {parseReadinessTargetKey} from "./sourceReadinessTargets";

export type {SourceWork};
export const SOURCE_WORK_RUNTIME = "event-assistance-source/v1";
export const SOURCE_WORK_LIFETIME = 86_400_000;
export type SourceWorkInput = Pick<SourceWork, "scope" | "source">;
export type EventSourceScope = Extract<SourceWork["scope"], {context: unknown}>;
export type ReadinessSourceScope =
  Exclude<SourceWork["scope"], EventSourceScope>;
export const isEventSourceScope = (scope: SourceWork["scope"]):
  scope is EventSourceScope => "context" in scope;
export const sourceFailureId =
  (f: SourceWork["checkpoint"]["failures"][number]) =>
    "workItemId" in f ? f.workItemId : f.targetKey;

export function sourceWorkIds(input: SourceWorkInput) {
  const scope = input.scope;
  if (isEventSourceScope(scope)) {
    guestIdentity(scope.context, scope.attendeeId ?? "scope");
  } else if (scope.kind === "sender") {
    requireDocumentId(scope.senderId);
  } else {
    requireDocumentId(scope.organizerId);
    requireDocumentId(scope.recipientEndpointId);
  }
  requireDocumentId(input.source.eventId);
  requireDocumentId(input.source.documentId);
  const key = operationContentHash({scope: input.scope, source: input.source});
  return {signalId: "signal:" + key,
    runId: "run:source:" + key, workItemId: "work:source:" + key};
}

export function sourceWorkProjection(payload: SourceWork) {
  const {phase, failures, visited} = payload.checkpoint;
  const terminal = phase === "complete" || phase === "expired";
  const review = phase === "review";
  return {primaryStage: terminal ? "finished" : review ? "host_review" :
    phase === "retry" ? "retrying" : "fanout",
  lifecycleStatus: terminal ? "terminal" as const : "waiting" as const,
  outcome: terminal ? phase : null,
  taskFlags: review ? ["human_review_required"] : [],
  blockerCodes: review ? [visited >= 10_000 ? "target_limit" :
    failures.length >= 100 ? "failure_limit" : "target_unavailable"] : []};
}

export function sourceWorkBasis(payload: SourceWork) {
  return {schemaVersion: payload.schemaVersion, kind: payload.kind,
    signalId: payload.signalId, scope: payload.scope, source: payload.source,
    expiresAt: payload.expiresAt};
}

export function parseSourceWork(value: unknown, now: number): SourceWork {
  if (!validateEventAssistanceSourceWork(value)) throw invalidWork();
  const ids = sourceWorkIds(value);
  const c = value.checkpoint;
  if (!Number.isSafeInteger(now) || now < value.source.occurredAt ||
      value.signalId !== ids.signalId || value.expiresAt !==
        value.source.occurredAt + SOURCE_WORK_LIFETIME ||
      (c.dueAt !== null && (c.dueAt > value.expiresAt ||
        c.dueAt < value.source.occurredAt)) ||
      (["complete", "review", "expired"].includes(c.phase)) !==
        (c.dueAt === null) ||
      (c.phase === "complete" && c.failures.length !== 0) ||
      (c.phase === "retry" && (c.failures.length === 0 || c.retries >= 5)) ||
      (c.phase === "scan" && c.retries !== 0) ||
      c.failures.length > c.visited ||
      (c.visited === 0 && c.cursor !== null) ||
      new Set(c.failures.map(sourceFailureId)).size !== c.failures.length ||
      c.failures.some((f) => isEventSourceScope(value.scope) !==
        ("workItemId" in f))) {
    throw invalidWork();
  }
  for (const key of [...c.failures.map(sourceFailureId),
    ...(c.cursor === null ? [] : [c.cursor])]) {
    if (isEventSourceScope(value.scope)) {
      if (!/^work:(assistance|delivery):[a-f0-9]{64}$/.test(key)) {
        throw invalidWork();
      }
    } else {
      const [expiry] = parseReadinessTargetKey(key, value.scope);
      if (expiry <= value.source.occurredAt) throw invalidWork();
    }
  }
  return value;
}

export function readSourceWorkRecords(runValue: unknown, itemValue: unknown,
  workItemId: string, now: number) {
  const a = validateOperationRun(runValue);
  const b = validateOperationWorkItem(itemValue);
  if (!a.ok || !b.ok) throw invalidWork();
  const run = a.value;
  const item = b.value;
  const payload = parseSourceWork(item.normalizedPayload, now);
  const ids = sourceWorkIds(payload);
  const p = sourceWorkProjection(payload);
  const hash = operationContentHash(sourceWorkBasis(payload));
  if (workItemId !== ids.workItemId || item.workItemId !== workItemId ||
      item.runId !== ids.runId || run.runId !== ids.runId ||
      item.workflowId !== ASSISTANCE_WORKFLOW ||
      run.workflowId !== ASSISTANCE_WORKFLOW ||
      item.entityKind !== "source_signal" ||
      item.externalKey !== payload.signalId ||
      item.candidateHash !== hash || run.inputHash !== hash ||
      run.mode !== "autonomous" || run.rulesetVersion !== SOURCE_WORK_RUNTIME ||
      run.policyVersion !== ASSISTANCE_POLICY_VERSION ||
      operationContentHash(run.scope) !== operationContentHash(payload.scope) ||
      operationContentHash(run.metadata) !==
        operationContentHash({runtime: SOURCE_WORK_RUNTIME}) ||
      item.revision !== run.revision ||
      run.checkpoint.lastSequence !== item.revision ||
      run.checkpoint.cursor !== payload.checkpoint.cursor ||
      item.attemptCount !== item.revision ||
      item.createdAt !== run.createdAt || item.updatedAt !== run.updatedAt ||
      run.startedAt !== run.createdAt || run.failure !== null ||
      run.finishedAt !== (p.lifecycleStatus === "terminal" ?
        item.updatedAt : null) ||
      Date.parse(item.createdAt) > Date.parse(item.updatedAt) ||
      Date.parse(item.updatedAt) > now ||
      Date.parse(item.createdAt) < payload.source.occurredAt ||
      item.staleAt !== null ||
      item.expiresAt !== new Date(payload.expiresAt).toISOString() ||
      item.primaryStage !== p.primaryStage ||
      item.lifecycleStatus !== p.lifecycleStatus ||
      item.outcome !== p.outcome ||
      operationContentHash(item.taskFlags) !==
        operationContentHash(p.taskFlags) ||
      operationContentHash(item.blockerCodes) !==
        operationContentHash(p.blockerCodes) ||
      run.status !== (p.lifecycleStatus === "terminal" ? "completed" :
        p.primaryStage === "host_review" ? "paused" : "running") ||
      operationContentHash(run.counters) !== operationContentHash({
        discovered: 1, processed: Number(item.revision > 0),
        modelCalls: 0, modelTokens: 0, costMicros: 0, published: 0,
        failed: payload.checkpoint.failures.length,
        escalated: Number(p.primaryStage === "host_review")}) ||
      operationContentHash(run.budgets) !== operationContentHash({
        maxWorkItems: 1, maxModelCalls: 0, maxModelTokens: 0,
        maxCostMicros: 0, deadlineAt: null})) throw invalidWork();
  return {run, item, payload};
}

export function newSourceWorkRecords(input: SourceWorkInput, now: number) {
  const ids = sourceWorkIds(input);
  const payload = parseSourceWork({schemaVersion: 1, kind: "liveSourceWake",
    signalId: ids.signalId, ...input,
    expiresAt: input.source.occurredAt + SOURCE_WORK_LIFETIME,
    checkpoint: {phase: "scan", cursor: null, visited: 0,
      dueAt: Math.min(now, input.source.occurredAt + SOURCE_WORK_LIFETIME),
      failures: [], retries: 0}}, now);
  const at = new Date(now).toISOString();
  const hash = operationContentHash(sourceWorkBasis(payload));
  const p = sourceWorkProjection(payload);
  const run: OperationRun = {schemaVersion: 1, runId: ids.runId,
    workflowId: ASSISTANCE_WORKFLOW, revision: 0, mode: "autonomous",
    status: "running", scope: {...input.scope},
    rulesetVersion: SOURCE_WORK_RUNTIME,
    policyVersion: ASSISTANCE_POLICY_VERSION, inputHash: hash,
    budgets: {maxWorkItems: 1, maxModelCalls: 0, maxModelTokens: 0,
      maxCostMicros: 0, deadlineAt: null},
    counters: {discovered: 1, processed: 0, modelCalls: 0, modelTokens: 0,
      costMicros: 0, escalated: 0, published: 0, failed: 0},
    checkpoint: {lastSequence: 0, cursor: null}, createdAt: at, updatedAt: at,
    startedAt: at, finishedAt: null, failure: null,
    metadata: {runtime: SOURCE_WORK_RUNTIME}};
  const item: OperationWorkItem = {schemaVersion: 1,
    workItemId: ids.workItemId, runId: ids.runId,
    workflowId: ASSISTANCE_WORKFLOW, entityKind: "source_signal",
    externalKey: ids.signalId, revision: 0, candidateHash: hash, ...p,
    warningCodes: [], priority: 0, attemptCount: 0,
    evidenceRefs: [], fieldProvenance: [], normalizedPayload: {...payload},
    decisionId: null, publicationPlanId: null,
    createdAt: at, updatedAt: at, staleAt: null,
    expiresAt: new Date(payload.expiresAt).toISOString()};
  return readSourceWorkRecords(run, item, ids.workItemId, now);
}
