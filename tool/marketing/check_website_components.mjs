#!/usr/bin/env node
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import {fromRepo} from "../lib/repo_paths.mjs";

const args = parseArgs(process.argv.slice(2));

if (args.help) {
  printHelp();
  process.exit(0);
}

if (args.selfTest) {
  runSelfTest();
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
validateFeatureComponentExports(registry.components ?? []);
validatePublicOrganizerProfileStrength();

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
  const componentById = new Map();
  const readyStorySources = new Map();

  for (const focusRouteId of focusRouteIds) {
    if (!routeIds.has(focusRouteId)) {
      errors.push(`coverage.currentFocus references unknown route id ${focusRouteId}.`);
    }
  }

  for (const component of components) {
    validateComponent(component, {
      componentById,
      componentIds,
      routeIds,
      readyStorySources,
    });
  }

  for (const focusRouteId of focusRouteIds) {
    const hasRouteComponent = components.some(
      (component) => component.kind === "route" && component.routeIds?.includes(focusRouteId)
    );
    if (!hasRouteComponent) {
      errors.push(`coverage.currentFocus route ${focusRouteId} needs a route component entry.`);
    }
  }

  validateStoryDeclarations({componentById, readyStorySources, routeIds});
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
  if (component.id) context.componentById.set(component.id, component);
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

  const coveredStates = storyStatesForComponent(source, component.id);
  for (const state of storybook.states ?? []) {
    if (coveredStates.has(state)) continue;
    errors.push(`${label}: Storybook coverage does not declare state ${state}.`);
  }
}

function validateStoryDeclarations({componentById, readyStorySources, routeIds}) {
  const exportsByComponent = new Map();

  for (const [storyPath, source] of readyStorySources.entries()) {
    const declarations = storyComponentDeclarations(source);
    for (const declaration of declarations) {
      const storyLabel =
        `${path.relative(fromRepo("."), storyPath)}:${declaration.exportName}`;
      const component = componentById.get(declaration.id);
      if (!component) {
        errors.push(`${storyLabel}: declares unknown catchComponent.id ${declaration.id}.`);
        continue;
      }
      if (component.storybook?.status !== "ready") {
        errors.push(
          `${storyLabel}: declares ${declaration.id}, but registry status is ${component.storybook?.status}.`
        );
      }
      if (component.storybook?.story &&
          fromRepo(component.storybook.story) !== storyPath) {
        errors.push(
          `${storyLabel}: declares ${declaration.id}, but registry points to ${component.storybook.story}.`
        );
      }
      if (declaration.routeIds.length === 0) {
        errors.push(`${storyLabel}: catchComponent.routeIds must list at least one route id.`);
      }
      for (const routeId of declaration.routeIds) {
        if (!routeIds.has(routeId)) {
          errors.push(`${storyLabel}: declares unknown route id ${routeId}.`);
        } else if (!component.routeIds.includes(routeId)) {
          errors.push(`${storyLabel}: route ${routeId} is not registered for ${declaration.id}.`);
        }
      }
      if (declaration.states.length === 0) {
        errors.push(`${storyLabel}: catchComponent.states must list at least one state.`);
      }
      for (const state of declaration.states) {
        if (!component.storybook.states.includes(state)) {
          errors.push(`${storyLabel}: state ${state} is not registered for ${declaration.id}.`);
        }
      }

      const exports = exportsByComponent.get(declaration.id) ?? new Set();
      exports.add(declaration.exportName);
      exportsByComponent.set(declaration.id, exports);
    }
  }

  for (const component of componentById.values()) {
    if (component.storybook?.status !== "ready") continue;
    const exports = exportsByComponent.get(component.id) ?? new Set();
    if (!exports.has(component.storybook.exportName)) {
      errors.push(
        `${component.id}: ready Storybook export ${component.storybook.exportName} must declare catchComponent.id ${component.id}.`
      );
    }
  }
}

function validateFeatureComponentExports(components) {
  const registeredExports = new Set(
    components.map((component) =>
      `${normalizeRepoPath(component.source)}::${component.exportName}`
    )
  );
  const featureRoot = fromRepo("website/src/features");
  for (const filePath of walkFiles(featureRoot, ".tsx")) {
    const relativePath = normalizeRepoPath(path.relative(fromRepo("."), filePath));
    const source = fs.readFileSync(filePath, "utf8");
    for (const exported of exportedReactComponents(source)) {
      if (registeredExports.has(`${relativePath}::${exported.name}`)) continue;
      errors.push(
        `${relativePath}: exported feature component ${exported.name} must be registered in design/website/components.json or made private.`
      );
    }
  }
}

function sourceExports(source, exportName) {
  const escaped = escapeRegExp(exportName);
  return new RegExp(`export\\s+function\\s+${escaped}\\b`, "u").test(source) ||
    new RegExp(`export\\s+const\\s+${escaped}\\b`, "u").test(source) ||
    new RegExp(`export\\s+class\\s+${escaped}\\b`, "u").test(source);
}

function exportedReactComponents(source) {
  const components = [];
  const pattern =
    /\bexport\s+(?:default\s+)?function\s+([A-Z][A-Za-z0-9_]*)\b|\bexport\s+const\s+([A-Z][A-Za-z0-9_]*)\b/gu;
  for (const match of source.matchAll(pattern)) {
    components.push({
      name: match[1] ?? match[2],
      index: match.index ?? 0,
    });
  }
  return components;
}

function walkFiles(directory, extension) {
  const files = [];
  if (!fs.existsSync(directory)) return files;
  for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
    const fullPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      files.push(...walkFiles(fullPath, extension));
      continue;
    }
    if (entry.name.endsWith(extension)) files.push(fullPath);
  }
  return files;
}

function validatePublicOrganizerProfileStrength() {
  const organizerRoot = fromRepo("website/src/features/organizers");
  for (const filePath of walkFiles(organizerRoot, ".tsx")) {
    const source = fs.readFileSync(filePath, "utf8");
    if (!containsProfileStrengthComponent(source)) continue;
    errors.push(
      `${normalizeRepoPath(path.relative(fromRepo("."), filePath))}: ` +
        "public organizer UI must not render the internal ProfileStrength heuristic."
    );
  }
}

function containsProfileStrengthComponent(source) {
  return /\bProfileStrength\b/u.test(source);
}

function normalizeRepoPath(value) {
  return String(value ?? "").split(path.sep).join("/");
}

function storyStatesForComponent(source, componentId) {
  const states = new Set();
  for (const declaration of storyComponentDeclarations(source)) {
    if (declaration.id !== componentId) continue;
    for (const state of declaration.states) states.add(state);
  }
  return states;
}

function storyComponentDeclarations(source) {
  const declarations = [];
  const constants = stringArrayConstants(source);
  const exportPattern = /^export\s+const\s+([A-Za-z0-9_]+)\b/gmu;
  const matches = [...source.matchAll(exportPattern)];

  for (let index = 0; index < matches.length; index += 1) {
    const match = matches[index];
    const exportName = match[1];
    const start = match.index ?? 0;
    const end = matches[index + 1]?.index ?? source.length;
    const block = source.slice(start, end);
    if (!block.includes("catchComponent")) continue;

    const catchComponentIndex = block.indexOf("catchComponent");
    const catchComponentBlock = block.slice(catchComponentIndex);
    const id = firstStringProperty(catchComponentBlock, "id");
    if (!id) continue;

    declarations.push({
      exportName,
      id,
      routeIds: stringArrayProperty(catchComponentBlock, "routeIds", constants),
      states: stringArrayProperty(catchComponentBlock, "states", constants),
    });
  }

  return declarations;
}

function stringArrayConstants(source) {
  const constants = new Map();
  const constPattern =
    /const\s+([A-Za-z0-9_]+)\s*=\s*\[([\s\S]*?)\]\s*(?:as\s+const)?\s*;/gu;
  for (const match of source.matchAll(constPattern)) {
    constants.set(match[1], stringValues(match[2]));
  }
  return constants;
}

function firstStringProperty(source, propertyName) {
  const pattern = new RegExp(`${escapeRegExp(propertyName)}:\\s*"([^"]+)"`, "u");
  return source.match(pattern)?.[1] ?? null;
}

function stringArrayProperty(source, propertyName, constants) {
  const inlinePattern = new RegExp(
    `${escapeRegExp(propertyName)}:\\s*\\[([\\s\\S]*?)\\]`,
    "u"
  );
  const inline = source.match(inlinePattern);
  if (inline) return stringValues(inline[1]);

  const referencePattern = new RegExp(
    `${escapeRegExp(propertyName)}:\\s*([A-Za-z0-9_]+)`,
    "u"
  );
  const reference = source.match(referencePattern)?.[1] ?? null;
  return reference ? constants.get(reference) ?? [] : [];
}

function stringValues(source) {
  return [...source.matchAll(/"([^"]+)"/gu)].map((match) => match[1]);
}

function readJson(filePath, label) {
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch (error) {
    throw new Error(`Unable to read ${label} at ${filePath}: ${error.message}`);
  }
}

function parseArgs(argv) {
  const parsed = {components: null, help: false, selfTest: false, summary: false};
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--self-test") parsed.selfTest = true;
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
  console.log(`Usage: node tool/marketing/check_website_components.mjs [--check] [--summary] [--self-test]

Validates design/website/components.json against marketing website source files,
route ids, CSS ownership, and Storybook component coverage.
`);
}

function runSelfTest() {
  const source = `
const listingRouteIds = ["organizer_listing_canonical", "organizer_listing_legacy"];

export const ListingFacts = {
  parameters: {
    catchComponent: {
      id: "listing_facts_section",
      routeIds: listingRouteIds,
      states: ["claimable-unclaimed"],
    },
  },
};

export const ClaimUrlState = {
  parameters: {
    catchComponent: {
      id: "claim_url_state_section",
      routeIds: ["claim", "claim_lookup"],
      states: ["already-claimed", "pending-claim"],
    },
  },
};
`;
  const declarations = storyComponentDeclarations(source);
  assert.deepEqual(declarations, [
    {
      exportName: "ListingFacts",
      id: "listing_facts_section",
      routeIds: ["organizer_listing_canonical", "organizer_listing_legacy"],
      states: ["claimable-unclaimed"],
    },
    {
      exportName: "ClaimUrlState",
      id: "claim_url_state_section",
      routeIds: ["claim", "claim_lookup"],
      states: ["already-claimed", "pending-claim"],
    },
  ]);
  assert.deepEqual(
    exportedReactComponents(`
export function RegisteredSection() {
  return null;
}

export const RegisteredCard = () => null;
export function useNotAComponent() {}
function PrivateComponent() {
  return null;
}
`).map((component) => component.name),
    ["RegisteredSection", "RegisteredCard"]
  );
  assert.equal(
    containsProfileStrengthComponent(
      'import {ProfileStrength} from "./OrganizerIdentity";\n<ProfileStrength value={92} />'
    ),
    true
  );
  assert.equal(
    containsProfileStrengthComponent("const score = listingProfileStrength(listing);"),
    false
  );
  console.log("Website component checker self-test passed.");
}

function fail(message) {
  console.error(message);
  process.exit(64);
}
