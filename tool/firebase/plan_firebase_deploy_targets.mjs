#!/usr/bin/env node
import {fileURLToPath} from "node:url";
import {listFirebaseFunctionTargets} from "./list_firebase_function_targets.mjs";

const safeOrder = [
  "firestore:indexes",
  "functions",
  "firestore:rules",
  "storage",
];
const firebaseTargetPattern =
  /^[A-Za-z0-9_.-]+(?::[A-Za-z0-9_.-]+)*$/;
const deployGroupTargets = Object.freeze({
  functions: ["functions"],
  "firestore-indexes": ["firestore:indexes"],
  "firestore-rules": ["firestore:rules"],
  "storage-rules": ["storage"],
});

function rejectUnsafeTarget(target) {
  if (!firebaseTargetPattern.test(target)) {
    throw new Error(`Invalid Firebase deploy target: ${JSON.stringify(target)}`);
  }
  throw new Error(
    `Firebase deploy target is not allowed in automatic delivery: ${target}`,
  );
}

export function planFirebaseDeployTargets(
  targetsCsv,
  {functionTargets = []} = {},
) {
  const selected = new Set();
  const exactFunctions = new Set();
  let deployAllFunctions = false;

  for (const rawTarget of String(targetsCsv).split(",")) {
    const target = rawTarget.trim();
    if (!target) continue;
    if (target === "firestore") {
      selected.add("firestore:indexes");
      selected.add("firestore:rules");
    } else if (target === "functions") {
      deployAllFunctions = true;
      selected.add("functions");
    } else if (target.startsWith("functions:")) {
      if (!firebaseTargetPattern.test(target) || target === "functions:") {
        rejectUnsafeTarget(target);
      }
      exactFunctions.add(target);
      selected.add("functions");
    } else if (safeOrder.includes(target)) {
      selected.add(target);
    } else {
      rejectUnsafeTarget(target);
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
  if (plans.length === 0) {
    throw new Error("No Firebase deploy targets were selected.");
  }
  return plans;
}

export function planFirebaseDeployGroups(
  deployGroups,
  {functionTargets = []} = {},
) {
  if (!Array.isArray(deployGroups) || deployGroups.length === 0) {
    throw new Error("No Firebase deploy groups were selected.");
  }
  const targets = new Set();
  for (const rawGroup of deployGroups) {
    const group = String(rawGroup).trim();
    const mappedTargets = deployGroupTargets[group];
    if (!mappedTargets) {
      throw new Error(
        `CI deploy group is not allowed in automatic delivery: ${group}`,
      );
    }
    for (const target of mappedTargets) targets.add(target);
  }
  return planFirebaseDeployTargets([...targets].join(","), {functionTargets});
}

function currentFunctionTargets() {
  return listFirebaseFunctionTargets(process.env.CATCH_FIREBASE_SOURCE_ROOT);
}

function main() {
  const args = process.argv.slice(2);
  const format = args.includes("--json") ? "json" : "tsv";
  const groupsIndex = args.indexOf("--groups");
  const positionalTargets = args.filter((arg, index) =>
    !arg.startsWith("--") &&
    (groupsIndex < 0 || index !== groupsIndex + 1),
  );
  const targetsCsv = positionalTargets.length === 1 ?
    positionalTargets[0] :
    undefined;
  const groupsCsv = groupsIndex >= 0 ? args[groupsIndex + 1] : undefined;
  if (
    (!groupsCsv && positionalTargets.length !== 1) ||
    (groupsCsv && positionalTargets.length !== 0)
  ) {
    throw new Error(
      "Usage: node plan_firebase_deploy_targets.mjs <targets> [--json|--tsv] OR --groups <groups> [--json|--tsv]",
    );
  }
  const options = {functionTargets: currentFunctionTargets()};
  const plans = groupsCsv
    ? planFirebaseDeployGroups(groupsCsv.split(",").filter(Boolean), options)
    : planFirebaseDeployTargets(targetsCsv, options);
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
