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
  return {matrix, categories, templates};
}

export async function planDiscoveryQueries({
  market,
  organizerCandidates = [],
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
    inputHash: hashValue({
      market,
      policy,
      organizerCandidates,
    }),
  };
}

function planEntry(value) {
  const runKey = [
    value.source,
    normalizeQuery(value.renderedQuery),
    value.citySlug,
    value.categoryId,
    value.candidateId ?? "generic",
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
    .replace(/\s+/g, " ")
    .trim();
}

function normalizeQuery(value) {
  return String(value).toLowerCase().replace(/\s+/g, " ").trim();
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

