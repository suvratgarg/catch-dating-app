import {operationContentHash} from "../../operations/durableActions";
import type {OperationRun, OperationWorkItem} from "../../operations/models";
import {validateOperationRun, validateOperationWorkItem} from
  "../../operations/validation";
import type {EventAssistanceOperationalNoticeFanout as Fanout} from
  "../../shared/generated/eventAssistanceOperationalNoticeFanout";
import {validateEventAssistanceOperationalNoticeFanout} from
  "../../shared/generated/validators/eventAssistanceOperationalNoticeFanout";
import {guestIdentity, requireDocumentId} from "./guestRecords";
import {ASSISTANCE_POLICY_VERSION} from "./policySettings";
import {ASSISTANCE_WORKFLOW, invalidWork} from "./liveWorkRecords";

export type {Fanout};
export type OperationalNoticeFanoutInput = Pick<Fanout,
  "context" | "source" | "policyBinding">;
export const OPERATIONAL_NOTICE_FANOUT_RUNTIME =
  "event-assistance-operational-notice-fanout/v1";

export function operationalNoticeFanoutIds(
  input: OperationalNoticeFanoutInput
) {
  guestIdentity(input.context, "scope");
  requireDocumentId(input.source.sourceId);
  requireDocumentId(input.policyBinding.settingId);
  const key = operationContentHash({context: input.context,
    source: input.source, policyBinding: input.policyBinding});
  return {signalId: "signal:" + key,
    runId: "run:notice:" + key, workItemId: "work:notice:" + key};
}

export function operationalNoticeFanoutProjection(payload: Fanout) {
  const {phase, failures, visited} = payload.checkpoint;
  const terminal = phase === "complete" || phase === "expired" ||
    phase === "stopped";
  const review = phase === "review";
  return {primaryStage: terminal ? "finished" : review ? "host_review" :
    phase === "retry" ? "retrying" : "fanout",
  lifecycleStatus: terminal ? "terminal" as const : "waiting" as const,
  outcome: terminal ? phase : null,
  taskFlags: review ? ["human_review_required"] : [],
  blockerCodes: review ? [visited >= 10_000 ? "target_limit" :
    failures.length >= 100 ? "failure_limit" : "target_unavailable"] : []};
}

export function operationalNoticeFanoutBasis(payload: Fanout) {
  return {schemaVersion: payload.schemaVersion, kind: payload.kind,
    signalId: payload.signalId, context: payload.context,
    source: payload.source, policyBinding: payload.policyBinding,
    expiresAt: payload.expiresAt};
}

export function parseOperationalNoticeFanout(value: unknown,
  now: number): Fanout {
  if (!validateEventAssistanceOperationalNoticeFanout(value)) {
    throw invalidWork();
  }
  const ids = operationalNoticeFanoutIds(value);
  const c = value.checkpoint;
  const workflowKind = value.source.kind === "planChange" ?
    "planChangeCommunication" : "postEventFollowUp";
  const active = c.phase === "scan" || c.phase === "retry";
  if (!Number.isSafeInteger(now) || now < 0 ||
      value.signalId !== ids.signalId ||
      value.source.occurredAt >= value.source.validUntil ||
      value.expiresAt !== value.source.validUntil ||
      value.policyBinding.workflowKind !== workflowKind ||
      value.policyBinding.groupId !== "event:whole" ||
      (c.dueAt !== null && (c.dueAt < value.source.occurredAt ||
        c.dueAt > value.expiresAt)) || active !== (c.dueAt !== null) ||
      (c.phase === "stopped") !== (c.stopReason !== null) ||
      (c.phase === "complete" && c.failures.length !== 0) ||
      (c.phase === "retry" && (c.failures.length === 0 || c.retries >= 5)) ||
      (c.phase === "scan" && c.retries !== 0) ||
      c.failures.length > c.visited ||
      c.published + c.skipped + c.failures.length > c.visited ||
      (c.visited === 0 && c.cursor !== null) ||
      new Set(c.failures.map((failure) => failure.attendeeId)).size !==
        c.failures.length ||
      c.failures.some((failure) => !validId(failure.attendeeId)) ||
      (c.cursor !== null && !validId(c.cursor))) throw invalidWork();
  return value;
}

export function readOperationalNoticeFanoutRecords(runValue: unknown,
  itemValue: unknown, workItemId: string, now: number) {
  const a = validateOperationRun(runValue);
  const b = validateOperationWorkItem(itemValue);
  if (!a.ok || !b.ok) throw invalidWork();
  const run = a.value;
  const item = b.value;
  const payload = parseOperationalNoticeFanout(item.normalizedPayload, now);
  const ids = operationalNoticeFanoutIds(payload);
  const p = operationalNoticeFanoutProjection(payload);
  const hash = operationContentHash(operationalNoticeFanoutBasis(payload));
  if (workItemId !== ids.workItemId || item.workItemId !== workItemId ||
      item.runId !== ids.runId || run.runId !== ids.runId ||
      item.workflowId !== ASSISTANCE_WORKFLOW ||
      run.workflowId !== ASSISTANCE_WORKFLOW ||
      item.entityKind !== "notice_fanout" ||
      item.externalKey !== payload.signalId ||
      item.candidateHash !== hash || run.inputHash !== hash ||
      run.mode !== "autonomous" ||
      run.rulesetVersion !== OPERATIONAL_NOTICE_FANOUT_RUNTIME ||
      run.policyVersion !== ASSISTANCE_POLICY_VERSION ||
      operationContentHash(run.scope) !== operationContentHash({
        context: payload.context, source: payload.source}) ||
      operationContentHash(run.metadata) !== operationContentHash({
        runtime: OPERATIONAL_NOTICE_FANOUT_RUNTIME}) ||
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
      Date.parse(item.createdAt) >= payload.expiresAt ||
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
        modelCalls: 0, modelTokens: 0, costMicros: 0,
        published: payload.checkpoint.published,
        failed: payload.checkpoint.failures.length,
        escalated: Number(p.primaryStage === "host_review")}) ||
      operationContentHash(run.budgets) !== operationContentHash({
        maxWorkItems: 1, maxModelCalls: 0, maxModelTokens: 0,
        maxCostMicros: 0, deadlineAt: null})) throw invalidWork();
  return {run, item, payload};
}

export function newOperationalNoticeFanoutRecords(
  input: OperationalNoticeFanoutInput, now: number
) {
  if (now >= input.source.validUntil) throw invalidWork();
  const ids = operationalNoticeFanoutIds(input);
  const payload = parseOperationalNoticeFanout({schemaVersion: 1,
    kind: "operationalNoticeFanout", signalId: ids.signalId, ...input,
    expiresAt: input.source.validUntil,
    checkpoint: {phase: "scan", cursor: null, visited: 0, published: 0,
      skipped: 0, dueAt: Math.max(now, input.source.occurredAt), failures: [],
      retries: 0, stopReason: null}}, now);
  const at = new Date(now).toISOString();
  const hash = operationContentHash(operationalNoticeFanoutBasis(payload));
  const p = operationalNoticeFanoutProjection(payload);
  const run: OperationRun = {schemaVersion: 1, runId: ids.runId,
    workflowId: ASSISTANCE_WORKFLOW, revision: 0, mode: "autonomous",
    status: "running", scope: {context: input.context, source: input.source},
    rulesetVersion: OPERATIONAL_NOTICE_FANOUT_RUNTIME,
    policyVersion: ASSISTANCE_POLICY_VERSION, inputHash: hash,
    budgets: {maxWorkItems: 1, maxModelCalls: 0, maxModelTokens: 0,
      maxCostMicros: 0, deadlineAt: null},
    counters: {discovered: 1, processed: 0, modelCalls: 0, modelTokens: 0,
      costMicros: 0, escalated: 0, published: 0, failed: 0},
    checkpoint: {lastSequence: 0, cursor: null}, createdAt: at, updatedAt: at,
    startedAt: at, finishedAt: null, failure: null,
    metadata: {runtime: OPERATIONAL_NOTICE_FANOUT_RUNTIME}};
  const item: OperationWorkItem = {schemaVersion: 1,
    workItemId: ids.workItemId, runId: ids.runId,
    workflowId: ASSISTANCE_WORKFLOW, entityKind: "notice_fanout",
    externalKey: ids.signalId, revision: 0, candidateHash: hash, ...p,
    warningCodes: [], priority: 0, attemptCount: 0,
    evidenceRefs: [], fieldProvenance: [], normalizedPayload: {...payload},
    decisionId: null, publicationPlanId: null,
    createdAt: at, updatedAt: at, staleAt: null,
    expiresAt: new Date(payload.expiresAt).toISOString()};
  return readOperationalNoticeFanoutRecords(run, item, ids.workItemId, now);
}

function validId(value: string) {
  return /^[A-Za-z0-9][A-Za-z0-9._:-]{0,159}$/.test(value);
}
