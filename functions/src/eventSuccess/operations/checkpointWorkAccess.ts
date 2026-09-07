import {randomUUID} from "node:crypto";
import type {Firestore, Transaction} from "firebase-admin/firestore";
import {operationCollections} from "../../operations/collections";
import {operationActionId, operationContentHash} from
  "../../operations/durableActions";
import {operationResourceLeaseId} from
  "../../operations/firestoreLeaseRepository";
import type {FirestoreOperationsRepository} from
  "../../operations/firestoreRepository";
import {validateOperationActionReceipt} from "../../operations/validation";
import {validateEventAssistanceCheckpointReceiptDocument} from
  "../../shared/generated/validators/eventAssistanceCheckpointReceiptDocument";
import {CHECKPOINT_RECEIPTS, checkpointIdentity, Scope} from
  "./checkpointRecords";
import {CHECKPOINT_WORK_RUNTIME, CheckpointWorkRecords,
  checkpointWorkIds, readCheckpointWorkRecords} from "./checkpointWorkRecords";
import {invalidWork} from "./liveWorkRecords";
import {errorCode} from "./liveWorkRunner";

/** Full domain evidence and the fenced Operations receipt share one commit. */
export async function readCheckpointAssignmentReceipt(db: Firestore,
  tx: Transaction, id: string, records: CheckpointWorkRecords, now: number) {
  const {run, item, payload} = records;
  const actionId = operationActionId(run.runId, item.workItemId, id);
  const [saved, action] = await tx.getAll(
    db.collection(CHECKPOINT_RECEIPTS).doc(id),
    db.collection(operationCollections.actionReceipts).doc(actionId));
  if (!saved.exists && !action.exists) return null;
  const r = saved.data();
  const parsed = validateOperationActionReceipt(action.data());
  if (!validateEventAssistanceCheckpointReceiptDocument(r) ||
      !("assignment" in r) || !parsed.ok) throw invalidWork();
  const a = r.assignment;
  const receipt = parsed.value;
  const at = new Date(a.assignedAt).toISOString();
  if (r.receiptId !== id || a.receiptId !== id ||
      operationContentHash(r.scope) !== operationContentHash(payload.scope) ||
      r.rosterHash !== payload.rosterHash ||
      a.assignedAt < payload.requestedAt || a.assignedAt > now ||
      a.assignedAt > Date.parse(item.updatedAt) ||
      a.reason !== a.reason.trim() ||
      a.previousResponsibleOperatorId === a.responsibleOperatorId ||
      a.revision > (payload.reassignment?.revision ?? 0) ||
      a.revision > r.workItemRevision || r.workItemRevision > item.revision ||
      a.revision === 1 && a.previousResponsibleOperatorId !==
        payload.request.responsibleOperatorId ||
      a.revision === payload.reassignment?.revision &&
        operationContentHash(a) !==
          operationContentHash(payload.reassignment) ||
      receipt.actionId !== actionId || receipt.runId !== run.runId ||
      receipt.workItemId !== item.workItemId ||
      receipt.idempotencyKey !== id || receipt.inputHash !== r.requestHash ||
      receipt.operation !== "checkpoint_report_reassign" ||
      receipt.rulesetVersion !== CHECKPOINT_WORK_RUNTIME ||
      receipt.actor.actorType !== "human" ||
      receipt.actor.actorId !== a.assignedBy ||
      receipt.status !== "succeeded" || receipt.failure !== null ||
      receipt.toRevision !== r.workItemRevision ||
      receipt.fromRevision + 1 !== receipt.toRevision ||
      receipt.sequence !== receipt.toRevision ||
      receipt.occurredAt !== at || receipt.completedAt !== at ||
      receipt.outputHash === null || receipt.toRevision === item.revision &&
        receipt.outputHash !== operationContentHash(item)) throw invalidWork();
  return r;
}

/** Missing legacy work is distinct from malformed or partially missing work. */
export async function readCheckpointWorkSnapshot(db: Firestore, tx: Transaction,
  scope: Scope, clock: () => number): Promise<CheckpointWorkRecords | null> {
  const ids = checkpointWorkIds(checkpointIdentity(scope));
  const [run, item] = await tx.getAll(
    db.collection(operationCollections.runs).doc(ids.runId),
    db.collection(operationCollections.workItems).doc(ids.workItemId));
  if (!run.exists && !item.exists) return null;
  const now = clock();
  const records = readCheckpointWorkRecords(run.data(), item.data(),
    ids.workItemId, now);
  if (records.payload.reassignment &&
      !await readCheckpointAssignmentReceipt(db, tx,
        records.payload.reassignment.receiptId, records, clock())) {
    throw invalidWork();
  }
  return records;
}

/** Manual assignment and background evaluation fence the same work item. */
export async function acquireCheckpointWorkLease(
  operations: FirestoreOperationsRepository, workItemId: string,
  clock: () => number) {
  const now = clock();
  try {
    return await operations.acquireLease({
      leaseId: operationResourceLeaseId("work_item", workItemId),
      resourceId: workItemId, resourceType: "work_item",
      ownerId: "checkpoint-worker:" + randomUUID(),
      idempotencyKey: randomUUID(), acquiredAt: new Date(now).toISOString(),
      expiresAt: new Date(now + 60_000).toISOString()});
  } catch (error) {
    if (errorCode(error) === "lease_conflict") return null;
    throw error;
  }
}
