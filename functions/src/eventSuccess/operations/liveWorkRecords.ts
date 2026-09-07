import {operationContentHash} from "../../operations/durableActions";
import type {OperationRun, OperationWorkItem} from "../../operations/models";
import {validateOperationRun, validateOperationWorkItem} from
  "../../operations/validation";
import type {EventAssistanceLiveWork as LiveWork} from
  "../../shared/generated/eventAssistanceLiveWork";
import {validateEventAssistanceLiveWork} from
  "../../shared/generated/validators/eventAssistanceLiveWork";
import {guestIdentity, requireDocumentId} from "./guestRecords";
import {ASSISTANCE_POLICY_VERSION} from "./policySettings";

export type {LiveWork};
export type Observation = NonNullable<LiveWork["checkpoint"]["observation"]>;
export const LIVE_WORK_RUNTIME = "event-assistance-live/v1";
export const ASSISTANCE_WORKFLOW = "event-assistance";

export function liveWorkIds(scope: LiveWork["scope"]) {
  guestIdentity(scope.context, scope.attendeeId);
  requireDocumentId(scope.episodeId);
  const key = operationContentHash(["lateJoin", scope]);
  return {runId: "run:assistance:" + key, workItemId: "work:assistance:" + key};
}

export function liveWorkBasis(payload: LiveWork) {
  const {checkpoint, ...basis} = payload;
  void checkpoint;
  return basis;
}

export function parseLiveWork(value: unknown, now: number): LiveWork {
  if (!validateEventAssistanceLiveWork(value)) throw invalidWork();
  liveWorkIds(value.scope);
  const c = value.checkpoint;
  if (!Number.isSafeInteger(now) || now < 0 ||
      c.evaluations > value.maxEvaluations ||
      (c.evaluatedAt !== null && c.evaluatedAt > now) ||
      (c.observation === null) !== (c.evaluatedAt === null) ||
      (c.observation === null && (c.evaluations !== 0 ||
        c.sourceHash !== null || c.publication !== null)) ||
      (c.observation !== null && c.evaluations === 0 &&
        c.observation.kind !== "workExpired") ||
      (c.observation?.kind === "decision" && c.sourceHash === null) ||
      (c.dueAt !== null && c.dueAt > value.expiresAt) ||
      new Set(value.options.routes.map((r) => r.routeId)).size !==
        value.options.routes.length) throw invalidWork();
  const projection = liveWorkProjection(c.observation);
  if ((projection.lifecycleStatus === "terminal") !== (c.dueAt === null)) {
    throw invalidWork();
  }
  return value;
}

/** Workflow vocabulary projects onto the existing Operations item contract. */
export function liveWorkProjection(observation: Observation | null) {
  const state = (primaryStage: string,
    lifecycleStatus: OperationWorkItem["lifecycleStatus"],
    reason: string, outcome: string | null = null) => ({primaryStage,
    lifecycleStatus, outcome,
    taskFlags: primaryStage === "host_review" ? ["human_review_required"] : [],
    blockerCodes: primaryStage === "host_review" ? [code(reason)] : [],
    reasonCodes: [code(reason)]});
  if (!observation) return state("evaluating", "queued", "queued");
  switch (observation.kind) {
  case "decision": {
    const d = observation.decision;
    switch (d.kind) {
    case "resolved":
    case "cancelled":
    case "expired": return state("finished", "terminal", d.reason, d.kind);
    case "wait": return state("waiting", "waiting", d.reason);
    case "hostDecision": return state("host_review", "waiting", d.reason);
    case "update": return state(d.shouldSend ? "ready" : "waiting",
      d.shouldSend ? "ready" : "waiting", "guidanceCurrent");
    default: return unhandled(d);
    }
  }
  case "sourceNotReady":
    switch (observation.reason) {
    case "eventClosed": return state("finished", "terminal", "eventClosed",
      "expired");
    case "disabled":
    case "runtimeNotLive":
    case "progressUnconfirmed":
      return state("waiting", "waiting", observation.reason);
    case "episodeMissing":
    case "guestSourceChanged":
    case "membershipMissing":
    case "membershipSourceChanged":
    case "unconfigured":
    case "settingSourceChanged":
    case "progressSourceChanged":
    case "destinationUnavailable":
      return state("host_review", "waiting", observation.reason);
    default: return unhandled(observation);
    }
  case "historyUnavailable":
    return state("host_review", "waiting", observation.reason);
  case "runtimeUnavailable":
    if (observation.reason === "paused") {
      return state("waiting", "waiting", "runtimePaused");
    }
    if (observation.reason === "expired" ||
        observation.reason === "eventClosed") {
      return state("finished", "terminal", observation.reason, "expired");
    }
    return state("host_review", "waiting", observation.reason);
  case "responseDeadlineMissing":
  case "evaluationLimit":
    return state("host_review", "waiting", observation.kind);
  case "episodeChanged":
    return state("finished", "terminal", observation.kind, "cancelled");
  case "workExpired":
    return state("finished", "terminal", observation.kind, "expired");
  default: return unhandled(observation);
  }
}

export function readLiveWorkRecords(runValue: unknown, itemValue: unknown,
  workItemId: string, now: number) {
  const runResult = validateOperationRun(runValue);
  const itemResult = validateOperationWorkItem(itemValue);
  if (!runResult.ok || !itemResult.ok) throw invalidWork();
  const run = runResult.value;
  const item = itemResult.value;
  const payload = parseLiveWork(item.normalizedPayload, now);
  const ids = liveWorkIds(payload.scope);
  const hash = operationContentHash(liveWorkBasis(payload));
  const projection = liveWorkProjection(payload.checkpoint.observation);
  if (workItemId !== ids.workItemId || item.workItemId !== workItemId ||
      run.runId !== ids.runId || item.runId !== run.runId ||
      run.workflowId !== ASSISTANCE_WORKFLOW ||
      item.workflowId !== ASSISTANCE_WORKFLOW ||
      run.mode !== "autonomous" || run.rulesetVersion !== LIVE_WORK_RUNTIME ||
      run.policyVersion !== ASSISTANCE_POLICY_VERSION ||
      operationContentHash(run.metadata) !==
        operationContentHash({runtime: LIVE_WORK_RUNTIME}) ||
      operationContentHash(run.scope) !== operationContentHash(payload.scope) ||
      run.inputHash !== hash || item.candidateHash !== hash ||
      item.entityKind !== "guest_episode" ||
      item.externalKey !== payload.scope.episodeId ||
      run.revision !== item.revision ||
      run.checkpoint.lastSequence !== item.revision ||
      run.checkpoint.cursor !== workItemId ||
      item.attemptCount !== payload.checkpoint.evaluations ||
      item.revision < item.attemptCount || item.staleAt !== null ||
      item.expiresAt !== new Date(payload.expiresAt).toISOString() ||
      item.createdAt !== run.createdAt || item.updatedAt !== run.updatedAt ||
      Date.parse(item.updatedAt) > now ||
      Date.parse(item.createdAt) >= payload.expiresAt ||
      item.primaryStage !== projection.primaryStage ||
      item.lifecycleStatus !== projection.lifecycleStatus ||
      item.outcome !== projection.outcome ||
      operationContentHash(item.taskFlags) !==
        operationContentHash(projection.taskFlags) ||
      operationContentHash(item.blockerCodes) !==
        operationContentHash(projection.blockerCodes) ||
      (item.lifecycleStatus === "terminal") !==
        (run.status === "completed") ||
      !["running", "paused", "completed"].includes(run.status) ||
      operationContentHash(run.budgets) !== operationContentHash({
        maxWorkItems: 1, maxModelCalls: 0, maxModelTokens: 0,
        maxCostMicros: 0, deadlineAt: null}) ||
      run.counters.discovered !== 1 || run.counters.modelCalls !== 0 ||
      run.counters.modelTokens !== 0 || run.counters.costMicros !== 0) {
    throw invalidWork();
  }
  return {run, item, payload};
}

export function newLiveWorkRecords(payload: LiveWork, now: number):
  {run: OperationRun; item: OperationWorkItem} {
  const ids = liveWorkIds(payload.scope);
  const at = new Date(now).toISOString();
  const hash = operationContentHash(liveWorkBasis(payload));
  const p = liveWorkProjection(null);
  const run: OperationRun = {schemaVersion: 1, runId: ids.runId,
    workflowId: ASSISTANCE_WORKFLOW, revision: 0, mode: "autonomous",
    status: "running", scope: payload.scope, rulesetVersion: LIVE_WORK_RUNTIME,
    policyVersion: ASSISTANCE_POLICY_VERSION, inputHash: hash,
    budgets: {maxWorkItems: 1, maxModelCalls: 0, maxModelTokens: 0,
      maxCostMicros: 0, deadlineAt: null},
    counters: {discovered: 1, processed: 0, modelCalls: 0, modelTokens: 0,
      costMicros: 0, escalated: 0, published: 0, failed: 0},
    checkpoint: {lastSequence: 0, cursor: ids.workItemId},
    createdAt: at, updatedAt: at, startedAt: at,
    finishedAt: null, failure: null,
    metadata: {runtime: LIVE_WORK_RUNTIME}};
  const item: OperationWorkItem = {schemaVersion: 1, ...ids,
    workflowId: ASSISTANCE_WORKFLOW, entityKind: "guest_episode",
    externalKey: payload.scope.episodeId, revision: 0, candidateHash: hash,
    primaryStage: p.primaryStage, lifecycleStatus: p.lifecycleStatus,
    outcome: null, taskFlags: [], blockerCodes: [], warningCodes: [],
    priority: 0, attemptCount: 0, evidenceRefs: [], fieldProvenance: [],
    normalizedPayload: {...payload}, decisionId: null, publicationPlanId: null,
    createdAt: at, updatedAt: at, staleAt: null,
    expiresAt: new Date(payload.expiresAt).toISOString()};
  readLiveWorkRecords(run, item, item.workItemId, now);
  return {run, item};
}

function code(value: string) {
  return value.replace(/[A-Z]/g, (letter) => "_" + letter.toLowerCase());
}
function unhandled(value: never): never {
  void value;
  throw invalidWork();
}
export function invalidWork() {
  return new Error("Invalid or inconsistent live assistance work");
}
