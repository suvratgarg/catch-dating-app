#!/usr/bin/env node
import fs from "node:fs/promises";
import path from "node:path";
import {fileURLToPath} from "node:url";
import Ajv from "ajv";
import {CLI_COMMANDS} from "../src/platform/cli-contract.mjs";
import {stableStringify} from "../src/platform/canonical-json.mjs";
import {
  PLATFORM_CAPABILITY_CEILING,
  SUPPORTED_EXECUTION_MODES,
} from "../src/platform/contracts.mjs";
import {WORKFLOW_REGISTRY} from "../src/workflows/registry.mjs";

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const operationsRoot = path.resolve(scriptDirectory, "..");
const repoRoot = path.resolve(operationsRoot, "..");
const defaultWorkflowsRoot = path.join(
  operationsRoot,
  "src",
  "workflows"
);
const defaultSchemaPath = path.join(
  repoRoot,
  "contracts",
  "operations",
  "workflow_manifest.schema.json"
);

if (isMain()) {
  const result = await checkWorkflowManifest();
  const output = `${JSON.stringify(result, null, result.ok ? 0 : 2)}\n`;
  if (result.ok) process.stdout.write(output);
  else {
    process.stderr.write(output);
    process.exitCode = 1;
  }
}

export async function checkWorkflowManifest({
  manifest,
  manifests = {},
  registry = WORKFLOW_REGISTRY,
  schema,
  sourceProfiles,
  workflowDirectories,
  workflowsRoot = defaultWorkflowsRoot,
} = {}) {
  const resolvedSchema = schema ?? await readJson(defaultSchemaPath);
  const directories = workflowDirectories ??
    await discoverWorkflowDirectories(workflowsRoot);
  const registeredDirectories = registry.map((entry) => entry.directory)
    .sort();
  const findings = [];
  compareOrdered(
    findings,
    "workflow-registry-directories",
    [...directories].sort(),
    registeredDirectories
  );
  const validate = new Ajv({allErrors: true, strict: false}).compile(
    resolvedSchema
  );
  const checked = [];

  for (const [index, descriptor] of registry.entries()) {
    let resolvedManifest = index === 0 && manifest ? manifest :
      manifests[descriptor.directory];
    if (!resolvedManifest) {
      try {
        resolvedManifest = await readJson(path.join(
          workflowsRoot,
          descriptor.directory,
          "manifest.json"
        ));
      } catch (error) {
        if (error?.code !== "ENOENT") throw error;
        findings.push({
          id: "workflow-manifest-missing",
          workflow: descriptor.directory,
          message: "A registered workflow does not have manifest.json.",
        });
        continue;
      }
    }
    if (!validate(resolvedManifest)) {
      findings.push({
        id: "workflow-manifest-schema-invalid",
        workflow: descriptor.directory,
        message: "The workflow manifest does not satisfy its JSON Schema.",
        errors: (validate.errors ?? []).map((error) => ({
          instancePath: error.instancePath,
          keyword: error.keyword,
          message: error.message,
        })),
      });
    }
    const sourceProfileIds = Array.isArray(descriptor.sourceProfileIds) ?
      descriptor.sourceProfileIds : [];
    const loaderDeclared =
      typeof descriptor.loadSourceProfiles === "function";
    if (sourceProfileIds.length > 0 && !loaderDeclared) {
      findings.push({
        id: "workflow-source-profile-loader-missing",
        workflow: descriptor.workflowId,
        message: "A non-empty source profile inventory requires a loader.",
      });
    }
    let resolvedProfiles = [];
    if (index === 0 && sourceProfiles !== undefined) {
      resolvedProfiles = sourceProfiles;
    } else if (loaderDeclared) {
      try {
        resolvedProfiles = await descriptor.loadSourceProfiles();
      } catch (error) {
        findings.push({
          id: "workflow-source-profile-loader-failed",
          workflow: descriptor.workflowId,
          message: error instanceof Error ? error.message : String(error),
        });
      }
    }
    if (!Array.isArray(resolvedProfiles)) {
      findings.push({
        id: "workflow-source-profile-loader-invalid",
        workflow: descriptor.workflowId,
        message: "The source profile loader must return an array.",
      });
      resolvedProfiles = [];
    }
    const loadedSourceProfileIds = resolvedProfiles.map((profile) =>
      typeof profile === "string" ? profile : profile.sourceProfileId);
    compareDescriptor(
      findings,
      descriptor,
      resolvedManifest,
      loadedSourceProfileIds
    );
    await inspectWorkflowFactory(findings, descriptor);
    checked.push({
      workflowId: descriptor.workflowId,
      directory: descriptor.directory,
      commands: arrayLength(descriptor.commands),
      primaryStages: arrayLength(descriptor.primaryStages),
      lifecycleStatuses: arrayLength(descriptor.lifecycleStatuses),
      entityKinds: arrayLength(descriptor.entityKinds),
      sourceProfiles: loadedSourceProfileIds.length,
      maxWorkItemsPerRun: descriptor.maxWorkItemsPerRun,
    });
  }

  return {
    schemaVersion: 1,
    policyId: "operations-workflow-manifest-v1",
    ok: findings.length === 0,
    findings,
    checked: {
      workflows: checked,
      registeredDirectories,
      discoveredDirectories: [...directories].sort(),
    },
  };
}

async function inspectWorkflowFactory(findings, descriptor) {
  if (typeof descriptor.createWorkflow !== "function") return;
  let workflow;
  try {
    workflow = await descriptor.createWorkflow({repoRoot});
  } catch (error) {
    findings.push({
      id: "workflow-factory-failed",
      workflow: descriptor.workflowId,
      message: error instanceof Error ? error.message : String(error),
    });
    return;
  }
  const contract = (name) => `${descriptor.workflowId}:factory-${name}`;
  compareValue(findings, contract("workflow-id"), workflow?.workflowId,
    descriptor.workflowId);
  compareValue(findings, contract("version"), workflow?.version,
    descriptor.version);
  compareOrdered(findings, contract("primary-stages"),
    workflow?.primaryStages, descriptor.primaryStages);
  compareOrdered(findings, contract("lifecycle-statuses"),
    workflow?.lifecycleStatuses, descriptor.lifecycleStatuses);
  compareValue(findings, contract("lifecycle-semantics"),
    workflow?.lifecycleSemantics, descriptor.lifecycleSemantics);
  compareOrdered(findings, contract("entity-kinds"),
    workflow?.entityKinds, descriptor.entityKinds);
  compareValue(findings, contract("allowed-transitions"),
    workflow?.allowedTransitions, descriptor.allowedTransitions);
  for (const method of requiredWorkflowMethods(descriptor.commands)) {
    compareValue(findings, contract(`method-${method}`),
      typeof workflow?.[method], "function");
  }
}

function requiredWorkflowMethods(commands) {
  const declared = new Set(Array.isArray(commands) ? commands : []);
  const methods = new Set();
  if (["run", "resume", "queue", "status", "promote", "reconcile",
    "export-admin"].some((command) => declared.has(command))) {
    methods.add("assertPlan");
    methods.add("assertWorkItem");
  }
  if (declared.has("plan") || declared.has("run")) {
    methods.add("createPlan");
  }
  if (declared.has("run") || declared.has("resume")) {
    methods.add("project");
    methods.add("review");
  }
  if (declared.has("promote")) {
    methods.add("promotionCandidates");
    methods.add("promotionEligibility");
  }
  if (declared.has("reconcile")) {
    methods.add("createReconciliationPlan");
    methods.add("reconcile");
  }
  return [...methods].sort();
}

function compareDescriptor(
  findings,
  descriptor,
  manifest,
  loadedSourceProfileIds
) {
  const contract = (name) => `${descriptor.workflowId}:${name}`;
  compareValue(findings, contract("workflow-id"), manifest.workflowId,
    descriptor.workflowId);
  compareValue(findings, contract("workflow-version"), manifest.version,
    descriptor.version);
  compareValue(findings, contract("work-item-capacity"),
    manifest.maxWorkItemsPerRun, descriptor.maxWorkItemsPerRun);
  compareOrdered(findings, contract("execution-modes"),
    manifest.executionModes, descriptor.executionModes);
  compareSubset(findings, contract("platform-execution-modes"),
    descriptor.executionModes, SUPPORTED_EXECUTION_MODES);
  compareOrdered(findings, contract("cli-commands"), manifest.commands,
    descriptor.commands);
  compareSubset(findings, contract("live-cli-commands"),
    descriptor.commands, CLI_COMMANDS);
  compareValue(findings, contract("workflow-factory"),
    typeof descriptor.createWorkflow, "function");
  compareOrdered(findings, contract("primary-stages"),
    manifest.primaryStages, descriptor.primaryStages);
  compareOrdered(findings, contract("lifecycle-statuses"),
    manifest.lifecycleStatuses, descriptor.lifecycleStatuses);
  compareValue(findings, contract("lifecycle-semantics"),
    manifest.lifecycleSemantics, descriptor.lifecycleSemantics);
  validateLifecycleSemantics(findings,
    contract("manifest-lifecycle-semantics"),
    manifest.lifecycleStatuses, manifest.lifecycleSemantics);
  validateLifecycleSemantics(findings,
    contract("descriptor-lifecycle-semantics"),
    descriptor.lifecycleStatuses, descriptor.lifecycleSemantics);
  compareOrdered(findings, contract("entity-kinds"), manifest.entityKinds,
    descriptor.entityKinds);
  compareValue(findings, contract("allowed-transitions"),
    manifest.allowedTransitions, descriptor.allowedTransitions);
  validateTransitionGraph(findings, contract("manifest-transition-closure"),
    manifest.primaryStages, manifest.allowedTransitions);
  validateTransitionGraph(findings, contract("descriptor-transition-closure"),
    descriptor.primaryStages, descriptor.allowedTransitions);
  compareOrdered(findings, contract("declared-source-profiles"),
    manifest.sourceProfiles, descriptor.sourceProfileIds);
  compareOrdered(findings, contract("loaded-source-profiles"),
    loadedSourceProfileIds, descriptor.sourceProfileIds);
  compareOrdered(findings, contract("compatibility-artifacts"),
    (manifest.compatibilityInputs ?? []).flatMap((entry) =>
      entry.artifacts ?? []), descriptor.compatibilityArtifactPatterns);
  compareValue(findings, contract("capabilities"), manifest.capabilities,
    descriptor.capabilities);
  compareCapabilityCeiling(findings,
    contract("platform-capability-ceiling"), descriptor.capabilities,
    PLATFORM_CAPABILITY_CEILING);
  if (Array.isArray(descriptor.commands) &&
      descriptor.commands.includes("learn")) {
    compareValue(findings, contract("learner-factory"),
      typeof descriptor.createLearner, "function");
  }
}

function compareSubset(findings, contract, actual, supported) {
  if (Array.isArray(actual) &&
      actual.every((value) => supported.includes(value))) return;
  findings.push({
    id: "workflow-manifest-contract-drift",
    contract,
    actual: actual ?? null,
    expected: {subsetOf: [...supported]},
  });
}

function compareCapabilityCeiling(findings, contract, actual, ceiling) {
  if (actual && typeof actual === "object" &&
      Object.keys(ceiling).every((key) =>
        typeof actual[key] === "boolean" &&
        (!actual[key] || ceiling[key]))) return;
  findings.push({
    id: "workflow-manifest-contract-drift",
    contract,
    actual: actual ?? null,
    expected: {maximum: ceiling},
  });
}

function compareOrdered(findings, contract, actual, expected) {
  if (Array.isArray(actual) && Array.isArray(expected) &&
      actual.length === expected.length &&
      actual.every((value, index) => value === expected[index])) {
    return;
  }
  findings.push({
    id: "workflow-manifest-contract-drift",
    contract,
    actual: actual ?? null,
    expected: Array.isArray(expected) ? [...expected] : expected ?? null,
  });
}

function validateTransitionGraph(findings, contract, stages, transitions) {
  const stageSet = new Set(Array.isArray(stages) ? stages : []);
  const keys = transitions && typeof transitions === "object" &&
    !Array.isArray(transitions) ? Object.keys(transitions) : [];
  const keyClosure = keys.length === stageSet.size &&
    keys.every((key) => stageSet.has(key));
  const targetClosure = keyClosure && keys.every((key) =>
    Array.isArray(transitions[key]) &&
      transitions[key].every((target) => stageSet.has(target)));
  if (keyClosure && targetClosure) return;
  findings.push({
    id: "workflow-transition-graph-invalid",
    contract,
    actual: transitions ?? null,
    expected: {
      keys: [...stageSet],
      targets: {membersOf: [...stageSet]},
    },
  });
}

function validateLifecycleSemantics(
  findings,
  contract,
  lifecycleStatuses,
  semantics
) {
  const declared = new Set(Array.isArray(lifecycleStatuses) ?
    lifecycleStatuses : []);
  const active = semantics?.activeStatuses;
  const published = semantics?.publishedStatuses;
  const expired = semantics?.expiredStatuses;
  const groups = [active, published, expired];
  const arraysValid = Array.isArray(active) && active.length > 0 &&
    groups.every((group) => Array.isArray(group) &&
      new Set(group).size === group.length &&
      group.every((status) => declared.has(status)));
  const activeSet = new Set(Array.isArray(active) ? active : []);
  const publishedSet = new Set(Array.isArray(published) ? published : []);
  const disjoint = arraysValid &&
    [...publishedSet].every((status) => !activeSet.has(status)) &&
    (Array.isArray(expired) ? expired : []).every((status) =>
      !activeSet.has(status) && !publishedSet.has(status));
  if (arraysValid && disjoint) return;
  findings.push({
    id: "workflow-lifecycle-semantics-invalid",
    contract,
    actual: semantics ?? null,
    expected: {
      activeStatuses: {nonEmptySubsetOf: [...declared]},
      publishedStatuses: {terminalSubsetOf: [...declared]},
      expiredStatuses: {terminalSubsetOf: [...declared]},
      categories: "pairwise_disjoint",
    },
  });
}

function arrayLength(value) {
  return Array.isArray(value) ? value.length : 0;
}

function compareValue(findings, contract, actual, expected) {
  if (actual !== undefined &&
      stableStringify(actual) === stableStringify(expected)) return;
  findings.push({
    id: "workflow-manifest-contract-drift",
    contract,
    actual: actual ?? null,
    expected,
  });
}

async function discoverWorkflowDirectories(root) {
  return (await fs.readdir(root, {withFileTypes: true}))
    .filter((entry) => entry.isDirectory())
    .map((entry) => entry.name)
    .sort();
}

async function readJson(filePath) {
  return JSON.parse(await fs.readFile(filePath, "utf8"));
}

function isMain() {
  return process.argv[1] &&
    path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
}
