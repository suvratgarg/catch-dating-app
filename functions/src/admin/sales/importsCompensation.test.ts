import assert from "node:assert/strict";
import test from "node:test";
import {newSalesAccount} from "./account";
import {applySalesImport, previewSalesImport,
  type ImportPacket} from "./imports";
import {applyImportCompensation, previewImportCompensation} from
  "./importsCompensation";
import type {SalesPrincipal} from "./types";

type Doc = Record<string, unknown>;
const now = "2026-09-28T00:00:00.000Z";
const owner: SalesPrincipal = {uid: "owner-1", roles: ["adminOwner"]};
const employee: SalesPrincipal = {uid: "employee-1", roles: ["admin"]};

class Ref {
  constructor(readonly db: Db, readonly path: string) {}
  get id() {
    return this.path.split("/").at(-1) ?? "";
  }
  collection(name: string) {
    return new Collection(this.db, `${this.path}/${name}`);
  }
  async get() {
    return this.db.snapshot(this);
  }
}
class Query {
  constructor(readonly db: Db, readonly path: string,
    readonly field: string | null = null, readonly value: unknown = null,
    readonly cap = Infinity) {}
  where(field: string, operator: string, value: unknown) {
    assert.equal(operator, "==");
    return new Query(this.db, this.path, field, value, this.cap);
  }
  limit(cap: number) {
    return new Query(this.db, this.path, this.field,
      this.value, cap);
  }
  async get() {
    return this.db.query(this);
  }
}
class Collection extends Query {
  constructor(db: Db, path: string) {
    super(db, path);
  }
  doc(id: string) {
    return new Ref(this.db, `${this.path}/${id}`);
  }
}
class Db {
  docs = new Map<string, Doc>();
  doc(path: string) {
    return new Ref(this, path);
  }
  collection(name: string) {
    return new Collection(this, name);
  }
  snapshot(ref: Ref) {
    const row = this.docs.get(ref.path);
    return {ref, exists: row !== undefined, data: () =>
      row === undefined ? undefined : structuredClone(row)};
  }
  query(query: Query) {
    const docs = [...this.docs.keys()].filter((path) =>
      path.startsWith(`${query.path}/`) &&
      !path.slice(query.path.length + 1).includes("/"))
      .map((path) => this.snapshot(new Ref(this, path)))
      .filter((snap) => query.field === null ||
        query.field.split(".").reduce<unknown>((value, part) =>
          value && typeof value === "object" ?
            (value as Doc)[part] : undefined, snap.data()) === query.value)
      .slice(0, query.cap);
    return {size: docs.length, docs};
  }
}
class Tx {
  private readonly reads = new Map<string, string>();
  private readonly writes: Array<{kind: "create" | "update" | "delete" |
    "set";
    ref: Ref; value: Doc}> = [];
  constructor(readonly db: Db) {}
  async get(ref: Ref | Query) {
    assert.equal(this.writes.length, 0, "all reads precede writes");
    const snapshot = ref instanceof Ref ? this.db.snapshot(ref) :
      this.db.query(ref);
    this.reads.set(ref.path + (ref instanceof Query ?
      `:${ref.field}:${String(ref.value)}:${ref.cap}` : ""),
    JSON.stringify(snapshot));
    return snapshot;
  }
  create(ref: Ref, value: Doc) {
    this.writes.push({kind: "create", ref, value});
  }
  update(ref: Ref, value: Doc) {
    this.writes.push({kind: "update", ref, value});
  }
  delete(ref: Ref) {
    this.writes.push({kind: "delete", ref, value: {}});
  }
  set(ref: Ref, value: Doc) {
    this.writes.push({kind: "set", ref, value});
  }
  commit() {
    for (const [key, prior] of this.reads) {
      const [path, field, value, cap] = key.split(":");
      const current = field === undefined ? this.db.snapshot(new Ref(this.db,
        path)) : this.db.query(new Query(this.db, path, field === "null" ?
        null : field, value === "null" ? null : value, Number(cap)));
      assert.equal(JSON.stringify(current), prior, "stale transaction read");
    }
    const staged = new Map(this.db.docs);
    for (const write of this.writes) {
      const current = staged.get(write.ref.path);
      if (write.kind === "delete") {
        staged.delete(write.ref.path);
        continue;
      }
      if (write.kind === "create") assert.equal(current, undefined);
      if (write.kind === "update") assert.ok(current);
      staged.set(write.ref.path, write.kind === "set" &&
        write.ref.path === "salesFitQueueMeta/current" ?
        {...write.value, generation: Number(current?.generation ?? 0) + 1} :
        write.kind === "create" || write.kind === "set" ?
          structuredClone(write.value) :
          {...current, ...structuredClone(write.value)});
    }
    this.db.docs = staged;
  }
}

function packet(source = "source-a", cohorts = ["cohort-a"]): ImportPacket {
  return {sourceId: source, contentHash: "a".repeat(64),
    mappingVersion: "review-v1", rows: [{sourceRowId: `${source}:1`,
      organizerId: "org-1", name: "Example", researchStatus: "new",
      cohortIds: cohorts}]};
}
async function importPacket(db: Db, source = "source-a",
  cohorts = ["cohort-a"], requestId = "request-0001") {
  const data = packet(source, cohorts);
  const firestore = db as unknown as FirebaseFirestore.Firestore;
  const preview = await previewSalesImport(firestore, employee, data);
  const tx = new Tx(db);
  const result = await applySalesImport(tx as unknown as
    FirebaseFirestore.Transaction, firestore, employee,
  {...data, requestId, previewHash: preview.previewHash as string}, now);
  tx.commit();
  return result.importId as string;
}
function prepared() {
  const db = new Db();
  db.docs.set("organizers/org-1", {name: "Example"});
  return db;
}
async function preview(db: Db, importId: string,
  principal = owner) {
  return previewImportCompensation(db as unknown as
    FirebaseFirestore.Firestore, principal, {importId, organizerId: "org-1"});
}
async function apply(db: Db, importId: string, previewHash: string,
  requestId = "compensation-0001") {
  const tx = new Tx(db);
  const result = await applyImportCompensation(tx as unknown as
    FirebaseFirestore.Transaction, db as unknown as
    FirebaseFirestore.Firestore, owner, {importId, organizerId: "org-1",
      previewHash, requestId, reason: "Reviewed source correction"}, now);
  tx.commit();
  return result;
}

test("pristine imported companion archives with outreach held " +
  "and lineage intact", async () => {
  const db = prepared();
  const importId = await importPacket(db);
  db.docs.set("salesFitQueueEntries/org-1", {organizerId: "org-1"});
  const plan = await preview(db, importId);
  assert.equal(plan.mode, "archive_companion");
  const result = await apply(db, importId, plan.previewHash as string);
  assert.equal(result.status, "compensated");
  assert.equal(db.docs.get("organizerSalesAccounts/org-1")?.researchStatus,
    "archived");
  assert.equal(db.docs.get("organizerSalesAccounts/org-1")?.suppressionStatus,
    "held");
  assert.ok(db.docs.has("organizers/org-1"));
  assert.ok(db.docs.has(`salesImportJobs/${importId}`));
  assert.equal(db.docs.has("salesFitQueueEntries/org-1"), false);
  assert.equal(db.docs.get("salesFitQueueMeta/current")?.generation, 2);
  assert.equal([...db.docs.keys()].filter((path) =>
    path.startsWith("salesImportCompensations/")).length, 1);
  const repeat = await apply(db, importId, plan.previewHash as string,
    "compensation-0002");
  assert.equal(repeat.status, "already_compensated");
});

test("later unrelated edits retain content while only owned cohorts leave",
  async () => {
    const db = prepared();
    const importId = await importPacket(db);
    const account = db.docs.get("organizerSalesAccounts/org-1")!;
    account.summary = "Later employee note";
    account.revision = 2;
    const plan = await preview(db, importId);
    assert.equal(plan.mode, "remove_cohorts");
    await apply(db, importId, plan.previewHash as string);
    const corrected = db.docs.get("organizerSalesAccounts/org-1")!;
    assert.equal(corrected.summary, "Later employee note");
    assert.deepEqual(corrected.cohortIds, []);
    assert.equal(corrected.researchStatus, "needs_research");
  });

test("old imports without effects and later sibling membership fail closed",
  async () => {
    const db = prepared();
    const importId = await importPacket(db);
    const job = db.docs.get(`salesImportJobs/${importId}`)!;
    const effects = job.accountEffects;
    delete job.accountEffects;
    assert.deepEqual((await preview(db, importId)).blockers,
      ["import_proof_missing"]);
    assert.equal([...db.docs.keys()].filter((path) =>
      path.startsWith("salesImportCompensations/")).length, 0);
    job.accountEffects = effects;
    await importPacket(db, "source-b", ["cohort-a"], "request-0002");
    const blocked = await preview(db, importId);
    assert.ok((blocked.blockers as string[])
      .includes("sibling_import_membership"));
    assert.ok((blocked.blockers as string[])
      .includes("cohort_changed_since_import"));
  });

test("stale review and concurrent workers cannot both commit", async () => {
  const db = prepared();
  const importId = await importPacket(db);
  const plan = await preview(db, importId);
  db.docs.get("organizerSalesAccounts/org-1")!.summary = "new note";
  await assert.rejects(apply(db, importId, plan.previewHash as string),
    /changed since review/);
  const fresh = await preview(db, importId);
  const first = new Tx(db);
  const second = new Tx(db);
  const payload = {importId, organizerId: "org-1",
    previewHash: fresh.previewHash as string,
    requestId: "compensation-0001", reason: "Reviewed source correction"};
  await applyImportCompensation(first as unknown as
    FirebaseFirestore.Transaction, db as unknown as
    FirebaseFirestore.Firestore, owner, payload, now);
  await applyImportCompensation(second as unknown as
    FirebaseFirestore.Transaction, db as unknown as
    FirebaseFirestore.Firestore, owner, {...payload,
      requestId: "compensation-0002"}, now);
  first.commit();
  assert.throws(() => second.commit(), /stale transaction read/);
});

test("business work prevents archive; non-owner cannot preview", async () => {
  const db = prepared();
  const importId = await importPacket(db);
  db.docs.set("salesTasks/task-1", {organizerId: "org-1"});
  const plan = await preview(db, importId);
  assert.equal(plan.mode, "remove_cohorts");
  assert.ok((plan.blockers as string[]).length === 0);
  await assert.rejects(preview(db, importId, employee),
    /Admin Owner authority/);
});

test("existing account removes only import-added membership", async () => {
  const db = prepared();
  db.docs.set("organizerSalesAccounts/org-1", {...newSalesAccount(
    "org-1", {name: "Example"}, employee.uid, now),
  revision: 4, cohortIds: ["original"], summary: "kept"});
  const importId = await importPacket(db);
  const plan = await preview(db, importId);
  assert.equal(plan.mode, "remove_cohorts");
  await apply(db, importId, plan.previewHash as string);
  assert.deepEqual(db.docs.get("organizerSalesAccounts/org-1")?.cohortIds,
    ["original"]);
  assert.equal(db.docs.get("organizerSalesAccounts/org-1")?.summary, "kept");
});
