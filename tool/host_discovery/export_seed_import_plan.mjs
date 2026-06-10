#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const discoveryRoot = scriptDir;
const repoRoot = path.resolve(discoveryRoot, "..", "..");
const seedRoot = path.join(discoveryRoot, "seed_clubs");
const evidencePath = path.join(discoveryRoot, "generated", "source_evidence.json");
const readinessPath = path.join(discoveryRoot, "generated", "index_readiness_report.json");
const outputPath = path.join(discoveryRoot, "generated", "firestore_seed_import_plan.json");
const checkMode = process.argv.includes("--check");

const seeds = loadSeeds();
const evidence = fs.existsSync(evidencePath) ? readJson(evidencePath).evidence ?? [] : [];
const readiness = fs.existsSync(readinessPath) ? readJson(readinessPath) : null;
const writes = [];

for (const seed of seeds) {
  writes.push({
    op: "set",
    path: seed.path,
    merge: false,
    sourceFile: seed.file,
    data: seed.data,
    guardrails: [
      "Only import into a non-production or explicitly approved Firebase project.",
      "Do not change publicPage.indexStatus from noindex during import.",
      "Do not overwrite a claimed club without a separate migration review.",
    ],
  });
}

for (const entry of evidence) {
  writes.push({
    op: "set",
    path: entry.futureFirestorePath,
    merge: false,
    sourceFile: relative(evidencePath),
    data: {
      evidenceId: entry.evidenceId,
      candidateId: entry.candidateId,
      clubId: entry.clubId,
      seedDocumentPath: entry.seedDocumentPath,
      sourceType: entry.sourceType,
      sourceUrl: entry.sourceUrl,
      sourceOwner: entry.sourceOwner,
      sourceConfidence: entry.sourceConfidence,
      capturedAt: entry.capturedAt,
      capturedFacts: entry.capturedFacts,
      capturedButNotDisplayed: entry.capturedButNotDisplayed,
      displayPolicy: entry.displayPolicy,
      sourceRunFile: entry.sourceRunFile,
      seedFile: entry.seedFile,
    },
    guardrails: [
      "Evidence records are server/import owned and not rendered directly on the public website.",
      "Use public summaries only; preserve capturedButNotDisplayed as internal audit data.",
    ],
  });
}

const output = {
  schemaVersion: 1,
  generatedFrom: {
    seedDocs: seeds.map((seed) => seed.file).sort(),
    sourceEvidence: relative(evidencePath),
    indexReadiness: readiness ? relative(readinessPath) : null,
  },
  applyStatus: "dry_run_only",
  applyRequires: [
    "Explicit Firebase project selection.",
    "Manual approval for remote writes.",
    "A preflight read proving the target club paths do not already exist or are safe to overwrite.",
  ],
  importSummary: {
    clubWrites: seeds.length,
    sourceEvidenceWrites: evidence.length,
    totalWrites: writes.length,
    indexReadyCount: readiness?.summary?.indexReady ?? null,
    blockedFromIndexCount: readiness?.summary?.blocked ?? null,
  },
  writes,
};

const rendered = `${stableStringify(output)}\n`;
if (checkMode) {
  if (!fs.existsSync(outputPath)) {
    console.error(`Missing Firestore import plan: ${relative(outputPath)}`);
    process.exit(1);
  }
  const current = fs.readFileSync(outputPath, "utf8");
  if (current !== rendered) {
    console.error(`Firestore import plan is stale: ${relative(outputPath)}`);
    console.error("Run: node tool/host_discovery/export_seed_import_plan.mjs");
    process.exit(1);
  }
} else {
  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, rendered);
}

console.log(
  `Host discovery Firestore import plan ready: ${writes.length} dry-run writes.`
);

function loadSeeds() {
  if (!fs.existsSync(seedRoot)) return [];
  return fs
    .readdirSync(seedRoot)
    .filter((file) => file.endsWith(".json"))
    .sort()
    .map((file) => {
      const fullPath = path.join(seedRoot, file);
      const seed = readJson(fullPath);
      return {
        file: relative(fullPath),
        path: seed.path,
        data: seed.data,
      };
    });
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

function relative(file) {
  return path.relative(repoRoot, file);
}
