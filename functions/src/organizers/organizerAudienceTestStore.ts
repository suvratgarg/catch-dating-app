/**
 * Transactional test store for intake and audience joins. No production
 * export.
 */
import assert from "node:assert/strict";

type Data = Record<string, unknown>;
type Transaction = {
  getAll: (...refs: Ref[]) => Promise<unknown[]>;
  get: (ref: Ref | Query) => Promise<unknown>;
  create: (ref: Ref, data: Data) => void;
  set: (ref: Ref, data: Data) => void;
  update: (ref: Ref, data: Data) => void;
};
type Filter = [string, string, unknown];

class Ref {
  constructor(readonly store: AudienceTestStore, readonly path: string) {}
  get id() {
    return this.path.split("/").at(-1)!;
  }
  async get() {
    return this.store.snapshot(this);
  }
  async update(data: Data) {
    this.store.write(this, data, true);
  }
}

class Query {
  constructor(readonly store: AudienceTestStore, readonly path: string,
    readonly filters: Filter[] = [], readonly cap = Infinity) {}
  doc(id = "auto-id") {
    return new Ref(this.store, `${this.path}/${id}`);
  }
  where(field: string, op: string, value: unknown) {
    return new Query(this.store, this.path, [...this.filters, [field, op,
      value]],
    this.cap);
  }
  orderBy() {
    return this;
  }
  limit(cap: number) {
    return new Query(this.store, this.path, this.filters, cap);
  }
  async get() {
    const docs = Object.entries(this.store.docs)
      .filter(([path, data]) => path.startsWith(this.path + "/") &&
        path.split("/").length === this.path.split("/").length + 1 &&
        this.filters.every(([field, op, value]) => {
          const actual = field.split(".").reduce<unknown>((v, key) =>
            (v as Data)?.[key], data);
          if (op === "in") return (value as unknown[]).includes(actual);
          if (op === "<=") {
            if (actual == null) return false;
            return (actual as {toMillis: () => number}).toMillis() <=
              (value as {toMillis: () => number}).toMillis();
          }
          assert.equal(op, "==", "Unsupported test-store query operator");
          return actual === value;
        }))
      .sort(([a], [b]) => a.localeCompare(b)).slice(0, this.cap)
      .map(([path]) => this.store.snapshot(new Ref(this.store, path)));
    return {docs, size: docs.length, empty: docs.length === 0};
  }
}

export class AudienceTestStore {
  constructor(readonly docs: Record<string, Data> = {}) {}
  collection(path: string) {
    return new Query(this, path);
  }
  asFirestore() {
    return this as unknown as FirebaseFirestore.Firestore;
  }
  snapshot(ref: Ref) {
    const data = this.docs[ref.path];
    return {ref, id: ref.id, exists: data !== undefined, data: () => data};
  }
  async getAll(...refs: Ref[]) {
    return refs.map((ref) => this.snapshot(ref));
  }
  write(ref: Ref, data: Data, merge = false) {
    const next: Data = merge ? {...this.docs[ref.path]} : {};
    for (const [key, value] of Object.entries(data)) {
      next[key] = value?.constructor?.name === "NumericIncrementTransform" ?
        (Number(next[key]) || 0) +
          (value as {operand: number}).operand : value;
    }
    this.docs[ref.path] = next;
  }
  async runTransaction<T>(body: (tx: Transaction) => Promise<T>): Promise<T> {
    const writes: Array<() => void> = [];
    const result = await body({
      getAll: (...refs: Ref[]) => {
        assert.equal(writes.length, 0, "Firestore forbids reads after writes");
        return this.getAll(...refs);
      },
      get: (ref: Ref | Query) => {
        assert.equal(writes.length, 0, "Firestore forbids reads after writes");
        return ref.get();
      },
      create: (ref: Ref, data: Data) => writes.push(() => {
        assert.equal(this.docs[ref.path], undefined, "Duplicate create");
        this.write(ref, data);
      }),
      set: (ref: Ref, data: Data) => writes.push(() => this.write(ref, data)),
      update: (ref: Ref, data: Data) =>
        writes.push(() => this.write(ref, data, true)),
    });
    writes.forEach((write) => write());
    return result;
  }
}
