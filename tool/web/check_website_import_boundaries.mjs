#!/usr/bin/env node
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const repoRoot = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "../.."
);
const websiteSrcRoot = path.join(repoRoot, "website/src");
const websiteContentRoot = path.join(websiteSrcRoot, "content");
const functionsGeneratedRoot = path.join(repoRoot, "functions/src/shared/generated");
const allowedSourceExtensions = new Set([".ts", ".tsx"]);
const args = parseArgs(process.argv.slice(2));

if (args.help) {
  printHelp();
  process.exit(0);
}

if (args.selfTest) {
  runSelfTest();
  process.exit(0);
}

const allowedFeatureImports = new Map([
  ["claims", new Set(["marketing", "organizers"])],
  ["home", new Set(["marketing", "organizers", "waitlist"])],
  ["host", new Set(["marketing"])],
  ["organizers", new Set(["claims", "marketing", "reviews"])],
  ["reviews", new Set(["organizers"])],
]);

function walkSourceFiles(directory) {
  const files = [];
  for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
    const absolutePath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      files.push(...walkSourceFiles(absolutePath));
      continue;
    }
    if (allowedSourceExtensions.has(path.extname(entry.name))) {
      files.push(absolutePath);
    }
  }
  return files;
}

function relativeToWebsiteSource(absolutePath) {
  return path.relative(websiteSrcRoot, absolutePath).split(path.sep).join("/");
}

function isInside(parent, child) {
  const relativePath = path.relative(parent, child);
  return relativePath === "" ||
    (!relativePath.startsWith("..") && !path.isAbsolute(relativePath));
}

function layerFor(relativePath) {
  const parts = relativePath.split("/");
  if (parts[0] === "app") return {name: "app"};
  if (parts[0] === "content") return {name: "content"};
  if (parts[0] === "features") return {name: "feature", feature: parts[1] ?? ""};
  if (parts[0] === "generated") return {name: "generated"};
  if (parts[0] === "shared") return {name: "shared"};
  if (parts[0] === "stories") return {name: "story"};
  if (
    relativePath === "analytics.ts" ||
    relativePath === "firebase.ts" ||
    relativePath === "firebaseConfig.ts"
  ) {
    return {name: "service"};
  }
  if (relativePath === "App.tsx" || relativePath === "main.tsx") {
    return {name: "entry"};
  }
  return {name: "root"};
}

function importSpecifiers(source) {
  const staticImports =
    /\bimport\s+(?:type\s+)?(?:[\s\S]*?\s+from\s+)?["']([^"']+)["']/g;
  const dynamicImports = /\bimport\(\s*["']([^"']+)["']\s*\)/g;
  const specifiers = [];
  for (const match of source.matchAll(staticImports)) {
    specifiers.push(match[1]);
  }
  for (const match of source.matchAll(dynamicImports)) {
    specifiers.push(match[1]);
  }
  return specifiers;
}

function allowedExternalImport(sourceRelativePath, targetAbsolutePath) {
  return (
    sourceRelativePath === "features/organizers/types.ts" ||
    sourceRelativePath === "firebase.ts"
  ) && isInside(functionsGeneratedRoot, targetAbsolutePath);
}

function isAllowedGeneratedImport(sourceRelativePath) {
  return sourceRelativePath === "features/organizers/data.ts";
}

function allowedCrossFeatureImport(sourceLayer, targetLayer) {
  return allowedFeatureImports.get(sourceLayer.feature)?.has(targetLayer.feature) ?? false;
}

function violationFor(sourceRelativePath, sourceLayer, targetLayer) {
  if (sourceLayer.name === "story") return null;

  if (sourceLayer.name === "content") {
    if (targetLayer.name !== "content") {
      return "content modules must remain data-only and may only import other content modules";
    }
    return null;
  }

  if (sourceLayer.name === "shared") {
    if (targetLayer.name === "app" || targetLayer.name === "entry" || targetLayer.name === "feature") {
      return "shared modules must not import app, entry, or feature modules";
    }
    if (targetLayer.name === "generated") {
      return "shared modules must not import generated website projections directly";
    }
    if (targetLayer.name === "content") {
      return "shared UI modules must not own or depend on route-specific marketing content";
    }
    return null;
  }

  if (sourceLayer.name === "feature") {
    if (targetLayer.name === "app" || targetLayer.name === "entry" || targetLayer.name === "root") {
      return "feature modules must not import app-shell, entry, or uncategorized root modules";
    }
    if (targetLayer.name === "generated" && !isAllowedGeneratedImport(sourceRelativePath)) {
      return "generated organizer projections must be read through features/organizers/data.ts";
    }
    if (
      targetLayer.name === "feature" &&
      targetLayer.feature !== sourceLayer.feature &&
      !allowedCrossFeatureImport(sourceLayer, targetLayer)
    ) {
      return `feature '${sourceLayer.feature}' must not import feature '${targetLayer.feature}' without a scanner allowlist`;
    }
    return null;
  }

  if (sourceLayer.name === "app") {
    if (targetLayer.name === "entry" || targetLayer.name === "root") {
      return "app-shell modules must not import entry or uncategorized root modules";
    }
    return null;
  }

  if (sourceLayer.name === "service") {
    if (
      targetLayer.name === "app" ||
      targetLayer.name === "content" ||
      targetLayer.name === "feature" ||
      targetLayer.name === "shared"
    ) {
      return "root service modules must stay independent of app, content, feature, and shared UI modules";
    }
    return null;
  }

  if (sourceLayer.name === "entry") return null;

  if (sourceLayer.name === "root") {
    if (targetLayer.name !== "service") {
      return "uncategorized root modules must not import production app layers";
    }
  }

  return null;
}

const violations = [];
for (const file of walkSourceFiles(websiteSrcRoot)) {
  const sourceRelativePath = relativeToWebsiteSource(file);
  const sourceLayer = layerFor(sourceRelativePath);
  const source = fs.readFileSync(file, "utf8");

  const contentSourceReason = contentSourceViolation(
    sourceRelativePath,
    sourceLayer,
    source
  );
  if (contentSourceReason !== null) {
    violations.push({
      source: sourceRelativePath,
      specifier: "<module source>",
      reason: contentSourceReason,
    });
  }

  for (const specifier of importSpecifiers(source)) {
    if (specifier.startsWith("@catch/web-ui/")) {
      violations.push({
        source: sourceRelativePath,
        specifier,
        reason: "shared web UI must be imported from @catch/web-ui without deep imports",
      });
      continue;
    }
    const aliasedTarget = contentAliasTarget(specifier);
    if (!specifier.startsWith(".") && aliasedTarget === null) continue;

    const targetAbsolutePath = aliasedTarget ?? path.resolve(path.dirname(file), specifier);
    if (!isInside(websiteSrcRoot, targetAbsolutePath)) {
      if (!allowedExternalImport(sourceRelativePath, targetAbsolutePath)) {
        violations.push({
          source: sourceRelativePath,
          specifier,
          reason: "relative import leaves website/src without an explicit allowlist",
        });
      }
      continue;
    }

    const targetLayer = layerFor(relativeToWebsiteSource(resolveModulePath(targetAbsolutePath)));
    const reason = violationFor(sourceRelativePath, sourceLayer, targetLayer);
    if (reason !== null) {
      violations.push({source: sourceRelativePath, specifier, reason});
    }
  }
}

function contentSourceViolation(sourceRelativePath, sourceLayer, source) {
  if (sourceLayer.name !== "content") return null;
  if (sourceRelativePath.endsWith(".tsx")) {
    return "content modules must not own JSX; render content in feature or shared UI adapters";
  }
  if (/\bimport\.meta\.env\b/.test(source)) {
    return "content modules must not read import.meta.env; feature adapters own environment values";
  }
  return null;
}

if (violations.length > 0) {
  console.error("Website import boundary violations:");
  for (const violation of violations) {
    console.error(
      `- ${violation.source} imports ${violation.specifier}: ${violation.reason}`
    );
  }
  process.exitCode = 1;
} else {
  console.log("Website import boundaries passed.");
}

function resolveModulePath(absolutePath) {
  if (path.extname(absolutePath)) return absolutePath;
  for (const extension of [".ts", ".tsx", ".json"]) {
    const candidate = `${absolutePath}${extension}`;
    if (fs.existsSync(candidate)) return candidate;
  }
  for (const extension of [".ts", ".tsx"]) {
    const candidate = path.join(absolutePath, `index${extension}`);
    if (fs.existsSync(candidate)) return candidate;
  }
  return absolutePath;
}

function contentAliasTarget(specifier) {
  if (specifier === "@content") return websiteContentRoot;
  if (!specifier.startsWith("@content/")) return null;
  return path.join(websiteContentRoot, specifier.slice("@content/".length));
}

function parseArgs(argv) {
  const parsed = {help: false, selfTest: false};
  for (const arg of argv) {
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--self-test") parsed.selfTest = true;
    else if (arg === "--check" || arg === "--summary") {
      // Default scan mode; accepted for consistency with repo checkers.
    } else {
      console.error(`Unknown argument: ${arg}`);
      process.exit(64);
    }
  }
  return parsed;
}

function printHelp() {
  console.log(`Usage: node tool/web/check_website_import_boundaries.mjs [--check] [--self-test]

Checks marketing website import boundaries, including content imports, JSX
ownership, and environment-access boundaries.
`);
}

function runSelfTest() {
  assert.deepEqual(layerFor("content/meta.json"), {name: "content"});
  assert.equal(
    violationFor(
      "content/home.ts",
      {name: "content"},
      {name: "feature", feature: "home"}
    ),
    "content modules must remain data-only and may only import other content modules"
  );
  assert.equal(
    violationFor("content/home.ts", {name: "content"}, {name: "content"}),
    null
  );
  assert.equal(
    violationFor(
      "features/home/HomePage.tsx",
      {name: "feature", feature: "home"},
      {name: "content"}
    ),
    null
  );
  assert.equal(
    violationFor("shared/ui/Card.tsx", {name: "shared"}, {name: "content"}),
    "shared UI modules must not own or depend on route-specific marketing content"
  );
  assert.equal(
    contentAliasTarget("@content/markets"),
    path.join(websiteContentRoot, "markets")
  );
  assert.equal(contentAliasTarget("react"), null);
  assert.equal(
    contentSourceViolation(
      "content/site.ts",
      {name: "content"},
      'export const href = import.meta.env.VITE_APP_STORE_URL;'
    ),
    "content modules must not read import.meta.env; feature adapters own environment values"
  );
  assert.equal(
    contentSourceViolation(
      "content/HomeCopy.tsx",
      {name: "content"},
      "export const copy = <span>Copy</span>;"
    ),
    "content modules must not own JSX; render content in feature or shared UI adapters"
  );
  assert.equal(
    contentSourceViolation(
      "content/metaContract.ts",
      {name: "content"},
      "export function validate() { return true; }"
    ),
    null
  );
  console.log("Website import boundary checker self-test passed.");
}
