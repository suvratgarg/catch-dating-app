import {randomUUID} from "node:crypto";
import {FieldPath, Firestore, Transaction} from "firebase-admin/firestore";
import {operationCollections} from "../../operations/collections";
import {operationActionId, operationContentHash} from
  "../../operations/durableActions";
import {operationResourceLeaseId} from
  "../../operations/firestoreLeaseRepository";
import {FirestoreOperationsRepository} from
  "../../operations/firestoreRepository";
import type {OperationActionReceipt, OperationLease} from
  "../../operations/models";
import {EVENT_ASSISTANCE_MESSAGES} from "./firestoreMessageOutbox";
import {readEventAssistanceMessageGate} from "./guestMessageGate";
import {requireDocumentId} from "./guestRecords";
import {ASSISTANCE_WORKFLOW, invalidWork} from "./liveWorkRecords";
import {errorCode, releaseAssistanceWorkLease} from "./liveWorkRunner";
import {evaluateOutbox} from "./messageOutbox";
import {LiveMessageDispatcher} from "./liveMessageDispatcher";
import {readLateJoinDispatchState} from "./lateJoinDispatchPolicy";
import {nextDeliveryCheckpoint, observedDeliveryDecision,
  DeliveryExecution} from "./deliveryWorkPolicy";
import {advanceDeliveryWorkRecords, assertDeliveryMessage,
  deliveryReasonCode, deliveryWorkIds, DELIVERY_WORK_RUNTIME,
  readDeliveryWorkRecords} from
  "./deliveryWorkRecords";

type Records = ReturnType<typeof readDeliveryWorkRecords>;
type Dispatcher = Pick<LiveMessageDispatcher, "dispatch">;

/** Scheduling is durable; the independently fenced outbox owns provider I/O. */
export class AssistanceDeliveryWorkStore {
  readonly operations: FirestoreOperationsRepository;
  private readonly dispatcher: Dispatcher;
  constructor(private readonly db: Firestore,
    private readonly clock: () => number = Date.now, dispatcher?: Dispatcher) {
    this.operations = new FirestoreOperationsRepository(db, clock);
    this.dispatcher = dispatcher ?? new LiveMessageDispatcher(db, clock);
  }

  get(workItemId: string) {
    return this.db.runTransaction((tx) => this.read(tx, workItemId));
  }

  /** Receipts wake saved work; a raw outbox row cannot enroll itself. */
  async processMessage(messageId: string) {
    const {workItemId} = deliveryWorkIds(messageId);
    if (!(await this.db.collection(operationCollections.workItems)
      .doc(workItemId).get()).exists) return {kind: "idle" as const};
    return this.process(workItemId);
  }

  async listDue(limit: number) {
    const now = this.clock();
    if (!Number.isInteger(limit) || limit < 1 || limit > 100 ||
        !Number.isSafeInteger(now) || now < 0) throw invalidWork();
    const result = await this.db.collection(operationCollections.workItems)
      .where("workflowId", "==", ASSISTANCE_WORKFLOW)
      .where("normalizedPayload.kind", "==", "liveMessageDelivery")
      .where("normalizedPayload.checkpoint.dueAt", ">=", 0)
      .where("normalizedPayload.checkpoint.dueAt", "<=", now)
      .orderBy("normalizedPayload.checkpoint.dueAt")
      .orderBy(FieldPath.documentId()).limit(limit).get();
    return result.docs.map((doc) => doc.id);
  }

  async process(workItemId: string) {
    const initial = await this.snapshot(workItemId);
    if (!this.needsWork(initial)) {
      return {kind: "idle" as const,
        records: initial.records};
    }
    const lease = await this.acquire(workItemId);
    if (!lease) return {kind: "busy" as const};
    try {
      const current = await this.snapshot(workItemId);
      if (!this.needsWork(current)) {
        return {kind: "idle" as const,
          records: current.records};
      }
      if (current.kind === "closed") {
        return {kind: "idle" as const,
          records: current.records};
      }
      const decision = current.decision;
      const hasReservation = decision.kind === "reconcile" &&
        current.message.attempts.filter((a) =>
          decision.attemptIds.includes(a.attemptId))
          .every((a) => a.state.kind === "reserved");
      let execution: DeliveryExecution | null = null;
      if (!current.policyDeferred &&
          (hasReservation || (decision.kind === "hostDecision" &&
          decision.reason === "noEligibleRoute")) &&
          current.records.payload.checkpoint.evaluations < 100 &&
          this.clock() < current.records.payload.expiresAt) {
        try {
          execution = await this.dispatcher.dispatch(current.message,
            Math.min(Date.parse(lease.expiresAt),
              current.records.payload.expiresAt));
        } catch {
          // A crash after provider I/O may have persisted unknown/accepted.
          // The fresh checkpoint below reads that history before retry advice.
          execution = {kind: "unavailable"};
        }
      }
      return {kind: "committed" as const,
        records: await this.checkpoint(current.records, execution, lease)};
    } finally {
      await releaseAssistanceWorkLease(this.operations, lease, this.clock());
    }
  }

  private needsWork(value: Awaited<ReturnType<
    AssistanceDeliveryWorkStore["snapshot"]>>) {
    if (value.kind === "closed") return false;
    const c = value.records.payload.checkpoint;
    return operationContentHash(value.message) !== c.messageHash ||
      (c.dueAt !== null && c.dueAt <= this.clock());
  }

  private snapshot(workItemId: string) {
    return this.db.runTransaction(async (tx) => {
      const records = await this.read(tx, workItemId);
      if (records.run.status === "completed") {
        return {kind: "closed" as const, records};
      }
      return {kind: "open" as const, records,
        ...await this.observe(tx, records)};
    });
  }

  private async observe(tx: Transaction, records: Records) {
    const message = assertDeliveryMessage(records.payload,
      (await tx.get(this.db.collection(EVENT_ASSISTANCE_MESSAGES)
        .doc(records.payload.messageId))).data());
    if (this.clock() < message.updatedAt) throw invalidWork();
    const recorded = observedDeliveryDecision(message, this.clock());
    if (recorded) return {message, decision: recorded, policyDeferred: false};
    let gate;
    try {
      gate = await readEventAssistanceMessageGate(this.db, tx,
        message.intent, this.clock());
      if (gate.kind === "stop" && gate.reason === "hostStopped") {
        const state = await readLateJoinDispatchState(this.db, tx,
          message.intent, this.clock());
        if (state.deferred) {
          return {message, decision: state.deferred,
            policyDeferred: true};
        }
      }
    } catch {
      // Unavailable domain facts provide no send authority. Retain a bounded
      // repair issue instead of guessing attendance or retrying forever.
      return {message, decision: {kind: "refreshFacts" as const,
        reason: "eventFactsStale" as const}, policyDeferred: false};
    }
    const now = this.clock();
    if (now < message.updatedAt) throw invalidWork();
    return {message,
      decision: evaluateOutbox(message, {gate, routes: []}, now),
      policyDeferred: false};
  }

  private async checkpoint(previous: Records,
    execution: DeliveryExecution | null, lease: OperationLease) {
    return this.db.runTransaction(async (tx) => {
      const current = await this.read(tx, previous.item.workItemId);
      if (operationContentHash(current) !== operationContentHash(previous)) {
        throw new Error("Delivery work checkpoint changed");
      }
      const observed = await this.observe(tx, current);
      const now = this.clock();
      const next = advanceDeliveryWorkRecords(current,
        nextDeliveryCheckpoint(current.payload, observed.message,
          observed.decision, execution, now, observed.policyDeferred), now);
      const {run, item} = next;
      const at = new Date(now).toISOString();
      const key = "delivery:" + current.item.revision;
      const receipt: OperationActionReceipt = {schemaVersion: 1,
        actionId: operationActionId(run.runId, item.workItemId, key),
        runId: run.runId, workItemId: item.workItemId, sequence: item.revision,
        operation: "message_delivery_checkpoint", status: "succeeded",
        fromRevision: current.item.revision, toRevision: item.revision,
        actor: {actorType: "system",
          actorId: "event-assistance-delivery-worker"},
        idempotencyKey: key, inputHash: operationContentHash(current.item),
        outputHash: operationContentHash(item),
        rulesetVersion: DELIVERY_WORK_RUNTIME, modelVersion: null,
        reasonCodes: [deliveryReasonCode(next.payload.checkpoint.reason!)],
        occurredAt: at, completedAt: at, failure: null};
      const prepared = await this.operations.prepareWorkItemAction(tx,
        {workItem: item, receipt, lease});
      prepared.commit();
      tx.set(this.db.collection(operationCollections.runs).doc(run.runId), run);
      return next;
    });
  }

  private async read(tx: Transaction, workItemId: string) {
    requireDocumentId(workItemId);
    const item = (await tx.get(this.db
      .collection(operationCollections.workItems)
      .doc(workItemId))).data();
    if (!item || typeof item.runId !== "string") throw invalidWork();
    requireDocumentId(item.runId);
    const run = (await tx.get(this.db.collection(operationCollections.runs)
      .doc(item.runId))).data();
    return readDeliveryWorkRecords(run, item, workItemId, this.clock());
  }

  private async acquire(workItemId: string): Promise<OperationLease | null> {
    const now = this.clock();
    try {
      return await this.operations.acquireLease({
        leaseId: operationResourceLeaseId("work_item", workItemId),
        resourceId: workItemId, resourceType: "work_item",
        ownerId: "delivery-worker:" + randomUUID(),
        idempotencyKey: randomUUID(),
        acquiredAt: new Date(now).toISOString(),
        expiresAt: new Date(now + 60_000).toISOString()});
    } catch (error) {
      if (errorCode(error) === "lease_conflict") return null;
      throw error;
    }
  }
}
