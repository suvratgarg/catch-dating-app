#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {buildSearchResultCandidateQueue} from "./lib/search_result_ingest_core.mjs";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, "..", "..");
const searchBatchRoot = path.join(scriptDir, "search_result_batches");
const generatedOutputPath = path.join(scriptDir, "generated", "search_result_candidate_queue.json");
const dedupeIndexPath = path.join(scriptDir, "generated", "organizer_dedupe_index.json");

const flags = parseFlags(process.argv.slice(2));

if (flags.help) {
  printHelp();
  process.exit(0);
}

try {
  const batches = loadBatches(flags.input ?? flags.fixture);
  const dedupeIndex = fs.existsSync(dedupeIndexPath) ? readJson(dedupeIndexPath) : null;
  const queue = buildSearchResultCandidateQueue(batches, {dedupeIndex});
  if (queue.errors.length > 0) {
    console.error("Organizer search-result ingestion validation failed:");
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
      console.error(`Missing search-result candidate queue: ${relative(outputPath)}`);
      process.exit(1);
    }
    const current = fs.readFileSync(outputPath, "utf8");
    if (current !== rendered) {
      console.error(`Search-result candidate queue is stale: ${relative(outputPath)}`);
      console.error(`Run: node tool/organizer_intake/ingest_search_results.mjs --output ${relative(outputPath)}`);
      process.exit(1);
    }
    console.log(`Organizer search-result candidate queue is current: ${relative(outputPath)}`);
    process.exit(0);
  }

  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, rendered);
  console.log(
    `Organizer search-result ingestion ready: ${queue.summary.batches} batch(es), ` +
      `${queue.summary.results} result(s), ${queue.summary.candidates} candidate(s), ` +
      `${queue.summary.matchedExistingEntities} matched existing surface key(s).`
  );
  console.log(`Wrote ${relative(outputPath)}.`);
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
}

function loadBatches(inputPath) {
  const target = inputPath ? path.resolve(repoRoot, inputPath) : searchBatchRoot;
  if (!fs.existsSync(target)) {
    if (inputPath) throw new Error(`Input does not exist: ${inputPath}`);
    return [];
  }
  const stats = fs.statSync(target);
  if (stats.isFile()) return [readJson(target)];
  if (!stats.isDirectory()) throw new Error(`Input must be a file or directory: ${inputPath}`);
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
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--check") {
      flags.check = true;
    } else if (arg === "--dry-run") {
      flags.dryRun = true;
    } else if (arg === "--help" || arg === "-h") {
      flags.help = true;
    } else if (["--fixture", "--input", "--output"].includes(arg)) {
      const value = argv[index + 1];
      if (!value || value.startsWith("--")) throw new Error(`${arg} requires a value.`);
      flags[arg.slice(2)] = value;
      index += 1;
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return flags;
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
  node tool/organizer_intake/ingest_search_results.mjs [flags]

Flags:
  --input <file-or-dir>  Read a search-result batch file or directory.
  --fixture <file>       Alias for --input, intended for tests/checks.
  --output <file>        Write or check a candidate queue at this path.
  --check                Compare output with the generated candidate queue.
  --dry-run              Print candidate queue without writing.
`);
}
