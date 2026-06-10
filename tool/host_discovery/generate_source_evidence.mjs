#!/usr/bin/env node
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const discoveryRoot = scriptDir;
const repoRoot = path.resolve(discoveryRoot, "..", "..");
const runsRoot = path.join(discoveryRoot, "runs");
const seedRoot = path.join(discoveryRoot, "seed_clubs");
const outputPath = path.join(discoveryRoot, "generated", "source_evidence.json");
const checkMode = process.argv.includes("--check");

const seedDocs = loadSeedDocs();
const runFiles = fs.existsSync(runsRoot) ?
  fs.readdirSync(runsRoot).filter((file) => file.endsWith(".json")).sort() :
  [];
const evidence = [];

for (const file of runFiles) {
  const runPath = path.join(runsRoot, file);
  const run = readJson(runPath);
  const seed = run.seedDocumentPath ? seedDocs.get(run.seedDocumentPath) : null;
  const clubId = run.seedDocumentPath?.startsWith("clubs/") ?
    run.seedDocumentPath.slice("clubs/".length) :
    null;

  for (const [index, source] of (run.discoveredSources ?? []).entries()) {
    const record = normalizeEvidenceRecord({
      run,
      source,
      index,
      runFile: relative(runPath),
      seedFile: seed?.file ?? null,
      clubId,
    });
    evidence.push(record);
  }
}

const output = {
  schemaVersion: 1,
  generatedFrom: {
    runs: runFiles.map((file) => relative(path.join(runsRoot, file))),
    seedDocs: [...seedDocs.values()].map((entry) => entry.file).sort(),
  },
  evidenceCount: evidence.length,
  counts: {
    byCandidate: countBy(evidence, "candidateId"),
    byType: countBy(evidence, "sourceType"),
    publicDisplayAllowed: evidence.filter((entry) => entry.displayPolicy.publicDisplayAllowed).length,
  },
  evidence: evidence.sort((a, b) => a.evidenceId.localeCompare(b.evidenceId)),
};

const rendered = `${stableStringify(output)}\n`;
if (checkMode) {
  if (!fs.existsSync(outputPath)) {
    console.error(`Missing generated source evidence: ${relative(outputPath)}`);
    process.exit(1);
  }
  const current = fs.readFileSync(outputPath, "utf8");
  if (current !== rendered) {
    console.error(`Generated source evidence is stale: ${relative(outputPath)}`);
    console.error("Run: node tool/host_discovery/generate_source_evidence.mjs");
    process.exit(1);
  }
} else {
  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, rendered);
}

console.log(`Host discovery source evidence ready: ${evidence.length} records.`);

function normalizeEvidenceRecord({run, source, index, runFile, seedFile, clubId}) {
  const evidenceBase = {
    runId: run.runId,
    candidateId: run.candidateId,
    clubId,
    seedDocumentPath: run.seedDocumentPath ?? null,
    sourceType: source.type,
    sourceUrl: source.url ?? null,
    sourceOwner: source.sourceOwner ?? null,
    capturedAt: run.searchedAt,
    sourceConfidence: inferSourceConfidence(source.type),
    capturedFacts: arrayOfStrings(source.capturedFacts),
    capturedButNotDisplayed: arrayOfStrings(source.capturedButNotDisplayed),
    sourceRunFile: runFile,
    seedFile,
  };
  const evidenceId = evidenceIdFor(evidenceBase, index);
  return {
    evidenceId,
    ...evidenceBase,
    displayPolicy: displayPolicyFor(source),
    futureFirestorePath: `clubSourceEvidence/${evidenceId}`,
  };
}

function displayPolicyFor(source) {
  const hidden = arrayOfStrings(source.capturedButNotDisplayed);
  return {
    publicDisplayAllowed: source.type !== "embedded_event_data",
    ownerSafeSummaryAllowed: true,
    rawSnapshotAllowedOnWebsite: false,
    excludedFromPublicProfile: hidden,
    notes: [
      "Display original Catch-written summaries instead of copied source text.",
      "Do not display raw images, private coordinates, registration counts, or commerce internals without owner permission.",
    ],
  };
}

function inferSourceConfidence(type) {
  if (type === "official_site" || type === "public_event_page") return "high";
  if (type === "embedded_event_data") return "high";
  if (type.includes("registration")) return "medium";
  return "medium";
}

function loadSeedDocs() {
  const docs = new Map();
  if (!fs.existsSync(seedRoot)) return docs;
  for (const file of fs.readdirSync(seedRoot).filter((entry) => entry.endsWith(".json")).sort()) {
    const fullPath = path.join(seedRoot, file);
    const seed = readJson(fullPath);
    if (typeof seed.path === "string") {
      docs.set(seed.path, {file: relative(fullPath), seed});
    }
  }
  return docs;
}

function evidenceIdFor(record, index) {
  const slug = `${record.candidateId ?? "unknown"}-${record.sourceType}-${index}`;
  const hash = crypto.createHash("sha256")
    .update(stableStringify({
      candidateId: record.candidateId,
      sourceType: record.sourceType,
      sourceUrl: record.sourceUrl,
      capturedFacts: record.capturedFacts,
    }))
    .digest("hex")
    .slice(0, 10);
  return `${slugify(slug)}-${hash}`;
}

function countBy(items, field) {
  const counts = {};
  for (const item of items) {
    const key = item[field] ?? "<missing>";
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return Object.fromEntries(Object.entries(counts).sort(([a], [b]) => a.localeCompare(b)));
}

function arrayOfStrings(value) {
  return Array.isArray(value) ? value.filter((item) => typeof item === "string") : [];
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
