#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fromRepo, relativeToRepo, repoRoot} from "../lib/repo_paths.mjs";

const matrixPath = fromRepo("docs/design_parity/state_matrix.json");
const routeInventoryPath = fromRepo("tool/ui_capture/route_inventory.json");
const catalogPath = fromRepo("test/ui_captures/catalog/screen_capture_catalog.dart");
const componentRegistryPath = fromRepo("design/components/catch.components.json");
const screenContractsPath = fromRepo("design/screens/catch.screens.json");

const args = process.argv.slice(2);
const command = args[0] ?? "--help";

if (command === "--help" || command === "-h" || command === "help") {
  printHelp();
} else if (command === "--check" || command === "check") {
  checkMatrix({summary: args.includes("--summary")});
} else if (command === "--summary" || command === "summary") {
  checkMatrix({summary: true});
} else {
  console.error(`Unknown command: ${command}`);
  printHelp();
  process.exit(64);
}

function checkMatrix({summary = false} = {}) {
  const matrix = readJson(matrixPath);
  const routeInventory = readJson(routeInventoryPath);
  const componentRegistry = readJson(componentRegistryPath);
  const screenContracts = readJson(screenContractsPath);
  const captureCatalog = parseCaptureCatalog(fs.readFileSync(catalogPath, "utf8"));

  const errors = validateMatrix({
    matrix,
    routeInventory,
    componentRegistry,
    screenContracts,
    captureCatalog,
  });

  if (summary || errors.length === 0) {
    printSummary(matrix);
  }

  if (errors.length > 0) {
    console.error("Design parity matrix check failed:");
    for (const error of errors) console.error(`- ${error}`);
    process.exit(1);
  }
}

function validateMatrix({
  matrix,
  routeInventory,
  componentRegistry,
  screenContracts,
  captureCatalog,
}) {
  const errors = [];
  const routeIds = new Set((routeInventory.routes ?? []).map((route) => route.id));
  const captureIds = new Set(captureCatalog.map((entry) => entry.id));
  const componentIds = new Set((componentRegistry.components ?? []).map((entry) => entry.id));
  const screenContractIds = new Set((screenContracts.screens ?? []).map((screen) => screen.id));
  const screenContractStateIds = new Map(
    (screenContracts.screens ?? []).map((screen) => [
      screen.id,
      new Set((screen.states ?? []).map((state) => state.id)),
    ])
  );
  const screenContractCaptureIds = new Map(
    (screenContracts.screens ?? []).map((screen) => [
      screen.id,
      new Set([
        ...(screen.captures ?? []).map((capture) => capture.id),
        ...(screen.states ?? []).flatMap((state) => state.captureIds ?? []),
      ]),
    ])
  );
  const routeToScreenContractId = new Map();
  for (const screen of screenContracts.screens ?? []) {
    for (const route of screen.routes ?? []) {
      routeToScreenContractId.set(route.id, screen.id);
    }
  }
  const featureIds = new Set();
  const screenIds = new Set();
  const matrixScreenContractIds = new Set();
  const matrixStateIdsByContractId = new Map();
  const matrixCaptureIdsByContractId = new Map();
  const allowedPriorities = new Set(["P1", "P2", "P3", "P4"]);
  const allowedFeatureStatuses = new Set(["planned", "in_progress", "ready", "blocked"]);
  const allowedStateStatuses = new Set([
    "planned",
    "implemented",
    "captured",
    "tested",
    "ready",
    "blocked",
  ]);
  const allowedDesignKinds = new Set(["repo", "external", "figma", "generated"]);
  const allowedDesignStatuses = new Set(["available", "needs_export", "planned", "blocked"]);
  const allowedGapStatuses = new Set(["open", "in_progress", "blocked", "closed"]);

  if (matrix.version !== 1) errors.push("version must be 1.");
  if (!isDate(matrix.updated)) errors.push("updated must be YYYY-MM-DD.");
  if (!Array.isArray(matrix.features) || matrix.features.length === 0) {
    errors.push("features must be a non-empty array.");
    return errors;
  }

  for (const feature of matrix.features) {
    const featureLabel = feature?.id ?? "<missing feature id>";
    if (!/^[a-z0-9_]+$/u.test(featureLabel)) {
      errors.push(`${featureLabel}: feature id must be snake_case.`);
      continue;
    }
    if (featureIds.has(featureLabel)) errors.push(`${featureLabel}: duplicate feature id.`);
    featureIds.add(featureLabel);
    if (!feature.name) errors.push(`${featureLabel}: name is required.`);
    if (!allowedPriorities.has(feature.priority)) {
      errors.push(`${featureLabel}: priority must be P1, P2, P3, or P4.`);
    }
    if (!allowedFeatureStatuses.has(feature.status)) {
      errors.push(`${featureLabel}: invalid feature status ${feature.status}.`);
    }
    if (!Array.isArray(feature.screens) || feature.screens.length === 0) {
      errors.push(`${featureLabel}: screens must be a non-empty array.`);
      continue;
    }

    validateGaps(errors, `${featureLabel}.lintCandidates`, feature.lintCandidates, allowedGapStatuses);
    validateGaps(errors, `${featureLabel}.previewPlan`, feature.previewPlan, allowedGapStatuses);

    for (const screen of feature.screens) {
      validateScreen(errors, {
        featureLabel,
        screen,
        screenIds,
        matrixScreenContractIds,
        screenContractIds,
        routeToScreenContractId,
        matrixStateIdsByContractId,
        matrixCaptureIdsByContractId,
        routeIds,
        captureIds,
        componentIds,
        allowedStateStatuses,
        allowedDesignKinds,
        allowedDesignStatuses,
        allowedGapStatuses,
      });
    }
  }

  for (const screenId of screenContractIds) {
    if (!matrixScreenContractIds.has(screenId)) {
      errors.push(
        `${screenId}: screen contract is missing from docs/design_parity/state_matrix.json.`
      );
    }
  }
  validateScreenContractStateParity(errors, {
    screenContractStateIds,
    matrixStateIdsByContractId,
  });
  validateScreenContractCaptureParity(errors, {
    screenContractCaptureIds,
    matrixCaptureIdsByContractId,
  });

  return errors;
}

function validateScreen(
  errors,
  {
    featureLabel,
    screen,
    screenIds,
    matrixScreenContractIds,
    screenContractIds,
    routeToScreenContractId,
    matrixStateIdsByContractId,
    matrixCaptureIdsByContractId,
    routeIds,
    captureIds,
    componentIds,
    allowedStateStatuses,
    allowedDesignKinds,
    allowedDesignStatuses,
    allowedGapStatuses,
  }
) {
  const screenLabel = `${featureLabel}.${screen?.id ?? "<missing screen id>"}`;
  if (!/^[a-z0-9_.-]+$/u.test(screen?.id ?? "")) {
    errors.push(`${screenLabel}: screen id must be lowercase dot/dash/underscore.`);
  }
  if (screenIds.has(screen?.id)) errors.push(`${screenLabel}: duplicate screen id.`);
  screenIds.add(screen?.id);

  if (!routeIds.has(screen?.routeId)) {
    errors.push(`${screenLabel}: unknown routeId ${screen?.routeId}.`);
  }
  const explicitScreenContractId = `screen.${screen?.id}`;
  const boundScreenContractId = routeToScreenContractId.get(screen?.routeId);
  let screenContractId = null;
  if (screenContractIds.has(explicitScreenContractId)) {
    screenContractId = explicitScreenContractId;
    matrixScreenContractIds.add(screenContractId);
  } else if (boundScreenContractId) {
    screenContractId = boundScreenContractId;
    matrixScreenContractIds.add(screenContractId);
  }

  validatePaths(errors, `${screenLabel}.implementationPaths`, screen.implementationPaths);
  validateIds(errors, `${screenLabel}.captureIds`, screen.captureIds, captureIds);
  const screenCaptureIds = new Set(screen.captureIds ?? []);
  validateIds(errors, `${screenLabel}.componentIds`, screen.componentIds, componentIds);
  validateDesignRefs(errors, screenLabel, screen.designRefs, allowedDesignKinds, allowedDesignStatuses);
  validateGaps(errors, `${screenLabel}.gaps`, screen.gaps, allowedGapStatuses);

  if (!Array.isArray(screen.states) || screen.states.length === 0) {
    errors.push(`${screenLabel}: states must be a non-empty array.`);
    return;
  }

  const stateIds = new Set();
  for (const state of screen.states) {
    const stateLabel = `${screenLabel}.${state?.id ?? "<missing state id>"}`;
    if (!/^[a-z0-9_.-]+$/u.test(state?.id ?? "")) {
      errors.push(`${stateLabel}: state id must be lowercase dot/dash/underscore.`);
    }
    if (stateIds.has(state?.id)) errors.push(`${stateLabel}: duplicate state id.`);
    stateIds.add(state?.id);
    if (!state.kind) errors.push(`${stateLabel}: kind is required.`);
    if (!allowedStateStatuses.has(state.status)) {
      errors.push(`${stateLabel}: invalid state status ${state.status}.`);
    }
    validateIds(errors, `${stateLabel}.captureIds`, state.captureIds, captureIds);
    for (const captureId of state.captureIds ?? []) {
      if (!screenCaptureIds.has(captureId)) {
        errors.push(`${stateLabel}.captureIds: ${captureId} is missing from ${screenLabel}.captureIds.`);
      }
    }
    validatePaths(errors, `${stateLabel}.tests`, state.tests);
    if ((state.status === "captured" || state.status === "ready") && !state.captureIds?.length) {
      errors.push(`${stateLabel}: ${state.status} states must list captureIds.`);
    }
    const staleCaptureTextField = staleCapturedStateTextField(state);
    if ((state.status === "captured" || state.status === "ready") && staleCaptureTextField) {
      errors.push(
        `${stateLabel}.${staleCaptureTextField}: ${state.status} state text says capture coverage is missing.`
      );
    }
  }
  if (screenContractId) {
    const aggregateStateIds =
      matrixStateIdsByContractId.get(screenContractId) ?? new Set();
    for (const stateId of stateIds) aggregateStateIds.add(stateId);
    matrixStateIdsByContractId.set(screenContractId, aggregateStateIds);

    const aggregateCaptureIds =
      matrixCaptureIdsByContractId.get(screenContractId) ?? new Set();
    for (const captureId of screenCaptureIds) aggregateCaptureIds.add(captureId);
    matrixCaptureIdsByContractId.set(screenContractId, aggregateCaptureIds);
  }
}

function staleCapturedStateTextField(state) {
  const staleCapturedStateTextPattern =
    /\b(?:no\b[^.]*\bcaptures?\b[^.]*\bexists?\s+yet|captures?\b[^.]*\bnot\s+yet\s+registered)\b/iu;
  const fields = ["notes", "nextAction", "source"];
  for (const field of fields) {
    if (typeof state?.[field] !== "string") continue;
    if (staleCapturedStateTextPattern.test(state[field])) return field;
  }
  return null;
}

function validateScreenContractStateParity(
  errors,
  {screenContractStateIds, matrixStateIdsByContractId}
) {
  for (const [screenId, contractStateIds] of screenContractStateIds.entries()) {
    const matrixStateIds = matrixStateIdsByContractId.get(screenId) ?? new Set();
    for (const stateId of contractStateIds) {
      if (!matrixStateIds.has(stateId)) {
        errors.push(`${screenId}.${stateId}: state is missing from design parity matrix.`);
      }
    }
    for (const stateId of matrixStateIds) {
      if (!contractStateIds.has(stateId)) {
        errors.push(`${screenId}.${stateId}: state is not declared in catch.screens.json.`);
      }
    }
  }
}

function validateScreenContractCaptureParity(
  errors,
  {screenContractCaptureIds, matrixCaptureIdsByContractId}
) {
  for (const [screenId, contractCaptureIds] of screenContractCaptureIds.entries()) {
    const matrixCaptureIds = matrixCaptureIdsByContractId.get(screenId) ?? new Set();
    for (const captureId of contractCaptureIds) {
      if (!matrixCaptureIds.has(captureId)) {
        errors.push(`${screenId}.${captureId}: capture is missing from design parity matrix.`);
      }
    }
  }
}

function validateDesignRefs(errors, label, refs, allowedKinds, allowedStatuses) {
  if (refs === undefined) return;
  if (!Array.isArray(refs)) {
    errors.push(`${label}.designRefs must be an array.`);
    return;
  }
  const ids = new Set();
  for (const ref of refs) {
    const refLabel = `${label}.designRefs.${ref?.id ?? "<missing ref id>"}`;
    if (!/^[a-z0-9_.-]+$/u.test(ref?.id ?? "")) {
      errors.push(`${refLabel}: invalid design ref id.`);
    }
    if (ids.has(ref?.id)) errors.push(`${refLabel}: duplicate design ref id.`);
    ids.add(ref?.id);
    if (!allowedKinds.has(ref?.kind)) errors.push(`${refLabel}: invalid kind ${ref?.kind}.`);
    if (!allowedStatuses.has(ref?.status)) {
      errors.push(`${refLabel}: invalid status ${ref?.status}.`);
    }
    if ((ref?.kind === "repo" || ref?.kind === "generated") && ref.path) {
      validatePaths(errors, `${refLabel}.path`, [ref.path]);
    }
  }
}

function validateGaps(errors, label, gaps, allowedStatuses) {
  if (gaps === undefined) return;
  if (!Array.isArray(gaps)) {
    errors.push(`${label} must be an array.`);
    return;
  }
  const ids = new Set();
  for (const gap of gaps) {
    const gapLabel = `${label}.${gap?.id ?? "<missing gap id>"}`;
    if (!/^[A-Z0-9-]+$/u.test(gap?.id ?? "")) errors.push(`${gapLabel}: invalid gap id.`);
    if (ids.has(gap?.id)) errors.push(`${gapLabel}: duplicate gap id.`);
    ids.add(gap?.id);
    if (!allowedStatuses.has(gap?.status)) {
      errors.push(`${gapLabel}: invalid status ${gap?.status}.`);
    }
    if (!gap?.nextAction) errors.push(`${gapLabel}: nextAction is required.`);
  }
}

function validateIds(errors, label, values, allowedValues) {
  if (values === undefined) return;
  if (!Array.isArray(values)) {
    errors.push(`${label} must be an array.`);
    return;
  }
  const seen = new Set();
  for (const value of values) {
    if (seen.has(value)) errors.push(`${label}: duplicate ${value}.`);
    seen.add(value);
    if (!allowedValues.has(value)) errors.push(`${label}: unknown id ${value}.`);
  }
}

function validatePaths(errors, label, values) {
  if (values === undefined) return;
  if (!Array.isArray(values)) {
    errors.push(`${label} must be an array.`);
    return;
  }
  const seen = new Set();
  for (const value of values) {
    if (seen.has(value)) errors.push(`${label}: duplicate ${value}.`);
    seen.add(value);
    if (!fs.existsSync(fromRepo(value))) {
      errors.push(`${label}: missing path ${value}.`);
    }
  }
}

function parseCaptureCatalog(source) {
  const entries = [];
  for (const block of extractCallBlocks(source, "ScreenCaptureEntry")) {
    const id = matchString(block, /\bid:\s*'([^']+)'/u);
    if (!id) continue;
    entries.push({id});
  }
  return entries;
}

function extractCallBlocks(source, callName) {
  const blocks = [];
  let searchIndex = 0;
  while (searchIndex < source.length) {
    const callIndex = source.indexOf(`${callName}(`, searchIndex);
    if (callIndex === -1) break;
    const openIndex = source.indexOf("(", callIndex);
    const endIndex = findBalancedEnd(source, openIndex, "(", ")");
    blocks.push(source.slice(callIndex, endIndex + 1));
    searchIndex = endIndex + 1;
  }
  return blocks;
}

function findBalancedEnd(source, openIndex, openChar, closeChar) {
  let depth = 0;
  let stringQuote = null;
  let escaped = false;
  for (let index = openIndex; index < source.length; index += 1) {
    const char = source[index];
    if (stringQuote) {
      if (escaped) {
        escaped = false;
      } else if (char === "\\") {
        escaped = true;
      } else if (char === stringQuote) {
        stringQuote = null;
      }
      continue;
    }
    if (char === "'" || char === '"') {
      stringQuote = char;
      continue;
    }
    if (char === openChar) depth += 1;
    if (char === closeChar) {
      depth -= 1;
      if (depth === 0) return index;
    }
  }
  throw new Error(`Could not find balanced ${openChar}${closeChar} block.`);
}

function matchString(source, pattern) {
  return pattern.exec(source)?.[1] ?? null;
}

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"));
  } catch (error) {
    console.error(`Failed to parse ${relativeToRepo(file)}: ${error.message}`);
    process.exit(1);
  }
}

function isDate(value) {
  return /^\d{4}-\d{2}-\d{2}$/u.test(value ?? "");
}

function printSummary(matrix) {
  const features = matrix.features ?? [];
  const screens = features.flatMap((feature) => feature.screens ?? []);
  const states = screens.flatMap((screen) => screen.states ?? []);
  const gaps = [
    ...features.flatMap((feature) => feature.lintCandidates ?? []),
    ...features.flatMap((feature) => feature.previewPlan ?? []),
    ...screens.flatMap((screen) => screen.gaps ?? []),
  ];
  console.log(
    [
      `Design parity matrix: ${relativeToRepo(matrixPath)}`,
      `Features: ${features.length}`,
      `Screens: ${screens.length}`,
      `States: ${states.length}`,
      `Open gaps: ${gaps.filter((gap) => gap.status !== "closed").length}`,
    ].join("\n")
  );
}

function printHelp() {
  console.log(`Usage: node tool/design/check_design_parity_matrix.mjs [--check|--summary]

Validates docs/design_parity/state_matrix.json against route inventory,
UI capture catalog ids, component contract ids, and referenced repo paths.
`);
}
