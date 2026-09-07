import {operationContentHash} from "../../operations/durableActions";
import type {OperationRun, OperationWorkItem} from "../../operations/models";
import {validateOperationRun, validateOperationWorkItem} from
  "../../operations/validation";
import type {EventAssistanceDeliveryWork as DeliveryWork} from
  "../../shared/generated/eventAssistanceDeliveryWork";
import {validateEventAssistanceDeliveryWork} from
  "../../shared/generated/validators/eventAssistanceDeliveryWork";
import {guestIdentity, threadIdentity} from "./guestRecords";
import {ASSISTANCE_WORKFLOW, invalidWork} from "./liveWorkRecords";
import {ASSISTANCE_POLICY_VERSION} from "./policySettings";
import {MessageRecord, parseMessageRecord} from "./messageOutbox";

export type {DeliveryWork};
export type DeliveryCheckpoint = DeliveryWork["checkpoint"];
export const DELIVERY_WORK_RUNTIME = "event-assistance-delivery/v1";

export const deliveryReasonCode = (reason: string) =>
  reason.replace(/[A-Z]/g, (letter) => "_" + letter.toLowerCase());

export function deliveryWorkIds(messageId: string) {
  if (!/^outbox:[a-f0-9]{64}$/.test(messageId)) throw invalidWork();
  const key = operationContentHash(messageId);
  return {runId: "run:delivery:" + key, workItemId: "work:delivery:" + key};
}

export function hasAutomaticDelivery(message: MessageRecord) {
  return message.intent.context.mode === "live" &&
    message.intent.kind === "joiningUpdate" &&
    !!message.intent.automation?.runtimeBinding;
}

export function deliveryWorkBasis(payload: DeliveryWork) {
  const {checkpoint, ...basis} = payload;
  void checkpoint;
  return basis;
}

export function deliveryWorkProjection(payload: DeliveryWork) {
  const c = payload.checkpoint;
  const terminal = c.phase === "complete";
  const review = c.phase === "review";
  return {primaryStage: terminal ? "finished" : review ? "host_review" :
    c.phase === "receipt" ? "awaiting_receipt" : "delivery",
  lifecycleStatus: terminal ? "terminal" as const : "waiting" as const,
  outcome: terminal ? deliveryReasonCode(c.reason!) : null,
  taskFlags: review ? ["human_review_required"] : [],
  blockerCodes: review ? [deliveryReasonCode(c.reason!)] : []};
}

export function parseDeliveryWork(value: unknown, now: number): DeliveryWork {
  if (!validateEventAssistanceDeliveryWork(value)) throw invalidWork();
  guestIdentity(value.scope.context, value.scope.attendeeId);
  deliveryWorkIds(value.messageId);
  const c = value.checkpoint;
  if (!Number.isSafeInteger(now) || now < value.createdAt ||
      value.expiresAt <= value.createdAt ||
      (c.phase === "complete") !== (c.dueAt === null) ||
      (c.phase === "queued") !== (c.reason === null) ||
      (c.phase === "queued" && (c.evaluations !== 0 || c.failures !== 0)) ||
      (c.dueAt !== null && (c.dueAt < value.createdAt ||
        c.dueAt > value.expiresAt)) ||
      (c.phase === "review" && c.dueAt !== value.expiresAt) ||
      (c.phase === "receipt" && c.reason !== "providerPending")) {
    throw invalidWork();
  }
  return value;
}

export function assertDeliveryMessage(payload: DeliveryWork,
  value: unknown): MessageRecord {
  const message = parseMessageRecord(value);
  const i = message.intent;
  if (!hasAutomaticDelivery(message) ||
      message.messageId !== payload.messageId ||
      operationContentHash(i) !== payload.intentHash ||
      threadIdentity(i) !== payload.threadId ||
      operationContentHash({context: i.context, attendeeId: i.attendeeId,
        episodeId: i.episodeId}) !== operationContentHash(payload.scope) ||
      message.createdAt !== payload.createdAt ||
      i.expiresAt !== payload.expiresAt ||
      message.revision < payload.checkpoint.messageRevision ||
      (message.revision === payload.checkpoint.messageRevision &&
        operationContentHash(message) !== payload.checkpoint.messageHash)) {
    throw invalidWork();
  }
  return message;
}

function buildRecords(payload: DeliveryWork, createdAt: string,
  updatedAt: string, revision: number) {
  const ids = deliveryWorkIds(payload.messageId);
  const p = deliveryWorkProjection(payload);
  const terminal = p.lifecycleStatus === "terminal";
  const review = payload.checkpoint.phase === "review";
  const hash = operationContentHash(deliveryWorkBasis(payload));
  const run: OperationRun = {schemaVersion: 1, runId: ids.runId,
    workflowId: ASSISTANCE_WORKFLOW, revision, mode: "autonomous",
    status: terminal ? "completed" : "running",
    scope: {...payload.scope}, rulesetVersion: DELIVERY_WORK_RUNTIME,
    policyVersion: ASSISTANCE_POLICY_VERSION, inputHash: hash,
    budgets: {maxWorkItems: 1, maxModelCalls: 0, maxModelTokens: 0,
      maxCostMicros: 0, deadlineAt: null},
    counters: {discovered: 1, processed: Number(revision > 0),
      modelCalls: 0, modelTokens: 0, costMicros: 0, published: 0,
      failed: payload.checkpoint.failures, escalated: Number(review)},
    checkpoint: {lastSequence: revision, cursor: null},
    createdAt, updatedAt, startedAt: createdAt,
    finishedAt: terminal ? updatedAt : null, failure: null,
    metadata: {runtime: DELIVERY_WORK_RUNTIME}};
  const item: OperationWorkItem = {schemaVersion: 1, ...ids,
    workflowId: ASSISTANCE_WORKFLOW, entityKind: "message_delivery",
    externalKey: payload.messageId, revision, candidateHash: hash, ...p,
    warningCodes: [], priority: 0, attemptCount: revision, evidenceRefs: [],
    fieldProvenance: [], normalizedPayload: {...payload}, decisionId: null,
    publicationPlanId: null, createdAt, updatedAt, staleAt: null,
    expiresAt: new Date(payload.expiresAt).toISOString()};
  return {run, item, payload};
}

export function readDeliveryWorkRecords(runValue: unknown, itemValue: unknown,
  workItemId: string, now: number) {
  const a = validateOperationRun(runValue);
  const b = validateOperationWorkItem(itemValue);
  if (!a.ok || !b.ok) throw invalidWork();
  const payload = parseDeliveryWork(b.value.normalizedPayload, now);
  const expected = buildRecords(payload, a.value.createdAt, a.value.updatedAt,
    a.value.revision);
  if (expected.item.workItemId !== workItemId ||
      Date.parse(a.value.createdAt) < payload.createdAt ||
      Date.parse(a.value.updatedAt) < Date.parse(a.value.createdAt) ||
      Date.parse(a.value.updatedAt) > now ||
      operationContentHash({run: a.value, item: b.value}) !==
        operationContentHash({run: expected.run, item: expected.item})) {
    throw invalidWork();
  }
  return expected;
}

export function newDeliveryWorkRecords(message: MessageRecord, now: number) {
  if (!hasAutomaticDelivery(message)) throw invalidWork();
  const i = message.intent;
  const payload = parseDeliveryWork({schemaVersion: 1,
    kind: "liveMessageDelivery", messageId: message.messageId,
    intentHash: operationContentHash(i), threadId: threadIdentity(i),
    scope: {context: i.context, attendeeId: i.attendeeId,
      episodeId: i.episodeId},
    createdAt: message.createdAt, expiresAt: i.expiresAt,
    checkpoint: {phase: "queued", reason: null,
      dueAt: Math.min(now, i.expiresAt), messageRevision: message.revision,
      messageHash: operationContentHash(message), failures: 0, evaluations: 0}},
  now);
  const at = new Date(now).toISOString();
  return buildRecords(payload, at, at, 0);
}

export function advanceDeliveryWorkRecords(
  current: ReturnType<typeof readDeliveryWorkRecords>,
  checkpoint: DeliveryCheckpoint, now: number) {
  const payload = parseDeliveryWork({...current.payload, checkpoint}, now);
  const next = buildRecords(payload, current.run.createdAt,
    new Date(now).toISOString(), current.item.revision + 1);
  return readDeliveryWorkRecords(next.run, next.item,
    next.item.workItemId, now);
}
