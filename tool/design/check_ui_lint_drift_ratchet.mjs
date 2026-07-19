#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

import {fromRepo} from "../lib/repo_paths.mjs";

const isCli = process.argv[1] &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isCli) runCli();

export function checkUiLintDriftRatchet({diagnostics, baseline, pluginSource}) {
  const failures = [];
  const currentCounts = countDiagnostics(diagnostics);
  const maxCounts = baseline?.maxCounts;
  if (!maxCounts || typeof maxCounts !== "object" || Array.isArray(maxCounts)) {
    return {failures: ["baseline.maxCounts must be an object"], currentCounts};
  }

  const pluginCodes = new Set(
    [...pluginSource.matchAll(/LintCode\(\s*['"](catch_[a-z0-9_]+)['"]/gu)].map(
      (match) => match[1],
    ),
  );
  const baselineCodes = new Set(Object.keys(maxCounts));

  for (const code of [...pluginCodes].sort()) {
    if (!baselineCodes.has(code)) {
      failures.push(`${code}: missing from ratchet baseline`);
    }
  }
  for (const code of [...baselineCodes].sort()) {
    if (!pluginCodes.has(code)) {
      failures.push(`${code}: stale baseline code is not declared by the plugin`);
    }
    const maximum = maxCounts[code];
    if (!Number.isInteger(maximum) || maximum < 0) {
      failures.push(`${code}: baseline maximum must be a non-negative integer`);
      continue;
    }
    const current = currentCounts[code] ?? 0;
    if (current > maximum) {
      failures.push(`${code}: ${current} exceeds ratchet maximum ${maximum}`);
    }
  }

  return {failures, currentCounts};
}

export function countDiagnostics(source) {
  const counts = {};
  for (const line of source.split(/\r?\n/u)) {
    if (!line.trim()) continue;
    const fields = line.split("|");
    const code = (fields[2] ?? "").toLowerCase();
    if (!/^catch_[a-z0-9_]+$/u.test(code)) continue;
    counts[code] = (counts[code] ?? 0) + 1;
  }
  return Object.fromEntries(Object.entries(counts).sort(([a], [b]) => a.localeCompare(b)));
}

function runCli() {
  const args = parseArgs(process.argv.slice(2));
  const diagnostics = fs.readFileSync(path.resolve(args.diagnostics), "utf8");
  const baseline = JSON.parse(fs.readFileSync(path.resolve(args.baseline), "utf8"));
  const pluginSource = fs.readFileSync(
    fromRepo("packages/catch_ui_lints/lib/src/catch_ui_rules.dart"),
    "utf8",
  );
  const result = checkUiLintDriftRatchet({diagnostics, baseline, pluginSource});
  if (result.failures.length) {
    console.error("Catch UI lint drift ratchet failed:");
    for (const failure of result.failures) console.error(`- ${failure}`);
    process.exit(1);
  }
  const total = Object.values(result.currentCounts).reduce((sum, count) => sum + count, 0);
  console.log(
    `Catch UI lint drift ratchet passed (${total} findings across ${Object.keys(result.currentCounts).length} non-zero codes).`,
  );
}

function parseArgs(argv) {
  const result = {};
  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === "--diagnostics" || argument === "--baseline") {
      const value = argv[index + 1];
      if (!value) usage(`Missing value for ${argument}`);
      result[argument.slice(2)] = value;
      index += 1;
      continue;
    }
    usage(`Unknown argument: ${argument}`);
  }
  if (!result.diagnostics || !result.baseline) usage("Both paths are required");
  return result;
}

function usage(message) {
  if (message) console.error(message);
  console.error(
    "Usage: node tool/design/check_ui_lint_drift_ratchet.mjs --diagnostics PATH --baseline PATH",
  );
  process.exit(64);
}
