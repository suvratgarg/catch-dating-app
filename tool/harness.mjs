#!/usr/bin/env node

import fs from "node:fs";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import {fromRepo, repoRoot} from "./lib/repo_paths.mjs";
import {planCi} from "./ci/plan_ci.mjs";
import {
  diffPlans,
  planAffected,
  runCodegenChecks,
  selectCompileCodegen,
  summarizeCoverage,
  validateComponentGraph,
} from "./harness/lib/component_graph.mjs";

const graphPath = fromRepo("tool/harness/component_graph.json");
const rootManifestPath = fromRepo("tool/repository_root_manifest.json");
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
  };
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

export function buildShadowReport({changedPaths, graph, rootManifest, mode, full = false}) {
  const v1Plan = planCi({changedPaths, ciPlanning: rootManifest.ciPlanning, full});
  const v2Plan = planAffected({changedPaths, graph, mode, full});
  return {
    generatedAt: new Date().toISOString(),
    authority: "v1",
    shadowStatus: graph.status,
    mode,
    full,
    changedPaths,
    v1Plan,
    v2Plan,
    comparison: diffPlans({v1Plan, v2Plan}),
  };
}

function main() {
  let options;
  try {
    options = parseArgs(process.argv.slice(2));
    if (["help", "--help", "-h"].includes(options.command)) {
      printHelp();
      return;
    }

    const graph = readJson(graphPath);
    const toolsManifest = readJson(toolsManifestPath);
    const knownCheckIds = new Set(
      toolsManifest.tools
        .filter((tool) =>
          tool.status === "active" &&
          String(tool.safety).startsWith("local") &&
          !String(tool.safety).includes("remote") &&
          Array.isArray(tool.checks) &&
          tool.checks.length > 0
        )
        .map((tool) => tool.id),
    );
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
      setClassificationExitCode(plan);
      return;
    }
    if (options.command === "shadow") {
      const rootManifest = readJson(rootManifestPath);
      const report = buildShadowReport({
        changedPaths,
        graph,
        rootManifest,
        mode: options.mode,
        full: options.full,
      });
      printResult(report, options.json);
      // Shadow incompleteness is evidence, not a replacement failure. V1 remains authoritative.
      if (authoritativeShadowFailure(report)) process.exitCode = 1;
      return;
    }
    if (options.command === "check") {
      requireAffected(options);
      if (!plan.complete) {
        printResult(plan, options.json);
        setClassificationExitCode(plan);
        return;
      }
      let execution = options.dryRun
        ? {status: 0, skipped: "dry-run", stdout: "", stderr: ""}
        : {status: 0, skipped: "no selected check ids", stdout: "", stderr: ""};
      if (!options.dryRun && plan.operations.checkIds.length > 0) {
        execution = executeCheckIds({ids: plan.operations.checkIds});
        if (!options.json) {
          if (execution.stdout) process.stdout.write(execution.stdout);
          if (execution.stderr) process.stderr.write(execution.stderr);
        }
        if (result.status !== 0) process.exitCode = result.status ?? 1;
      }
      printResult({plan, execution}, options.json);
      return;
    }
    if (options.command === "generate") {
      requireAffected(options);
      if (!options.checkOnly) {
        throw new UsageError(
          "Harness v2 only permits compile-codegen in explicit --check mode during shadow.",
        );
      }
      if (!plan.complete) {
        printResult(plan, options.json);
        setClassificationExitCode(plan);
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
    process.exitCode = error instanceof UsageError ? 64 : 1;
  }
}

function requireAffected(options) {
  if (!options.affected) {
    throw new UsageError(`${options.command} requires --affected to make scope explicit.`);
  }
}

export function authoritativeShadowFailure(report) {
  return (report.v1Plan.unmatchedPaths ?? []).length > 0;
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

function setClassificationExitCode(plan) {
  if (!plan.complete) process.exitCode = 1;
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
  validate
  coverage [--json]
  explain [--paths a,b | --base ref | --full] [--mode mode] [--json]
  shadow [--paths a,b | --base ref | --full] [--mode mode] [--json]
  check --affected [--paths a,b | --base ref] [--dry-run] [--json]
  generate --affected --check [--paths a,b | --base ref] [--json]

Shadow mode never replaces v1 CI output. Authoritative v1 mapping failures still
fail the command; v2-only unknown or ambiguous paths remain shadow evidence.
Compile-codegen executes only declared, deterministic, network-free checks.`);
}

class UsageError extends Error {}

if (process.argv[1] === fileURLToPath(import.meta.url)) main();
