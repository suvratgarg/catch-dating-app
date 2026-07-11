#!/usr/bin/env node
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";

const safeOrder = [
  "functions",
  "firestore:indexes",
  "firestore:rules",
  "storage",
  "hosting",
  "remoteconfig",
];
const firebaseTargetPattern =
  /^[A-Za-z0-9_.-]+(?::[A-Za-z0-9_.-]+)*$/;

export function planFirebaseDeployTargets(
  targetsCsv,
  {functionTargets = []} = {},
) {
  const selected = new Set();
  const exactFunctions = new Set();
  const extras = [];
  let deployAllFunctions = false;

  const select = (target) => selected.add(target);
  for (const rawTarget of String(targetsCsv).split(",")) {
    const target = rawTarget.trim();
    if (!target) continue;
    if (!firebaseTargetPattern.test(target)) {
      throw new Error(`Invalid Firebase deploy target: ${JSON.stringify(target)}`);
    }
    if (target === "all") {
      deployAllFunctions = true;
      for (const expanded of [
        "functions",
        "firestore:indexes",
        "firestore:rules",
        "storage",
        "hosting",
      ]) {
        select(expanded);
      }
    } else if (target === "firestore") {
      select("firestore:indexes");
      select("firestore:rules");
    } else if (target === "functions") {
      deployAllFunctions = true;
      select("functions");
    } else if (target.startsWith("functions:")) {
      exactFunctions.add(target);
      select("functions");
    } else if (safeOrder.includes(target)) {
      select(target);
    } else if (!extras.includes(target)) {
      extras.push(target);
    }
  }

  const plans = [];
  for (const phase of safeOrder) {
    if (!selected.has(phase)) continue;
    if (phase === "functions") {
      const targets = deployAllFunctions
        ? [...new Set(functionTargets)].sort()
        : [...exactFunctions].sort();
      if (targets.length === 0) {
        throw new Error("No Firebase Function targets were resolved.");
      }
      plans.push({phase, deployOnly: targets.join(",")});
    } else {
      plans.push({phase, deployOnly: phase});
    }
  }
  for (const target of extras) {
    plans.push({phase: "extra", deployOnly: target});
  }
  if (plans.length === 0) {
    throw new Error("No Firebase deploy targets were selected.");
  }
  return plans;
}

function currentFunctionTargets() {
  const result = spawnSync(
    process.execPath,
    [
      fileURLToPath(
        new URL("list_firebase_function_targets.mjs", import.meta.url),
      ),
      "--csv",
    ],
    {encoding: "utf8"},
  );
  if (result.status !== 0) {
    throw new Error(result.stderr || "Could not list Firebase Functions.");
  }
  return result.stdout.trim().split(",").filter(Boolean);
}

function main() {
  const args = process.argv.slice(2);
  const format = args.includes("--json") ? "json" : "tsv";
  const targetsCsv = args.find((arg) => !arg.startsWith("--"));
  if (!targetsCsv) {
    throw new Error(
      "Usage: node plan_firebase_deploy_targets.mjs <targets> [--json|--tsv]",
    );
  }
  const plans = planFirebaseDeployTargets(targetsCsv, {
    functionTargets: currentFunctionTargets(),
  });
  if (format === "json") {
    process.stdout.write(`${JSON.stringify(plans, null, 2)}\n`);
    return;
  }
  for (const plan of plans) {
    process.stdout.write(`${plan.phase}\t${plan.deployOnly}\n`);
  }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  try {
    main();
  } catch (error) {
    process.stderr.write(`${error.message}\n`);
    process.exitCode = 1;
  }
}
