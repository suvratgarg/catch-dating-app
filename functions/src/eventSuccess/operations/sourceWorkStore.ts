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
import {requireDocumentId} from "./guestRecords";
import {ASSISTANCE_WORKFLOW, invalidWork} from "./liveWorkRecords";
import {LiveAssistanceWorkRunner, errorCode, releaseAssistanceWorkLease} from
  "./liveWorkRunner";
import {SOURCE_WORK_RUNTIME, SourceWork, SourceWorkInput,
  newSourceWorkRecords, readSourceWorkRecords, sourceWorkProjection} from
  "./sourceWorkRecords";

type Records = ReturnType<typeof readSourceWorkRecords>;
type Failure = SourceWork["checkpoint"]["failures"][number];
const PAGE_SIZE = 20;

/** Durable bounded fanout, sharing Operations persistence and lease fencing. */
export class AssistanceSourceWorkStore {
  readonly operations: FirestoreOperationsRepository;
  private readonly target: Pick<LiveAssistanceWorkRunner, "process">;
  constructor(private readonly db: Firestore,
    private readonly clock: () => number = Date.now,
    target?: Pick<LiveAssistanceWorkRunner, "process">) {
    this.operations = new FirestoreOperationsRepository(db, clock);
    this.target = target ?? new LiveAssistanceWorkRunner(db, clock);
  }

  async enqueue(input: SourceWorkInput) {
    const frozen = structuredClone(input);
    return this.db.runTransaction(async (tx) => {
      const proposed = newSourceWorkRecords(frozen, this.clock());
      const runRef = this.db.collection(operationCollections.runs)
        .doc(proposed.run.runId);
      const itemRef = this.db.collection(operationCollections.workItems)
        .doc(proposed.item.workItemId);
      const [run, item] = await tx.getAll(runRef, itemRef);
      if (run.exists || item.exists) {
        const existing = readSourceWorkRecords(run.data(), item.data(),
          itemRef.id, this.clock());
        return {...existing, replayed: true};
      }
      tx.create(runRef, proposed.run);
      tx.create(itemRef, proposed.item);
      return {...proposed, replayed: false};
    });
  }

  get(workItemId: string) {
    return this.db.runTransaction((tx) => this.read(tx, workItemId));
  }

  async hasTargets(scope: SourceWork["scope"]) {
    return !(await this.targetQuery(scope, null).limit(1).get()).empty;
  }

  async listDue(limit: number) {
    if (!Number.isInteger(limit) || limit < 1 || limit > 100) {
      throw invalidWork();
    }
    const now = this.clock();
    if (!Number.isSafeInteger(now) || now < 0) throw invalidWork();
    const result = await this.db.collection(operationCollections.workItems)
      .where("workflowId", "==", ASSISTANCE_WORKFLOW)
      .where("normalizedPayload.kind", "==", "liveSourceWake")
      .where("normalizedPayload.checkpoint.dueAt", ">=", 0)
      .where("normalizedPayload.checkpoint.dueAt", "<=", now)
      .orderBy("normalizedPayload.checkpoint.dueAt")
      .orderBy(FieldPath.documentId()).limit(limit).get();
    return result.docs.map((doc) => doc.id);
  }

  async process(workItemId: string) {
    const initial = await this.get(workItemId);
    if (initial.payload.checkpoint.dueAt === null ||
        initial.payload.checkpoint.dueAt > this.clock()) {
      return {kind: "idle" as const, records: initial};
    }
    const lease = await this.acquire(workItemId);
    if (!lease) return {kind: "busy" as const};
    try {
      const current = await this.get(workItemId);
      if (current.payload.checkpoint.dueAt === null ||
          current.payload.checkpoint.dueAt > this.clock()) {
        return {kind: "idle" as const, records: current};
      }
      const next = await this.nextPage(current.payload, lease);
      return {kind: "committed" as const,
        records: await this.checkpoint(current, next, lease)};
    } finally {
      await releaseAssistanceWorkLease(this.operations, lease, this.clock());
    }
  }

  private async nextPage(payload: SourceWork, lease: OperationLease) {
    const next = structuredClone(payload);
    const c = next.checkpoint;
    if (this.clock() >= payload.expiresAt) {
      c.phase = "expired";
      c.dueAt = null;
      return next;
    }
    if (c.phase !== "scan" && c.phase !== "retry") throw invalidWork();
    let continueRetryPage = false;
    if (c.phase === "retry") {
      const pending = c.failures.filter((f) => c.cursor === null ||
        f.workItemId > c.cursor).sort((a, b) =>
        a.workItemId.localeCompare(b.workItemId));
      for (const previous of pending.slice(0, PAGE_SIZE)) {
        const failure = await this.wake(previous.workItemId, payload, lease);
        c.failures = c.failures.filter((f) =>
          f.workItemId !== previous.workItemId);
        if (failure) c.failures.push(failure);
        c.cursor = previous.workItemId;
      }
      continueRetryPage = pending.length > PAGE_SIZE;
      if (!continueRetryPage) {
        c.retries += 1;
        c.cursor = null;
      }
      c.phase = !c.failures.length ? "complete" :
        c.retries >= 5 ? "review" : "retry";
    } else {
      const room = Math.min(PAGE_SIZE, 10_000 - c.visited,
        100 - c.failures.length);
      if (room <= 0) {
        c.phase = "review";
      } else {
        const page = await this.targets(payload, room + 1);
        for (const id of page.slice(0, room)) {
          const failure = await this.wake(id, payload, lease);
          if (failure) c.failures.push(failure);
          c.cursor = id;
          c.visited += 1;
        }
        c.phase = page.length > room ? "scan" :
          c.failures.length ? "retry" : "complete";
        if (c.phase === "retry") c.cursor = null;
        if (c.phase === "scan" &&
            (c.visited >= 10_000 || c.failures.length >= 100)) {
          c.phase = "review";
        }
      }
    }
    c.dueAt = c.phase === "scan" || continueRetryPage ? this.clock() :
      c.phase === "retry" ? Math.min(payload.expiresAt,
        this.clock() + 30_000 * 2 ** c.retries) : null;
    return next;
  }

  private async wake(workItemId: string, payload: SourceWork,
    lease: OperationLease): Promise<Failure | null> {
    if (this.clock() >= Math.min(Date.parse(lease.expiresAt),
      payload.expiresAt)) {
      throw new Error("Source work execution window expired");
    }
    try {
      // Re-read the work's scope before invoking the generic target port.
      const target = await new LiveAssistanceWorkRunner(this.db, this.clock)
        .store.get(workItemId);
      if (operationContentHash(target.payload.scope.context) !==
          operationContentHash(payload.scope.context) ||
          (payload.scope.attendeeId !== null &&
            target.payload.scope.attendeeId !== payload.scope.attendeeId)) {
        throw invalidWork();
      }
      const result = await this.target.process(workItemId,
        {kind: "wake", signalId: payload.signalId});
      return result.kind === "busy" ? {workItemId, reason: "busy"} : null;
    } catch {
      // Keep the exact target for bounded retry and eventual human review;
      // other guests in this page still receive their wake signal.
      return {workItemId, reason: "unavailable"};
    }
  }

  private async targets(payload: SourceWork, limit: number) {
    return (await this.targetQuery(payload.scope, payload.checkpoint.cursor)
      .limit(limit).get()).docs.map((doc) => doc.id);
  }

  private targetQuery(scope: SourceWork["scope"], cursor: string | null) {
    let query = this.db.collection(operationCollections.workItems)
      .where("workflowId", "==", ASSISTANCE_WORKFLOW)
      .where("normalizedPayload.kind", "==", "liveLateJoin")
      .where("normalizedPayload.scope.context.organizerId", "==",
        scope.context.organizerId)
      .where("normalizedPayload.scope.context.eventId", "==",
        scope.context.eventId);
    if (scope.attendeeId !== null) {
      query = query.where("normalizedPayload.scope.attendeeId", "==",
        scope.attendeeId);
    }
    query = query.orderBy(FieldPath.documentId());
    if (cursor !== null) {
      query = query.startAfter(cursor);
    }
    return query;
  }

  private async checkpoint(previous: Records, payload: SourceWork,
    lease: OperationLease) {
    return this.db.runTransaction(async (tx) => {
      const current = await this.read(tx, previous.item.workItemId);
      if (current.item.revision !== previous.item.revision ||
          operationContentHash(current) !== operationContentHash(previous)) {
        throw new Error("Source work checkpoint changed");
      }
      const now = this.clock();
      if (now >= payload.expiresAt) {
        payload = {...payload, checkpoint: {...payload.checkpoint,
          phase: "expired", dueAt: null}};
      }
      const at = new Date(now).toISOString();
      const p = sourceWorkProjection(payload);
      const revision = current.item.revision + 1;
      const item = {...current.item, ...p, revision, attemptCount: revision,
        normalizedPayload: {...payload}, updatedAt: at};
      const run = {...current.run, revision,
        status: p.lifecycleStatus === "terminal" ? "completed" as const :
          p.primaryStage === "host_review" ? "paused" as const :
            "running" as const,
        updatedAt: at,
        finishedAt: p.lifecycleStatus === "terminal" ? at : null,
        checkpoint: {lastSequence: revision, cursor: payload.checkpoint.cursor},
        counters: {...current.run.counters, processed: 1,
          failed: payload.checkpoint.failures.length,
          escalated: Number(p.primaryStage === "host_review")}};
      const next = readSourceWorkRecords(run, item, item.workItemId, now);
      const key = "page:" + current.item.revision;
      const receipt: OperationActionReceipt = {schemaVersion: 1,
        actionId: operationActionId(run.runId, item.workItemId, key),
        runId: run.runId, workItemId: item.workItemId, sequence: revision,
        operation: "source_wake_page", status: "succeeded",
        fromRevision: current.item.revision, toRevision: revision,
        actor: {actorType: "system", actorId: "event-assistance-source-worker"},
        idempotencyKey: key, inputHash: operationContentHash(current.item),
        outputHash: operationContentHash(item),
        rulesetVersion: SOURCE_WORK_RUNTIME,
        modelVersion: null,
        reasonCodes: p.blockerCodes.length ? p.blockerCodes :
          ["source_wake_" + payload.checkpoint.phase],
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
    const item = (await tx.get(this.db.collection(
      operationCollections.workItems).doc(workItemId))).data();
    if (!item || typeof item.runId !== "string") throw invalidWork();
    requireDocumentId(item.runId);
    const run = (await tx.get(this.db.collection(operationCollections.runs)
      .doc(item.runId))).data();
    return readSourceWorkRecords(run, item, workItemId, this.clock());
  }

  private async acquire(workItemId: string): Promise<OperationLease | null> {
    const now = this.clock();
    try {
      return await this.operations.acquireLease({
        leaseId: operationResourceLeaseId("work_item", workItemId),
        resourceId: workItemId, resourceType: "work_item",
        ownerId: "source-worker:" + randomUUID(), idempotencyKey: randomUUID(),
        acquiredAt: new Date(now).toISOString(),
        expiresAt: new Date(now + 60_000).toISOString()});
    } catch (error) {
      if (errorCode(error) === "lease_conflict") return null;
      throw error;
    }
  }
}
