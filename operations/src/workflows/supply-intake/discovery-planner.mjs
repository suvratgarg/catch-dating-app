import fs from "node:fs/promises";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {hashValue} from "../../platform/canonical-json.mjs";
import {OperationsError, invariant} from "../../platform/errors.mjs";

const moduleDirectory = path.dirname(fileURLToPath(import.meta.url));
const configDirectory = path.join(moduleDirectory, "config");

export async function loadDiscoveryPolicy({readFile = fs.readFile} = {}) {
  const [matrix, categories, templates] = await Promise.all([
    readJson(path.join(configDirectory, "search_matrix.json"), readFile),
    readJson(path.join(configDirectory, "target_categories.json"), readFile),
    readJson(path.join(configDirectory, "query_templates.json"), readFile),
  ]);
  return {
    matrix,
    categories,
    templates,
    ...(matrix.marketMap ? {marketMap: matrix.marketMap} : {}),
  };
}

export async function planDiscoveryQueries({
  market,
  organizerCandidates = [],
  discoveryKnowledge = null,
  policyLoader = loadDiscoveryPolicy,
}) {
  invariant(
    /^[a-z][a-z0-9-]{1,49}$/.test(market ?? ""),
    "INVALID_MARKET",
    "Discovery planning requires a market slug."
  );
  const policy = await policyLoader();
  const cities = new Map((policy.categories.cities ?? []).map((city) => [
    city.slug,
    city,
  ]));
  const city = cities.get(market);
  invariant(
    city,
    "UNKNOWN_DISCOVERY_MARKET",
    `Discovery policy has no city entry for ${market}.`
  );
  const templates = new Map(policy.templates.map((template) => [
    template.id,
    template,
  ]));
  const planned = [];
  const frontier = policy.marketMap ? planDiscoveryFrontier({
    market,
    policy: policy.marketMap,
    coverage: discoveryKnowledge?.coverage ?? {},
  }) : null;
  if (frontier) {
    for (const cell of frontier.cells) {
      for (const lensId of cell.queryLenses) {
        const lens = policy.marketMap.lenses.find((entry) => entry.id === lensId);
        for (const queryTemplate of lens.queryTemplates) {
          planned.push(planEntry({
            planKind: "market_map_lens",
            queryTemplateId: lens.id,
            categoryId: cell.segment,
            source: lens.source,
            lens: lens.id,
            citySlug: market,
            city: city.name,
            country: cell.country,
            locale: lens.locale,
            language: lens.language,
            candidateId: null,
            candidateName: null,
            queryTemplate,
            renderedQuery: renderQuery(queryTemplate, {
              city: city.name,
              country: cell.country,
              segment: cell.segment,
            }),
          }));
        }
      }
    }
  }
  for (const generic of policy.matrix.genericSearches ?? []) {
    if (!(generic.citySlugs ?? []).includes(market)) continue;
    const template = templates.get(generic.queryTemplateId);
    invariant(
      template,
      "INVALID_DISCOVERY_POLICY",
      `Unknown query template ${generic.queryTemplateId}.`
    );
    for (const queryTemplate of template.queryTemplates ?? []) {
      if (queryTemplate.includes("{candidateName}")) continue;
      planned.push(planEntry({
        planKind: "generic_city_category",
        queryTemplateId: generic.queryTemplateId,
        categoryId: generic.categoryId,
        source: generic.source,
        citySlug: market,
        city: city.name,
        candidateId: null,
        candidateName: null,
        queryTemplate,
        renderedQuery: renderQuery(queryTemplate, {city: city.name}),
      }));
    }
  }
  const verification = policy.matrix.candidateVerification;
  if (verification?.enabled) {
    const template = templates.get(verification.queryTemplateId);
    invariant(
      template,
      "INVALID_DISCOVERY_POLICY",
      `Unknown query template ${verification.queryTemplateId}.`
    );
    const states = new Set(verification.states ?? []);
    const priorities = new Set(verification.priorityTiers ?? []);
    for (const candidate of organizerCandidates) {
      const candidateMarket =
        candidate?.queryIntent?.marketSlug ?? candidate?.citySlug;
      const candidateName = candidate?.displayName ?? candidate?.title;
      if (candidateMarket !== market ||
        !states.has(candidate?.state) ||
        !priorities.has(candidate?.priority) ||
        typeof candidateName !== "string" ||
        candidateName.length === 0) continue;
      for (const queryTemplate of template.queryTemplates ?? []) {
        if (!queryTemplate.includes("{candidateName}")) continue;
        planned.push(planEntry({
          planKind: "candidate_verification",
          queryTemplateId: verification.queryTemplateId,
          categoryId:
            candidate.categoryId ??
            candidate.queryIntent?.categoryId ??
            "organizer_brand",
          source: verification.source,
          citySlug: market,
          city: city.name,
          candidateId: candidate.candidateId,
          candidateName,
          queryTemplate,
          renderedQuery: renderQuery(queryTemplate, {
            city: city.name,
            candidateName,
          }),
        }));
      }
    }
  }
  const unique = Array.from(new Map(planned.map((entry) => [
    entry.runKey,
    entry,
  ])).values()).sort((left, right) =>
    left.runKey.localeCompare(right.runKey));
  return {
    schemaVersion: 1,
    plannerId: "operations-supply-discovery-v1",
    market,
    planned: unique,
    ...(frontier ? {frontier} : {}),
    inputHash: hashValue({
      market,
      policy,
      organizerCandidates,
      ...(frontier ? {discoveryKnowledge} : {}),
    }),
  };
}

export function planDiscoveryFrontier({market, policy, coverage = {}}) {
  const requiredLenses = [
    "web_press", "social", "event_calendar", "app_directory",
  ];
  invariant(Array.isArray(policy?.lenses) &&
    requiredLenses.every((id) => policy.lenses.some((lens) =>
      lens.id === id && typeof lens.source === "string" &&
      Array.isArray(lens.queryTemplates) && lens.queryTemplates.length > 0)) &&
    policy.lenses.length === requiredLenses.length &&
    Array.isArray(policy.cells) &&
    Number.isSafeInteger(policy.minimumCensusSize) &&
    policy.minimumCensusSize > 0 &&
    Number.isSafeInteger(policy.topLeaderGateCount) &&
    policy.topLeaderGateCount > 0 &&
    Number.isSafeInteger(policy.minimumSourceDomains) &&
    policy.minimumSourceDomains > 0,
  "INVALID_DISCOVERY_POLICY",
  "Market-map policy needs four configured lenses, cells and coverage thresholds.");
  const cells = policy.cells.filter((cell) => cell.market === market)
    .map((cell) => {
      invariant(typeof cell.country === "string" && cell.country.length > 0 &&
        /^[a-z][a-z0-9-]{1,49}$/u.test(cell.segment ?? ""),
      "INVALID_DISCOVERY_POLICY", "Market-map cells need country and segment.");
      const observed = coverage[cell.segment] ?? null;
      const reviewed = Number.isSafeInteger(observed?.reviewRevision) &&
        observed.reviewRevision > 0 &&
        typeof observed.reviewerId === "string" &&
        observed.reviewerId.length > 0 &&
        Array.isArray(observed.inputRefs) &&
        observed.inputRefs.length > 0;
      const missingLenses = requiredLenses.filter((id) =>
        !Number.isSafeInteger(observed?.lenses?.[id]?.usefulQueryCount) ||
        observed.lenses[id].usefulQueryCount < 1 ||
        !Array.isArray(observed.lenses[id].queryRefs) ||
        observed.lenses[id].queryRefs.length <
          observed.lenses[id].usefulQueryCount);
      const unknowns = [];
      if (!reviewed) unknowns.push("coverage_review_missing");
      if (missingLenses.length) unknowns.push("lens_coverage_incomplete");
      const domains = new Set(requiredLenses.flatMap((id) =>
        observed?.lenses?.[id]?.sourceDomains ?? []));
      if (domains.size < policy.minimumSourceDomains) {
        unknowns.push("source_diversity_unproven");
      }
      const census = observed?.leaderCensus;
      if ((census?.candidateFingerprints?.length ?? 0) <
        policy.minimumCensusSize) unknowns.push("leader_set_incomplete");
      if (!Array.isArray(census?.prominenceEvidenceRefs) ||
        census.prominenceEvidenceRefs.length === 0) {
        unknowns.push("leader_prominence_unproven");
      }
      if (!census?.presumedLeaderFingerprint ||
        !census?.runnerUpFingerprint) unknowns.push("leader_order_unknown");
      if (census?.stabilityConfirmed !== true) {
        unknowns.push("leader_stability_unproven");
      }
      const top = census?.topCandidateFingerprints ?? [];
      const outcomes = census?.gateOutcomes ?? {};
      const terminal = new Set(["pass", "benchmark_pass", "reject"]);
      if (top.length < policy.topLeaderGateCount ||
        top.slice(0, policy.topLeaderGateCount).some((id) =>
          !census?.candidateFingerprints?.includes(id)) ||
        top.slice(0, policy.topLeaderGateCount).some((id) =>
          !terminal.has(outcomes[id]?.outcome) ||
          !Array.isArray(outcomes[id]?.inputRefs) ||
          outcomes[id].inputRefs.length === 0)) {
        unknowns.push("top_leader_gate_unresolved");
      }
      if (census?.status !== "complete") {
        unknowns.push("leader_census_not_reviewed_complete");
      }
      const complete = unknowns.length === 0;
      const reopen = observed?.reopenLenses ?? [];
      const queryLenses = [...new Set([...missingLenses,
        ...reopen.filter((id) => requiredLenses.includes(id))])];
      return {
        market,
        country: cell.country,
        segment: cell.segment,
        status: complete ? "complete" : "incomplete",
        capEligible: complete,
        missingLenses,
        queryLenses,
        unknowns,
        priority: unknowns.length * 10 + missingLenses.length,
        coverageReviewRevision: observed?.reviewRevision ?? null,
      };
    });
  cells.sort((left, right) =>
    right.priority - left.priority || left.segment.localeCompare(right.segment));
  return {schemaVersion: 1, market, cells};
}

function planEntry(value) {
  const runKey = [
    value.source,
    value.planKind === "market_map_lens" ?
      normalizeMarketMapQuery(value.renderedQuery) :
      normalizeQuery(value.renderedQuery),
    value.citySlug,
    value.categoryId,
    value.candidateId ?? "generic",
    ...(value.planKind === "market_map_lens" ? [
      value.lens,
      value.locale ?? "default",
      value.language ?? "default",
    ] : []),
  ].join("|");
  return {
    ...value,
    runKey,
    resultFingerprint: hashValue({
      queryTemplateId: value.queryTemplateId,
      renderedQuery: value.renderedQuery,
      citySlug: value.citySlug,
      categoryId: value.categoryId,
      candidateId: value.candidateId,
      source: value.source,
    }).slice(0, 16),
  };
}

function renderQuery(template, values) {
  return template
    .replaceAll("{city}", values.city ?? "")
    .replaceAll("{candidateName}", values.candidateName ?? "")
    .replaceAll("{country}", values.country ?? "")
    .replaceAll("{segment}", values.segment ?? "")
    .replace(/\s+/g, " ")
    .trim();
}

function normalizeQuery(value) {
  return String(value).toLowerCase().replace(/\s+/g, " ").trim();
}

function normalizeMarketMapQuery(value) {
  return String(value).normalize("NFKC").toLowerCase()
    .replace(/[^\p{L}\p{N}]+/gu, " ").replace(/\s+/gu, " ").trim();
}

async function readJson(file, readFile) {
  try {
    return JSON.parse(await readFile(file, "utf8"));
  } catch (error) {
    if (error instanceof SyntaxError) {
      throw new OperationsError(
        "INVALID_DISCOVERY_POLICY",
        `Discovery policy ${file} is invalid JSON.`,
        {cause: error}
      );
    }
    throw error;
  }
}
