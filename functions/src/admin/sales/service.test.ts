import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {executeSalesAction} from "./service";
import type {SalesServiceDeps} from "./service";
import type {SalesPrincipal} from "./types";

type Doc = Record<string, unknown>;
class FakeRef {
  constructor(readonly db: FakeDb, readonly path: string) {}
  get id() { return this.path.split("/").at(-1) ?? ""; }
  collection(name: string) { return new FakeCollection(this.db, `${this.path}/${name}`); }
}
class FakeCollection {
  constructor(readonly db: FakeDb, readonly path: string) {}
  doc(id?: string) { return new FakeRef(this.db, `${this.path}/${id ?? `auto${++this.db.seq}`}`); }
}
class FakeDb {
  seq = 0;
  readonly docs = new Map<string, Doc>();
  collection(name: string) { return new FakeCollection(this, name); }
  async runTransaction<T>(run: (tx: FakeTx) => Promise<T>) {
    const tx = new FakeTx(this);
    const result = await run(tx);
    tx.commit();
    return result;
  }
}
class FakeTx {
  private writes: Array<() => void> = [];
  constructor(readonly db: FakeDb) {}
  async get(ref: FakeRef) {
    const data = this.db.docs.get(ref.path);
    return {exists: data !== undefined, data: () => structuredClone(data)};
  }
  create(ref: FakeRef, value: Doc) {
    this.writes.push(() => {
      if (this.db.docs.has(ref.path)) throw new Error("duplicate create");
      this.db.docs.set(ref.path, structuredClone(value));
    });
  }
  set(ref: FakeRef, value: Doc) {
    this.writes.push(() => this.db.docs.set(ref.path, structuredClone(value)));
  }
  commit() { for (const write of this.writes) write(); }
}

const employee: SalesPrincipal = {uid: "admin-1", roles: ["admin"]};
const support: SalesPrincipal = {uid: "support-1", roles: ["support"]};
function fixture() {
  const db = new FakeDb();
  db.docs.set("organizers/org-1", {name: "Example Host", cityName: "Delhi"});
  const deps: SalesServiceDeps = {
    firestore: () => db as unknown as FirebaseFirestore.Firestore,
    now: () => new Date("2026-09-28T00:00:00.000Z"),
  };
  return {db, deps};
}
const create = {organizerId: "org-1", requestId: "req-create-0001"};

test("requires current administrator authority and canonical organizer", async () => {
  const {db, deps} = fixture();
  await assert.rejects(executeSalesAction(support, "hosts.create", create, deps),
    (error: unknown) => error instanceof HttpsError && error.code === "permission-denied");
  assert.equal(db.docs.size, 1);
  await assert.rejects(executeSalesAction(employee, "hosts.create",
    {...create, organizerId: "missing"}, deps),
  (error: unknown) => error instanceof HttpsError && error.code === "not-found");
});

test("create is private, idempotent, and rejects changed material", async () => {
  const {db, deps} = fixture();
  const first = await executeSalesAction(employee, "hosts.create", create, deps);
  assert.equal((first.account as Doc).revision, 1);
  assert.equal(db.docs.get("organizers/org-1")?.name, "Example Host");
  assert.equal(db.docs.get("organizerSalesAccounts/org-1")?.classification,
    "sales_private");
  const replay = await executeSalesAction(employee, "hosts.create", create, deps);
  assert.deepEqual(replay, first);
  await assert.rejects(executeSalesAction(employee, "hosts.create",
    {...create, organizerId: "org-2"}, deps),
  (error: unknown) => error instanceof HttpsError && error.code === "already-exists");
  assert.equal([...db.docs.keys()].filter((key) => key.startsWith("adminAuditLogs/")).length, 1);
});

test("revision conflict and strict nested payload rejection", async () => {
  const {deps} = fixture();
  await executeSalesAction(employee, "hosts.create", create, deps);
  await assert.rejects(executeSalesAction(employee, "hosts.update", {
    organizerId: "org-1", requestId: "req-update-0001", expectedRevision: 0,
    patch: {summary: "Reviewed"},
  }, deps), (error: unknown) => error instanceof HttpsError && error.code === "aborted");
  await assert.rejects(executeSalesAction(employee, "hosts.update", {
    organizerId: "org-1", requestId: "req-update-0002", expectedRevision: 1,
    patch: {summary: "Reviewed", publicVisibility: true},
  }, deps), (error: unknown) => error instanceof HttpsError && error.code === "invalid-argument");
});

test("delegated action replay cannot cross client or delegation identity", async () => {
  const {deps} = fixture();
  const scoped: SalesPrincipal = {...employee, clientId: "client-1",
    delegationId: "grant-1", organizerIds: ["org-1"], allowedActions: ["hosts.create"]};
  const delegatedDeps: SalesServiceDeps = {...deps,
    authorizeInTransaction: async () => undefined,
    authorizeRead: async () => undefined};
  await executeSalesAction(scoped, "hosts.create", create, delegatedDeps);
  await assert.rejects(executeSalesAction({...scoped, delegationId: "grant-2"},
    "hosts.create", create, delegatedDeps),
  (error: unknown) => error instanceof HttpsError && error.code === "permission-denied");
  await assert.rejects(executeSalesAction({...scoped, organizerIds: []},
    "hosts.create", create, delegatedDeps),
  (error: unknown) => error instanceof HttpsError && error.code === "permission-denied");
});

test("revoked delegation inside transaction blocks replay and new writes", async () => {
  const {db, deps} = fixture();
  const scoped: SalesPrincipal = {...employee, clientId: "client-1",
    clientAuthUid: "service-1", delegationId: "grant-1",
    organizerIds: ["org-1"], allowedActions: ["hosts.create", "hosts.update"]};
  let active = true;
  const delegatedDeps: SalesServiceDeps = {...deps,
    authorizeInTransaction: async () => {
      if (!active) throw new HttpsError("permission-denied", "Delegation revoked.");
    },
    authorizeRead: async () => undefined};
  await executeSalesAction(scoped, "hosts.create", create, delegatedDeps);
  active = false;
  await assert.rejects(executeSalesAction(scoped, "hosts.create", create,
    delegatedDeps), (error: unknown) => error instanceof HttpsError &&
      error.code === "permission-denied");
  await assert.rejects(executeSalesAction(scoped, "hosts.update", {
    organizerId: "org-1", requestId: "req-update-0003", expectedRevision: 1,
    patch: {summary: "Should not commit"},
  }, delegatedDeps), (error: unknown) => error instanceof HttpsError &&
      error.code === "permission-denied");
  assert.equal(db.docs.get("organizerSalesAccounts/org-1")?.revision, 1);
});
