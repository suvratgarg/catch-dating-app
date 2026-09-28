import assert from "node:assert/strict";
import test from "node:test";
import {applyReviewedCompensation, previewReviewedCompensation} from
  "../src/domains/host-revenue/compensation.mjs";

const importId = "import-a";
const organizerId = "org-a";
const previewHash = "a".repeat(64);
const plan = {importId, organizerId, previewHash,
  mode: "remove_cohorts", blockers: [], cohortIdsRemoved: ["cohort-a"],
  accountRevision: 3, alreadyCompensated: false};

class Store {
  acquired = 0;
  released = 0;
  checkpoints = [];
  async acquireLease() {this.acquired += 1; return {leaseId: "lease-1"};}
  async putCheckpoint(_runId, _name, data) {this.checkpoints.push(data);}
  async releaseLease() {this.released += 1;}
}

test("preview binds one organizer to the server plan", async () => {
  const calls = [];
  const client = {invoke: async (name, payload) => {
    calls.push({name, payload}); return plan;
  }};
  assert.deepEqual(await previewReviewedCompensation(client,
    {importId, organizerId}), plan);
  assert.deepEqual(calls, [{name: "adminPreviewSalesImportCompensation",
    payload: {importId, organizerId}}]);
  await assert.rejects(previewReviewedCompensation(client,
    {importId, organizerId: "../other"}), /canonical organizer ID/);
});

test("apply requires the exact unblocked hash and reviewed reason", async () => {
  const calls = [];
  const client = {invoke: async (name, payload) => {
    calls.push({name, payload});
    return {importId, organizerId, status: "compensated",
      receipt: {requestId: payload.requestId, revision: null}};
  }};
  const store = new Store();
  const options = {plan, approvedPreviewHash: previewHash,
    reason: "Reviewed source correction", client, store,
    now: () => "2026-09-28T00:00:00.000Z"};
  await assert.rejects(applyReviewedCompensation({...options,
    approvedPreviewHash: "b".repeat(64)}), /current unblocked/);
  await assert.rejects(applyReviewedCompensation({...options,
    plan: {...plan, blockers: ["sibling_import_membership"]}}),
  /current unblocked/);
  await assert.rejects(applyReviewedCompensation({...options,
    reason: " "}), /reviewed reason/);
  assert.equal(calls.length, 0);
  const result = await applyReviewedCompensation(options);
  assert.equal(result.status, "compensated");
  assert.equal(store.acquired, 1);
  assert.equal(store.released, 1);
  assert.equal(store.checkpoints.length, 1);
  assert.equal(calls[0].name, "adminApplySalesImportCompensation");
  assert.equal(calls[0].payload.previewHash, previewHash);
  assert.match(calls[0].payload.requestId, /^compensation-[a-f0-9]{48}$/u);
  await applyReviewedCompensation(options);
  assert.equal(calls[1].payload.requestId, calls[0].payload.requestId);
});

test("uncertain response cannot create a checkpoint and releases the lease", async () => {
  const store = new Store();
  const client = {invoke: async () => {
    throw new Error("network outcome unknown");
  }};
  await assert.rejects(applyReviewedCompensation({plan,
    approvedPreviewHash: previewHash, reason: "Reviewed source correction",
    client, store}), /network outcome unknown/);
  assert.equal(store.acquired, 1);
  assert.equal(store.released, 1);
  assert.deepEqual(store.checkpoints, []);
});
