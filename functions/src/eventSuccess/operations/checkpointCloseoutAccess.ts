import type {Firestore, Transaction} from "firebase-admin/firestore";
import {operationCollections} from "../../operations/collections";
import {operationActionId, operationContentHash} from
  "../../operations/durableActions";
import {validateOperationActionReceipt} from "../../operations/validation";
import {validateEventAssistanceCheckpointReceiptDocument} from
  "../../shared/generated/validators/eventAssistanceCheckpointReceiptDocument";
import {CHECKPOINT_RECEIPTS} from "./checkpointRecords";
import {CHECKPOINT_WORK_RUNTIME, CheckpointWorkRecords} from
  "./checkpointWorkRecords";
import {assertCloseoutChange} from "./checkpointCloseoutPolicy";
import {invalidWork} from "./liveWorkRecords";

/** Verify the full closeout history entry and its atomic Operations receipt. */
export async function readCheckpointCloseoutReceipt(db: Firestore,
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
      !("closeout" in r) || !parsed.ok) throw invalidWork();
  const c = r.closeout;
  const receipt = parsed.value;
  assertCloseoutChange(c, payload);
  const at = new Date(c.changedAt).toISOString();
  if (r.receiptId !== id || c.receiptId !== id ||
      operationContentHash(r.scope) !== operationContentHash(payload.scope) ||
      r.rosterHash !== payload.rosterHash || c.changedAt > now ||
      c.changedAt > Date.parse(item.updatedAt) ||
      c.revision > (payload.closeout?.revision ?? 0) ||
      c.revision > r.workItemRevision || r.workItemRevision > item.revision ||
      c.revision === payload.closeout?.revision &&
        operationContentHash(c) !== operationContentHash(payload.closeout) ||
      receipt.actionId !== actionId || receipt.runId !== run.runId ||
      receipt.workItemId !== item.workItemId ||
      receipt.idempotencyKey !== id ||
      receipt.inputHash !== operationContentHash(r) ||
      receipt.operation !== "checkpoint_closeout_" + c.decision.kind ||
      receipt.rulesetVersion !== CHECKPOINT_WORK_RUNTIME ||
      receipt.actor.actorType !== "human" ||
      receipt.actor.actorId !== c.changedBy ||
      receipt.status !== "succeeded" || receipt.failure !== null ||
      receipt.toRevision !== r.workItemRevision ||
      receipt.fromRevision + 1 !== receipt.toRevision ||
      receipt.sequence !== receipt.toRevision ||
      receipt.occurredAt !== at || receipt.completedAt !== at ||
      receipt.outputHash === null || receipt.toRevision === item.revision &&
        receipt.outputHash !== operationContentHash(item)) throw invalidWork();
  return r;
}
