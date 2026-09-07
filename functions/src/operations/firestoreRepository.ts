import {
  DocumentData,
  DocumentReference,
  FieldPath,
  Firestore,
  Query,
} from "firebase-admin/firestore";
import {isDeepStrictEqual} from "node:util";
import {operationCollections} from "./collections";
import {
  CommitWorkItemAction,
  CommittedWorkItemAction,
  operationActionId,
  operationContentHash,
} from "./durableActions";
import {
  assertCurrentOperationLease,
  FirestoreOperationLeaseRepository,
  operationResourceLeaseId,
  validatedLease,
} from "./firestoreLeaseRepository";
import {
  OperationConflictError,
  OperationDomainError,
  OperationNotFoundError,
} from "./errors";
import {
  OperationActionReceipt,
  OperationRun,
  OperationWorkItem,
} from "./models";
import {
  ListPage,
  OperationRunRepository,
  OperationWorkItemRepository,
  RunListQuery,
  WorkItemListQuery,
} from "./repositories";
import {
  validateOperationActionReceipt,
  validateOperationRun,
  validateOperationWorkItem,
  ValidationResult,
} from "./validation";
import {decodeRunCursor, encodeRunCursor} from "./runPagination";

type DurableOperationsRepository =
  OperationRunRepository & OperationWorkItemRepository;

function clone<T>(value: T): T {
  return structuredClone(value);
}

function validated<T>(
  result: ValidationResult<T>,
  entity: string
): T {
  if (!result.ok) {
    throw new OperationDomainError(
      "invalid_entity",
      `${entity} is invalid: ${result.issues.map((issue) =>
        `${issue.path}:${issue.code}`).join(", ")}`
    );
  }
  return result.value;
}

function assertPageLimit(limit: number): void {
  if (!Number.isInteger(limit) || limit < 1 || limit > 200) {
    throw new OperationDomainError(
      "invalid_page_limit",
      "Page limit must be an integer between 1 and 200"
    );
  }
}

export class FirestoreOperationsRepository extends
  FirestoreOperationLeaseRepository implements
  DurableOperationsRepository {
  constructor(db: Firestore, leaseClock: () => number = Date.now) {
    super(db, leaseClock);
  }

  /**
   * Commit the work-item checkpoint and immutable evidence together. This
   * transaction never invokes a provider; a worker must reserve an external
   * attempt durably before calling it and reconcile an uncertain outcome.
   */
  async commitWorkItemAction(input: CommitWorkItemAction):
    Promise<CommittedWorkItemAction> {
    const {workItem, receipt, lease: proof} = input;
    validated(validateOperationWorkItem(workItem), "work item");
    validated(validateOperationActionReceipt(receipt), "action receipt");
    if (receipt.actionId !== operationActionId(
      receipt.runId, receipt.workItemId, receipt.idempotencyKey
    ) || receipt.runId !== workItem.runId ||
        receipt.workItemId !== workItem.workItemId ||
        receipt.fromRevision + 1 !== workItem.revision ||
        receipt.toRevision !== workItem.revision ||
        receipt.sequence !== workItem.revision ||
        receipt.outputHash !== operationContentHash(workItem)) {
      throw new OperationDomainError("action_binding_mismatch",
        "Receipt must bind the exact work item, revision and idempotency key");
    }
    if (proof.leaseId !== operationResourceLeaseId(
      "work_item", workItem.workItemId
    )) {
      throw new OperationDomainError("lease_resource_mismatch",
        "Action requires the work item's lease");
    }
    const itemRef = this.db.collection(operationCollections.workItems)
      .doc(workItem.workItemId);
    const receiptRef = this.db.collection(operationCollections.actionReceipts)
      .doc(receipt.actionId);
    const leaseRef = this.db.collection(operationCollections.leases)
      .doc(proof.leaseId);
    const runRef = this.db.collection(operationCollections.runs)
      .doc(workItem.runId);
    return this.db.runTransaction(async (transaction) => {
      const [itemSnapshot, receiptSnapshot, leaseSnapshot, runSnapshot] =
        await Promise.all([
          transaction.get(itemRef), transaction.get(receiptRef),
          transaction.get(leaseRef), transaction.get(runRef),
        ]);
      if (!itemSnapshot.exists || !runSnapshot.exists) {
        throw new OperationNotFoundError("operation", workItem.workItemId);
      }
      const current = validated(
        validateOperationWorkItem(itemSnapshot.data()), "stored work item"
      );
      const run = validated(
        validateOperationRun(runSnapshot.data()), "stored run"
      );
      if (current.workItemId !== workItem.workItemId ||
          current.runId !== run.runId || run.runId !== workItem.runId ||
          current.workflowId !== workItem.workflowId ||
          run.workflowId !== workItem.workflowId ||
          current.entityKind !== workItem.entityKind) {
        throw new OperationDomainError("action_scope_mismatch",
          "Action cannot change the owning run, workflow or entity");
      }
      if (receiptSnapshot.exists) {
        const existing = validated(validateOperationActionReceipt(
          receiptSnapshot.data()
        ), "stored action receipt");
        if (!isDeepStrictEqual(existing, receipt)) {
          throw new OperationConflictError("idempotency_conflict",
            "Action key has already been committed with different evidence");
        }
        if (current.revision < existing.toRevision ||
            (current.revision === existing.toRevision &&
             operationContentHash(current) !== existing.outputHash)) {
          throw new OperationConflictError("action_checkpoint_drift",
            "Work item no longer contains the committed checkpoint");
        }
        return {workItem: clone(current), receipt: clone(existing),
          replayed: true};
      }
      if (!leaseSnapshot.exists) {
        throw new OperationNotFoundError("lease", proof.leaseId);
      }
      const now = this.leaseClock();
      assertCurrentOperationLease(
        validatedLease(leaseSnapshot.data()), proof, now
      );
      if (run.status !== "running" ||
          (run.budgets.deadlineAt !== null &&
           Date.parse(run.budgets.deadlineAt) <= now)) {
        throw new OperationConflictError("run_not_executable",
          "Work can advance only within an active run's deadline");
      }
      if (current.lifecycleStatus === "terminal" ||
          current.lifecycleStatus === "published") {
        throw new OperationConflictError("terminal_work_item",
          "Completed work cannot re-enter execution");
      }
      if (current.revision !== receipt.fromRevision) {
        throw new OperationConflictError("revision_conflict",
          "Work item advanced after this action was prepared");
      }
      transaction.set(itemRef, workItem);
      transaction.create(receiptRef, receipt);
      return {workItem: clone(workItem), receipt: clone(receipt),
        replayed: false};
    });
  }

  async getActionReceipt(actionId: string):
    Promise<OperationActionReceipt | null> {
    const snapshot = await this.db
      .collection(operationCollections.actionReceipts).doc(actionId).get();
    if (!snapshot.exists) return null;
    const receipt = validated(validateOperationActionReceipt(snapshot.data()),
      "stored action receipt");
    if (receipt.actionId !== actionId) {
      throw new OperationDomainError("action_identity_mismatch",
        "Stored receipt does not match its document id");
    }
    return receipt;
  }

  async findActionReceiptByIdempotencyKey(
    runId: string, workItemId: string, idempotencyKey: string
  ): Promise<OperationActionReceipt | null> {
    const receipt = await this.getActionReceipt(operationActionId(
      runId, workItemId, idempotencyKey
    ));
    if (receipt && (receipt.runId !== runId ||
        receipt.workItemId !== workItemId ||
        receipt.idempotencyKey !== idempotencyKey)) {
      throw new OperationDomainError("action_scope_mismatch",
        "Receipt lookup does not match its idempotency scope");
    }
    return receipt;
  }

  async createRun(run: OperationRun): Promise<OperationRun> {
    validated(validateOperationRun(run), "run");
    this.assertInitialRevision(run.revision);
    await this.createVersioned(
      this.db.collection(operationCollections.runs).doc(run.runId),
      run,
      "run"
    );
    return clone(run);
  }

  async getRun(runId: string): Promise<OperationRun | null> {
    const snapshot = await this.db
      .collection(operationCollections.runs)
      .doc(runId)
      .get();
    if (!snapshot.exists) return null;
    return clone(validated(
      validateOperationRun(snapshot.data()),
      `stored run ${runId}`
    ));
  }

  async saveRun(run: OperationRun, expectedRevision: number):
    Promise<OperationRun> {
    validated(validateOperationRun(run), "run");
    await this.saveVersioned(
      this.db.collection(operationCollections.runs).doc(run.runId),
      run,
      expectedRevision,
      "run"
    );
    return clone(run);
  }

  async listRuns(query: RunListQuery): Promise<ListPage<OperationRun>> {
    assertPageLimit(query.limit);
    let firestoreQuery: Query<DocumentData> = this.db.collection(
      operationCollections.runs
    );
    if (query.workflowId) {
      firestoreQuery = firestoreQuery.where(
        "workflowId",
        "==",
        query.workflowId
      );
    }
    if (query.status) {
      firestoreQuery = firestoreQuery.where("status", "==", query.status);
    }
    firestoreQuery = firestoreQuery
      .orderBy("updatedAt", "desc")
      .orderBy(FieldPath.documentId(), "desc");
    if (query.cursor) {
      const cursor = decodeRunCursor(query.cursor);
      firestoreQuery = firestoreQuery.startAfter(
        cursor.updatedAt,
        cursor.runId
      );
    }
    const snapshot = await firestoreQuery.limit(query.limit + 1).get();
    const hasMore = snapshot.docs.length > query.limit;
    const docs = snapshot.docs.slice(0, query.limit);
    const items = docs.map((doc) => clone(validated(
      validateOperationRun(doc.data()),
      `stored run ${doc.id}`
    )));
    return {
      items,
      nextCursor: hasMore ? encodeRunCursor(items[items.length - 1]) : null,
    };
  }

  async createWorkItem(workItem: OperationWorkItem):
    Promise<OperationWorkItem> {
    validated(validateOperationWorkItem(workItem), "work item");
    this.assertInitialRevision(workItem.revision);
    await this.createVersioned(
      this.db.collection(operationCollections.workItems)
        .doc(workItem.workItemId),
      workItem,
      "work item"
    );
    return clone(workItem);
  }

  async getWorkItem(workItemId: string): Promise<OperationWorkItem | null> {
    const snapshot = await this.db
      .collection(operationCollections.workItems)
      .doc(workItemId)
      .get();
    if (!snapshot.exists) return null;
    return clone(validated(
      validateOperationWorkItem(snapshot.data()),
      `stored work item ${workItemId}`
    ));
  }

  async saveWorkItem(
    workItem: OperationWorkItem,
    expectedRevision: number
  ): Promise<OperationWorkItem> {
    validated(validateOperationWorkItem(workItem), "work item");
    await this.saveVersioned(
      this.db.collection(operationCollections.workItems)
        .doc(workItem.workItemId),
      workItem,
      expectedRevision,
      "work item"
    );
    return clone(workItem);
  }

  async listWorkItems(query: WorkItemListQuery):
    Promise<ListPage<OperationWorkItem>> {
    assertPageLimit(query.limit);
    let firestoreQuery: Query<DocumentData> = this.db.collection(
      operationCollections.workItems
    );
    const filters: Array<[string, unknown]> = [
      ["workflowId", query.workflowId],
      ["runId", query.runId],
      ["primaryStage", query.primaryStage],
      ["entityKind", query.entityKind],
      ["lifecycleStatus", query.lifecycleStatus],
    ];
    for (const [field, value] of filters) {
      if (value !== undefined) {
        firestoreQuery = firestoreQuery.where(field, "==", value);
      }
    }
    if (query.humanReviewRequired) {
      firestoreQuery = firestoreQuery.where(
        "taskFlags",
        "array-contains",
        "human_review_required"
      );
    }
    firestoreQuery = firestoreQuery.orderBy(FieldPath.documentId());
    if (query.cursor) {
      firestoreQuery = firestoreQuery.startAfter(query.cursor);
    }
    const snapshot = await firestoreQuery.limit(query.limit + 1).get();
    const hasMore = snapshot.docs.length > query.limit;
    const docs = snapshot.docs.slice(0, query.limit);
    const items = docs.map((doc) => clone(validated(
      validateOperationWorkItem(doc.data()),
      `stored work item ${doc.id}`
    )));
    return {
      items,
      nextCursor: hasMore ? docs[docs.length - 1].id : null,
    };
  }

  private async createVersioned<T extends {revision: number}>(
    reference: DocumentReference<DocumentData>,
    value: T,
    entity: string
  ): Promise<void> {
    await this.db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(reference);
      if (snapshot.exists) {
        throw new OperationConflictError(
          "already_exists",
          `${entity} ${reference.id} already exists`
        );
      }
      transaction.create(reference, value);
    });
  }

  private async saveVersioned<T extends {revision: number}>(
    reference: DocumentReference<DocumentData>,
    value: T,
    expectedRevision: number,
    entity: string
  ): Promise<void> {
    await this.db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(reference);
      if (!snapshot.exists) {
        throw new OperationNotFoundError(entity, reference.id);
      }
      const storedRevision = snapshot.data()?.revision;
      if (storedRevision !== expectedRevision) {
        throw new OperationConflictError(
          "revision_conflict",
          `${entity} ${reference.id} expected revision ` +
            `${expectedRevision}; found ${String(storedRevision)}`
        );
      }
      if (value.revision !== expectedRevision + 1) {
        throw new OperationDomainError(
          "revision_not_incremented",
          `${entity} ${reference.id} must increment revision exactly once`
        );
      }
      transaction.set(reference, value);
    });
  }

  private assertInitialRevision(revision: number): void {
    if (revision !== 0) {
      throw new OperationDomainError(
        "invalid_initial_revision",
        "New versioned records must start at revision 0"
      );
    }
  }
}
