import assert from "node:assert/strict";
import test from "node:test";
import {applySalesImport, previewSalesImport} from "./imports";
import type {ImportPacket} from "./imports";
import type {SalesPrincipal} from "./types";

type Doc = Record<string, unknown>;
class Ref {
  constructor(readonly db: Db, readonly path: string) {}
  collection(name: string) {
    return new Collection(this.db, `${this.path}/${name}`);
  }
  async get() {
    return this.db.snapshot(this);
  }
}
class Collection {
  constructor(readonly db: Db, readonly path: string) {}
  doc(id: string) {
    return new Ref(this.db, `${this.path}/${id}`);
  }
}
class Db {
  docs = new Map<string, Doc>();
  collection(name: string) {
    return new Collection(this, name);
  }
  snapshot(ref: Ref) {
    const data = this.docs.get(ref.path);
    return {ref, exists: data !== undefined, data: () => structuredClone(data)};
  }
}
class Tx {
  writes: Array<() => void> = [];
  constructor(readonly db: Db) {}
  async get(ref: Ref) {
    assert.equal(this.writes.length, 0, "all Firestore reads precede writes");
    return this.db.snapshot(ref);
  }
  create(ref: Ref, value: Doc) {
    this.writes.push(() => {
      assert.equal(this.db.docs.has(ref.path), false);
      this.db.docs.set(ref.path, structuredClone(value));
    });
  }
  update(ref: Ref, patch: Doc) {
    this.writes.push(() => {
      const current = this.db.docs.get(ref.path);
      assert.ok(current);
      this.db.docs.set(ref.path, {...current, ...structuredClone(patch)});
    });
  }
  commit() {
    for (const write of this.writes) write();
  }
}

const employee: SalesPrincipal = {uid: "employee-1", roles: ["admin"]};
const packet: ImportPacket = {sourceId: "source-a", contentHash: "a".repeat(64),
  mappingVersion: "review-v1", rows: [
    {sourceRowId: "cohort-a:1", organizerId: "org-1", name: "Example",
      researchStatus: "new", cohortIds: ["cohort-a"]},
    {sourceRowId: "cohort-b:2", organizerId: "org-1", name: "Example",
      researchStatus: "new", cohortIds: ["cohort-b"]},
  ]};

test("same organizer creates once and retains both source rows", async () => {
  const db = new Db();
  db.docs.set("organizers/org-1", {name: "Example"});
  const firestore = db as unknown as FirebaseFirestore.Firestore;
  const preview = await previewSalesImport(firestore, employee, packet);
  assert.deepEqual(preview.counts, {created: 1, matched: 1, duplicate: 0,
    unresolved: 0, rejected: 0});
  const tx = new Tx(db);
  const result = await applySalesImport(
    tx as unknown as FirebaseFirestore.Transaction,
    firestore, employee, {...packet, requestId: "request-0001",
      previewHash: preview.previewHash as string}, "2026-09-28T00:00:00.000Z");
  tx.commit();
  assert.deepEqual(db.docs.get("organizerSalesAccounts/org-1")?.cohortIds,
    ["cohort-a", "cohort-b"]);
  assert.equal(result.counts && (result.counts as Doc).matched, 1);
  const lineagePaths = [...db.docs.keys()].filter((path) =>
    path.startsWith("salesImportRows/"));
  assert.equal(lineagePaths.length, 2);
  const lineageCohorts = [...db.docs.values()]
    .filter((value) => value.sourceRowId)
    .map((value) => value.cohortIds).filter(Boolean);
  assert.deepEqual(lineageCohorts,
    [["cohort-a"], ["cohort-a"], ["cohort-b"], ["cohort-b"]]);
});

test("existing account unions cohorts and rejects stale previews", async () => {
  const db = new Db();
  db.docs.set("organizers/org-1", {name: "Example"});
  db.docs.set("organizerSalesAccounts/org-1", {classification: "sales_private",
    revision: 4, cohortIds: ["original"], summary: "keep", createdAt: "old",
    updatedAt: "old", updatedBy: "employee-2"});
  const firestore = db as unknown as FirebaseFirestore.Firestore;
  const preview = await previewSalesImport(firestore, employee, packet);
  db.docs.get("organizerSalesAccounts/org-1")!.revision = 5;
  await assert.rejects(applySalesImport(
    new Tx(db) as unknown as FirebaseFirestore.Transaction,
    firestore, employee, {...packet, requestId: "request-0002",
      previewHash: preview.previewHash as string}, "2026-09-28T00:00:00.000Z"),
  /changed since the reviewed preview/);
  db.docs.get("organizerSalesAccounts/org-1")!.revision = 4;
  const tx = new Tx(db);
  await applySalesImport(tx as unknown as FirebaseFirestore.Transaction,
    firestore, employee, {...packet, requestId: "request-0003",
      previewHash: preview.previewHash as string}, "2026-09-28T00:00:00.000Z");
  tx.commit();
  assert.deepEqual(db.docs.get("organizerSalesAccounts/org-1")?.cohortIds,
    ["original", "cohort-a", "cohort-b"]);
  assert.equal(db.docs.get("organizerSalesAccounts/org-1")?.revision, 5);
  assert.equal(db.docs.get("organizerSalesAccounts/org-1")?.summary, "keep");
});

test("new account rejects 31 cohorts before any write", async () => {
  const db = new Db();
  db.docs.set("organizers/org-1", {name: "Example"});
  const wide = structuredClone(packet);
  wide.rows[0].cohortIds = Array.from({length: 30}, (_, index) =>
    `cohort-${index}`);
  wide.rows[1].cohortIds = ["cohort-extra"];
  const firestore = db as unknown as FirebaseFirestore.Firestore;
  const preview = await previewSalesImport(firestore, employee, wide);
  const tx = new Tx(db);
  await assert.rejects(applySalesImport(
    tx as unknown as FirebaseFirestore.Transaction, firestore, employee,
    {...wide, requestId: "request-0004",
      previewHash: preview.previewHash as string},
    "2026-09-28T00:00:00.000Z"), /cohort limit exceeded/);
  assert.equal(tx.writes.length, 0);
  assert.equal(db.docs.has("organizerSalesAccounts/org-1"), false);
});

test("new and existing accounts accept 30; existing rejects 31", async () => {
  const wide = structuredClone(packet);
  wide.rows[0].cohortIds = Array.from({length: 29}, (_, index) =>
    `cohort-${index}`);
  wide.rows[1].cohortIds = ["cohort-29"];
  const fresh = new Db();
  fresh.docs.set("organizers/org-1", {name: "Example"});
  const freshStore = fresh as unknown as FirebaseFirestore.Firestore;
  const freshPreview = await previewSalesImport(freshStore, employee, wide);
  const freshTx = new Tx(fresh);
  await applySalesImport(freshTx as unknown as FirebaseFirestore.Transaction,
    freshStore, employee, {...wide, requestId: "request-0005",
      previewHash: freshPreview.previewHash as string},
    "2026-09-28T00:00:00.000Z");
  freshTx.commit();
  assert.equal((fresh.docs.get("organizerSalesAccounts/org-1")?.cohortIds as
    string[]).length, 30);

  const existing = new Db();
  existing.docs.set("organizers/org-1", {name: "Example"});
  existing.docs.set("organizerSalesAccounts/org-1", {
    classification: "sales_private", revision: 1,
    cohortIds: Array.from({length: 29}, (_, index) => `prior-${index}`),
  });
  const existingStore = existing as unknown as FirebaseFirestore.Firestore;
  const oneMore = structuredClone(packet);
  oneMore.rows[0].cohortIds = ["cohort-29"];
  oneMore.rows[1].cohortIds = [];
  const boundaryPreview = await previewSalesImport(existingStore, employee,
    oneMore);
  const boundaryTx = new Tx(existing);
  await applySalesImport(boundaryTx as unknown as FirebaseFirestore.Transaction,
    existingStore, employee, {...oneMore, requestId: "request-0006",
      previewHash: boundaryPreview.previewHash as string},
    "2026-09-28T00:00:00.000Z");
  boundaryTx.commit();
  assert.equal((existing.docs.get("organizerSalesAccounts/org-1")?.cohortIds as
    string[]).length, 30);

  const over = structuredClone(packet);
  over.rows[0].sourceRowId = "cohort-c:3";
  over.rows[1].sourceRowId = "cohort-d:4";
  over.rows[0].cohortIds = ["cohort-30"];
  over.rows[1].cohortIds = [];
  const overPreview = await previewSalesImport(existingStore, employee, over);
  const overTx = new Tx(existing);
  await assert.rejects(applySalesImport(
    overTx as unknown as FirebaseFirestore.Transaction, existingStore, employee,
    {...over, requestId: "request-0007",
      previewHash: overPreview.previewHash as string},
    "2026-09-28T00:00:00.000Z"), /cohort limit exceeded/);
  assert.equal(overTx.writes.length, 0);
});
