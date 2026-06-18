#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, "..", "..");
const generatedQueuePath = path.join(
  scriptDir,
  "generated",
  "external_event_location_resolution_queue.json"
);
const resolutionsRoot = path.join(scriptDir, "event_location_resolutions");

const command = process.argv[2] ?? "help";
const args = process.argv.slice(3);

if (command === "help" || command === "--help" || command === "-h") {
  printHelp();
} else if (command === "list") {
  listQueue(args);
} else if (command === "draft") {
  draftResolution(args);
} else {
  console.error(`Unknown organizer event location command: ${command}`);
  printHelp();
  process.exit(64);
}

function listQueue(rawArgs = []) {
  const flags = parseFlags(rawArgs);
  const queue = loadQueue(flags.queue);
  console.log(
    `External event location queue: ${queue.summary.candidates} candidate(s), ` +
      `${queue.summary.tasks} task(s), ` +
      `${queue.summary.missingExactCoordinates} missing coordinate(s).`
  );
  for (const task of queue.tasks) {
    console.log(
      [
        task.candidateId.padEnd(52),
        task.entityId.padEnd(18),
        task.countryCode.padEnd(8),
        task.resolutionState,
        task.resolutionQuery || "missing query",
      ].join("  ")
    );
  }
}

function draftResolution(rawArgs) {
  const candidateId = rawArgs[0];
  if (!candidateId || candidateId.startsWith("--")) {
    console.error(
      "Usage: node tool/organizer_intake/event_location_resolution.mjs " +
        "draft <candidateId> [flags]"
    );
    process.exit(64);
  }

  const flags = parseFlags(rawArgs.slice(1));
  const reviewer = requiredFlag(flags, "reviewer");
  const date = requiredFlag(flags, "date");
  const note = requiredFlag(flags, "note");
  const name = requiredFlag(flags, "name");
  const latitude = numericFlag(flags, "latitude", -90, 90);
  const longitude = numericFlag(flags, "longitude", -180, 180);
  const dryRun = Boolean(flags["dry-run"]);
  const confirmChecklist = Boolean(flags["confirm-location-checklist"]);

  if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
    failFlag("date", "must be YYYY-MM-DD");
  }
  if (!confirmChecklist) {
    failFlag(
      "confirm-location-checklist",
      "is required before storing reviewed event coordinates"
    );
  }

  const queue = loadQueue(flags.queue);
  const task = queue.tasks.find((entry) =>
    entry.candidateId === candidateId || entry.taskId === candidateId
  );
  if (!task) {
    console.error(`No event location task found for ${candidateId}.`);
    console.error("Run node tool/organizer_intake/plan_event_location_resolution.mjs first if inputs changed.");
    process.exit(1);
  }
  if (existingResolutionFiles(task.candidateId).length > 0) {
    console.error(`A location resolution already exists for ${task.candidateId}:`);
    for (const file of existingResolutionFiles(task.candidateId)) {
      console.error(`- ${relative(file)}`);
    }
    process.exit(1);
  }

  const locationResolutionBatchId = [
    date,
    task.entityId,
    "location",
    "resolved",
  ].join("-");
  const outputPath = path.join(
    resolutionsRoot,
    `${locationResolutionBatchId}.json`
  );
  const payload = {
    schemaVersion: 1,
    locationResolutionBatchId,
    resolvedAt: date,
    reviewer,
    resolutions: [
      {
        candidateId: task.candidateId,
        checklist: completeChecklist(),
        location: {
          address: nullableFlag(flags, "address") ??
            task.sourceLocation.address,
          latitude,
          longitude,
          name,
          notes: nullableFlag(flags, "notes"),
          placeId: nullableFlag(flags, "place-id") ??
            task.sourceLocation.placeId,
        },
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

  fs.mkdirSync(resolutionsRoot, {recursive: true});
  if (fs.existsSync(outputPath)) {
    console.error(`Resolution file already exists: ${relative(outputPath)}`);
    process.exit(1);
  }
  fs.writeFileSync(outputPath, rendered);
  console.log(`Wrote ${relative(outputPath)}.`);
  console.log("Run: node tool/organizer_intake/ingest_event_sources.mjs");
  console.log("Run: node tool/organizer_intake/plan_external_event_imports.mjs");
}

function loadQueue(queuePath) {
  const targetPath = queuePath ?
    path.resolve(repoRoot, queuePath) :
    generatedQueuePath;
  if (!fs.existsSync(targetPath)) {
    console.error(`Missing event location queue: ${relative(targetPath)}`);
    console.error("Run: node tool/organizer_intake/plan_event_location_resolution.mjs");
    process.exit(1);
  }
  return JSON.parse(fs.readFileSync(targetPath, "utf8"));
}

function existingResolutionFiles(candidateId) {
  if (!fs.existsSync(resolutionsRoot)) return [];
  const files = fs
    .readdirSync(resolutionsRoot)
    .filter((file) => file.endsWith(".json"))
    .map((file) => path.join(resolutionsRoot, file));
  return files.filter((file) => {
    const decision = JSON.parse(fs.readFileSync(file, "utf8"));
    return (decision.resolutions ?? []).some((entry) =>
      entry.candidateId === candidateId
    );
  });
}

function completeChecklist() {
  return {
    coordinatesReviewed: true,
    importSafetyReviewed: true,
    placeIdentityReviewed: true,
    sourceLocationReviewed: true,
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
    if (["confirm-location-checklist", "dry-run"].includes(key)) {
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

function nullableFlag(flags, name) {
  const value = flags[name];
  if (typeof value !== "string") return null;
  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}

function numericFlag(flags, name, min, max) {
  const raw = requiredFlag(flags, name);
  const value = Number(raw);
  if (!Number.isFinite(value) || value < min || value > max) {
    failFlag(name, `must be a number between ${min} and ${max}`);
  }
  return value;
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
  console.log(`Usage: node tool/organizer_intake/event_location_resolution.mjs <command>

Commands:
  list
    Print the generated external event location resolution queue.

  draft <candidateId> --name <name> --latitude <number> --longitude <number>
      --reviewer <name> --date <YYYY-MM-DD> --note <text> [--queue <path>]
      [--address <text>] [--place-id <id>] [--notes <text>]
      --confirm-location-checklist [--dry-run]

Examples:
  node tool/organizer_intake/event_location_resolution.mjs list
  node tool/organizer_intake/event_location_resolution.mjs draft \\
    2026-06-17-afterfly-luma-events:pxgmph3b \\
    --name "Nehru Stadium" \\
    --address "Nehru Stadium, Indore, Madhya Pradesh" \\
    --place-id "ChIJ-afterfly-indore" \\
    --latitude 22.7196 \\
    --longitude 75.8577 \\
    --reviewer "admin@example.com" \\
    --date 2026-06-17 \\
    --note "Manual location QA complete." \\
    --confirm-location-checklist
`);
}
