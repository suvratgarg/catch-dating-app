/** Test adapter shared by program/transport handler suites. Real IDs, atomic
 * rollback, read-before-write checks and optimistic transaction retries.
 * It does not prove production index, IAM or emulator behavior.
 */
export type FakeData = Record<string, unknown>;
type Where = {field: string; op: string; value: unknown};


export function timestampMillis(value: unknown): number {
  if (value && typeof value === "object") {
    const stamp = value as {seconds?: number; _seconds?: number;
      toMillis?: () => number};
    if (typeof stamp.toMillis === "function") return stamp.toMillis();
    if (typeof stamp.seconds === "number") return stamp.seconds * 1000;
    if (typeof stamp._seconds === "number") return stamp._seconds * 1000;
  }
  return typeof value === "number" ? value : 0;
}

class FakeDocSnapshot {
  constructor(readonly id: string,
    readonly ref: FakeDocRef,
    private readonly value: FakeData | undefined) {}
  get exists() {
    return this.value !== undefined;
  }
  data() {
    return this.value;
  }
}

export class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}
  get id() {
    return this.path.split("/").pop()!;
  }
  async get() {
    return new FakeDocSnapshot(this.id, this,
      this.firestore.getDoc(this.path));
  }
  async set(data: FakeData) {
    this.firestore.setDoc(this.path, data);
  }
  async update(data: FakeData) {
    this.firestore.updateDoc(this.path, data);
  }
}

class FakeQuery {
  constructor(readonly firestore: FakeFirestore,
    readonly collectionPath: string,
    readonly wheres: Where[] = [],
    readonly order: {field: string; dir: "asc" | "desc"} | null = null,
    readonly limitN: number | null = null,
    readonly startAfterValue: unknown = null) {}
  where(field: string, op: string, value: unknown) {
    return new FakeQuery(this.firestore, this.collectionPath,
      [...this.wheres, {field, op, value}], this.order, this.limitN,
      this.startAfterValue);
  }
  orderBy(field: string | {toString(): string}, dir: "asc" | "desc" = "asc") {
    return new FakeQuery(this.firestore, this.collectionPath, this.wheres,
      {field: String(field), dir}, this.limitN, this.startAfterValue);
  }
  limit(n: number) {
    return new FakeQuery(this.firestore, this.collectionPath, this.wheres,
      this.order, n, this.startAfterValue);
  }
  startAfter(value: unknown) {
    return new FakeQuery(this.firestore, this.collectionPath, this.wheres,
      this.order, this.limitN, value);
  }
  async get() {
    return this.firestore.runQuery(this);
  }
}

class FakeCollectionRef extends FakeQuery {
  doc(id?: string) {
    return new FakeDocRef(this.firestore,
      `${this.collectionPath}/${id ?? this.firestore.nextAutoId()}`);
  }
}

class FakeQuerySnapshot {
  constructor(readonly docs: FakeDocSnapshot[]) {}
  get size() {
    return this.docs.length;
  }
}

class FakeTransaction {
  private readonly writes: Array<() => void> = [];
  constructor(private readonly firestore: FakeFirestore) {}
  async get(source: FakeDocRef | FakeQuery) {
    if (this.writes.length > 0) {
      throw new Error("Firestore transactions require reads before writes.");
    }
    return source.get();
  }
  set(ref: FakeDocRef, data: FakeData) {
    this.writes.push(() => this.firestore.setDoc(ref.path, data));
  }
  update(ref: FakeDocRef, data: FakeData) {
    this.writes.push(() => this.firestore.updateDoc(ref.path, data));
  }
  commit() {
    for (const write of this.writes) write();
  }
}

export class FakeFirestore {
  readonly docs: Map<string, FakeData>;
  private autoCounter = 0;
  private version = 0;
  transactionCommits = 0;
  beforeCommit?: () => Promise<void>;
  nextAutoId(): string {
    return `auto-${++this.autoCounter}`;
  }
  doc(path: string) {
    return new FakeDocRef(this, path);
  }
  constructor(seed: Record<string, FakeData | undefined>) {
    this.docs = new Map(Object.entries(seed)
      .filter(([, v]) => v !== undefined) as [string, FakeData][]);
  }
  collection(path: string) {
    return new FakeCollectionRef(this, path);
  }
  getDoc(path: string) {
    return this.docs.get(path);
  }
  setDoc(path: string, data: FakeData) {
    this.docs.set(path, {...data});
    this.version++;
  }
  updateDoc(path: string, data: FakeData) {
    const existing = this.docs.get(path);
    if (!existing) throw new Error(`Document missing: ${path}`);
    this.docs.set(path, {...existing, ...data});
    this.version++;
  }
  async runQuery(query: FakeQuery) {
    const prefix = `${query.collectionPath}/`;
    const docs: FakeDocSnapshot[] = [];
    for (const [path, data] of this.docs) {
      if (!path.startsWith(prefix)) continue;
      if (path.slice(prefix.length).includes("/")) continue;
      const id = path.slice(prefix.length);
      const ref = new FakeDocRef(this, path);
      if (query.wheres.every((where) => matchWhere(data, where))) {
        docs.push(new FakeDocSnapshot(id, ref, data));
      }
    }
    if (query.order) {
      const {field, dir} = query.order;
      docs.sort((a, b) => {
        const av = field === "__name__" ? a.id :
          timestampMillis(a.data()?.[field]) ||
          String(a.data()?.[field] ?? "");
        const bv = field === "__name__" ? b.id :
          timestampMillis(b.data()?.[field]) ||
          String(b.data()?.[field] ?? "");
        const order = av < bv ? -1 : av > bv ? 1 :
          a.id < b.id ? -1 : a.id > b.id ? 1 : 0;
        return dir === "desc" ? -order : order;
      });
    }
    let filtered = docs;
    if (query.startAfterValue !== null && query.order) {
      const field = query.order.field;
      const cursor = query.startAfterValue;
      const cursorValue = cursor instanceof FakeDocSnapshot ?
        (field === "__name__" ? cursor.id : cursor.data()?.[field]) : cursor;
      filtered = docs.filter((doc) => {
        const value = field === "__name__" ? doc.id : doc.data()?.[field];
        const av = timestampMillis(value) || String(value ?? "");
        const bv = timestampMillis(cursorValue) || String(cursorValue ?? "");
        const order = av < bv ? -1 : av > bv ? 1 :
          cursor instanceof FakeDocSnapshot ?
            doc.id < cursor.id ? -1 : doc.id > cursor.id ? 1 : 0 : 0;
        return query.order!.dir === "desc" ? order < 0 : order > 0;
      });
    }
    const limited = query.limitN === null ?
      filtered : filtered.slice(0, query.limitN);
    return new FakeQuerySnapshot(limited);
  }
  async runTransaction<T>(callback: (tx: FakeTransaction) => Promise<T>) {
    for (let attempt = 0; attempt < 20; attempt++) {
      const readVersion = this.version;
      const tx = new FakeTransaction(this);
      const result = await callback(tx);
      await this.beforeCommit?.();
      if (readVersion !== this.version) continue;
      const before = new Map(this.docs);
      try {
        tx.commit();
        this.transactionCommits++;
        return result;
      } catch (error) {
        this.docs.clear();
        for (const [key, value] of before) this.docs.set(key, value);
        throw error;
      }
    }
    throw new Error("Test transaction exhausted retries.");
  }
}

function matchWhere(data: FakeData, where: Where): boolean {
  const value = data[where.field];
  if (where.op === "==") return value === where.value;
  if (where.op === "array-contains") {
    return Array.isArray(value) && value.includes(where.value);
  }
  if (where.op === "in") {
    return Array.isArray(where.value) && where.value.includes(value);
  }
  if (where.op === ">" || where.op === "<=") {
    if (value == null) return false;
    return where.op === ">" ?
      timestampMillis(value) > timestampMillis(where.value) :
      timestampMillis(value) <= timestampMillis(where.value);
  }
  if (where.op === "!=") return value !== where.value;
  throw new Error(`Unsupported where op: ${where.op}`);
}

