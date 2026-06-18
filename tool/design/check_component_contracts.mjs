#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fromRepo, repoRoot} from "../lib/repo_paths.mjs";

const registryPath = fromRepo("design/components/catch.components.json");
const tokenPath = fromRepo("design/tokens/catch.tokens.json");

const registry = readJson(registryPath);
const tokens = readJson(tokenPath);
const tokenRefs = collectTokenRefs(tokens);
const failures = [];

validateRoot(registry);
validateComponents(registry.components ?? []);

if (failures.length > 0) {
  console.error("Component contract check failed:");
  for (const failure of failures) console.error(`- ${failure}`);
  process.exit(1);
}

console.log(`Component contract check passed (${registry.components.length} components).`);

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"));
  } catch (error) {
    console.error(`Failed to parse ${path.relative(repoRoot, file)}: ${error.message}`);
    process.exit(1);
  }
}

function collectTokenRefs(document) {
  const refs = new Set();

  function walk(node, parts) {
    if (!node || typeof node !== "object" || Array.isArray(node)) return;
    if (Object.prototype.hasOwnProperty.call(node, "$value") && parts.length > 0) {
      refs.add(parts.join("."));
    }
    for (const [key, value] of Object.entries(node)) {
      if (key.startsWith("$")) continue;
      walk(value, [...parts, key]);
    }
  }

  walk(document, []);
  return refs;
}

function validateRoot(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    failures.push("registry root must be an object");
    return;
  }
  if (value.version !== 1) failures.push("registry.version must be 1");
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value.updated ?? "")) {
    failures.push("registry.updated must be YYYY-MM-DD");
  }
  if (!Array.isArray(value.components) || value.components.length === 0) {
    failures.push("registry.components must be a non-empty array");
  }
}

function validateComponents(components) {
  const ids = new Set();
  const idPattern = /^catch\.[a-z0-9_.-]+$/;
  const validStatuses = new Set(["active", "planned", "deprecated"]);
  const validKinds = new Set(["primitive", "composite", "pattern", "screen-contract"]);
  const validFigmaStatuses = new Set(["unmapped", "mapped", "planned"]);
  const validCodeConnectStatuses = new Set(["planned", "mapped", "not-applicable"]);

  for (const component of components) {
    const label = component?.id ?? "<missing id>";

    if (!idPattern.test(label)) {
      failures.push(`${label}: id must match catch.<name>`);
      continue;
    }
    if (ids.has(label)) failures.push(`${label}: duplicate id`);
    ids.add(label);

    if (!validStatuses.has(component.status)) {
      failures.push(`${label}: invalid status '${component.status}'`);
    }
    if (!validKinds.has(component.kind)) {
      failures.push(`${label}: invalid kind '${component.kind}'`);
    }

    validateDart(component, label);

    const figma = component.design?.figma;
    if (!validFigmaStatuses.has(figma?.status)) {
      failures.push(`${label}: invalid figma status '${figma?.status}'`);
    }
    if (figma?.status === "mapped" && !figma.componentUrl) {
      failures.push(`${label}: mapped figma component requires componentUrl`);
    }

    const codeConnect = component.design?.codeConnect;
    if (!validCodeConnectStatuses.has(codeConnect?.status)) {
      failures.push(`${label}: invalid Code Connect status '${codeConnect?.status}'`);
    }
    if (codeConnect?.status === "mapped" && !codeConnect.template) {
      failures.push(`${label}: mapped Code Connect component requires template`);
    }

    validateContract(component.contract, label);
    validateHandoff(component.handoff, label, ids, components);
  }
}

function validateDart(component, label) {
  const dart = component.dart;
  if (!dart?.file || !dart?.symbol) {
    failures.push(`${label}: dart.file and dart.symbol are required`);
    return;
  }
  const file = fromRepo(dart.file);
  if (!fs.existsSync(file)) {
    failures.push(`${label}: dart.file does not exist: ${dart.file}`);
    return;
  }
  const source = fs.readFileSync(file, "utf8");
  if (!new RegExp(`\\b${escapeRegExp(dart.symbol)}\\b`).test(source)) {
    failures.push(`${label}: dart.symbol '${dart.symbol}' not found in ${dart.file}`);
  }
}

function validateContract(contract, label) {
  if (!contract || typeof contract !== "object") {
    failures.push(`${label}: contract is required`);
    return;
  }
  validateProps(contract.props, label);
  validateUniqueArray(contract.states, `${label}: contract.states`);
  validateUniqueArray(contract.tokens, `${label}: contract.tokens`);
  validateUniqueArray(contract.dartRoles, `${label}: contract.dartRoles`);
  validateUniqueArray(contract.goldens, `${label}: contract.goldens`);

  for (const token of contract.tokens ?? []) {
    if (!tokenRefs.has(token)) {
      failures.push(`${label}: unknown DTCG token reference '${token}'`);
    }
  }
}

function validateProps(props, label) {
  if (!Array.isArray(props)) {
    failures.push(`${label}: contract.props must be an array`);
    return;
  }
  const names = new Set();
  const validTypes = new Set([
    "string",
    "bool",
    "enum",
    "callback",
    "widget",
    "color",
    "number",
    "list",
    "generic-list",
    "object",
  ]);

  for (const prop of props) {
    const propLabel = `${label}.${prop?.name ?? "<missing prop>"}`;
    if (!prop?.name) failures.push(`${propLabel}: prop.name is required`);
    if (names.has(prop.name)) failures.push(`${propLabel}: duplicate prop`);
    names.add(prop.name);
    if (!validTypes.has(prop.type)) failures.push(`${propLabel}: invalid prop type '${prop.type}'`);
    if (typeof prop.required !== "boolean") {
      failures.push(`${propLabel}: prop.required must be boolean`);
    }
    if (prop.type === "enum" && (!Array.isArray(prop.values) || prop.values.length === 0)) {
      failures.push(`${propLabel}: enum prop requires non-empty values`);
    }
  }
}

function validateHandoff(handoff, label, seenIds, components) {
  if (!handoff || typeof handoff !== "object") {
    failures.push(`${label}: handoff is required`);
    return;
  }
  validateUniqueArray(handoff.allowedChildren, `${label}: handoff.allowedChildren`);
  const knownIds = new Set(components.map((component) => component.id));
  for (const child of handoff.allowedChildren ?? []) {
    if (!knownIds.has(child)) {
      failures.push(`${label}: unknown allowed child '${child}'`);
    }
  }
}

function validateUniqueArray(value, label) {
  if (!Array.isArray(value)) {
    failures.push(`${label} must be an array`);
    return;
  }
  const seen = new Set();
  for (const item of value) {
    if (seen.has(item)) failures.push(`${label} contains duplicate '${item}'`);
    seen.add(item);
  }
}

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}
