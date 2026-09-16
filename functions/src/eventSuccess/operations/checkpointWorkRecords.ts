import {operationContentHash} from "../../operations/durableActions";
import type {OperationRun, OperationWorkItem} from "../../operations/models";
import {validateOperationRun, validateOperationWorkItem} from
  "../../operations/validation";
import type {EventAssistanceCheckpointWork as CheckpointWork} from
  "../../shared/generated/eventAssistanceCheckpointWork";
import {validateEventAssistanceCheckpointWork} from
  "../../shared/generated/validators/eventAssistanceCheckpointWork";
import {checkpointIdentity, parseDepartureRoster, Roster} from
  "./checkpointRecords";
import {MAX_REPORT_DELAY} from "./checkpointRequest";
import {departureRosterIdentity} from "./departureRosterSource";
import {ASSISTANCE_WORKFLOW, invalidWork} from "./liveWorkRecords";
import {ASSISTANCE_POLICY_VERSION} from "./policySettings";
import {assertCloseoutChange, CloseoutChange} from "./checkpointCloseoutPolicy";

export type {CheckpointWork};
export type WorkCheckpoint = CheckpointWork["checkpoint"];
export type Reassignment = NonNullable<CheckpointWork["reassignment"]>;
export type CheckpointWorkRecords = ReturnType<
  typeof readCheckpointWorkRecords>;

export function effectiveCheckpointRequest(payload: CheckpointWork) {
  return {...payload.request, responsibleOperatorId:
    payload.reassignment?.responsibleOperatorId ??
      payload.request.responsibleOperatorId};
}
export const CHECKPOINT_WORK_RUNTIME = "event-assistance-checkpoint/v1";

export function checkpointWorkIds(reportId: string) {
  if (!/^checkpoint:[a-f0-9]{64}$/.test(reportId)) throw invalidWork();
  const key = operationContentHash(reportId);
  return {runId: "run:checkpoint:" + key, workItemId: "work:checkpoint:" + key};
}

export function checkpointWorkBasis(payload: CheckpointWork) {
  const {checkpoint, reassignment, closeout, ...basis} = payload;
  void checkpoint;
  void reassignment;
  void closeout;
  return basis;
}

/** Deadlines and expiry wake once; source-read retries are bounded. */
export function nextReportDue(payload: CheckpointWork,
  c: WorkCheckpoint): number | null {
  if (c.evaluatedAt === null) return payload.requestedAt;
  if (c.observation?.kind === "unavailable") {
    return c.failures >= 5 ? null : c.evaluatedAt +
      5000 * 2 ** (c.failures - 1);
  }
  if (!c.observation || ["complete", "closedOut"].includes(
    c.observation.request.state)) return null;
  const until = c.observation.ownerValidUntil;
  const times = [payload.request.dueAt, ...(until < Number.MAX_SAFE_INTEGER ?
    [until] : [])].filter((t) => t > c.evaluatedAt!);
  return times.length ? Math.min(...times) : null;
}

export function parseCheckpointWork(value: unknown, now: number):
  CheckpointWork {
  if (!validateEventAssistanceCheckpointWork(value)) throw invalidWork();
  checkpointWorkIds(checkpointIdentity(value.scope));
  const c = value.checkpoint;
  const change = value.reassignment;
  if (value.closeout) assertCloseoutChange(value.closeout, value);
  if (change && (change.assignedAt < value.requestedAt ||
      c.evaluatedAt === null || change.assignedAt > c.evaluatedAt ||
      change.reason !== change.reason.trim() ||
      change.responsibleOperatorId === change.previousResponsibleOperatorId ||
      change.revision === 1 && change.previousResponsibleOperatorId !==
        value.request.responsibleOperatorId)) throw invalidWork();
  if (!Number.isSafeInteger(now) || now < value.requestedAt ||
      value.rosterId !== departureRosterIdentity(value.scope.context,
        value.scope.groupId, value.scope.progressRevision) ||
      value.request.dueAt < value.requestedAt ||
      value.request.dueAt > value.requestedAt + MAX_REPORT_DELAY ||
      (c.observation === null) !== (c.evaluatedAt === null) ||
      (c.evaluatedAt !== null && (c.evaluatedAt < value.requestedAt ||
        c.evaluatedAt > now)) ||
      (c.observation?.kind === "unavailable") !== (c.failures > 0) ||
      c.dueAt !== nextReportDue(value, c)) throw invalidWork();
  if (c.observation?.kind === "observed") {
    const o = c.observation;
    if (o.request.responsibleOperatorId !==
        effectiveCheckpointRequest(value).responsibleOperatorId ||
        o.request.dueAt !== value.request.dueAt ||
        (["awaitingReport", "overdue"].includes(o.request.state) &&
          o.reportRevision !== 0) ||
        (["complete", "closedOut", "discrepancy"].includes(o.request.state) &&
          o.reportRevision === 0) ||
        (o.request.state === "closedOut" &&
          (value.closeout?.decision.kind !== "close" ||
            value.closeout.decision.report.revision !== o.reportRevision)) ||
        (o.request.state === "awaitingReport" &&
          c.evaluatedAt! >= value.request.dueAt) ||
        (o.request.state === "overdue" &&
          c.evaluatedAt! < value.request.dueAt) ||
        (!["complete", "closedOut"].includes(o.request.state) &&
          (o.request.ownerAvailability === "current") !==
          (o.ownerValidUntil >
            Math.max(c.evaluatedAt!, value.request.dueAt)))) {
      throw invalidWork();
    }
  }
  return value;
}

export function checkpointWorkProjection(payload: CheckpointWork) {
  const o = payload.checkpoint.observation;
  const complete = o?.kind === "observed" &&
    ["complete", "closedOut"].includes(o.request.state);
  const closed = o?.kind === "observed" && o.request.state === "closedOut";
  const reason = o?.kind === "unavailable" ? "facts_unavailable" :
    o?.kind === "observed" && o.request.ownerAvailability ===
      "needsReassignment" ? "reporter_unavailable" :
      o?.kind === "observed" ? o.request.state.replace(/[A-Z]/g,
        (c) => "_" + c.toLowerCase()) : "awaiting_report";
  const review = !complete && reason !== "awaiting_report";
  return {primaryStage: closed ? "report_closed_out" : complete ?
    "report_complete" : review ?
      "host_review" : "report_requested",
  lifecycleStatus: "waiting" as const, outcome: null,
  taskFlags: complete ? [] :
    [review ? "human_review_required" : "operator_action_required"],
  blockerCodes: review ? [reason] : [], priority: review ? 100 : 0};
}

function records(payload: CheckpointWork, createdAt: string, updatedAt: string,
  revision: number) {
  const ids = checkpointWorkIds(checkpointIdentity(payload.scope));
  const hash = operationContentHash(checkpointWorkBasis(payload));
  const p = checkpointWorkProjection(payload);
  const run: OperationRun = {schemaVersion: 1, runId: ids.runId,
    workflowId: ASSISTANCE_WORKFLOW, revision, mode: "autonomous",
    status: "running", scope: {...payload.scope},
    rulesetVersion: CHECKPOINT_WORK_RUNTIME,
    policyVersion: ASSISTANCE_POLICY_VERSION, inputHash: hash,
    budgets: {maxWorkItems: 1, maxModelCalls: 0, maxModelTokens: 0,
      maxCostMicros: 0, deadlineAt: null},
    counters: {discovered: 1, processed: Number(revision > 0),
      modelCalls: 0, modelTokens: 0, costMicros: 0, published: 0,
      failed: payload.checkpoint.failures,
      escalated: Number(p.primaryStage === "host_review")},
    checkpoint: {lastSequence: revision, cursor: null}, createdAt, updatedAt,
    startedAt: createdAt, finishedAt: null, failure: null,
    metadata: {runtime: CHECKPOINT_WORK_RUNTIME}};
  const item: OperationWorkItem = {schemaVersion: 1, ...ids,
    workflowId: ASSISTANCE_WORKFLOW, entityKind: "checkpoint_report",
    externalKey: checkpointIdentity(payload.scope), revision,
    candidateHash: hash, ...p, warningCodes: [], attemptCount: revision,
    evidenceRefs: [], fieldProvenance: [], normalizedPayload: {...payload},
    decisionId: null, publicationPlanId: null, createdAt, updatedAt,
    staleAt: null, expiresAt: null};
  return {run, item, payload};
}

export function readCheckpointWorkRecords(runValue: unknown, itemValue: unknown,
  workItemId: string, now: number) {
  const a = validateOperationRun(runValue);
  const b = validateOperationWorkItem(itemValue);
  if (!a.ok || !b.ok) throw invalidWork();
  const payload = parseCheckpointWork(b.value.normalizedPayload, now);
  const expected = records(payload, a.value.createdAt, a.value.updatedAt,
    a.value.revision);
  if (expected.item.workItemId !== workItemId ||
      (payload.reassignment?.revision ?? 0) > a.value.revision ||
      (payload.closeout?.revision ?? 0) > a.value.revision ||
      (a.value.revision === 0) !==
        (payload.checkpoint.evaluatedAt === null) ||
      Date.parse(a.value.updatedAt) !==
        (payload.checkpoint.evaluatedAt ?? payload.requestedAt) ||
      Date.parse(a.value.createdAt) !== payload.requestedAt ||
      Date.parse(a.value.updatedAt) < Date.parse(a.value.createdAt) ||
      Date.parse(a.value.updatedAt) > now ||
      operationContentHash({run: a.value, item: b.value}) !==
        operationContentHash({run: expected.run, item: expected.item})) {
    throw invalidWork();
  }
  return expected;
}

export function newCheckpointWorkRecords(roster: Roster) {
  const t = roster.destination;
  const checkpointId = t?.kind === "itineraryStop" ? t.stopId :
    t?.kind === "groupCheckpoint" ? t.checkpointId : null;
  if (!roster.checkpointRequest || !checkpointId) throw invalidWork();
  const scope = {context: roster.context, groupId: roster.groupId,
    checkpointId, progressRevision: roster.progressRevision};
  parseDepartureRoster(roster, scope, roster.confirmedAt);
  const payload = parseCheckpointWork({schemaVersion: 1,
    kind: "liveCheckpointReport", scope, rosterId: roster.rosterId,
    rosterHash: operationContentHash(roster), request: roster.checkpointRequest,
    requestedAt: roster.confirmedAt, checkpoint: {dueAt: roster.confirmedAt,
      evaluatedAt: null, failures: 0, observation: null}}, roster.confirmedAt);
  const at = new Date(roster.confirmedAt).toISOString();
  const next = records(payload, at, at, 0);
  return readCheckpointWorkRecords(next.run, next.item,
    next.item.workItemId, roster.confirmedAt);
}

export function advanceCheckpointWorkRecords(
  current: ReturnType<typeof readCheckpointWorkRecords>,
  observed: WorkCheckpoint["observation"], now: number,
  reassignment?: Reassignment, closeout?: CloseoutChange) {
  if (!observed || now < Date.parse(current.item.updatedAt)) {
    throw invalidWork();
  }
  if (reassignment && (reassignment.revision !==
      (current.payload.reassignment?.revision ?? 0) + 1 ||
      reassignment.previousResponsibleOperatorId !==
        effectiveCheckpointRequest(current.payload).responsibleOperatorId ||
      reassignment.assignedAt !== now)) throw invalidWork();
  if (closeout && (closeout.previousRevision !==
      (current.payload.closeout?.revision ?? 0) ||
      closeout.revision !== closeout.previousRevision + 1 ||
      closeout.changedAt !== now)) throw invalidWork();
  const checkpoint: WorkCheckpoint = {evaluatedAt: now, observation: observed,
    failures: observed.kind === "unavailable" ?
      Math.min(5, current.payload.checkpoint.failures + 1) : 0, dueAt: null};
  checkpoint.dueAt = nextReportDue(current.payload, checkpoint);
  const payload = parseCheckpointWork({...current.payload, checkpoint,
    ...(reassignment ? {reassignment} : {}),
    ...(closeout ? {closeout} : {})}, now);
  const next = records(payload, current.run.createdAt,
    new Date(now).toISOString(), current.item.revision + 1);
  return readCheckpointWorkRecords(next.run, next.item,
    next.item.workItemId, now);
}
