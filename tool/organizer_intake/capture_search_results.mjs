#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {
  buildSearchResultBatchFromCapture,
  findSearchPlanEntry,
} from "./lib/search_capture_core.mjs";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, "..", "..");
const defaultSearchPlanPath = path.join(repoRoot, "tool", "host_discovery", "generated", "search_plan.json");
const searchResultBatchesRoot = path.join(scriptDir, "search_result_batches");

const flags = parseFlags(process.argv.slice(2));

if (flags.help) {
  printHelp();
  process.exit(0);
}

try {
  if (!flags.runKey) throw new Error("--run-key is required.");
  if (!flags.rawResults) throw new Error("--raw-results is required.");
  if (!flags.date) throw new Error("--date YYYY-MM-DD is required.");

  const searchPlanPath = path.resolve(repoRoot, flags.searchPlan ?? defaultSearchPlanPath);
  const searchPlan = readJson(searchPlanPath);
  const planEntry = findSearchPlanEntry(searchPlan, flags.runKey);
  if (!planEntry) {
    throw new Error(`Run key not found in ${relative(searchPlanPath)}: ${flags.runKey}`);
  }

  const batch = buildSearchResultBatchFromCapture({
    capture: readJson(path.resolve(repoRoot, flags.rawResults)),
    capturedAt: flags.date,
    planEntry,
    source: flags.source,
  });
  if (flags.batchId) batch.batchId = flags.batchId;

  const outputPath = path.resolve(
    repoRoot,
    flags.output ?? path.join(searchResultBatchesRoot, `${batch.batchId}.json`)
  );
  const rendered = `${stableStringify(batch)}\n`;

  if (flags.check) {
    if (!fs.existsSync(outputPath)) {
      throw new Error(`Missing expected capture batch: ${relative(outputPath)}`);
    }
    const current = fs.readFileSync(outputPath, "utf8");
    if (current !== rendered) {
      throw new Error(`Capture batch is stale: ${relative(outputPath)}`);
    }
    console.log(`Organizer search capture is current: ${relative(outputPath)}`);
    process.exit(0);
  }

  if (flags.dryRun || !flags.write) {
    console.log(rendered.trimEnd());
    if (!flags.write) {
      console.error("\nDry run only. Re-run with --write after reviewing the batch.");
    }
    process.exit(0);
  }

  if (fs.existsSync(outputPath) && !flags.allowOverwrite) {
    throw new Error(`Refusing to overwrite ${relative(outputPath)} without --allow-overwrite.`);
  }
  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, rendered);
  console.log(
    `Captured ${batch.results.length} search result(s) for ${batch.query}.`
  );
  console.log(`Wrote ${relative(outputPath)}.`);
  console.log("Run: node tool/organizer_intake/ingest_search_results.mjs");
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
}

function parseFlags(argv) {
  const flags = {
    allowOverwrite: false,
    batchId: null,
    check: false,
    date: null,
    dryRun: false,
    help: false,
    output: null,
    rawResults: null,
    runKey: null,
    searchPlan: null,
    source: "manual_google_search",
    write: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--allow-overwrite") flags.allowOverwrite = true;
    else if (arg === "--check") flags.check = true;
    else if (arg === "--dry-run") flags.dryRun = true;
    else if (arg === "--help" || arg === "-h") flags.help = true;
    else if (arg === "--write") flags.write = true;
    else if ([
      "--batch-id",
      "--date",
      "--output",
      "--raw-results",
      "--run-key",
      "--search-plan",
      "--source",
    ].includes(arg)) {
      const value = argv[index + 1];
      if (!value || value.startsWith("--")) throw new Error(`${arg} requires a value.`);
      flags[toCamelCase(arg.slice(2))] = value;
      index += 1;
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return flags;
}

function toCamelCase(value) {
  return value.replace(/-([a-z])/g, (_, char) => char.toUpperCase());
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
  node tool/organizer_intake/capture_search_results.mjs \\
    --run-key <host-discovery-run-key> \\
    --raw-results <provider-json> \\
    --date YYYY-MM-DD [flags]

Flags:
  --source <source>       manual_google_search, manual_web_search, serp_api, custom_scraper, or fixture.
  --search-plan <file>    Defaults to tool/host_discovery/generated/search_plan.json.
  --batch-id <id>         Override the deterministic output batch id.
  --output <file>         Output path for --write or --check.
  --write                 Persist the normalized batch. Omitted means dry run.
  --allow-overwrite       Allow --write to replace an existing batch.
  --check                 Compare normalized output with --output.
  --dry-run               Print normalized output without writing.
`);
}
