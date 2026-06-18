#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {buildExternalEventCandidateQueue} from "./lib/event_source_ingest_core.mjs";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, "..", "..");
const eventBatchRoot = path.join(scriptDir, "event_source_batches");
const eventReviewDecisionsRoot = path.join(scriptDir, "event_review_decisions");
const eventLocationResolutionsRoot = path.join(
  scriptDir,
  "event_location_resolutions"
);
const generatedOutputPath = path.join(
  scriptDir,
  "generated",
  "external_event_candidate_queue.json"
);

const flags = parseFlags(process.argv.slice(2));

if (flags.help) {
  printHelp();
  process.exit(0);
}

try {
  const batches = loadBatches(flags.input ?? flags.fixture);
  const reviewDecisionBatches = loadReviewDecisionBatches(
    flags.reviewDecisionsRoot
  );
  const locationResolutionBatches = loadLocationResolutionBatches(
    flags.locationResolutionsRoot
  );
  const queue = buildExternalEventCandidateQueue(batches, {
    reviewDecisionBatches,
    locationResolutionBatches,
  });
  if (queue.errors.length > 0) {
    console.error("External event source ingestion validation failed:");
    for (const error of queue.errors) console.error(`- ${error}`);
    process.exit(1);
  }

  const outputPath = path.resolve(repoRoot, flags.output ?? generatedOutputPath);
  const rendered = `${stableStringify(queue)}\n`;

  if (flags.dryRun) {
    console.log(rendered.trimEnd());
    process.exit(0);
  }

  if (flags.check) {
    if (!fs.existsSync(outputPath)) {
      console.error(`Missing external event candidate queue: ${relative(outputPath)}`);
      process.exit(1);
    }
    const current = fs.readFileSync(outputPath, "utf8");
    if (current !== rendered) {
      console.error(`External event candidate queue is stale: ${relative(outputPath)}`);
      console.error(`Run: node tool/organizer_intake/ingest_event_sources.mjs --output ${relative(outputPath)}`);
      process.exit(1);
    }
    console.log(`External event candidate queue is current: ${relative(outputPath)}`);
    process.exit(0);
  }

  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, rendered);
  console.log(
    `External event ingestion ready: ${queue.summary.batches} batch(es), ` +
      `${queue.summary.events} event(s), ${queue.summary.candidates} candidate(s), ` +
      `${queue.summary.blocked} blocked by policy.`
  );
  console.log(`Wrote ${relative(outputPath)}.`);
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
}

function loadBatches(inputPath) {
  const target = inputPath ? path.resolve(repoRoot, inputPath) : eventBatchRoot;
  if (!fs.existsSync(target)) {
    if (inputPath) throw new Error(`Input does not exist: ${inputPath}`);
    return [];
  }
  const stats = fs.statSync(target);
  if (stats.isFile()) return [readJson(target)];
  if (!stats.isDirectory()) {
    throw new Error(`Input must be a file or directory: ${inputPath}`);
  }
  return fs
    .readdirSync(target)
    .filter((file) => file.endsWith(".json"))
    .sort()
    .map((file) => readJson(path.join(target, file)));
}

function parseFlags(argv) {
  const flags = {
    check: false,
    dryRun: false,
    fixture: null,
    help: false,
    input: null,
    output: null,
    reviewDecisionsRoot: null,
    locationResolutionsRoot: null,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--check") flags.check = true;
    else if (arg === "--dry-run") flags.dryRun = true;
    else if (arg === "--help" || arg === "-h") flags.help = true;
    else if ([
      "--fixture",
      "--input",
      "--output",
      "--review-decisions-root",
      "--location-resolutions-root",
    ].includes(arg)) {
      const value = argv[index + 1];
      if (!value || value.startsWith("--")) {
        throw new Error(`${arg} requires a value.`);
      }
      flags[camelFlag(arg.slice(2))] = value;
      index += 1;
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return flags;
}

function loadReviewDecisionBatches(inputPath) {
  const target = inputPath ?
    path.resolve(repoRoot, inputPath) :
    eventReviewDecisionsRoot;
  if (!fs.existsSync(target)) return [];
  const stats = fs.statSync(target);
  if (stats.isFile()) return [readJson(target)];
  if (!stats.isDirectory()) {
    throw new Error(`Review decisions input must be a file or directory: ${inputPath}`);
  }
  return fs
    .readdirSync(target)
    .filter((file) => file.endsWith(".json"))
    .sort()
    .map((file) => ({
      ...readJson(path.join(target, file)),
      file: relative(path.join(target, file)),
    }));
}

function loadLocationResolutionBatches(inputPath) {
  const target = inputPath ?
    path.resolve(repoRoot, inputPath) :
    eventLocationResolutionsRoot;
  if (!fs.existsSync(target)) return [];
  const stats = fs.statSync(target);
  if (stats.isFile()) return [readJson(target)];
  if (!stats.isDirectory()) {
    throw new Error(
      `Location resolutions input must be a file or directory: ${inputPath}`
    );
  }
  return fs
    .readdirSync(target)
    .filter((file) => file.endsWith(".json"))
    .sort()
    .map((file) => ({
      ...readJson(path.join(target, file)),
      file: relative(path.join(target, file)),
    }));
}

function camelFlag(value) {
  return value.replace(/-([a-z])/g, (_match, letter) => letter.toUpperCase());
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function relative(file) {
  return path.relative(repoRoot, file);
}

function stableStringify(value) {
  return JSON.stringify(sortValue(value), null, 2);
}

function sortValue(value) {
  if (Array.isArray(value)) return value.map(sortValue);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([key, nested]) => [key, sortValue(nested)])
    );
  }
  return value;
}

function printHelp() {
  console.log(`Usage:
  node tool/organizer_intake/ingest_event_sources.mjs [flags]

Flags:
  --input <file-or-dir>  Read an event source batch file or directory.
  --fixture <file>       Alias for --input, intended for tests/checks.
  --output <file>        Write or check a candidate queue at this path.
  --review-decisions-root <file-or-dir>
                        Read local event review decision batches.
  --location-resolutions-root <file-or-dir>
                        Read local event location resolution batches.
  --check                Compare output with the generated candidate queue.
  --dry-run              Print candidate queue without writing.
`);
}
