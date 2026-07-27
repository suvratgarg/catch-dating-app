#!/usr/bin/env node

import fs from "node:fs";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import {fromRepo, repoRoot} from "../lib/repo_paths.mjs";

const manifestPath = fromRepo("tool/repository_root_manifest.json");
const outputNames = {
  admin: "admin",
  contracts: "contracts",
  doc_state: "doc_state",
  firestore_rules: "firestore_rules",
  flutter: "flutter",
  flutter_build_android: "flutter_build_android",
  flutter_build_ios: "flutter_build_ios",
  flutter_build_web: "flutter_build_web",
  functions: "functions",
  marketing: "marketing",
  operations: "operations",
  tools: "tools",
  visual_integration: "visual_integration",
};

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

export function validateCiPlanning(ciPlanning) {
  const errors = [];
  const targets = new Set(ciPlanning?.targets ?? []);
  const ruleIds = new Set();

  if (!ciPlanning || typeof ciPlanning !== "object") {
    return ["repository_root_manifest.json must define ciPlanning."];
  }
  if (targets.size === 0) errors.push("ciPlanning.targets must not be empty.");
  for (const target of targets) {
    if (!(target in outputNames)) {
      errors.push(`ciPlanning target "${target}" has no stable workflow output.`);
    }
  }
  for (const target of ciPlanning.fullValidationTargets ?? []) {
    if (!targets.has(target)) {
      errors.push(`Unknown full-validation target "${target}".`);
    }
  }
  for (const rule of ciPlanning.rules ?? []) {
    if (!rule.id) errors.push("CI planning rule is missing id.");
    if (ruleIds.has(rule.id)) errors.push(`Duplicate CI planning rule id: ${rule.id}`);
    ruleIds.add(rule.id);
    if (!Array.isArray(rule.patterns) || rule.patterns.length === 0) {
      errors.push(`${rule.id ?? "<missing>"} must declare patterns.`);
    }
    if (!Array.isArray(rule.targets) || rule.targets.length === 0) {
      errors.push(`${rule.id ?? "<missing>"} must declare targets.`);
    }
    for (const target of rule.targets ?? []) {
      if (!targets.has(target)) {
        errors.push(`${rule.id ?? "<missing>"} references unknown target "${target}".`);
      }
    }
    for (const role of rule.mobileRoles ?? []) {
      if (!["consumer", "host"].includes(role)) {
        errors.push(`${rule.id ?? "<missing>"} references unknown mobile role "${role}".`);
      }
    }
    if (
      rule.backendDeploy !== undefined &&
      typeof rule.backendDeploy !== "boolean"
    ) {
      errors.push(`${rule.id ?? "<missing>"}.backendDeploy must be boolean.`);
    }
  }
  return errors;
}

export function planCi({changedPaths, ciPlanning, full = false}) {
  const errors = validateCiPlanning(ciPlanning);
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }

  const matchedRuleIds = new Set();
  const targets = new Set(full ? ciPlanning.fullValidationTargets : []);
  const mobileRoles = new Set();
  let backendDeployRequired = false;
  const unmatchedPaths = [];
  const pathMatches = {};

  for (const changedPath of [...new Set(changedPaths)].sort()) {
    const rule = ciPlanning.rules.find((candidate) =>
      candidate.patterns.some((pattern) => matchesGlob(changedPath, pattern))
    );
    if (!rule) {
      unmatchedPaths.push(changedPath);
      continue;
    }
    pathMatches[changedPath] = rule.id;
    matchedRuleIds.add(rule.id);
    for (const target of rule.targets) targets.add(target);
    for (const role of rule.mobileRoles ?? []) mobileRoles.add(role);
    if (rule.backendDeploy === true) backendDeployRequired = true;
  }

  const enabled = Object.fromEntries(
    Object.entries(outputNames).map(([target, output]) => [output, targets.has(target)]),
  );
  const orderedMobileReleaseRoles = ["consumer", "host"].filter(
    (role) => mobileRoles.has(role),
  );
  const hasAppBuild = [
    enabled.flutter_build_android,
    enabled.flutter_build_ios,
    enabled.flutter_build_web,
  ].some(Boolean);
  const appRoles = hasAppBuild && orderedMobileReleaseRoles.length === 0
    ? ["consumer", "host"]
    : orderedMobileReleaseRoles;

  return {
    schemaVersion: ciPlanning.version,
    full,
    changedPaths: [...new Set(changedPaths)].sort(),
    pathMatches,
    matchedRules: [...matchedRuleIds].sort(),
    targets: [...targets].sort(),
    enabled,
    appRoles,
    appRolesJson: JSON.stringify(appRoles),
    mobileReleaseRoles: orderedMobileReleaseRoles,
    mobileReleaseRolesJson: JSON.stringify(orderedMobileReleaseRoles),
    backendDeployRequired,
    unmatchedPaths,
  };
}

function changedPathsBetween(base, head) {
  const result = spawnSync("git", ["diff", "--name-only", `${base}...${head}`], {
    cwd: repoRoot,
    encoding: "utf8",
  });
  if (result.status !== 0) {
    throw new Error(result.stderr || `Unable to diff ${base}...${head}.`);
  }
  return result.stdout.split(/\r?\n/).filter(Boolean);
}

function valueAfter(args, flag) {
  const index = args.indexOf(flag);
  if (index === -1) return null;
  const value = args[index + 1];
  if (!value || value.startsWith("--")) throw new Error(`${flag} requires a value.`);
  return value;
}

function parseArgs(args) {
  const paths = valueAfter(args, "--paths");
  return {
    base: valueAfter(args, "--base") ?? "origin/main",
    head: valueAfter(args, "--head") ?? "HEAD",
    paths: paths == null
      ? null
      : paths.split(",").map((value) => value.trim()).filter(Boolean),
    full: args.includes("--full"),
    githubOutput: valueAfter(args, "--github-output"),
    json: args.includes("--json"),
  };
}

export function writeGithubOutputs(outputPath, plan) {
  const lines = [
    `app_roles=${plan.appRolesJson}`,
    `mobile_release_roles=${plan.mobileReleaseRolesJson}`,
    `has_mobile_release_roles=${plan.mobileReleaseRoles.length > 0}`,
    `backend_deploy_required=${plan.backendDeployRequired}`,
    `full=${plan.full}`,
    ...Object.entries(plan.enabled).map(([name, enabled]) => `${name}=${enabled}`),
  ];
  fs.appendFileSync(outputPath, `${lines.join("\n")}\n`);
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  const rootManifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
  const changedPaths = options.paths ?? (
    options.full ? [] : changedPathsBetween(options.base, options.head)
  );
  const plan = planCi({
    changedPaths,
    ciPlanning: rootManifest.ciPlanning,
    full: options.full,
  });

  if (options.json || !options.githubOutput) {
    console.log(JSON.stringify(plan, null, 2));
  }
  if (options.githubOutput) writeGithubOutputs(options.githubOutput, plan);
  if (plan.unmatchedPaths.length > 0) {
    console.error(`Unmapped CI paths: ${plan.unmatchedPaths.join(", ")}`);
    process.exitCode = 1;
  }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  main();
}
