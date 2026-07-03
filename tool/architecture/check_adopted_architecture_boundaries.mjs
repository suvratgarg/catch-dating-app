#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {fromRepo} from "../lib/repo_paths.mjs";

const defaultTrackerPath = fromRepo(
  "docs/audit_registry/architecture_pattern_adoption.json",
);

const forbiddenImports = [
  {
    pattern: /^package:flutter_riverpod(?:\/|$)/u,
    label: "Riverpod",
  },
  {
    pattern: /^package:go_router(?:\/|$)/u,
    label: "go_router",
  },
  {
    pattern: /^package:catch_dating_app\/routing\//u,
    label: "app routing",
  },
  {
    pattern: /^package:catch_dating_app\/[^/]+\/data\//u,
    label: "feature data layer",
  },
  {
    pattern: /^package:catch_dating_app\/[^/]+\/.*repository/u,
    label: "repository API",
  },
];

const forbiddenSourcePatterns = [
  {
    pattern: /\b(?:ConsumerWidget|ConsumerStatefulWidget|WidgetRef|ProviderScope|Ref<|Ref\s+ref)\b/u,
    label: "Riverpod widget/ref API",
  },
  {
    pattern: /\bref\.(?:watch|read|listen|invalidate)\s*\(/u,
    label: "Riverpod ref access",
  },
  {
    pattern: /\b(?:GoRouter|GoRoute)\b|context\.(?:go|push|replace|pop)\s*\(/u,
    label: "route navigation API",
  },
];

const isCliEntrypoint =
  process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isCliEntrypoint) runCli();

export function scanAdoptedArchitectureBoundaries({
  root = fromRepo(),
  tracker = null,
  trackerPath = path.join(
    root,
    "docs/audit_registry/architecture_pattern_adoption.json",
  ),
} = {}) {
  const resolvedTracker = tracker ?? readJson(trackerPath);
  const adoptedProviderFreePaths =
    collectAdoptedProviderFreePaths(resolvedTracker);
  const findings = [];

  for (const entry of adoptedProviderFreePaths) {
    const absolutePath = path.join(root, entry.path);
    if (!fs.existsSync(absolutePath)) {
      findings.push({
        path: entry.path,
        patternId: entry.patternId,
        reason: "tracked aligned provider-free adopter is missing on disk",
        evidence: [],
      });
      continue;
    }

    const source = fs.readFileSync(absolutePath, "utf8");
    const evidence = scanBoundaryFile({source});
    if (evidence.length === 0) continue;
    findings.push({
      path: entry.path,
      patternId: entry.patternId,
      role: entry.role,
      reason:
        "aligned provider-free adopter imports or uses provider, routing, data, or repository APIs",
      evidence,
    });
  }

  return {
    tracker: trackerPath == null ? null : relativeToDisplay(root, trackerPath),
    checkedProviderFreeAdopters: adoptedProviderFreePaths.length,
    findings,
  };
}

export function collectAdoptedProviderFreePaths(tracker) {
  const paths = new Map();
  for (const pattern of tracker.patterns ?? []) {
    for (const adopter of pattern.adopters ?? []) {
      if (adopter.status !== "aligned") continue;
      if (adopter.providerFree !== true) continue;
      if (typeof adopter.path !== "string" || !adopter.path.endsWith(".dart")) {
        continue;
      }
      if (!adopter.path.startsWith("lib/")) continue;
      paths.set(adopter.path, {
        path: adopter.path,
        patternId: pattern.id,
        role: adopter.role ?? "",
      });
    }
  }
  return [...paths.values()].sort((a, b) => a.path.localeCompare(b.path));
}

export function scanBoundaryFile({source}) {
  return [...scanForbiddenImports(source), ...scanForbiddenSource(source)];
}

export function scanForbiddenImports(source) {
  const evidence = [];
  for (const match of source.matchAll(/import\s+'([^']+)';/gu)) {
    const uri = match[1];
    const forbidden = forbiddenImports.find((entry) => entry.pattern.test(uri));
    if (!forbidden) continue;
    evidence.push({
      type: "import",
      label: forbidden.label,
      line: lineForOffset(source, match.index ?? 0),
      text: match[0],
    });
  }
  return evidence;
}

export function scanForbiddenSource(source) {
  const evidence = [];
  const importEnd = lastImportEnd(source);
  const body = source.slice(importEnd);
  for (const forbidden of forbiddenSourcePatterns) {
    const match = forbidden.pattern.exec(body);
    if (!match) continue;
    evidence.push({
      type: "source",
      label: forbidden.label,
      line: lineForOffset(source, importEnd + match.index),
      text: match[0],
    });
  }
  return evidence;
}

function lastImportEnd(source) {
  let end = 0;
  for (const match of source.matchAll(/import\s+'[^']+';\s*/gu)) {
    end = Math.max(end, (match.index ?? 0) + match[0].length);
  }
  return end;
}

function lineForOffset(source, offset) {
  let line = 1;
  for (let index = 0; index < offset; index += 1) {
    if (source.charCodeAt(index) === 10) line += 1;
  }
  return line;
}

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"));
  } catch (error) {
    throw new Error(
      `Failed to parse ${relativeToDisplay(fromRepo(), file)}: ${error.message}`,
    );
  }
}

function printFindings(result) {
  console.error(
    `Adopted architecture boundary check failed (${result.findings.length} finding(s)).`,
  );
  for (const finding of result.findings) {
    console.error(`- ${finding.path} [${finding.patternId}]: ${finding.reason}`);
    for (const evidence of finding.evidence ?? []) {
      console.error(
        `  L${evidence.line} ${evidence.type}/${evidence.label}: ${evidence.text}`,
      );
    }
  }
}

function printHelp() {
  console.log(`Usage:
  node tool/architecture/check_adopted_architecture_boundaries.mjs
  node tool/architecture/check_adopted_architecture_boundaries.mjs --json
  node tool/architecture/check_adopted_architecture_boundaries.mjs --root <repo-root> --tracker <path>

Reads docs/audit_registry/architecture_pattern_adoption.json and enforces that
aligned adopter Dart files with "providerFree": true do not import or use
Riverpod/provider, routing, data-layer, or repository APIs directly.`);
}

function parseArgs(rawArgs) {
  const parsed = {
    help: false,
    json: false,
    root: fromRepo(),
    trackerPath: defaultTrackerPath,
  };

  for (let index = 0; index < rawArgs.length; index += 1) {
    const arg = rawArgs[index];
    if (arg === "--help" || arg === "-h") {
      parsed.help = true;
    } else if (arg === "--json") {
      parsed.json = true;
    } else if (arg === "--root") {
      parsed.root = requireValue(rawArgs, (index += 1), arg);
      if (parsed.trackerPath === defaultTrackerPath) {
        parsed.trackerPath = path.join(
          parsed.root,
          "docs/audit_registry/architecture_pattern_adoption.json",
        );
      }
    } else if (arg === "--tracker") {
      parsed.trackerPath = requireValue(rawArgs, (index += 1), arg);
    } else {
      console.error(`Unknown argument: ${arg}`);
      process.exit(2);
    }
  }

  return parsed;
}

function requireValue(argsList, index, flag) {
  const value = argsList[index];
  if (value == null || value.startsWith("--")) {
    console.error(`Missing value for ${flag}`);
    process.exit(2);
  }
  return path.resolve(value);
}

function relativeToDisplay(root, file) {
  return normalizePath(path.relative(root, file));
}

function normalizePath(filePath) {
  return filePath.split(path.sep).join("/");
}

function runCli() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    printHelp();
    process.exit(0);
  }

  let result;
  try {
    result = scanAdoptedArchitectureBoundaries({
      root: args.root,
      trackerPath: args.trackerPath,
    });
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }

  if (args.json) {
    console.log(JSON.stringify(result, null, 2));
  }

  if (result.findings.length > 0) {
    if (!args.json) printFindings(result);
    process.exit(1);
  }

  if (!args.json) {
    console.log(
      `Adopted architecture boundary check passed (${result.checkedProviderFreeAdopters} provider-free adopter paths).`,
    );
  }
}
