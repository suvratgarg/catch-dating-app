#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const intakeRoot = scriptDir;
const repoRoot = path.resolve(intakeRoot, "..", "..");
const curationRoot = path.join(intakeRoot, "curation_decisions");
const generatedCurationStatePath = path.join(intakeRoot, "generated", "organizer_curation_state.json");
const generatedSearchCandidateQueuePath = path.join(
  intakeRoot,
  "generated",
  "search_result_candidate_queue.json"
);

const command = process.argv[2] ?? "help";

if (command === "help" || command === "--help" || command === "-h") {
  printHelp();
} else if (command === "list") {
  listCurationState();
} else if (command === "draft") {
  draftCurationDecision(process.argv.slice(3));
} else {
  console.error(`Unknown organizer curation command: ${command}`);
  printHelp();
  process.exit(64);
}

function listCurationState() {
  const state = fs.existsSync(generatedCurationStatePath) ?
    readJson(generatedCurationStatePath) :
    null;
  if (!state) {
    console.error("Run node tool/organizer_intake/organizer_intake.mjs first.");
    process.exit(1);
  }
  console.log(
    `Organizer curation: ${state.summary.operations} operation(s), ` +
      `${state.summary.merges} merge(s), ` +
      `${state.summary.surfaceDecisions} surface decision(s), ` +
      `${state.summary.splitSurfaces} split surface(s).`
  );
  for (const operation of [
    ...state.mergedEntities.map((item) => ({kind: "merge", ...item})),
    ...state.suppressedEntities.map((item) => ({kind: "suppress", ...item})),
    ...state.surfaceDecisions.map((item) => ({kind: "surface", ...item})),
    ...state.splitSurfaces.map((item) => ({kind: "split", ...item})),
  ]) {
    console.log(`${operation.kind.padEnd(9)} ${operation.operationId} ${operation.reason}`);
  }
}

function draftCurationDecision(argv) {
  const operationType = argv[0];
  const args = parseDraftArgs(argv.slice(1));
  if (!operationType) {
    console.error("Usage: node tool/organizer_intake/curation_decision.mjs draft <operation> [flags]");
    process.exit(64);
  }
  if (!args.reviewer) fail("--reviewer is required.");
  if (!args.date) fail("--date YYYY-MM-DD is required.");
  if (!/^\d{4}-\d{2}-\d{2}$/.test(args.date)) fail("--date must be YYYY-MM-DD.");
  if (!args.reason) fail("--reason is required.");

  const operation = operationFor(operationType, args);
  const curationBatchId = args.batchId ?? `${args.date}-curation-${operationType.replaceAll("_", "-")}`;
  const batch = {
    schemaVersion: 1,
    curationBatchId,
    decidedAt: args.date,
    reviewer: args.reviewer,
    operations: [operation],
  };
  const outputPath = path.join(curationRoot, `${curationBatchId}.json`);
  const rendered = `${stableStringify(batch)}\n`;

  if (args.dryRun) {
    console.log(rendered.trimEnd());
    return;
  }
  if (fs.existsSync(outputPath) && !args.allowOverwrite) {
    fail(`Refusing to overwrite ${relative(outputPath)} without --allow-overwrite.`);
  }
  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, rendered);
  console.log(`Wrote ${relative(outputPath)}.`);
  console.log("Run: node tool/organizer_intake/organizer_intake.mjs");
}

function operationFor(operationType, args) {
  if (operationType === "attach_surface") {
    if (!args.entity) fail("--entity is required for attach_surface.");
    if (!args.searchCandidate) fail("--search-candidate is required for attach_surface.");
    const candidate = searchCandidateFor(args.searchCandidate, args.searchQueue);
    return {
      type: "attach_surface",
      entityId: args.entity,
      sourceCandidateId: candidate.candidateId,
      surface: surfaceForCandidate(candidate),
      reason: args.reason,
    };
  }
  if (operationType === "merge_entity") {
    if (!args.sourceEntity) fail("--source is required for merge_entity.");
    if (!args.targetEntity) fail("--target is required for merge_entity.");
    return {
      type: "merge_entity",
      sourceEntityId: args.sourceEntity,
      targetEntityId: args.targetEntity,
      reason: args.reason,
    };
  }
  if (operationType === "suppress_entity") {
    if (!args.entity) fail("--entity is required for suppress_entity.");
    return {
      type: "suppress_entity",
      entityId: args.entity,
      reason: args.reason,
    };
  }
  if (operationType === "surface_decision") {
    if (!args.entity) fail("--entity is required for surface_decision.");
    if (!args.surface) fail("--surface is required for surface_decision.");
    if (!args.decision) fail("--decision is required for surface_decision.");
    return {
      type: "surface_decision",
      entityId: args.entity,
      surfaceId: args.surface,
      decision: args.decision,
      reason: args.reason,
    };
  }
  if (operationType === "split_surface") {
    if (!args.entity) fail("--entity is required for split_surface.");
    if (!args.surface) fail("--surface is required for split_surface.");
    if (!args.newEntity) fail("--new-entity is required for split_surface.");
    return {
      type: "split_surface",
      entityId: args.entity,
      surfaceId: args.surface,
      newEntityId: args.newEntity,
      reason: args.reason,
    };
  }
  fail(`Unknown operation type: ${operationType}`);
}

function parseDraftArgs(argv) {
  const parsed = {
    allowOverwrite: false,
    batchId: null,
    date: null,
    decision: null,
    dryRun: false,
    entity: null,
    newEntity: null,
    reason: null,
    reviewer: null,
    searchCandidate: null,
    searchQueue: null,
    sourceEntity: null,
    surface: null,
    targetEntity: null,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--allow-overwrite") parsed.allowOverwrite = true;
    else if (arg === "--dry-run") parsed.dryRun = true;
    else if (arg === "--batch-id") parsed.batchId = requiredValue(argv, ++index, arg);
    else if (arg === "--date") parsed.date = requiredValue(argv, ++index, arg);
    else if (arg === "--decision") parsed.decision = requiredValue(argv, ++index, arg);
    else if (arg === "--entity") parsed.entity = requiredValue(argv, ++index, arg);
    else if (arg === "--new-entity") parsed.newEntity = requiredValue(argv, ++index, arg);
    else if (arg === "--reason") parsed.reason = requiredValue(argv, ++index, arg);
    else if (arg === "--reviewer") parsed.reviewer = requiredValue(argv, ++index, arg);
    else if (arg === "--search-candidate") parsed.searchCandidate = requiredValue(argv, ++index, arg);
    else if (arg === "--search-queue") parsed.searchQueue = requiredValue(argv, ++index, arg);
    else if (arg === "--source") parsed.sourceEntity = requiredValue(argv, ++index, arg);
    else if (arg === "--surface") parsed.surface = requiredValue(argv, ++index, arg);
    else if (arg === "--target") parsed.targetEntity = requiredValue(argv, ++index, arg);
    else fail(`Unknown argument: ${arg}`);
  }
  return parsed;
}

function searchCandidateFor(candidateId, queuePath) {
  const candidateQueuePath = queuePath ?
    path.resolve(repoRoot, queuePath) :
    generatedSearchCandidateQueuePath;
  if (!fs.existsSync(candidateQueuePath)) {
    fail(`Search candidate queue does not exist: ${relative(candidateQueuePath)}`);
  }
  const queue = readJson(candidateQueuePath);
  const candidate = (queue.candidates ?? []).find((entry) => entry.candidateId === candidateId);
  if (!candidate) {
    fail(`Search candidate ${candidateId} not found in ${relative(candidateQueuePath)}.`);
  }
  return candidate;
}

function surfaceForCandidate(candidate) {
  const surface = structuredClone(candidate.suggestedSurface);
  surface.evidenceRefs = [
    ...(surface.evidenceRefs ?? []),
    {
      type: "manualNote",
      ref: "tool/organizer_intake/generated/search_result_candidate_queue.json",
      description:
        `Search candidate ${candidate.candidateId} observed ${candidate.observedAt}.`,
    },
  ];
  surface.notes = appendSentence(
    surface.notes,
    `Candidate title: ${candidate.title}`
  );
  return surface;
}

function appendSentence(value, sentence) {
  const base = String(value ?? "").trim();
  const next = String(sentence ?? "").trim();
  if (!base) return next;
  if (!next) return base;
  return `${base} ${next}`;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) fail(`${flag} requires a value.`);
  return value;
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

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/curation_decision.mjs <command>

Commands:
  list
    Print generated organizer curation state.

  draft <attach_surface|merge_entity|suppress_entity|surface_decision|split_surface>
    Draft a repo-backed curation decision batch.

Examples:
  node tool/organizer_intake/curation_decision.mjs list
  node tool/organizer_intake/curation_decision.mjs draft attach_surface \\
    --entity afterfly \\
    --search-candidate 2026-06-17-afterfly-search-fixture:sort-my-scene \\
    --reviewer admin --date 2026-06-17 \\
    --reason "Sort My Scene profile belongs to Afterfly."
  node tool/organizer_intake/curation_decision.mjs draft merge_entity \\
    --source duplicate-afterfly --target afterfly --reviewer admin \\
    --date 2026-06-17 --reason "Same organizer identity."
  node tool/organizer_intake/curation_decision.mjs draft surface_decision \\
    --entity afterfly --surface afterfly-wrong-website-reported \\
    --decision reject_wrong_entity --reviewer admin --date 2026-06-17 \\
    --reason "Website belongs to another Afterfly."
`);
}

function fail(message) {
  console.error(message);
  process.exit(1);
}
