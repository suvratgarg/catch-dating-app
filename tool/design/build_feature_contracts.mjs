#!/usr/bin/env node
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

import Ajv2020 from "ajv/dist/2020.js";

import {fromRepo, repoRoot} from "../lib/repo_paths.mjs";

const featureRoot = fromRepo("design/features");
const generatedRoot = fromRepo("design/features/generated");
const schemaPath = path.join(featureRoot, "feature_contract.schema.json");
const screenRegistryPath = fromRepo("design/screens/catch.screens.json");
const componentRegistryPath = fromRepo("design/components/catch.components.json");
const isCli = process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

export class FeatureContractError extends Error {
  constructor(errors) {
    super(errors.join("\n"));
    this.name = "FeatureContractError";
    this.errors = errors;
  }
}

if (isCli) {
  runCli().catch((error) => {
    if (error instanceof FeatureContractError) {
      console.error("Feature contract generation failed:");
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
  if (unknown.length > 0) {
    console.error(`Unknown argument: ${unknown[0]}`);
    printHelp();
    process.exitCode = 64;
    return;
  }

  const schema = readJson(schemaPath);
  const ajv = new Ajv2020({allErrors: true, strict: false});
  const validate = ajv.compile(schema);
  const screenRegistry = readJson(screenRegistryPath);
  const componentRegistry = readJson(componentRegistryPath);
  const sources = fs.readdirSync(featureRoot)
    .filter((name) => name.endsWith(".feature.json"))
    .sort();
  if (sources.length === 0) {
    throw new FeatureContractError([
      "design/features must contain at least one *.feature.json source contract.",
    ]);
  }

  const outputs = [];
  for (const name of sources) {
    const sourcePath = path.join(featureRoot, name);
    const source = readJson(sourcePath);
    if (!validate(source)) {
      const schemaErrors = (validate.errors ?? []).map((error) =>
        `${name}${error.instancePath || "/"}: ${error.message}`
      );
      throw new FeatureContractError(schemaErrors);
    }
    const availablePreviews = new Set();
    for (const widgetbookSource of source.bindings.widgetbookSources) {
      const parsed = parseWidgetbookPreviewIds(
        fs.readFileSync(fromRepo(widgetbookSource), "utf8"),
      );
      for (const previewId of parsed) availablePreviews.add(previewId);
    }
    const artifact = compileFeatureContract({
      source,
      sourcePath: relative(sourcePath),
      screenRegistry,
      componentRegistry,
      availablePreviews,
      pathExists: (filePath) => fs.existsSync(fromRepo(filePath)),
      readPath: (filePath) => fs.readFileSync(fromRepo(filePath), "utf8"),
    });
    outputs.push({
      path: path.join(
        generatedRoot,
        name.replace(/\.feature\.json$/u, ".feature_contract.json"),
      ),
      artifact,
    });
  }

  if (summaryOnly) {
    for (const output of outputs) printSummary(output.artifact);
    return;
  }

  const expectedPaths = new Set(outputs.map((output) => path.resolve(output.path)));
  const existingGenerated = fs.existsSync(generatedRoot)
    ? fs.readdirSync(generatedRoot)
      .filter((name) => name.endsWith(".feature_contract.json"))
      .map((name) => path.join(generatedRoot, name))
    : [];
  const stale = [];
  for (const output of outputs) {
    const content = `${JSON.stringify(output.artifact, null, 2)}\n`;
    if (checkOnly) {
      const current = fs.existsSync(output.path)
        ? fs.readFileSync(output.path, "utf8")
        : null;
      if (current !== content) stale.push(relative(output.path));
    } else {
      fs.mkdirSync(path.dirname(output.path), {recursive: true});
      fs.writeFileSync(output.path, content);
    }
  }
  for (const existing of existingGenerated) {
    if (expectedPaths.has(path.resolve(existing))) continue;
    if (checkOnly) {
      stale.push(`${relative(existing)} (orphaned)`);
    } else {
      fs.rmSync(existing);
    }
  }

  if (stale.length > 0) {
    console.error("Generated feature contract outputs are stale:");
    for (const filePath of stale) console.error(`- ${filePath}`);
    console.error("Run: node tool/design/build_feature_contracts.mjs");
    process.exitCode = 1;
    return;
  }

  for (const output of outputs) printSummary(output.artifact);
  console.log(
    checkOnly
      ? "Generated feature contract outputs are current."
      : `Generated ${outputs.length} feature contract artifact(s).`,
  );
}

export function compileFeatureContract({
  source,
  sourcePath,
  screenRegistry,
  componentRegistry,
  availablePreviews,
  pathExists,
  readPath,
}) {
  const errors = [];
  const screens = new Map(
    (screenRegistry.screens ?? []).map((screen) => [screen.id, screen]),
  );
  const screen = screens.get(source.screenContract);
  if (screen == null) {
    errors.push(`${source.id}: unknown screen contract ${source.screenContract}.`);
    throw new FeatureContractError(errors);
  }

  validateBindings({source, componentRegistry, pathExists, readPath, errors});

  const dimensionDefaults = {};
  for (const [id, dimension] of Object.entries(source.dimensions ?? {})) {
    if (!(dimension.values ?? []).includes(dimension.default)) {
      errors.push(`${source.id}.dimensions.${id}: default must be one of values.`);
    }
    dimensionDefaults[id] = dimension.default;
  }

  const screenStates = new Map((screen.states ?? []).map((state) => [state.id, state]));
  const evidenceExceptions = compileEvidenceExceptions({
    source,
    screenStates,
    errors,
  });
  const evidenceExceptionMap = new Map();
  for (const exception of evidenceExceptions) {
    for (const screenStateId of exception.screenStateIds) {
      for (const evidenceKind of exception.evidence) {
        const key = evidenceExceptionKey(screenStateId, evidenceKind);
        if (evidenceExceptionMap.has(key)) {
          errors.push(
            `${source.id}.evidenceExceptions: duplicate exception for ` +
            `${screenStateId} ${evidenceKind}.`,
          );
        } else {
          evidenceExceptionMap.set(key, exception);
        }
      }
    }
  }
  const usedEvidenceExceptions = new Set();
  const actionIds = new Set();
  const actions = [];
  const actionOwnerSource = safeRead(source.bindings.actionOwner.file, readPath, errors);
  const ownerSymbol = source.bindings.actionOwner.symbol;
  if (actionOwnerSource != null && !hasSymbol(actionOwnerSource, ownerSymbol)) {
    errors.push(
      `${source.id}.bindings.actionOwner: ${ownerSymbol} is missing from ` +
      `${source.bindings.actionOwner.file}.`,
    );
  }
  for (const action of source.actions ?? []) {
    if (actionIds.has(action.id)) errors.push(`${source.id}: duplicate action ${action.id}.`);
    actionIds.add(action.id);
    for (const outcome of action.outcomes ?? []) {
      if (outcome.kind === "screen_state") {
        for (const stateId of outcome.stateIds ?? []) {
          if (!screenStates.has(stateId)) {
            errors.push(
              `${source.id}.actions.${action.id}: unknown outcome screen state ${stateId}.`,
            );
          }
        }
      } else if (outcome.kind === "route" && !screens.has(outcome.screenContract)) {
        errors.push(
          `${source.id}.actions.${action.id}: unknown outcome route ` +
          `${outcome.screenContract}.`,
        );
      }
    }
    if (actionOwnerSource != null && !hasWord(actionOwnerSource, action.codeValue)) {
      errors.push(
        `${source.id}.actions.${action.id}: codeValue ${action.codeValue} is missing from ` +
        `${source.bindings.actionOwner.file}.`,
      );
    }
    actions.push(action);
  }

  const mappedStateIds = new Set();
  const scenarioIds = new Set();
  const referencedActionIds = new Set();
  const compiledScenarios = [];
  for (const scenario of source.scenarios ?? []) {
    if (scenarioIds.has(scenario.id)) errors.push(`${source.id}: duplicate scenario ${scenario.id}.`);
    scenarioIds.add(scenario.id);
    if (mappedStateIds.has(scenario.screenStateId)) {
      errors.push(
        `${source.id}: screen state ${scenario.screenStateId} is mapped by more than one scenario.`,
      );
    }
    mappedStateIds.add(scenario.screenStateId);
    const screenState = screenStates.get(scenario.screenStateId);
    if (screenState == null) {
      errors.push(
        `${source.id}.scenarios.${scenario.id}: unknown screenStateId ` +
        `${scenario.screenStateId}.`,
      );
      continue;
    }

    validateDimensionSelection({
      label: `${source.id}.scenarios.${scenario.id}.dimensions`,
      selection: scenario.dimensions,
      dimensions: source.dimensions,
      errors,
    });
    const actionCaseIds = new Set();
    const actionCases = [];
    for (const actionCase of scenario.actionCases ?? []) {
      if (actionCaseIds.has(actionCase.id)) {
        errors.push(`${source.id}.scenarios.${scenario.id}: duplicate action case ${actionCase.id}.`);
      }
      actionCaseIds.add(actionCase.id);
      validateDimensionSelection({
        label: `${source.id}.scenarios.${scenario.id}.actionCases.${actionCase.id}.dimensions`,
        selection: actionCase.dimensions,
        dimensions: source.dimensions,
        errors,
      });
      const enabled = actionCase.enabledActions ?? [];
      const disabled = actionCase.disabledActions ?? [];
      const overlap = enabled.filter((id) => disabled.includes(id));
      if (overlap.length > 0) {
        errors.push(
          `${source.id}.scenarios.${scenario.id}.actionCases.${actionCase.id}: ` +
          `actions cannot be both enabled and disabled: ${overlap.join(", ")}.`,
        );
      }
      for (const actionId of [...enabled, ...disabled]) {
        if (!actionIds.has(actionId)) {
          errors.push(
            `${source.id}.scenarios.${scenario.id}.actionCases.${actionCase.id}: ` +
            `unknown action ${actionId}.`,
          );
        }
        referencedActionIds.add(actionId);
      }
      actionCases.push({
        id: actionCase.id,
        dimensions: {
          ...dimensionDefaults,
          ...(scenario.dimensions ?? {}),
          ...(actionCase.dimensions ?? {}),
        },
        actions: {
          enabled: [...enabled],
          disabled: [...disabled],
          notAllowed: actions
            .map((action) => action.id)
            .filter((id) => !enabled.includes(id) && !disabled.includes(id)),
        },
      });
    }

    const evidence = {
      captureIds: [...(screenState.captureIds ?? [])],
      previewIds: [...(screenState.previewIds ?? [])],
      tests: [...(screenState.tests ?? [])],
    };
    validateEvidence({
      featureId: source.id,
      scenario,
      screen,
      evidence,
      availablePreviews,
      pathExists,
      requiredEvidence: source.requiredEvidence,
      evidenceExceptionMap,
      usedEvidenceExceptions,
      errors,
    });
    compiledScenarios.push({
      id: scenario.id,
      screenStateId: scenario.screenStateId,
      kind: screenState.kind,
      status: screenState.status,
      dimensions: {...dimensionDefaults, ...(scenario.dimensions ?? {})},
      evidence,
      actionCases,
    });
  }

  const missingStates = [...screenStates.keys()].filter((id) => !mappedStateIds.has(id));
  const unknownMappedStates = [...mappedStateIds].filter((id) => !screenStates.has(id));
  if (missingStates.length > 0) {
    errors.push(`${source.id}: unmapped screen states: ${missingStates.join(", ")}.`);
  }
  if (unknownMappedStates.length > 0) {
    errors.push(`${source.id}: mapped unknown screen states: ${unknownMappedStates.join(", ")}.`);
  }
  const orphanActions = [...actionIds].filter((id) => !referencedActionIds.has(id));
  if (orphanActions.length > 0) {
    errors.push(`${source.id}: actions are never classified by a scenario: ${orphanActions.join(", ")}.`);
  }
  for (const key of evidenceExceptionMap.keys()) {
    if (!usedEvidenceExceptions.has(key)) {
      const [screenStateId, evidenceKind] = key.split(":");
      errors.push(
        `${source.id}.evidenceExceptions: unused exception for ` +
        `${screenStateId} ${evidenceKind}.`,
      );
    }
  }
  if (errors.length > 0) throw new FeatureContractError(errors);

  const selectedComponents = (componentRegistry.components ?? [])
    .filter((component) => source.bindings.componentContracts.includes(component.id))
    .map((component) => ({id: component.id, dart: component.dart}));
  const selectedPreviews = [...new Set(compiledScenarios.flatMap(
    (scenario) => scenario.evidence.previewIds,
  ))].sort();
  const resolvedProjection = {
    screen: {
      id: screen.id,
      states: compiledScenarios.map((scenario) => ({
        id: scenario.screenStateId,
        kind: scenario.kind,
        status: scenario.status,
        evidence: scenario.evidence,
      })),
    },
    components: selectedComponents,
    previews: selectedPreviews,
    evidenceExceptions,
  };
  const uniqueCaptures = uniqueSorted(compiledScenarios.flatMap(
    (scenario) => scenario.evidence.captureIds,
  ));
  const uniqueTests = uniqueSorted(compiledScenarios.flatMap(
    (scenario) => scenario.evidence.tests,
  ));

  return {
    notice: "GENERATED CODE - DO NOT MODIFY BY HAND.",
    version: 1,
    generatedFrom: sourcePath,
    generatedFor: source.updated,
    sourceDigest: digest(source),
    resolvedDigest: digest(resolvedProjection),
    feature: {
      id: source.id,
      name: source.name,
      owner: source.owner,
      status: source.status,
      description: source.description,
      actionScope: source.actionScope,
    },
    bindings: source.bindings,
    coverage: {
      screenStates: screenStates.size,
      scenarios: compiledScenarios.length,
      actionCases: compiledScenarios.reduce(
        (total, scenario) => total + scenario.actionCases.length,
        0,
      ),
      actions: actions.length,
      captures: uniqueCaptures.length,
      previews: selectedPreviews.length,
      testFiles: uniqueTests.length,
      evidenceExceptions: usedEvidenceExceptions.size,
    },
    dimensions: source.dimensions,
    actions,
    evidenceExceptions,
    scenarios: compiledScenarios,
  };
}

function compileEvidenceExceptions({source, screenStates, errors}) {
  const exceptions = [];
  for (const [index, exception] of (source.evidenceExceptions ?? []).entries()) {
    for (const stateId of exception.screenStateIds ?? []) {
      if (!screenStates.has(stateId)) {
        errors.push(
          `${source.id}.evidenceExceptions.${index}: unknown screen state ${stateId}.`,
        );
      }
    }
    exceptions.push({
      screenStateIds: [...(exception.screenStateIds ?? [])],
      evidence: [...(exception.evidence ?? [])],
      debtId: exception.debtId,
      reason: exception.reason,
    });
  }
  return exceptions;
}

function validateBindings({source, componentRegistry, pathExists, readPath, errors}) {
  const componentIds = new Set(
    (componentRegistry.components ?? []).map((component) => component.id),
  );
  for (const componentId of source.bindings.componentContracts ?? []) {
    if (!componentIds.has(componentId)) {
      errors.push(`${source.id}.bindings.componentContracts: unknown ${componentId}.`);
    }
  }
  for (const filePath of [
    ...(source.bindings.widgetbookSources ?? []),
    source.bindings.actionOwner.file,
    ...(source.bindings.dataContracts ?? []),
  ]) {
    if (!pathExists(filePath)) errors.push(`${source.id}.bindings: missing path ${filePath}.`);
  }
  for (const widgetbookSource of source.bindings.widgetbookSources ?? []) {
    if (pathExists(widgetbookSource)) safeRead(widgetbookSource, readPath, errors);
  }
}

function validateDimensionSelection({label, selection = {}, dimensions, errors}) {
  for (const [id, value] of Object.entries(selection ?? {})) {
    const dimension = dimensions[id];
    if (dimension == null) {
      errors.push(`${label}: unknown dimension ${id}.`);
      continue;
    }
    if (!dimension.values.includes(value)) {
      errors.push(`${label}: ${value} is not valid for ${id}.`);
    }
  }
}

function validateEvidence({
  featureId,
  scenario,
  screen,
  evidence,
  availablePreviews,
  pathExists,
  requiredEvidence,
  evidenceExceptionMap,
  usedEvidenceExceptions,
  errors,
}) {
  const label = `${featureId}.scenarios.${scenario.id}`;
  const screenCaptureIds = new Set([
    ...(screen.captures ?? []).map((capture) => capture.id),
    ...(screen.states ?? []).flatMap((state) => state.captureIds ?? []),
  ]);
  validateRequiredEvidence({
    label,
    screenStateId: scenario.screenStateId,
    evidenceKind: "captures",
    isRequired: requiredEvidence.captures,
    hasEvidence: evidence.captureIds.length > 0,
    evidenceExceptionMap,
    usedEvidenceExceptions,
    errors,
  });
  for (const captureId of evidence.captureIds) {
    if (!screenCaptureIds.has(captureId)) {
      errors.push(`${label}: capture ${captureId} is not registered on ${screen.id}.`);
    }
  }
  validateRequiredEvidence({
    label,
    screenStateId: scenario.screenStateId,
    evidenceKind: "previews",
    isRequired: requiredEvidence.previews,
    hasEvidence: evidence.previewIds.length > 0,
    evidenceExceptionMap,
    usedEvidenceExceptions,
    errors,
  });
  for (const previewId of evidence.previewIds) {
    if (!availablePreviews.has(previewId)) {
      errors.push(`${label}: Widgetbook preview ${previewId} is not declared.`);
    }
  }
  validateRequiredEvidence({
    label,
    screenStateId: scenario.screenStateId,
    evidenceKind: "tests",
    isRequired: requiredEvidence.tests,
    hasEvidence: evidence.tests.length > 0,
    evidenceExceptionMap,
    usedEvidenceExceptions,
    errors,
  });
  for (const testPath of evidence.tests) {
    if (!pathExists(testPath)) errors.push(`${label}: test path does not exist: ${testPath}.`);
  }
}

function validateRequiredEvidence({
  label,
  screenStateId,
  evidenceKind,
  isRequired,
  hasEvidence,
  evidenceExceptionMap,
  usedEvidenceExceptions,
  errors,
}) {
  const key = evidenceExceptionKey(screenStateId, evidenceKind);
  const hasException = evidenceExceptionMap.has(key);
  if (hasEvidence) return;
  if (isRequired && hasException) {
    usedEvidenceExceptions.add(key);
    return;
  }
  if (!isRequired) return;
  const labelByKind = {
    captures: "capture evidence",
    previews: "Widgetbook preview evidence",
    tests: "test evidence",
  };
  errors.push(`${label}: ${labelByKind[evidenceKind]} is required.`);
}

function evidenceExceptionKey(screenStateId, evidenceKind) {
  return `${screenStateId}:${evidenceKind}`;
}

export function parseWidgetbookPreviewIds(source) {
  const ids = new Set();
  const annotation = /@widgetbook\.UseCase\(([\s\S]*?)\n\)/gu;
  for (const match of source.matchAll(annotation)) {
    const body = match[1];
    const name = body.match(/\bname:\s*(['"])(.*?)\1/u)?.[2];
    const type = body.match(/\btype:\s*([A-Za-z_][A-Za-z0-9_]*)/u)?.[1];
    if (name != null && type != null) ids.add(`${type}/${name}`);
  }
  return ids;
}

function safeRead(filePath, readPath, errors) {
  try {
    return readPath(filePath);
  } catch (error) {
    errors.push(`${filePath}: unable to read (${error instanceof Error ? error.message : error}).`);
    return null;
  }
}

function hasSymbol(source, symbol) {
  return new RegExp(`\\b(?:class|enum|mixin|typedef)\\s+${escapeRegExp(symbol)}\\b`, "u")
    .test(source);
}

function hasWord(source, value) {
  return new RegExp(`\\b${escapeRegExp(value)}\\b`, "u").test(source);
}

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function digest(value) {
  return `sha256:${crypto.createHash("sha256").update(canonicalJson(value)).digest("hex")}`;
}

function canonicalJson(value) {
  if (Array.isArray(value)) return `[${value.map(canonicalJson).join(",")}]`;
  if (value != null && typeof value === "object") {
    return `{${Object.keys(value).sort().map((key) =>
      `${JSON.stringify(key)}:${canonicalJson(value[key])}`
    ).join(",")}}`;
  }
  return JSON.stringify(value);
}

function uniqueSorted(values) {
  return [...new Set(values)].sort();
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function relative(filePath) {
  return path.relative(repoRoot, filePath).replaceAll(path.sep, "/");
}

function printSummary(artifact) {
  const coverage = artifact.coverage;
  console.log(
    `${artifact.feature.id}: ${coverage.scenarios}/${coverage.screenStates} states, ` +
    `${coverage.actionCases} action cases, ${coverage.actions} actions, ` +
    `${coverage.captures} captures, ${coverage.previews} previews, ` +
    `${coverage.testFiles} test files, ` +
    `${coverage.evidenceExceptions} evidence exceptions.`,
  );
}

function printHelp() {
  console.log(`Usage:
  node tool/design/build_feature_contracts.mjs
  node tool/design/build_feature_contracts.mjs --check
  node tool/design/build_feature_contracts.mjs --summary

Compiles design/features/*.feature.json orchestration contracts against the
authoritative screen, component, capture, Widgetbook, test, and data-contract
sources. The default command writes deterministic generated artifacts; --check
fails when those artifacts or their referenced evidence are stale.`);
}
