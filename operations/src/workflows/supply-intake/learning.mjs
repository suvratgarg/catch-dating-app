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
  constructor({
    store,
    clock = () => new Date(),
    candidateRuleFactory = candidateRule,
  } = {}) {
    this.store = store;
    this.clock = clock;
    this.candidateRuleFactory = candidateRuleFactory;
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
      candidateRule: this.candidateRuleFactory(sourceProfileId),
    };
    const proposalId = `rule-${sourceProfileId}-${shortHash(basis)}`;
    const existing = await this.store.getRuleProposal(proposalId);
    if (existing) {
      assertFrozenProposal(existing);
      return existing;
    }
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
    await this.store.putRuleProposal(proposal);
    await this.recordAction("rule.proposed", proposal.proposedAt, proposalId, {
      proposalHash: proposal.proposalHash,
      sourceProfileId,
    });
    return proposal;
  }

  async evaluate(proposalId) {
    return this.withProposalGuard(proposalId, () => this.evaluateUnlocked(proposalId));
  }

  async evaluateUnlocked(proposalId) {
    const proposal = await this.store.getRuleProposal(proposalId);
    if (!proposal) throw new OperationsError("RULE_PROPOSAL_NOT_FOUND", `Rule proposal ${proposalId} was not found.`, {exitCode: 2});
    assertFrozenProposal(proposal);
    const fixture = await readFixture(proposal.fixtureSet);
    invariant(
      fixture.sourceProfileId === proposal.sourceProfileId,
      "CORRUPT_RULE_FIXTURE",
      "Rule fixture source does not match its frozen proposal."
    );
    const executeCandidate = compileCandidateRule(proposal.candidateRule);
    const results = fixture.cases.map((testCase) =>
      evaluateCase(executeCandidate, testCase));
    const totalExpected = results.reduce((sum, result) => sum + result.expected, 0);
    const exact = results.reduce((sum, result) => sum + result.exactMatches, 0);
    const falsePositive = results.reduce((sum, result) => sum + result.falsePositives, 0);
    const falseNegative = results.reduce((sum, result) => sum + result.falseNegatives, 0);
    const precision = exact + falsePositive === 0 ? 1 : exact / (exact + falsePositive);
    const recall = totalExpected === 0 ? 1 : exact / totalExpected;
    const passed = precision === 1 && recall === 1 && results.every((result) => result.passed);
    const evaluatedAt = this.now();
    const basis = {
      proposalId,
      proposalHash: proposal.proposalHash,
      fixtureSetId: fixture.fixtureSetId,
      fixtureHash: hashValue(fixture),
      evaluatedAt,
      results,
    };
    const evaluation = {
      schemaVersion: 1,
      evaluationId: `evaluation-${shortHash(basis)}`,
      ...basis,
      status: passed ? "passed" : "failed",
      metrics: {cases: results.length, expectedRecords: totalExpected, exactMatches: exact, falsePositives: falsePositive, falseNegatives: falseNegative, precision, recall},
      canaryEligible: passed,
    };
    await this.store.putRuleEvaluation(evaluation);
    await this.store.putRuleProposal({...proposal, lifecycleStatus: passed ? "evaluated" : "evaluation_failed", latestEvaluationId: evaluation.evaluationId});
    await this.recordAction("rule.evaluated", evaluatedAt, proposalId, {
      evaluationId: evaluation.evaluationId,
      status: evaluation.status,
      fixtureHash: evaluation.fixtureHash,
    });
    return evaluation;
  }

  async canary(proposalId) {
    return this.withProposalGuard(proposalId, () => this.canaryUnlocked(proposalId));
  }

  async canaryUnlocked(proposalId) {
    let proposal = await this.store.getRuleProposal(proposalId);
    if (!proposal) throw new OperationsError("RULE_PROPOSAL_NOT_FOUND", `Rule proposal ${proposalId} was not found.`, {exitCode: 2});
    assertFrozenProposal(proposal);
    const evaluation = latestEvaluation(
      (await this.store.listRuleEvaluations()).filter((candidate) => candidate.proposalId === proposalId)
    );
    invariant(
      evaluation,
      "LATEST_RULE_EVALUATION_NOT_PASSED",
      "The proposal must have an immutable evaluation before shadow canary creation."
    );
    const repairedLifecycle = evaluation.status === "passed" ? "evaluated" : "evaluation_failed";
    if (proposal.latestEvaluationId !== evaluation.evaluationId ||
        proposal.lifecycleStatus !== repairedLifecycle) {
      proposal = await this.store.putRuleProposal({
        ...proposal,
        lifecycleStatus: repairedLifecycle,
        latestEvaluationId: evaluation.evaluationId,
      });
    }
    invariant(
      evaluation?.proposalHash === proposal.proposalHash &&
        evaluation.status === "passed" &&
        evaluation.canaryEligible === true,
      "LATEST_RULE_EVALUATION_NOT_PASSED",
      "The proposal's latest evaluation must pass before shadow canary creation."
    );
    const createdAt = this.now();
    const basis = {
      proposalId,
      proposalHash: proposal.proposalHash,
      evaluationId: evaluation.evaluationId,
      mode: "shadow",
      createdAt,
    };
    const canary = {
      schemaVersion: 1,
      canaryId: `canary-${shortHash(basis)}`,
      ...basis,
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
    await this.recordAction("rule.canary_created", createdAt, proposalId, {
      canaryId: canary.canaryId,
      evaluationId: evaluation.evaluationId,
      activationAllowed: canary.activationAllowed,
    });
    return canary;
  }

  async withProposalGuard(proposalId, work) {
    invariant(
      typeof this.store.withLeaseGuard === "function",
      "LEARNING_SERIALIZATION_UNAVAILABLE",
      "Rule learning requires a serialized proposal guard."
    );
    return this.store.withLeaseGuard(`learning:${proposalId}`, work);
  }

  async status() {
    const [proposals, evaluations, canaries, actions] = await Promise.all([
      this.store.listRuleProposals(),
      this.store.listRuleEvaluations(),
      this.store.listRuleCanaries(),
      this.store.listLearningActions(),
    ]);
    return {
      schemaVersion: 1,
      summary: {
        proposals: proposals.length,
        evaluations: evaluations.length,
        passingEvaluations: evaluations.filter((evaluation) => evaluation.status === "passed").length,
        shadowCanaries: canaries.filter((canary) => canary.status === "shadow_canary").length,
        activatedRules: 0,
        actions: actions.length,
      },
      proposals,
      evaluations,
      canaries,
      actions,
    };
  }

  async recordAction(type, at, proposalId, payload) {
    const action = {
      schemaVersion: 1,
      actionId: `learning-${shortHash({type, at, proposalId, payload})}`,
      type,
      at,
      proposalId,
      payload,
      payloadHash: hashValue(payload),
    };
    return this.store.appendLearningAction(action);
  }

  now() {
    return new Date(this.clock()).toISOString();
  }
}

function latestEvaluation(evaluations) {
  const ordered = evaluations.map((evaluation) => {
    const evaluatedAtEpoch = Date.parse(evaluation.evaluatedAt);
    invariant(
      typeof evaluation.evaluationId === "string" &&
        typeof evaluation.evaluatedAt === "string" &&
        !Number.isNaN(evaluatedAtEpoch),
      "CORRUPT_RULE_EVALUATION",
      "Rule evaluation evidence has an invalid identity or timestamp."
    );
    return {evaluation, evaluatedAtEpoch};
  }).sort((left, right) => right.evaluatedAtEpoch - left.evaluatedAtEpoch);
  if (ordered.length > 1 &&
      ordered[0].evaluatedAtEpoch === ordered[1].evaluatedAtEpoch &&
      ordered[0].evaluation.evaluationId !== ordered[1].evaluation.evaluationId) {
    throw new OperationsError(
      "AMBIGUOUS_RULE_EVALUATION_ORDER",
      "Distinct rule evaluations share the latest instant; canary ordering fails closed."
    );
  }
  return ordered[0]?.evaluation ?? null;
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
    implementationId: "cntraveller-editorial-link-card-v1",
    mappings: {title: "card.heading", dateText: "card.dateText", venueText: "card.venueText", links: "card.links"},
    invariantOutputs: {discoveryOnly: true, requiresOfficialSource: true},
    onTemplateMismatch: "abstain",
  };
  return {
    kind: "deterministic_extractor",
    templateFamily: "schema_org_event_json_ld",
    version: 1,
    implementationId: "luma-json-ld-event-v1",
    requiredTypes: ["Event"],
    onTemplateMismatch: "abstain",
  };
}

async function readFixture(name) {
  return JSON.parse(await fs.readFile(path.join(directory, "fixtures", name), "utf8"));
}

function evaluateCase(executeCandidate, testCase) {
  const actual = executeCandidate(testCase.input);
  const expectedKeys = testCase.expected.map(recordKey);
  const actualKeys = actual.map((record) => recordKey(projectComparable(record, testCase.expected)));
  const expectedCounts = frequencies(expectedKeys);
  const actualCounts = frequencies(actualKeys);
  const keys = new Set([...expectedCounts.keys(), ...actualCounts.keys()]);
  const exactMatches = [...keys].reduce((sum, key) =>
    sum + Math.min(expectedCounts.get(key) ?? 0, actualCounts.get(key) ?? 0), 0);
  const falsePositives = actualKeys.length - exactMatches;
  const falseNegatives = expectedKeys.length - exactMatches;
  return {
    caseId: testCase.caseId,
    expected: expectedKeys.length,
    actual: actualKeys.length,
    exactMatches,
    falsePositives,
    falseNegatives,
    passed: falsePositives === 0 && falseNegatives === 0,
  };
}

function assertFrozenProposal(proposal) {
  const source = SUPPORTED_SOURCES[proposal?.sourceProfileId];
  invariant(
    proposal?.schemaVersion === 1 &&
      source &&
      proposal.extractorId === source.extractorId &&
      proposal.fixtureSet === source.fixture,
    "CORRUPT_RULE_PROPOSAL",
    "Rule proposal source, extractor, or fixture binding is invalid."
  );
  const basis = proposalBasis(proposal);
  invariant(
    proposal.proposalHash === hashValue(basis) &&
      proposal.proposalId ===
        `rule-${proposal.sourceProfileId}-${shortHash(basis)}`,
    "CORRUPT_RULE_PROPOSAL",
    "Rule proposal identity does not match its frozen candidate evidence."
  );
}

function proposalBasis(proposal) {
  return {
    schemaVersion: proposal.schemaVersion,
    sourceProfileId: proposal.sourceProfileId,
    extractorId: proposal.extractorId,
    fixtureSet: proposal.fixtureSet,
    observations: proposal.observations,
    candidateRule: proposal.candidateRule,
  };
}

function compileCandidateRule(rule) {
  if (rule?.kind === "declarative_extractor_config" &&
      rule.templateFamily === "editorial_link_card" &&
      rule.version === 1 &&
      rule.implementationId === "cntraveller-editorial-link-card-v1") {
    return compileEditorialLinkCardRule(rule);
  }
  if (rule?.kind === "deterministic_extractor" &&
      rule.templateFamily === "schema_org_event_json_ld" &&
      rule.version === 1 &&
      rule.implementationId === "luma-json-ld-event-v1" &&
      hashValue(rule.requiredTypes) === hashValue(["Event"]) &&
      rule.onTemplateMismatch === "abstain") {
    return (input) => extractLumaEvents(input).events;
  }
  throw new OperationsError(
    "RULE_CANDIDATE_UNSUPPORTED",
    "Candidate rule has no allowlisted deterministic evaluator."
  );
}

function compileEditorialLinkCardRule(rule) {
  const keys = Object.keys(rule.mappings ?? {}).sort();
  const requiredKeys = ["dateText", "links", "title", "venueText"];
  const safePaths = new Set([
    "card.id",
    "card.heading",
    "card.summary",
    "card.dateText",
    "card.venueText",
    "card.links",
  ]);
  invariant(
    hashValue(keys) === hashValue(requiredKeys) &&
      Object.values(rule.mappings).every((value) => safePaths.has(value)) &&
      rule.invariantOutputs?.discoveryOnly === true &&
      rule.invariantOutputs?.requiresOfficialSource === true &&
      rule.onTemplateMismatch === "abstain",
    "RULE_CANDIDATE_UNSUPPORTED",
    "Editorial candidate mappings or safety invariants are unsupported."
  );
  return (input) => {
    const document = input?.document ?? input ?? {};
    const cards = Array.isArray(document.cards) ? document.cards : [];
    const mappedCards = cards.map((card) => ({
      id: card?.id,
      heading: readCandidatePath({card}, rule.mappings.title),
      summary: card?.summary,
      dateText: readCandidatePath({card}, rule.mappings.dateText),
      venueText: readCandidatePath({card}, rule.mappings.venueText),
      links: readCandidatePath({card}, rule.mappings.links),
    }));
    const mapped = input?.document ? {
      ...input,
      document: {...document, cards: mappedCards},
    } : {...document, cards: mappedCards};
    return extractCnTravellerLeads(mapped).leads;
  };
}

function readCandidatePath(scope, candidatePath) {
  return candidatePath.split(".").reduce((value, segment) =>
    value?.[segment], scope);
}

function frequencies(values) {
  const counts = new Map();
  for (const value of values) counts.set(value, (counts.get(value) ?? 0) + 1);
  return counts;
}

function projectComparable(actual, expectedRecords) {
  const keys = new Set(expectedRecords.flatMap((record) => Object.keys(record)));
  return Object.fromEntries([...keys].sort().map((key) => [key, actual[key] ?? null]));
}

function recordKey(record) {
  return hashValue(record);
}
