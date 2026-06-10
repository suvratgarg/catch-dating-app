#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const discoveryRoot = scriptDir;
const repoRoot = path.resolve(discoveryRoot, "..", "..");
const candidateBatchRoot = path.join(discoveryRoot, "candidate_batches");
const seedRoot = path.join(discoveryRoot, "seed_clubs");
const evidencePath = path.join(discoveryRoot, "generated", "source_evidence.json");
const outputPath = path.join(discoveryRoot, "generated", "index_readiness_report.json");
const checkMode = process.argv.includes("--check");

const candidates = loadCandidates();
const seededCandidates = candidates.filter((candidate) => candidate.state === "page_seeded");
const seedDocs = loadSeedDocs();
const sourceEvidence = fs.existsSync(evidencePath) ? readJson(evidencePath).evidence ?? [] : [];
const sourceEvidenceByCandidate = groupBy(sourceEvidence, "candidateId");

const results = seededCandidates.map((candidate) => checkCandidate(candidate));
const output = {
  schemaVersion: 1,
  generatedFrom: {
    candidateBatches: fs
      .readdirSync(candidateBatchRoot)
      .filter((file) => file.endsWith(".json"))
      .sort()
      .map((file) => relative(path.join(candidateBatchRoot, file))),
    seedDocs: [...seedDocs.values()].map((entry) => entry.file).sort(),
    sourceEvidence: relative(evidencePath),
  },
  checkedAt: "2026-06-10",
  summary: {
    checked: results.length,
    indexReady: results.filter((result) => result.indexReady).length,
    blocked: results.filter((result) => !result.indexReady).length,
  },
  results,
};

const rendered = `${stableStringify(output)}\n`;
if (checkMode) {
  if (!fs.existsSync(outputPath)) {
    console.error(`Missing index-readiness report: ${relative(outputPath)}`);
    process.exit(1);
  }
  const current = fs.readFileSync(outputPath, "utf8");
  if (current !== rendered) {
    console.error(`Index-readiness report is stale: ${relative(outputPath)}`);
    console.error("Run: node tool/host_discovery/check_index_readiness.mjs");
    process.exit(1);
  }
} else {
  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, rendered);
}

console.log(
  `Host discovery index readiness checked: ${output.summary.indexReady} ready, ${output.summary.blocked} blocked.`
);

function checkCandidate(candidate) {
  const seed = seedDocs.get(candidate.seedDocumentPath);
  const club = seed?.seed?.data ?? {};
  const evidence = sourceEvidenceByCandidate.get(candidate.candidateId) ?? [];
  const gates = [
    gate("canonical_seed_doc", Boolean(seed), "Candidate has a backend-shaped seed club document."),
    gate(
      "qa_noindex_until_ready",
      club.publicPage?.publishStatus === "qa" &&
        club.publicPage?.indexStatus === "noindex" &&
        club.publicPage?.robots === "noindex, follow",
      "Seed page remains QA/noindex until all readiness gates pass."
    ),
    gate(
      "unclaimed_claim_cta",
      club.claim?.state === "unclaimed" && typeof club.claim?.claimHref === "string" &&
        club.claim.claimHref.length > 0,
      "Unclaimed page has a claim/correction path."
    ),
    gate(
      "hidden_from_app",
      club.appVisibility === "hidden",
      "Programmatic listing is hidden from native app discovery until approved."
    ),
    gate(
      "stable_public_source",
      evidence.some((entry) =>
        entry.displayPolicy?.publicDisplayAllowed === true &&
        entry.sourceConfidence === "high" &&
        typeof entry.sourceUrl === "string"
      ),
      "At least one high-confidence public source is available."
    ),
    gate(
      "owner_safe_profile_copy",
      textLength(club.publicProfile?.summary) >= 140 &&
        textLength(club.publicProfile?.sourceSummary) >= 80 &&
        Array.isArray(club.publicProfile?.facts) &&
        club.publicProfile.facts.length >= 5,
      "Profile has enough original owner-safe summary and facts."
    ),
    gate(
      "city_identity_verified",
      candidate.verificationStatus !== "source_backed_city_ambiguous" &&
        !missingEvidence(club).some((item) => item.toLowerCase().includes("city-specific")),
      "Target city identity is verified by public evidence."
    ),
    gate(
      "current_cadence_verified",
      !missingEvidence(club).some((item) =>
        item.toLowerCase().includes("current") ||
        item.toLowerCase().includes("cadence")
      ),
      "Current event cadence is verified."
    ),
    gate(
      "owner_or_contact_verified",
      !missingEvidence(club).some((item) =>
        item.toLowerCase().includes("owner") ||
        item.toLowerCase().includes("contact")
      ),
      "Owner, host, or preferred business contact has been verified."
    ),
    gate(
      "media_permission_verified",
      !missingEvidence(club).some((item) =>
        item.toLowerCase().includes("logo") ||
        item.toLowerCase().includes("profile image") ||
        item.toLowerCase().includes("permission")
      ),
      "Logo or profile media permission is verified, or a neutral/generated asset is selected."
    ),
  ];
  const blockers = gates
    .filter((entry) => !entry.passed)
    .map((entry) => entry.id);
  return {
    candidateId: candidate.candidateId,
    seedDocumentPath: candidate.seedDocumentPath,
    canonicalPath: candidate.canonicalPath,
    indexReady: blockers.length === 0,
    blockers,
    gates,
    nextAction: blockers.length === 0 ?
      "Flip publicPage.indexStatus to index and publishStatus to published after final human review." :
      candidate.nextAction,
  };
}

function gate(id, passed, description) {
  return {id, passed, description};
}

function loadCandidates() {
  const candidates = [];
  for (const file of fs.readdirSync(candidateBatchRoot).filter((entry) => entry.endsWith(".json")).sort()) {
    const batch = readJson(path.join(candidateBatchRoot, file));
    candidates.push(...(batch.candidates ?? []));
  }
  return candidates;
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

function missingEvidence(club) {
  return Array.isArray(club.publicProfile?.missingEvidence) ?
    club.publicProfile.missingEvidence.filter((item) => typeof item === "string") :
    [];
}

function textLength(value) {
  return typeof value === "string" ? value.trim().length : 0;
}

function groupBy(items, field) {
  const groups = new Map();
  for (const item of items) {
    const key = item[field] ?? "<missing>";
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(item);
  }
  return groups;
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
