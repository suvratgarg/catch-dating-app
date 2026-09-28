import assert from "node:assert/strict";
import test from "node:test";
import {historyDecisionTemplate, freezeHistoryPromotion,
  reviewHistoryPromotion, applyReviewedHistoryPromotion} from
  "../src/domains/host-revenue/history-promotion.mjs";

const source = {sourceId: "synthetic", contentHash: "a".repeat(64),
  mappingVersion: "review-v1", rows: [
    {sourceRowId: "row-1", organizerId: "org-1",
      originalCells: [{column: "First touch", value: "2026-01-01T00:00:00Z"}]},
    {sourceRowId: "row-2", organizerId: "org-2", originalCells: []},
    {sourceRowId: "row-3", organizerId: null, originalCells: []},
  ]};
const decisions = () => ({...historyDecisionTemplate(source),
  rows: [{sourceRowId: "row-1", organizerId: "org-1", importId: "import-1",
    disposition: "promoted", reason: "Reviewed historic note",
    entries: [{kind: "activity", sourceColumn: "First touch",
      sourceValue: "2026-01-01T00:00:00Z", occurredAt: null,
      dateSourceColumn: null, dateSourceValue: null}]},
  {sourceRowId: "row-2", organizerId: "org-2", importId: "import-2",
    disposition: "skipped", reason: "No reviewed history cells", entries: []}]});
class Store {
  checkpoints = [];
  released = 0;
  async acquireLease() {return {id: "lease"};}
  async renewLease(lease) {return lease;}
  async putCheckpoint(_runId, _name, value) {this.checkpoints.push(value);}
  async releaseLease() {this.released += 1;}
}
function fixture() {
  const calls = [];
  const client = {async invoke(name, payload) {
    calls.push({name, payload});
    const result = {previewHash: "b".repeat(64),
      packetRowCount: payload.rows.length,
      rows: payload.rows.map(row => ({sourceRowId: row.sourceRowId,
        organizerId: row.organizerId, status: row.disposition,
        recordIds: row.entries.map((_, index) => `record-${index}`)}))};
    if (name === "adminPreviewSalesImportHistory") {
      return {...result, effectsApplied: false};
    }
    assert.equal(name, "adminApplySalesImportHistory");
    return {...result, effectsApplied: true, recordsCreated: 1,
      receipt: {requestId: payload.requestId, revision: null}};
  }};
  return {client, calls};
}

test("all private source rows have promoted, skipped or pending disposition", () => {
  const plan = freezeHistoryPromotion(source, decisions());
  assert.equal(plan.rowCount, 3);
  assert.deepEqual(plan.counts,
    {promoted: 1, skipped: 1, review_needed: 1});
  assert.deepEqual(plan.packets.map(packet => packet.rows.length), [2]);
  assert.equal(plan.rows[2].importId, null);
  const changed = structuredClone(source);
  changed.rows[0].originalCells[0].value = "changed";
  assert.throws(() => freezeHistoryPromotion(changed, decisions()),
    /exact source/);
  const bad = decisions();
  bad.rows[0].entries[0].sourceValue = "fabricated";
  assert.throws(() => freezeHistoryPromotion(source, bad),
    /exact source cell/);
});

test("reviewed identity with pending mapping has a durable row disposition", () => {
  const pending = decisions();
  pending.rows[1] = {sourceRowId: "row-2", organizerId: "org-2",
    importId: "import-2", disposition: "review_needed",
    reason: "Source chronology needs review", entries: []};
  const plan = freezeHistoryPromotion(source, pending);
  assert.equal(plan.counts.review_needed, 2);
  assert.deepEqual(plan.packets[0].rows.map(row => row.sourceRowId),
    ["row-1", "row-2"]);
  assert.equal(plan.rows[2].importId, null);
});

test("exact server review, stable retries and lease checkpoints", async () => {
  const plan = freezeHistoryPromotion(source, decisions());
  const {client, calls} = fixture();
  const review = await reviewHistoryPromotion(plan, client);
  const store = new Store();
  const options = {plan, review, approvedReviewHash: review.reviewHash,
    client, store};
  const result = await applyReviewedHistoryPromotion(options);
  assert.equal(result.complete, false);
  assert.equal(result.recordsCreated, 1);
  assert.equal(store.checkpoints.length, 1);
  assert.equal(store.released, 1);
  await applyReviewedHistoryPromotion(options);
  assert.equal(calls.at(-1).payload.requestId,
    calls.at(-2).payload.requestId);
  assert.match(calls.at(-1).payload.requestId,
    /^history-[a-f0-9]{48}$/u);
});

test("changed review and uncertain action never create a checkpoint", async () => {
  const plan = freezeHistoryPromotion(source, decisions());
  const {client} = fixture();
  const review = await reviewHistoryPromotion(plan, client);
  const store = new Store();
  await assert.rejects(applyReviewedHistoryPromotion({plan, review,
    approvedReviewHash: "c".repeat(64), client, store}), /exact server/);
  assert.equal(store.released, 0);
  await assert.rejects(applyReviewedHistoryPromotion({plan, review,
    approvedReviewHash: review.reviewHash,
    client: {invoke: async () => {throw new Error("uncertain");}}, store}),
  /uncertain/);
  assert.equal(store.released, 1);
  assert.deepEqual(store.checkpoints, []);
});
