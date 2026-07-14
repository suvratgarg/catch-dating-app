import {
  DocumentData,
  DocumentReference,
  FieldPath,
  Firestore,
  Query,
} from "firebase-admin/firestore";
import {operationCollections} from "./collections";
import {
  OperationConflictError,
  OperationDomainError,
  OperationNotFoundError,
} from "./errors";
import {OperationRun, OperationWorkItem} from "./models";
import {
  ListPage,
  OperationRunRepository,
  OperationWorkItemRepository,
  RunListQuery,
  WorkItemListQuery,
} from "./repositories";
import {
  validateOperationRun,
  validateOperationWorkItem,
  ValidationResult,
} from "./validation";

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

export class FirestoreOperationsRepository implements
  DurableOperationsRepository {
  constructor(private readonly db: Firestore) {}

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
    firestoreQuery = firestoreQuery.orderBy(FieldPath.documentId());
    if (query.cursor) {
      firestoreQuery = firestoreQuery.startAfter(query.cursor);
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
      nextCursor: hasMore ? docs[docs.length - 1].id : null,
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
