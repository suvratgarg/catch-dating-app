#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, "..", "..");
const generatedQueuePath = path.join(
  scriptDir,
  "generated",
  "external_event_candidate_queue.json"
);
const decisionsRoot = path.join(scriptDir, "event_review_decisions");

const command = process.argv[2] ?? "help";
const args = process.argv.slice(3);

if (command === "help" || command === "--help" || command === "-h") {
  printHelp();
} else if (command === "list") {
  listQueue(args);
} else if (command === "draft") {
  draftDecision(args);
} else {
  console.error(`Unknown organizer event review command: ${command}`);
  printHelp();
  process.exit(64);
}

function listQueue(rawArgs = []) {
  const flags = parseFlags(rawArgs);
  const queue = loadQueue(flags.queue);
  console.log(
    `External event candidate queue: ${queue.summary.candidates} candidate(s), ` +
      `${queue.summary.reviewed ?? 0} reviewed, ` +
      `${queue.summary.blocked} blocked.`
  );
  for (const candidate of queue.candidates) {
    console.log(
      [
        candidate.candidateId.padEnd(52),
        candidate.entityId.padEnd(18),
        candidate.platform.padEnd(10),
        candidate.reviewStatus ?? "needs_admin_review",
        candidate.blockers.length > 0 ?
          `blocked: ${candidate.blockers.join(", ")}` :
          "ready",
      ].join("  ")
    );
  }
}

function draftDecision(rawArgs) {
  const candidateId = rawArgs[0];
  if (!candidateId || candidateId.startsWith("--")) {
    console.error(
      "Usage: node tool/organizer_intake/event_review_decision.mjs " +
        "draft <candidateId> [flags]"
    );
    process.exit(64);
  }

  const flags = parseFlags(rawArgs.slice(1));
  const decision = requiredFlag(flags, "decision");
  const reviewer = requiredFlag(flags, "reviewer");
  const date = requiredFlag(flags, "date");
  const note = requiredFlag(flags, "note");
  const dryRun = Boolean(flags["dry-run"]);
  const confirmImportChecklist = Boolean(flags["confirm-import-checklist"]);

  if (!["approve_for_import", "hold", "reject"].includes(decision)) {
    failFlag("decision", "must be approve_for_import, hold, or reject");
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
    failFlag("date", "must be YYYY-MM-DD");
  }
  if (decision === "approve_for_import" && !confirmImportChecklist) {
    failFlag(
      "confirm-import-checklist",
      "is required before approving an event candidate for future import"
    );
  }

  const queue = loadQueue(flags.queue);
  const candidate = queue.candidates.find((entry) =>
    entry.candidateId === candidateId
  );
  if (!candidate) {
    console.error(`No event candidate found for ${candidateId}.`);
    console.error("Run node tool/organizer_intake/ingest_event_sources.mjs first if inputs changed.");
    process.exit(1);
  }
  if (existingDecisionFiles(candidateId).length > 0) {
    console.error(`An event review decision already exists for ${candidateId}:`);
    for (const file of existingDecisionFiles(candidateId)) {
      console.error(`- ${relative(file)}`);
    }
    process.exit(1);
  }

  const eventReviewBatchId = [
    date,
    candidate.entityId,
    "event",
    decision.replaceAll("_", "-"),
  ].join("-");
  const outputPath = path.join(decisionsRoot, `${eventReviewBatchId}.json`);
  const checklist = confirmImportChecklist ?
    completeChecklist() :
    emptyChecklist();
  const payload = {
    schemaVersion: 1,
    eventReviewBatchId,
    decidedAt: date,
    reviewer,
    decisions: [
      {
        candidateId,
        decision,
        checklist,
        note,
      },
    ],
  };
  const rendered = `${stableStringify(payload)}\n`;

  if (dryRun) {
    console.log(`Would write ${relative(outputPath)}:`);
    console.log(rendered);
    return;
  }

  fs.mkdirSync(decisionsRoot, {recursive: true});
  if (fs.existsSync(outputPath)) {
    console.error(`Decision file already exists: ${relative(outputPath)}`);
    process.exit(1);
  }
  fs.writeFileSync(outputPath, rendered);
  console.log(`Wrote ${relative(outputPath)}.`);
  console.log("Run: node tool/organizer_intake/ingest_event_sources.mjs");
  console.log("Run: node tool/organizer_intake/organizer_intake.mjs");
}

function loadQueue(queuePath) {
  const targetPath = queuePath ?
    path.resolve(repoRoot, queuePath) :
    generatedQueuePath;
  if (!fs.existsSync(targetPath)) {
    console.error(`Missing event candidate queue: ${relative(targetPath)}`);
    console.error("Run: node tool/organizer_intake/ingest_event_sources.mjs");
    process.exit(1);
  }
  return JSON.parse(fs.readFileSync(targetPath, "utf8"));
}

function existingDecisionFiles(candidateId) {
  if (!fs.existsSync(decisionsRoot)) return [];
  const files = fs
    .readdirSync(decisionsRoot)
    .filter((file) => file.endsWith(".json"))
    .map((file) => path.join(decisionsRoot, file));
  return files.filter((file) => {
    const decision = JSON.parse(fs.readFileSync(file, "utf8"));
    return (decision.decisions ?? []).some((entry) =>
      entry.candidateId === candidateId
    );
  });
}

function completeChecklist() {
  return {
    dedupeReviewed: true,
    identityReviewed: true,
    importPolicyAcknowledged: true,
    locationReviewed: true,
    ownerSafeCopyReviewed: true,
    sourceEventReviewed: true,
    timeReviewed: true,
  };
}

function emptyChecklist() {
  return {
    dedupeReviewed: false,
    identityReviewed: false,
    importPolicyAcknowledged: false,
    locationReviewed: false,
    ownerSafeCopyReviewed: false,
    sourceEventReviewed: false,
    timeReviewed: false,
  };
}

function parseFlags(flagArgs) {
  const flags = {};
  for (let index = 0; index < flagArgs.length; index += 1) {
    const arg = flagArgs[index];
    if (!arg.startsWith("--")) {
      console.error(`Unexpected positional argument: ${arg}`);
      process.exit(64);
    }
    const key = arg.slice(2);
    if (["confirm-import-checklist", "dry-run"].includes(key)) {
      flags[key] = true;
      continue;
    }
    const value = flagArgs[index + 1];
    if (!value || value.startsWith("--")) {
      console.error(`Flag --${key} requires a value.`);
      process.exit(64);
    }
    flags[key] = value;
    index += 1;
  }
  return flags;
}

function requiredFlag(flags, name) {
  const value = flags[name];
  if (typeof value !== "string" || value.trim().length === 0) {
    failFlag(name, "is required");
  }
  return value.trim();
}

function failFlag(name, reason) {
  console.error(`Invalid --${name}: ${reason}.`);
  process.exit(64);
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

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/event_review_decision.mjs <command>

Commands:
  list
    Print the generated external event candidate queue.

  draft <candidateId> --decision <approve_for_import|hold|reject>
      --reviewer <name> --date <YYYY-MM-DD> --note <text> [--queue <path>]
      [--confirm-import-checklist] [--dry-run]

Examples:
  node tool/organizer_intake/event_review_decision.mjs list
  node tool/organizer_intake/event_review_decision.mjs draft \\
    2026-06-17-afterfly-luma-events:pxgmph3b \\
    --decision approve_for_import \\
    --reviewer "admin@example.com" \\
    --date 2026-06-17 \\
    --note "Manual event QA complete." \\
    --confirm-import-checklist
`);
}
