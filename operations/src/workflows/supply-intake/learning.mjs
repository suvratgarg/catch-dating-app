import fs from "node:fs/promises";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {hashValue, shortHash} from "../../platform/canonical-json.mjs";
import {OperationsError, invariant} from "../../platform/errors.mjs";
import {extractCnTravellerLeads} from "./sources/cntraveller/extractor.mjs";
import {extractLumaEvents} from "./sources/luma/extractor.mjs";

const directory = path.dirname(fileURLToPath(import.meta.url));
const SUPPORTED_SOURCES = Object.freeze({
  cntraveller: {
    extractorId: "editorial_link_card_v1",
    fixture: "cntraveller.editorial_link_card_v1.json",
    minimumOperationalSupport: 25,
  },
  luma: {
    extractorId: "json_ld_event_v1",
    fixture: "luma.json_ld_event_v1.json",
    minimumOperationalSupport: 25,
  },
});

export class SupplyIntakeLearner {
  constructor({store, clock = () => new Date()} = {}) {
    this.store = store;
    this.clock = clock;
  }

  async propose(sourceProfileId) {
    const source = SUPPORTED_SOURCES[sourceProfileId];
    invariant(source, "SOURCE_NOT_SUPPORTED", `No rule-learning adapter exists for ${sourceProfileId}.`);
    const items = (await this.store.listWorkItems({sourceProfileId}));
    const observations = summarizeObservations(items);
    const basis = {
      schemaVersion: 1,
      sourceProfileId,
      extractorId: source.extractorId,
      fixtureSet: source.fixture,
      observations,
      candidateRule: candidateRule(sourceProfileId),
    };
    const proposalId = `rule-${sourceProfileId}-${shortHash(basis)}`;
    const existing = await this.store.getRuleProposal(proposalId);
    if (existing) return existing;
    const proposal = {
      ...basis,
      proposalId,
      proposalHash: hashValue(basis),
      lifecycleStatus: "proposed",
      proposedAt: this.now(),
      evaluationEligible: true,
      activationEligible: observations.supportCount >= source.minimumOperationalSupport,
      activationBlockers: observations.supportCount >= source.minimumOperationalSupport ? [] : [
        `minimum_operational_support_${source.minimumOperationalSupport}_not_met`,
      ],
      guardrails: [
        "Proposal generation does not edit or deploy extractor code.",
        "Gold fixtures must not be generated solely from prior model answers.",
        "Activation requires holdout evaluation, shadow canary, review, and a separately authorized deployment.",
      ],
    };
    return this.store.putRuleProposal(proposal);
  }

  async evaluate(proposalId) {
    const proposal = await this.store.getRuleProposal(proposalId);
    if (!proposal) throw new OperationsError("RULE_PROPOSAL_NOT_FOUND", `Rule proposal ${proposalId} was not found.`, {exitCode: 2});
    const fixture = await readFixture(proposal.fixtureSet);
    const results = fixture.cases.map((testCase) => evaluateCase(proposal.sourceProfileId, testCase));
    const totalExpected = results.reduce((sum, result) => sum + result.expected, 0);
    const exact = results.reduce((sum, result) => sum + result.exactMatches, 0);
    const falsePositive = results.reduce((sum, result) => sum + result.falsePositives, 0);
    const falseNegative = results.reduce((sum, result) => sum + result.falseNegatives, 0);
    const precision = exact + falsePositive === 0 ? 1 : exact / (exact + falsePositive);
    const recall = totalExpected === 0 ? 1 : exact / totalExpected;
    const passed = precision === 1 && recall === 1 && results.every((result) => result.passed);
    const basis = {proposalId, proposalHash: proposal.proposalHash, fixtureSetId: fixture.fixtureSetId, fixtureHash: hashValue(fixture), results};
    const evaluation = {
      schemaVersion: 1,
      evaluationId: `evaluation-${shortHash(basis)}`,
      ...basis,
      evaluatedAt: this.now(),
      status: passed ? "passed" : "failed",
      metrics: {cases: results.length, expectedRecords: totalExpected, exactMatches: exact, falsePositives: falsePositive, falseNegatives: falseNegative, precision, recall},
      canaryEligible: passed,
    };
    await this.store.putRuleEvaluation(evaluation);
    await this.store.putRuleProposal({...proposal, lifecycleStatus: passed ? "evaluated" : "evaluation_failed", latestEvaluationId: evaluation.evaluationId});
    return evaluation;
  }

  async canary(proposalId) {
    const proposal = await this.store.getRuleProposal(proposalId);
    if (!proposal) throw new OperationsError("RULE_PROPOSAL_NOT_FOUND", `Rule proposal ${proposalId} was not found.`, {exitCode: 2});
    const evaluations = (await this.store.listRuleEvaluations()).filter((evaluation) => evaluation.proposalId === proposalId && evaluation.status === "passed");
    const evaluation = evaluations.sort((left, right) => right.evaluatedAt.localeCompare(left.evaluatedAt))[0];
    invariant(evaluation, "RULE_EVALUATION_REQUIRED", "A passing evaluation is required before shadow canary creation.");
    const basis = {proposalId, proposalHash: proposal.proposalHash, evaluationId: evaluation.evaluationId, mode: "shadow"};
    const canary = {
      schemaVersion: 1,
      canaryId: `canary-${shortHash(basis)}`,
      ...basis,
      createdAt: this.now(),
      status: "shadow_canary",
      trafficBasisPoints: 0,
      activationAllowed: false,
      deploymentAllowed: false,
      activationBlockers: [
        ...proposal.activationBlockers,
        "human_rule_review_required",
        "deployment_pr_required",
        "production_capability_not_granted",
      ],
      rollbackSignalIds: ["template_fingerprint_drift", "field_accuracy_regression", "correction_rate_regression"],
    };
    await this.store.putRuleCanary(canary);
    await this.store.putRuleProposal({...proposal, lifecycleStatus: "shadow_canary", latestCanaryId: canary.canaryId});
    return canary;
  }

  async status() {
    const [proposals, evaluations, canaries] = await Promise.all([
      this.store.listRuleProposals(),
      this.store.listRuleEvaluations(),
      this.store.listRuleCanaries(),
    ]);
    return {
      schemaVersion: 1,
      summary: {
        proposals: proposals.length,
        evaluations: evaluations.length,
        passingEvaluations: evaluations.filter((evaluation) => evaluation.status === "passed").length,
        shadowCanaries: canaries.filter((canary) => canary.status === "shadow_canary").length,
        activatedRules: 0,
      },
      proposals,
      evaluations,
      canaries,
    };
  }

  now() {
    return new Date(this.clock()).toISOString();
  }
}

function summarizeObservations(items) {
  const failureReasons = new Map();
  for (const item of items) {
    for (const blocker of item.blockers) failureReasons.set(blocker, (failureReasons.get(blocker) ?? 0) + 1);
    for (const flag of item.taskFlags) failureReasons.set(flag, (failureReasons.get(flag) ?? 0) + 1);
  }
  return {
    supportCount: items.length,
    artifactCount: new Set(items.map((item) => item.evidence.artifactHash)).size,
    failureReasons: Object.fromEntries([...failureReasons.entries()].sort(([left], [right]) => left.localeCompare(right))),
  };
}

function candidateRule(sourceProfileId) {
  if (sourceProfileId === "cntraveller") return {
    kind: "declarative_extractor_config",
    templateFamily: "editorial_link_card",
    version: 1,
    mappings: {title: "card.heading", dateText: "card.dateText", venueText: "card.venueText", links: "card.links"},
    invariantOutputs: {discoveryOnly: true, requiresOfficialSource: true},
    onTemplateMismatch: "abstain",
  };
  return {
    kind: "deterministic_extractor",
    templateFamily: "schema_org_event_json_ld",
    version: 1,
    requiredTypes: ["Event"],
    onTemplateMismatch: "abstain",
  };
}

async function readFixture(name) {
  return JSON.parse(await fs.readFile(path.join(directory, "fixtures", name), "utf8"));
}

function evaluateCase(sourceProfileId, testCase) {
  const actual = sourceProfileId === "cntraveller" ?
    extractCnTravellerLeads(testCase.input).leads :
    extractLumaEvents(testCase.input).events;
  const expectedKeys = testCase.expected.map(recordKey);
  const actualKeys = actual.map((record) => recordKey(projectComparable(record, testCase.expected)));
  const expectedSet = new Set(expectedKeys);
  const actualSet = new Set(actualKeys);
  const exactMatches = [...expectedSet].filter((key) => actualSet.has(key)).length;
  const falsePositives = [...actualSet].filter((key) => !expectedSet.has(key)).length;
  const falseNegatives = [...expectedSet].filter((key) => !actualSet.has(key)).length;
  return {
    caseId: testCase.caseId,
    expected: expectedSet.size,
    actual: actualSet.size,
    exactMatches,
    falsePositives,
    falseNegatives,
    passed: falsePositives === 0 && falseNegatives === 0,
  };
}

function projectComparable(actual, expectedRecords) {
  const keys = new Set(expectedRecords.flatMap((record) => Object.keys(record)));
  return Object.fromEntries([...keys].sort().map((key) => [key, actual[key] ?? null]));
}

function recordKey(record) {
  return hashValue(record);
}
