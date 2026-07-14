import assert from "node:assert/strict";
import test from "node:test";
import {Firestore} from "firebase-admin/firestore";
import {OperationConflictError} from "./errors";
import {FirestoreOperationsRepository} from "./firestoreRepository";
import {operationRun, operationWorkItem} from "./testFixtures";

type FakeData = Record<string, unknown>;

class FakeSnapshot {
  constructor(readonly id: string, private readonly value?: FakeData) {}

  get exists(): boolean {
    return this.value !== undefined;
  }

  data(): FakeData | undefined {
    return this.value === undefined ? undefined : structuredClone(this.value);
  }
}

class FakeDocReference {
  constructor(
    readonly firestore: FakeFirestore,
    readonly collectionPath: string,
    readonly id: string
  ) {}

  get path(): string {
    return `${this.collectionPath}/${this.id}`;
  }

  async get(): Promise<FakeSnapshot> {
    return new FakeSnapshot(this.id, this.firestore.read(this.path));
  }
}

class FakeQuery {
  constructor(
    protected readonly firestore: FakeFirestore,
    protected readonly collectionPath: string,
    private readonly filters: Array<[string, unknown]> = [],
    private readonly cursor: string | null = null,
    private readonly pageLimit: number | null = null
  ) {}

  where(field: string, _operator: string, value: unknown): FakeQuery {
    return new FakeQuery(
      this.firestore,
      this.collectionPath,
      [...this.filters, [field, value]],
      this.cursor,
      this.pageLimit
    );
  }

  orderBy(field: unknown): FakeQuery {
    void field;
    return this;
  }

  startAfter(cursor: string): FakeQuery {
    return new FakeQuery(
      this.firestore,
      this.collectionPath,
      this.filters,
      cursor,
      this.pageLimit
    );
  }

  limit(limit: number): FakeQuery {
    return new FakeQuery(
      this.firestore,
      this.collectionPath,
      this.filters,
      this.cursor,
      limit
    );
  }

  async get(): Promise<{docs: FakeSnapshot[]}> {
    const prefix = `${this.collectionPath}/`;
    const docs = this.firestore.entries()
      .filter(([path]) => path.startsWith(prefix))
      .map(([path, value]) =>
        new FakeSnapshot(path.slice(prefix.length), value))
      .filter((snapshot) => !this.cursor || snapshot.id > this.cursor)
      .filter((snapshot) => this.filters.every(([field, value]) =>
        snapshot.data()?.[field] === value))
      .sort((left, right) => left.id.localeCompare(right.id));
    return {
      docs: this.pageLimit === null ? docs : docs.slice(0, this.pageLimit),
    };
  }
}

class FakeCollection extends FakeQuery {
  doc(id: string): FakeDocReference {
    return new FakeDocReference(this.firestore, this.collectionPath, id);
  }
}

class FakeTransaction {
  constructor(private readonly firestore: FakeFirestore) {}

  async get(reference: FakeDocReference): Promise<FakeSnapshot> {
    return reference.get();
  }

  create(reference: FakeDocReference, value: unknown): void {
    if (this.firestore.read(reference.path)) {
      throw new Error("already exists");
    }
    this.firestore.write(reference.path, value as FakeData);
  }

  set(reference: FakeDocReference, value: unknown): void {
    this.firestore.write(reference.path, value as FakeData);
  }
}

class FakeFirestore {
  private readonly docs = new Map<string, FakeData>();

  collection(path: string): FakeCollection {
    return new FakeCollection(this, path);
  }

  async runTransaction<T>(
    callback: (transaction: FakeTransaction) => Promise<T>
  ): Promise<T> {
    return callback(new FakeTransaction(this));
  }

  read(path: string): FakeData | undefined {
    const value = this.docs.get(path);
    return value === undefined ? undefined : structuredClone(value);
  }

  write(path: string, value: FakeData): void {
    this.docs.set(path, structuredClone(value));
  }

  entries(): Array<[string, FakeData]> {
    return [...this.docs.entries()].map(([path, value]) =>
      [path, structuredClone(value)]);
  }
}

interface Harness {
  firestore: FakeFirestore;
  repository: FirestoreOperationsRepository;
}

function harness(): Harness {
  const firestore = new FakeFirestore();
  return {
    firestore,
    repository: new FirestoreOperationsRepository(
      firestore as unknown as Firestore
    ),
  };
}

test("Firestore repository round-trips serializable run and work items",
  async () => {
    const {repository} = harness();
    await repository.createRun(operationRun());
    await repository.createWorkItem(operationWorkItem());
    assert.equal((await repository.getRun(
      "run:mumbai:2026-07-14"
    ))?.workflowId, "supply-intake");
    assert.equal((await repository.getWorkItem(
      "work:event:1"
    ))?.primaryStage, "incoming");
  });

test("Firestore repository compares revisions in a transaction", async () => {
  const {repository} = harness();
  await repository.createWorkItem(operationWorkItem());
  await repository.saveWorkItem(operationWorkItem({
    revision: 1,
    primaryStage: "verify",
    lifecycleStatus: "in_progress",
  }), 0);
  await assert.rejects(repository.saveWorkItem(operationWorkItem({
    revision: 2,
    primaryStage: "resolve",
    lifecycleStatus: "waiting",
  }), 0), (error: unknown) => {
    assert.ok(error instanceof OperationConflictError);
    assert.equal(error.code, "revision_conflict");
    return true;
  });
});

test("Firestore repository filters before stable document-id pagination",
  async () => {
    const {repository} = harness();
    for (let index = 0; index < 3; index += 1) {
      await repository.createWorkItem(operationWorkItem({
        workItemId: `work:event:${index}`,
        entityKind: index === 2 ? "organizer" : "event",
      }));
    }
    const first = await repository.listWorkItems({
      workflowId: "supply-intake",
      primaryStage: "incoming",
      entityKind: "event",
      limit: 1,
    });
    assert.deepEqual(first.items.map((item) => item.workItemId), [
      "work:event:0",
    ]);
    assert.equal(first.nextCursor, "work:event:0");
    const second = await repository.listWorkItems({
      workflowId: "supply-intake",
      primaryStage: "incoming",
      entityKind: "event",
      limit: 1,
      cursor: first.nextCursor,
    });
    assert.deepEqual(second.items.map((item) => item.workItemId), [
      "work:event:1",
    ]);
  });
