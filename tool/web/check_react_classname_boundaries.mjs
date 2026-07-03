#!/usr/bin/env node
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {fromRepo} from "../lib/repo_paths.mjs";

const surfaces = {
  admin: {
    root: "admin/src",
    primitiveOwners: ["admin/src/shared/ui/"],
  },
  website: {
    root: "website/src",
    primitiveOwners: ["website/src/shared/site/", "website/src/shared/ui/"],
  },
};

const checkedExtensions = new Set([".tsx", ".jsx"]);
const overrideToken = "react-classname-boundary-allow";
const debtIdPattern = /[A-Z][A-Z0-9]+(?:-[A-Z0-9]+)*-\d{3,}/u;

const args = parseArgs(process.argv.slice(2));

if (args.selfTest) {
  runSelfTest();
  process.exit(0);
}

const selectedSurfaces =
  args.surface === "all" ? Object.keys(surfaces) : [args.surface];
const violations = [];
const overrideNotes = [];

for (const surfaceName of selectedSurfaces) {
  const surface = surfaces[surfaceName];
  const root = fromRepo(surface.root);
  for (const filePath of walk(root)) {
    const relativePath = relativeToRepo(filePath);
    if (isPrimitiveOwner(relativePath, surface.primitiveOwners)) continue;
    scanFile({filePath, relativePath, surfaceName});
  }
}

if (violations.length > 0) {
  console.error("React className boundary violations:");
  for (const violation of violations) {
    console.error(
      `- ${violation.path}:${violation.line}: className belongs in the shared primitive owner for ${violation.surface}.`,
    );
  }
  console.error(
    `\nMove the shell/style decision into shared primitives, or add a temporary ` +
      `${overrideToken}: <debt-id> comment with a removal plan.`,
  );
  process.exit(1);
}

if (args.summary || overrideNotes.length > 0) {
  console.log(
    `React className boundaries ok: ${selectedSurfaces.join(", ")} (${checkedExtensions.size} extension kinds checked).`,
  );
  if (overrideNotes.length > 0) {
    console.log(`Temporary overrides: ${overrideNotes.length}`);
    for (const override of overrideNotes) {
      console.log(`- ${override.path}:${override.line}`);
    }
  }
}

function scanFile({filePath, relativePath, surfaceName}) {
  const lines = fs.readFileSync(filePath, "utf8").split(/\r?\n/u);
  const findings = scanLines({lines, relativePath, surfaceName});
  violations.push(...findings.violations);
  overrideNotes.push(...findings.overrideNotes);
}

function scanLines({lines, relativePath, surfaceName}) {
  const localViolations = [];
  const localOverrideNotes = [];
  for (let index = 0; index < lines.length; index += 1) {
    const line = lines[index];
    if (!/\bclassName\s*=/u.test(line)) continue;
    if (hasBoundaryOverride(lines, index)) {
      localOverrideNotes.push({
        path: relativePath,
        line: index + 1,
        surface: surfaceName,
      });
      continue;
    }
    localViolations.push({
      path: relativePath,
      line: index + 1,
      surface: surfaceName,
    });
  }
  return {violations: localViolations, overrideNotes: localOverrideNotes};
}

function hasBoundaryOverride(lines, index) {
  const candidates = [lines[index - 1] ?? "", lines[index]];
  return candidates.some((line) => isValidBoundaryOverride(line));
}

function isValidBoundaryOverride(line) {
  const tokenIndex = line.indexOf(overrideToken);
  if (tokenIndex === -1) return false;

  const payload = line.slice(tokenIndex + overrideToken.length);
  const match = payload.match(/^\s*:\s*([A-Z][A-Z0-9]+(?:-[A-Z0-9]+)*-\d{3,})\b(.*)$/u);
  if (!match) return false;
  if (!debtIdPattern.test(match[1])) return false;

  return match[2].trim().length >= 8;
}

function isPrimitiveOwner(relativePath, primitiveOwners) {
  return primitiveOwners.some((owner) => relativePath.startsWith(owner));
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
  const parsed = {surface: "all", summary: false, selfTest: false};
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
    if (arg === "--surface") {
      parsed.surface = requiredValue(argv, ++index, arg);
      continue;
    }
    if (arg === "--help" || arg === "-h") {
      printHelp();
      process.exit(0);
    }
    fail(`Unknown argument: ${arg}`);
  }
  if (parsed.surface !== "all" && !surfaces[parsed.surface]) {
    fail(`Unknown surface: ${parsed.surface}`);
  }
  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) fail(`${flag} requires a value.`);
  return value;
}

function fail(message) {
  console.error(message);
  process.exit(64);
}

function runSelfTest() {
  const clean = scanLines({
    lines: ["export function Feature() {", "  return <PanelShell />;", "}"],
    relativePath: "website/src/features/example/Example.tsx",
    surfaceName: "website",
  });
  assert.equal(clean.violations.length, 0);

  const rawClass = scanLines({
    lines: ["export function Feature() {", "  return <div className=\"panel\" />;", "}"],
    relativePath: "website/src/features/example/Example.tsx",
    surfaceName: "website",
  });
  assert.equal(rawClass.violations.length, 1);
  assert.equal(rawClass.violations[0].line, 2);

  const override = scanLines({
    lines: [
      "export function Feature() {",
      "  // react-classname-boundary-allow: WEB-UI-999 remove after shared shell lands",
      "  return <div className=\"panel\" />;",
      "}",
    ],
    relativePath: "website/src/features/example/Example.tsx",
    surfaceName: "website",
  });
  assert.equal(override.violations.length, 0);
  assert.equal(override.overrideNotes.length, 1);

  const invalidOverride = scanLines({
    lines: [
      "export function Feature() {",
      "  // react-classname-boundary-allow: WEB-UI-999",
      "  return <div className=\"panel\" />;",
      "}",
    ],
    relativePath: "website/src/features/example/Example.tsx",
    surfaceName: "website",
  });
  assert.equal(invalidOverride.violations.length, 1);

  const primitiveOwner = isPrimitiveOwner("website/src/shared/ui/primitives.tsx", [
    "website/src/shared/ui/",
  ]);
  assert.equal(primitiveOwner, true);

  const tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), "react-classname-boundary-"));
  fs.rmSync(tmpRoot, {recursive: true, force: true});

  console.log("React className boundary scanner self-test passed.");
}

function printHelp() {
  console.log(`Usage: node tool/web/check_react_classname_boundaries.mjs [--check] [--surface all|website|admin] [--summary] [--self-test]

Fails when React app/feature/story code passes className directly instead of
routing shell and styling decisions through shared UI/site primitive owners.

Temporary exceptions require an adjacent comment containing:
  ${overrideToken}: <DEBT-ID-001> <removal note>
`);
}
