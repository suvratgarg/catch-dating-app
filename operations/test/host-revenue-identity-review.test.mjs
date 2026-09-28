import test from "node:test";
import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import {identityDecisionTemplate, prepareIdentityReview} from
  "../src/domains/host-revenue/identity-review.mjs";
import {freezeMigration, reviewMigration} from "../src/domains/host-revenue/migration.mjs";
import {stableStringify} from "../src/platform/canonical-json.mjs";
import {planMigrationCompensation} from "../src/domains/host-revenue/compensation-plan.mjs";

const source = {sourceId: "example", contentHash: "a".repeat(64),
  mappingVersion: "staged-v1", rows: [
    {sourceRowId: "cohort-a:1", organizerId: null, name: "Example", researchStatus: "new",
      originalCells: [{column: "original", value: "kept"}]},
    {sourceRowId: "cohort-b:2", organizerId: null, name: "Example", researchStatus: "new"},
    {sourceRowId: "cohort-c:3", organizerId: null, name: "Other", researchStatus: "new"},
  ]};

test("review binds explicit identities and keeps unresolved rows visible", () => {
  const decisions = {...identityDecisionTemplate(source), decisions: [
      {sourceRowId: "cohort-a:1", status: "matched", organizerId: "org-1",
        cohortIds: ["cohort-a"], evidenceRefs: ["evidence-1"]},
      {sourceRowId: "cohort-b:2", status: "matched", organizerId: "org-1",
        cohortIds: ["cohort-b"], evidenceRefs: ["evidence-2"]},
      {sourceRowId: "cohort-c:3", status: "ambiguous", cohortIds: ["cohort-c"],
        candidateOrganizerIds: ["org-2", "org-3"]},
    ]};
  const result = prepareIdentityReview(source, decisions);
  assert.deepEqual(result.counts, {matched: 2, unresolved: 0, ambiguous: 1,
    unreviewed: 0});
  assert.deepEqual(result.rows.slice(0, 2).map(row => row.cohortIds),
    [["cohort-a"], ["cohort-b"]]);
  assert.equal(result.mappedSource.rows[2].organizerId, null);
  assert.equal(result.mappedSource.rows[0].originalCells[0].value, "kept");
  const manifest = freezeMigration(result.mappedSource);
  assert.deepEqual(manifest.packets[0].rows.slice(0, 2).map(row => row.sourceRowId),
    ["cohort-a:1", "cohort-b:2"]);
  assert.throws(() => prepareIdentityReview(source, {...decisions, decisions: [
    {...decisions.decisions[0], organizerId: "org-guessed", evidenceRefs: []}]}),
  /canonical match needs/);
});

test("compensation stays read-only and preserves accounts edited after import", async () => {
  const mapped = structuredClone(source);
  mapped.rows[0].organizerId = "org-1";
  mapped.rows[1].organizerId = "org-1";
  const manifest = freezeMigration(mapped);
  const review = await reviewMigration(manifest, {invoke: async (_name, packet) => ({
    previewHash: "b".repeat(64), effectsApplied: false,
    packetRowCount: packet.rows.length,
    rows: packet.rows.map(row => ({sourceRowId: row.sourceRowId,
      organizerId: row.organizerId, disposition: row.organizerId ? "matched" : "unresolved"})),
    counts: {created: 0, matched: packet.rows.filter(row => row.organizerId).length,
      duplicate: 0, unresolved: packet.rows.filter(row => !row.organizerId).length,
      rejected: 0},
  })});
  const receipts = manifest.packets.map((packet, index) => ({
    importId: `import-${index}`, effectsApplied: true,
    receipt: {requestId: `migration-${createHash("sha256").update(stableStringify({
      manifestHash: manifest.manifestHash, reviewHash: review.reviewHash, index,
    })).digest("hex").slice(0, 48)}`},
    rows: packet.rows.map((row, rowIndex) => ({sourceRowId: row.sourceRowId,
      organizerId: row.organizerId,
      disposition: row.organizerId === null ? "unresolved" :
        rowIndex === 0 ? "created" : "matched"})),
  }));
  const plan = planMigrationCompensation({manifest, review, receipts, currentAccounts: {
    "org-1": {revision: 2, createdAt: "2026-01-01", updatedAt: "2026-01-02"},
  }});
  assert.equal(plan.executableRollback, false);
  assert.equal(plan.effectsApplied, false);
  assert.equal(plan.accounts[0].status, "preserve_later_edits");
  assert.deepEqual(plan.rows.map(row => row.sourceRowId),
    ["cohort-a:1", "cohort-b:2"]);
});
