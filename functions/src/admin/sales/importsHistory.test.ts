import assert from "node:assert/strict";
import test from "node:test";
import {createHash} from "node:crypto";
import {applySalesImportHistory, listSalesImportHistory,
  previewSalesImportHistory, type HistoryPacket} from "./importsHistory";
import type {SalesPrincipal} from "./types";

type Doc = Record<string, unknown>;
const now = "2026-09-28T00:00:00.000Z";
const owner: SalesPrincipal = {uid: "owner", roles: ["adminOwner"]};
const employee: SalesPrincipal = {uid: "employee", roles: ["admin"]};
const sourceId = "source-a";
const sourceRowId = "row-1";
const sourceContentHash = "a".repeat(64);
const digest = (value: string) => createHash("sha256")
  .update(value).digest("hex");

class Ref {
  constructor(readonly db: Db, readonly path: string) {}
  get id() {
    return this.path.split("/").at(-1) ?? "";
  }
  async get() {
    return this.db.snapshot(this);
  }
}
class Query {
  private field = "";
  private value = "";
  private after = "";
  private cap = 100;
  constructor(readonly db: Db, readonly path: string) {}
  where(field: string, _op: string, value: string) {
    this.field = field; this.value = value; return this;
  }
  orderBy(field: string) {
    assert.equal(field, "__name__");
    return this;
  }
  startAfter(cursor: string) {
    this.after = cursor; return this;
  }
  limit(cap: number) {
    this.cap = cap; return this;
  }
  doc(id: string) {
    return new Ref(this.db, `${this.path}/${id}`);
  }
  async get() {
    return this.db.query(this);
  }
  matches(doc: Doc) {
    return !this.field || doc[this.field] === this.value;
  }
  get cursor() {
    return this.after;
  }
  get limitCount() {
    return this.cap;
  }
}
class Db {
  docs = new Map<string, Doc>();
  collection(path: string) {
    return new Query(this, path);
  }
  snapshot(ref: Ref) {
    const value = this.docs.get(ref.path);
    return {exists: value !== undefined,
      data: () => value === undefined ? undefined : structuredClone(value)};
  }
  query(query: Query) {
    const docs = [...this.docs].filter(([path, value]) =>
      path.startsWith(`${query.path}/`) && query.matches(value) &&
      path.slice(query.path.length + 1) > query.cursor)
      .sort(([a], [b]) => a.localeCompare(b))
      .slice(0, query.limitCount)
      .map(([path, value]) => ({id: path.split("/").at(-1)!,
        data: () => structuredClone(value)}));
    return {docs};
  }
}
class Tx {
  private reads = new Map<string, string>();
  private writes: Array<{ref: Ref; value: Doc}> = [];
  constructor(readonly db: Db) {}
  async get(ref: Ref) {
    assert.equal(this.writes.length, 0, "all reads before writes");
    const value = this.db.snapshot(ref);
    this.reads.set(ref.path, JSON.stringify(value.data()));
    return value;
  }
  create(ref: Ref, value: Doc) {
    this.writes.push({ref, value});
  }
  commit() {
    for (const [path, prior] of this.reads) {
      assert.equal(JSON.stringify(this.db.snapshot(
        new Ref(this.db, path)).data()),
      prior, "stale transaction read");
    }
    const next = new Map(this.db.docs);
    for (const {ref, value} of this.writes) {
      assert.equal(next.has(ref.path), false, "conflicting create");
      next.set(ref.path, structuredClone(value));
    }
    this.db.docs = next;
  }
}
function fixture() {
  const db = new Db();
  db.docs.set(`salesImportRows/${digest(`${sourceId}\u0000${sourceRowId}`)}`, {
    sourceId, sourceRowId, sourceContentHash,
    mappingVersion: "review-v1", importId: "import-a", organizerId: "org-a",
    disposition: "created", originalCells: [
      {column: "First touch", value: "2026-04-01T10:00:00Z"},
      {column: "Last response / signal", value: "Historical reply noted"},
      {column: "Score /100", value: "72"}],
  });
  db.docs.set("salesImportJobs/import-a", {sourceId,
    contentHash: sourceContentHash, mappingVersion: "review-v1",
    status: "applied"});
  db.docs.set("organizerSalesAccounts/org-a", {classification: "sales_private",
    researchStatus: "needs_research", suppressionStatus: "clear", revision: 1});
  return db;
}
function packet(): HistoryPacket {
  return {sourceId, contentHash: sourceContentHash,
    mappingVersion: "review-v1", promotionVersion: "promotion-v1",
    rows: [{importId: "import-a", sourceRowId, organizerId: "org-a",
      disposition: "promoted", reason: "Reviewed historical source cells",
      entries: [{kind: "activity", sourceColumn: "First touch",
        sourceValue: "2026-04-01T10:00:00Z",
        occurredAt: "2026-04-01T10:00:00.000Z",
        dateSourceColumn: "First touch",
        dateSourceValue: "2026-04-01T10:00:00Z"},
      {kind: "observation", sourceColumn: "Last response / signal",
        sourceValue: "Historical reply noted", occurredAt: null,
        dateSourceColumn: null, dateSourceValue: null},
      {kind: "benchmark", sourceColumn: "Score /100", sourceValue: "72",
        occurredAt: null, dateSourceColumn: null, dateSourceValue: null}]}]};
}
const firestore = (db: Db) => db as unknown as FirebaseFirestore.Firestore;
async function apply(db: Db, input = packet(), previewHash?: string) {
  const review = previewHash ?? (await previewSalesImportHistory(firestore(db),
    owner, input)).previewHash as string;
  const tx = new Tx(db);
  const result = await applySalesImportHistory(tx as unknown as
    FirebaseFirestore.Transaction, firestore(db), owner,
  {...input, requestId: "history-request-1", previewHash: review}, now);
  tx.commit();
  return result;
}

test("reviewed history is private, immutable and never current send or fit",
  async () => {
    const db = fixture();
    const result = await apply(db);
    assert.equal(result.recordsCreated, 3);
    const records = [...db.docs].filter(([path]) =>
      path.startsWith("salesImportHistoryRecords/")).map(([, value]) => value);
    assert.equal(records.length, 3);
    assert.ok(records.every((item) => item.providerConfirmed === false &&
    item.currentFitAuthority === false && item.contactAuthority === false &&
    item.sendAuthority === false));
    const observation = records.find((item) => item.kind === "observation");
    assert.equal(observation?.occurredAt,
      null);
    assert.equal(db.docs.get("organizerSalesAccounts/org-a")?.revision, 1);
    assert.equal([...db.docs.keys()].some((path) =>
      path.startsWith("salesActivities/")), false);
    const listed = await listSalesImportHistory(firestore(db), employee,
      {organizerId: "org-a", limit: 2});
    assert.equal((listed.records as unknown[]).length, 2);
    assert.ok(listed.nextCursor);
  });

test("identical review duplicates; conflicting reinterpretation closes",
  async () => {
    const db = fixture();
    await apply(db);
    const duplicate = await apply(db);
    assert.equal(duplicate.recordsCreated, 0);
    assert.equal((duplicate.rows as Array<{status: string}>)[0].status,
      "duplicate");
    const changed = packet();
    changed.rows[0].entries[1].kind = "activity";
    await assert.rejects(previewSalesImportHistory(
      firestore(db), owner, changed),
    /conflicting reviewed history mapping/);
  });

test("stale preview, account restriction and source mismatch fail closed",
  async () => {
    const db = fixture();
    const input = packet();
    const preview = await previewSalesImportHistory(
      firestore(db), owner, input);
    db.docs.get("organizerSalesAccounts/org-a")!.revision = 2;
    await assert.rejects(apply(db, input, preview.previewHash as string),
      /changed since the reviewed preview/);
    db.docs.get("organizerSalesAccounts/org-a")!.researchStatus = "archived";
    await assert.rejects(previewSalesImportHistory(firestore(db), owner, input),
      /archived or privacy restricted/);
    db.docs.get("organizerSalesAccounts/org-a")!.researchStatus =
      "needs_research";
    db.docs.get("organizerSalesAccounts/org-a")!.suppressionStatus = "held";
    await assert.rejects(previewSalesImportHistory(firestore(db), owner, input),
      /archived or privacy restricted/);
    db.docs.get("organizerSalesAccounts/org-a")!.suppressionStatus = "clear";
    input.rows[0].entries[1].sourceValue = "Invented content";
    await assert.rejects(previewSalesImportHistory(firestore(db), owner, input),
      /does not match preserved source cells/);
  });

test("unknown dates stay null, ambiguous dates cannot be promoted as exact",
  async () => {
    const db = fixture();
    const input = packet();
    input.rows[0].entries[0].occurredAt = null;
    input.rows[0].entries[0].dateSourceColumn = null;
    input.rows[0].entries[0].dateSourceValue = null;
    await apply(db, input);
    const first = [...db.docs.values()].find((value) =>
      value.kind === "activity");
    assert.equal(first?.occurredAt, null);
    const bad = packet();
    bad.rows[0].entries[0].dateSourceValue = "04/01/2026";
    await assert.rejects(previewSalesImportHistory(firestore(fixture()), owner,
      bad), /exact source timestamp/);
  });

test("non-owner, concurrent workers and invalid source identity cannot write",
  async () => {
    const db = fixture();
    await assert.rejects(previewSalesImportHistory(firestore(db), employee,
      packet()), /Admin Owner/);
    const bad = packet();
    bad.rows[0].organizerId = "org-other";
    await assert.rejects(previewSalesImportHistory(firestore(db), owner, bad),
      /proof is missing or changed/);
    const input = packet();
    const review = await previewSalesImportHistory(firestore(db), owner, input);
    const a = new Tx(db); const b = new Tx(db);
    await applySalesImportHistory(a as unknown as FirebaseFirestore.Transaction,
      firestore(db), owner, {...input, requestId: "request-a",
        previewHash: review.previewHash as string}, now);
    await applySalesImportHistory(b as unknown as FirebaseFirestore.Transaction,
      firestore(db), owner, {...input, requestId: "request-b",
        previewHash: review.previewHash as string}, now);
    a.commit();
    assert.throws(() => b.commit(), /stale transaction read/);
  });
