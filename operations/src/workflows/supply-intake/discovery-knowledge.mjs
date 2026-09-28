import {hashValue} from "../../platform/canonical-json.mjs";
import {invariant} from "../../platform/errors.mjs";

const STEP_ID = "discovery-knowledge";
const LEASE_MS = 60_000;
const DISPOSITIONS = new Set([
  "retained", "rejected", "probable_duplicate", "review",
]);

export function discoveryFingerprint({market, segment, identityKey}) {
  const normalized = String(identityKey ?? "").normalize("NFKC")
    .toLowerCase().replace(/\s+/gu, " ").trim();
  invariant(/^[a-z][a-z0-9_]*:.+$/u.test(normalized),
    "INVALID_DISCOVERY_IDENTITY",
    "A candidate needs a typed canonical identity key.");
  invariant(validSlug(market) && validSlug(segment),
    "INVALID_DISCOVERY_CELL", "Market and segment slugs are required.");
  return hashValue({market, identityKey: normalized});
}

export async function readDiscoveryKnowledge({store, market}) {
  assertStore(store);
  invariant(validSlug(market), "INVALID_DISCOVERY_CELL", "Market slug is required.");
  const state = await store.getCheckpoint(ledgerId(market), STEP_ID);
  if (!state) return emptyKnowledge(market);
  assertKnowledge(state, market);
  return structuredClone(state);
}

export function discoveryReviewBinding(state) {
  invariant(state?.pause && Number.isSafeInteger(state.revision),
    "DISCOVERY_NOT_PAUSED", "A paused discovery ledger is required for review.");
  return {
    knowledgeRevision: state.revision,
    knowledgeHash: hashValue({
      market: state.market,
      revision: state.revision,
      retainedCount: state.retainedCount,
      batchRetained: state.batchRetained,
      pause: state.pause,
      candidates: state.candidates,
      coverage: state.coverage,
    }),
  };
}

export async function recordDiscoveryCandidates({
  store, market, candidates, reviewEvery, now, owner = "discovery-worker",
}) {
  invariant(Array.isArray(candidates), "INVALID_DISCOVERY_BATCH",
    "Candidates must be an ordered array.");
  invariant(Number.isSafeInteger(reviewEvery) && reviewEvery > 0,
    "INVALID_DISCOVERY_POLICY", "A positive reviewed batch interval is required.");
  return withKnowledgeLease({store, market, owner}, async (lease, leaseNow) => {
    let state = await readDiscoveryKnowledge({store, market});
    state = bindInterval(state, reviewEvery);
    state = await recoverContinuation({store, state, lease, leaseNow});
    let processed = 0;
    let replayed = 0;
    for (const candidate of candidates) {
      const normalized = assertCandidate(candidate, market);
      const previous = state.candidates[normalized.fingerprint];
      const identical = previous &&
        previous.decisionRevision === normalized.decisionRevision &&
        previous.decisionHash === normalized.decisionHash;
      if (identical) {
        const observationRefs = [...new Set([
          ...(previous.observationRefs ?? []),
          ...normalized.observationRefs,
        ])].sort();
        if (observationRefs.length !== (previous.observationRefs ?? []).length) {
          state = {
            ...state,
            revision: state.revision + 1,
            candidates: {
              ...state.candidates,
              [normalized.fingerprint]: {
                ...previous,
                observationRefs,
                lastSeenAt: now,
              },
            },
          };
          await saveKnowledge({store, state, lease, leaseNow});
        }
        replayed += 1;
        processed += 1;
        continue;
      }
      if (state.pause) break;
      if (previous) {
        invariant(normalized.decisionRevision > previous.decisionRevision,
          "DISCOVERY_REVISION_CONFLICT",
          "A changed candidate decision needs a higher review revision.");
        invariant(normalized.reviewedChange?.reviewerId &&
          normalized.reviewedChange?.priorDecisionHash === previous.decisionHash,
        "DISCOVERY_REVIEW_REQUIRED",
        "A changed candidate decision needs an explicit review of its prior decision.");
      }
      const newlyRetained = normalized.disposition === "retained" &&
        !previous?.everRetained;
      const nextRevision = state.revision + 1;
      state = {
        ...state,
        revision: nextRevision,
        retainedCount: state.retainedCount + (newlyRetained ? 1 : 0),
        batchRetained: state.batchRetained + (newlyRetained ? 1 : 0),
        candidates: {
          ...state.candidates,
          [normalized.fingerprint]: {
            ...normalized,
            everRetained: previous?.everRetained === true || newlyRetained,
            observationRefs: [...new Set([
              ...(previous?.observationRefs ?? []),
              ...normalized.observationRefs,
            ])].sort(),
            firstSeenAt: previous?.firstSeenAt ?? now,
            lastSeenAt: now,
          },
        },
      };
      if (state.batchRetained === reviewEvery) {
        state.pause = {
          reviewRevision: nextRevision,
          retainedCount: state.retainedCount,
          candidateFingerprint: normalized.fingerprint,
          pausedAt: now,
        };
      }
      await saveKnowledge({store, state, lease, leaseNow});
      processed += 1;
    }
    return {
      state,
      processed,
      replayed,
      nextIndex: processed,
      paused: state.pause !== null,
    };
  });
}

export async function continueDiscoveryAfterReview({
  store, market, receipt, now, owner = "discovery-reviewer",
}) {
  return withKnowledgeLease({store, market, owner}, async (lease, leaseNow) => {
    let state = await readDiscoveryKnowledge({store, market});
    if (!state.pause && state.lastReview?.reviewRevision === receipt?.reviewRevision) {
      const receiptHash = hashValue(receipt);
      invariant(state.lastReview.receiptHash === receiptHash,
        "DISCOVERY_REVIEW_CONFLICT",
        "A different review already controls this pause.");
      return {state, receiptHash, idempotentReplay: true};
    }
    invariant(state.pause, "DISCOVERY_NOT_PAUSED",
      "No retained-row review is awaiting continuation.");
    assertReviewReceipt(receipt, state);
    const key = continuationKey(market, receipt);
    const receiptHash = hashValue(receipt);
    const result = await store.withFencedWrite(lease, leaseNow(), () =>
      store.recordIdempotency(key, {
        receiptHash,
        receipt: structuredClone(receipt),
        recordedAt: now,
      }));
    invariant(result.record.receiptHash === receiptHash,
      "DISCOVERY_REVIEW_CONFLICT",
      "A different review already controls this pause.");
    state = applyContinuation(state, result.record);
    await saveKnowledge({store, state, lease, leaseNow});
    return {state, receiptHash, idempotentReplay: !result.created};
  });
}

export async function recordDiscoveryCellReview({
  store, market, segment, coverage, now, owner = "discovery-reviewer",
}) {
  return withKnowledgeLease({store, market, owner}, async (lease, leaseNow) => {
    invariant(validSlug(segment), "INVALID_DISCOVERY_CELL", "Segment slug is required.");
    assertCoverage(coverage);
    const state = await readDiscoveryKnowledge({store, market});
    const prior = state.coverage[segment];
    invariant(!prior || coverage.reviewRevision > prior.reviewRevision,
      "DISCOVERY_REVISION_CONFLICT",
      "Coverage review revision must advance.");
    const updated = {
      ...state,
      revision: state.revision + 1,
      coverage: {
        ...state.coverage,
        [segment]: {...structuredClone(coverage), market, segment, reviewedAt: now},
      },
    };
    await saveKnowledge({store, state: updated, lease, leaseNow});
    return updated.coverage[segment];
  });
}

function assertCandidate(candidate, market) {
  invariant(candidate && typeof candidate === "object" &&
    validSlug(candidate.segment) && DISPOSITIONS.has(candidate.disposition) &&
    Number.isSafeInteger(candidate.decisionRevision) &&
    candidate.decisionRevision > 0 &&
    nonemptyStrings(candidate.ruleIds) &&
    nonemptyStrings(candidate.inputRefs),
  "INVALID_DISCOVERY_CANDIDATE",
  "Candidate needs a segment, disposition, revision, rules and input references.");
  invariant(candidate.candidateInputHash === undefined ||
    typeof candidate.candidateId === "string" && candidate.candidateId.length > 0 &&
    /^[a-f0-9]{64}$/u.test(candidate.candidateInputHash) &&
    typeof candidate.reviewedBy === "string" && candidate.reviewedBy.length > 0 &&
    typeof candidate.reviewedAt === "string" &&
      !Number.isNaN(Date.parse(candidate.reviewedAt)),
  "INVALID_DISCOVERY_CANDIDATE",
  "A source-bound candidate needs its input hash and reviewed provenance.");
  const fingerprint = discoveryFingerprint({
    market, segment: candidate.segment, identityKey: candidate.identityKey,
  });
  invariant(candidate.fingerprint === undefined || candidate.fingerprint === fingerprint,
    "DISCOVERY_FINGERPRINT_CONFLICT", "Candidate fingerprint does not match its identity.");
  invariant(candidate.observationRefs === undefined ||
    Array.isArray(candidate.observationRefs) &&
    candidate.observationRefs.every((entry) =>
      typeof entry === "string" && entry.length > 0),
  "INVALID_DISCOVERY_CANDIDATE",
  "Observation references must be nonempty strings.");
  const decision = {
    segment: candidate.segment,
    identityKey: String(candidate.identityKey).normalize("NFKC")
      .toLowerCase().replace(/\s+/gu, " ").trim(),
    disposition: candidate.disposition,
    decisionRevision: candidate.decisionRevision,
    reasonCode: candidate.reasonCode ?? null,
    permanent: candidate.permanent === true,
    ruleIds: [...candidate.ruleIds],
    inputRefs: [...candidate.inputRefs],
    ...(candidate.candidateInputHash === undefined ? {} : {
      candidateId: candidate.candidateId,
      candidateInputHash: candidate.candidateInputHash,
      reviewedBy: candidate.reviewedBy,
      reviewedAt: candidate.reviewedAt,
    }),
  };
  invariant(candidate.disposition !== "rejected" ||
    typeof decision.reasonCode === "string" && decision.reasonCode.length > 0,
  "INVALID_DISCOVERY_CANDIDATE", "Rejected candidates need a reason code.");
  return {
    ...decision,
    fingerprint,
    decisionHash: hashValue(decision),
    reviewedChange: candidate.reviewedChange ?? null,
    observationRefs: candidate.observationRefs ?? [],
    publicationEligible: false,
    fitScore: null,
  };
}

function assertCoverage(value) {
  invariant(value && typeof value === "object" &&
    Number.isSafeInteger(value.reviewRevision) && value.reviewRevision > 0 &&
    typeof value.reviewerId === "string" && value.reviewerId.length > 0 &&
    nonemptyStrings(value.ruleIds) && nonemptyStrings(value.inputRefs) &&
    value.lenses && typeof value.lenses === "object" &&
    value.leaderCensus && typeof value.leaderCensus === "object",
  "INVALID_DISCOVERY_COVERAGE", "Coverage requires a reviewed revision, lenses, leader census and evidence references.");
  for (const lens of Object.values(value.lenses)) {
    invariant(Number.isSafeInteger(lens?.usefulQueryCount) &&
      lens.usefulQueryCount >= 0 &&
      Array.isArray(lens.queryRefs) &&
      lens.queryRefs.length >= lens.usefulQueryCount &&
      Array.isArray(lens.sourceDomains),
    "INVALID_DISCOVERY_COVERAGE",
    "Each lens needs an evidenced useful-query count and source domains.");
  }
  const census = value.leaderCensus;
  invariant(Array.isArray(census.candidateFingerprints) &&
    Array.isArray(census.prominenceEvidenceRefs) &&
    Array.isArray(census.topCandidateFingerprints) &&
    census.gateOutcomes && typeof census.gateOutcomes === "object",
  "INVALID_DISCOVERY_COVERAGE",
  "Leader census needs candidate identities, prominence evidence and gate outcomes.");
}

function assertReviewReceipt(receipt, state) {
  const pause = state.pause;
  const binding = discoveryReviewBinding(state);
  invariant(receipt && receipt.decision === "continue" &&
    receipt.reviewRevision === pause.reviewRevision &&
    receipt.candidateFingerprint === pause.candidateFingerprint &&
    receipt.retainedCount === pause.retainedCount &&
    receipt.knowledgeRevision === binding.knowledgeRevision &&
    receipt.knowledgeHash === binding.knowledgeHash &&
    typeof receipt.reviewerId === "string" && receipt.reviewerId.length > 0 &&
    nonemptyStrings(receipt.inputRefs) &&
    validAudit(receipt.precisionAudit) &&
    validAudit(receipt.leaderRecallAudit) &&
    Array.isArray(receipt.findings) && Array.isArray(receipt.changes) &&
    receipt.changes.every((change) =>
      change && ["applied", "rejected"].includes(change.status) &&
      typeof change.ruleId === "string" && change.ruleId.length > 0),
  "INVALID_DISCOVERY_REVIEW",
  "Continuation must review the exact paused fingerprint and revision with precision, leader recall, findings and resolved changes.");
}

async function recoverContinuation({store, state, lease, leaseNow}) {
  if (!state.pause) return state;
  const receipt = await store.getIdempotency(
    continuationKey(state.market, {
      reviewRevision: state.pause.reviewRevision,
      ...discoveryReviewBinding(state),
    }));
  if (!receipt) return state;
  assertReviewReceipt(receipt.receipt, state);
  invariant(receipt.receiptHash === hashValue(receipt.receipt),
    "DISCOVERY_REVIEW_CONFLICT", "Saved continuation receipt hash is invalid.");
  const recovered = applyContinuation(state, receipt);
  await saveKnowledge({store, state: recovered, lease, leaseNow});
  return recovered;
}

function applyContinuation(state, record) {
  return {
    ...state,
    revision: state.revision + 1,
    batchRetained: 0,
    pause: null,
    lastReview: {
      reviewRevision: record.receipt.reviewRevision,
      receiptHash: record.receiptHash,
      reviewedAt: record.recordedAt,
    },
  };
}

function bindInterval(state, reviewEvery) {
  invariant(state.reviewEvery === null || state.reviewEvery === reviewEvery,
    "DISCOVERY_POLICY_CONFLICT",
    "A discovery ledger's reviewed batch interval cannot change mid-session.");
  return state.reviewEvery === null ? {...state, reviewEvery} : state;
}

async function withKnowledgeLease({store, market, owner}, work) {
  assertStore(store);
  invariant(validSlug(market), "INVALID_DISCOVERY_CELL", "Market slug is required.");
  const leaseNow = () => new Date().toISOString();
  const lease = await store.acquireLease(`discovery:${market}`, {
    owner, ttlMs: LEASE_MS, now: leaseNow(),
  });
  try {
    return await work(lease, leaseNow);
  } finally {
    await store.releaseLease(lease);
  }
}

async function saveKnowledge({store, state, lease, leaseNow}) {
  await store.putCheckpoint(ledgerId(state.market), STEP_ID, state, {
    lease, now: leaseNow(),
  });
}

function emptyKnowledge(market) {
  return {
    schemaVersion: 1,
    market,
    revision: 0,
    reviewEvery: null,
    retainedCount: 0,
    batchRetained: 0,
    pause: null,
    lastReview: null,
    candidates: {},
    coverage: {},
  };
}

function assertKnowledge(state, market) {
  invariant(state.schemaVersion === 1 && state.market === market &&
    Number.isSafeInteger(state.revision) &&
    Number.isSafeInteger(state.retainedCount) &&
    Number.isSafeInteger(state.batchRetained) &&
    state.candidates && state.coverage,
  "INVALID_DISCOVERY_KNOWLEDGE", "Saved discovery knowledge is invalid.");
}

function assertStore(store) {
  invariant(store && ["getCheckpoint", "putCheckpoint", "acquireLease",
    "releaseLease", "getIdempotency", "recordIdempotency",
    "withFencedWrite"].every((key) =>
    typeof store[key] === "function"),
  "INVALID_DISCOVERY_STORE", "Discovery needs the Operations store primitives.");
}

function ledgerId(market) {
  return `supply-discovery-${market}`;
}

function continuationKey(market, receipt) {
  return `supply-discovery-review:${market}:${receipt.reviewRevision}:${receipt.knowledgeRevision}:${receipt.knowledgeHash}`;
}

function validSlug(value) {
  return typeof value === "string" && /^[a-z][a-z0-9-]{1,49}$/u.test(value);
}

function nonemptyStrings(value) {
  return Array.isArray(value) && value.length > 0 &&
    value.every((entry) => typeof entry === "string" && entry.length > 0);
}

function validAudit(value) {
  return value && typeof value.outcome === "string" &&
    value.outcome.length > 0 && nonemptyStrings(value.inputRefs);
}
