#!/usr/bin/env node
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath, pathToFileURL} from "node:url";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const defaultRepoRoot = path.resolve(toolDir, "../..");
const supportedRequirementKinds = new Set([
  "secret-version",
  "firestore-ttl",
]);
const deployTargetPattern = /^[A-Za-z0-9_.-]+(?::[A-Za-z0-9_.-]+)*$/u;
const capabilityPattern = /^[a-z][a-z0-9-]*$/u;
const secretNamePattern = /^[A-Z][A-Z0-9_]*$/u;
const resourceNamePattern = /^[A-Za-z][A-Za-z0-9_-]*$/u;
const projectIdPattern = /^[a-z][a-z0-9-]{4,28}[a-z0-9]$/u;
const metadataCommandTimeoutMs = 15_000;

export class ReadinessUsageError extends Error {
  constructor(message) {
    super(message);
    this.name = "ReadinessUsageError";
    this.exitCode = 64;
  }
}

export function parseArgs(argv) {
  const parsed = {
    all: false,
    capabilities: [],
    environment: null,
    help: false,
    json: false,
    manifestOnly: false,
    targets: [],
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--all") parsed.all = true;
    else if (arg === "--env") {
      parsed.environment = requireValue(argv, ++index, arg);
    } else if (arg === "--targets") {
      parsed.targets.push(...parseCsv(requireValue(argv, ++index, arg), arg));
    } else if (arg === "--capability" || arg === "--capabilities") {
      parsed.capabilities.push(
        ...parseCsv(requireValue(argv, ++index, arg), arg),
      );
    } else if (arg === "--manifest-only") parsed.manifestOnly = true;
    else if (arg === "--json") parsed.json = true;
    else if (arg === "--help" || arg === "-h") parsed.help = true;
    else throw new ReadinessUsageError(`Unknown argument: ${arg}`);
  }

  parsed.targets = [...new Set(parsed.targets)].sort();
  parsed.capabilities = [...new Set(parsed.capabilities)].sort();
  if (parsed.help) return parsed;

  for (const target of parsed.targets) {
    if (!deployTargetPattern.test(target)) {
      throw new ReadinessUsageError(`Invalid deploy target: ${target}`);
    }
  }
  for (const capability of parsed.capabilities) {
    if (!capabilityPattern.test(capability)) {
      throw new ReadinessUsageError(`Invalid capability: ${capability}`);
    }
  }

  if (parsed.manifestOnly) {
    if (parsed.all || parsed.environment || parsed.targets.length > 0 ||
        parsed.capabilities.length > 0) {
      throw new ReadinessUsageError(
        "--manifest-only cannot be combined with live environment selectors.",
      );
    }
    return parsed;
  }
  if (parsed.all === Boolean(parsed.environment)) {
    throw new ReadinessUsageError(
      "Choose exactly one of --env <environment> or --all.",
    );
  }
  if (parsed.targets.length === 0 && parsed.capabilities.length === 0) {
    throw new ReadinessUsageError(
      "Live readiness requires --targets and/or --capabilities.",
    );
  }
  return parsed;
}

export function validateEnvironmentReadinessManifest(
  manifest,
  {
    discoveredSecrets,
    functionTargets,
    sourcePathExists,
    unsupportedSecretDeclarations = [],
  } = {},
) {
  const errors = [];
  const manifestEnvironments = Array.isArray(manifest?.environments)
    ? manifest.environments
    : [];
  const requirements = Array.isArray(manifest?.requirements)
    ? manifest.requirements
    : [];
  const selectorDeployTargets = manifest?.selectors?.deployTargets;
  const selectorCapabilities = manifest?.selectors?.capabilities;
  if (manifest?.version !== 1) {
    errors.push("version must be 1.");
  }
  if (manifestEnvironments.length === 0) {
    errors.push("environments must be a non-empty array.");
  }
  const environments = new Set(manifestEnvironments);
  if (environments.size !== manifestEnvironments.length) {
    errors.push("environments must not contain duplicates.");
  }
  for (const environment of environments) {
    if (typeof environment !== "string" ||
        !capabilityPattern.test(environment)) {
      errors.push(`invalid environment: ${environment}.`);
    }
  }
  if (requirements.length === 0) {
    errors.push("requirements must be a non-empty array.");
  }
  validateStringArray({
    errors,
    key: "selectors.deployTargets",
    label: "manifest",
    value: selectorDeployTargets,
  });
  validateStringArray({
    errors,
    key: "selectors.capabilities",
    label: "manifest",
    value: selectorCapabilities,
  });
  const knownDeployTargets = new Set(selectorDeployTargets ?? []);
  const knownCapabilities = new Set(selectorCapabilities ?? []);
  for (const target of knownDeployTargets) {
    if (!deployTargetPattern.test(target)) {
      errors.push(`manifest: invalid deploy selector ${target}.`);
    }
  }
  for (const capability of knownCapabilities) {
    if (!capabilityPattern.test(capability)) {
      errors.push(`manifest: invalid capability selector ${capability}.`);
    }
  }

  const ids = new Set();
  const manifestSecrets = new Set();
  for (const requirement of requirements) {
    const label = requirement?.id ?? "<missing id>";
    if (!requirement || typeof requirement !== "object") {
      errors.push("every requirement must be an object.");
      continue;
    }
    if (typeof requirement.id !== "string" || requirement.id.trim() === "") {
      errors.push(`${label}: id is required.`);
    } else if (ids.has(requirement.id)) {
      errors.push(`${label}: duplicate id.`);
    }
    ids.add(requirement.id);
    if (!supportedRequirementKinds.has(requirement.kind)) {
      errors.push(`${label}: unsupported kind ${requirement.kind}.`);
    }
    const requirementEnvironments = Array.isArray(requirement.environments)
      ? requirement.environments
      : [];
    const acceptedStates = Array.isArray(requirement.acceptedStates)
      ? requirement.acceptedStates
      : [];
    const sourcePaths = Array.isArray(requirement.sourcePaths)
      ? requirement.sourcePaths
      : [];
    validateStringArray({
      errors,
      key: "environments",
      label,
      value: requirement.environments,
    });
    for (const environment of requirementEnvironments) {
      if (!environments.has(environment)) {
        errors.push(`${label}: unknown environment ${environment}.`);
      }
    }
    validateStringArray({
      errors,
      key: "acceptedStates",
      label,
      value: requirement.acceptedStates,
    });
    validateStringArray({
      errors,
      key: "sourcePaths",
      label,
      value: requirement.sourcePaths,
    });
    if (typeof requirement.owner !== "string" ||
        requirement.owner.trim() === "") {
      errors.push(`${label}: owner is required.`);
    }
    for (const sourcePath of sourcePaths) {
      if (typeof sourcePath !== "string") continue;
      if (path.isAbsolute(sourcePath) || sourcePath.split(/[\\/]/u).includes("..")) {
        errors.push(`${label}: source path must stay inside the repo: ${sourcePath}.`);
      } else if (sourcePathExists && !sourcePathExists(sourcePath)) {
        errors.push(`${label}: source path does not exist: ${sourcePath}.`);
      }
    }

    const requiredWhen = requirement.requiredWhen;
    if (!requiredWhen || typeof requiredWhen !== "object") {
      errors.push(`${label}: requiredWhen is required.`);
    } else {
      const deployTargets = Array.isArray(requiredWhen.anyDeployTarget)
        ? requiredWhen.anyDeployTarget
        : [];
      const capabilities = Array.isArray(requiredWhen.anyCapability)
        ? requiredWhen.anyCapability
        : [];
      if (requiredWhen.anyDeployTarget != null) {
        validateStringArray({
          errors,
          key: "requiredWhen.anyDeployTarget",
          label,
          value: deployTargets,
        });
      }
      if (requiredWhen.anyCapability != null) {
        validateStringArray({
          errors,
          key: "requiredWhen.anyCapability",
          label,
          value: capabilities,
        });
      }
      if (deployTargets.length === 0 && capabilities.length === 0) {
        errors.push(`${label}: requiredWhen must select a target or capability.`);
      }
      for (const target of deployTargets) {
        if (typeof target !== "string" || !deployTargetPattern.test(target)) {
          errors.push(`${label}: invalid deploy target ${target}.`);
        } else if (target.startsWith("functions:") &&
            functionTargets && !functionTargets.has(target)) {
          errors.push(`${label}: Function target is not exported: ${target}.`);
        } else if (!target.startsWith("functions:") &&
            !knownDeployTargets.has(target)) {
          errors.push(`${label}: undeclared deploy selector ${target}.`);
        }
      }
      for (const capability of capabilities) {
        if (typeof capability !== "string" ||
            !capabilityPattern.test(capability)) {
          errors.push(`${label}: invalid capability ${capability}.`);
        } else if (!knownCapabilities.has(capability)) {
          errors.push(`${label}: undeclared capability selector ${capability}.`);
        }
      }
    }

    if (requirement.kind === "secret-version") {
      if (!secretNamePattern.test(requirement.name ?? "")) {
        errors.push(`${label}: invalid secret name.`);
      } else if (manifestSecrets.has(requirement.name)) {
        errors.push(`${label}: duplicate secret ${requirement.name}.`);
      }
      manifestSecrets.add(requirement.name);
      if (acceptedStates.length !== 1 || acceptedStates[0] !== "ENABLED") {
        errors.push(`${label}: secret versions must accept only ENABLED.`);
      }
    } else if (requirement.kind === "firestore-ttl") {
      if (!resourceNamePattern.test(requirement.collectionGroup ?? "")) {
        errors.push(`${label}: invalid collectionGroup.`);
      }
      if (!resourceNamePattern.test(requirement.field ?? "")) {
        errors.push(`${label}: invalid TTL field.`);
      }
      if (acceptedStates.length !== 1 || acceptedStates[0] !== "ACTIVE") {
        errors.push(`${label}: Firestore TTL must accept only ACTIVE.`);
      }
    }
  }

  for (const sourcePath of unsupportedSecretDeclarations) {
    errors.push(
      `defineSecret must use a literal name for offline discovery: ${sourcePath}.`,
    );
  }
  if (discoveredSecrets) {
    for (const secret of [...discoveredSecrets].sort()) {
      if (!manifestSecrets.has(secret)) {
        errors.push(`defineSecret is missing from the manifest: ${secret}.`);
      }
    }
    for (const secret of [...manifestSecrets].sort()) {
      if (!discoveredSecrets.has(secret)) {
        errors.push(`manifest secret is not declared with defineSecret: ${secret}.`);
      }
    }
  }

  if (errors.length > 0) {
    throw new ReadinessUsageError(
      `Environment readiness manifest is invalid:\n- ${errors.join("\n- ")}`,
    );
  }
  return manifest;
}

export function discoverDefineSecretNames(sources) {
  const names = new Set();
  const unsupported = [];
  for (const source of sources) {
    const allCalls = [...source.contents.matchAll(/\bdefineSecret\s*\(/gu)];
    const literalCalls = [
      ...source.contents.matchAll(
        /\bdefineSecret\s*\(\s*(["'])([A-Z][A-Z0-9_]*)\1\s*\)/gu,
      ),
    ];
    if (allCalls.length !== literalCalls.length) unsupported.push(source.path);
    for (const match of literalCalls) names.add(match[2]);
  }
  return {names, unsupported};
}

export function parseFirebaseFunctionTargets(indexSource) {
  const targets = new Set();
  for (const match of indexSource.matchAll(
    /export\s*\{([\s\S]*?)\}\s*from\s*["']/gu,
  )) {
    for (const rawPart of match[1].split(",")) {
      const part = rawPart.trim();
      if (!part) continue;
      const alias = part.match(/\s+as\s+([A-Za-z_$][\w$]*)$/u)?.[1];
      const name = alias ?? part.match(/^([A-Za-z_$][\w$]*)/u)?.[1];
      if (!name) {
        throw new ReadinessUsageError(
          `Could not parse Firebase Function export: ${part}.`,
        );
      }
      targets.add(`functions:${name}`);
    }
  }
  if (targets.size === 0) {
    throw new ReadinessUsageError("No Firebase Function exports were found.");
  }
  return targets;
}

export function parseFirebaseProjectAliases(contents) {
  let parsed;
  try {
    parsed = JSON.parse(contents);
  } catch {
    throw new ReadinessUsageError(".firebaserc is not valid JSON.");
  }
  if (!parsed.projects || typeof parsed.projects !== "object") {
    throw new ReadinessUsageError(".firebaserc does not declare projects.");
  }
  return parsed.projects;
}

export function resolveFirebaseProjectId({environment, aliases}) {
  const projectId = aliases[environment];
  if (typeof projectId !== "string" || !projectIdPattern.test(projectId)) {
    throw new ReadinessUsageError(
      `No valid Firebase project alias found for environment: ${environment}.`,
    );
  }
  return projectId;
}

export function selectReadinessRequirements({
  capabilities = [],
  environment,
  manifest,
  targets = [],
}) {
  const selectedTargets = new Set(targets);
  const selectedCapabilities = new Set(capabilities);
  return manifest.requirements
    .filter((requirement) => requirement.environments.includes(environment))
    .filter((requirement) => {
      const targetMatch = (requirement.requiredWhen.anyDeployTarget ?? [])
        .some((target) => targetMatches(target, selectedTargets));
      const capabilityMatch = (requirement.requiredWhen.anyCapability ?? [])
        .some((capability) => selectedCapabilities.has(capability));
      return targetMatch || capabilityMatch;
    })
    .sort((left, right) => left.id.localeCompare(right.id));
}

export function validateReadinessSelectors({
  capabilities = [],
  functionTargets,
  manifest,
  targets = [],
}) {
  const knownTargets = new Set(manifest.selectors.deployTargets);
  const knownCapabilities = new Set(manifest.selectors.capabilities);
  for (const target of targets) {
    if (target.startsWith("functions:")) {
      if (!functionTargets.has(target)) {
        throw new ReadinessUsageError(
          `Unknown Firebase Function deploy target: ${target}.`,
        );
      }
    } else if (!knownTargets.has(target)) {
      throw new ReadinessUsageError(
        `Unknown Firebase deploy target: ${target}.`,
      );
    }
  }
  for (const capability of capabilities) {
    if (!knownCapabilities.has(capability)) {
      throw new ReadinessUsageError(
        `Unknown environment capability: ${capability}.`,
      );
    }
  }
}

export function buildProjectIdentityCommand(projectId) {
  validateProjectId(projectId);
  return metadataOnlyCommand([
    "projects",
    "describe",
    projectId,
    "--format=json(projectId,lifecycleState)",
    "--quiet",
  ]);
}

export function buildRequirementCommand({projectId, requirement}) {
  validateProjectId(projectId);
  let args;
  if (requirement.kind === "secret-version") {
    args = [
      "secrets",
      "versions",
      "list",
      requirement.name,
      `--project=${projectId}`,
      "--filter=state=ENABLED",
      "--limit=1",
      "--format=json(state)",
      "--quiet",
    ];
  } else if (requirement.kind === "firestore-ttl") {
    args = [
      "firestore",
      "fields",
      "ttls",
      "list",
      `--project=${projectId}`,
      "--database=(default)",
      `--collection-group=${requirement.collectionGroup}`,
      "--format=json(name,ttlConfig)",
      "--quiet",
    ];
  } else {
    throw new ReadinessUsageError(
      `Cannot build probe for requirement kind: ${requirement.kind}.`,
    );
  }
  return metadataOnlyCommand(args);
}

export function assertMetadataOnlyCommand(spec) {
  if (spec?.command !== "gcloud" || !Array.isArray(spec.args)) {
    throw new ReadinessUsageError("Readiness probes must use gcloud argv.");
  }
  const words = spec.args.map((arg) => String(arg).toLowerCase());
  for (let index = 0; index <= words.length - 3; index += 1) {
    if (words[index] === "secrets" && words[index + 1] === "versions" &&
        words[index + 2] === "access") {
      throw new ReadinessUsageError(
        "Secret payload access is forbidden in environment readiness.",
      );
    }
  }
  const allowed = (words[0] === "projects" && words[1] === "describe") ||
    words.slice(0, 3).join(" ") === "secrets versions list" ||
    words.slice(0, 4).join(" ") === "firestore fields ttls list";
  if (!allowed) {
    throw new ReadinessUsageError(
      `Unsupported readiness metadata command: ${words.slice(0, 4).join(" ")}.`,
    );
  }
  return spec;
}

export function classifyProjectIdentity({projectId, result}) {
  const failure = classifyCommandFailure(result);
  if (failure) {
    return readinessResult({
      id: "environment.project-identity",
      kind: "project-identity",
      resource: projectId,
      ...failure,
    });
  }
  const payload = parseJsonOutput(result.stdout);
  if (!payload || Array.isArray(payload) || typeof payload !== "object") {
    return readinessResult({
      id: "environment.project-identity",
      kind: "project-identity",
      reason: "invalid-metadata-response",
      resource: projectId,
      status: "unknown",
    });
  }
  if (payload.projectId !== projectId || payload.lifecycleState !== "ACTIVE") {
    return readinessResult({
      id: "environment.project-identity",
      kind: "project-identity",
      metadata: {
        lifecycleState: payload.lifecycleState ?? null,
        projectIdMatches: payload.projectId === projectId,
      },
      reason: "project-identity-not-active",
      resource: projectId,
      status: "not-ready",
    });
  }
  return readinessResult({
    id: "environment.project-identity",
    kind: "project-identity",
    metadata: {
      lifecycleState: payload.lifecycleState,
    },
    reason: "project-active",
    resource: projectId,
    status: "ready",
  });
}

export function classifyRequirementResult({requirement, result}) {
  const resource = requirement.kind === "secret-version"
    ? requirement.name
    : `${requirement.collectionGroup}.${requirement.field}`;
  const failure = classifyCommandFailure(result);
  if (failure) {
    return readinessResult({
      id: requirement.id,
      kind: requirement.kind,
      resource,
      ...failure,
    });
  }
  const payload = parseJsonOutput(result.stdout);
  if (!Array.isArray(payload)) {
    return readinessResult({
      id: requirement.id,
      kind: requirement.kind,
      reason: "invalid-metadata-response",
      resource,
      status: "unknown",
    });
  }
  if (requirement.kind === "secret-version") {
    const version = payload.find((entry) =>
      requirement.acceptedStates.includes(entry?.state));
    if (!version) {
      return readinessResult({
        id: requirement.id,
        kind: requirement.kind,
        metadata: {enabledVersionPresent: false},
        reason: "no-enabled-version",
        resource,
        status: "not-ready",
      });
    }
    return readinessResult({
      id: requirement.id,
      kind: requirement.kind,
      metadata: compactObject({
        enabledVersionPresent: true,
        state: version.state,
      }),
      reason: "enabled-version-present",
      resource,
      status: "ready",
    });
  }

  const ttl = payload.find((entry) =>
    resourceFieldName(entry?.name) === requirement.field);
  const state = ttl?.ttlConfig?.state;
  if (!ttl || !requirement.acceptedStates.includes(state)) {
    return readinessResult({
      id: requirement.id,
      kind: requirement.kind,
      metadata: {state: state ?? null},
      reason: ttl ? "ttl-not-active" : "ttl-policy-missing",
      resource,
      status: "not-ready",
    });
  }
  return readinessResult({
    id: requirement.id,
    kind: requirement.kind,
    metadata: {state},
    reason: "ttl-active",
    resource,
    status: "ready",
  });
}

export function exitCodeForResults(results) {
  if (results.some((result) => result.status === "unknown")) return 2;
  if (results.some((result) => result.status === "not-ready")) return 1;
  return 0;
}

export function runEnvironmentReadiness({
  aliases,
  capabilities = [],
  environments,
  manifest,
  runCommand = defaultRunCommand,
  targets = [],
}) {
  const environmentReports = [];
  for (const environment of environments) {
    if (!manifest.environments.includes(environment)) {
      throw new ReadinessUsageError(
        `Environment is not declared in the manifest: ${environment}.`,
      );
    }
    const projectId = resolveFirebaseProjectId({environment, aliases});
    const requirements = selectReadinessRequirements({
      capabilities,
      environment,
      manifest,
      targets,
    });
    const identityCommand = buildProjectIdentityCommand(projectId);
    const results = [
      classifyProjectIdentity({
        projectId,
        result: executeMetadataCommand(identityCommand, runCommand),
      }),
    ];
    for (const requirement of requirements) {
      const command = buildRequirementCommand({projectId, requirement});
      results.push(classifyRequirementResult({
        requirement,
        result: executeMetadataCommand(command, runCommand),
      }));
    }
    const exitCode = exitCodeForResults(results);
    environmentReports.push({
      environment,
      exitCode,
      projectId,
      ready: exitCode === 0,
      results,
      selectedRequirementCount: requirements.length,
      status: statusForExitCode(exitCode),
    });
  }

  const results = environmentReports.flatMap((report) => report.results);
  const exitCode = exitCodeForResults(results);
  return {
    capabilities: [...capabilities],
    environments: environmentReports,
    exitCode,
    mode: "live",
    ready: exitCode === 0,
    status: statusForExitCode(exitCode),
    targets: [...targets],
    version: 1,
  };
}

export function executeReadinessCli(argv, dependencies = {}) {
  const args = parseArgs(argv);
  if (args.help) {
    return {exitCode: 0, output: helpText()};
  }
  const repoRoot = dependencies.repoRoot ?? defaultRepoRoot;
  const readFile = dependencies.readFile ?? fs.readFileSync;
  const pathExists = dependencies.pathExists ?? fs.existsSync;
  const manifestPath = dependencies.manifestPath ?? path.join(
    repoRoot,
    "tool/firebase/environment_readiness.json",
  );
  const manifest = dependencies.manifest ?? readJsonFile(manifestPath, readFile);

  let validationOptions = {};
  let functionTargets = dependencies.functionTargets ?? new Set();
  if (dependencies.repositoryValidation !== false) {
    const sourceRoot = path.join(repoRoot, "functions/src");
    const sources = dependencies.sources ?? readTypescriptSources({
      repoRoot,
      sourceRoot,
      readFile,
    });
    const declarations = discoverDefineSecretNames(sources);
    const indexSource = dependencies.indexSource ?? readFile(
      path.join(sourceRoot, "index.ts"),
      "utf8",
    );
    functionTargets = parseFirebaseFunctionTargets(indexSource);
    validationOptions = {
      discoveredSecrets: declarations.names,
      functionTargets,
      sourcePathExists: (sourcePath) => pathExists(path.join(repoRoot, sourcePath)),
      unsupportedSecretDeclarations: declarations.unsupported,
    };
  }
  validateEnvironmentReadinessManifest(manifest, validationOptions);

  if (args.manifestOnly) {
    const report = {
      mode: "manifest-only",
      ready: true,
      requirementCount: manifest.requirements.length,
      secretCount: manifest.requirements.filter(
        (requirement) => requirement.kind === "secret-version",
      ).length,
      status: "ready",
      version: manifest.version,
    };
    return {
      exitCode: 0,
      output: formatReport(report, args.json),
      report,
    };
  }

  validateReadinessSelectors({
    capabilities: args.capabilities,
    functionTargets,
    manifest,
    targets: args.targets,
  });

  const firebaseRcPath = dependencies.firebaseRcPath ?? path.join(
    repoRoot,
    ".firebaserc",
  );
  const aliases = dependencies.aliases ?? parseFirebaseProjectAliases(
    readFile(firebaseRcPath, "utf8"),
  );
  const environments = args.all
    ? [...manifest.environments]
    : [args.environment];
  const report = runEnvironmentReadiness({
    aliases,
    capabilities: args.capabilities,
    environments,
    manifest,
    runCommand: dependencies.runCommand,
    targets: args.targets,
  });
  return {
    exitCode: report.exitCode,
    output: formatReport(report, args.json),
    report,
  };
}

function targetMatches(requiredTarget, selectedTargets) {
  if (selectedTargets.has("all")) return true;
  if (selectedTargets.has(requiredTarget)) return true;
  return requiredTarget.startsWith("functions:") &&
    selectedTargets.has("functions");
}

function metadataOnlyCommand(args) {
  return assertMetadataOnlyCommand({command: "gcloud", args});
}

function executeMetadataCommand(spec, runCommand) {
  assertMetadataOnlyCommand(spec);
  try {
    return normalizeCommandResult(runCommand(spec));
  } catch (error) {
    return {
      error: {code: error?.code ?? "COMMAND_EXCEPTION"},
      status: null,
      stderr: "",
      stdout: "",
    };
  }
}

function defaultRunCommand(spec) {
  const result = spawnSync(spec.command, spec.args, {
    encoding: "utf8",
    env: {
      ...process.env,
      CLOUDSDK_CORE_DISABLE_PROMPTS: "1",
    },
    shell: false,
    timeout: metadataCommandTimeoutMs,
  });
  return normalizeCommandResult(result);
}

function normalizeCommandResult(result = {}) {
  return {
    error: result.error
      ? {code: result.error.code ?? "COMMAND_ERROR"}
      : null,
    status: Number.isInteger(result.status) ? result.status : null,
    stderr: typeof result.stderr === "string" ? result.stderr : "",
    stdout: typeof result.stdout === "string" ? result.stdout : "",
  };
}

function classifyCommandFailure(result) {
  if (result?.error) {
    return {
      reason: result.error.code === "ENOENT"
        ? "gcloud-unavailable"
        : result.error.code === "ETIMEDOUT"
          ? "metadata-command-timeout"
          : "metadata-command-error",
      status: "unknown",
    };
  }
  if (result?.status === 0) return null;
  const diagnostic = String(result?.stderr ?? "").toUpperCase();
  if (diagnostic.includes("NOT_FOUND")) {
    return {reason: "resource-not-found", status: "not-ready"};
  }
  if (diagnostic.includes("PERMISSION_DENIED")) {
    return {reason: "permission-denied", status: "unknown"};
  }
  if (diagnostic.includes("UNAUTHENTICATED") ||
      diagnostic.includes("LOGIN REQUIRED") ||
      diagnostic.includes("REAUTHENTICATE")) {
    return {reason: "authentication-failed", status: "unknown"};
  }
  return {reason: "metadata-command-failed", status: "unknown"};
}

function readinessResult({
  id,
  kind,
  metadata,
  reason,
  resource,
  status,
}) {
  return compactObject({id, kind, metadata, reason, resource, status});
}

function resourceFieldName(resourceName) {
  if (typeof resourceName !== "string") return null;
  const encoded = resourceName.split("/fields/").at(-1);
  if (!encoded) return null;
  try {
    return decodeURIComponent(encoded);
  } catch {
    return encoded;
  }
}

function parseJsonOutput(stdout) {
  try {
    return JSON.parse(String(stdout ?? ""));
  } catch {
    return null;
  }
}

function compactObject(object) {
  return Object.fromEntries(
    Object.entries(object).filter(([, value]) => value !== undefined),
  );
}

function statusForExitCode(exitCode) {
  if (exitCode === 0) return "ready";
  if (exitCode === 1) return "not-ready";
  return "unknown";
}

function validateStringArray({errors, key, label, value}) {
  if (!Array.isArray(value) || value.length === 0) {
    errors.push(`${label}: ${key} must be a non-empty array.`);
    return;
  }
  if (new Set(value).size !== value.length) {
    errors.push(`${label}: ${key} must not contain duplicates.`);
  }
  for (const item of value) {
    if (typeof item !== "string" || item.trim() === "") {
      errors.push(`${label}: ${key} must contain non-empty strings.`);
    }
  }
}

function validateProjectId(projectId) {
  if (!projectIdPattern.test(projectId ?? "")) {
    throw new ReadinessUsageError(`Invalid Firebase project id: ${projectId}.`);
  }
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) {
    throw new ReadinessUsageError(`${flag} requires a value.`);
  }
  return value;
}

function parseCsv(value, flag) {
  const values = value.split(",").map((item) => item.trim()).filter(Boolean);
  if (values.length === 0) {
    throw new ReadinessUsageError(`${flag} requires a non-empty value.`);
  }
  return values;
}

function readJsonFile(filePath, readFile) {
  try {
    return JSON.parse(readFile(filePath, "utf8"));
  } catch (error) {
    throw new ReadinessUsageError(
      `Could not read ${filePath}: ${error?.message ?? String(error)}.`,
    );
  }
}

function readTypescriptSources({repoRoot, sourceRoot, readFile}) {
  const files = [];
  const visit = (directory) => {
    for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
      if (entry.isDirectory()) {
        if (entry.name !== "generated" && entry.name !== "node_modules") {
          visit(path.join(directory, entry.name));
        }
      } else if (entry.isFile() && entry.name.endsWith(".ts") &&
          !entry.name.endsWith(".test.ts")) {
        const filePath = path.join(directory, entry.name);
        files.push({
          contents: readFile(filePath, "utf8"),
          path: path.relative(repoRoot, filePath),
        });
      }
    }
  };
  visit(sourceRoot);
  return files;
}

function formatReport(report, json) {
  if (json) return `${JSON.stringify(report, null, 2)}\n`;
  if (report.mode === "manifest-only") {
    return (
      `READY environment readiness manifest: ${report.requirementCount} ` +
      `requirements (${report.secretCount} secrets).\n`
    );
  }
  const lines = [];
  for (const environment of report.environments) {
    lines.push(
      `${environment.status.toUpperCase().padEnd(9)} ` +
      `${environment.environment}: ${environment.projectId} ` +
      `(${environment.selectedRequirementCount} prerequisite(s))`,
    );
    for (const result of environment.results) {
      lines.push(
        `  ${result.status.toUpperCase().padEnd(9)} ${result.id} ` +
        `(${result.reason})`,
      );
    }
  }
  return `${lines.join("\n")}\n`;
}

function helpText() {
  return `Check Firebase/GCP environment prerequisites without reading secrets.

Usage:
  node tool/firebase/check_environment_readiness.mjs --manifest-only [--json]
  node tool/firebase/check_environment_readiness.mjs \\
    (--env <dev|staging|prod> | --all) \\
    [--targets <csv>] [--capabilities <csv>] [--json]

The live checker resolves projects only from .firebaserc and uses metadata-only
gcloud commands. It has no apply mode and never accesses secret payloads.
`;
}

function main() {
  try {
    const execution = executeReadinessCli(process.argv.slice(2));
    process.stdout.write(execution.output);
    process.exitCode = execution.exitCode;
  } catch (error) {
    process.stderr.write(`${error?.message ?? String(error)}\n`);
    process.exitCode = error?.exitCode ?? 2;
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main();
}
