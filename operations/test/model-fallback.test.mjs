import assert from "node:assert/strict";
import test from "node:test";
import {FileOperationsStore} from
  "../src/platform/storage/file-store.mjs";
import {
  createSupplyModelFallback,
  loadSupplyModelPolicy,
  modelBudgetLedgers,
  modelDependenceMetrics,
} from "../src/workflows/supply-intake/model-fallback.mjs";
import {SupplyIntakeWorkflow} from
  "../src/workflows/supply-intake/workflow.mjs";
import {SupplyIntakeLearner} from
  "../src/workflows/supply-intake/learning.mjs";
import {
  createFixtureRepository,
  temporaryDirectory,
} from "./helpers.mjs";

const NOW = "2026-07-27T00:00:00.000Z";
const ARTIFACT_HASH = "a".repeat(64);

test("model policy is disabled with zero run and monthly ceilings", async () => {
  const policy = await loadSupplyModelPolicy();
  assert.equal(policy.provider.enabled, false);
  assert.equal(policy.provider.adapterId, null);
  assert.equal(policy.provider.modelId, null);
  assert.equal(policy.provider.decisionId, null);
  assert.ok(Object.values(policy.budgets).every((value) => value === 0));
  assert.deepEqual(policy.placement.allowedReasons, [
    "unknown_source",
    "unstable_source",
    "ambiguous_identity",
  ]);
  assert.deepEqual(policy.placement.forbiddenUses, [
    "copy_generation",
    "ranking",
    "per_user_path",
  ]);
});

test("deterministic extraction bypasses the model and lowers dependence",
  async () => {
    const policy = await loadSupplyModelPolicy();
    const store = await new FileOperationsStore(await temporaryDirectory())
      .initialize();
    const router = createSupplyModelFallback({
      policy,
      store,
      clock: () => new Date(NOW),
    });
    const result = await router.resolve({
      sourceProfileId: "luma",
      artifactHash: ARTIFACT_HASH,
      observedAt: NOW,
      deterministic: {
        attempted: true,
        resolved: true,
        profileFound: true,
        output: {title: "Courtside Social"},
      },
    });
    assert.equal(result.route, "deterministic");
    assert.deepEqual(result.output, {title: "Courtside Social"});
    const metrics = await modelDependenceMetrics(store);
    assert.equal(metrics.sources[0].dependenceRate, 0);
    assert.equal((await store.listModelRuleCandidates()).length, 0);
  });

test("fallback placement rejects non-extraction and unresolved scorecard gaps",
  async () => {
    const policy = enabledPolicy(await loadSupplyModelPolicy());
    const store = await new FileOperationsStore(await temporaryDirectory())
      .initialize();
    const router = createSupplyModelFallback({
      policy,
      policyDecision: acceptedDecision(),
      provider: fixtureProvider(),
      store,
      budgets: modelBudgetLedgers({
        policy,
        monthKey: "2026-07",
      }),
      clock: () => new Date(NOW),
    });
    await assert.rejects(router.resolve({
      ...fallbackRequest(),
      reason: "copy_generation",
    }), {code: "MODEL_PLACEMENT_FORBIDDEN"});
    await assert.rejects(router.resolve({
      ...fallbackRequest(),
      reason: "ambiguous_identity",
      deterministic: {
        attempted: true,
        resolved: false,
        profileFound: true,
        identityScorecard: {
          evaluated: false,
          resolution: "ambiguous",
        },
      },
    }), {code: "MODEL_PLACEMENT_FORBIDDEN"});
    await assert.rejects(router.resolve({
      ...fallbackRequest(),
      input: {
        excerpt: "Public page",
        userId: "member-1",
      },
    }), {code: "MODEL_INPUT_FORBIDDEN"});
    await assert.rejects(router.resolve({
      ...fallbackRequest(),
      deterministic: {
        attempted: true,
        resolved: false,
        profileFound: false,
        evidence: {email: "private@example.com"},
      },
    }), {code: "MODEL_INPUT_FORBIDDEN"});
  });

test("fallback uses GuardedModelRunner cache and emits a candidate per field",
  async () => {
    const policy = enabledPolicy(await loadSupplyModelPolicy());
    const store = await new FileOperationsStore(await temporaryDirectory())
      .initialize();
    let providerCalls = 0;
    const provider = fixtureProvider(() => providerCalls += 1);
    const budgets = modelBudgetLedgers({
      policy,
      monthKey: "2026-07",
    });
    const router = createSupplyModelFallback({
      policy,
      policyDecision: acceptedDecision(),
      provider,
      store,
      budgets,
      clock: () => new Date(NOW),
    });
    const first = await router.resolve(fallbackRequest());
    const replay = await router.resolve(fallbackRequest());
    const secondReplay = await router.resolve(fallbackRequest());

    assert.equal(first.route, "model_provider");
    assert.equal(replay.route, "model_cache");
    assert.equal(secondReplay.route, "model_cache");
    assert.equal(first.authority, "proposal_only");
    assert.equal(first.reviewRequired, true);
    assert.equal(providerCalls, 1);
    const candidates = await store.listModelRuleCandidates();
    assert.equal(candidates.length, 2);
    assert.ok(candidates.every((candidate) =>
      candidate.status === "needs_human_fixture" &&
      candidate.activationEligible === false &&
      candidate.activationBlockers.includes(
        "human_verified_fixture_required"
      )));
    assert.equal(budgets.run.snapshot().consumed.modelCalls, 1);
    assert.equal(budgets.month.snapshot().consumed.modelCalls, 1);
    const metrics = await modelDependenceMetrics(store);
    assert.equal(metrics.expectedTrend, "declining");
    assert.equal(metrics.sources[0].modelRoutes, 2);
    assert.equal(metrics.sources[0].providerCalls, 1);
    assert.equal(metrics.sources[0].cacheReplays, 1);
    assert.equal(metrics.sources[0].dependenceRate, 1);
  });

test("monthly cap breach fails closed before the provider call", async () => {
  const policy = enabledPolicy(await loadSupplyModelPolicy());
  const store = await new FileOperationsStore(await temporaryDirectory())
    .initialize();
  let providerCalls = 0;
  const router = createSupplyModelFallback({
    policy,
    policyDecision: acceptedDecision(),
    provider: fixtureProvider(() => providerCalls += 1),
    store,
    budgets: modelBudgetLedgers({
      policy,
      monthKey: "2026-07",
      monthlyConsumed: {
        modelCalls: policy.budgets.maxModelCallsPerMonth,
      },
    }),
    clock: () => new Date(NOW),
  });
  await assert.rejects(router.resolve(fallbackRequest()), {
    code: "BUDGET_EXCEEDED",
  });
  assert.equal(providerCalls, 0);
});

test("each model field enters proposals but cannot evaluate without human fixtures",
  async () => {
    const policy = enabledPolicy(await loadSupplyModelPolicy());
    const store = await new FileOperationsStore(await temporaryDirectory())
      .initialize();
    const router = createSupplyModelFallback({
      policy,
      policyDecision: acceptedDecision(),
      provider: fixtureProvider(),
      store,
      budgets: modelBudgetLedgers({
        policy,
        monthKey: "2026-07",
      }),
      clock: () => new Date(NOW),
    });
    await router.resolve({
      ...fallbackRequest(),
      sourceProfileId: "cntraveller",
      reason: "unstable_source",
      deterministic: {
        attempted: true,
        resolved: false,
        profileFound: true,
        sourceStability: "unstable",
        modelFallbackAllowed: true,
        evidence: {reason: "template_fingerprint_drift"},
      },
    });
    const learner = new SupplyIntakeLearner({
      store,
      clock: () => new Date(NOW),
    });
    const proposal = await learner.propose("cntraveller");
    assert.equal(proposal.modelRuleCandidateIds.length, 2);
    assert.equal(proposal.observations.modelRuleCandidateCount, 2);
    assert.equal(proposal.evaluationEligible, false);
    assert.ok(proposal.activationBlockers.includes(
      "model_candidates_require_human_verified_fixtures"
    ));
    await assert.rejects(learner.evaluate(proposal.proposalId), {
      code: "RULE_PROPOSAL_FIXTURE_REQUIRED",
    });
  });

test("workflow freezes disabled policy and only a reviewed plan can route fallback",
  async () => {
    const disabled = await loadSupplyModelPolicy();
    const store = await new FileOperationsStore(await temporaryDirectory())
      .initialize();
    const router = createSupplyModelFallback({
      policy: disabled,
      store,
      clock: () => new Date(NOW),
    });
    const repoRoot = await createFixtureRepository(
      await temporaryDirectory("catch-model-workflow-")
    );
    const workflow = new SupplyIntakeWorkflow({
      repoRoot,
      extractionRouter: router,
    });
    const plan = await workflow.createPlan({
      market: "mumbai",
      through: "2026-07-28",
      now: NOW,
      intakeScope: "organizer",
    });
    assert.equal(plan.capabilities.modelCalls, false);
    assert.equal(plan.budgets.modelCalls, 0);
    await assert.rejects(
      workflow.resolveExtraction(plan, fallbackRequest()),
      {code: "UNSAFE_CAPABILITY"}
    );
  });

function fallbackRequest() {
  return {
    sourceProfileId: "unknown-events-site",
    artifactHash: ARTIFACT_HASH,
    observedAt: NOW,
    sourceUrl: "https://events.example/courtside",
    reason: "unknown_source",
    deterministic: {
      attempted: true,
      resolved: false,
      profileFound: false,
      evidence: {reason: "no_source_profile"},
    },
    input: {excerpt: "Courtside Social · 8 PM · Bandra"},
    estimatedInputTokens: 20,
    maxOutputTokens: 30,
    maxCostMicros: 500,
  };
}

function enabledPolicy(base) {
  return {
    ...base,
    policyVersion: "supply-model-fixture-v1",
    provider: {
      ...base.provider,
      enabled: true,
      adapterId: "fixture-provider",
      modelId: "fixture-model",
      decisionId: "llm-policy-decision-2026-07",
    },
    budgets: {
      maxModelCallsPerRun: 2,
      maxInputTokensPerRun: 100,
      maxOutputTokensPerRun: 100,
      maxCostMicrosPerRun: 2_000,
      maxModelCallsPerMonth: 4,
      maxInputTokensPerMonth: 200,
      maxOutputTokensPerMonth: 200,
      maxCostMicrosPerMonth: 4_000,
    },
  };
}

function acceptedDecision() {
  return {
    gapId: "llm_extraction_fallback_policy",
    decisionId: "llm-policy-decision-2026-07",
    decision: "accept",
    decisionStatus: "accepted",
    operationalState: "blocked_until_policy_encoded",
    checklist: {
      requiredInputsReviewed: true,
      costAndSafetyReviewed: true,
      implementationOwnerReviewed: true,
      behaviorStillDisabledAcknowledged: true,
    },
  };
}

function fixtureProvider(onCall = () => {}) {
  return {
    run: async () => {
      onCall();
      return {
        output: {
          fields: [
            {
              field: "title",
              value: "Courtside Social",
              confidence: 0.94,
              evidenceLocator: "text:Courtside Social",
            },
            {
              field: "venueName",
              value: "Bandra Padel",
              confidence: 0.81,
              evidenceLocator: "text:Bandra",
            },
          ],
          identityResolution: {
            status: "not_applicable",
            candidateKey: null,
            rationale: null,
          },
          abstained: false,
          uncertainties: ["End time was not present."],
        },
        usage: {
          inputTokens: 12,
          outputTokens: 18,
          costMicros: 200,
        },
      };
    },
  };
}
