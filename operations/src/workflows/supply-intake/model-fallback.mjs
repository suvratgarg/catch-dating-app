import fs from "node:fs/promises";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {BudgetLedger} from "../../platform/budget.mjs";
import {hashValue, shortHash} from "../../platform/canonical-json.mjs";
import {OperationsError, invariant} from "../../platform/errors.mjs";
import {validateJsonSchema} from "../../platform/json-schema.mjs";
import {
  GuardedModelRunner,
  modelCachePort,
} from "../../platform/model/guarded-model-runner.mjs";

const directory = path.dirname(fileURLToPath(import.meta.url));
const policyPath = path.join(directory, "config", "model_policy.json");
const schemaPath = path.join(
  directory,
  "config",
  "model_policy.schema.json"
);
const ALLOWED_REASONS = Object.freeze([
  "unknown_source",
  "unstable_source",
  "ambiguous_identity",
]);
const ALLOWED_FIELDS = Object.freeze([
  "title",
  "startAt",
  "endAt",
  "venueName",
  "venueAddress",
  "locality",
  "organizerName",
  "organizerUrl",
  "sourceUrl",
  "formats",
]);
const FORBIDDEN_INPUT_KEYS = new Set([
  "uid",
  "userId",
  "email",
  "phone",
  "phoneNumber",
  "datingProfile",
  "rankingTarget",
  "copyBrief",
]);

export async function loadSupplyModelPolicy({readFile = fs.readFile} = {}) {
  const [policyText, schemaText] = await Promise.all([
    readFile(policyPath, "utf8"),
    readFile(schemaPath, "utf8"),
  ]);
  const policy = JSON.parse(policyText);
  const schema = JSON.parse(schemaText);
  const validation = validateJsonSchema(schema, policy);
  if (!validation.valid) {
    throw new OperationsError(
      "INVALID_MODEL_POLICY",
      "Supply Intake model policy does not satisfy its schema.",
      {details: {errors: validation.errors}}
    );
  }
  assertModelPolicy(policy);
  return structuredClone(policy);
}

export function modelBudgetLedgers({
  policy,
  monthKey,
  runConsumed = {},
  monthlyConsumed = {},
}) {
  assertModelPolicy(policy);
  invariant(
    /^\d{4}-\d{2}$/.test(monthKey ?? ""),
    "INVALID_MODEL_BUDGET",
    "The model monthly budget requires a YYYY-MM window."
  );
  return {
    monthKey,
    run: new BudgetLedger({
      limits: runBudget(policy),
      consumed: runConsumed,
    }),
    month: new BudgetLedger({
      limits: monthBudget(policy),
      consumed: monthlyConsumed,
    }),
  };
}

export function createSupplyModelFallback({
  policy,
  policyDecision = null,
  provider = null,
  store,
  budgets,
  clock,
} = {}) {
  assertModelPolicy(policy);
  invariant(
    store &&
      typeof store.getModelCache === "function" &&
      typeof store.putModelCache === "function",
    "MODEL_STORE_REQUIRED",
    "Supply model fallback requires the Operations cache and evidence store."
  );
  if (policy.provider.enabled) {
    assertAcceptedModelPolicyDecision(policyDecision, policy);
    assertModelBudgets(budgets, policy);
  }
  const disabledBudgets = budgets ?? modelBudgetLedgers({
    policy,
    monthKey: "1970-01",
  });
  const runner = new GuardedModelRunner({
    enabled: policy.provider.enabled,
    provider,
    cache: modelCachePort(store),
    budget: disabledBudgets.run,
    monthlyBudget: disabledBudgets.month,
    monthlyWindow: disabledBudgets.monthKey,
    modelId: policy.provider.modelId ?? "disabled",
  });
  return new SupplyIntakeExtractionRouter({
    policy,
    runner,
    store,
    clock,
  });
}

export class SupplyIntakeExtractionRouter {
  constructor({
    policy,
    runner,
    store,
    clock = () => new Date(),
  } = {}) {
    assertModelPolicy(policy);
    invariant(
      runner && typeof runner.run === "function",
      "MODEL_RUNNER_REQUIRED",
      "Supply extraction fallback requires GuardedModelRunner."
    );
    invariant(
      store &&
        typeof store.putModelRuleCandidate === "function" &&
        typeof store.putModelRoutingRecord === "function",
      "MODEL_STORE_REQUIRED",
      "Supply extraction fallback requires durable candidate and metric ports."
    );
    this.policy = structuredClone(policy);
    this.runner = runner;
    this.store = store;
    this.clock = clock;
  }

  async resolve(request) {
    assertRoutingRequest(request);
    const deterministic = request.deterministic;
    if (deterministic.resolved === true) {
      const result = {
        route: "deterministic",
        authority: "deterministic",
        reviewRequired: false,
        output: structuredClone(deterministic.output),
        provenance: {
          sourceProfileId: request.sourceProfileId,
          artifactHash: request.artifactHash,
          reason: null,
          model: null,
        },
      };
      await this.recordRouting(request, result, 0);
      return result;
    }
    assertFallbackEligibility(request);
    assertSafeModelInput(request.input);
    assertSafeDeterministicEvidence(request.deterministic.evidence);
    const response = await this.runner.run({
      task: "supply-extraction-fallback",
      promptVersion: this.policy.provider.promptVersion,
      input: {
        sourceProfileId: request.sourceProfileId,
        reason: request.reason,
        artifactHash: request.artifactHash,
        sourceUrl: request.sourceUrl ?? null,
        excerpt: request.input.excerpt,
        deterministicEvidence:
          request.deterministic.evidence ?? null,
      },
      outputSchema: extractionOutputSchema(),
      estimatedInputTokens: request.estimatedInputTokens,
      maxOutputTokens: request.maxOutputTokens,
      maxCostMicros: request.maxCostMicros,
    });
    for (const field of response.output.fields) {
      await this.store.putModelRuleCandidate(modelRuleCandidate({
        request,
        field,
        response,
        at: request.observedAt,
      }));
    }
    const result = {
      route: response.provenance.cacheHit ?
        "model_cache" :
        "model_provider",
      authority: "proposal_only",
      reviewRequired: true,
      output: response.output,
      provenance: {
        sourceProfileId: request.sourceProfileId,
        artifactHash: request.artifactHash,
        reason: request.reason,
        model: response.provenance,
        ruleProposalCandidateCount: response.output.fields.length,
      },
    };
    await this.recordRouting(request, result, response.output.fields.length);
    return result;
  }

  async recordRouting(request, result, modelFieldCount) {
    const basis = {
      sourceProfileId: request.sourceProfileId,
      artifactHash: request.artifactHash,
      route: result.route,
      outputHash: hashValue(result.output),
    };
    await this.store.putModelRoutingRecord({
      schemaVersion: 1,
      routingId: `model-route-${shortHash(basis)}`,
      ...basis,
      fallbackReason: request.reason ?? null,
      modelFieldCount,
      cacheHit: result.route === "model_cache",
      providerCalled: result.route === "model_provider",
      routedAt: request.observedAt,
    });
  }

  now() {
    return new Date(this.clock()).toISOString();
  }
}

export async function modelDependenceMetrics(store) {
  const records = await store.listModelRoutingRecords();
  const sources = new Map();
  for (const record of records) {
    const current = sources.get(record.sourceProfileId) ?? {
      sourceProfileId: record.sourceProfileId,
      extractionRoutes: 0,
      deterministicRoutes: 0,
      modelRoutes: 0,
      providerCalls: 0,
      cacheReplays: 0,
      modelFields: 0,
    };
    current.extractionRoutes += 1;
    if (record.route === "deterministic") current.deterministicRoutes += 1;
    else current.modelRoutes += 1;
    if (record.providerCalled) current.providerCalls += 1;
    if (record.cacheHit) current.cacheReplays += 1;
    current.modelFields += record.modelFieldCount;
    sources.set(record.sourceProfileId, current);
  }
  return {
    schemaVersion: 1,
    metric: "per_source_llm_dependence",
    expectedTrend: "declining",
    sources: [...sources.values()]
      .map((source) => ({
        ...source,
        dependenceRate: source.extractionRoutes === 0 ?
          0 :
          source.modelRoutes / source.extractionRoutes,
      }))
      .sort((left, right) =>
        left.sourceProfileId.localeCompare(right.sourceProfileId)),
  };
}

function modelRuleCandidate({request, field, response, at}) {
  const basis = {
    sourceProfileId: request.sourceProfileId,
    artifactHash: request.artifactHash,
    field: field.field,
    extractedValue: field.value,
    promptVersion: response.provenance.promptVersion,
    modelId: response.provenance.modelId,
  };
  return {
    schemaVersion: 1,
    candidateId: `model-rule-${shortHash(basis)}`,
    ...basis,
    confidence: field.confidence,
    evidenceLocator: field.evidenceLocator,
    status: "needs_human_fixture",
    activationEligible: false,
    activationBlockers: [
      "human_verified_fixture_required",
      "reviewed_rule_proposal_required",
    ],
    proposedAt: at,
  };
}

function assertRoutingRequest(request) {
  invariant(
    request &&
      typeof request.sourceProfileId === "string" &&
      request.sourceProfileId.length > 0 &&
      request.sourceProfileId.length <= 160,
    "INVALID_MODEL_FALLBACK_REQUEST",
    "A bounded source profile id is required."
  );
  invariant(
    /^[a-f0-9]{64}$/.test(request.artifactHash ?? ""),
    "INVALID_MODEL_FALLBACK_REQUEST",
    "A SHA-256 artifact hash is required."
  );
  invariant(
    request.deterministic?.attempted === true &&
      typeof request.deterministic.resolved === "boolean",
    "DETERMINISTIC_EXTRACTION_REQUIRED",
    "The deterministic extractor must run before model routing."
  );
  invariant(
    typeof request.observedAt === "string" &&
      Number.isFinite(Date.parse(request.observedAt)),
    "INVALID_MODEL_FALLBACK_REQUEST",
    "Model routing requires the immutable artifact observation time."
  );
}

function assertFallbackEligibility(request) {
  invariant(
    ALLOWED_REASONS.includes(request.reason),
    "MODEL_PLACEMENT_FORBIDDEN",
    "Model fallback is limited to unknown, unstable, or ambiguous extraction."
  );
  if (request.reason === "unknown_source") {
    invariant(
      request.deterministic.profileFound === false,
      "MODEL_PLACEMENT_FORBIDDEN",
      "Unknown-source fallback requires a missing deterministic profile."
    );
  }
  if (request.reason === "unstable_source") {
    invariant(
      request.deterministic.profileFound === true &&
        request.deterministic.sourceStability === "unstable" &&
        request.deterministic.modelFallbackAllowed === true,
      "MODEL_PLACEMENT_FORBIDDEN",
      "Unstable-source fallback requires an explicitly unstable profile that opts into fallback."
    );
  }
  if (request.reason === "ambiguous_identity") {
    invariant(
      request.deterministic.identityScorecard?.evaluated === true &&
        request.deterministic.identityScorecard?.resolution === "ambiguous",
      "MODEL_PLACEMENT_FORBIDDEN",
      "Identity fallback requires an unresolved deterministic scorecard."
    );
  }
}

function assertSafeModelInput(input) {
  invariant(
    input &&
      typeof input === "object" &&
      typeof input.excerpt === "string" &&
      input.excerpt.length > 0 &&
      input.excerpt.length <= 20_000,
    "INVALID_MODEL_FALLBACK_REQUEST",
    "Model fallback accepts only a bounded source excerpt."
  );
  const forbidden = [];
  visitKeys(input, (key) => {
    if (FORBIDDEN_INPUT_KEYS.has(key)) forbidden.push(key);
  });
  invariant(
    forbidden.length === 0,
    "MODEL_INPUT_FORBIDDEN",
    "Per-user, ranking, contact, and copy-generation inputs are forbidden.",
    {forbidden: [...new Set(forbidden)].sort()}
  );
}

function assertSafeDeterministicEvidence(evidence) {
  if (evidence === undefined || evidence === null) return;
  invariant(
    typeof evidence === "object" &&
      Buffer.byteLength(JSON.stringify(evidence), "utf8") <= 8_192,
    "INVALID_MODEL_FALLBACK_REQUEST",
    "Deterministic fallback evidence must be a bounded object."
  );
  const forbidden = [];
  visitKeys(evidence, (key) => {
    if (FORBIDDEN_INPUT_KEYS.has(key)) forbidden.push(key);
  });
  invariant(
    forbidden.length === 0,
    "MODEL_INPUT_FORBIDDEN",
    "Deterministic evidence cannot add per-user, ranking, contact, or copy-generation inputs.",
    {forbidden: [...new Set(forbidden)].sort()}
  );
}

function visitKeys(value, visitor) {
  if (Array.isArray(value)) {
    for (const item of value) visitKeys(item, visitor);
    return;
  }
  if (!value || typeof value !== "object") return;
  for (const [key, child] of Object.entries(value)) {
    visitor(key);
    visitKeys(child, visitor);
  }
}

function extractionOutputSchema() {
  return {
    type: "object",
    additionalProperties: false,
    required: ["fields", "identityResolution", "abstained", "uncertainties"],
    properties: {
      fields: {
        type: "array",
        maxItems: ALLOWED_FIELDS.length,
        items: {
          type: "object",
          additionalProperties: false,
          required: ["field", "value", "confidence", "evidenceLocator"],
          properties: {
            field: {type: "string", enum: [...ALLOWED_FIELDS]},
            value: {
              anyOf: [
                {type: "string", maxLength: 2000},
                {type: "null"},
                {
                  type: "array",
                  maxItems: 20,
                  items: {type: "string", maxLength: 500},
                },
              ],
            },
            confidence: {type: "number", minimum: 0, maximum: 1},
            evidenceLocator: {
              type: ["string", "null"],
              maxLength: 1000,
            },
          },
        },
      },
      identityResolution: {
        type: "object",
        additionalProperties: false,
        required: ["status", "candidateKey", "rationale"],
        properties: {
          status: {
            type: "string",
            enum: ["not_applicable", "resolved", "ambiguous"],
          },
          candidateKey: {type: ["string", "null"], maxLength: 500},
          rationale: {type: ["string", "null"], maxLength: 1000},
        },
      },
      abstained: {type: "boolean"},
      uncertainties: {
        type: "array",
        maxItems: 20,
        items: {type: "string", minLength: 1, maxLength: 500},
      },
    },
  };
}

function assertModelPolicy(policy) {
  invariant(
    policy?.schemaVersion === 1 &&
      typeof policy.policyVersion === "string" &&
      policy.provider &&
      policy.placement &&
      policy.budgets &&
      policy.metrics?.expectedTrend === "declining" &&
      hashValue(policy.placement.allowedReasons) ===
        hashValue(ALLOWED_REASONS) &&
      hashValue(policy.placement.forbiddenUses) ===
        hashValue(["copy_generation", "ranking", "per_user_path"]),
    "INVALID_MODEL_POLICY",
    "Supply model policy is missing required fail-closed controls."
  );
  const budgets = Object.values(policy.budgets);
  invariant(
    budgets.every((value) => Number.isSafeInteger(value) && value >= 0),
    "INVALID_MODEL_POLICY",
    "Supply model budgets must be non-negative safe integers."
  );
  if (!policy.provider.enabled) {
    invariant(
      policy.provider.adapterId === null &&
        policy.provider.modelId === null &&
        policy.provider.decisionId === null &&
        budgets.every((value) => value === 0),
      "INVALID_MODEL_POLICY",
      "Disabled model policy must retain null provider identity and zero caps."
    );
  }
}

function assertAcceptedModelPolicyDecision(decision, policy) {
  invariant(
    decision?.gapId === policy.provider.policyGapId &&
      decision.decisionId === policy.provider.decisionId &&
      decision.decision === "accept" &&
      decision.decisionStatus === "accepted" &&
      decision.operationalState === "blocked_until_policy_encoded" &&
      decision.checklist?.requiredInputsReviewed === true &&
      decision.checklist?.costAndSafetyReviewed === true &&
      decision.checklist?.implementationOwnerReviewed === true &&
      decision.checklist?.behaviorStillDisabledAcknowledged === true,
    "MODEL_POLICY_DECISION_REQUIRED",
    "Enabled model fallback requires the exact reviewed policy-gap decision."
  );
}

function assertModelBudgets(budgets, policy) {
  invariant(
    budgets &&
      /^\d{4}-\d{2}$/.test(budgets.monthKey ?? "") &&
      budgets.run?.snapshot &&
      budgets.month?.snapshot &&
      hashValue(budgets.run.snapshot().limits) ===
        hashValue(new BudgetLedger({limits: runBudget(policy)}).snapshot().limits) &&
      hashValue(budgets.month.snapshot().limits) ===
        hashValue(new BudgetLedger({limits: monthBudget(policy)}).snapshot().limits),
    "MODEL_BUDGET_MISMATCH",
    "Run and monthly model ledgers must match the frozen policy ceilings."
  );
}

function runBudget(policy) {
  return {
    modelCalls: policy.budgets.maxModelCallsPerRun,
    modelInputTokens: policy.budgets.maxInputTokensPerRun,
    modelOutputTokens: policy.budgets.maxOutputTokensPerRun,
    modelCostMicros: policy.budgets.maxCostMicrosPerRun,
  };
}

function monthBudget(policy) {
  return {
    modelCalls: policy.budgets.maxModelCallsPerMonth,
    modelInputTokens: policy.budgets.maxInputTokensPerMonth,
    modelOutputTokens: policy.budgets.maxOutputTokensPerMonth,
    modelCostMicros: policy.budgets.maxCostMicrosPerMonth,
  };
}
