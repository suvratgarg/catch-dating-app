#!/usr/bin/env node
import {createHash} from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {planFirebaseDeployGroups} from "../firebase/plan_firebase_deploy_targets.mjs";
import {listFirebaseFunctionTargets} from "../firebase/list_firebase_function_targets.mjs";

export const FIREBASE_DELIVERY_PLAN_SCHEMA = "catch.firebase-delivery-plan/v2";
export const FIREBASE_DELIVERY_INVENTORY_SCHEMA =
  "catch.firebase-delivery-inventory/v1";

const SHA_RE = /^[0-9a-f]{40}$/;
const RUN_ID_RE = /^[1-9][0-9]*$/;
const DIGEST_RE = /^[0-9a-f]{64}$/;
const PHASE_TO_STAGE = Object.freeze({
  "firestore:indexes": "firestore-indexes",
  functions: "functions",
  "firestore:rules": "firestore-rules",
  storage: "storage-rules",
});
const STAGE_TO_PHASE = Object.freeze(
  Object.fromEntries(Object.entries(PHASE_TO_STAGE).map(([phase, stage]) => [stage, phase])),
);
const DEPLOY_GROUP_REQUIREMENTS = Object.freeze({
  "firestore-indexes": "contracts",
  functions: "functions",
  "firestore-rules": "firestore_rules",
  "storage-rules": "firestore_rules",
});
const INVENTORY_FILE = "delivery-inventory.json";
const RUNTIME_DEPENDENCY_ROOT = "functions/node_modules";

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function assertObject(value, label) {
  assert(value !== null && typeof value === "object" && !Array.isArray(value),
    `${label} must be an object.`);
}

function assertExactKeys(value, keys, label) {
  assertObject(value, label);
  const actual = Object.keys(value).sort();
  const expected = [...keys].sort();
  assert(JSON.stringify(actual) === JSON.stringify(expected),
    `${label} must contain exactly: ${expected.join(", ")}.`);
}

function readRegularBytes(filePath, label) {
  let stat;
  try {
    stat = fs.lstatSync(filePath);
  } catch (error) {
    throw new Error(`Cannot read ${label} '${filePath}': ${error.message}`);
  }
  assert(stat.isFile() && !stat.isSymbolicLink(),
    `${label} must be a regular non-symlink file: ${filePath}`);
  return fs.readFileSync(filePath);
}

function readJson(filePath, label) {
  try {
    return JSON.parse(readRegularBytes(filePath, label).toString("utf8"));
  } catch (error) {
    if (error.message.startsWith("Cannot read") || error.message.includes("must be a regular")) {
      throw error;
    }
    throw new Error(`Cannot parse ${label} '${filePath}': ${error.message}`);
  }
}

function writeJson(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), {recursive: true});
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`, "utf8");
}

function sha256(buffer) {
  return createHash("sha256").update(buffer).digest("hex");
}

function jsonEqual(left, right) {
  return JSON.stringify(left) === JSON.stringify(right);
}

function assertStringArray(value, label) {
  assert(Array.isArray(value) && value.every((entry) =>
    typeof entry === "string" && entry.length > 0), `${label} must be an array of strings.`);
  return [...value];
}

function cloneWithoutPredeploy(value) {
  if (Array.isArray(value)) return value.map(cloneWithoutPredeploy);
  if (value === null || typeof value !== "object") return value;
  return Object.fromEntries(
    Object.entries(value)
      .filter(([key]) => key !== "predeploy")
      .map(([key, child]) => [key, cloneWithoutPredeploy(child)]),
  );
}

function canonicalFunctionsConfig(value) {
  assertObject(value, "firebase.json functions configuration");
  assert(value.source === "functions",
    "firebase.json functions.source must be the canonical package-relative path 'functions'.");
  return {...cloneWithoutPredeploy(value), source: "functions"};
}

function canonicalFirestoreConfig(value, selected) {
  assertObject(value, "firebase.json Firestore configuration");
  const bounded = {};
  for (const key of ["database", "location"]) {
    if (value[key] !== undefined) bounded[key] = value[key];
  }
  if (selected.has("firestore:indexes")) {
    assert(value.indexes === "firestore.indexes.json",
      "firebase.json firestore.indexes must be the canonical package-relative path 'firestore.indexes.json'.");
    bounded.indexes = "firestore.indexes.json";
  }
  if (selected.has("firestore:rules")) {
    assert(value.rules === "firestore.rules",
      "firebase.json firestore.rules must be the canonical package-relative path 'firestore.rules'.");
    bounded.rules = "firestore.rules";
  }
  return bounded;
}

export function createBoundedFirebaseConfig(sourceConfig, phases) {
  assertObject(sourceConfig, "firebase.json");
  const selected = new Set(phases);
  const bounded = {};
  if (selected.has("functions")) {
    assert(sourceConfig.functions, "firebase.json is missing functions configuration.");
    bounded.functions = canonicalFunctionsConfig(sourceConfig.functions);
  }
  if (selected.has("firestore:indexes") || selected.has("firestore:rules")) {
    assert(sourceConfig.firestore, "firebase.json is missing Firestore configuration.");
    bounded.firestore = canonicalFirestoreConfig(sourceConfig.firestore, selected);
  }
  if (selected.has("storage")) {
    assertObject(sourceConfig.storage, "firebase.json Storage configuration");
    assert(sourceConfig.storage.rules === "storage.rules",
      "firebase.json storage.rules must be the canonical package-relative path 'storage.rules'.");
    bounded.storage = {rules: "storage.rules"};
  }
  assert(Object.keys(bounded).length > 0, "No bounded Firebase configuration was selected.");
  return bounded;
}

function validateBinding({sourceSha, baseSha, sourceCiRunId, sourceCiRunAttempt}) {
  assert(SHA_RE.test(sourceSha), "source SHA must be 40 lowercase hexadecimal characters.");
  assert(SHA_RE.test(baseSha), "base SHA must be 40 lowercase hexadecimal characters.");
  assert(RUN_ID_RE.test(String(sourceCiRunId)),
    "source CI run id must be a positive decimal identifier.");
  assert(RUN_ID_RE.test(String(sourceCiRunAttempt)),
    "source CI run attempt must be a positive decimal identifier.");
}

function validateImpactPlan(impactPlan, binding) {
  assertObject(impactPlan, "CI impact plan");
  assert(impactPlan.schemaVersion === "0.2.0",
    "CI impact plan must use Harness schemaVersion 0.2.0.");
  assert(impactPlan.graphStatus === "required",
    "CI impact plan must come from the required component graph.");
  assert(impactPlan.complete === true, "CI impact plan must be complete.");
  assert(impactPlan.mode === "main", "Firebase delivery requires a main-mode CI impact plan.");
  for (const [key, expected] of Object.entries({
    sourceSha: binding.sourceSha,
    baseSha: binding.baseSha,
    sourceCiRunId: String(binding.sourceCiRunId),
    sourceCiRunAttempt: String(binding.sourceCiRunAttempt),
  })) {
    assert(impactPlan[key] === expected,
      `CI impact plan ${key} does not match the requested delivery binding.`);
  }
  assertObject(impactPlan.operations, "CI impact plan operations");
  const deployGroups = assertStringArray(
    impactPlan.operations.deployGroups,
    "CI impact plan operations.deployGroups",
  );
  assert(deployGroups.length > 0, "CI impact plan did not authorize a Firebase deployment.");
  const ciTargets = new Set(assertStringArray(
    impactPlan.operations.ciTargets,
    "CI impact plan operations.ciTargets",
  ));
  for (const group of deployGroups) {
    const requiredTarget = DEPLOY_GROUP_REQUIREMENTS[group];
    assert(requiredTarget,
      `CI deploy group is not allowed in automatic delivery: ${group}`);
    assert(ciTargets.has(requiredTarget),
      `CI deploy group '${group}' requires successful '${requiredTarget}' validation.`);
  }
  return [...new Set(deployGroups)].sort();
}

function deliverySelection({impactPlan, functionTargets, binding}) {
  const deployGroups = validateImpactPlan(impactPlan, binding);
  const phases = planFirebaseDeployGroups(deployGroups, {functionTargets});
  return {
    deployGroups,
    stages: phases.map(({phase}) => PHASE_TO_STAGE[phase]),
    targets: phases.map(({deployOnly}) => deployOnly),
  };
}

function assertNoSymlinkComponents(root, candidate) {
  const relative = path.relative(root, candidate);
  assert(relative !== "" && !relative.startsWith(`..${path.sep}`) && relative !== "..",
    `Path must be a descendant of ${root}: ${candidate}`);
  let current = root;
  for (const segment of relative.split(path.sep)) {
    current = path.join(current, segment);
    if (!fs.existsSync(current)) continue;
    assert(!fs.lstatSync(current).isSymbolicLink(),
      `Path must not traverse a symlink: ${current}`);
  }
}

function createFreshStage(sourceRoot, stageDir) {
  const resolvedSource = path.resolve(sourceRoot);
  assert(fs.realpathSync(resolvedSource) === resolvedSource,
    "sourceRoot must be a canonical non-symlink path.");
  const buildRoot = path.join(resolvedSource, "build");
  const resolvedStage = path.resolve(stageDir);
  assertNoSymlinkComponents(resolvedSource, resolvedStage);
  assert(resolvedStage.startsWith(`${buildRoot}${path.sep}`),
    "stageDir must be a fresh descendant of sourceRoot/build.");
  assert(!fs.existsSync(resolvedStage), "stageDir must not already exist.");
  fs.mkdirSync(path.dirname(resolvedStage), {recursive: true});
  assertNoSymlinkComponents(resolvedSource, path.dirname(resolvedStage));
  fs.mkdirSync(resolvedStage, {recursive: false, mode: 0o700});
  return {sourceRoot: resolvedSource, stageDir: resolvedStage};
}

function copyRegularFile(source, destination, label) {
  const bytes = readRegularBytes(source, label);
  fs.mkdirSync(path.dirname(destination), {recursive: true});
  fs.writeFileSync(destination, bytes);
}

function copyDirectoryStrict(sourceDir, destinationDir, label) {
  const rootStat = fs.lstatSync(sourceDir);
  assert(rootStat.isDirectory() && !rootStat.isSymbolicLink(),
    `${label} must be a regular non-symlink directory.`);
  fs.mkdirSync(destinationDir, {recursive: true});
  let copiedFiles = 0;
  const visit = (source, destination, relative) => {
    for (const entry of fs.readdirSync(source, {withFileTypes: true})) {
      const sourcePath = path.join(source, entry.name);
      const destinationPath = path.join(destination, entry.name);
      const entryLabel = `${label}/${relative ? `${relative}/` : ""}${entry.name}`;
      const stat = fs.lstatSync(sourcePath);
      assert(!stat.isSymbolicLink(), `${entryLabel} must not be a symlink.`);
      if (stat.isDirectory()) {
        fs.mkdirSync(destinationPath, {recursive: false});
        visit(sourcePath, destinationPath, relative ? `${relative}/${entry.name}` : entry.name);
      } else {
        assert(stat.isFile(), `${entryLabel} must be a regular file or directory.`);
        fs.copyFileSync(sourcePath, destinationPath);
        copiedFiles += 1;
      }
    }
  };
  visit(sourceDir, destinationDir, "");
  assert(copiedFiles > 0, `${label} must contain at least one file.`);
}

function boundedFunctionsPackage(sourcePackage) {
  assertObject(sourcePackage, "functions/package.json");
  const bounded = structuredClone(sourcePackage);
  const syncScript = sourcePackage.scripts?.["sync:callable-invokers"];
  bounded.scripts = syncScript ? {"sync:callable-invokers": syncScript} : {};
  for (const lifecycle of [
    "preinstall", "install", "postinstall", "prepare", "prepublish", "prepublishOnly",
  ]) {
    assert(!(lifecycle in bounded.scripts),
      `Packaged Functions must not contain npm lifecycle hook '${lifecycle}'.`);
  }
  return bounded;
}

function normalizeInventoryPath(value) {
  assert(typeof value === "string" && value.length > 0,
    "Inventory paths must be non-empty strings.");
  assert(!value.includes("\\") && !path.posix.isAbsolute(value),
    `Inventory path must be package-relative POSIX syntax: ${value}`);
  const normalized = path.posix.normalize(value);
  assert(normalized === value && !normalized.startsWith("../") && normalized !== ".." &&
    normalized !== ".", `Inventory path escapes the package: ${value}`);
  return value;
}

function collectFiles(rootDir, {allowRuntimeDependencies = false} = {}) {
  const rootStat = fs.lstatSync(rootDir);
  assert(rootStat.isDirectory() && !rootStat.isSymbolicLink(),
    `Firebase package must be a regular non-symlink directory: ${rootDir}`);
  const entries = [];
  const visit = (directory, relativeDirectory) => {
    for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
      const relativePath = relativeDirectory
        ? `${relativeDirectory}/${entry.name}`
        : entry.name;
      if (allowRuntimeDependencies && relativePath === RUNTIME_DEPENDENCY_ROOT) {
        const runtimeStat = fs.lstatSync(path.join(directory, entry.name));
        assert(runtimeStat.isDirectory() && !runtimeStat.isSymbolicLink(),
          `${RUNTIME_DEPENDENCY_ROOT} must be a real directory.`);
        continue;
      }
      const filePath = path.join(directory, entry.name);
      const stat = fs.lstatSync(filePath);
      assert(!stat.isSymbolicLink(), `Firebase package must not contain symlinks: ${relativePath}`);
      if (stat.isDirectory()) {
        visit(filePath, relativePath);
      } else {
        assert(stat.isFile(), `Firebase package contains a non-regular entry: ${relativePath}`);
        if (relativePath !== INVENTORY_FILE) {
          const bytes = fs.readFileSync(filePath);
          entries.push({path: relativePath, sizeBytes: bytes.length, sha256: sha256(bytes)});
        }
      }
    }
  };
  visit(rootDir, "");
  return entries.sort((left, right) => left.path < right.path ? -1 : left.path > right.path ? 1 : 0);
}

function validateInventory(value) {
  assertExactKeys(value, ["entries", "schema"], "delivery inventory");
  assert(value.schema === FIREBASE_DELIVERY_INVENTORY_SCHEMA,
    `Expected delivery inventory schema ${FIREBASE_DELIVERY_INVENTORY_SCHEMA}.`);
  assert(Array.isArray(value.entries), "delivery inventory entries must be an array.");
  let previous = "";
  const seen = new Set();
  const entries = value.entries.map((entry, index) => {
    assertExactKeys(entry, ["path", "sha256", "sizeBytes"],
      `delivery inventory entry ${index + 1}`);
    const entryPath = normalizeInventoryPath(entry.path);
    assert(entryPath > previous,
      "delivery inventory entries must be unique and sorted by path.");
    previous = entryPath;
    assert(!seen.has(entryPath), `Duplicate delivery inventory path: ${entryPath}`);
    seen.add(entryPath);
    assert(Number.isSafeInteger(entry.sizeBytes) && entry.sizeBytes >= 0,
      `Invalid size for delivery inventory path: ${entryPath}`);
    assert(DIGEST_RE.test(entry.sha256),
      `Invalid SHA-256 for delivery inventory path: ${entryPath}`);
    return {...entry};
  });
  return {schema: FIREBASE_DELIVERY_INVENTORY_SCHEMA, entries};
}

function writeInventory(stageDir) {
  const inventory = validateInventory({
    schema: FIREBASE_DELIVERY_INVENTORY_SCHEMA,
    entries: collectFiles(stageDir),
  });
  writeJson(path.join(stageDir, INVENTORY_FILE), inventory);
  return inventory;
}

function verifyInventory(packageDir, {allowRuntimeDependencies = false, trustedPackageDir} = {}) {
  const inventoryPath = path.join(packageDir, INVENTORY_FILE);
  const inventoryBytes = readRegularBytes(inventoryPath, "delivery inventory");
  let trustedInventoryBytes = inventoryBytes;
  if (trustedPackageDir) {
    trustedInventoryBytes = readRegularBytes(
      path.join(trustedPackageDir, INVENTORY_FILE),
      "trusted delivery inventory",
    );
    assert(inventoryBytes.equals(trustedInventoryBytes),
      "Runtime delivery inventory does not match the trusted package inventory.");
  }
  const inventory = validateInventory(JSON.parse(trustedInventoryBytes.toString("utf8")));
  const actualEntries = collectFiles(packageDir, {allowRuntimeDependencies});
  assert(jsonEqual(actualEntries, inventory.entries),
    "Firebase package contents do not match the delivery inventory.");
  return inventory;
}

function currentFunctionTargets(sourceRoot) {
  return listFirebaseFunctionTargets(sourceRoot);
}

export function prepareFirebaseDelivery({
  sourceRoot,
  impactPlanPath,
  sourceSha,
  baseSha,
  sourceCiRunId,
  sourceCiRunAttempt,
  stageDir,
  functionTargets,
  functionsLibDir,
}) {
  const binding = {sourceSha, baseSha, sourceCiRunId, sourceCiRunAttempt};
  validateBinding(binding);
  const resolvedSourceRoot = fs.realpathSync(path.resolve(sourceRoot));
  const impactPlanBytes = readRegularBytes(impactPlanPath, "CI impact plan");
  const impactPlan = JSON.parse(impactPlanBytes.toString("utf8"));
  const resolvedFunctionTargets = functionTargets ?? currentFunctionTargets(resolvedSourceRoot);
  const selection = deliverySelection({
    impactPlan,
    functionTargets: resolvedFunctionTargets,
    binding,
  });
  const sourceFirebaseConfig = readJson(
    path.join(resolvedSourceRoot, "firebase.json"),
    "firebase config",
  );
  const phases = selection.stages.map((stage) => STAGE_TO_PHASE[stage]);
  const boundedConfig = createBoundedFirebaseConfig(sourceFirebaseConfig, phases);
  const sourceFirebaseRc = readJson(
    path.join(resolvedSourceRoot, ".firebaserc"),
    "Firebase aliases",
  );
  assertObject(sourceFirebaseRc.projects, ".firebaserc projects");
  assert(Object.values(sourceFirebaseRc.projects).every((projectId) =>
    typeof projectId === "string" && projectId.length > 0),
  ".firebaserc project aliases must map to non-empty project ids.");
  const prepared = createFreshStage(resolvedSourceRoot, stageDir);

  writeJson(path.join(prepared.stageDir, "firebase.json"), boundedConfig);
  writeJson(path.join(prepared.stageDir, ".firebaserc"), {projects: sourceFirebaseRc.projects});
  fs.writeFileSync(path.join(prepared.stageDir, "impact-plan.json"), impactPlanBytes);

  const copySourceFile = (relativePath) => copyRegularFile(
    path.join(prepared.sourceRoot, relativePath),
    path.join(prepared.stageDir, relativePath),
    relativePath,
  );
  if (selection.stages.includes("firestore-indexes")) copySourceFile("firestore.indexes.json");
  if (selection.stages.includes("firestore-rules")) copySourceFile("firestore.rules");
  if (selection.stages.includes("storage-rules")) copySourceFile("storage.rules");
  if (selection.stages.includes("functions")) {
    assert(functionsLibDir, "functionsLibDir is required for a Functions delivery.");
    const sourcePackage = readJson(
      path.join(prepared.sourceRoot, "functions/package.json"),
      "Functions package",
    );
    writeJson(
      path.join(prepared.stageDir, "functions/package.json"),
      boundedFunctionsPackage(sourcePackage),
    );
    copySourceFile("functions/package-lock.json");
    copySourceFile("functions/scripts/set-callable-invokers-public.cjs");
    copyDirectoryStrict(
      path.resolve(functionsLibDir),
      path.join(prepared.stageDir, "functions/lib"),
      "tested Functions lib",
    );
    assert(fs.existsSync(path.join(prepared.stageDir, "functions/lib/index.js")),
      "Tested Functions lib must contain index.js.");
  }

  const deliveryPlan = {
    schema: FIREBASE_DELIVERY_PLAN_SCHEMA,
    sourceSha,
    baseSha,
    sourceCiRunId: String(sourceCiRunId),
    sourceCiRunAttempt: String(sourceCiRunAttempt),
    impactPlanSha256: sha256(impactPlanBytes),
    deployGroups: selection.deployGroups,
    stages: selection.stages,
    targets: selection.targets,
  };
  writeJson(path.join(prepared.stageDir, "delivery-plan.json"), deliveryPlan);
  writeInventory(prepared.stageDir);
  return deliveryPlan;
}

function validateDeliveryPlan(value) {
  assertExactKeys(value, [
    "baseSha",
    "deployGroups",
    "impactPlanSha256",
    "schema",
    "sourceCiRunAttempt",
    "sourceCiRunId",
    "sourceSha",
    "stages",
    "targets",
  ], "delivery plan");
  assert(value.schema === FIREBASE_DELIVERY_PLAN_SCHEMA,
    `Expected delivery plan schema ${FIREBASE_DELIVERY_PLAN_SCHEMA}.`);
  validateBinding(value);
  assert(DIGEST_RE.test(value.impactPlanSha256),
    "delivery plan impactPlanSha256 must be a SHA-256 digest.");
  const deployGroups = assertStringArray(value.deployGroups, "delivery plan deployGroups");
  const stages = assertStringArray(value.stages, "delivery plan stages");
  const targets = assertStringArray(value.targets, "delivery plan targets");
  assert(stages.length === targets.length,
    "delivery plan stages and targets must have the same length.");
  assert(new Set(stages).size === stages.length,
    "delivery plan stages must not contain duplicates.");
  return {...value, deployGroups, stages, targets};
}

export function verifyFirebaseDelivery({
  sourceRoot,
  packageDir,
  sourceSha,
  baseSha,
  sourceCiRunId,
  sourceCiRunAttempt,
  provenanceManifestPath,
  functionTargets,
  allowRuntimeDependencies = false,
  trustedPackageDir,
}) {
  const binding = {sourceSha, baseSha, sourceCiRunId, sourceCiRunAttempt};
  validateBinding(binding);
  if (allowRuntimeDependencies) {
    assert(trustedPackageDir,
      "trustedPackageDir is required when runtime dependencies are allowed.");
  }
  verifyInventory(packageDir, {allowRuntimeDependencies, trustedPackageDir});
  const deliveryPlan = validateDeliveryPlan(
    readJson(path.join(packageDir, "delivery-plan.json"), "delivery plan"),
  );
  for (const [key, expected] of Object.entries({
    sourceSha,
    baseSha,
    sourceCiRunId: String(sourceCiRunId),
    sourceCiRunAttempt: String(sourceCiRunAttempt),
  })) {
    assert(deliveryPlan[key] === expected,
      `Delivery plan ${key} does not match the expected delivery binding.`);
  }

  const impactPlanBytes = readRegularBytes(
    path.join(packageDir, "impact-plan.json"),
    "packaged CI impact plan",
  );
  assert(sha256(impactPlanBytes) === deliveryPlan.impactPlanSha256,
    "Packaged CI impact plan digest does not match the delivery plan.");
  const impactPlan = JSON.parse(impactPlanBytes.toString("utf8"));
  const resolvedFunctionTargets = functionTargets ?? currentFunctionTargets(path.resolve(sourceRoot));
  const selection = deliverySelection({impactPlan, functionTargets: resolvedFunctionTargets, binding});
  assert(jsonEqual(selection.deployGroups, deliveryPlan.deployGroups),
    "Delivery groups do not match the packaged CI impact plan.");
  assert(jsonEqual(selection.stages, deliveryPlan.stages),
    "Delivery stages do not match the packaged CI impact plan.");
  assert(jsonEqual(selection.targets, deliveryPlan.targets),
    "Delivery targets do not match the checked-in Firebase Function exports and CI plan.");

  assert(provenanceManifestPath,
    "provenanceManifestPath is required for combined adapter verification.");
  const provenance = readJson(provenanceManifestPath, "delivery provenance manifest");
  assert(provenance.sourceSha === sourceSha,
    "Provenance manifest source SHA does not match the delivery plan.");
  assert(String(provenance.sourceCiRunId) === String(sourceCiRunId),
    "Provenance manifest CI run id does not match the delivery plan.");
  assert(String(provenance.sourceCiRunAttempt) === String(sourceCiRunAttempt),
    "Provenance manifest CI run attempt does not match the delivery plan.");
  assert(jsonEqual(provenance.stages, deliveryPlan.stages),
    "Provenance manifest stages do not exactly match the Firebase delivery plan.");

  const sourceConfig = readJson(path.join(sourceRoot, "firebase.json"), "source firebase config");
  const packagedConfig = readJson(path.join(packageDir, "firebase.json"), "packaged firebase config");
  const expectedConfig = createBoundedFirebaseConfig(
    sourceConfig,
    deliveryPlan.stages.map((stage) => STAGE_TO_PHASE[stage]),
  );
  assert(jsonEqual(packagedConfig, expectedConfig),
    "Packaged Firebase config is not the canonical no-predeploy projection of firebase.json.");
  assert(!JSON.stringify(packagedConfig).includes('"predeploy"'),
    "Packaged Firebase config must not contain predeploy hooks.");
  for (const forbidden of ["extensions", "remoteconfig", "hosting", "flutter"]) {
    assert(!(forbidden in packagedConfig),
      `Packaged Firebase config must not contain ${forbidden}.`);
  }

  const sourceFirebaseRc = readJson(path.join(sourceRoot, ".firebaserc"), "source Firebase aliases");
  const packagedFirebaseRc = readJson(path.join(packageDir, ".firebaserc"), "packaged Firebase aliases");
  assert(jsonEqual(packagedFirebaseRc, {projects: sourceFirebaseRc.projects}),
    "Packaged .firebaserc is not the exact bounded project-alias projection.");

  if (deliveryPlan.stages.includes("functions")) {
    const sourcePackage = readJson(
      path.join(sourceRoot, "functions/package.json"),
      "source Functions package",
    );
    const packagedPackage = readJson(
      path.join(packageDir, "functions/package.json"),
      "packaged Functions package",
    );
    assert(jsonEqual(packagedPackage, boundedFunctionsPackage(sourcePackage)),
      "Packaged Functions package.json is not the bounded lifecycle-safe projection.");
  }
  return deliveryPlan;
}

function parseArgs(argv) {
  const [command, ...rest] = argv;
  const values = {};
  for (let index = 0; index < rest.length; index += 2) {
    const flag = rest[index];
    const value = rest[index + 1];
    assert(flag?.startsWith("--") && value !== undefined,
      "Arguments must be supplied as --name value pairs.");
    assert(values[flag.slice(2)] === undefined, `Duplicate option ${flag}.`);
    values[flag.slice(2)] = value;
  }
  return {command, values};
}

function required(values, name) {
  assert(values[name], `Missing required option --${name}.`);
  return values[name];
}

function main() {
  const {command, values} = parseArgs(process.argv.slice(2));
  const sourceRoot = path.resolve(values["source-root"] ?? ".");
  let result;
  if (command === "prepare") {
    result = prepareFirebaseDelivery({
      sourceRoot,
      impactPlanPath: required(values, "impact-plan"),
      sourceSha: required(values, "source-sha"),
      baseSha: required(values, "base-sha"),
      sourceCiRunId: required(values, "ci-run-id"),
      sourceCiRunAttempt: required(values, "ci-run-attempt"),
      stageDir: required(values, "stage-dir"),
      functionsLibDir: values["functions-lib-dir"],
    });
  } else if (command === "verify") {
    result = verifyFirebaseDelivery({
      sourceRoot,
      packageDir: required(values, "package-dir"),
      sourceSha: required(values, "source-sha"),
      baseSha: required(values, "base-sha"),
      sourceCiRunId: required(values, "ci-run-id"),
      sourceCiRunAttempt: required(values, "ci-run-attempt"),
      provenanceManifestPath: required(values, "provenance-manifest"),
      allowRuntimeDependencies: values["allow-runtime-dependencies"] === "true",
      trustedPackageDir: values["trusted-package-dir"],
    });
  } else {
    throw new Error("Command must be prepare or verify.");
  }
  process.stdout.write(`${JSON.stringify({ok: true, ...result})}\n`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  try {
    main();
  } catch (error) {
    process.stderr.write(`${JSON.stringify({ok: false, message: error.message})}\n`);
    process.exitCode = 1;
  }
}
