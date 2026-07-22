#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

import Ajv2020 from "ajv/dist/2020.js";

import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";

const coveragePath = fromRepo("design/features/feature_coverage.json");
const schemaPath = fromRepo("design/features/feature_coverage.schema.json");
const featureRoot = fromRepo("design/features");
const isCli = process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isCli) {
  runCli();
}

function runCli() {
  const args = process.argv.slice(2);
  const command = args[0] ?? "--check";
  if (command === "--help" || command === "-h" || command === "help") {
    printHelp();
    return;
  }
  if (!["--check", "check", "--summary", "summary"].includes(command)) {
    console.error(`Unknown command: ${command}`);
    printHelp();
    process.exitCode = 64;
    return;
  }

  const coverage = readJson(coveragePath);
  const schema = readJson(schemaPath);
  const ajv = new Ajv2020({allErrors: true, strict: false});
  const validateSchema = ajv.compile(schema);
  const errors = [];
  if (!validateSchema(coverage)) {
    errors.push(...(validateSchema.errors ?? []).map((error) =>
      `${relativeToRepo(coveragePath)}${error.instancePath || "/"}: ${error.message}`
    ));
  }

  const featureContracts = loadFeatureContracts();
  const result = validateFeatureCoverage({
    coverage,
    featureContracts,
    readRegistry: (registryPath) => readJson(fromRepo(registryPath)),
  });
  errors.push(...result.errors);

  if (errors.length > 0) {
    console.error("Feature contract coverage failed:");
    for (const error of errors) console.error(`- ${error}`);
    process.exitCode = 1;
    return;
  }

  printSummary(result.summary);
  console.log("Feature contract coverage is exhaustive and current.");
}

export function validateFeatureCoverage({coverage, featureContracts, readRegistry}) {
  const errors = [];
  const authorities = new Map();
  const inventory = new Map();
  const authorityCounts = new Map();

  for (const authority of coverage.authorities ?? []) {
    if (authorities.has(authority.id)) {
      errors.push(`${authority.id}: duplicate authority.`);
      continue;
    }
    authorities.set(authority.id, authority);
    let registry;
    try {
      registry = readRegistry(authority.registry);
    } catch (error) {
      errors.push(
        `${authority.id}: cannot read ${authority.registry}: ` +
        `${error instanceof Error ? error.message : String(error)}`,
      );
      continue;
    }
    const collection = registry[authority.collection];
    if (!Array.isArray(collection)) {
      errors.push(
        `${authority.id}: ${authority.registry}.${authority.collection} must be an array.`,
      );
      continue;
    }
    const items = collection.filter((item) =>
      authority.filter == null || item?.[authority.filter.field] === authority.filter.value
    );
    authorityCounts.set(authority.id, items.length);
    for (const item of items) {
      const authorityId = item?.[authority.idField];
      if (typeof authorityId !== "string" || authorityId.length === 0) {
        errors.push(
          `${authority.id}: inventory item is missing string field ${authority.idField}.`,
        );
        continue;
      }
      const key = decisionKey(authority.id, authorityId);
      if (inventory.has(key)) errors.push(`${key}: duplicate authority inventory item.`);
      inventory.set(key, {authority, item});
    }
  }

  const decisions = new Map();
  const statusCounts = new Map();
  for (const decision of coverage.decisions ?? []) {
    const key = decisionKey(decision.authority, decision.authorityId);
    if (decisions.has(key)) errors.push(`${key}: duplicate coverage decision.`);
    decisions.set(key, decision);
    if (!authorities.has(decision.authority)) {
      errors.push(`${key}: unknown authority ${decision.authority}.`);
    } else if (!inventory.has(key)) {
      errors.push(`${key}: unknown authority item.`);
    }
    const countKey = `${decision.authority}:${decision.status}`;
    statusCounts.set(countKey, (statusCounts.get(countKey) ?? 0) + 1);
  }

  for (const key of inventory.keys()) {
    if (!decisions.has(key)) errors.push(`${key}: missing feature coverage decision.`);
  }

  const contractsById = new Map();
  for (const contract of featureContracts ?? []) {
    if (contractsById.has(contract.id)) errors.push(`${contract.id}: duplicate feature contract id.`);
    contractsById.set(contract.id, contract);
  }

  const referencedContracts = new Set();
  for (const [key, decision] of decisions) {
    if (decision.status === "contracted") {
      const contract = contractsById.get(decision.featureContract);
      if (contract == null) {
        errors.push(`${key}: unknown feature contract ${decision.featureContract}.`);
        continue;
      }
      referencedContracts.add(decision.featureContract);
      if (!contractAuthorityKeys(contract).has(key)) {
        errors.push(
          `${key}: ${decision.featureContract} does not bind this authority item.`,
        );
      }
    }

    if (decision.status === "grouped") {
      const primaryKey = decisionKey(decision.authority, decision.primaryAuthorityId);
      const primary = decisions.get(primaryKey);
      if (primary == null) {
        errors.push(`${key}: unknown grouped primary ${primaryKey}.`);
      } else if (primaryKey === key) {
        errors.push(`${key}: grouped decision cannot point to itself.`);
      } else if (primary.status === "grouped") {
        errors.push(`${key}: grouped primary ${primaryKey} cannot itself be grouped.`);
      }
    }
  }

  for (const contract of featureContracts ?? []) {
    if (!referencedContracts.has(contract.id)) {
      errors.push(`${contract.id}: feature contract has no contracted coverage decision.`);
    }
  }

  return {
    errors,
    summary: {
      authorityCounts,
      statusCounts,
      totalInventory: inventory.size,
      featureContracts: contractsById.size,
    },
  };
}

function contractAuthorityKeys(contract) {
  const keys = new Set();
  for (const surface of contract.surfaces ?? []) {
    if (typeof surface?.authority?.registry === "string" &&
        typeof surface?.authority?.id === "string") {
      keys.add(decisionKey(surface.authority.registry, surface.authority.id));
    }
  }
  return keys;
}

function loadFeatureContracts() {
  return fs.readdirSync(featureRoot)
    .filter((name) => name.endsWith(".feature.json"))
    .sort()
    .map((name) => readJson(path.join(featureRoot, name)));
}

function decisionKey(authority, authorityId) {
  return `${authority}:${authorityId}`;
}

function printSummary(summary) {
  console.log(
    `Feature coverage: ${summary.totalInventory} authority items; ` +
    `${summary.featureContracts} source contracts.`,
  );
  for (const [authorityId, total] of summary.authorityCounts) {
    const statuses = ["contracted", "grouped", "planned", "excluded"]
      .map((status) => `${status}=${summary.statusCounts.get(`${authorityId}:${status}`) ?? 0}`)
      .join(", ");
    console.log(`- ${authorityId}: ${total} (${statuses})`);
  }
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function printHelp() {
  console.log(`Usage:
  node tool/design/check_feature_coverage.mjs --check
  node tool/design/check_feature_coverage.mjs --summary

Checks that every registered Flutter screen, marketing route, and admin route
has exactly one contracted, grouped, planned, or excluded feature decision.`);
}
