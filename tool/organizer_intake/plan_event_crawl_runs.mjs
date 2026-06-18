#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {buildEventCrawlRunPlan} from
  "./lib/event_crawl_run_plan_core.mjs";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, "..", "..");
const defaultEventCrawlPlanPath = path.join(
  scriptDir,
  "generated",
  "event_crawl_plan.json"
);
const defaultOutputPath = path.join(
  scriptDir,
  "generated",
  "event_crawl_run_plan.json"
);

const args = parseArgs(process.argv.slice(2));
if (args.help) {
  printHelp();
  process.exit(0);
}

const eventCrawlPlanPath = path.resolve(
  args.eventCrawlPlan ?? defaultEventCrawlPlanPath
);
const outputPath = path.resolve(args.output ?? defaultOutputPath);
if (!fs.existsSync(eventCrawlPlanPath)) {
  fail(`Missing event crawl plan: ${relative(eventCrawlPlanPath)}`);
}

const eventCrawlPlan = readJson(eventCrawlPlanPath);
const plan = buildEventCrawlRunPlan({eventCrawlPlan});
const rendered = `${stableStringify(plan)}\n`;

if (args.check) {
  if (!fs.existsSync(outputPath)) {
    fail(`Missing event crawl run plan: ${relative(outputPath)}`);
  }
  const current = fs.readFileSync(outputPath, "utf8");
  if (current !== rendered) {
    fail(
      `Event crawl run plan is stale: ${relative(outputPath)}\n` +
        "Run node tool/organizer_intake/plan_event_crawl_runs.mjs"
    );
  }
  console.log(`Event crawl run plan is current: ${relative(outputPath)}`);
  process.exit(0);
}

fs.mkdirSync(path.dirname(outputPath), {recursive: true});
fs.writeFileSync(outputPath, rendered);
console.log(
  `Event crawl run plan ready: ${plan.summary.candidateSurfaces} ` +
    `candidate surface(s), ${plan.summary.wouldFetch} would fetch, ` +
    `${plan.summary.blocked} blocked.`
);
console.log(`Wrote ${relative(outputPath)}.`);

function parseArgs(argv) {
  const parsed = {
    check: false,
    eventCrawlPlan: null,
    help: false,
    output: null,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--check") parsed.check = true;
    else if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--event-crawl-plan") {
      parsed.eventCrawlPlan = requiredValue(argv, ++index, arg);
    } else if (arg === "--output") {
      parsed.output = requiredValue(argv, ++index, arg);
    } else {
      fail(`Unknown argument: ${arg}`);
    }
  }

  return parsed;
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

function fail(message) {
  console.error(message);
  process.exit(1);
}

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/plan_event_crawl_runs.mjs [options]

Options:
  --check                    Check generated event crawl run plan drift.
  --event-crawl-plan <path>  Read a specific event crawl plan.
  --output <path>            Write or check a specific output path.
`);
}
