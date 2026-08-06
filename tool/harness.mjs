#!/usr/bin/env node

import fs from "node:fs";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import {fromRepo, repoRoot} from "./lib/repo_paths.mjs";
import {
  deriveAppRoles,
  planAffected,
  resolveTargetCheckout,
  runCodegenChecks,
  selectCompileCodegen,
  summarizeCoverage,
  validateComponentGraph,
} from "./harness/lib/component_graph.mjs";
import {
  executeTaskCommand,
  TaskUsageError,
  taskHelp,
} from "./harness/lib/worktree_lifecycle.mjs";
import {toolChecksAreLocalReadonly} from "./lib/tool_impact.mjs";

const graphPath = fromRepo("tool/harness/component_graph.json");
const toolsManifestPath = fromRepo("tool/tools_manifest.json");

export function parseArgs(args) {
  const command = args[0] ?? "help";
  const pathsValue = valueAfter(args, "--paths");
  return {
    command,
    base: valueAfter(args, "--base") ?? "origin/main",
    head: valueAfter(args, "--head") ?? "HEAD",
    mode: valueAfter(args, "--mode") ?? "pr",
    paths: pathsValue == null
      ? null
      : pathsValue.split(",").map((value) => value.trim()).filter(Boolean),
    json: args.includes("--json"),
    affected: args.includes("--affected"),
    checkOnly: args.includes("--check"),
    dryRun: args.includes("--dry-run"),
    full: args.includes("--full"),
    githubOutput: valueAfter(args, "--github-output"),
  };
}

export function projectPlanOutputs({plan, graph}) {
  if (plan.complete !== true) {
    throw new Error("Refusing to project outputs from an incomplete Harness plan.");
  }
  const selectedTargets = new Set(plan.operations.ciTargets);
  const appRoles = deriveAppRoles(plan);
  return {
    ...Object.fromEntries(graph.targets.map((target) => [
      target,
      selectedTargets.has(target),
    ])),
    app_roles: JSON.stringify(appRoles),
    build_targets: JSON.stringify([...plan.operations.buildTargets].sort()),
    release_roles: JSON.stringify([...plan.operations.releaseRoles].sort()),
    has_release_roles: plan.operations.releaseRoles.length > 0,
    deploy_groups: JSON.stringify([...plan.operations.deployGroups].sort()),
    deploy_required: plan.operations.deployGroups.length > 0,
    docs_checkout: JSON.stringify(resolveTargetCheckout({graph, target: "docs"})),
    mode: plan.mode,
    full: plan.full,
    complete: plan.complete,
  };
}

export function formatGithubOutputs(outputs) {
  return Object.entries(outputs)
    .map(([key, value]) => {
      const serialized = String(value);
      if (!/^[a-z][a-z0-9_]*$/.test(key) || /[\r\n]/.test(serialized)) {
        throw new Error(`Unsafe GitHub output ${JSON.stringify(key)}.`);
      }
      return `${key}=${serialized}\n`;
    })
    .join("");
}

export function writeGithubOutputs(path, outputs) {
  fs.appendFileSync(path, formatGithubOutputs(outputs), "utf8");
}

export function changedPathsSince({base, head = "HEAD", cwd = repoRoot}) {
  const commands = [
    ["diff", "--name-only", `${base}...${head}`],
    ["diff", "--name-only"],
    ["diff", "--cached", "--name-only"],
    ["ls-files", "--others", "--exclude-standard"],
  ];
  const paths = new Set();
  for (const gitArgs of commands) {
    const result = spawnSync("git", gitArgs, {cwd, encoding: "utf8"});
    if (result.status !== 0) {
      throw new Error(result.stderr || `Unable to resolve changed paths from ${base}.`);
    }
    for (const line of result.stdout.split(/\r?\n/).filter(Boolean)) paths.add(line);
  }
  return [...paths].sort();
}

export function main({
  args = process.argv.slice(2),
  checkExecutor = executeCheckIds,
  taskExecutor = executeTaskCommand,
  setExitCode = (status) => {
    process.exitCode = status;
  },
} = {}) {
  let options;
  try {
    options = parseArgs(args);
    if (["help", "--help", "-h"].includes(options.command)) {
      printHelp();
      return;
    }
    if (options.command === "task") {
      if (["help", "--help", "-h"].includes(args[1] ?? "help")) {
        console.log(taskHelp());
        return;
      }
      const execution = taskExecutor({args: args.slice(1), cwd: repoRoot});
      printResult(execution.result, options.json);
      if (execution.status !== 0) setExitCode(execution.status);
      return;
    }

    const graph = readJson(graphPath);
    const toolsManifest = readJson(toolsManifestPath);
    const knownCheckIds = collectKnownCheckIds(toolsManifest);
    const validationErrors = validateComponentGraph(graph, {knownCheckIds});
    if (validationErrors.length > 0) {
      printErrors("Harness v2 component graph is invalid:", validationErrors);
      process.exitCode = 1;
      return;
    }
    if (options.command === "validate") {
      printResult({valid: true, graphVersion: graph.version, status: graph.status}, options.json);
      return;
    }
    if (options.command === "coverage") {
      const paths = trackedPaths();
      const coverage = summarizeCoverage({paths, graph});
      printResult({graphVersion: graph.version, status: graph.status, ...coverage}, options.json);
      return;
    }

    const changedPaths = options.paths ?? (options.full ? [] : changedPathsSince(options));
    const plan = planAffected({
      changedPaths,
      graph,
      mode: options.mode,
      full: options.full,
    });

    if (options.command === "explain") {
      printResult(plan, options.json);
      setClassificationExitCode(plan, setExitCode);
      return;
    }
    if (options.command === "plan") {
      if (graph.status !== "required") {
        throw new Error(
          `Harness plan authority requires graph status "required", found ${JSON.stringify(graph.status)}.`,
        );
      }
      if (!plan.complete) {
        printResult(plan, options.json);
        setClassificationExitCode(plan, setExitCode);
        return;
      }
      if (options.githubOutput) {
        writeGithubOutputs(
          options.githubOutput,
          projectPlanOutputs({plan, graph}),
        );
      }
      printResult(plan, options.json);
      return;
    }
    if (options.command === "check") {
      requireAffected(options);
      if (!plan.complete) {
        printResult(plan, options.json);
        setClassificationExitCode(plan, setExitCode);
        return;
      }
      let execution = options.dryRun
        ? {status: 0, skipped: "dry-run", stdout: "", stderr: ""}
        : {status: 0, skipped: "no selected check ids", stdout: "", stderr: ""};
      if (!options.dryRun && plan.operations.checkIds.length > 0) {
        execution = checkExecutor({ids: plan.operations.checkIds});
        if (!options.json) {
          if (execution.stdout) process.stdout.write(execution.stdout);
          if (execution.stderr) process.stderr.write(execution.stderr);
        }
        if (execution.status !== 0) setExitCode(execution.status ?? 1);
      }
      printResult({plan, execution}, options.json);
      return;
    }
    if (options.command === "generate") {
      requireAffected(options);
      if (!options.checkOnly) {
        throw new UsageError(
          "Harness only permits compile-codegen in explicit --check mode.",
        );
      }
      if (!plan.complete) {
        printResult(plan, options.json);
        setClassificationExitCode(plan, setExitCode);
        return;
      }
      const selection = selectCompileCodegen({plan, graph});
      const results = runCodegenChecks({entries: selection.selected, cwd: repoRoot});
      const output = {plan, selection, results};
      printResult(output, options.json);
      if (selection.unsupported.length > 0 || results.some((result) => result.status !== 0)) {
        process.exitCode = 1;
      }
      return;
    }

    throw new UsageError(`Unknown harness command "${options.command}".`);
  } catch (error) {
    console.error(error.message);
    if (error instanceof UsageError) printHelp();
    if (error instanceof TaskUsageError) console.error(taskHelp());
    process.exitCode = error instanceof UsageError || error instanceof TaskUsageError ? 64 : 1;
  }
}

export function collectKnownCheckIds(toolsManifest) {
  return new Set(
    (toolsManifest?.tools ?? [])
      .filter((tool) =>
        tool.status === "active" &&
        toolChecksAreLocalReadonly(tool) &&
        Array.isArray(tool.checks) &&
        tool.checks.length > 0
      )
      .map((tool) => tool.id),
  );
}

function requireAffected(options) {
  if (!options.affected) {
    throw new UsageError(`${options.command} requires --affected to make scope explicit.`);
  }
}

export function executeCheckIds({ids, cwd = repoRoot, runner = spawnSync}) {
  const result = runner(
    process.execPath,
    ["tool/run.mjs", "check", ...ids],
    {cwd, encoding: "utf8", shell: false},
  );
  return {
    status: result.status,
    signal: result.signal ?? null,
    stdout: result.stdout ?? "",
    stderr: result.stderr ?? "",
  };
}

function setClassificationExitCode(plan, setExitCode) {
  if (!plan.complete) setExitCode(1);
}

function readJson(path) {
  return JSON.parse(fs.readFileSync(path, "utf8"));
}

function trackedPaths() {
  const result = spawnSync("git", ["ls-files"], {
    cwd: repoRoot,
    encoding: "utf8",
    shell: false,
  });
  if (result.status !== 0) throw new Error(result.stderr || "Unable to list tracked paths.");
  return result.stdout.split(/\r?\n/).filter(Boolean);
}

function valueAfter(args, flag) {
  const index = args.indexOf(flag);
  if (index === -1) return null;
  const value = args[index + 1];
  if (!value || value.startsWith("--")) throw new UsageError(`${flag} requires a value.`);
  return value;
}

function printErrors(label, errors) {
  console.error(label);
  for (const error of errors) console.error(`- ${error}`);
}

function printResult(value, json) {
  if (json) {
    console.log(JSON.stringify(value, null, 2));
    return;
  }
  if (value.operation === "reap") {
    console.log(`Harness task reap ${value.mode}: ${value.worktrees.length} registered worktrees`);
    console.log(`Classifications: ${Object.entries(value.counts).map(([key, count]) => `${key}=${count}`).join(", ")}`);
    console.log(`Legacy review only: ${value.legacyReview.count} worktrees, ${value.legacyReview.bytes} bytes`);
    console.log(`Deletion authorized: ${value.deletionAuthorized}`);
    console.log(`Report digest: ${value.reportDigest}`);
    return;
  }
  if (value.plan) {
    printPlan(value.plan);
    if (value.results) {
      for (const result of value.results) {
        console.log(`codegen ${result.id}: ${result.status === 0 ? "passed" : "failed"} (${result.durationMs}ms)`);
      }
    }
    return;
  }
  if (value.directComponents) {
    printPlan(value);
    return;
  }
  console.log(JSON.stringify(value, null, 2));
}

function printPlan(plan) {
  console.log(`Harness v2 ${plan.graphStatus} plan (${plan.mode})`);
  console.log(`Direct components: ${plan.directComponents.join(", ") || "none"}`);
  console.log(`Affected components: ${plan.affectedComponents.join(", ") || "none"}`);
  console.log(`CI targets: ${plan.operations.ciTargets.join(", ") || "none"}`);
  console.log(`Checks: ${plan.operations.checkIds.join(", ") || "none"}`);
  console.log(`Compile-codegen: ${plan.operations.codegenIds.join(", ") || "none"}`);
  console.log(`Deploy groups: ${plan.operations.deployGroups.join(", ") || "none"}`);
  console.log(`Release roles: ${plan.operations.releaseRoles.join(", ") || "none"}`);
  if (plan.unknownPaths.length > 0) console.error(`Unknown paths: ${plan.unknownPaths.join(", ")}`);
  if (plan.ambiguousPaths.length > 0) {
    console.error(`Ambiguous paths: ${plan.ambiguousPaths.map((entry) => entry.path).join(", ")}`);
  }
}

function printHelp() {
  console.log(`Usage: node tool/harness.mjs <command> [options]

Commands:
  task start|doctor|finish|reap
  validate
  coverage [--json]
  explain [--paths a,b | --base ref | --full] [--mode mode] [--json]
  plan [--paths a,b | --base ref | --full] [--mode mode] [--github-output path] [--json]
  check --affected [--paths a,b | --base ref] [--dry-run] [--json]
  generate --affected --check [--paths a,b | --base ref] [--json]

Compile-codegen executes only declared, deterministic, network-free checks.`);
}

class UsageError extends Error {}

if (process.argv[1] === fileURLToPath(import.meta.url)) main();
