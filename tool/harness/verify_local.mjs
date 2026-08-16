#!/usr/bin/env node
/**
 * Run the CI gates that apply to the current change, derived from the workflow
 * definitions rather than from a hand-maintained list.
 *
 *   node tool/harness/verify_local.mjs --base origin/main            # run them
 *   node tool/harness/verify_local.mjs --base origin/main --list     # show them
 *   node tool/harness/verify_local.mjs --base origin/main --json
 *   node tool/harness/verify_local.mjs --target flutter --list       # one target
 *
 * Motivation: every prompt, checklist and doc in this repository that restated
 * "the gates to run" has drifted from CI at least once, and each drift cost a
 * CI round-trip or shipped a defect. `tool/harness.mjs plan` already resolves
 * *which* CI targets a diff affects, but it emits identifiers, so turning them
 * into commands stayed a from-memory step. This closes that gap: identifiers in,
 * the workflow's own commands out.
 *
 * Fail-closed by design. A ciTarget with no matching workflow, or a workflow
 * whose steps cannot be parsed, is an error — not an empty run. Silently
 * verifying nothing is the failure mode this tool exists to prevent.
 */

import {spawnSync} from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import process from "node:process";

import {deriveTargetWorkflows, extractSteps, workflowForTarget} from "./lib/workflow_steps.mjs";

const WORKFLOW_DIR = ".github/workflows";

function parseArgs(argv) {
  const args = {base: "origin/main", head: "HEAD", list: false, json: false, targets: []};
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--list") args.list = true;
    else if (arg === "--json") args.json = true;
    else if (arg === "--base") args.base = argv[++i];
    else if (arg === "--head") args.head = argv[++i];
    else if (arg === "--target") args.targets.push(argv[++i]);
    else if (arg === "--help" || arg === "-h") args.help = true;
    else throw new Error(`unknown argument: ${arg}`);
  }
  return args;
}

function resolveTargets({base, head}) {
  const result = spawnSync(
    "node",
    ["tool/harness.mjs", "plan", "--base", base, "--head", head, "--json"],
    {encoding: "utf8"},
  );
  // The planner exits non-zero when it cannot map every changed path, but it
  // still emits a usable plan. Treat that as "incomplete", not "unavailable":
  // the useful response is to run the gates it did resolve and say loudly which
  // paths were unmapped, rather than to refuse and leave the change unverified.
  let plan;
  try {
    plan = JSON.parse(result.stdout);
  } catch {
    throw new Error(
      `harness plan failed (exit ${result.status}) and produced no plan:\n` +
      `${result.stderr || result.stdout}`,
    );
  }
  return {
    targets: plan.operations?.ciTargets ?? [],
    changedPaths: plan.changedPaths ?? [],
    complete: plan.complete !== false,
    unknownPaths: plan.unknownPaths ?? [],
  };
}

function collectGates(targets) {
  const available = fs.readdirSync(WORKFLOW_DIR).filter((f) => f.endsWith(".yml"));
  const derived = deriveTargetWorkflows(
    fs.readFileSync(path.join(WORKFLOW_DIR, "ci.yml"), "utf8"),
  );
  const gates = [];
  const unresolved = [];
  const seen = new Set();

  for (const target of targets) {
    const workflows = workflowForTarget(target, available, derived);
    if (workflows.length === 0) {
      unresolved.push(target);
      continue;
    }
    for (const workflow of workflows) {
      const source = fs.readFileSync(path.join(WORKFLOW_DIR, workflow), "utf8");
      const steps = extractSteps(source);
      if (steps.length === 0) {
        unresolved.push(`${target} (no steps parsed from ${workflow})`);
        continue;
      }
      for (const step of steps) {
        if (!step.runnable) continue;
        // Targets share workflows (android/ios/web all route to the build
        // matrix); running a gate once per target would multiply the cost of
        // a full verification for no additional coverage.
        const key = `${workflow}::${step.name}::${step.run}`;
        if (seen.has(key)) continue;
        seen.add(key);
        gates.push({target, workflow, name: step.name, command: step.run});
      }
    }
  }
  return {gates, unresolved};
}

function runGate(gate) {
  const started = Date.now();
  const result = spawnSync("bash", ["-c", gate.command], {stdio: "inherit"});
  return {...gate, status: result.status ?? 1, seconds: Math.round((Date.now() - started) / 1000)};
}

function main() {
  let args;
  try {
    args = parseArgs(process.argv.slice(2));
  } catch (error) {
    console.error(String(error.message));
    process.exit(2);
  }
  if (args.help) {
    console.log(fs.readFileSync(new URL(import.meta.url), "utf8").split("*/")[0]);
    return;
  }

  let targets;
  let context = {};
  if (args.targets.length > 0) {
    targets = args.targets;
  } else {
    const resolved = resolveTargets(args);
    targets = resolved.targets;
    context = resolved;
  }

  const {gates, unresolved} = collectGates(targets);

  if (unresolved.length > 0) {
    console.error(
      `error: no workflow resolved for ciTarget(s): ${unresolved.join(", ")}\n` +
      `The harness component graph and ${WORKFLOW_DIR}/ have diverged. Fix the ` +
      `mapping in tool/harness/lib/workflow_steps.mjs rather than ignoring the target.`,
    );
    process.exit(2);
  }

  if (args.json) {
    console.log(JSON.stringify({targets, gates, ...context}, null, 2));
    return;
  }

  if (targets.length === 0) {
    console.log("No CI targets affected by this change.");
    return;
  }

  console.log(`CI targets affected: ${targets.join(", ")}`);
  if (context.unknownPaths?.length) {
    console.log(`warning: ${context.unknownPaths.length} path(s) unmapped by the harness ` +
      `(${context.unknownPaths.slice(0, 3).join(", ")}) — coverage may be incomplete.`);
  }
  console.log(`${gates.length} locally-runnable gate(s):\n`);

  if (args.list) {
    let lastWorkflow = null;
    for (const gate of gates) {
      if (gate.workflow !== lastWorkflow) {
        console.log(`  ── ${gate.workflow}`);
        lastWorkflow = gate.workflow;
      }
      console.log(`  ${gate.name}`);
      for (const line of gate.command.split("\n")) console.log(`      ${line}`);
    }
    return;
  }

  const results = [];
  for (const [index, gate] of gates.entries()) {
    console.log(`\n[${index + 1}/${gates.length}] ${gate.name}  (${gate.workflow})`);
    results.push(runGate(gate));
  }

  const failed = results.filter((r) => r.status !== 0);
  console.log(`\n${"─".repeat(60)}`);
  for (const r of results) {
    console.log(`  ${r.status === 0 ? "pass" : "FAIL"}  ${String(r.seconds).padStart(4)}s  ${r.name}`);
  }
  console.log(`${results.length - failed.length}/${results.length} gate(s) passed.`);
  process.exit(failed.length === 0 ? 0 : 1);
}

main();
