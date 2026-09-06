import assert from "node:assert/strict";

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
    private readonly filters: Array<[string, string, unknown]> = [],
    private readonly cursor: string | null = null,
    private readonly pageLimit: number | null = null
  ) {}

  where(field: string, operator: string, value: unknown): FakeQuery {
    return new FakeQuery(
      this.firestore,
      this.collectionPath,
      [...this.filters, [field, operator, value]],
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
      .filter((snapshot) => this.filters.every(([field, operator, value]) => {
        const stored = snapshot.data()?.[field];
        return operator === "array-contains" ?
          Array.isArray(stored) && stored.includes(value) :
          stored === value;
      }))
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
  private readonly writes = new Map<string, FakeData>();

  constructor(private readonly firestore: FakeFirestore) {}

  async get(reference: FakeDocReference): Promise<FakeSnapshot> {
    assert.equal(this.writes.size, 0, "Firestore reads must precede writes");
    return reference.get();
  }

  async getAll(...references: FakeDocReference[]): Promise<FakeSnapshot[]> {
    assert.equal(this.writes.size, 0, "Firestore reads must precede writes");
    return Promise.all(references.map((reference) => reference.get()));
  }

  create(reference: FakeDocReference, value: unknown): void {
    if (this.firestore.read(reference.path) ||
        this.writes.has(reference.path)) {
      throw new Error("already exists");
    }
    this.writes.set(reference.path, structuredClone(value as FakeData));
  }

  set(reference: FakeDocReference, value: unknown): void {
    this.writes.set(reference.path, structuredClone(value as FakeData));
  }

  commit(): void {
    for (const [path, value] of this.writes) this.firestore.write(path, value);
  }
}

export class FakeFirestore {
  private readonly docs = new Map<string, FakeData>();
  private transactionTail: Promise<unknown> = Promise.resolve();
  failNextCommit = false;

  collection(path: string): FakeCollection {
    return new FakeCollection(this, path);
  }

  async runTransaction<T>(
    callback: (transaction: FakeTransaction) => Promise<T>
  ): Promise<T> {
    const pending = this.transactionTail.then(async () => {
      const transaction = new FakeTransaction(this);
      const result = await callback(transaction);
      if (this.failNextCommit) {
        this.failNextCommit = false;
        throw new Error("injected transaction interruption");
      }
      transaction.commit();
      return result;
    });
    this.transactionTail = pending.catch(() => undefined);
    return pending;
  }

  read(path: string): FakeData | undefined {
    const value = this.docs.get(path);
    return value === undefined ? undefined : structuredClone(value);
  }

  write(path: string, value: FakeData): void {
    this.docs.set(path, structuredClone(value));
  }

  remove(path: string): void {
    this.docs.delete(path);
  }

  entries(): Array<[string, FakeData]> {
    return [...this.docs.entries()].map(([path, value]) =>
      [path, structuredClone(value)]);
  }
}
