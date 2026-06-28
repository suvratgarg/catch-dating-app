#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import Ajv2020 from "ajv/dist/2020.js";
import {fromRepo, repoRoot} from "../lib/repo_paths.mjs";

const registryPath = fromRepo("docs/audit_registry/widget_classification.json");
const schemaPath = fromRepo("docs/audit_registry/widget_classification.schema.json");
const contractsPath = fromRepo("design/components/catch.components.json");
const widgetbookPath = fromRepo("widgetbook/lib/main.directories.g.dart");
const failures = [];

const registry = readJson(registryPath);
const schema = readJson(schemaPath);
const contracts = readJson(contractsPath).components ?? [];
const contractEntries = collectContractEntries(contracts);
const contractsById = new Map(contractEntries.map((entry) => [entry.id, entry]));
const contractsBySymbol = new Map(contractEntries.map((entry) => [entry.symbol, entry]));
const widgetbookNames = readWidgetbookNames();
const sourceDeclarations = collectSourceDeclarations();
const registryKeys = new Set();

validateSchema(registry);
validateRoot(registry);
validateEntries(registry.widgets ?? []);
validateStaleness(registry.widgets ?? []);

if (failures.length > 0) {
  console.error("Widget classification check failed:");
  for (const failure of failures) console.error(`- ${failure}`);
  process.exit(1);
}

const reviewCount = (registry.widgets ?? []).filter((widget) =>
  String(widget.decision ?? "").startsWith("review-"),
).length;
const privateWidgetCount = (registry.widgets ?? []).filter(
  (widget) => widget.visibility === "private" && widget.classKind === "widget",
).length;
console.log(
  `Widget classification check passed (${registry.widgets.length} entries, ${reviewCount} review items, ${privateWidgetCount} private widget classes flagged).`,
);

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"));
  } catch (error) {
    console.error(`Failed to parse ${path.relative(repoRoot, file)}: ${error.message}`);
    process.exit(1);
  }
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
  if (!Array.isArray(value.widgets)) failures.push("registry.widgets must be an array");
  if (!String(value.sourceOfTruth?.privateHelperPolicy ?? "").includes("not an allowed destination")) {
    failures.push("sourceOfTruth.privateHelperPolicy must explicitly ban private-helper destinations");
  }
}

function validateSchema(value) {
  const ajv = new Ajv2020({allErrors: true, strict: false});
  const validate = ajv.compile(schema);
  if (validate(value)) return;

  for (const error of validate.errors ?? []) {
    const location = error.instancePath || "/";
    failures.push(`schema ${location}: ${error.message}`);
  }
}

function validateEntries(widgets) {
  const validRoles = new Set([
    "atom",
    "composition",
    "pattern",
    "feature-adapter",
    "screen",
    "widget-state",
  ]);
  const validRemediations = new Set([
    "keepPublicCataloged",
    "mergeIntoCanonical",
    "promoteToCanonicalContract",
    "promoteToPublicCatalog",
    "inlineDelete",
    "moveStateToController",
    "routeThroughScreenState",
  ]);
  const forbiddenPattern = /private[-_ ]?helper|convert.*private|demote.*private/iu;

  for (const widget of widgets) {
    const label = `${widget.file}:${widget.name}`;
    const key = `${widget.file}|${widget.name}|${widget.baseClass}`;
    if (registryKeys.has(key)) failures.push(`${label}: duplicate registry entry`);
    registryKeys.add(key);

    if (!validRoles.has(widget.role)) failures.push(`${label}: invalid role '${widget.role}'`);
    if (forbiddenPattern.test(JSON.stringify(widget))) {
      failures.push(`${label}: private-helper remediation wording is forbidden`);
    }
    for (const option of widget.remediationOptions ?? []) {
      if (!validRemediations.has(option)) {
        failures.push(`${label}: invalid remediation option '${option}'`);
      }
    }
    if (widget.classKind === "widget-state" && widget.role !== "widget-state") {
      failures.push(`${label}: widget-state class must use widget-state role`);
    }
    if (widget.classKind === "widget-state" && widget.visibility !== "private") {
      failures.push(`${label}: widget-state classes must remain private`);
    }
    if (widget.classKind === "widget-state" && widget.publicApi) {
      failures.push(`${label}: widget-state classes cannot be publicApi=true`);
    }
    if (widget.classKind === "widget" && widget.role === "widget-state") {
      failures.push(`${label}: widget class cannot use widget-state role`);
    }
    if (widget.visibility === "private" && widget.classKind === "widget") {
      if (widget.decision !== "review-promote-or-inline") {
        failures.push(`${label}: private widget classes must be review-promote-or-inline`);
      }
      for (const required of ["promoteToPublicCatalog", "mergeIntoCanonical", "inlineDelete"]) {
        if (!(widget.remediationOptions ?? []).includes(required)) {
          failures.push(`${label}: private widget remediation must include ${required}`);
        }
      }
    }
    if (widget.visibility === "private" && widget.publicApi) {
      failures.push(`${label}: private classes cannot be publicApi=true`);
    }
    if (widget.contractId !== null) {
      const contract = contractsById.get(widget.contractId);
      if (!contract) failures.push(`${label}: unknown contractId '${widget.contractId}'`);
      if (contract && contractsBySymbol.get(widget.name)?.id !== widget.contractId) {
        failures.push(`${label}: contractId does not match contract dart symbol`);
      }
      if (contract && widget.canonicalFamily !== contract.parentId) {
        failures.push(`${label}: canonicalFamily must equal contract parent ${contract.parentId}`);
      }
      if (widget.catalogStatus !== "contracted") {
        failures.push(`${label}: contractId entries must use catalogStatus=contracted`);
      }
      if (contract?.primary && !widgetbookNames.has(widget.name)) {
        failures.push(`${label}: contracted widget must have a Widgetbook listing`);
      }
    }
  }
}

function collectContractEntries(components) {
  const entries = [];
  for (const component of components) {
    entries.push({
      id: component.id,
      parentId: component.id,
      symbol: component.dart?.symbol,
      primary: true,
    });
    for (const member of component.contract?.members ?? []) {
      entries.push({
        id: member.id,
        parentId: component.id,
        symbol: member.symbol,
        primary: false,
      });
    }
  }
  return entries;
}

function validateStaleness(widgets) {
  const currentKeys = new Set(
    sourceDeclarations.map((entry) => `${entry.file}|${entry.name}|${entry.baseClass}`),
  );
  for (const entry of sourceDeclarations) {
    const key = `${entry.file}|${entry.name}|${entry.baseClass}`;
    if (!registryKeys.has(key)) failures.push(`${entry.file}:${entry.name}: missing classification`);
  }
  for (const widget of widgets) {
    const key = `${widget.file}|${widget.name}|${widget.baseClass}`;
    if (!currentKeys.has(key)) failures.push(`${widget.file}:${widget.name}: stale classification`);
  }
}

function readWidgetbookNames() {
  if (!fs.existsSync(widgetbookPath)) return new Set();
  const source = fs.readFileSync(widgetbookPath, "utf8");
  return new Set(
    [...source.matchAll(/WidgetbookComponent\(\s*name: '([^']+)'/gu)].map(
      (match) => match[1],
    ),
  );
}

function collectSourceDeclarations() {
  const rows = [];
  for (const file of listDartFiles(fromRepo("lib"))) {
    const source = fs.readFileSync(file, "utf8");
    const relativeFile = path.relative(repoRoot, file);
    const regex =
      /class\s+([A-Za-z_][A-Za-z0-9_]*)\s+extends\s+(?:[A-Za-z_][A-Za-z0-9_]*\.)?((?:StatelessWidget|StatefulWidget|ConsumerWidget|ConsumerStatefulWidget|HookWidget|HookConsumerWidget)|(?:State|ConsumerState)<[^>{}]+>)/gu;
    for (const match of source.matchAll(regex)) {
      rows.push({
        file: relativeFile,
        name: match[1],
        baseClass: match[2],
      });
    }
  }
  return rows;
}

function listDartFiles(root) {
  const results = [];
  for (const entry of fs.readdirSync(root, {withFileTypes: true})) {
    const fullPath = path.join(root, entry.name);
    if (entry.isDirectory()) {
      results.push(...listDartFiles(fullPath));
    } else if (entry.isFile() && entry.name.endsWith(".dart")) {
      results.push(fullPath);
    }
  }
  return results;
}
