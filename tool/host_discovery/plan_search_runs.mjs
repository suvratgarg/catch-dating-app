#!/usr/bin/env node
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const discoveryRoot = scriptDir;
const repoRoot = path.resolve(discoveryRoot, "..", "..");
const checkMode = process.argv.includes("--check");

const matrixPath = path.join(discoveryRoot, "search_matrix.json");
const categoriesPath = path.join(discoveryRoot, "target_categories.json");
const templatesPath = path.join(discoveryRoot, "query_templates.json");
const batchRoot = path.join(discoveryRoot, "candidate_batches");
const runsRoot = path.join(discoveryRoot, "runs");
const outputPath = path.join(discoveryRoot, "generated", "search_plan.json");

const matrix = readJson(matrixPath);
const categoriesConfig = readJson(categoriesPath);
const templates = readJson(templatesPath);
const batches = loadBatches();
const candidates = batches.flatMap((batch) => batch.candidates);
const cities = new Map((categoriesConfig.cities ?? []).map((city) => [city.slug, city]));
const templatesById = new Map(templates.map((template) => [template.id, template]));
const existingRuns = loadExistingRuns();

const errors = [];
const planned = [];
const skipped = [];
const asOf = process.env.HOST_DISCOVERY_AS_OF ?? matrix.updatedAt;

for (const generic of matrix.genericSearches ?? []) {
  const template = templatesById.get(generic.queryTemplateId);
  if (!template) {
    errors.push(`Unknown queryTemplateId in search_matrix: ${generic.queryTemplateId}`);
    continue;
  }
  for (const citySlug of generic.citySlugs ?? []) {
    const city = cities.get(citySlug);
    if (!city) {
      errors.push(`Unknown citySlug in search_matrix: ${citySlug}`);
      continue;
    }
    for (const queryTemplate of template.queryTemplates ?? []) {
      if (queryTemplate.includes("{candidateName}")) continue;
      addPlan({
        planKind: "generic_city_category",
        queryTemplateId: generic.queryTemplateId,
        categoryId: generic.categoryId,
        source: generic.source,
        citySlug,
        city: city.name,
        candidateId: null,
        candidateName: null,
        queryTemplate,
        renderedQuery: renderQuery(queryTemplate, {city: city.name}),
      });
    }
  }
}

if (matrix.candidateVerification?.enabled) {
  const template = templatesById.get(matrix.candidateVerification.queryTemplateId);
  if (!template) {
    errors.push(
      `Unknown candidate verification template: ${matrix.candidateVerification.queryTemplateId}`
    );
  } else {
    const states = new Set(matrix.candidateVerification.states ?? []);
    const priorities = new Set(matrix.candidateVerification.priorityTiers ?? []);
    for (const candidate of candidates) {
      if (!states.has(candidate.state)) continue;
      if (!priorities.has(candidate.priority)) continue;
      for (const queryTemplate of template.queryTemplates ?? []) {
        if (!queryTemplate.includes("{candidateName}")) continue;
        addPlan({
          planKind: "candidate_verification",
          queryTemplateId: matrix.candidateVerification.queryTemplateId,
          categoryId: candidate.categoryId,
          source: matrix.candidateVerification.source,
          citySlug: candidate.citySlug,
          city: candidate.city,
          candidateId: candidate.candidateId,
          candidateName: candidate.displayName,
          queryTemplate,
          renderedQuery: renderQuery(queryTemplate, {
            city: candidate.city,
            candidateName: candidate.displayName,
          }),
        });
      }
    }
  }
}

if (errors.length > 0) {
  console.error("Host discovery search planning failed:");
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

const output = {
  schemaVersion: 1,
  generatedFrom: {
    searchMatrix: relative(matrixPath),
    targetCategories: relative(categoriesPath),
    queryTemplates: relative(templatesPath),
    batches: batches.map((batch) => batch.file).sort(),
    runs: existingRuns.map((run) => run.file).sort(),
  },
  asOf,
  freshForDays: matrix.freshForDays,
  plannedCount: planned.length,
  skippedFreshCount: skipped.length,
  planned,
  skippedFresh: skipped,
  inputHash: hashObject({
    matrix,
    categoriesConfig,
    templates,
    candidates,
    existingRuns: existingRuns.map((run) => ({
      runId: run.runId,
      searchedAt: run.searchedAt,
      category: run.category,
      candidateId: run.candidateId,
      queries: run.queries,
    })),
  }),
};

const rendered = `${stableStringify(output)}\n`;
if (checkMode) {
  if (!fs.existsSync(outputPath)) {
    console.error(`Missing generated search plan: ${relative(outputPath)}`);
    process.exit(1);
  }
  const current = fs.readFileSync(outputPath, "utf8");
  if (current !== rendered) {
    console.error(`Generated search plan is stale: ${relative(outputPath)}`);
    console.error("Run: node tool/host_discovery/plan_search_runs.mjs");
    process.exit(1);
  }
} else {
  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, rendered);
}

console.log(
  `Host discovery search plan ready: ${planned.length} planned, ${skipped.length} skipped as fresh.`
);

function addPlan(plan) {
  const key = planKey(plan);
  const freshCandidateRun =
    plan.planKind === "candidate_verification" && plan.candidateId
      ? existingRuns.find((run) => run.candidateId === plan.candidateId && isFresh(run.searchedAt))
      : null;
  const freshRun =
    freshCandidateRun ?? existingRuns.find((run) => run.keys.has(key) && isFresh(run.searchedAt));
  const entry = {
    ...plan,
    runKey: key,
    resultFingerprint: hashObject({
      queryTemplateId: plan.queryTemplateId,
      renderedQuery: plan.renderedQuery,
      citySlug: plan.citySlug,
      categoryId: plan.categoryId,
      candidateId: plan.candidateId,
      source: plan.source,
    }).slice(0, 16),
  };
  if (freshRun) {
    skipped.push({
      ...entry,
      existingRunId: freshRun.runId,
      existingRunFile: freshRun.file,
      searchedAt: freshRun.searchedAt,
    });
  } else {
    planned.push(entry);
  }
}

function loadBatches() {
  return fs
    .readdirSync(batchRoot)
    .filter((file) => file.endsWith(".json"))
    .sort()
    .map((file) => {
      const batchPath = path.join(batchRoot, file);
      return {...readJson(batchPath), file: relative(batchPath)};
    });
}

function loadExistingRuns() {
  if (!fs.existsSync(runsRoot)) return [];
  return fs
    .readdirSync(runsRoot)
    .filter((file) => file.endsWith(".json"))
    .sort()
    .map((file) => {
      const runPath = path.join(runsRoot, file);
      const run = readJson(runPath);
      const keys = new Set();
      for (const query of run.queries ?? []) {
        keys.add(
          planKey({
            source: query.source,
            renderedQuery: query.renderedQuery,
            citySlug: slugify(run.seed?.city ?? ""),
            categoryId: run.category,
            candidateId: run.candidateId ?? null,
          })
        );
      }
      return {
        ...run,
        file: relative(runPath),
        keys,
      };
    });
}

function planKey(plan) {
  return [
    plan.source,
    normalizeQuery(plan.renderedQuery),
    plan.citySlug,
    plan.categoryId,
    plan.candidateId ?? "generic",
  ].join("|");
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

function isFresh(searchedAt) {
  if (!searchedAt) return false;
  const searched = Date.parse(`${searchedAt}T00:00:00Z`);
  const current = Date.parse(`${asOf}T00:00:00Z`);
  if (Number.isNaN(searched) || Number.isNaN(current)) return false;
  const ageDays = Math.floor((current - searched) / 86_400_000);
  return ageDays >= 0 && ageDays <= matrix.freshForDays;
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function stableStringify(value) {
  return JSON.stringify(sortValue(value), null, 2);
}

function sortValue(value) {
  if (Array.isArray(value)) return value.map(sortValue);
  if (!value || typeof value !== "object") return value;
  if (value instanceof Set) return [...value].sort();
  return Object.fromEntries(
    Object.entries(value)
      .filter(([, nested]) => nested !== undefined)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([key, nested]) => [key, sortValue(nested)])
  );
}

function hashObject(value) {
  return crypto.createHash("sha256").update(stableStringify(value)).digest("hex");
}

function slugify(value) {
  return String(value)
    .normalize("NFKD")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function relative(file) {
  return path.relative(repoRoot, file);
}
