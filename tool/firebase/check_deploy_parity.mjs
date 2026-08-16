#!/usr/bin/env node
/**
 * Compare the repository's Firebase Functions and declared secrets with one
 * live Firebase environment. Environment-only Functions are intentionally
 * ignored because installed Firebase Extensions own legitimate extra exports.
 *
 * This command is metadata-only. It never reads secret payloads.
 *
 *   node tool/firebase/check_deploy_parity.mjs --env prod
 *   node tool/firebase/check_deploy_parity.mjs --env staging --json
 */

import {spawnSync} from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import {fileURLToPath} from "node:url";

import {
  discoverDefineSecretNames,
  parseFirebaseFunctionTargets,
  parseFirebaseProjectAliases,
  resolveFirebaseProjectId,
} from "./check_environment_readiness.mjs";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const defaultRepoRoot = path.resolve(toolDir, "../..");
const commandTimeoutMs = 120_000;

export class DeployParityUsageError extends Error {
  constructor(message) {
    super(message);
    this.name = "DeployParityUsageError";
    this.exitCode = 64;
  }
}

export class DeployParityMetadataError extends Error {
  constructor(message) {
    super(message);
    this.name = "DeployParityMetadataError";
    this.exitCode = 2;
  }
}

function requireValue(argv, index, option) {
  const value = argv[index];
  if (!value || value.startsWith("--")) {
    throw new DeployParityUsageError(`${option} requires a value.`);
  }
  return value;
}

export function parseArgs(argv) {
  const parsed = {
    environment: null,
    help: false,
    json: false,
    repoRoot: defaultRepoRoot,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--env") {
      parsed.environment = requireValue(argv, ++index, arg);
    } else if (arg === "--repo-root") {
      parsed.repoRoot = path.resolve(requireValue(argv, ++index, arg));
    } else if (arg === "--json") {
      parsed.json = true;
    } else if (arg === "--help" || arg === "-h") {
      parsed.help = true;
    } else {
      throw new DeployParityUsageError(`Unknown argument: ${arg}`);
    }
  }
  if (!parsed.help && !parsed.environment) {
    throw new DeployParityUsageError("--env <environment> is required.");
  }
  return parsed;
}

function readUtf8(filePath, label) {
  try {
    return fs.readFileSync(filePath, "utf8");
  } catch (error) {
    throw new DeployParityUsageError(
      `Could not read ${label}: ${error.message}`,
    );
  }
}

function collectTypeScriptSources(directory, repoRoot, sources = []) {
  let entries;
  try {
    entries = fs.readdirSync(directory, {withFileTypes: true});
  } catch (error) {
    throw new DeployParityUsageError(
      `Could not inspect ${path.relative(repoRoot, directory)}: ${error.message}`,
    );
  }
  for (const entry of entries) {
    const entryPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      collectTypeScriptSources(entryPath, repoRoot, sources);
    } else if (entry.isFile() && entry.name.endsWith(".ts")) {
      sources.push({
        contents: readUtf8(entryPath, path.relative(repoRoot, entryPath)),
        path: path.relative(repoRoot, entryPath),
      });
    }
  }
  return sources;
}

export function loadRepositoryInventory(repoRoot) {
  const indexPath = path.join(repoRoot, "functions/src/index.ts");
  const functionsSourceRoot = path.join(repoRoot, "functions/src");
  const functionTargets = parseFirebaseFunctionTargets(
    readUtf8(indexPath, "functions/src/index.ts"),
  );
  const discovery = discoverDefineSecretNames(
    collectTypeScriptSources(functionsSourceRoot, repoRoot),
  );
  if (discovery.unsupported.length > 0) {
    throw new DeployParityUsageError(
      "Every defineSecret declaration must use a literal name; unsupported " +
      `declarations: ${discovery.unsupported.sort().join(", ")}.`,
    );
  }
  return {
    functionNames: new Set(
      [...functionTargets].map((target) => target.replace(/^functions:/u, "")),
    ),
    secretNames: discovery.names,
  };
}

export function buildFunctionsListCommand(projectId) {
  return {
    command: "firebase",
    args: ["functions:list", "--project", projectId, "--json"],
  };
}

export function buildSecretsListCommand(projectId) {
  return {
    command: "gcloud",
    args: [
      "secrets",
      "list",
      `--project=${projectId}`,
      "--format=json(name)",
      "--quiet",
    ],
  };
}

function defaultRunCommand({command, args}) {
  const result = spawnSync(command, args, {
    encoding: "utf8",
    env: {...process.env, NO_UPDATE_NOTIFIER: "1"},
    maxBuffer: 32 * 1024 * 1024,
    timeout: commandTimeoutMs,
  });
  return {
    error: result.error,
    status: result.status,
    stderr: result.stderr ?? "",
    stdout: result.stdout ?? "",
  };
}

function requireSuccessfulCommand(result, label) {
  if (result?.status === 0 && !result.error) return result.stdout;
  const detail = result?.error?.message ||
    result?.stderr?.trim().split("\n")[0] ||
    `exit ${result?.status ?? "unknown"}`;
  throw new DeployParityMetadataError(`${label} failed: ${detail}`);
}

function parseJson(contents, label) {
  try {
    return JSON.parse(contents);
  } catch {
    throw new DeployParityMetadataError(`${label} returned malformed JSON.`);
  }
}

export function parseDeployedFunctionNames(contents) {
  const parsed = parseJson(contents, "firebase functions:list");
  if (parsed?.status !== "success" || !Array.isArray(parsed.result)) {
    throw new DeployParityMetadataError(
      "firebase functions:list did not return a successful function inventory.",
    );
  }
  const names = new Set();
  for (const entry of parsed.result) {
    if (typeof entry?.id !== "string" || entry.id.trim() === "") {
      throw new DeployParityMetadataError(
        "firebase functions:list returned a function without an id.",
      );
    }
    names.add(entry.id);
  }
  return names;
}

export function parseLiveSecretNames(contents) {
  const parsed = parseJson(contents, "gcloud secrets list");
  if (!Array.isArray(parsed)) {
    throw new DeployParityMetadataError(
      "gcloud secrets list did not return a secret inventory.",
    );
  }
  const names = new Set();
  for (const entry of parsed) {
    const match = typeof entry?.name === "string" ?
      entry.name.match(/\/secrets\/([A-Z][A-Z0-9_]*)$/u) : null;
    if (!match) {
      throw new DeployParityMetadataError(
        "gcloud secrets list returned an invalid secret resource name.",
      );
    }
    names.add(match[1]);
  }
  return names;
}

export function compareDeployParity({
  declaredSecretNames,
  deployedFunctionNames,
  liveSecretNames,
  repoFunctionNames,
}) {
  const missingFunctions = [...repoFunctionNames]
    .filter((name) => !deployedFunctionNames.has(name))
    .sort();
  const missingSecrets = [...declaredSecretNames]
    .filter((name) => !liveSecretNames.has(name))
    .sort();
  const environmentOnlyFunctionCount = [...deployedFunctionNames]
    .filter((name) => !repoFunctionNames.has(name)).length;
  return {
    ok: missingFunctions.length === 0 && missingSecrets.length === 0,
    missingFunctions,
    missingSecrets,
    repoFunctionCount: repoFunctionNames.size,
    deployedFunctionCount: deployedFunctionNames.size,
    declaredSecretCount: declaredSecretNames.size,
    liveSecretCount: liveSecretNames.size,
    environmentOnlyFunctionCount,
  };
}

export function runDeployParity({
  environment,
  repoRoot = defaultRepoRoot,
  runCommand = defaultRunCommand,
}) {
  const aliases = parseFirebaseProjectAliases(
    readUtf8(path.join(repoRoot, ".firebaserc"), ".firebaserc"),
  );
  const projectId = resolveFirebaseProjectId({environment, aliases});
  const repository = loadRepositoryInventory(repoRoot);
  const deployedFunctionNames = parseDeployedFunctionNames(
    requireSuccessfulCommand(
      runCommand(buildFunctionsListCommand(projectId)),
      "Firebase Function inventory",
    ),
  );
  const liveSecretNames = parseLiveSecretNames(
    requireSuccessfulCommand(
      runCommand(buildSecretsListCommand(projectId)),
      "Secret Manager inventory",
    ),
  );
  return {
    environment,
    projectId,
    ...compareDeployParity({
      declaredSecretNames: repository.secretNames,
      deployedFunctionNames,
      liveSecretNames,
      repoFunctionNames: repository.functionNames,
    }),
  };
}

export function formatReport(report) {
  const lines = [
    `${report.ok ? "PASS" : "FAIL"} deploy parity for ` +
      `${report.environment}: ${report.projectId}`,
    `  Functions: ${report.repoFunctionCount} repo export(s), ` +
      `${report.deployedFunctionCount} deployed, ` +
      `${report.environmentOnlyFunctionCount} environment-only ignored`,
    `  Secrets: ${report.declaredSecretCount} defineSecret name(s), ` +
      `${report.liveSecretCount} present`,
  ];
  if (report.missingFunctions.length > 0) {
    lines.push(`  Missing Functions: ${report.missingFunctions.join(", ")}`);
  }
  if (report.missingSecrets.length > 0) {
    lines.push(`  Missing secrets: ${report.missingSecrets.join(", ")}`);
  }
  return lines.join("\n");
}

function usage() {
  return [
    "Usage: node tool/firebase/check_deploy_parity.mjs " +
      "--env <dev|staging|prod> [options]",
    "",
    "Options:",
    "  --repo-root <path>  Read exports and defineSecret declarations here.",
    "  --json              Emit a machine-readable report.",
    "  --help              Show this help.",
  ].join("\n");
}

function main() {
  try {
    const options = parseArgs(process.argv.slice(2));
    if (options.help) {
      console.log(usage());
      return;
    }
    const report = runDeployParity(options);
    console.log(
      options.json ? JSON.stringify(report, null, 2) : formatReport(report),
    );
    if (!report.ok) process.exitCode = 1;
  } catch (error) {
    console.error(error.message);
    process.exitCode = error.exitCode ?? 2;
  }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) main();
