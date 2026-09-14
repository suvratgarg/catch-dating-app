#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fromRepo, repoRoot} from "../lib/repo_paths.mjs";
import {collectComponentApi, componentApiProblems} from "./lib/component_api.mjs";
import {productionWidgetRoots} from "./lib/production_widget_roots.mjs";

const knownBad = process.argv.includes("--known-bad");
const registry = readJson("design/components/catch.components.json");
const failures = [];
const componentById = new Map(
  (registry.components ?? []).map((component) => [component.id, component])
);
const allowedSurfaces = new Set(["flutter", "website", "admin", "webui"]);
const symbols = {
  flutter: new Set(productionWidgetRoots.flatMap((root) =>
    [...collectDartSymbols(fromRepo(root))])),
  website: collectTypeScriptExports(fromRepo("website/src/shared/ui")),
  admin: collectTypeScriptExports(fromRepo("admin/src/shared/ui/AdminPrimitives")),
  webui: collectTypeScriptExports(fromRepo("packages/web-ui/src")),
};

validateSemanticDistinction("catch.badge", {
  flutter: "CatchBadge",
  website: "StatusBadge",
  admin: "StatusChip",
  webui: "BadgeControl",
});
validateSemanticDistinction("catch.ui_label", {
  flutter: "CatchSectionHeaderTitle",
  website: "UiLabel",
  admin: "AdminEyebrow",
  webui: "UiLabel",
});

if (knownBad && registry.components?.[0]) {
  registry.components[0].surfaces = {
    ...registry.components[0].surfaces,
    website: "__KnownMissingWebsiteSymbol__",
  };
}

for (const component of registry.components ?? []) {
  const surfaces = component.surfaces;
  if (!surfaces || typeof surfaces !== "object" || Array.isArray(surfaces)) {
    failures.push(`${component.id}: surfaces must be an object`);
    continue;
  }
  for (const [surface, symbol] of Object.entries(surfaces)) {
    if (!allowedSurfaces.has(surface)) {
      failures.push(`${component.id}: unknown surface '${surface}'`);
      continue;
    }
    if (typeof symbol !== "string" || !symbol.trim()) {
      failures.push(`${component.id}: surfaces.${surface} must be a non-empty symbol`);
      continue;
    }
    if (!symbols[surface].has(symbol)) {
      failures.push(`${component.id}: surfaces.${surface} symbol '${symbol}' was not found`);
    }
  }
}

validateReverseRegistry("website", "design/website/components.json");
validateReverseRegistry("admin", "design/admin/components.json");
if (fs.existsSync(fromRepo("design/web-ui/components.json"))) {
  validateReverseRegistry("webui", "design/web-ui/components.json");
}

const apiInventory = collectComponentApi({repoRoot});
if (process.argv.includes("--known-bad-api")) {
  const input = apiInventory.classes?.find((row) => row.name === "CatchField")
    ?.constructors.find((row) => row.name === "input");
  if (!input) failures.push("API probe could not find the production Field.input constructor");
  else input.parameters.push({name: "unreviewedFlag", type: "bool", kind: "value", named: true});
}
const apiProblems = componentApiProblems(apiInventory);
failures.push(...apiProblems.map((problem) =>
  `${problem.file ?? "component API"}:${problem.line ?? 0}: ${problem.message}`));

if (failures.length > 0) {
  console.error("Component lexicon check failed:");
  failures.forEach((failure) => console.error(`- ${failure}`));
  process.exit(1);
}

console.log(
  `Component lexicon check passed (${componentById.size} contracts; ` +
  `${countLinks(registry.components ?? [])} surface links; 0 shared API grammar violations).`
);

function validateReverseRegistry(surface, relativePath) {
  const document = readJson(relativePath);
  for (const entry of document.components ?? []) {
    if (entry.lexicon !== true) continue;
    if (typeof entry.lexiconId !== "string") {
      failures.push(`${relativePath}:${entry.id}: lexiconId is required when lexicon=true`);
      continue;
    }
    const contract = componentById.get(entry.lexiconId);
    if (!contract) {
      failures.push(`${relativePath}:${entry.id}: unknown lexiconId '${entry.lexiconId}'`);
      continue;
    }
    if (contract.surfaces?.[surface] !== entry.exportName) {
      failures.push(
        `${relativePath}:${entry.id}: ${entry.exportName} does not match ` +
        `${entry.lexiconId}.surfaces.${surface}`
      );
    }
  }
}

function validateSemanticDistinction(componentId, expectedSurfaces) {
  const component = componentById.get(componentId);
  if (!component) {
    failures.push(`${componentId}: required cross-stack semantic family is missing`);
    return;
  }
  for (const [surface, expectedSymbol] of Object.entries(expectedSurfaces)) {
    const actualSymbol = component.surfaces?.[surface];
    if (actualSymbol !== expectedSymbol) {
      failures.push(
        `${componentId}: surfaces.${surface} must be '${expectedSymbol}', received '${actualSymbol ?? "missing"}'`
      );
    }
  }
}

function collectDartSymbols(root) {
  const symbols = new Set();
  for (const file of filesUnder(root, (value) => value.endsWith(".dart"))) {
    const source = fs.readFileSync(file, "utf8");
    for (const match of source.matchAll(/\bclass\s+([A-Za-z_][A-Za-z0-9_]*)/gu)) {
      symbols.add(match[1]);
    }
  }
  return symbols;
}

function collectTypeScriptExports(root) {
  const symbols = new Set();
  if (!fs.existsSync(root)) return symbols;
  for (const file of filesUnder(root, (value) => /\.[cm]?[jt]sx?$/u.test(value))) {
    const source = fs.readFileSync(file, "utf8");
    for (const match of source.matchAll(/\bexport\s+(?:async\s+)?(?:function|class|const)\s+([A-Za-z_$][A-Za-z0-9_$]*)/gu)) {
      symbols.add(match[1]);
    }
  }
  return symbols;
}

function filesUnder(root, accepts) {
  if (!fs.existsSync(root)) return [];
  const output = [];
  const visit = (directory) => {
    for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
      const absolute = path.join(directory, entry.name);
      if (entry.isDirectory()) visit(absolute);
      else if (accepts(absolute)) output.push(absolute);
    }
  };
  visit(root);
  return output;
}

function readJson(relativePath) {
  return JSON.parse(fs.readFileSync(fromRepo(relativePath), "utf8"));
}

function countLinks(components) {
  return components.reduce(
    (total, component) => total + Object.keys(component.surfaces ?? {}).length,
    0
  );
}
