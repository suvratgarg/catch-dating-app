#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath, pathToFileURL} from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const defaultCoveragePath = path.join(
  scriptDir,
  "generated",
  "organizer_pending_work_coverage.json"
);

if (isMain()) {
  main();
}

export function checkOrganizerPendingWorkCoverage(coverage) {
  const errors = [];
  const warnings = [];
  if (!coverage || typeof coverage !== "object") {
    return {
      ok: false,
      errors: ["Pending work coverage payload must be an object."],
      warnings,
      summary: emptySummary(),
    };
  }

  const entries = Array.isArray(coverage.entries) ? coverage.entries : [];
  const summary = coverage.summary ?? {};
  if (coverage.schemaVersion !== 1) {
    errors.push(`Expected schemaVersion 1, got ${coverage.schemaVersion}.`);
  }
  if (!Array.isArray(coverage.entries)) {
    errors.push("entries must be an array.");
  }
  if (summary.unresolvedWorkstreams !== entries.length) {
    errors.push(
      `summary.unresolvedWorkstreams ${summary.unresolvedWorkstreams} ` +
        `does not match entries length ${entries.length}.`
    );
  }

  const coveredByInput = entries.filter((entry) =>
    entry.coverageStatus === "covered_by_input_request").length;
  const coveredByFollowUp = entries.filter((entry) =>
    entry.coverageStatus === "covered_by_follow_up").length;
  const untriaged = entries.filter((entry) =>
    entry.coverageStatus === "untriaged").length;
  if (summary.coveredByInputRequest !== coveredByInput) {
    errors.push(
      `summary.coveredByInputRequest ${summary.coveredByInputRequest} ` +
        `does not match ${coveredByInput}.`
    );
  }
  if (summary.coveredByFollowUp !== coveredByFollowUp) {
    errors.push(
      `summary.coveredByFollowUp ${summary.coveredByFollowUp} ` +
        `does not match ${coveredByFollowUp}.`
    );
  }
  if (summary.coveredWorkstreams !== coveredByInput + coveredByFollowUp) {
    errors.push(
      `summary.coveredWorkstreams ${summary.coveredWorkstreams} does not ` +
        `match ${coveredByInput + coveredByFollowUp}.`
    );
  }
  if (summary.untriagedWorkstreams !== untriaged) {
    errors.push(
      `summary.untriagedWorkstreams ${summary.untriagedWorkstreams} ` +
        `does not match ${untriaged}.`
    );
  }

  compareCountMap({
    actual: countBy(entries, "coverageStatus"),
    errors,
    expected: summary.coverageByStatus ?? {},
    label: "coverageByStatus",
  });
  compareCountMap({
    actual: countBy(entries, "status"),
    errors,
    expected: summary.workstreamsByStatus ?? {},
    label: "workstreamsByStatus",
  });
  compareCountMap({
    actual: countBy(entries, "priority"),
    errors,
    expected: summary.workstreamsByPriority ?? {},
    label: "workstreamsByPriority",
  });

  const expectedStatus = entries.length === 0 ?
    "ready" :
    untriaged > 0 ?
      "untriaged_work" :
      "awaiting_required_input";
  if (summary.status !== expectedStatus) {
    errors.push(
      `summary.status ${summary.status} does not match ${expectedStatus}.`
    );
  }

  for (const entry of entries) validateEntry(entry, errors);
  if (entries.length > 0 && untriaged === 0) {
    warnings.push(
      `${entries.length} unresolved workstream(s) are covered and awaiting input.`
    );
  }
  if (untriaged > 0) {
    warnings.push(`${untriaged} unresolved workstream(s) are untriaged.`);
  }

  return {
    ok: errors.length === 0,
    errors,
    warnings,
    summary: {
      status: summary.status ?? "unknown",
      unresolvedWorkstreams: entries.length,
      coveredWorkstreams: coveredByInput + coveredByFollowUp,
      untriagedWorkstreams: untriaged,
      highestPriority: summary.highestPriority ?? null,
    },
  };
}

function validateEntry(entry, errors) {
  for (const field of [
    "coverageId",
    "workstreamId",
    "label",
    "status",
    "priority",
    "coverageStatus",
    "blockerClass",
  ]) {
    if (!entry[field]) {
      errors.push(`${entry.coverageId ?? "entry"} missing ${field}.`);
    }
  }
  if (!Array.isArray(entry.pendingRequestIds)) {
    errors.push(`${entry.coverageId}: pendingRequestIds must be an array.`);
  }
  if (!Array.isArray(entry.followUpIds)) {
    errors.push(`${entry.coverageId}: followUpIds must be an array.`);
  }
  if (!Array.isArray(entry.commands)) {
    errors.push(`${entry.coverageId}: commands must be an array.`);
  }
}

export function renderPendingWorkCoverageMarkdown(coverage) {
  const lines = [
    "# Organizer Pending Work Coverage",
    "",
    `Status: ${coverage.summary?.status ?? "unknown"}; ` +
      `${coverage.summary?.coveredWorkstreams ?? 0}/` +
      `${coverage.summary?.unresolvedWorkstreams ?? 0} covered; ` +
      `${coverage.summary?.untriagedWorkstreams ?? 0} untriaged.`,
    "",
  ];
  for (const entry of coverage.entries ?? []) {
    lines.push(
      `## ${entry.label}`,
      "",
      `Coverage: ${entry.coverageStatus}`,
      `Status: ${entry.status}`,
      `Priority: ${entry.priority}`,
      `Pending requests: ${(entry.pendingRequestIds ?? []).join(", ") || "none"}`,
      `Follow-ups: ${(entry.followUpIds ?? []).join(", ") || "none"}`,
      ""
    );
    if (entry.nextActions?.[0]) {
      lines.push(`Next: ${entry.nextActions[0]}`, "");
    }
    if (entry.commands?.[0]) {
      lines.push(`Command: \`${entry.commands[0]}\``, "");
    }
  }
  return `${lines.join("\n")}\n`;
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    printHelp();
    process.exit(0);
  }

  const coveragePath = path.resolve(args.coverage ?? defaultCoveragePath);
  const coverage = readJson(coveragePath);
  const result = checkOrganizerPendingWorkCoverage(coverage);
  if (args.requireCovered && result.summary.untriagedWorkstreams > 0) {
    result.errors.push(
      `${result.summary.untriagedWorkstreams} unresolved workstream(s) are untriaged.`
    );
    result.ok = false;
  }
  if (args.requireReady && result.summary.unresolvedWorkstreams > 0) {
    result.errors.push(
      `${result.summary.unresolvedWorkstreams} unresolved workstream(s) remain.`
    );
    result.ok = false;
  }
  if (args.check && !result.ok) {
    printErrors(result);
    process.exit(1);
  }

  if (args.format === "json") {
    console.log(JSON.stringify(args.check ? result : coverage, null, 2));
  } else if (args.format === "markdown") {
    console.log(renderPendingWorkCoverageMarkdown(coverage));
  } else {
    printText({coveragePath, result});
  }
  if (!result.ok) process.exit(1);
}

function printText({coveragePath, result}) {
  console.log(
    `Organizer pending work coverage: ${result.summary.status} ` +
      `(${result.summary.coveredWorkstreams}/` +
      `${result.summary.unresolvedWorkstreams} covered, ` +
      `${result.summary.untriagedWorkstreams} untriaged).`
  );
  console.log(`Source: ${relative(coveragePath)}`);
  if (result.warnings.length > 0) {
    for (const warning of result.warnings) console.log(`- ${warning}`);
  }
}

function printErrors(result) {
  console.error("Organizer pending work coverage check failed:");
  for (const error of result.errors) console.error(`- ${error}`);
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
    coverage: null,
    format: "text",
    help: false,
    requireCovered: false,
    requireReady: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--check") {
      args.check = true;
    } else if (arg === "--coverage") {
      args.coverage = requiredValue(argv, index += 1, arg);
    } else if (arg === "--format") {
      args.format = requiredValue(argv, index += 1, arg);
    } else if (arg === "--require-covered") {
      args.requireCovered = true;
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
  if (!["json", "markdown", "text"].includes(args.format)) {
    console.error("--format must be json, markdown, or text.");
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

function emptySummary() {
  return {
    coveredWorkstreams: 0,
    highestPriority: null,
    status: "unknown",
    unresolvedWorkstreams: 0,
    untriagedWorkstreams: 0,
  };
}

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/pending_work_coverage.mjs [options]

Validates or renders organizer unresolved-work coverage.

Options:
  --check              Validate the generated coverage artifact.
  --coverage PATH      Read a specific coverage JSON file.
  --format text|json|markdown
                       Output format. Defaults to text.
  --require-covered    Fail if any unresolved workstream is untriaged.
  --require-ready      Fail if any unresolved workstream remains.
  --help               Show this message.
`);
}

function relative(filePath) {
  return path.relative(process.cwd(), filePath) || ".";
}

function isMain() {
  return import.meta.url === pathToFileURL(process.argv[1]).href;
}
