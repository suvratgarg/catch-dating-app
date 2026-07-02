#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";

const args = process.argv.slice(2);
if (args.includes("--help") || args.includes("-h")) {
  printHelp();
  process.exit(0);
}

const shouldJson = args.includes("--json");
const unknownArg = args.find((arg) => arg !== "--json");
if (unknownArg) {
  console.error(`Unknown argument: ${unknownArg}`);
  process.exit(2);
}

const dartFiles = collectDartFiles(fromRepo("lib"));
const findings = [];

for (const file of dartFiles) {
  const source = fs.readFileSync(file, "utf8");
  if (!isBuildMethodMutationPendingCandidate(source)) continue;
  if (hasMutationErrorSurface(source)) continue;

  findings.push({
    path: relativeToRepo(file),
    reason:
      "build method reads mutation pending state but has no mutation error surface",
    pendingLines: pendingLines(source).slice(0, 8),
  });
}

const result = {
  checkedFiles: dartFiles.length,
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
    `Mutation error surface check passed (${dartFiles.length} lib Dart files scanned).`,
  );
}

function collectDartFiles(root) {
  const files = [];
  walk(root, files);
  return files
    .filter((file) => file.endsWith(".dart"))
    .filter((file) => !file.endsWith(".g.dart"))
    .sort((a, b) => a.localeCompare(b));
}

function walk(directory, files) {
  for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
    const absolutePath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      walk(absolutePath, files);
    } else if (entry.isFile()) {
      files.push(absolutePath);
    }
  }
}

function isBuildMethodMutationPendingCandidate(source) {
  return (
    /\bWidget\s+build\s*\(/u.test(source) &&
    /\bref\.(?:watch|read)\s*\(/u.test(source) &&
    /\.isPending\b/u.test(source) &&
    /\b[Mm]utation\b/u.test(source)
  );
}

function hasMutationErrorSurface(source) {
  return [
    /\.hasError\b/u,
    /\bCatchMutationErrorBanner\b/u,
    /\bCatchMutationErrorListener(?:s)?\b/u,
    /\bmutationErrorMessage\s*\(/u,
    /\bshowCatchErrorSnackBar\s*\(/u,
  ].some((pattern) => pattern.test(source));
}

function pendingLines(source) {
  const lines = source.split(/\r?\n/u);
  const matches = [];
  for (const [index, line] of lines.entries()) {
    if (!line.includes(".isPending")) continue;
    matches.push({
      line: index + 1,
      text: line.trim(),
    });
  }
  return matches;
}

function printFindings(result) {
  console.error(
    `Mutation error surface check failed (${result.findings.length} finding(s)).`,
  );
  for (const finding of result.findings) {
    console.error(`- ${finding.path}: ${finding.reason}`);
    for (const pending of finding.pendingLines) {
      console.error(`  L${pending.line}: ${pending.text}`);
    }
  }
}

function printHelp() {
  console.log(`Usage:
  node tool/architecture/check_mutation_error_surfaces.mjs
  node tool/architecture/check_mutation_error_surfaces.mjs --json

Scans production lib/**/*.dart build methods. Any file that reads mutation
isPending state from Riverpod must also include a mutation error surface in the
same file, such as CatchMutationErrorListener, CatchMutationErrorBanner,
mutationErrorMessage, showCatchErrorSnackBar, or a direct hasError branch.`);
}
