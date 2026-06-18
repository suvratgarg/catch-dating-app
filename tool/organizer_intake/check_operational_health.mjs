#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath, pathToFileURL} from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const defaultHealthPath = path.join(
  scriptDir,
  "generated",
  "organizer_operational_health.json"
);

const priorityRank = {
  p0: 0,
  p1: 1,
  p2: 2,
  p3: 3,
};

const nonBlockingStatuses = new Set(["clear", "idle", "ready"]);

if (isMain()) {
  main();
}

export function checkOrganizerOperationalHealth({
  expectStatus = null,
  health,
  maxHighestPriority = null,
  requireReady = false,
} = {}) {
  const errors = [];
  const warnings = [];
  if (!health || typeof health !== "object") {
    return {
      ok: false,
      errors: ["Operational health payload must be an object."],
      warnings,
      summary: emptySummary(),
      unresolvedWorkstreams: [],
    };
  }

  const summary = health.summary ?? {};
  const workstreams = health.workstreams ?? [];
  if (health.schemaVersion !== 1) {
    errors.push(`Expected schemaVersion 1, got ${health.schemaVersion}.`);
  }
  if (!Array.isArray(workstreams)) {
    errors.push("workstreams must be an array.");
  }
  if (!summary.healthStatus) {
    errors.push("summary.healthStatus is required.");
  }
  if (summary.workstreams !== workstreams.length) {
    errors.push(
      `summary.workstreams ${summary.workstreams} does not match ` +
        `workstreams length ${workstreams.length}.`
    );
  }

  const statusCounts = countBy(workstreams, "status");
  const priorityCounts = countBy(workstreams, "priority");
  compareCountMap({
    actual: statusCounts,
    errors,
    expected: summary.workstreamsByStatus ?? {},
    label: "workstreamsByStatus",
  });
  compareCountMap({
    actual: priorityCounts,
    errors,
    expected: summary.workstreamsByPriority ?? {},
    label: "workstreamsByPriority",
  });

  const highestPriority = highestWorkstreamPriority(workstreams);
  if ((summary.highestPriority ?? null) !== highestPriority) {
    errors.push(
      `summary.highestPriority ${summary.highestPriority ?? "null"} ` +
        `does not match ${highestPriority ?? "null"}.`
    );
  }

  const unresolvedWorkstreams = workstreams
    .filter((workstream) => !nonBlockingStatuses.has(workstream.status))
    .map((workstream) => ({
      id: workstream.id,
      label: workstream.label,
      status: workstream.status,
      priority: workstream.priority,
      blockers: workstream.blockers ?? [],
      nextActions: workstream.nextActions ?? [],
      commands: workstream.commands ?? [],
    }))
    .sort(workstreamComparator);

  for (const workstream of workstreams) {
    validateWorkstream(workstream, errors);
  }

  if (expectStatus && summary.healthStatus !== expectStatus) {
    errors.push(
      `Expected health status ${expectStatus}, got ${summary.healthStatus}.`
    );
  }
  if (requireReady && summary.healthStatus !== "ready") {
    errors.push(
      `Operational health is ${summary.healthStatus}; expected ready.`
    );
  }
  if (maxHighestPriority &&
    priorityRank[highestPriority] < priorityRank[maxHighestPriority]) {
    errors.push(
      `Highest priority ${highestPriority} is above allowed ` +
        `${maxHighestPriority}.`
    );
  }

  if (unresolvedWorkstreams.length > 0) {
    warnings.push(
      `${unresolvedWorkstreams.length} operational workstream(s) are unresolved.`
    );
  }

  return {
    ok: errors.length === 0,
    errors,
    warnings,
    summary: {
      healthStatus: summary.healthStatus ?? null,
      highestPriority,
      workstreams: workstreams.length,
      unresolvedWorkstreams: unresolvedWorkstreams.length,
      actionRequiredWorkstreams:
        summary.actionRequiredWorkstreams ?? 0,
      policyBlockedWorkstreams:
        summary.policyBlockedWorkstreams ?? 0,
      waitingWorkstreams: summary.waitingWorkstreams ?? 0,
      operatorActions: summary.operatorActions ?? 0,
      adminDecisionsRequired:
        summary.adminDecisionsRequired ?? 0,
      policyInputsRequired:
        summary.policyInputsRequired ?? 0,
    },
    unresolvedWorkstreams,
  };
}

function validateWorkstream(workstream, errors) {
  for (const field of ["id", "label", "status", "priority"]) {
    if (!workstream[field]) {
      errors.push(`workstream is missing ${field}: ${JSON.stringify(workstream)}`);
    }
  }
  if (!Array.isArray(workstream.blockers)) {
    errors.push(`${workstream.id}: blockers must be an array.`);
  }
  if (!Array.isArray(workstream.nextActions)) {
    errors.push(`${workstream.id}: nextActions must be an array.`);
  }
  if (!Array.isArray(workstream.commands)) {
    errors.push(`${workstream.id}: commands must be an array.`);
  }
  if (!workstream.metrics || typeof workstream.metrics !== "object" ||
    Array.isArray(workstream.metrics)) {
    errors.push(`${workstream.id}: metrics must be an object.`);
  }
  if (!priorityRank.hasOwnProperty(workstream.priority)) {
    errors.push(`${workstream.id}: unknown priority ${workstream.priority}.`);
  }
}

function compareCountMap({actual, errors, expected, label}) {
  const keys = new Set([...Object.keys(actual), ...Object.keys(expected)]);
  for (const key of [...keys].sort()) {
    if ((actual[key] ?? 0) !== (expected[key] ?? 0)) {
      errors.push(
        `${label}.${key} ${expected[key] ?? 0} does not match ` +
          `${actual[key] ?? 0}.`
      );
    }
  }
}

function countBy(items, field) {
  return Object.fromEntries([...items.reduce((counts, item) => {
    const key = item[field] ?? "unknown";
    counts.set(key, (counts.get(key) ?? 0) + 1);
    return counts;
  }, new Map()).entries()].sort(([left], [right]) =>
    String(left).localeCompare(String(right))));
}

function highestWorkstreamPriority(workstreams) {
  return workstreams
    .map((workstream) => workstream.priority)
    .filter(Boolean)
    .sort((left, right) =>
      (priorityRank[left] ?? 99) - (priorityRank[right] ?? 99))[0] ?? null;
}

function workstreamComparator(left, right) {
  return (priorityRank[left.priority] ?? 99) -
    (priorityRank[right.priority] ?? 99) ||
    left.status.localeCompare(right.status) ||
    left.id.localeCompare(right.id);
}

function emptySummary() {
  return {
    adminDecisionsRequired: 0,
    healthStatus: null,
    highestPriority: null,
    operatorActions: 0,
    policyBlockedWorkstreams: 0,
    policyInputsRequired: 0,
    unresolvedWorkstreams: 0,
    waitingWorkstreams: 0,
    workstreams: 0,
  };
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    printHelp();
    process.exit(0);
  }

  const healthPath = path.resolve(args.health ?? defaultHealthPath);
  const health = readJson(healthPath);
  const result = checkOrganizerOperationalHealth({
    expectStatus: args.expectStatus ?? null,
    health,
    maxHighestPriority: args.maxHighestPriority ?? null,
    requireReady: args.requireReady,
  });

  if (args.format === "json") {
    console.log(JSON.stringify(result, null, 2));
  } else {
    printTextResult({healthPath, result});
  }

  if (!result.ok) process.exit(1);
}

function printTextResult({healthPath, result}) {
  if (!result.ok) {
    console.error("Organizer operational health check failed:");
    for (const error of result.errors) console.error(`- ${error}`);
  }
  console.log(
    `Organizer operational health: ${result.summary.healthStatus} ` +
      `(${result.summary.unresolvedWorkstreams}/${result.summary.workstreams} ` +
      `unresolved, highest ${result.summary.highestPriority ?? "none"}).`
  );
  console.log(`Source: ${relative(healthPath)}`);
  if (result.unresolvedWorkstreams.length > 0) {
    console.log("Unresolved workstreams:");
    for (const workstream of result.unresolvedWorkstreams.slice(0, 12)) {
      console.log(
        `- ${workstream.priority} ${workstream.id}: ` +
          `${workstream.status}`
      );
      if (workstream.nextActions[0]) {
        console.log(`  next: ${workstream.nextActions[0]}`);
      }
      if (workstream.commands[0]) {
        console.log(`  command: ${workstream.commands[0]}`);
      }
    }
  }
}

function readJson(filePath) {
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch (error) {
    console.error(`Unable to read ${relative(filePath)}: ${error.message}`);
    process.exit(1);
  }
}

function parseArgs(argv) {
  const args = {
    check: false,
    expectStatus: null,
    format: "text",
    health: null,
    help: false,
    maxHighestPriority: null,
    requireReady: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--check") {
      args.check = true;
    } else if (arg === "--expect-status") {
      args.expectStatus = requiredValue(argv, index += 1, arg);
    } else if (arg === "--format") {
      args.format = requiredValue(argv, index += 1, arg);
    } else if (arg === "--health") {
      args.health = requiredValue(argv, index += 1, arg);
    } else if (arg === "--max-highest-priority") {
      args.maxHighestPriority = requiredValue(argv, index += 1, arg);
    } else if (arg === "--require-ready") {
      args.requireReady = true;
    } else if (arg === "--help" || arg === "-h") {
      args.help = true;
    } else {
      console.error(`Unknown argument: ${arg}`);
      printHelp();
      process.exit(1);
    }
  }
  if (!["json", "text"].includes(args.format)) {
    console.error("--format must be json or text.");
    process.exit(1);
  }
  if (args.maxHighestPriority &&
    !priorityRank.hasOwnProperty(args.maxHighestPriority)) {
    console.error("--max-highest-priority must be p0, p1, p2, or p3.");
    process.exit(1);
  }
  return args;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value) {
    console.error(`${flag} requires a value.`);
    process.exit(1);
  }
  return value;
}

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/check_operational_health.mjs [options]

Validates the generated organizer operational health rollup.

Options:
  --check                         Validate and print a concise summary.
  --health PATH                   Read a specific health JSON file.
  --expect-status STATUS          Fail unless summary.healthStatus matches.
  --max-highest-priority p0..p3   Fail if unresolved priority is above this.
  --require-ready                 Fail unless summary.healthStatus is ready.
  --format text|json              Output format. Defaults to text.
  --help                          Show this message.
`);
}

function relative(filePath) {
  return path.relative(process.cwd(), filePath) || ".";
}

function isMain() {
  return import.meta.url === pathToFileURL(process.argv[1]).href;
}
