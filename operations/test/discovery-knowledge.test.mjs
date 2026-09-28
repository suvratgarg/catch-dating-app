import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {FileOperationsStore} from "../src/platform/storage/file-store.mjs";
import {
  continueDiscoveryAfterReview,
  discoveryReviewBinding,
  readDiscoveryKnowledge,
  recordDiscoveryCandidates,
  recordDiscoveryCellReview,
} from "../src/workflows/supply-intake/discovery-knowledge.mjs";

const now = "2026-09-28T00:00:00.000Z";

async function fixture(t) {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "discovery-knowledge-"));
  t.after(() => fs.rm(root, {recursive: true, force: true}));
  return {root, store: await new FileOperationsStore(root).initialize()};
}

function candidate(number, disposition = "retained") {
  return {
    segment: "sample-segment",
    identityKey: `domain:sample-${number}.test`,
    disposition,
    decisionRevision: 1,
    ...(disposition === "rejected" ? {reasonCode: "outside_scope"} : {}),
    ruleIds: ["synthetic-rule@1"],
    inputRefs: [`synthetic-capture:${number}`],
  };
}

test("the 25th retained identity pauses before candidate 26, including after restart", async (t) => {
  const {root, store} = await fixture(t);
  const candidates = [candidate(0, "rejected"),
    candidate(1, "probable_duplicate"),
    ...Array.from({length: 26}, (_, index) => candidate(index + 2))];
  const first = await recordDiscoveryCandidates({
    store, market: "sample-market", candidates, reviewEvery: 25, now,
  });
  assert.equal(first.processed, 27);
  assert.equal(first.state.retainedCount, 25);
  assert.equal(first.state.batchRetained, 25);
  assert.equal(first.paused, true);
  assert.equal(first.state.candidates[Object.keys(first.state.candidates)[0]].publicationEligible, false);

  const restarted = await new FileOperationsStore(root).initialize();
  const replay = await recordDiscoveryCandidates({
    store: restarted, market: "sample-market", candidates,
    reviewEvery: 25, now,
  });
  assert.equal(replay.processed, 27);
  assert.equal(replay.replayed, 27);
  assert.equal(replay.state.retainedCount, 25);
  const pause = replay.state.pause;
  await assert.rejects(() => continueDiscoveryAfterReview({
    store: restarted, market: "sample-market", now,
    receipt: {
      decision: "continue", reviewRevision: pause.reviewRevision + 1,
      ...discoveryReviewBinding(replay.state),
      candidateFingerprint: pause.candidateFingerprint,
      retainedCount: pause.retainedCount, reviewerId: "reviewer",
      inputRefs: ["synthetic-review"],
      precisionAudit: {outcome: "checked", inputRefs: ["synthetic-precision"]},
      leaderRecallAudit: {outcome: "checked", inputRefs: ["synthetic-recall"]},
      findings: [], changes: [],
    },
  }), {code: "INVALID_DISCOVERY_REVIEW"});
  const reviewed = await continueDiscoveryAfterReview({
    store: restarted, market: "sample-market", now,
    receipt: {
      decision: "continue", reviewRevision: pause.reviewRevision,
      ...discoveryReviewBinding(replay.state),
      candidateFingerprint: pause.candidateFingerprint,
      retainedCount: pause.retainedCount, reviewerId: "reviewer",
      inputRefs: ["synthetic-review"],
      precisionAudit: {outcome: "checked", inputRefs: ["synthetic-precision"]},
      leaderRecallAudit: {outcome: "checked", inputRefs: ["synthetic-recall"]},
      findings: [], changes: [],
    },
  });
  const repeated = await continueDiscoveryAfterReview({
    store: restarted, market: "sample-market", now,
    receipt: {
      decision: "continue", reviewRevision: pause.reviewRevision,
      ...discoveryReviewBinding(replay.state),
      candidateFingerprint: pause.candidateFingerprint,
      retainedCount: pause.retainedCount, reviewerId: "reviewer",
      inputRefs: ["synthetic-review"],
      precisionAudit: {outcome: "checked", inputRefs: ["synthetic-precision"]},
      leaderRecallAudit: {outcome: "checked", inputRefs: ["synthetic-recall"]},
      findings: [], changes: [],
    },
  });
  assert.equal(repeated.idempotentReplay, true);
  assert.equal(repeated.receiptHash, reviewed.receiptHash);
  const resumed = await recordDiscoveryCandidates({
    store: restarted, market: "sample-market", candidates,
    reviewEvery: 25, now,
  });
  assert.equal(resumed.processed, 28);
  assert.equal(resumed.state.retainedCount, 26);
  assert.equal(resumed.state.batchRetained, 1);
  assert.equal(resumed.paused, false);
});

test("failed checkpoint and failed continuation write replay without double counting", async (t) => {
  const {root, store} = await fixture(t);
  let writes = 0;
  const interrupted = Object.create(store);
  interrupted.putCheckpoint = async (...args) => {
    writes += 1;
    if (writes === 2) throw new Error("simulated crash");
    return store.putCheckpoint(...args);
  };
  await assert.rejects(() => recordDiscoveryCandidates({
    store: interrupted, market: "sample-market",
    candidates: [candidate(1), candidate(2)], reviewEvery: 2, now,
  }), /simulated crash/);
  const restarted = await new FileOperationsStore(root).initialize();
  const processed = await recordDiscoveryCandidates({
    store: restarted, market: "sample-market",
    candidates: [candidate(1), candidate(2), candidate(3)],
    reviewEvery: 2, now,
  });
  assert.equal(processed.state.retainedCount, 2);
  assert.equal(processed.processed, 2);
  const pause = processed.state.pause;
  const receipt = {
    decision: "continue", reviewRevision: pause.reviewRevision,
    ...discoveryReviewBinding(processed.state),
    candidateFingerprint: pause.candidateFingerprint,
    retainedCount: pause.retainedCount, reviewerId: "reviewer",
    inputRefs: ["synthetic-review"],
    precisionAudit: {outcome: "checked", inputRefs: ["synthetic-precision"]},
    leaderRecallAudit: {outcome: "checked", inputRefs: ["synthetic-recall"]},
    findings: [], changes: [],
  };
  const failedWrite = Object.create(restarted);
  failedWrite.putCheckpoint = async () => { throw new Error("lost checkpoint"); };
  await assert.rejects(() => continueDiscoveryAfterReview({
    store: failedWrite, market: "sample-market", receipt, now,
  }), /lost checkpoint/);
  const recovered = await recordDiscoveryCandidates({
    store: restarted, market: "sample-market",
    candidates: [candidate(1), candidate(2), candidate(3)],
    reviewEvery: 2, now,
  });
  assert.equal(recovered.state.retainedCount, 3);
  assert.equal(recovered.state.batchRetained, 1);
  assert.equal(recovered.state.lastReview.reviewRevision, pause.reviewRevision);
});

test("rejected identity persists and requires reviewed revision to change", async (t) => {
  const {store} = await fixture(t);
  await recordDiscoveryCandidates({
    store, market: "sample-market", candidates: [candidate(1, "rejected")],
    reviewEvery: 2, now,
  });
  const rediscovered = await recordDiscoveryCandidates({
    store, market: "sample-market",
    candidates: [{...candidate(1, "rejected"),
      observationRefs: ["synthetic-query:later"]}],
    reviewEvery: 2, now,
  });
  assert.equal(rediscovered.replayed, 1);
  assert.equal(rediscovered.state.retainedCount, 0);
  const changed = {...candidate(1), decisionRevision: 2};
  await assert.rejects(() => recordDiscoveryCandidates({
    store, market: "sample-market", candidates: [changed], reviewEvery: 2, now,
  }), {code: "DISCOVERY_REVIEW_REQUIRED"});
  const prior = (await readDiscoveryKnowledge({store, market: "sample-market"}));
  const fingerprint = Object.keys(prior.candidates)[0];
  assert.deepEqual(prior.candidates[fingerprint].observationRefs,
    ["synthetic-query:later"]);
  const accepted = await recordDiscoveryCandidates({
    store, market: "sample-market",
    candidates: [{...changed, reviewedChange: {
      reviewerId: "reviewer",
      priorDecisionHash: prior.candidates[fingerprint].decisionHash,
    }}],
    reviewEvery: 2, now,
  });
  assert.equal(accepted.state.retainedCount, 1);
  assert.equal(accepted.state.candidates[fingerprint].everRetained, true);
});

test("reviewed lens and leader coverage is durable", async (t) => {
  const {root, store} = await fixture(t);
  await recordDiscoveryCellReview({
    store, market: "sample-market", segment: "sample-segment", now,
    coverage: {
      reviewRevision: 1, reviewerId: "reviewer",
      ruleIds: ["synthetic-coverage@1"],
      inputRefs: ["synthetic-query:1"],
      lenses: {web_press: {usefulQueryCount: 1, queryRefs: ["query:one"], sourceDomains: ["sample.test"]}},
      leaderCensus: {
        status: "incomplete", candidateFingerprints: [],
        prominenceEvidenceRefs: [], topCandidateFingerprints: [], gateOutcomes: {},
      },
    },
  });
  const restarted = await new FileOperationsStore(root).initialize();
  const state = await readDiscoveryKnowledge({store: restarted, market: "sample-market"});
  assert.equal(state.coverage["sample-segment"].reviewRevision, 1);
  assert.equal(state.coverage["sample-segment"].leaderCensus.status, "incomplete");
});

test("paused observations and coverage invalidate an earlier review binding", async (t) => {
  const {store} = await fixture(t);
  const paused = await recordDiscoveryCandidates({
    store, market: "sample-market", candidates: [candidate(1), candidate(2)],
    reviewEvery: 2, now,
  });
  const oldReceipt = {
    decision: "continue",
    reviewRevision: paused.state.pause.reviewRevision,
    candidateFingerprint: paused.state.pause.candidateFingerprint,
    retainedCount: paused.state.pause.retainedCount,
    ...discoveryReviewBinding(paused.state),
    reviewerId: "reviewer",
    inputRefs: ["synthetic-review"],
    precisionAudit: {outcome: "checked", inputRefs: ["synthetic-precision"]},
    leaderRecallAudit: {outcome: "checked", inputRefs: ["synthetic-recall"]},
    findings: [], changes: [],
  };
  await recordDiscoveryCandidates({
    store, market: "sample-market",
    candidates: [{...candidate(1), observationRefs: ["query:new"]}],
    reviewEvery: 2, now,
  });
  await assert.rejects(() => continueDiscoveryAfterReview({
    store, market: "sample-market", receipt: oldReceipt, now,
  }), {code: "INVALID_DISCOVERY_REVIEW"});
  await recordDiscoveryCellReview({
    store, market: "sample-market", segment: "sample-segment", now,
    coverage: {
      reviewRevision: 1, reviewerId: "reviewer",
      ruleIds: ["synthetic-coverage@1"], inputRefs: ["synthetic-query:1"],
      lenses: {},
      leaderCensus: {
        status: "incomplete", candidateFingerprints: [],
        prominenceEvidenceRefs: [], topCandidateFingerprints: [], gateOutcomes: {},
      },
    },
  });
  const current = await readDiscoveryKnowledge({store, market: "sample-market"});
  assert.equal(current.pause.reviewRevision, oldReceipt.reviewRevision);
  await assert.rejects(() => continueDiscoveryAfterReview({
    store, market: "sample-market", receipt: oldReceipt, now,
  }), {code: "INVALID_DISCOVERY_REVIEW"});
  const accepted = await continueDiscoveryAfterReview({
    store, market: "sample-market",
    receipt: {...oldReceipt, ...discoveryReviewBinding(current)}, now,
  });
  assert.equal(accepted.state.pause, null);
});

test("lost lease cannot persist a continuation receipt or clear the pause", async (t) => {
  const {root, store} = await fixture(t);
  const paused = await recordDiscoveryCandidates({
    store, market: "sample-market", candidates: [candidate(1)],
    reviewEvery: 1, now,
  });
  const receipt = {
    decision: "continue",
    reviewRevision: paused.state.pause.reviewRevision,
    candidateFingerprint: paused.state.pause.candidateFingerprint,
    retainedCount: paused.state.pause.retainedCount,
    ...discoveryReviewBinding(paused.state),
    reviewerId: "reviewer", inputRefs: ["synthetic-review"],
    precisionAudit: {outcome: "checked", inputRefs: ["synthetic-precision"]},
    leaderRecallAudit: {outcome: "checked", inputRefs: ["synthetic-recall"]},
    findings: [], changes: [],
  };
  const lostOwner = Object.create(store);
  lostOwner.withFencedWrite = async (lease, leaseNow, write) => {
    await store.releaseLease(lease);
    return store.withFencedWrite(lease, leaseNow, write);
  };
  await assert.rejects(() => continueDiscoveryAfterReview({
    store: lostOwner, market: "sample-market", receipt, now,
  }), {code: "LEASE_LOST"});
  assert.deepEqual(await fs.readdir(path.join(root, "idempotency")), []);
  const restarted = await new FileOperationsStore(root).initialize();
  const replay = await recordDiscoveryCandidates({
    store: restarted, market: "sample-market",
    candidates: [candidate(1), candidate(2)], reviewEvery: 1, now,
  });
  assert.equal(replay.state.pause.reviewRevision, paused.state.pause.reviewRevision);
  assert.equal(replay.processed, 1);
});
