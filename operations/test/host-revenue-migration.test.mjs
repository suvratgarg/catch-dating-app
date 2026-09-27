import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import {FileOperationsStore} from "../src/platform/storage/file-store.mjs";
import {freezeMigration, reviewMigration, applyReviewedMigration} from
  "../src/domains/host-revenue/migration.mjs";

function source(count = 28) {
  return {sourceId: "synthetic-source", contentHash: "a".repeat(64),
    mappingVersion: "synthetic-v1", rows: Array.from({length: count}, (_, i) => ({
      sourceRowId: `row-${i}`, organizerId: `org-${i}`, name: `Example ${i}`,
      researchStatus: "new", originalCells: [{column: "Unknown source field", value: "Kept"}],
    }))};
}
function clientFixture() {
  const receipts = new Map();
  let effects = 0;
  const client = {async invoke(name, input) {
    if (name === "adminGetSalesReceipt") {
      if (!receipts.has(input.requestId)) throw Object.assign(new Error("missing"),
        {code: "ADMIN_CALLABLE_NOT_FOUND"});
      return {receipt: receipts.get(input.requestId)};
    }
    const preview = {previewHash: "b".repeat(64), packetRowCount: input.rows.length,
      effectsApplied: false, counts: {created: input.rows.length,
        matched: 0, duplicate: 0, unresolved: 0, rejected: 0},
      rows: input.rows.map(row => ({sourceRowId: row.sourceRowId,
        organizerId: row.organizerId, disposition: "created", reason: "synthetic"}))};
    if (name === "adminPreviewSalesImport") return preview;
    assert.equal(name, "adminApplySalesImport");
    if (receipts.has(input.requestId)) return receipts.get(input.requestId);
    effects += input.rows.length;
    const result = {...preview, effectsApplied: true, importId: `import-${receipts.size}`,
      receipt: {requestId: input.requestId, revision: null}};
    receipts.set(input.requestId, result);
    return result;
  }};
  return {client, effects: () => effects};
}

test("frozen migration preserves unknown cells and limits batches by count and bytes", () => {
  const manifest = freezeMigration(source());
  assert.deepEqual(manifest.packets.map(p => p.rows.length), [25, 3]);
  assert.equal(manifest.packets[0].rows[0].originalCells[0].value, "Kept");
  const input = source(2);
  input.rows[1].sourceRowId = input.rows[0].sourceRowId;
  assert.throws(() => freezeMigration(input), /unique lineage/);
  input.rows[1].sourceRowId = "row-other";
  for (const row of input.rows) row.originalCells = Array.from({length: 50},
    (_, i) => ({column: `Column ${i}`, value: "x".repeat(2000)}));
  assert.equal(freezeMigration(input).packets.length, 2);
  assert.ok(freezeMigration(input).packets.every(p =>
    Buffer.byteLength(JSON.stringify(p)) <= 120000));
});

test("restart after business commit before checkpoint recovers without duplicate effects", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "sales-migration-test-"));
  try {
    const store = await new FileOperationsStore(root).initialize();
    const manifest = freezeMigration(source());
    const fixture = clientFixture();
    const review = await reviewMigration(manifest, fixture.client);
    const options = {manifest, review, approvedReviewHash: review.reviewHash,
      client: fixture.client, store, owner: "synthetic-worker"};
    await assert.rejects(applyReviewedMigration({...options,
      afterCommit: async () => {throw new Error("simulated interruption");}}), /interruption/);
    assert.equal(fixture.effects(), 25);
    const result = await applyReviewedMigration(options);
    assert.equal(fixture.effects(), 28);
    assert.equal(result.counts.created, 28);
    assert.equal(result.batchesCompleted, 2);
    await applyReviewedMigration(options);
    assert.equal(fixture.effects(), 28);
  } finally {await fs.rm(root, {recursive: true, force: true});}
});

test("altered source or review cannot reuse prior approval", async () => {
  const manifest = freezeMigration(source());
  const {client} = clientFixture();
  const review = await reviewMigration(manifest, client);
  const options = {manifest, review, approvedReviewHash: review.reviewHash,
    client, store: {}, owner: "synthetic-worker"};
  const changed = structuredClone(manifest);
  changed.packets[0].rows[0].name = "Changed after review";
  await assert.rejects(applyReviewedMigration({...options, manifest: changed}), /changed/);
  const changedReview = structuredClone(review);
  changedReview.batches[0].previewHash = "c".repeat(64);
  await assert.rejects(applyReviewedMigration({...options, review: changedReview}), /exact frozen/);
});

test("unknown receipt failures never fall back to a mutation", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "sales-migration-test-"));
  try {
    const store = await new FileOperationsStore(root).initialize();
    const manifest = freezeMigration(source(1));
    const fixture = clientFixture();
    const review = await reviewMigration(manifest, fixture.client);
    const client = {invoke: async () => {throw Object.assign(new Error("role revoked"),
      {code: "ADMIN_CALLABLE_PERMISSION_DENIED"});}};
    await assert.rejects(applyReviewedMigration({manifest, review,
      approvedReviewHash: review.reviewHash, client, store, owner: "worker"}), /role revoked/);
    assert.equal(fixture.effects(), 0);
  } finally {await fs.rm(root, {recursive: true, force: true});}
});


test("more than sixty wide batches respect read and write minute budgets", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "sales-migration-rate-"));
  try {
    let milliseconds = Date.parse("2026-09-28T00:00:00Z");
    const timing = {clock: () => milliseconds, wait: async ms => {milliseconds += ms;}};
    const now = () => new Date(milliseconds).toISOString();
    const store = await new FileOperationsStore(root).initialize();
    const input = source(70);
    for (const row of input.rows) row.originalCells = Array.from({length: 50},
      (_, i) => ({column: `Column ${i}`, value: "x".repeat(2000)}));
    const manifest = freezeMigration(input);
    assert.equal(manifest.packets.length, 70);
    const fixture = clientFixture();
    const calls = new Map();
    const client = {async invoke(name, payload) {
      const timestamps = (calls.get(name) ?? []).filter(at => milliseconds - at < 60000);
      const budget = name === "adminApplySalesImport" ? 20 : 60;
      assert.ok(timestamps.length < budget, `${name} exceeded its minute budget`);
      timestamps.push(milliseconds); calls.set(name, timestamps);
      return fixture.client.invoke(name, payload);
    }};
    const review = await reviewMigration(manifest, client, timing);
    const result = await applyReviewedMigration({manifest, review,
      approvedReviewHash: review.reviewHash, client, store, owner: "worker", now, timing});
    assert.equal(result.batchesCompleted, 70);
    assert.equal(fixture.effects(), 70);
    // A new minute permits a restart; rechecking 70 receipts must also pace.
    milliseconds += 61000;
    await applyReviewedMigration({manifest, review, approvedReviewHash: review.reviewHash,
      client, store, owner: "worker", now, timing});
    assert.equal(fixture.effects(), 70);
  } finally {await fs.rm(root, {recursive: true, force: true});}
});


test("repeated canonical identities cannot invalidate a later frozen batch", () => {
  const input = source(26);
  input.rows[25].organizerId = input.rows[0].organizerId;
  assert.throws(() => freezeMigration(input), /organizer spans multiple batches/);
  input.rows[25].organizerId = null;
  input.rows[1].organizerId = input.rows[0].organizerId;
  assert.equal(freezeMigration(input).packets.length, 2);
});
