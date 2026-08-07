#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {repoRoot} from "./lib/repo_paths.mjs";
import {createRepositorySnapshot} from "./lib/repository_snapshot.mjs";
import {
  toolSupportsPlatform,
  validateToolPlatforms,
} from "./lib/tool_platform.mjs";
import {
  deriveAppRoles,
  matchesGlob,
  planAffected,
} from "./harness/lib/component_graph.mjs";
import {
  duplicateCanonicalFullPathOverrides,
  formatAffectedToolGithubOutputs,
  hasExecutableChecks,
  planAffectedToolChecks,
  validateToolCheckSafety,
  validateToolCiRequirements,
} from "./lib/tool_impact.mjs";

const manifestPath = "tool/tools_manifest.json";
const componentGraphPath = "tool/harness/component_graph.json";
let capturedRepositorySnapshot = null;

const command = process.argv[2] ?? "help";
const argv = process.argv.slice(3);

if (command === "help" || command === "--help" || command === "-h") {
  printHelp();
} else if (command === "list") {
  listTools(argv);
} else if (command === "check") {
  await checkTools(argv);
} else if (command === "impacted") {
  await impactedTools(argv);
} else if (command === "affected-tools") {
  await affectedToolChecks(argv);
} else if (command === "run" || command === "exec") {
  runTool(argv);
} else {
  console.error(`Unknown command: ${command}`);
  printHelp();
  process.exit(64);
}

function loadManifest() {
  const manifest = repositorySnapshot().readJson(manifestPath, {required: true});
  if (!Array.isArray(manifest.tools)) {
    throw new Error("tools_manifest.json must contain a tools array.");
  }
  return manifest;
}

function listTools(args) {
  const {category, json} = parseListArgs(args);
  const tools = selectTools(loadManifest(), {category});
  requireSelection(tools, {category});

  if (json) {
    console.log(JSON.stringify(tools, null, 2));
    return;
  }

  const byCategory = new Map();
  for (const tool of tools) {
    if (!byCategory.has(tool.category)) byCategory.set(tool.category, []);
    byCategory.get(tool.category).push(tool);
  }

  for (const [name, entries] of [...byCategory.entries()].sort()) {
    console.log(`\n${name}`);
    for (const tool of entries.sort((a, b) => a.id.localeCompare(b.id))) {
      console.log(`  ${tool.id.padEnd(42)} ${tool.path}`);
    }
  }
}

async function checkTools(args) {
  const {category, ids, manifestOnly} = parseCheckArgs(args);
  const manifest = loadManifest();
  const tools = selectTools(manifest, {category, ids});
  const errors = validateManifest(manifest, loadComponentGraph());

  if (errors.length > 0) {
    console.error("Tool manifest validation failed:");
    for (const error of errors) console.error(`- ${error}`);
    process.exitCode = 1;
    return;
  }

  if (manifestOnly) {
    console.log("Tool manifest validation passed.");
    return;
  }

  const selectedIds = new Set(tools.map((tool) => tool.id));
  const missingIds = ids.filter((id) => !selectedIds.has(id));
  if (missingIds.length > 0) {
    console.error(`Unknown or inactive tool ids: ${missingIds.join(", ")}.`);
    process.exitCode = 64;
    return;
  }

  requireSelection(tools, {category, ids});
  await runChecks(tools);
}

async function runChecks(tools) {
  for (const tool of tools) {
    if (!toolSupportsPlatform(tool)) {
      console.log(
        `==> ${tool.id}: skipped on ${process.platform}; ` +
        `supported platforms: ${tool.platforms.join(", ")}`,
      );
      continue;
    }
    for (const check of tool.checks ?? []) {
      console.log(`==> ${tool.id}: ${check}`);
      const result = spawnSync(check, {
        cwd: repoRoot,
        shell: true,
        stdio: "inherit",
      });
      if (result.status !== 0) {
        process.exitCode = result.status ?? 1;
        return;
      }
    }
  }

  console.log("Tool checks passed.");
}

function requireSelection(tools, {category, ids = []} = {}) {
  if (tools.length > 0 || (!category && ids.length === 0)) return;
  const selector = category ? `category ${category}` : `tool ids ${ids.join(", ")}`;
  console.error(`No active tools matched ${selector}.`);
  process.exit(64);
}

async function impactedTools(args) {
  const options = parseImpactedArgs(args);
  const manifest = loadManifest();
  const rootManifest = repositorySnapshot().readJson(
    "tool/repository_root_manifest.json",
    {required: true},
  );
  const componentGraph = loadComponentGraph();
  const changedPaths = options.paths ?? changedPathsSince(options.base);
  const relationships = rootManifest.relationships ?? [];
  const matchedRelationships = relationships.filter((relationship) =>
    changedPaths.some((changedPath) => relationshipPatterns(relationship)
      .some((pattern) => matchesGlob(changedPath, pattern)))
  );
  const matchedPaths = new Set(changedPaths.filter((changedPath) =>
    matchedRelationships.some((relationship) => relationshipPatterns(relationship)
      .some((pattern) => matchesGlob(changedPath, pattern)))
  ));
  const toolIds = [...new Set(matchedRelationships.flatMap(
    (relationship) => relationship.checks ?? [],
  ))].sort();
  const ciWorkflows = [...new Set(matchedRelationships.flatMap(
    (relationship) => relationship.ciWorkflows ?? [],
  ))].sort();
  const prPlan = planAffected({
    changedPaths,
    graph: componentGraph,
    mode: "pr",
  });
  const mainPlan = planAffected({
    changedPaths,
    graph: componentGraph,
    mode: "main",
  });
  const unknownPaths = [...new Set([
    ...prPlan.unknownPaths,
    ...mainPlan.unknownPaths,
  ])].sort();
  const ambiguousPaths = [...prPlan.ambiguousPaths].sort((left, right) =>
    left.path.localeCompare(right.path)
  );
  const unmatchedPaths = [...new Set([
    ...changedPaths.filter((changedPath) => !matchedPaths.has(changedPath)),
    ...unknownPaths,
    ...ambiguousPaths.map((entry) => entry.path),
  ])].sort();
  const result = {
    base: options.base,
    changedPaths,
    relationships: matchedRelationships.map((relationship) => relationship.id).sort(),
    toolIds,
    ciWorkflows,
    ciTargets: prPlan.operations.ciTargets,
    appRoles: deriveAppRoles(prPlan),
    buildTargets: prPlan.operations.buildTargets,
    mobileReleaseRoles: mainPlan.operations.releaseRoles,
    deployGroups: mainPlan.operations.deployGroups,
    deployRequired: mainPlan.operations.deployGroups.length > 0,
    unknownPaths,
    ambiguousPaths,
    unmatchedPaths,
  };

  if (options.json || !options.check) {
    console.log(JSON.stringify(result, null, 2));
  } else {
    console.log(`Impacted relationships: ${result.relationships.join(", ") || "none"}`);
    console.log(`Impacted tool checks: ${toolIds.join(", ") || "none"}`);
    console.log(`CI workflows: ${ciWorkflows.join(", ") || "none"}`);
    console.log(`CI targets: ${result.ciTargets.join(", ") || "none"}`);
    console.log(`App roles: ${result.appRoles.join(", ") || "none"}`);
    console.log(
      `Mobile release roles: ${result.mobileReleaseRoles.join(", ") || "none"}`,
    );
    console.log(`Deploy groups: ${result.deployGroups.join(", ") || "none"}`);
  }

  if (unmatchedPaths.length > 0) {
    console.error(`Unmapped changed paths: ${unmatchedPaths.join(", ")}`);
    process.exitCode = 1;
    return;
  }
  if (!options.check || toolIds.length === 0) return;
  const tools = selectTools(manifest, {ids: toolIds});
  const missingIds = toolIds.filter((id) => !tools.some((tool) => tool.id === id));
  if (missingIds.length > 0) {
    console.error(`Impact graph references unknown tool ids: ${missingIds.join(", ")}`);
    process.exitCode = 1;
    return;
  }
  requireSelection(tools, {ids: toolIds});
  await runChecks(tools);
}

async function affectedToolChecks(args) {
  const options = parseAffectedToolArgs(args);
  const manifest = loadManifest();
  const componentGraph = loadComponentGraph();
  const errors = validateManifest(manifest, componentGraph);
  if (errors.length > 0) {
    console.error("Tool manifest validation failed:");
    for (const error of errors) console.error(`- ${error}`);
    process.exitCode = 1;
    return;
  }

  const changedPaths = options.paths ?? changedPathsSince(options.base);
  const plan = planAffectedToolChecks({
    changedPaths,
    manifest,
    componentGraph,
    mode: options.mode,
    full: options.full,
  });
  if (!options.check) {
    console.log(JSON.stringify(plan, null, 2));
    if (!options.githubOutput) return;
  }
  let tools = [];
  if (plan.mode !== "full") {
    tools = selectTools(manifest, {ids: plan.toolIds});
    const missingIds = plan.toolIds.filter(
      (id) => !tools.some((tool) => tool.id === id),
    );
    if (missingIds.length > 0) {
      console.error(
        `Affected-tool plan references inactive or unknown tool ids: ${missingIds.join(", ")}`,
      );
      process.exitCode = 1;
      return;
    }
    requireSelection(tools, {ids: plan.toolIds});
  }
  if (!options.check) {
    fs.appendFileSync(
      options.githubOutput,
      formatAffectedToolGithubOutputs(plan),
      "utf8",
    );
    return;
  }
  if (options.githubOutput) {
    fs.appendFileSync(
      options.githubOutput,
      formatAffectedToolGithubOutputs(plan),
      "utf8",
    );
  }
  if (options.json) {
    console.log(JSON.stringify(plan, null, 2));
  } else {
    console.log(`Affected tool mode: ${plan.mode}`);
    console.log(`Affected tool checks: ${plan.toolIds.join(", ") || "none"}`);
  }
  if (plan.mode === "full") {
    console.error(
      "Affected-tool planning selected full mode; run the full category matrix.",
    );
    process.exitCode = 1;
    return;
  }
  await runChecks(tools);
}

function changedPathsSince(base) {
  const commands = [
    ["diff", "--name-only", `${base}...HEAD`],
    ["diff", "--name-only"],
    ["diff", "--cached", "--name-only"],
    ["ls-files", "--others", "--exclude-standard"],
  ];
  const paths = new Set();
  for (const gitArgs of commands) {
    const result = spawnSync("git", gitArgs, {cwd: repoRoot, encoding: "utf8"});
    if (result.status !== 0) {
      console.error(result.stderr || `Unable to resolve changed paths from ${base}.`);
      process.exit(result.status ?? 1);
    }
    for (const line of result.stdout.split(/\r?\n/).filter(Boolean)) paths.add(line);
  }
  return [...paths].sort();
}

function relationshipPatterns(relationship) {
  return [
    ...(relationship.sources ?? []),
    ...(relationship.generatedOutputs ?? []),
    ...(relationship.consumers ?? []),
  ];
}

function runTool(args) {
  const id = args[0];
  if (!id) {
    console.error("Usage: node tool/run.mjs run <tool-id> [args...]");
    process.exit(64);
  }

  const tool = loadManifest().tools.find((entry) => entry.id === id);
  if (!tool) {
    console.error(`Unknown tool id: ${id}`);
    process.exit(64);
  }
  if (!tool.command) {
    console.error(`Tool ${id} does not define a command.`);
    process.exit(64);
  }
  if (!toolSupportsPlatform(tool)) {
    console.error(
      `Tool ${id} is unavailable on ${process.platform}; ` +
      `supported platforms: ${tool.platforms.join(", ")}.`,
    );
    process.exit(64);
  }

  const forwarded = args.slice(1).map(shellQuote).join(" ");
  const commandLine = forwarded ? `${tool.command} ${forwarded}` : tool.command;
  const result = spawnSync(commandLine, {
    cwd: repoRoot,
    shell: true,
    stdio: "inherit",
  });
  process.exit(result.status ?? 1);
}

function validateManifest(manifest, componentGraph) {
  const errors = [];
  const ids = new Set();
  const paths = new Set();

  for (const tool of manifest.tools) {
    if (!tool.id) errors.push("Tool entry is missing id.");
    if (!tool.category) errors.push(`${tool.id ?? "<missing>"} is missing category.`);
    if (!tool.path) errors.push(`${tool.id ?? "<missing>"} is missing path.`);
    for (const error of validateToolPlatforms(tool)) {
      errors.push(`${tool.id ?? "<missing>"}: ${error}`);
    }
    validateStringArrayField(tool.impactPaths, `${tool.id}.impactPaths`, errors);
    validateStringArrayField(tool.alsoCheckIds, `${tool.id}.alsoCheckIds`, errors);
    for (const error of validateToolCiRequirements(tool)) {
      errors.push(`${tool.id ?? "<missing>"}: ${error}`);
    }
    for (const error of validateToolCheckSafety(tool)) {
      errors.push(`${tool.id ?? "<missing>"}: ${error}`);
    }
    if (tool.status === "active" && !hasExecutableChecks(tool)) {
      errors.push(`${tool.id ?? "<missing>"} is active but defines no checks.`);
    }
    if (tool.id && ids.has(tool.id)) errors.push(`Duplicate tool id: ${tool.id}`);
    if (tool.id) ids.add(tool.id);
    if (tool.path) {
      paths.add(tool.path);
      if (!repositorySnapshot().exists(tool.path)) {
        errors.push(`${tool.id}: missing path ${tool.path}`);
      }
    }
  }

  if (
    manifest.ciImpact == null ||
    typeof manifest.ciImpact !== "object" ||
    Array.isArray(manifest.ciImpact)
  ) {
    errors.push("Manifest is missing ciImpact configuration.");
  } else {
    validateStringArrayField(
      manifest.ciImpact.mandatoryCheckIds,
      "ciImpact.mandatoryCheckIds",
      errors,
      {required: true, nonEmpty: true},
    );
    validateStringArrayField(
      manifest.ciImpact.additionalFullPaths,
      "ciImpact.additionalFullPaths",
      errors,
      {required: true, nonEmpty: true},
    );
  }

  try {
    const duplicates = duplicateCanonicalFullPathOverrides({
      manifest,
      componentGraph,
    });
    if (duplicates.length > 0) {
      errors.push(
        `ciImpact.additionalFullPaths duplicates canonical repo.harness paths: ${duplicates.join(", ")}`,
      );
    }
  } catch (error) {
    errors.push(error.message);
  }

  const activeById = new Map(
    manifest.tools
      .filter((tool) => tool.status === "active")
      .map((tool) => [tool.id, tool]),
  );
  const referencedIds = [
    ...(manifest.ciImpact?.mandatoryCheckIds ?? []),
    ...manifest.tools.flatMap((tool) => tool.alsoCheckIds ?? []),
  ];
  for (const id of new Set(referencedIds)) {
    const tool = activeById.get(id);
    if (!tool) {
      errors.push(`Affected-tool metadata references inactive or unknown id: ${id}`);
    } else if (!Array.isArray(tool.checks) || tool.checks.length === 0) {
      errors.push(`Affected-tool metadata references id without checks: ${id}`);
    }
  }

  for (const relativePath of discoverManagedScripts()) {
    if (!paths.has(relativePath)) {
      errors.push(`Unmanaged tool script: ${relativePath}`);
    }
  }

  return errors;
}

function loadComponentGraph() {
  return repositorySnapshot().readJson(componentGraphPath, {required: true});
}

function discoverManagedScripts() {
  return repositorySnapshot().listFiles({prefix: "tool/"}).filter((relativePath) => {
    const ext = path.extname(relativePath);
    if (![".mjs", ".js", ".dart", ".py", ".rb", ".sh"].includes(ext)) {
      return false;
    }
    if (relativePath.includes("/lib/")) return false;
    if (relativePath.includes("/fixtures/")) return false;
    if (relativePath.includes("/contracts/generated/")) return false;
    if (relativePath.endsWith(".test.mjs")) return false;
    return true;
  });
}

function repositorySnapshot() {
  capturedRepositorySnapshot ??= createRepositorySnapshot();
  return capturedRepositorySnapshot;
}

function selectTools(manifest, {category, ids = []} = {}) {
  return manifest.tools.filter((tool) => {
    if (tool.status !== "active") return false;
    if (category && tool.category !== category) return false;
    if (ids.length > 0 && !ids.includes(tool.id)) return false;
    return true;
  });
}

function validateStringArrayField(
  value,
  label,
  errors,
  {required = false, nonEmpty = false} = {},
) {
  if (value == null && !required) return;
  if (!Array.isArray(value) || value.some((entry) => typeof entry !== "string" || entry === "")) {
    errors.push(`${label} must be an array of non-empty strings.`);
    return;
  }
  if (nonEmpty && value.length === 0) {
    errors.push(`${label} must not be empty.`);
  }
  if (new Set(value).size !== value.length) {
    errors.push(`${label} must not contain duplicates.`);
  }
}

function parseListArgs(args) {
  return {
    category: valueAfter(args, "--category"),
    json: args.includes("--json"),
  };
}

function parseCheckArgs(args) {
  const category = valueAfter(args, "--category");
  const manifestOnly = args.includes("--manifest-only");
  const ids = args.filter((arg, index) => {
    if (arg.startsWith("--")) return false;
    if (args[index - 1] === "--category") return false;
    return true;
  });
  return {category, ids, manifestOnly};
}

function parseImpactedArgs(args) {
  const pathsValue = valueAfter(args, "--paths");
  return {
    base: valueAfter(args, "--base") ?? "origin/main",
    paths: pathsValue == null ? null : pathsValue
      .split(",")
      .map((value) => value.trim())
      .filter(Boolean)
      .sort(),
    json: args.includes("--json"),
    check: args.includes("--check"),
  };
}

function parseAffectedToolArgs(args) {
  const pathsValue = valueAfter(args, "--paths");
  return {
    base: valueAfter(args, "--base") ?? "origin/main",
    paths: pathsValue == null ? null : pathsValue
      .split(",")
      .map((value) => value.trim())
      .filter(Boolean)
      .sort(),
    json: args.includes("--json"),
    check: args.includes("--check"),
    full: args.includes("--full"),
    mode: valueAfter(args, "--mode") ?? "pr",
    githubOutput: valueAfter(args, "--github-output"),
  };
}

function valueAfter(args, flag) {
  const index = args.indexOf(flag);
  if (index === -1) return null;
  const value = args[index + 1];
  if (!value || value.startsWith("--")) {
    throw new Error(`${flag} requires a value.`);
  }
  return value;
}

function shellQuote(value) {
  return `'${String(value).replaceAll("'", "'\\''")}'`;
}

function printHelp() {
  console.log(`Usage: node tool/run.mjs <command>

Commands:
  list [--category name] [--json]
  check [--category name] [--manifest-only] [tool-id ...]
  impacted [--base ref | --paths a,b] [--json] [--check]
  affected-tools [--base ref | --paths a,b] [--mode mode] [--full] [--json] [--check]
    [--github-output path]
  run <tool-id> [args...]

Examples:
  node tool/run.mjs list --category data
  node tool/run.mjs check --manifest-only
  node tool/run.mjs impacted --base origin/main --check
  node tool/run.mjs affected-tools --base origin/main --check
  node tool/run.mjs run demo:ops list-commands
`);
}
