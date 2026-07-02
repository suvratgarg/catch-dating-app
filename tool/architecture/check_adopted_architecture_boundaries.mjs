#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";

const trackerPath = fromRepo("docs/audit_registry/architecture_pattern_adoption.json");

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

const args = process.argv.slice(2);
if (args.includes("--help") || args.includes("-h")) {
  printHelp();
  process.exit(0);
}

const shouldJson = args.includes("--json");
const tracker = readJson(trackerPath);
const adoptedProviderFreePaths = collectAdoptedProviderFreePaths(tracker);
const findings = [];

for (const entry of adoptedProviderFreePaths) {
  const absolutePath = fromRepo(entry.path);
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
  const evidence = [
    ...scanForbiddenImports(source),
    ...scanForbiddenSource(source),
  ];
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

const result = {
  tracker: relativeToRepo(trackerPath),
  checkedProviderFreeAdopters: adoptedProviderFreePaths.length,
  findings,
};

if (shouldJson) {
  console.log(JSON.stringify(result, null, 2));
}

if (findings.length > 0) {
  if (!shouldJson) printFindings(result);
  process.exit(1);
}

if (!shouldJson) {
  console.log(
    `Adopted architecture boundary check passed (${adoptedProviderFreePaths.length} provider-free adopter paths).`,
  );
}

function collectAdoptedProviderFreePaths(tracker) {
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

function scanForbiddenImports(source) {
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

function scanForbiddenSource(source) {
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
    console.error(`Failed to parse ${path.relative(fromRepo(), file)}: ${error.message}`);
    process.exit(1);
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

Reads docs/audit_registry/architecture_pattern_adoption.json and enforces that
aligned adopter Dart files with "providerFree": true do not import or use
Riverpod/provider, routing, data-layer, or repository APIs directly.`);
}
