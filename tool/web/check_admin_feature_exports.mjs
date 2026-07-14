#!/usr/bin/env node
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import {fromRepo} from "../lib/repo_paths.mjs";

const args = parseArgs(process.argv.slice(2));
const featureRoot = "admin/src/features";
const checkedExtensions = new Set([".tsx"]);
const overrideToken = "admin-feature-export-allow";
const debtIdPattern = /[A-Z][A-Z0-9]+(?:-[A-Z0-9]+)*-\d{3,}/u;
const allowedComponentNamePattern = /(?:Screen|Workspace)$/u;

if (args.selfTest) {
  runSelfTest();
  process.exit(0);
}

const violations = [];
const overrideNotes = [];

for (const filePath of walk(fromRepo(featureRoot))) {
  const relativePath = relativeToRepo(filePath);
  scanFile({filePath, relativePath});
}

if (violations.length > 0) {
  console.error("Admin feature export violations:");
  for (const violation of violations) {
    console.error(
      `- ${violation.path}:${violation.line}: exported feature component ${violation.name} must be a route/workspace entry component, moved to admin shared UI, or made private.`,
    );
  }
  console.error(
    `\nTemporary exceptions require an adjacent ${overrideToken}: <DEBT-ID-001> <removal note> comment.`,
  );
  process.exit(1);
}

if (args.summary || overrideNotes.length > 0) {
  console.log("Admin feature exports ok.");
  if (overrideNotes.length > 0) {
    console.log(`Temporary overrides: ${overrideNotes.length}`);
    for (const override of overrideNotes) {
      console.log(`- ${override.path}:${override.line}: ${override.name}`);
    }
  }
}

function scanFile({filePath, relativePath}) {
  const lines = fs.readFileSync(filePath, "utf8").split(/\r?\n/u);
  const findings = scanLines({lines, relativePath});
  violations.push(...findings.violations);
  overrideNotes.push(...findings.overrideNotes);
}

function scanLines({lines, relativePath}) {
  const localViolations = [];
  const localOverrideNotes = [];
  for (let index = 0; index < lines.length; index += 1) {
    for (const name of exportedComponentNames(lines[index])) {
      if (allowedComponentNamePattern.test(name)) continue;
      if (hasExportOverride(lines, index)) {
        localOverrideNotes.push({path: relativePath, line: index + 1, name});
        continue;
      }
      localViolations.push({path: relativePath, line: index + 1, name});
    }
  }
  return {violations: localViolations, overrideNotes: localOverrideNotes};
}

function exportedComponentNames(line) {
  const names = [];
  const pattern =
    /\bexport\s+(?:default\s+)?(?:function|class)\s+([A-Z][A-Za-z0-9_]*)\b|\bexport\s+const\s+([A-Z][A-Za-z0-9_]*)\b/gu;
  for (const match of line.matchAll(pattern)) {
    names.push(match[1] ?? match[2]);
  }
  return names;
}

function hasExportOverride(lines, index) {
  const candidates = [lines[index - 1] ?? "", lines[index]];
  return candidates.some((line) => isValidExportOverride(line));
}

function isValidExportOverride(line) {
  const tokenIndex = line.indexOf(overrideToken);
  if (tokenIndex === -1) return false;

  const payload = line.slice(tokenIndex + overrideToken.length);
  const match = payload.match(/^\s*:\s*([A-Z][A-Z0-9]+(?:-[A-Z0-9]+)*-\d{3,})\b(.*)$/u);
  if (!match) return false;
  if (!debtIdPattern.test(match[1])) return false;

  return match[2].trim().length >= 8;
}

function walk(directory) {
  const files = [];
  if (!fs.existsSync(directory)) return files;
  for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
    const fullPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      if (entry.name === "dist" || entry.name === "storybook-static") continue;
      files.push(...walk(fullPath));
      continue;
    }
    if (checkedExtensions.has(path.extname(entry.name))) files.push(fullPath);
  }
  return files;
}

function relativeToRepo(filePath) {
  return path.relative(fromRepo("."), filePath).split(path.sep).join("/");
}

function parseArgs(argv) {
  const parsed = {selfTest: false, summary: false};
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--check") {
      continue;
    }
    if (arg === "--summary") {
      parsed.summary = true;
      continue;
    }
    if (arg === "--self-test") {
      parsed.selfTest = true;
      continue;
    }
    if (arg === "--help" || arg === "-h") {
      printHelp();
      process.exit(0);
    }
    fail(`Unknown argument: ${arg}`);
  }
  return parsed;
}

function fail(message) {
  console.error(message);
  process.exit(64);
}

function runSelfTest() {
  const clean = scanLines({
    lines: [
      "export function OrganizerIntakeScreen() {",
      "  return null;",
      "}",
      "export const EventIntakeWorkspace = () => null;",
    ],
    relativePath: "admin/src/features/intake/organizer/ui/OrganizerIntakeScreen.tsx",
  });
  assert.equal(clean.violations.length, 0);

  const rawPanel = scanLines({
    lines: [
      "export function PublicationBoundaryPanel() {",
      "  return null;",
      "}",
    ],
    relativePath: "admin/src/features/intake/organizer/ui/OrganizerIntakeScreen.tsx",
  });
  assert.equal(rawPanel.violations.length, 1);
  assert.equal(rawPanel.violations[0].name, "PublicationBoundaryPanel");

  const override = scanLines({
    lines: [
      "// admin-feature-export-allow: WEB-UI-999 remove after registry exists",
      "export function PublicationBoundaryPanel() {",
      "  return null;",
      "}",
    ],
    relativePath: "admin/src/features/intake/organizer/ui/OrganizerIntakeScreen.tsx",
  });
  assert.equal(override.violations.length, 0);
  assert.equal(override.overrideNotes.length, 1);

  console.log("Admin feature export scanner self-test passed.");
}

function printHelp() {
  console.log(`Usage: node tool/web/check_admin_feature_exports.mjs [--check] [--summary] [--self-test]

Fails when admin feature UI exports uppercase components that are not route or
workspace entry components. Reusable panels/cards/lists belong in
admin/src/shared/ui/AdminPrimitives/ or should stay private to the file.

Temporary exceptions require an adjacent comment containing:
  ${overrideToken}: <DEBT-ID-001> <removal note>
`);
}
