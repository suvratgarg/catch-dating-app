/* eslint-disable max-len */
import {strict as assert} from "node:assert";
import {test} from "node:test";
import type {SalesPrincipal} from "../sales/types";
import {type SalesPrivacyInventory} from "./inventory";
import {assertSalesPrivacyOpen, assertSalesPrivacyOpenRead,
  privacyHash} from "./model";
import {applySalesPrivacyBatch, previewSalesPrivacyPlan,
  restrictSalesOrganizer, reviewSalesPrivacyPlan,
  reviewSalesPrivacyPolicy, type PrivacyDeps} from "./service";

type Data = Record<string, unknown>;
class FakeRef {
  constructor(readonly db: FakeDb, readonly path: string) {}
  get id() {
    return this.path.split("/").at(-1)!;
  }
  async get() {
    return this.db.snapshot(this.path);
  }
  collection(name: string) {
    return new FakeCollection(this.db, `${this.path}/${name}`);
  }
}
class FakeCollection {
  constructor(readonly db: FakeDb, readonly path: string) {}
  doc(id: string) {
    return new FakeRef(this.db, `${this.path}/${id}`);
  }
  where(field: string, _op: string, value: unknown) {
    return new FakeQuery(this.db, this.path, field, value);
  }
}
class FakeQuery {
  private bound = 1000;
  constructor(readonly db: FakeDb, readonly path: string,
    readonly field: string, readonly value: unknown) {}
  limit(limit: number) {
    this.bound = limit; return this;
  }
  async get() {
    return {docs: [...this.db.docs.entries()].filter(([path, data]) =>
      path.startsWith(`${this.path}/`) && path.split("/").length ===
    this.path.split("/").length + 1 && data[this.field] === this.value)
      .slice(0, this.bound).map(([path]) => this.db.snapshot(path))};
  }
}
class FakeTx {
  private operations: Array<() => void> = [];
  constructor(readonly db: FakeDb) {}
  get(ref: FakeRef | FakeQuery) {
    return ref.get();
  }
  create(ref: FakeRef, value: Data) {
    this.operations.push(() => {
      if (this.db.docs.has(ref.path)) throw new Error("already exists");
      this.db.docs.set(ref.path, structuredClone(value));
    });
  }
  set(ref: FakeRef, value: Data) {
    this.operations.push(() =>
      this.db.docs.set(ref.path, structuredClone(value)));
  }
  update(ref: FakeRef, value: Data) {
    this.operations.push(() => {
      const current = this.db.docs.get(ref.path);
      if (!current) throw new Error("missing update target");
      this.db.docs.set(ref.path, {...current, ...structuredClone(value)});
    });
  }
  delete(ref: FakeRef) {
    this.operations.push(() => this.db.docs.delete(ref.path));
  }
  commit() {
    for (const operation of this.operations) operation();
  }
}
class FakeDb {
  docs = new Map<string, Data>();
  collection(name: string) {
    return new FakeCollection(this, name);
  }
  doc(path: string) {
    return new FakeRef(this, path);
  }
  snapshot(path: string) {
    const data = this.docs.get(path);
    return {exists: Boolean(data), id: path.split("/").at(-1)!,
      ref: this.doc(path), data: () => data ? structuredClone(data) : undefined};
  }
  async runTransaction<T>(run: (tx: FakeTx) => Promise<T>): Promise<T> {
    const tx = new FakeTx(this);
    const result = await run(tx);
    tx.commit(); return result;
  }
}
const principal: SalesPrincipal = {uid: "owner-a", roles: ["adminOwner"]};
const at = "2026-09-28T10:00:00.000Z";
function deps(db = new FakeDb(), inventory?: SalesPrivacyInventory) {
  let authorized = true;
  const value: PrivacyDeps = {db: db as unknown as FirebaseFirestore.Firestore,
    now: () => new Date(at), authorizeOwner: async () => {
      if (!authorized) throw new Error("owner role revoked");
    }, ...(inventory ? {inventory: async () => inventory} : {})};
  return {db, value, revoke: () => {
    authorized = false;
  }};
}
function inventoryFor(db: FakeDb): SalesPrivacyInventory {
  const items = ["organizerSalesAccounts/org-a", "salesTasks/task-a",
    "salesHostSettlementAttestations/finance-a"].map((path) => ({path,
    contentHash: privacyHash(db.docs.get(path)),
    disposition: path.startsWith("salesHost") ?
      "retain_finance" as const : "delete" as const}));
  const blockers = [{code: "external_exports_unverified",
    fingerprint: "a".repeat(16)}];
  return {organizerId: "org-a", items, blockers, overflow: false,
    inventoryHash: privacyHash([items, blockers]), counts: {deletable: 2,
      retained: 1, unresolved: 1}};
}
async function preparedCase() {
  const db = new FakeDb();
  db.docs.set("organizerSalesAccounts/org-a", {schemaVersion: 1,
    classification: "sales_private", organizerId: "org-a", summary: "private"});
  db.docs.set("salesTasks/task-a", {schemaVersion: 1,
    classification: "sales_private", organizerId: "org-a", title: "private"});
  db.docs.set("salesHostSettlementAttestations/finance-a", {schemaVersion: 1,
    classification: "sales_private", organizerId: "org-a",
    settlementReference: "private"});
  const inventory = inventoryFor(db);
  const h = deps(db, inventory);
  await reviewSalesPrivacyPolicy(h.value, principal, {requestId: "policy-req-0001",
    expectedRevision: 0, sourceReference: "Reviewed internal policy",
    sourceHash: "b".repeat(64), financeReason: "Reconciliation remains open",
    auditReason: "Audit review remains open"});
  await restrictSalesOrganizer(h.value, principal, {organizerId: "org-a",
    requestId: "restrict-0001", reason: "Approved private processing hold"});
  const preview = await previewSalesPrivacyPlan(h.value, principal,
    {organizerId: "org-a"});
  const reviewed = await reviewSalesPrivacyPlan(h.value, principal,
    {organizerId: "org-a", requestId: "plan-review-0001",
      restrictionRevision: preview.restrictionRevision,
      expectedActivePlanId: preview.activePlanId, policyHash: preview.policyHash, inventoryHash: preview.inventoryHash});
  return {h, preview, reviewed};
}

test("restriction is permanent, idempotent only for exact request, and invalidates fit queue", async () => {
  const h = deps();
  const tx = new FakeTx(h.db);
  await assertSalesPrivacyOpen(tx as unknown as FirebaseFirestore.Transaction,
    h.value.db, "org-a");
  const input = {organizerId: "org-a", requestId: "restrict-0001",
    reason: "Owner-approved restriction"};
  const first = await restrictSalesOrganizer(h.value, principal, input);
  assert.equal(first.restriction.status, "restricted");
  assert.ok(h.db.docs.has("salesPrivacyRestrictions/org-a"));
  assert.ok(h.db.docs.has("salesFitQueueMeta/current"));
  await assert.rejects(assertSalesPrivacyOpenRead(h.value.db, "org-a"),
    /restricted/u);
  await assert.rejects(assertSalesPrivacyOpen(new FakeTx(h.db) as unknown as
    FirebaseFirestore.Transaction, h.value.db, "org-a"), /restricted/u);
  assert.deepEqual(await restrictSalesOrganizer(h.value, principal, input), first);
  await assert.rejects(restrictSalesOrganizer(h.value, principal, {...input,
    requestId: "restrict-0002"}), /already has/u);
});

test("reviewed policy and exact plan process bounded batches but retain finance and external blockers", async () => {
  const {h, preview, reviewed} = await preparedCase();
  assert.equal(preview.effectsApplied, false);
  assert.equal(reviewed.plan.itemCount, 3);
  const input = {organizerId: "org-a", planId: reviewed.plan.planId,
    requestId: "batch-req-0001", expectedCursor: 0};
  const result = await applySalesPrivacyBatch(h.value, principal, input);
  assert.equal(result.batch.status, "internal_processed_with_unresolved");
  assert.equal(result.batch.completeDeletion, false);
  assert.equal(result.batch.deletedCount, 2);
  assert.equal(result.batch.retainedCount, 1);
  assert.equal(h.db.docs.has("organizerSalesAccounts/org-a"), false);
  assert.equal(h.db.docs.has("salesTasks/task-a"), false);
  assert.equal(h.db.docs.has("salesHostSettlementAttestations/finance-a"), true);
  assert.deepEqual(await applySalesPrivacyBatch(h.value, principal, input), result);
});

test("stale source or owner revocation rolls back the entire batch", async () => {
  const {h, reviewed} = await preparedCase();
  h.db.docs.set("salesTasks/task-a", {...h.db.docs.get("salesTasks/task-a")!,
    title: "changed after review"});
  const input = {organizerId: "org-a", planId: reviewed.plan.planId,
    requestId: "batch-req-0001", expectedCursor: 0};
  await assert.rejects(applySalesPrivacyBatch(h.value, principal, input),
    /source changed/u);
  assert.ok(h.db.docs.has("organizerSalesAccounts/org-a"));
  assert.equal((h.db.docs.get(`salesPrivacyPlans/${reviewed.plan.planId}`) as Data)
    .cursor, 0);
  h.revoke();
  await assert.rejects(applySalesPrivacyBatch(h.value, principal, input),
    /revoked/u);
  assert.ok(h.db.docs.has("organizerSalesAccounts/org-a"));
});

test("a new other-host relationship aborts contact deletion after plan review", async () => {
  const h = deps();
  h.db.docs.set("salesContacts/contact-a", {organizerId: "org-a",
    contactId: "contact-a", displayName: "Shared Person"});
  h.db.docs.set("salesContactRelationships/relation-a", {
    organizerId: "org-a", contactId: "contact-a"});
  const items = ["salesContacts/contact-a",
    "salesContactRelationships/relation-a"].map((path) => ({path,
    contentHash: privacyHash(h.db.docs.get(path)), disposition: "delete" as const}));
  const blockers = [{code: "external_exports_unverified",
    fingerprint: "a".repeat(16)}];
  h.value.inventory = async () => ({organizerId: "org-a", items, blockers,
    overflow: false, inventoryHash: privacyHash([items, blockers]),
    counts: {deletable: 2, retained: 0, unresolved: 1}});
  await reviewSalesPrivacyPolicy(h.value, principal, {requestId: "policy-req-0001",
    expectedRevision: 0, sourceReference: "Reviewed internal policy",
    sourceHash: "b".repeat(64), financeReason: "Finance review open",
    auditReason: "Audit review open"});
  await restrictSalesOrganizer(h.value, principal, {organizerId: "org-a",
    requestId: "restrict-0001", reason: "Approved hold"});
  const preview = await previewSalesPrivacyPlan(h.value, principal,
    {organizerId: "org-a"});
  const reviewed = await reviewSalesPrivacyPlan(h.value, principal,
    {organizerId: "org-a", requestId: "plan-review-0001",
      restrictionRevision: preview.restrictionRevision,
      expectedActivePlanId: preview.activePlanId, policyHash: preview.policyHash, inventoryHash: preview.inventoryHash});
  h.db.docs.set("salesContactRelationships/relation-b", {
    organizerId: "org-b", contactId: "contact-a"});
  await assert.rejects(applySalesPrivacyBatch(h.value, principal,
    {organizerId: "org-a", planId: reviewed.plan.planId,
      requestId: "batch-req-0001", expectedCursor: 0}),
  /shared contact relationship changed/u);
  assert.ok(h.db.docs.has("salesContacts/contact-a"));
  assert.ok(h.db.docs.has("salesContactRelationships/relation-b"));
  assert.equal((h.db.docs.get(`salesPrivacyPlans/${reviewed.plan.planId}`) as Data)
    .cursor, 0);
});

test("stale plan can be explicitly superseded, while its old batch stays blocked", async () => {
  const {h, preview, reviewed} = await preparedCase();
  const originalReview = {organizerId: "org-a", requestId: "plan-review-0001",
    restrictionRevision: preview.restrictionRevision,
    expectedActivePlanId: preview.activePlanId,
    policyHash: preview.policyHash, inventoryHash: preview.inventoryHash};
  assert.deepEqual(await reviewSalesPrivacyPlan(h.value, principal,
    originalReview), reviewed);
  h.db.docs.set("salesTasks/task-a", {...h.db.docs.get("salesTasks/task-a")!,
    title: "Changed after review"});
  h.value.inventory = async () => inventoryFor(h.db);
  await assert.rejects(applySalesPrivacyBatch(h.value, principal,
    {organizerId: "org-a", planId: reviewed.plan.planId,
      requestId: "old-batch-0001", expectedCursor: 0}), /source changed/u);
  const freshPreview = await previewSalesPrivacyPlan(h.value, principal,
    {organizerId: "org-a"});
  assert.equal(freshPreview.activePlanId, reviewed.plan.planId);
  const replacement = await reviewSalesPrivacyPlan(h.value, principal,
    {organizerId: "org-a", requestId: "plan-review-0002",
      restrictionRevision: freshPreview.restrictionRevision,
      expectedActivePlanId: freshPreview.activePlanId,
      policyHash: freshPreview.policyHash,
      inventoryHash: freshPreview.inventoryHash});
  assert.notEqual(replacement.plan.planId, reviewed.plan.planId);
  await assert.rejects(applySalesPrivacyBatch(h.value, principal,
    {organizerId: "org-a", planId: reviewed.plan.planId,
      requestId: "old-batch-0001", expectedCursor: 0}),
  /Privacy plan or retention policy changed/u);
  const applied = await applySalesPrivacyBatch(h.value, principal,
    {organizerId: "org-a", planId: replacement.plan.planId,
      requestId: "new-batch-0001", expectedCursor: 0});
  assert.equal(applied.batch.status, "internal_processed_with_unresolved");
});

test("overflow and policy drift fail closed before deletion", async () => {
  const {h, preview, reviewed} = await preparedCase();
  const plan = h.db.docs.get(`salesPrivacyPlans/${reviewed.plan.planId}`)!;
  h.db.docs.set("salesPrivacyPolicies/current", {
    ...h.db.docs.get("salesPrivacyPolicies/current")!, policyHash: "0".repeat(64)});
  await assert.rejects(applySalesPrivacyBatch(h.value, principal,
    {organizerId: "org-a", planId: reviewed.plan.planId,
      requestId: "batch-req-0001", expectedCursor: 0}), /policy hash/u);
  assert.equal(plan.cursor, 0);
  assert.ok(h.db.docs.has("salesTasks/task-a"));
  const overflow = {...inventoryFor(h.db), overflow: true};
  const other = deps(h.db, overflow);
  await assert.rejects(reviewSalesPrivacyPlan(other.value, principal,
    {organizerId: "org-a", requestId: "plan-review-0002",
      restrictionRevision: preview.restrictionRevision,
      expectedActivePlanId: preview.activePlanId, policyHash: preview.policyHash, inventoryHash: overflow.inventoryHash}),
  /exceeded its bound/u);
});
