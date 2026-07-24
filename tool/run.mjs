#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fromRepo, repoRoot, toolRoot} from "./lib/repo_paths.mjs";
import {
  toolSupportsPlatform,
  validateToolPlatforms,
} from "./lib/tool_platform.mjs";

const manifestPath = fromRepo("tool/tools_manifest.json");

const command = process.argv[2] ?? "help";
const argv = process.argv.slice(3);

if (command === "help" || command === "--help" || command === "-h") {
  printHelp();
} else if (command === "list") {
  listTools(argv);
} else if (command === "check") {
  checkTools(argv);
} else if (command === "impacted") {
  impactedTools(argv);
} else if (command === "run" || command === "exec") {
  runTool(argv);
} else {
  console.error(`Unknown command: ${command}`);
  printHelp();
  process.exit(64);
}

function loadManifest() {
  const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
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

function checkTools(args) {
  const {category, ids, manifestOnly} = parseCheckArgs(args);
  const manifest = loadManifest();
  const tools = selectTools(manifest, {category, ids});
  const errors = validateManifest(manifest);

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

  requireSelection(tools, {category, ids});
  runChecks(tools);
}

function runChecks(tools) {
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

function impactedTools(args) {
  const options = parseImpactedArgs(args);
  const manifest = loadManifest();
  const rootManifest = JSON.parse(
    fs.readFileSync(fromRepo("tool/repository_root_manifest.json"), "utf8"),
  );
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
  const unmatchedPaths = changedPaths.filter((changedPath) => !matchedPaths.has(changedPath));
  const result = {
    base: options.base,
    changedPaths,
    relationships: matchedRelationships.map((relationship) => relationship.id).sort(),
    toolIds,
    ciWorkflows,
    unmatchedPaths,
  };

  if (options.json || !options.check) {
    console.log(JSON.stringify(result, null, 2));
  } else {
    console.log(`Impacted relationships: ${result.relationships.join(", ") || "none"}`);
    console.log(`Impacted tool checks: ${toolIds.join(", ") || "none"}`);
    console.log(`CI workflows: ${ciWorkflows.join(", ") || "none"}`);
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
  runChecks(tools);
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

export function matchesGlob(value, pattern) {
  const doubleStar = "\u0000";
  const escaped = pattern
    .replace(/[.+^${}()|[\]\\]/g, "\\$&")
    .replaceAll("**", doubleStar)
    .replaceAll("*", "[^/]*")
    .replaceAll("?", "[^/]")
    .replaceAll(doubleStar, ".*");
  return new RegExp(`^${escaped}$`).test(value);
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

function validateManifest(manifest) {
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
    if (tool.id && ids.has(tool.id)) errors.push(`Duplicate tool id: ${tool.id}`);
    if (tool.id) ids.add(tool.id);
    if (tool.path) {
      paths.add(tool.path);
      if (!fs.existsSync(fromRepo(tool.path))) {
        errors.push(`${tool.id}: missing path ${tool.path}`);
      }
    }
  }

  for (const file of discoverManagedScripts()) {
    const relativePath = path.relative(repoRoot, file);
    if (!paths.has(relativePath)) {
      errors.push(`Unmanaged tool script: ${relativePath}`);
    }
  }

  return errors;
}

function discoverManagedScripts() {
  const files = [];
  walk(toolRoot, files);
  return files.filter((file) => {
    const relativePath = path.relative(repoRoot, file);
    const ext = path.extname(file);
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

function walk(dir, files) {
  for (const entry of fs.readdirSync(dir, {withFileTypes: true})) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(fullPath, files);
    else if (entry.isFile()) files.push(fullPath);
  }
}

function selectTools(manifest, {category, ids = []} = {}) {
  return manifest.tools.filter((tool) => {
    if (category && tool.category !== category) return false;
    if (ids.length > 0 && !ids.includes(tool.id)) return false;
    return true;
  });
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
  run <tool-id> [args...]

Examples:
  node tool/run.mjs list --category data
  node tool/run.mjs check --manifest-only
  node tool/run.mjs impacted --base origin/main --check
  node tool/run.mjs run demo:ops list-commands
`);
}
