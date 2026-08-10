#!/usr/bin/env node
import {createHash} from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {validateProvenanceManifest} from "./delivery_core.mjs";

export const WEB_HOSTING_DELIVERY_PLAN_SCHEMA =
  "catch.web-hosting-delivery-plan/v1";
export const WEB_HOSTING_DELIVERY_INVENTORY_SCHEMA =
  "catch.web-hosting-delivery-inventory/v1";

const SHA_RE = /^[0-9a-f]{40}$/u;
const DIGEST_RE = /^[0-9a-f]{64}$/u;
const DECIMAL_ID_RE = /^[1-9][0-9]*$/u;
const PROD_PROJECT_ID = "catch-dating-app-64e51";
const INVENTORY_FILE = "web-delivery-inventory.json";
const PLAN_FILE = "web-delivery-plan.json";

const SURFACES = Object.freeze({
  admin: Object.freeze({
    artifactName: "web-hosting-admin.tar.gz",
    publicDir: "admin/dist",
    site: "catchdates-admin",
    stage: "hosting-admin",
    target: "admin",
  }),
  host: Object.freeze({
    artifactName: "web-hosting-host.tar.gz",
    publicDir: "apps/host/build/web",
    site: "catchdates-host",
    stage: "hosting-host",
    target: "host",
  }),
  marketing: Object.freeze({
    artifactName: "web-hosting-marketing.tar.gz",
    publicDir: "website/dist",
    site: "catch-dating-app-64e51",
    stage: "hosting-marketing",
    target: "marketing",
  }),
});

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

function selectedSurface(value) {
  const config = SURFACES[value];
  assert(config, "surface must be exactly 'admin', 'host', or 'marketing'.");
  return {name: value, ...config};
}

function decimalIdentifier(value, label) {
  const normalized = typeof value === "number" && Number.isSafeInteger(value)
    ? String(value)
    : value;
  assert(typeof normalized === "string" && DECIMAL_ID_RE.test(normalized),
    `${label} must be a positive decimal identifier.`);
  return normalized;
}

function validateBinding({
  sourceSha,
  sourceCiWorkflowId,
  sourceCiRunNumber,
  sourceCiRunId,
  sourceCiRunAttempt,
}) {
  assert(typeof sourceSha === "string" && SHA_RE.test(sourceSha),
    "source SHA must be 40 lowercase hexadecimal characters.");
  return {
    sourceSha,
    sourceCiWorkflowId: decimalIdentifier(sourceCiWorkflowId, "source CI workflow id"),
    sourceCiRunNumber: decimalIdentifier(sourceCiRunNumber, "source CI run number"),
    sourceCiRunId: decimalIdentifier(sourceCiRunId, "source CI run id"),
    sourceCiRunAttempt: decimalIdentifier(sourceCiRunAttempt, "source CI run attempt"),
  };
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

function sha256(bytes) {
  return createHash("sha256").update(bytes).digest("hex");
}

function jsonEqual(left, right) {
  return JSON.stringify(left) === JSON.stringify(right);
}

function compareCodePointPaths(left, right) {
  if (left < right) return -1;
  if (left > right) return 1;
  return 0;
}

function assertNoSymlinkComponents(root, candidate) {
  const relative = path.relative(root, candidate);
  assert(relative !== "" && relative !== ".." && !relative.startsWith(`..${path.sep}`),
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
  const resolvedStage = path.resolve(stageDir);
  const buildRoot = path.join(resolvedSource, "build");
  assertNoSymlinkComponents(resolvedSource, resolvedStage);
  assert(resolvedStage.startsWith(`${buildRoot}${path.sep}`),
    "stageDir must be a fresh descendant of sourceRoot/build.");
  assert(!fs.existsSync(resolvedStage), "stageDir must not already exist.");
  fs.mkdirSync(path.dirname(resolvedStage), {recursive: true});
  assertNoSymlinkComponents(resolvedSource, path.dirname(resolvedStage));
  fs.mkdirSync(resolvedStage, {recursive: false, mode: 0o700});
  return {sourceRoot: resolvedSource, stageDir: resolvedStage};
}

function copyDirectoryStrict(sourceDir, destinationDir, label) {
  const sourceStat = fs.lstatSync(sourceDir);
  assert(sourceStat.isDirectory() && !sourceStat.isSymbolicLink(),
    `${label} must be a regular non-symlink directory.`);
  fs.mkdirSync(destinationDir, {recursive: true});
  let copiedFiles = 0;
  const visit = (source, destination, relative) => {
    const entries = fs.readdirSync(source, {withFileTypes: true})
      .sort((left, right) => left.name.localeCompare(right.name));
    for (const entry of entries) {
      const sourcePath = path.join(source, entry.name);
      const destinationPath = path.join(destination, entry.name);
      const entryLabel = `${label}/${relative ? `${relative}/` : ""}${entry.name}`;
      const stat = fs.lstatSync(sourcePath);
      assert(!stat.isSymbolicLink(), `${entryLabel} must not be a symlink.`);
      if (stat.isDirectory()) {
        fs.mkdirSync(destinationPath, {recursive: false});
        visit(sourcePath, destinationPath,
          relative ? `${relative}/${entry.name}` : entry.name);
      } else {
        assert(stat.isFile(), `${entryLabel} must be a regular file or directory.`);
        fs.copyFileSync(sourcePath, destinationPath);
        copiedFiles += 1;
      }
    }
  };
  visit(sourceDir, destinationDir, "");
  assert(copiedFiles > 0, `${label} must contain at least one file.`);
  return copiedFiles;
}

function normalizedInventoryPath(value) {
  assert(typeof value === "string" && value.length > 0,
    "Inventory paths must be non-empty strings.");
  assert(!value.includes("\\") && !path.posix.isAbsolute(value),
    `Inventory path must be package-relative POSIX syntax: ${value}`);
  const normalized = path.posix.normalize(value);
  assert(normalized === value && normalized !== "." && normalized !== ".." &&
    !normalized.startsWith("../"), `Inventory path escapes the package: ${value}`);
  return value;
}

function collectFiles(rootDir) {
  const rootStat = fs.lstatSync(rootDir);
  assert(rootStat.isDirectory() && !rootStat.isSymbolicLink(),
    `Web Hosting package must be a regular non-symlink directory: ${rootDir}`);
  const entries = [];
  const visit = (directory, relativeDirectory) => {
    for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
      const relativePath = relativeDirectory
        ? `${relativeDirectory}/${entry.name}`
        : entry.name;
      const filePath = path.join(directory, entry.name);
      const stat = fs.lstatSync(filePath);
      assert(!stat.isSymbolicLink(),
        `Web Hosting package must not contain symlinks: ${relativePath}`);
      if (stat.isDirectory()) {
        visit(filePath, relativePath);
      } else {
        assert(stat.isFile(),
          `Web Hosting package contains a non-regular entry: ${relativePath}`);
        if (relativePath !== INVENTORY_FILE) {
          const bytes = fs.readFileSync(filePath);
          entries.push({path: relativePath, sizeBytes: bytes.length, sha256: sha256(bytes)});
        }
      }
    }
  };
  visit(rootDir, "");
  return entries.sort((left, right) => compareCodePointPaths(left.path, right.path));
}

function validateInventory(value) {
  assertExactKeys(value, ["entries", "schema"], "web delivery inventory");
  assert(value.schema === WEB_HOSTING_DELIVERY_INVENTORY_SCHEMA,
    `Expected inventory schema ${WEB_HOSTING_DELIVERY_INVENTORY_SCHEMA}.`);
  assert(Array.isArray(value.entries), "web delivery inventory entries must be an array.");
  let previous = "";
  const entries = value.entries.map((entry, index) => {
    assertExactKeys(entry, ["path", "sha256", "sizeBytes"],
      `web delivery inventory entry ${index + 1}`);
    const entryPath = normalizedInventoryPath(entry.path);
    assert(compareCodePointPaths(entryPath, previous) > 0,
      "web delivery inventory entries must be unique and sorted by path.");
    previous = entryPath;
    assert(Number.isSafeInteger(entry.sizeBytes) && entry.sizeBytes >= 0,
      `Invalid size for web delivery inventory path: ${entryPath}`);
    assert(typeof entry.sha256 === "string" && DIGEST_RE.test(entry.sha256),
      `Invalid SHA-256 for web delivery inventory path: ${entryPath}`);
    return {...entry};
  });
  return {schema: WEB_HOSTING_DELIVERY_INVENTORY_SCHEMA, entries};
}

function writeInventory(stageDir) {
  const inventory = validateInventory({
    schema: WEB_HOSTING_DELIVERY_INVENTORY_SCHEMA,
    entries: collectFiles(stageDir),
  });
  writeJson(path.join(stageDir, INVENTORY_FILE), inventory);
  return inventory;
}

function verifyInventory(packageDir) {
  const inventory = validateInventory(readJson(
    path.join(packageDir, INVENTORY_FILE),
    "web delivery inventory",
  ));
  assert(jsonEqual(collectFiles(packageDir), inventory.entries),
    "Web Hosting package contents do not match the delivery inventory.");
  return inventory;
}

function sourceHostingTarget(sourceConfig, surface) {
  assertObject(sourceConfig, "firebase.json");
  assert(Array.isArray(sourceConfig.hosting), "firebase.json hosting must be an array.");
  const matches = sourceConfig.hosting.filter((entry) => entry?.target === surface.target);
  assert(matches.length === 1,
    `firebase.json must contain exactly one '${surface.target}' Hosting target.`);
  const target = structuredClone(matches[0]);
  assertObject(target, `firebase.json ${surface.target} Hosting target`);
  assert(target.public === surface.publicDir,
    `firebase.json ${surface.target}.public must be '${surface.publicDir}'.`);
  delete target.predeploy;
  delete target.postdeploy;
  target.public = "site";
  return target;
}

export function createBoundedWebHostingConfig(sourceConfig, surfaceName) {
  const surface = selectedSurface(surfaceName);
  return {hosting: [sourceHostingTarget(sourceConfig, surface)]};
}

function boundedFirebaseRc(sourceRc, surface) {
  assertObject(sourceRc, ".firebaserc");
  assertObject(sourceRc.projects, ".firebaserc projects");
  const projectId = sourceRc.projects.prod;
  assert(projectId === PROD_PROJECT_ID,
    `.firebaserc projects.prod must be exactly '${PROD_PROJECT_ID}'.`);
  const targetSites = sourceRc.targets?.[projectId]?.hosting?.[surface.target];
  assert(Array.isArray(targetSites) && targetSites.length === 1 &&
    targetSites[0] === surface.site,
  `.firebaserc must bind '${surface.target}' exactly to Hosting site '${surface.site}'.`);
  return {
    projects: {prod: projectId},
    targets: {
      [projectId]: {
        hosting: {[surface.target]: [...targetSites]},
      },
    },
  };
}

function siteMetrics(entries) {
  const siteEntries = entries.filter((entry) => entry.path.startsWith("site/"));
  assert(siteEntries.length > 0, "Web Hosting package must contain at least one site file.");
  return {
    siteEntryCount: siteEntries.length,
    siteBytes: siteEntries.reduce((total, entry) => total + entry.sizeBytes, 0),
  };
}

function validatePlan(value) {
  assertExactKeys(value, [
    "firebaseConfigSha256",
    "firebaseRcSha256",
    "hostingTarget",
    "projectId",
    "schema",
    "siteBytes",
    "siteEntryCount",
    "sourceCiRunAttempt",
    "sourceCiRunId",
    "sourceCiRunNumber",
    "sourceCiWorkflowId",
    "sourceSha",
    "stage",
    "surface",
  ], "web delivery plan");
  assert(value.schema === WEB_HOSTING_DELIVERY_PLAN_SCHEMA,
    `Expected web delivery plan schema ${WEB_HOSTING_DELIVERY_PLAN_SCHEMA}.`);
  const surface = selectedSurface(value.surface);
  const binding = validateBinding(value);
  assert(value.hostingTarget === surface.target,
    "Web delivery plan target does not match its surface.");
  assert(value.stage === surface.stage,
    "Web delivery plan stage does not match its surface.");
  assert(value.projectId === PROD_PROJECT_ID,
    `Web delivery plan projectId must be exactly '${PROD_PROJECT_ID}'.`);
  for (const field of ["firebaseConfigSha256", "firebaseRcSha256"]) {
    assert(typeof value[field] === "string" && DIGEST_RE.test(value[field]),
      `Web delivery plan ${field} must be a SHA-256 digest.`);
  }
  assert(Number.isSafeInteger(value.siteEntryCount) && value.siteEntryCount > 0,
    "Web delivery plan siteEntryCount must be a positive safe integer.");
  assert(Number.isSafeInteger(value.siteBytes) && value.siteBytes > 0,
    "Web delivery plan siteBytes must be a positive safe integer.");
  return {...value, ...binding};
}

export function prepareWebHostingDelivery({
  sourceRoot,
  surface: surfaceName,
  sourceSha,
  sourceCiWorkflowId,
  sourceCiRunNumber,
  sourceCiRunId,
  sourceCiRunAttempt,
  stageDir,
}) {
  const surface = selectedSurface(surfaceName);
  const binding = validateBinding({
    sourceSha,
    sourceCiWorkflowId,
    sourceCiRunNumber,
    sourceCiRunId,
    sourceCiRunAttempt,
  });
  const prepared = createFreshStage(sourceRoot, stageDir);
  const sourcePublicDir = path.join(prepared.sourceRoot, surface.publicDir);
  assertNoSymlinkComponents(prepared.sourceRoot, sourcePublicDir);
  copyDirectoryStrict(sourcePublicDir, path.join(prepared.stageDir, "site"),
    `${surface.name} deployable build`);

  const sourceConfig = readJson(
    path.join(prepared.sourceRoot, "firebase.json"),
    "source Firebase config",
  );
  const packagedConfig = createBoundedWebHostingConfig(sourceConfig, surface.name);
  const sourceRc = readJson(
    path.join(prepared.sourceRoot, ".firebaserc"),
    "source Firebase aliases",
  );
  const packagedRc = boundedFirebaseRc(sourceRc, surface);
  writeJson(path.join(prepared.stageDir, "firebase.json"), packagedConfig);
  writeJson(path.join(prepared.stageDir, ".firebaserc"), packagedRc);

  const preliminaryEntries = collectFiles(prepared.stageDir);
  const metrics = siteMetrics(preliminaryEntries);
  const plan = validatePlan({
    schema: WEB_HOSTING_DELIVERY_PLAN_SCHEMA,
    surface: surface.name,
    hostingTarget: surface.target,
    projectId: packagedRc.projects.prod,
    stage: surface.stage,
    ...binding,
    firebaseConfigSha256: sha256(readRegularBytes(
      path.join(prepared.stageDir, "firebase.json"),
      "packaged Firebase config",
    )),
    firebaseRcSha256: sha256(readRegularBytes(
      path.join(prepared.stageDir, ".firebaserc"),
      "packaged Firebase aliases",
    )),
    ...metrics,
  });
  writeJson(path.join(prepared.stageDir, PLAN_FILE), plan);
  writeInventory(prepared.stageDir);
  return plan;
}

export function verifyWebHostingDelivery({
  sourceRoot,
  packageDir,
  surface: surfaceName,
  sourceSha,
  sourceCiWorkflowId,
  sourceCiRunNumber,
  sourceCiRunId,
  sourceCiRunAttempt,
  provenanceManifestPath,
}) {
  const surface = selectedSurface(surfaceName);
  const binding = validateBinding({
    sourceSha,
    sourceCiWorkflowId,
    sourceCiRunNumber,
    sourceCiRunId,
    sourceCiRunAttempt,
  });
  const inventory = verifyInventory(packageDir);
  const plan = validatePlan(readJson(path.join(packageDir, PLAN_FILE), "web delivery plan"));
  for (const [key, expected] of Object.entries(binding)) {
    assert(plan[key] === expected,
      `Web delivery plan ${key} does not match the expected delivery binding.`);
  }
  assert(plan.surface === surface.name && plan.hostingTarget === surface.target &&
    plan.stage === surface.stage,
  "Web delivery plan does not match the requested surface.");
  assert(jsonEqual(siteMetrics(inventory.entries), {
    siteEntryCount: plan.siteEntryCount,
    siteBytes: plan.siteBytes,
  }), "Web delivery plan site metrics do not match the packaged bytes.");

  const sourceConfig = readJson(path.join(sourceRoot, "firebase.json"),
    "source Firebase config");
  const packagedConfigPath = path.join(packageDir, "firebase.json");
  const packagedConfig = readJson(packagedConfigPath, "packaged Firebase config");
  assert(jsonEqual(packagedConfig, createBoundedWebHostingConfig(sourceConfig, surface.name)),
    "Packaged Firebase config is not the canonical single-target lifecycle-hook-free projection.");
  const packagedConfigSource = JSON.stringify(packagedConfig);
  assert(!packagedConfigSource.includes('"predeploy"'),
    "Packaged Firebase config must not contain predeploy hooks.");
  assert(!packagedConfigSource.includes('"postdeploy"'),
    "Packaged Firebase config must not contain postdeploy hooks.");
  assert(Object.keys(packagedConfig).length === 1 && packagedConfig.hosting.length === 1,
    "Packaged Firebase config must contain exactly one Hosting target.");
  assert(sha256(readRegularBytes(packagedConfigPath, "packaged Firebase config")) ===
    plan.firebaseConfigSha256,
  "Packaged Firebase config digest does not match the web delivery plan.");

  const sourceRc = readJson(path.join(sourceRoot, ".firebaserc"), "source Firebase aliases");
  const packagedRcPath = path.join(packageDir, ".firebaserc");
  const packagedRc = readJson(packagedRcPath, "packaged Firebase aliases");
  assert(jsonEqual(packagedRc, boundedFirebaseRc(sourceRc, surface)),
    "Packaged .firebaserc is not the exact production target projection.");
  assert(packagedRc.projects.prod === plan.projectId,
    "Packaged production project does not match the web delivery plan.");
  assert(sha256(readRegularBytes(packagedRcPath, "packaged Firebase aliases")) ===
    plan.firebaseRcSha256,
  "Packaged Firebase alias digest does not match the web delivery plan.");

  assert(provenanceManifestPath,
    "provenanceManifestPath is required for combined adapter verification.");
  const provenance = validateProvenanceManifest(readJson(
    provenanceManifestPath,
    "web delivery provenance manifest",
  ));
  assert(provenance.sourceSha === binding.sourceSha,
    "Provenance manifest source SHA does not match the web delivery plan.");
  assert(provenance.sourceCiRunId === binding.sourceCiRunId,
    "Provenance manifest CI run id does not match the web delivery plan.");
  assert(provenance.sourceCiRunAttempt === binding.sourceCiRunAttempt,
    "Provenance manifest CI run attempt does not match the web delivery plan.");
  assert(jsonEqual(provenance.stages, [surface.stage]),
    "Provenance stages do not exactly match the Web Hosting target.");
  assert(provenance.artifact.name === surface.artifactName,
    "Provenance artifact basename does not match the Web Hosting surface.");
  return plan;
}

function parseArgs(argv) {
  const [command, ...rest] = argv;
  const values = {};
  for (let index = 0; index < rest.length; index += 2) {
    const flag = rest[index];
    const value = rest[index + 1];
    assert(flag?.startsWith("--") && value !== undefined && !value.startsWith("--"),
      "Arguments must be supplied as --name value pairs.");
    const name = flag.slice(2);
    assert(values[name] === undefined, `Duplicate option ${flag}.`);
    values[name] = value;
  }
  return {command, values};
}

function required(values, name) {
  assert(values[name], `Missing required option --${name}.`);
  return values[name];
}

function main() {
  const {command, values} = parseArgs(process.argv.slice(2));
  const common = {
    sourceRoot: path.resolve(values["source-root"] ?? "."),
    surface: required(values, "surface"),
    sourceSha: required(values, "source-sha"),
    sourceCiWorkflowId: required(values, "ci-workflow-id"),
    sourceCiRunNumber: required(values, "ci-run-number"),
    sourceCiRunId: required(values, "ci-run-id"),
    sourceCiRunAttempt: required(values, "ci-run-attempt"),
  };
  let result;
  if (command === "prepare") {
    result = prepareWebHostingDelivery({
      ...common,
      stageDir: required(values, "stage-dir"),
    });
  } else if (command === "verify") {
    result = verifyWebHostingDelivery({
      ...common,
      packageDir: required(values, "package-dir"),
      provenanceManifestPath: required(values, "provenance-manifest"),
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
