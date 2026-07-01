#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fromRepo} from "../lib/repo_paths.mjs";

const args = parseArgs(process.argv.slice(2));

if (args.help) {
  printHelp();
  process.exit(0);
}

const componentsPath = fromRepo(args.components ?? "design/website/components.json");
const schemaPath = fromRepo("design/website/website.components.schema.json");
const routesPath = fromRepo("design/website/routes.json");

const errors = [];
const warnings = [];

const registry = readJson(componentsPath, "website component registry");
const routeContract = readJson(routesPath, "website route contract");

validateRegistryShape(registry);
validateComponents(registry.components ?? [], routeContract.routes ?? []);

if (errors.length > 0) {
  console.error("Website component registry check failed:");
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

if (args.summary || warnings.length > 0) {
  for (const warning of warnings) console.warn(`Warning: ${warning}`);
  console.log(
    [
      `Website component registry ok: ${registry.components.length} component contract(s).`,
      `Storybook-ready components: ${registry.components.filter((component) => component.storybook?.status === "ready").length}.`,
      `Contract: ${path.relative(fromRepo("."), componentsPath)}`,
    ].join("\n")
  );
}

function validateRegistryShape(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    errors.push("components.json must be a JSON object.");
    return;
  }
  if (value.$schema !== "./website.components.schema.json") {
    errors.push("components.json must reference ./website.components.schema.json.");
  }
  if (!fs.existsSync(schemaPath)) {
    errors.push("missing design/website/website.components.schema.json.");
  }
  if (!Number.isInteger(value.version) || value.version < 1) {
    errors.push("components.json version must be a positive integer.");
  }
  if (value.owner !== "marketing_website") {
    errors.push("components.json owner must be marketing_website.");
  }
  if (!Array.isArray(value.components) || value.components.length === 0) {
    errors.push("components.json must declare at least one component.");
  }
  if (value.coverage?.strategy !== "route-plus-sections") {
    errors.push("components.json coverage.strategy must be route-plus-sections.");
  }
}

function validateComponents(components, routes) {
  const routeIds = new Set(routes.map((route) => route.id).filter(Boolean));
  const focusRouteIds = new Set(registry.coverage?.currentFocus ?? []);
  const componentIds = new Set();
  const readyStorySources = new Map();

  for (const focusRouteId of focusRouteIds) {
    if (!routeIds.has(focusRouteId)) {
      errors.push(`coverage.currentFocus references unknown route id ${focusRouteId}.`);
    }
  }

  for (const component of components) {
    validateComponent(component, {componentIds, routeIds, readyStorySources});
  }

  for (const focusRouteId of focusRouteIds) {
    const hasRouteComponent = components.some(
      (component) => component.kind === "route" && component.routeIds?.includes(focusRouteId)
    );
    if (!hasRouteComponent) {
      errors.push(`coverage.currentFocus route ${focusRouteId} needs a route component entry.`);
    }
  }
}

function validateComponent(component, context) {
  if (!component || typeof component !== "object" || Array.isArray(component)) {
    errors.push("component entries must be objects.");
    return;
  }

  const label = component.id ?? "<missing-id>";
  const allowedKinds = new Set(["route", "section", "flow", "supporting-component"]);
  const allowedStoryStatuses = new Set(["ready", "planned", "route-only", "not-required"]);

  if (!component.id) errors.push("component missing id.");
  if (component.id && context.componentIds.has(component.id)) {
    errors.push(`${label}: duplicate component id.`);
  }
  if (component.id) context.componentIds.add(component.id);
  if (!allowedKinds.has(component.kind)) errors.push(`${label}: invalid kind ${component.kind}.`);
  if (!component.owner) errors.push(`${label}: missing owner.`);
  if (!component.exportName) errors.push(`${label}: missing exportName.`);

  const sourcePath = component.source ? fromRepo(component.source) : null;
  if (!sourcePath || !fs.existsSync(sourcePath)) {
    errors.push(`${label}: source file does not exist: ${component.source}.`);
  } else {
    const source = fs.readFileSync(sourcePath, "utf8");
    if (!sourceExports(source, component.exportName)) {
      errors.push(`${label}: source does not export ${component.exportName}.`);
    }
  }

  if (!Array.isArray(component.routeIds) || component.routeIds.length === 0) {
    errors.push(`${label}: routeIds must list at least one route id.`);
  } else {
    for (const routeId of component.routeIds) {
      if (!context.routeIds.has(routeId)) {
        errors.push(`${label}: unknown route id ${routeId}.`);
      }
    }
  }

  if (!Array.isArray(component.css) || component.css.length === 0) {
    errors.push(`${label}: css must list at least one owned stylesheet.`);
  } else {
    for (const cssPath of component.css) {
      if (!fs.existsSync(fromRepo(cssPath))) {
        errors.push(`${label}: css file does not exist: ${cssPath}.`);
      }
    }
  }

  const storybook = component.storybook;
  if (!storybook || typeof storybook !== "object") {
    errors.push(`${label}: missing storybook coverage object.`);
    return;
  }
  if (!allowedStoryStatuses.has(storybook.status)) {
    errors.push(`${label}: invalid storybook.status ${storybook.status}.`);
  }
  if (!Array.isArray(storybook.states) || storybook.states.length === 0) {
    errors.push(`${label}: storybook.states must list at least one state.`);
  }

  if (storybook.status === "ready") {
    validateReadyStory(label, storybook, component, context.readyStorySources);
  } else if (storybook.story || storybook.exportName) {
    warnings.push(`${label}: storybook story metadata is ignored because status is ${storybook.status}.`);
  }
}

function validateReadyStory(label, storybook, component, readyStorySources) {
  if (!storybook.story) {
    errors.push(`${label}: ready Storybook coverage needs story.`);
    return;
  }
  if (!storybook.exportName) {
    errors.push(`${label}: ready Storybook coverage needs exportName.`);
    return;
  }

  const storyPath = fromRepo(storybook.story);
  if (!fs.existsSync(storyPath)) {
    errors.push(`${label}: Storybook story file does not exist: ${storybook.story}.`);
    return;
  }

  let source = readyStorySources.get(storyPath);
  if (!source) {
    source = fs.readFileSync(storyPath, "utf8");
    readyStorySources.set(storyPath, source);
  }

  const storyExportPattern = new RegExp(`export\\s+const\\s+${escapeRegExp(storybook.exportName)}\\b`, "u");
  if (!storyExportPattern.test(source)) {
    errors.push(`${label}: Storybook file does not export ${storybook.exportName}.`);
  }

  const componentIdPattern = new RegExp(`id:\\s*"${escapeRegExp(component.id)}"`, "u");
  if (!componentIdPattern.test(source)) {
    errors.push(`${label}: Storybook story must declare parameters.catchComponent.id ${component.id}.`);
  }
}

function sourceExports(source, exportName) {
  const escaped = escapeRegExp(exportName);
  return new RegExp(`export\\s+function\\s+${escaped}\\b`, "u").test(source) ||
    new RegExp(`export\\s+const\\s+${escaped}\\b`, "u").test(source) ||
    new RegExp(`export\\s+class\\s+${escaped}\\b`, "u").test(source);
}

function readJson(filePath, label) {
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch (error) {
    throw new Error(`Unable to read ${label} at ${filePath}: ${error.message}`);
  }
}

function parseArgs(argv) {
  const parsed = {components: null, help: false, summary: false};
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--summary") parsed.summary = true;
    else if (arg === "--check") {
      // Default mode; accepted for parity with other repo checkers.
    } else if (arg === "--components") parsed.components = requiredValue(argv, ++index, arg);
    else fail(`Unknown argument: ${arg}`);
  }
  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) fail(`${flag} requires a value.`);
  return value;
}

function escapeRegExp(value) {
  return String(value).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function printHelp() {
  console.log(`Usage: node tool/marketing/check_website_components.mjs [--check] [--summary]

Validates design/website/components.json against marketing website source files,
route ids, CSS ownership, and Storybook component coverage.
`);
}

function fail(message) {
  console.error(message);
  process.exit(64);
}
