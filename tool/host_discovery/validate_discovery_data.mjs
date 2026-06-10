#!/usr/bin/env node
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const discoveryRoot = scriptDir;
const repoRoot = path.resolve(discoveryRoot, "..", "..");
const checkMode = process.argv.includes("--check");

const categoriesPath = path.join(discoveryRoot, "target_categories.json");
const batchRoot = path.join(discoveryRoot, "candidate_batches");
const seedRoot = path.join(discoveryRoot, "seed_clubs");
const outputPath = path.join(discoveryRoot, "generated", "candidate_dedupe_index.json");

const errors = [];
const warnings = [];

const config = readJson(categoriesPath);
const allowedStates = new Set(config.states ?? []);
const allowedPriorities = new Set(Object.keys(config.priorityTiers ?? {}));
const categories = new Set((config.categories ?? []).map((category) => category.id));
const citySlugs = new Set((config.cities ?? []).map((city) => city.slug));
const sourceConfidences = new Set(["high", "medium", "low"]);
const seedDocs = loadSeedDocs();
const batches = loadBatches();
const candidates = batches.flatMap((batch) =>
  batch.candidates.map((candidate) => ({...candidate, batchId: batch.batchId}))
);

validateBatchSize(candidates);
validateCandidates(candidates);

const index = buildIndex(candidates);
validateDuplicateKeys(index);

if (errors.length > 0) {
  console.error("Host discovery validation failed:");
  for (const error of errors) console.error(`- ${error}`);
  if (warnings.length > 0) {
    console.error("\nWarnings:");
    for (const warning of warnings) console.error(`- ${warning}`);
  }
  process.exit(1);
}

const rendered = `${stableStringify(index)}\n`;
if (checkMode) {
  if (!fs.existsSync(outputPath)) {
    console.error(`Missing generated index: ${relative(outputPath)}`);
    process.exit(1);
  }
  const current = fs.readFileSync(outputPath, "utf8");
  if (current !== rendered) {
    console.error(`Generated index is stale: ${relative(outputPath)}`);
    console.error("Run: node tool/host_discovery/validate_discovery_data.mjs");
    process.exit(1);
  }
} else {
  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, rendered);
}

console.log(
  `Host discovery validation passed: ${candidates.length} candidates, ${index.dedupeKeys.length} dedupe keys.`
);
if (warnings.length > 0) {
  for (const warning of warnings) console.warn(`Warning: ${warning}`);
}

function loadBatches() {
  const files = fs
    .readdirSync(batchRoot)
    .filter((file) => file.endsWith(".json"))
    .sort();
  return files.map((file) => {
    const batch = readJson(path.join(batchRoot, file));
    if (!batch.batchId) errors.push(`${file}: missing batchId`);
    if (!Array.isArray(batch.candidates)) errors.push(`${file}: missing candidates array`);
    return {...batch, file: relative(path.join(batchRoot, file))};
  });
}

function loadSeedDocs() {
  const docs = new Map();
  if (!fs.existsSync(seedRoot)) return docs;
  for (const file of fs.readdirSync(seedRoot).filter((entry) => entry.endsWith(".json")).sort()) {
    const seed = readJson(path.join(seedRoot, file));
    if (typeof seed.path === "string") {
      docs.set(seed.path, {file: relative(path.join(seedRoot, file)), seed});
    }
  }
  return docs;
}

function validateBatchSize(allCandidates) {
  const minimum = config.batchSizeTarget?.minimum ?? 0;
  const maximum = config.batchSizeTarget?.maximum ?? Number.POSITIVE_INFINITY;
  if (allCandidates.length < minimum || allCandidates.length > maximum) {
    errors.push(
      `candidate count ${allCandidates.length} is outside target range ${minimum}-${maximum}`
    );
  }
}

function validateCandidates(allCandidates) {
  const ids = new Set();
  for (const candidate of allCandidates) {
    const prefix = `${candidate.batchId}/${candidate.candidateId ?? "<missing>"}`;
    if (!candidate.candidateId) errors.push(`${prefix}: missing candidateId`);
    else if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(candidate.candidateId)) {
      errors.push(`${prefix}: candidateId must be a lowercase slug`);
    } else if (ids.has(candidate.candidateId)) {
      errors.push(`${prefix}: duplicate candidateId`);
    } else {
      ids.add(candidate.candidateId);
    }

    requiredString(candidate, "displayName", prefix);
    requiredString(candidate, "city", prefix);
    requiredString(candidate, "citySlug", prefix);
    requiredString(candidate, "countryCode", prefix);
    requiredString(candidate, "categoryId", prefix);
    requiredString(candidate, "entityKind", prefix);
    requiredString(candidate, "priority", prefix);
    requiredString(candidate, "state", prefix);
    requiredString(candidate, "sourceConfidence", prefix);
    requiredString(candidate, "verificationStatus", prefix);
    requiredString(candidate, "nextAction", prefix);

    if (candidate.categoryId && !categories.has(candidate.categoryId)) {
      errors.push(`${prefix}: unknown categoryId ${candidate.categoryId}`);
    }
    if (candidate.citySlug && !citySlugs.has(candidate.citySlug)) {
      errors.push(`${prefix}: unknown citySlug ${candidate.citySlug}`);
    }
    if (candidate.state && !allowedStates.has(candidate.state)) {
      errors.push(`${prefix}: unknown state ${candidate.state}`);
    }
    if (candidate.priority && !allowedPriorities.has(candidate.priority)) {
      errors.push(`${prefix}: unknown priority ${candidate.priority}`);
    }
    if (candidate.sourceConfidence && !sourceConfidences.has(candidate.sourceConfidence)) {
      errors.push(`${prefix}: unknown sourceConfidence ${candidate.sourceConfidence}`);
    }
    if (!Number.isInteger(candidate.fitScore) || candidate.fitScore < 1 || candidate.fitScore > 5) {
      errors.push(`${prefix}: fitScore must be an integer from 1 to 5`);
    }
    if (!Array.isArray(candidate.aliases)) errors.push(`${prefix}: aliases must be an array`);
    if (!Array.isArray(candidate.fitSignals)) errors.push(`${prefix}: fitSignals must be an array`);
    if (!Array.isArray(candidate.sources) || candidate.sources.length === 0) {
      errors.push(`${prefix}: sources must be a non-empty array`);
    } else {
      validateSources(candidate.sources, prefix);
    }

    if (candidate.state === "page_seeded") {
      if (!candidate.seedDocumentPath) errors.push(`${prefix}: page_seeded requires seedDocumentPath`);
      if (!candidate.canonicalPath) errors.push(`${prefix}: page_seeded requires canonicalPath`);
    }
    if (candidate.seedDocumentPath) {
      const seed = seedDocs.get(candidate.seedDocumentPath);
      if (!seed) {
        errors.push(`${prefix}: seedDocumentPath has no matching seed doc ${candidate.seedDocumentPath}`);
      } else if (candidate.canonicalPath) {
        const seedCanonicalPath = seed.seed?.data?.publicPage?.canonicalPath;
        if (seedCanonicalPath && seedCanonicalPath !== candidate.canonicalPath) {
          errors.push(
            `${prefix}: canonicalPath ${candidate.canonicalPath} does not match seed ${seedCanonicalPath}`
          );
        }
      }
    }
  }
}

function validateSources(sources, prefix) {
  for (const [index, source] of sources.entries()) {
    const sourcePrefix = `${prefix}/sources[${index}]`;
    requiredString(source, "type", sourcePrefix);
    requiredString(source, "confidence", sourcePrefix);
    requiredString(source, "notes", sourcePrefix);
    if (source.confidence && !sourceConfidences.has(source.confidence)) {
      errors.push(`${sourcePrefix}: unknown confidence ${source.confidence}`);
    }
    if (source.url !== null && source.url !== undefined) {
      if (typeof source.url !== "string" || source.url.length === 0) {
        errors.push(`${sourcePrefix}: url must be null or a non-empty string`);
      } else {
        try {
          const url = new URL(source.url);
          if (!["http:", "https:"].includes(url.protocol)) {
            errors.push(`${sourcePrefix}: url must be http or https`);
          }
        } catch {
          errors.push(`${sourcePrefix}: invalid url ${source.url}`);
        }
      }
    }
  }
}

function buildIndex(allCandidates) {
  const keys = [];
  const candidateSummaries = [];

  for (const candidate of [...allCandidates].sort((a, b) => a.candidateId.localeCompare(b.candidateId))) {
    const candidateKeys = [];
    addKey(candidateKeys, "name_city", `${slugify(candidate.displayName)}:${candidate.citySlug}`);
    if (candidate.canonicalPath) addKey(candidateKeys, "canonical_path", candidate.canonicalPath);
    if (candidate.seedDocumentPath) addKey(candidateKeys, "seed_document", candidate.seedDocumentPath);
    if (candidate.identity?.website) addUrlHostKey(candidateKeys, "website_host", candidate.identity.website);
    if (candidate.identity?.instagramHandle) {
      addKey(candidateKeys, "instagram", normalizeHandle(candidate.identity.instagramHandle));
    }
    if (candidate.identity?.lumaUrl) addUrlKey(candidateKeys, "event_url", candidate.identity.lumaUrl);
    for (const source of candidate.sources ?? []) {
      if (source.url) addUrlKey(candidateKeys, "source_url", source.url);
      if (source.url && source.type.includes("official")) {
        addUrlHostKey(candidateKeys, "official_host", source.url);
      }
    }

    const uniqueKeys = [...new Map(candidateKeys.map((entry) => [`${entry.type}:${entry.value}`, entry])).values()]
      .sort((a, b) => `${a.type}:${a.value}`.localeCompare(`${b.type}:${b.value}`));
    for (const key of uniqueKeys) {
      keys.push({...key, candidateId: candidate.candidateId});
    }

    candidateSummaries.push({
      candidateId: candidate.candidateId,
      displayName: candidate.displayName,
      citySlug: candidate.citySlug,
      categoryId: candidate.categoryId,
      priority: candidate.priority,
      state: candidate.state,
      sourceConfidence: candidate.sourceConfidence,
      verificationStatus: candidate.verificationStatus,
      fitScore: candidate.fitScore,
      seedDocumentPath: candidate.seedDocumentPath ?? null,
      canonicalPath: candidate.canonicalPath ?? null,
      sourceUrls: (candidate.sources ?? []).map((source) => source.url).filter(Boolean).sort(),
      dedupeKeys: uniqueKeys,
    });
  }

  return {
    schemaVersion: 1,
    generatedFrom: {
      targetCategories: relative(categoriesPath),
      batches: batches.map((batch) => batch.file).sort(),
      seedDocs: [...seedDocs.values()].map((entry) => entry.file).sort(),
    },
    candidateCount: allCandidates.length,
    counts: {
      byCategory: countBy(allCandidates, "categoryId"),
      byCity: countBy(allCandidates, "citySlug"),
      byPriority: countBy(allCandidates, "priority"),
      byState: countBy(allCandidates, "state"),
    },
    candidates: candidateSummaries,
    dedupeKeys: keys.sort((a, b) =>
      `${a.type}:${a.value}:${a.candidateId}`.localeCompare(`${b.type}:${b.value}:${b.candidateId}`)
    ),
    inputHash: hashObject({
      config,
      batches: batches.map((batch) => ({...batch, file: undefined})),
      seedPaths: [...seedDocs.keys()].sort(),
    }),
  };
}

function validateDuplicateKeys(index) {
  const groups = new Map();
  for (const key of index.dedupeKeys) {
    const groupKey = `${key.type}:${key.value}`;
    if (!groups.has(groupKey)) groups.set(groupKey, new Set());
    groups.get(groupKey).add(key.candidateId);
  }

  for (const [key, candidateIds] of groups.entries()) {
    if (candidateIds.size <= 1) continue;
    const message = `${key} appears on ${[...candidateIds].sort().join(", ")}`;
    if (key.startsWith("source_url:")) warnings.push(`shared source URL: ${message}`);
    else errors.push(`duplicate strong dedupe key: ${message}`);
  }
}

function addUrlHostKey(keys, type, value) {
  try {
    const url = new URL(value);
    addKey(keys, type, url.hostname.toLowerCase().replace(/^www\./, ""));
  } catch {
    // URL validity is reported separately.
  }
}

function addUrlKey(keys, type, value) {
  try {
    const url = new URL(value);
    url.hash = "";
    const normalized = url.toString().replace(/\/$/, "");
    addKey(keys, type, normalized);
  } catch {
    // URL validity is reported separately.
  }
}

function addKey(keys, type, value) {
  if (!value) return;
  keys.push({type, value});
}

function countBy(items, field) {
  const counts = {};
  for (const item of items) {
    const key = item[field] ?? "<missing>";
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return Object.fromEntries(Object.entries(counts).sort(([a], [b]) => a.localeCompare(b)));
}

function requiredString(target, field, prefix) {
  if (typeof target[field] !== "string" || target[field].trim().length === 0) {
    errors.push(`${prefix}: missing ${field}`);
  }
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
  return Object.fromEntries(
    Object.entries(value)
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

function normalizeHandle(value) {
  return String(value).toLowerCase().replace(/^@/, "").trim();
}

function relative(file) {
  return path.relative(repoRoot, file);
}
