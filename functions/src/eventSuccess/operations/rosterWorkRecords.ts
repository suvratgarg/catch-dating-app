import {operationContentHash} from "../../operations/durableActions";
import type {OperationRun, OperationWorkItem} from "../../operations/models";
import {validateOperationRun, validateOperationWorkItem} from
  "../../operations/validation";
import type {EventAssistanceRosterWork as RosterWork} from
  "../../shared/generated/eventAssistanceRosterWork";
import {validateEventAssistanceRosterWork} from
  "../../shared/generated/validators/eventAssistanceRosterWork";
import {guestIdentity, requireDocumentId} from "./guestRecords";
import {ASSISTANCE_POLICY_VERSION} from "./policySettings";
import {runtimeConfigId} from "./runtimeConfigRecords";
import {ASSISTANCE_WORKFLOW, invalidWork} from "./liveWorkRecords";

export type {RosterWork};
export const ROSTER_WORK_RUNTIME = "event-assistance-roster/v1";
export const ROSTER_WORK_LIFETIME = 86_400_000;
export type RosterWorkInput = Pick<RosterWork,
  "scope" | "source" | "runtimeBinding">;

export function rosterWorkIds(input: RosterWorkInput) {
  guestIdentity(input.scope.context, input.scope.attendeeId ?? "scope");
  requireDocumentId(input.source.eventId);
  requireDocumentId(input.source.documentId);
  const key = operationContentHash({scope: input.scope, source: input.source,
    runtimeBinding: input.runtimeBinding});
  return {signalId: "signal:" + key,
    runId: "run:roster:" + key, workItemId: "work:roster:" + key};
}

export function rosterWorkProjection(payload: RosterWork) {
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

export function rosterWorkBasis(payload: RosterWork) {
  return {schemaVersion: payload.schemaVersion, kind: payload.kind,
    signalId: payload.signalId, scope: payload.scope, source: payload.source,
    runtimeBinding: payload.runtimeBinding,
    expiresAt: payload.expiresAt};
}

export function parseRosterWork(value: unknown, now: number): RosterWork {
  if (!validateEventAssistanceRosterWork(value)) throw invalidWork();
  const ids = rosterWorkIds(value);
  const c = value.checkpoint;
  if (!Number.isSafeInteger(now) || now < value.source.occurredAt ||
      value.runtimeBinding.runtimeId !== runtimeConfigId(value.scope.context) ||
      (value.source.collection === "eventAssistanceRuntimeConfigs" ?
        value.scope.attendeeId !== null ||
          value.source.documentId !== value.runtimeBinding.runtimeId :
        value.scope.attendeeId === null ||
          value.source.documentId !== (value.source.collection ===
            "eventAttendees" ? value.scope.attendeeId :
            guestIdentity(value.scope.context, value.scope.attendeeId))) ||
      value.signalId !== ids.signalId || value.expiresAt !==
        value.source.occurredAt + ROSTER_WORK_LIFETIME ||
      (c.dueAt !== null && (c.dueAt > value.expiresAt ||
        c.dueAt < value.source.occurredAt)) ||
      (["complete", "review", "expired", "stopped"].includes(c.phase)) !==
        (c.dueAt === null) ||
      (c.phase === "stopped") !== (c.stopReason !== null) ||
      (c.phase === "complete" && c.failures.length !== 0) ||
      (c.phase === "retry" && (c.failures.length === 0 || c.retries >= 5)) ||
      (c.phase === "scan" && c.retries !== 0) ||
      c.failures.length > c.visited ||
      (c.visited === 0 && c.cursor !== null) ||
      new Set(c.failures.map((f) => f.attendeeId)).size !== c.failures.length ||
      c.failures.some((f) => !/^[A-Za-z0-9][A-Za-z0-9._:-]{0,159}$/.test(
        f.attendeeId)) ||
      (c.cursor !== null &&
        !/^[A-Za-z0-9][A-Za-z0-9._:-]{0,159}$/.test(c.cursor))) {
    throw invalidWork();
  }
  return value;
}

export function readRosterWorkRecords(runValue: unknown, itemValue: unknown,
  workItemId: string, now: number) {
  const a = validateOperationRun(runValue);
  const b = validateOperationWorkItem(itemValue);
  if (!a.ok || !b.ok) throw invalidWork();
  const run = a.value;
  const item = b.value;
  const payload = parseRosterWork(item.normalizedPayload, now);
  const ids = rosterWorkIds(payload);
  const p = rosterWorkProjection(payload);
  const hash = operationContentHash(rosterWorkBasis(payload));
  if (workItemId !== ids.workItemId || item.workItemId !== workItemId ||
      item.runId !== ids.runId || run.runId !== ids.runId ||
      item.workflowId !== ASSISTANCE_WORKFLOW ||
      run.workflowId !== ASSISTANCE_WORKFLOW ||
      item.entityKind !== "runtime_roster" ||
      item.externalKey !== payload.signalId ||
      item.candidateHash !== hash || run.inputHash !== hash ||
      run.mode !== "autonomous" || run.rulesetVersion !== ROSTER_WORK_RUNTIME ||
      run.policyVersion !== ASSISTANCE_POLICY_VERSION ||
      operationContentHash(run.scope) !== operationContentHash(payload.scope) ||
      operationContentHash(run.metadata) !==
        operationContentHash({runtime: ROSTER_WORK_RUNTIME}) ||
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

export function newRosterWorkRecords(input: RosterWorkInput, now: number) {
  const ids = rosterWorkIds(input);
  const payload = parseRosterWork({schemaVersion: 1,
    kind: "liveRosterEnrollment",
    signalId: ids.signalId, ...input,
    expiresAt: input.source.occurredAt + ROSTER_WORK_LIFETIME,
    checkpoint: {phase: "scan", cursor: null, visited: 0,
      dueAt: Math.min(now, input.source.occurredAt + ROSTER_WORK_LIFETIME),
      failures: [], retries: 0, stopReason: null}}, now);
  const at = new Date(now).toISOString();
  const hash = operationContentHash(rosterWorkBasis(payload));
  const p = rosterWorkProjection(payload);
  const run: OperationRun = {schemaVersion: 1, runId: ids.runId,
    workflowId: ASSISTANCE_WORKFLOW, revision: 0, mode: "autonomous",
    status: "running", scope: {...input.scope},
    rulesetVersion: ROSTER_WORK_RUNTIME,
    policyVersion: ASSISTANCE_POLICY_VERSION, inputHash: hash,
    budgets: {maxWorkItems: 1, maxModelCalls: 0, maxModelTokens: 0,
      maxCostMicros: 0, deadlineAt: null},
    counters: {discovered: 1, processed: 0, modelCalls: 0, modelTokens: 0,
      costMicros: 0, escalated: 0, published: 0, failed: 0},
    checkpoint: {lastSequence: 0, cursor: null}, createdAt: at, updatedAt: at,
    startedAt: at, finishedAt: null, failure: null,
    metadata: {runtime: ROSTER_WORK_RUNTIME}};
  const item: OperationWorkItem = {schemaVersion: 1,
    workItemId: ids.workItemId, runId: ids.runId,
    workflowId: ASSISTANCE_WORKFLOW, entityKind: "runtime_roster",
    externalKey: ids.signalId, revision: 0, candidateHash: hash, ...p,
    warningCodes: [], priority: 0, attemptCount: 0,
    evidenceRefs: [], fieldProvenance: [], normalizedPayload: {...payload},
    decisionId: null, publicationPlanId: null,
    createdAt: at, updatedAt: at, staleAt: null,
    expiresAt: new Date(payload.expiresAt).toISOString()};
  return readRosterWorkRecords(run, item, ids.workItemId, now);
}
