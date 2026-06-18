#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {buildExternalEventImportPlan} from
  "./lib/event_import_plan_core.mjs";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, "..", "..");
const generatedQueuePath = path.join(
  scriptDir,
  "generated",
  "external_event_candidate_queue.json"
);
const generatedOutputPath = path.join(
  scriptDir,
  "generated",
  "external_event_import_plan.json"
);

const flags = parseFlags(process.argv.slice(2));

if (flags.help) {
  printHelp();
  process.exit(0);
}

try {
  const queuePath = path.resolve(repoRoot, flags.queue ?? generatedQueuePath);
  const outputPath = path.resolve(repoRoot, flags.output ?? generatedOutputPath);
  const queue = readJson(queuePath);
  const plan = buildExternalEventImportPlan(queue);
  const rendered = `${stableStringify(plan)}\n`;

  if (flags.dryRun) {
    console.log(rendered.trimEnd());
    process.exit(0);
  }

  if (flags.check) {
    if (!fs.existsSync(outputPath)) {
      console.error(`Missing external event import plan: ${relative(outputPath)}`);
      process.exit(1);
    }
    const current = fs.readFileSync(outputPath, "utf8");
    if (current !== rendered) {
      console.error(`External event import plan is stale: ${relative(outputPath)}`);
      console.error(`Run: node tool/organizer_intake/plan_external_event_imports.mjs --output ${relative(outputPath)}`);
      process.exit(1);
    }
    console.log(`External event import plan is current: ${relative(outputPath)}`);
    process.exit(0);
  }

  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, rendered);
  console.log(
    `External event import plan ready: ${plan.summary.candidates} candidate(s), ` +
      `${plan.summary.proposedReadOnlyEvents} proposed read-only event(s), ` +
      `${plan.summary.blocked} blocked, ${plan.summary.writeReady} write-ready.`
  );
  console.log(`Wrote ${relative(outputPath)}.`);
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
}

function parseFlags(argv) {
  const flags = {
    check: false,
    dryRun: false,
    help: false,
    output: null,
    queue: null,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--check") flags.check = true;
    else if (arg === "--dry-run") flags.dryRun = true;
    else if (arg === "--help" || arg === "-h") flags.help = true;
    else if (["--output", "--queue"].includes(arg)) {
      const value = argv[index + 1];
      if (!value || value.startsWith("--")) {
        throw new Error(`${arg} requires a value.`);
      }
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
  node tool/organizer_intake/plan_external_event_imports.mjs [flags]

Flags:
  --queue <file>   External event candidate queue JSON.
  --output <file>  Write or check the import plan at this path.
  --check          Compare output with the generated import plan.
  --dry-run        Print import plan without writing.
`);
}
