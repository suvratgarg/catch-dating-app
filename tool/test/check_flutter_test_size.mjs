#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {fromRepo} from "../lib/repo_paths.mjs";

const baselinePath = "tool/test/flutter_test_size_baseline.json";
const defaultMaxLines = 1200;
const isCliEntrypoint =
  process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isCliEntrypoint) runCli(process.argv.slice(2));

export function checkFlutterTestSizes(rows, baseline) {
  const findings = [];
  const maxLines = Number(baseline.maxLines);
  if (!Number.isInteger(maxLines) || maxLines <= 0) {
    return ["baseline maxLines must be a positive integer"];
  }

  const rowsByPath = new Map(rows.map((row) => [row.path, row]));
  const allowedByPath = new Map();
  for (const entry of baseline.allowedFindings ?? []) {
    if (allowedByPath.has(entry.path)) {
      findings.push(`${entry.path}: duplicate baseline entry`);
      continue;
    }
    allowedByPath.set(entry.path, entry);
  }

  for (const row of rows) {
    const allowed = allowedByPath.get(row.path);
    if (row.lines <= maxLines) {
      if (allowed != null) {
        findings.push(
          `${row.path}: baseline is stale at ${allowed.maxLines}; ` +
            `current ${row.lines} is within ${maxLines}`,
        );
      }
      continue;
    }
    if (allowed == null) {
      findings.push(
        `${row.path}: ${row.lines} lines exceeds ${maxLines} without a baseline entry`,
      );
      continue;
    }
    if (row.lines > allowed.maxLines) {
      findings.push(
        `${row.path}: grew from ${allowed.maxLines} to ${row.lines} lines`,
      );
    } else if (row.lines < allowed.maxLines) {
      findings.push(
        `${row.path}: improved from ${allowed.maxLines} to ${row.lines}; ` +
          "refresh the baseline to lock in the reduction",
      );
    }
  }

  for (const allowed of allowedByPath.values()) {
    if (!rowsByPath.has(allowed.path)) {
      findings.push(`${allowed.path}: baseline entry points to a missing test spec`);
    }
  }
  return findings.sort();
}

export function buildFlutterTestSizeBaseline(
  rows,
  {maxLines = defaultMaxLines} = {},
) {
  return {
    schemaVersion: 1,
    maxLines,
    policy:
      "new_or_split_flutter_test_specs_stay_bounded_existing_debt_cannot_grow",
    allowedFindings: rows
      .filter((row) => row.lines > maxLines)
      .map((row) => ({path: row.path, maxLines: row.lines}))
      .sort((a, b) => a.path.localeCompare(b.path)),
  };
}

export function lineCount(source) {
  if (source.length === 0) return 0;
  const lines = source.split(/\r?\n/u);
  if (lines.at(-1) === "") lines.pop();
  return lines.length;
}

function runCli(argv) {
  const args = parseArgs(argv);
  const rows = discoverFlutterTestSpecs();
  if (args.writeBaseline) {
    const baseline = buildFlutterTestSizeBaseline(rows, {
      maxLines: args.maxLines,
    });
    fs.writeFileSync(
      fromRepo(baselinePath),
      `${JSON.stringify(baseline, null, 2)}\n`,
    );
    console.log(
      `Wrote ${baselinePath}: ${baseline.allowedFindings.length} ` +
        `oversized spec(s), ${baseline.maxLines}-line ceiling.`,
    );
    return;
  }

  const baseline = JSON.parse(fs.readFileSync(fromRepo(baselinePath), "utf8"));
  const findings = checkFlutterTestSizes(rows, baseline);
  if (findings.length > 0) {
    console.error(
      `Flutter test size check failed (${findings.length} finding(s)):`,
    );
    for (const finding of findings) console.error(`- ${finding}`);
    process.exitCode = 1;
    return;
  }

  const largest = rows.slice().sort((a, b) => b.lines - a.lines)[0];
  console.log(
    `Flutter test size check passed: ${rows.length} specs; ` +
      `${baseline.allowedFindings.length} ratcheted oversized spec(s); ` +
      `largest ${largest.path} at ${largest.lines} lines.`,
  );
}

function discoverFlutterTestSpecs() {
  return ["test", "integration_test"]
    .flatMap((root) => walk(fromRepo(root)))
    .filter(
      (filePath) =>
        filePath.endsWith("_test.dart") || filePath.endsWith("_tests.dart"),
    )
    .map((filePath) => ({
      path: path.relative(fromRepo(), filePath).split(path.sep).join("/"),
      lines: lineCount(fs.readFileSync(filePath, "utf8")),
    }))
    .sort((a, b) => a.path.localeCompare(b.path));
}

function walk(root) {
  const files = [];
  for (const entry of fs.readdirSync(root, {withFileTypes: true})) {
    const absolute = path.join(root, entry.name);
    if (entry.isDirectory()) files.push(...walk(absolute));
    else if (entry.isFile()) files.push(absolute);
  }
  return files;
}

function parseArgs(argv) {
  const args = {
    writeBaseline: false,
    maxLines: defaultMaxLines,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--check") continue;
    if (arg === "--write-baseline") args.writeBaseline = true;
    else if (arg === "--max-lines") {
      args.maxLines = Number(argv[++index]);
    } else if (arg === "--help" || arg === "-h") {
      printHelp();
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  if (!Number.isInteger(args.maxLines) || args.maxLines <= 0) {
    throw new Error("--max-lines must be a positive integer.");
  }
  return args;
}

function printHelp() {
  console.log(`Usage: node tool/test/check_flutter_test_size.mjs [options]

Options:
  --check                 Check the current specs against the baseline
  --write-baseline        Record the current oversized specs
  --max-lines <count>     Ceiling for new/split specs (default: 1200)
`);
}
