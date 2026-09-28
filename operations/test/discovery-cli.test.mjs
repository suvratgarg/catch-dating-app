import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {main} from "../src/cli/main.mjs";
import {hashValue} from "../src/platform/canonical-json.mjs";
import {finalizeSupplyInputSnapshot} from "../src/workflows/supply-intake/input-snapshot.mjs";
import {fixtureInputSnapshot} from "./helpers.mjs";

const NOW = "2026-09-28T00:00:00.000Z";
const MARKET = "indore";

function candidate(number) {
  const id = `candidate-${number}`;
  const url = `https://${id}.example/`;
  return {
    candidateId: id, batchId: "synthetic-batch", resultId: id, rank: number,
    query: "synthetic organizers",
    queryIntent: {activityKind: "organizer-discovery", entityHint: null, marketSlug: MARKET},
    observedAt: "2026-09-28", title: `Synthetic prospect ${number}`,
    snippet: null, url, canonicalUrl: url, platform: "officialWebsite",
    surfaceKind: "website", normalizedKey: `domain:${id}.example`,
    suggestedSurface: {
      confidence: {city: "high", entityMatch: "medium", ownership: "low"},
      crawl: {eventDiscoveryStatus: "disabled", policy: "manualOnly", supportsEventExtraction: false},
      evidenceRefs: [], normalizedKey: `domain:${id}.example`, notes: "Synthetic only.",
      platform: "officialWebsite", role: "secondary", status: "candidate",
      surfaceId: `surface-${id}`, surfaceKind: "website", url,
    },
    existingEntityMatches: [], reviewAction: "verify_ownership_before_attach",
    diagnostics: [],
  };
}

async function fixture(t, {count = 3} = {}) {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "discovery-cli-"));
  t.after(() => fs.rm(root, {recursive: true, force: true}));
  const stateDir = path.join(root, "state");
  const candidates = Array.from({length: count}, (_, index) => candidate(index));
  const base = await fixtureInputSnapshot(root, MARKET);
  const snapshot = finalizeSupplyInputSnapshot({...base,
    organizerSearchCandidates: candidates});
  const policy = {
    schemaVersion: 1, enabled: true, reviewEvery: 2,
    decisions: candidates.map((source) => ({
      candidateId: source.candidateId,
      candidateInputHash: hashValue(source),
      identityKey: source.normalizedKey, segment: "synthetic-segment",
      disposition: "retained", decisionRevision: 1,
      reviewedBy: "synthetic-reviewer", reviewedAt: NOW,
      ruleIds: ["synthetic-rule@1"],
      inputRefs: [`synthetic-input:${source.candidateId}`],
    })),
  };
  const inputFile = path.join(root, "input.json");
  const policyFile = path.join(root, "private-policy.json");
  await fs.writeFile(inputFile, JSON.stringify(snapshot));
  await fs.writeFile(policyFile, JSON.stringify(policy));
  await main(["ingest-input", "--state-dir", stateDir, "--input", inputFile]);
  return {root, stateDir, policyFile, policy};
}

function receipt(preview) {
  return {
    decision: "continue",
    reviewRevision: preview.pause.reviewRevision,
    candidateFingerprint: preview.pause.candidateFingerprint,
    retainedCount: preview.pause.retainedCount,
    ...preview.binding,
    reviewerId: "synthetic-reviewer",
    inputRefs: ["synthetic-review"],
    precisionAudit: {outcome: "checked", inputRefs: ["synthetic-precision"]},
    leaderRecallAudit: {outcome: "checked", inputRefs: ["synthetic-recall"]},
    findings: [], changes: [],
  };
}

test("ordinary CLI private policy, pause preview, exact review, and resume", async (t) => {
  const {root, stateDir, policyFile} = await fixture(t);
  const started = await main(["run", "--state-dir", stateDir,
    "--market", MARKET, "--through", "2026-09-28",
    "--intake-scope", "organizer", "--now", NOW,
    "--discovery-policy", policyFile]);
  assert.equal(started.envelope.data.run.status, "paused");
  const runId = started.envelope.data.run.runId;
  const previewed = await main(["discovery", "preview",
    "--state-dir", stateDir, "--run", runId]);
  const preview = previewed.envelope.data;
  assert.equal(preview.retainedCount, 2);
  assert.equal(preview.nextProjectionIndex, 2);
  assert.equal(JSON.stringify(preview).includes("Synthetic prospect"), false);
  assert.equal(JSON.stringify(preview).includes(policyFile), false);
  const receiptFile = path.join(root, "private-receipt.json");
  const exactReceipt = receipt(preview);
  await fs.writeFile(receiptFile, JSON.stringify({...exactReceipt,
    knowledgeRevision: exactReceipt.knowledgeRevision + 1}));
  await assert.rejects(main(["discovery", "continue",
    "--state-dir", stateDir, "--run", runId, "--receipt", receiptFile]),
  {code: "INVALID_DISCOVERY_REVIEW"});
  await fs.writeFile(receiptFile, JSON.stringify(exactReceipt));
  const continued = await main(["discovery", "continue",
    "--state-dir", stateDir, "--run", runId, "--receipt", receiptFile]);
  assert.match(continued.envelope.data.receiptHash, /^[a-f0-9]{64}$/);
  const retried = await main(["discovery", "continue",
    "--state-dir", stateDir, "--run", runId, "--receipt", receiptFile]);
  assert.equal(retried.envelope.data.receiptHash, continued.envelope.data.receiptHash);
  assert.equal(retried.envelope.data.idempotentReplay, true);
  await fs.writeFile(receiptFile, JSON.stringify({...exactReceipt,
    findings: [{code: "synthetic-change"}]}));
  await assert.rejects(main(["discovery", "continue",
    "--state-dir", stateDir, "--run", runId, "--receipt", receiptFile]),
  {code: "DISCOVERY_REVIEW_CONFLICT"});
  const resumed = await main(["resume", "--state-dir", stateDir,
    "--run", runId, "--now", NOW]);
  assert.equal(resumed.envelope.data.run.status, "completed");
  assert.equal(resumed.envelope.data.summary.totalItems, 3);
});

test("an older review receipt cannot continue a later pause", async (t) => {
  const {root, stateDir, policyFile} = await fixture(t, {count: 5});
  const started = await main(["run", "--state-dir", stateDir,
    "--market", MARKET, "--through", "2026-09-28",
    "--intake-scope", "organizer", "--now", NOW,
    "--discovery-policy", policyFile]);
  const runId = started.envelope.data.run.runId;
  const first = (await main(["discovery", "preview",
    "--state-dir", stateDir, "--run", runId])).envelope.data;
  const oldReceiptFile = path.join(root, "old-receipt.json");
  await fs.writeFile(oldReceiptFile, JSON.stringify(receipt(first)));
  await main(["discovery", "continue", "--state-dir", stateDir,
    "--run", runId, "--receipt", oldReceiptFile]);
  const secondRun = await main(["resume", "--state-dir", stateDir,
    "--run", runId, "--now", NOW]);
  assert.equal(secondRun.envelope.data.run.status, "paused");
  const second = (await main(["discovery", "preview",
    "--state-dir", stateDir, "--run", runId])).envelope.data;
  assert.notEqual(second.pause.reviewRevision, first.pause.reviewRevision);
  await assert.rejects(main(["discovery", "continue",
    "--state-dir", stateDir, "--run", runId, "--receipt", oldReceiptFile]),
  {code: "INVALID_DISCOVERY_REVIEW"});
});

test("CLI files a private plan and fails closed for unknown decisions or runs", async (t) => {
  const {root, stateDir, policyFile, policy} = await fixture(t);
  await assert.rejects(main(["plan", "--state-dir", stateDir,
    "--market", MARKET, "--through", "2026-09-28",
    "--intake-scope", "organizer", "--now", NOW,
    "--discovery-policy", policyFile]), {code: "MISSING_ARGUMENT"});
  const planFile = path.join(root, "private-plan.json");
  const planned = await main(["plan", "--state-dir", stateDir,
    "--market", MARKET, "--through", "2026-09-28",
    "--intake-scope", "organizer", "--now", NOW,
    "--discovery-policy", policyFile, "--output", planFile]);
  assert.equal(Object.hasOwn(planned.envelope.data, "plan"), false);
  assert.equal(JSON.stringify(planned.envelope).includes("Synthetic prospect"), false);
  assert.equal((await fs.stat(planFile)).mode & 0o777, 0o600);
  assert.equal(JSON.parse(await fs.readFile(planFile, "utf8"))
    .discoveryGate.decisions["candidate-0"].disposition, "retained");
  const started = await main(["run", "--state-dir", stateDir,
    "--plan", planFile, "--now", NOW]);
  assert.equal(started.envelope.data.run.status, "paused");
  await fs.writeFile(policyFile, JSON.stringify({...policy,
    decisions: policy.decisions.slice(0, -1)}));
  await assert.rejects(main(["run", "--state-dir", stateDir,
    "--market", MARKET, "--through", "2026-09-28",
    "--intake-scope", "organizer", "--now", NOW,
    "--discovery-policy", policyFile]), {code: "INVALID_DISCOVERY_GATE"});
  const receiptFile = path.join(root, "receipt.json");
  await fs.writeFile(receiptFile, "{}");
  await assert.rejects(main(["discovery", "continue",
    "--state-dir", stateDir, "--run", "missing-run",
    "--receipt", receiptFile]), {code: "RUN_NOT_FOUND"});
});
