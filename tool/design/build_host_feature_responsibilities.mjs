#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

import Ajv2020 from "ajv/dist/2020.js";

import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";

const sourcePath = fromRepo(
  "design/features/host_feature_responsibilities.json",
);
const schemaPath = fromRepo(
  "design/features/host_feature_responsibilities.schema.json",
);
const shellManifestPath = fromRepo(
  "design/source_packs/host-v2/host-coverage-manifest.json",
);
const routeContractPath = fromRepo("lib/routing/route_contract.dart");
const featureContractRoot = fromRepo("design/features");
const expectedFeatureIds = ["today", "events", "audience", "inbox", "organizer"];
const generatedNotice =
  "<!-- GENERATED FROM design/features/host_feature_responsibilities.json. DO NOT EDIT. -->";
const isCli = process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

export class HostFeatureResponsibilityError extends Error {
  constructor(errors) {
    super(errors.join("\n"));
    this.name = "HostFeatureResponsibilityError";
    this.errors = errors;
  }
}

if (isCli) {
  runCli().catch((error) => {
    if (error instanceof HostFeatureResponsibilityError) {
      console.error("Host feature responsibility generation failed:");
      for (const message of error.errors) console.error(`- ${message}`);
    } else {
      console.error(error instanceof Error ? error.stack : String(error));
    }
    process.exitCode = 1;
  });
}

async function runCli() {
  const args = process.argv.slice(2);
  const checkOnly = args.includes("--check");
  const summaryOnly = args.includes("--summary");
  const unknown = args.filter((arg) => arg !== "--check" && arg !== "--summary");
  if (unknown.length > 0 || (checkOnly && summaryOnly)) {
    if (unknown.length > 0) console.error(`Unknown argument: ${unknown[0]}`);
    if (checkOnly && summaryOnly) {
      console.error("Use only one of --check or --summary.");
    }
    printHelp();
    process.exitCode = 64;
    return;
  }

  const contract = readJson(sourcePath);
  const schema = readJson(schemaPath);
  const validate = new Ajv2020({allErrors: true, strict: false}).compile(schema);
  if (!validate(contract)) {
    throw new HostFeatureResponsibilityError(
      (validate.errors ?? []).map(
        (error) =>
          `host_feature_responsibilities.json${error.instancePath || "/"}: ${error.message}`,
      ),
    );
  }

  const resolved = validateAndResolveHostFeatureResponsibilities({
    contract,
    shellManifest: readJson(shellManifestPath),
    routes: parseDartRoutes(fs.readFileSync(routeContractPath, "utf8")),
    featureContracts: loadFeatureContracts(),
    pathExists: (repoPath) => fs.existsSync(fromRepo(repoPath)),
    readText: (repoPath) => fs.readFileSync(fromRepo(repoPath), "utf8"),
  });
  const outputs = resolved.map((feature) => ({
    path: fromRepo(`${feature.targetRoot}/README.md`),
    content: renderHostFeatureReadme({contract, feature}),
  }));

  if (summaryOnly) {
    printSummary(resolved);
    return;
  }

  const stale = findStaleHostFeatureOutputs({
    outputs,
    readCurrent: (outputPath) =>
      fs.existsSync(outputPath) ? fs.readFileSync(outputPath, "utf8") : null,
  });
  if (checkOnly) {
    if (stale.length > 0) {
      console.error("Generated Host feature responsibility docs are stale:");
      for (const outputPath of stale) console.error(`- ${relativeToRepo(outputPath)}`);
      console.error("Run: node tool/design/build_host_feature_responsibilities.mjs");
      process.exitCode = 1;
      return;
    }
    printSummary(resolved);
    console.log("Generated Host feature responsibility docs are current.");
    return;
  }

  for (const output of outputs) {
    fs.mkdirSync(path.dirname(output.path), {recursive: true});
    fs.writeFileSync(output.path, output.content);
  }
  printSummary(resolved);
  console.log(`Generated ${outputs.length} Host feature responsibility docs.`);
}

export function parseDartRoutes(source) {
  const routes = new Map();
  const pattern = /^\s*([A-Za-z][A-Za-z0-9_]*)\(\s*'([^']+)'\s*,\s*AppRouteAudience\.([a-z]+)\s*[,)]/gmu;
  for (const match of source.matchAll(pattern)) {
    routes.set(match[1], {id: match[1], path: match[2], audience: match[3]});
  }
  return routes;
}

export function validateAndResolveHostFeatureResponsibilities({
  contract,
  shellManifest,
  routes,
  featureContracts,
  pathExists,
  readText,
}) {
  const errors = [];
  const declaredIds = (contract.features ?? []).map((feature) => feature.id);
  if (JSON.stringify(declaredIds) !== JSON.stringify(expectedFeatureIds)) {
    errors.push(
      `feature order must be ${expectedFeatureIds.join(", ")}; found ${declaredIds.join(", ")}`,
    );
  }
  const shellRoutes = shellManifest?.primaryRoutes ?? [];
  if (shellRoutes.length !== expectedFeatureIds.length) {
    errors.push(`Host shell manifest must declare five primary routes, found ${shellRoutes.length}.`);
  }

  const ownedRouteIds = new Map();
  const resolved = [];
  for (const [index, feature] of (contract.features ?? []).entries()) {
    const label = `features.${feature.id}`;
    const shellRoute = shellRoutes[index];
    if (shellRoute?.destination !== feature.destination) {
      errors.push(
        `${label}: destination ${feature.destination} does not match shell position ${shellRoute?.destination ?? "missing"}.`,
      );
    }
    if (shellRoute?.routeId !== feature.primaryRouteId) {
      errors.push(
        `${label}: primary route ${feature.primaryRouteId} does not match shell route ${shellRoute?.routeId ?? "missing"}.`,
      );
    }
    if (feature.targetRoot !== `lib/hosts/${feature.id}`) {
      errors.push(`${label}: targetRoot must be lib/hosts/${feature.id}.`);
    }
    if (!feature.ownedRouteIds.includes(feature.primaryRouteId)) {
      errors.push(`${label}: ownedRouteIds must include primaryRouteId ${feature.primaryRouteId}.`);
    }

    const resolvedRoutes = [];
    for (const routeId of feature.ownedRouteIds) {
      const route = resolveRoute({routeId, routes, label, errors});
      if (route != null) resolvedRoutes.push(route);
      const previous = ownedRouteIds.get(routeId);
      if (previous != null) {
        errors.push(`${label}: route ${routeId} is already owned by ${previous}.`);
      } else {
        ownedRouteIds.set(routeId, feature.id);
      }
    }
    const handoffRoutes = feature.handoffRouteIds
      .map((routeId) => resolveRoute({routeId, routes, label, errors}))
      .filter((route) => route != null);
    const primaryRoute = routes.get(feature.primaryRouteId);
    if (primaryRoute != null && shellRoute?.path !== primaryRoute.path) {
      errors.push(
        `${label}: shell path ${shellRoute?.path} does not match route contract ${primaryRoute.path}.`,
      );
    }

    for (const currentRoot of feature.currentRoots) {
      if (!pathExists(currentRoot)) errors.push(`${label}: missing current root ${currentRoot}.`);
    }
    if (
      feature.migrationStatus === "verticalSlice" &&
      !feature.currentRoots.includes(feature.targetRoot)
    ) {
      errors.push(`${label}: verticalSlice must list ${feature.targetRoot} as a current root.`);
    }

    const codeOwners = [];
    const dataContracts = new Set(feature.additionalDataContracts);
    const seenOwnerIds = new Set();
    for (const binding of feature.featureContractBindings) {
      const featureContract = featureContracts.get(binding.contractId);
      if (featureContract == null) {
        errors.push(`${label}: unknown feature contract ${binding.contractId}.`);
        continue;
      }
      const surface = (featureContract.surfaces ?? []).find(
        (candidate) => candidate.id === binding.surfaceId,
      );
      if (surface == null) {
        errors.push(
          `${label}: ${binding.contractId} has no surface ${binding.surfaceId}.`,
        );
        continue;
      }
      const ownersById = new Map(
        (surface.bindings?.actionOwners ?? []).map((owner) => [owner.id, owner]),
      );
      for (const ownerId of binding.actionOwnerIds) {
        const owner = ownersById.get(ownerId);
        if (owner == null) {
          errors.push(
            `${label}: ${binding.contractId}.${binding.surfaceId} has no action owner ${ownerId}.`,
          );
          continue;
        }
        const actionIds = (surface.actions ?? [])
          .filter((action) => action.owner === ownerId)
          .map((action) => action.id);
        addCodeOwner({
          owner: {
            ...owner,
            role: actionIds.length > 0
              ? `Feature-contract actions: ${actionIds.join(", ")}.`
              : `Structural owner from ${binding.contractId}.`,
          },
          label,
          errors,
          codeOwners,
          seenOwnerIds,
          pathExists,
          readText,
        });
      }
      if (binding.includeDataContracts) {
        for (const dataContract of surface.bindings?.dataContracts ?? []) {
          dataContracts.add(dataContract);
        }
      }
    }
    for (const owner of feature.additionalCodeOwners) {
      addCodeOwner({
        owner: {...owner, language: "dart"},
        label,
        errors,
        codeOwners,
        seenOwnerIds,
        pathExists,
        readText,
      });
    }
    for (const dataContract of dataContracts) {
      if (!pathExists(dataContract)) errors.push(`${label}: missing data contract ${dataContract}.`);
    }
    for (const dependency of feature.sharedDependencies) {
      if (!pathExists(dependency.path)) {
        errors.push(`${label}: missing shared dependency ${dependency.path}.`);
      }
    }
    for (const testFile of feature.testFiles) {
      if (!pathExists(testFile)) errors.push(`${label}: missing test file ${testFile}.`);
    }

    resolved.push({
      ...feature,
      label: shellRoute?.label ?? titleCase(feature.id),
      primaryRoute,
      routes: resolvedRoutes,
      handoffRoutes,
      codeOwners,
      dataContracts: [...dataContracts].sort(),
    });
  }

  if (errors.length > 0) throw new HostFeatureResponsibilityError(errors);
  return resolved;
}

function resolveRoute({routeId, routes, label, errors}) {
  const route = routes.get(routeId);
  if (route == null) {
    errors.push(`${label}: unknown route ${routeId}.`);
    return null;
  }
  if (route.audience !== "host") {
    errors.push(`${label}: route ${routeId} is not Host-owned.`);
  }
  return route;
}

function addCodeOwner({
  owner,
  label,
  errors,
  codeOwners,
  seenOwnerIds,
  pathExists,
  readText,
}) {
  if (seenOwnerIds.has(owner.id)) {
    errors.push(`${label}: duplicate code owner ${owner.id}.`);
    return;
  }
  seenOwnerIds.add(owner.id);
  if (!pathExists(owner.file)) {
    errors.push(`${label}: missing code owner path ${owner.file}.`);
    return;
  }
  const source = readText(owner.file);
  const symbolPattern = new RegExp(`\\b${escapeRegExp(owner.symbol)}\\b`, "u");
  if (!symbolPattern.test(source)) {
    errors.push(`${label}: symbol ${owner.symbol} is missing from ${owner.file}.`);
    return;
  }
  codeOwners.push(owner);
}

export function renderHostFeatureReadme({contract, feature}) {
  const lines = [
    generatedNotice,
    "",
    `# Host ${feature.label}`,
    "",
    feature.purpose,
    "",
    "## Ownership",
    "",
    `- Primary route: \`${feature.primaryRoute.id}\` (\`${feature.primaryRoute.path}\`)`,
    `- Target root: \`${feature.targetRoot}\``,
    `- Migration status: ${migrationStatusLabel(feature.migrationStatus)}`,
    `- Responsibility contract updated: ${contract.updated}`,
    "",
    "Current implementation roots:",
    "",
    ...feature.currentRoots.map((repoPath) => `- \`${repoPath}\``),
    "",
    "## This feature owns",
    "",
    ...feature.responsibilities.map((responsibility) => `- ${responsibility}`),
    "",
    "## This feature does not own",
    "",
    ...feature.doesNotOwn.map((exclusion) => `- ${exclusion}`),
    "",
    "## Routes",
    "",
    "Owned routes:",
    "",
    ...feature.routes.map((route) => `- \`${route.id}\` — \`${route.path}\``),
    "",
    "Typed handoffs:",
    "",
    ...feature.handoffRoutes.map((route) => `- \`${route.id}\` — \`${route.path}\``),
    "",
    "## Key code owners",
    "",
    "| Owner | Source | Responsibility |",
    "|---|---|---|",
    ...feature.codeOwners.map(
      (owner) =>
        `| \`${owner.symbol}\` | \`${owner.file}\` | ${escapeTable(owner.role)} |`,
    ),
    "",
    "## Shared dependencies",
    "",
    ...feature.sharedDependencies.map(
      (dependency) => `- \`${dependency.path}\` — ${dependency.reason}`,
    ),
    "",
    "## Data contracts",
    "",
    ...feature.dataContracts.map((repoPath) => `- \`${repoPath}\``),
    "",
    "## Focused tests",
    "",
    ...feature.testFiles.map((repoPath) => `- \`${repoPath}\``),
    "",
    "## Maintenance",
    "",
    "Do not edit this file directly. Update " +
      "`design/features/host_feature_responsibilities.json`, then run:",
    "",
    "```sh",
    "node tool/design/build_host_feature_responsibilities.mjs",
    "node tool/design/build_host_feature_responsibilities.mjs --check",
    "```",
    "",
    "The generator cross-checks the Host shell order, typed route contract, " +
      "feature-contract action owners, Dart symbols, data-contract paths, and focused tests.",
  ];
  return `${lines.join("\n")}\n`;
}

export function findStaleHostFeatureOutputs({outputs, readCurrent}) {
  return outputs
    .filter((output) => readCurrent(output.path) !== output.content)
    .map((output) => output.path);
}

function loadFeatureContracts() {
  const contracts = new Map();
  for (const name of fs.readdirSync(featureContractRoot).sort()) {
    if (!name.endsWith(".feature.json")) continue;
    const featureContract = readJson(path.join(featureContractRoot, name));
    contracts.set(featureContract.id, featureContract);
  }
  return contracts;
}

function readJson(filePath) {
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch (error) {
    throw new Error(`Could not read ${relativeToRepo(filePath)}: ${error.message}`);
  }
}

function migrationStatusLabel(status) {
  return status === "verticalSlice"
    ? "implemented as a destination-owned vertical slice"
    : "target boundary defined; implementation still lives in listed legacy Host roots";
}

function escapeTable(value) {
  return value.replaceAll("|", "\\|").replaceAll("\n", " ");
}

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/gu, "\\$&");
}

function titleCase(value) {
  return `${value[0].toUpperCase()}${value.slice(1)}`;
}

function printSummary(features) {
  console.log(
    `Host feature responsibilities: ${features.map((feature) => feature.label).join(" · ")}`,
  );
  for (const feature of features) {
    console.log(
      `- ${feature.label}: ${feature.routes.length} owned route(s), ` +
        `${feature.codeOwners.length} code owner(s), ${feature.dataContracts.length} data contract(s)`,
    );
  }
}

function printHelp() {
  console.log(`Usage:
  node tool/design/build_host_feature_responsibilities.mjs
  node tool/design/build_host_feature_responsibilities.mjs --check
  node tool/design/build_host_feature_responsibilities.mjs --summary

Validates the five ordered Host destination responsibilities against the shell,
route contract, feature contracts, Dart symbols, data contracts, and tests, then
generates one local README.md in each destination's target feature root.`);
}
