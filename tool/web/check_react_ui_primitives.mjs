#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fromRepo} from "../lib/repo_paths.mjs";

const surfaces = {
  admin: {
    root: "admin/src",
    primitiveOwners: [
      "admin/src/shared/ui/",
    ],
  },
  website: {
    root: "website/src",
    primitiveOwners: [
      "website/src/shared/site/",
      "website/src/shared/ui/",
    ],
  },
  webui: {
    root: "packages/web-ui/src",
    primitiveOwners: ["packages/web-ui/src/"],
  },
};

const checkedExtensions = new Set([".tsx", ".jsx", ".ts", ".js"]);
const jsxExtensions = new Set([".tsx", ".jsx"]);
const nativeInteractiveTags = new Set([
  "a",
  "button",
  "input",
  "select",
  "textarea",
]);
const overrideToken = "react-ui-primitive-allow";
const debtIdPattern = /[A-Z][A-Z0-9]+(?:-[A-Z0-9]+)*-\d{3,}/u;

const args = parseArgs(process.argv.slice(2));
const selectedSurfaces = args.surface === "all" ?
  Object.keys(surfaces) :
  [args.surface];

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
  console.error("React UI primitive violations:");
  for (const violation of violations) {
    console.error(
      `- ${violation.path}:${violation.line}: native <${violation.tag}> must be rendered through a shared primitive.`
    );
  }
  console.error(
    `\nMove the element into shared primitives, use an existing primitive, or add ` +
      `a temporary ${overrideToken}: <debt-id> comment with a removal plan.`
  );
  process.exit(1);
}

if (args.summary || overrideNotes.length > 0) {
  console.log(
    `React UI primitives ok: ${selectedSurfaces.join(", ")} (${nativeInteractiveTags.size} tag kinds checked).`
  );
  if (overrideNotes.length > 0) {
    console.log(`Temporary overrides: ${overrideNotes.length}`);
    for (const override of overrideNotes) {
      console.log(`- ${override.path}:${override.line}: <${override.tag}>`);
    }
  }
}

function scanFile({filePath, relativePath, surfaceName}) {
  const lines = fs.readFileSync(filePath, "utf8").split(/\r?\n/u);
  const scansJsxTags = jsxExtensions.has(path.extname(filePath));
  for (let index = 0; index < lines.length; index += 1) {
    const line = lines[index];
    if (scansJsxTags) {
      const tagPattern = /<([a-z][a-z0-9-]*)\b/gu;
      for (const match of line.matchAll(tagPattern)) {
        const tag = match[1];
        if (!nativeInteractiveTags.has(tag)) continue;
        if (hasPrimitiveOverride(lines, index)) {
          overrideNotes.push({
            path: relativePath,
            line: index + 1,
            surface: surfaceName,
            tag,
          });
          continue;
        }
        violations.push({
          path: relativePath,
          line: index + 1,
          surface: surfaceName,
          tag,
        });
      }
    }

    const createElementPattern =
      /(?:^|[^\w$.])(?:React\.)?createElement\(\s*["']([a-z][a-z0-9-]*)["']/gu;
    for (const match of line.matchAll(createElementPattern)) {
      const tag = match[1];
      if (!nativeInteractiveTags.has(tag)) continue;
      if (hasPrimitiveOverride(lines, index)) {
        overrideNotes.push({
          path: relativePath,
          line: index + 1,
          surface: surfaceName,
          tag,
        });
        continue;
      }
      violations.push({
        path: relativePath,
        line: index + 1,
        surface: surfaceName,
        tag,
      });
    }
  }
}

function hasPrimitiveOverride(lines, index) {
  const candidates = [lines[index - 1] ?? "", lines[index]];
  return candidates.some((line) => isValidPrimitiveOverride(line));
}

function isValidPrimitiveOverride(line) {
  const tokenIndex = line.indexOf(overrideToken);
  if (tokenIndex === -1) return false;

  const payload = line.slice(tokenIndex + overrideToken.length);
  const match = payload.match(/^\s*:\s*([A-Z][A-Z0-9]+(?:-[A-Z0-9]+)*-\d{3,})\b(.*)$/u);
  if (!match) return false;
  if (!debtIdPattern.test(match[1])) return false;

  // Require a short removal note so overrides stay tied to explicit debt.
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
  const parsed = {surface: "all", summary: false};
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--check") {
      continue;
    }
    if (arg === "--summary") {
      parsed.summary = true;
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

function printHelp() {
  console.log(`Usage: node tool/web/check_react_ui_primitives.mjs [--check] [--surface all|website|admin|webui] [--summary]

Fails when React app/feature code renders native interactive HTML directly
instead of routing controls through shared UI primitives.

Temporary exceptions require an adjacent comment containing:
  ${overrideToken}: <DEBT-ID-001> <removal note>
`);
}
