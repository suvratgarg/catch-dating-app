#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const moduleDir = path.dirname(fileURLToPath(import.meta.url));
const defaultRoot = path.resolve(moduleDir, "../..");

export const packageGraphPolicy = Object.freeze({
  catch_tokens: {
    projectRoot: "packages/catch_tokens",
    requiredPackages: ["flutter"],
    allowedPackages: ["flutter"],
    forbiddenPackages: [],
    requiredPlugins: [],
    forbiddenPlugins: [],
  },
  catch_ui: {
    projectRoot: "packages/catch_ui",
    requiredPackages: ["flutter", "catch_tokens", "phosphor_flutter"],
    allowedPackages: ["flutter", "catch_tokens", "phosphor_flutter"],
    forbiddenPackages: [],
    requiredPlugins: [],
    forbiddenPlugins: [],
  },
  consumer: {
    projectRoot: "apps/consumer",
    requiredPackages: ["health", "razorpay_flutter"],
    forbiddenPackages: [],
    requiredPlugins: ["health", "razorpay_flutter"],
    forbiddenPlugins: [],
  },
  host: {
    projectRoot: "apps/host",
    requiredPackages: [],
    forbiddenPackages: ["health", "razorpay_flutter"],
    requiredPlugins: [],
    forbiddenPlugins: ["health", "razorpay_flutter"],
  },
});

export function declaredPackageNamesFromPubspec(source) {
  const names = new Set();
  let inDependencies = false;
  for (const line of source.split(/\r?\n/u)) {
    if (line === "dependencies:") {
      inDependencies = true;
      continue;
    }
    if (inDependencies && /^\S/u.test(line) && line.trim().length > 0) break;
    const match = inDependencies
      ? line.match(/^  ([a-zA-Z0-9_]+):(?:\s+.*)?$/u)
      : null;
    if (match) names.add(match[1]);
  }
  return names;
}

export function pluginNamesFromMetadata(source) {
  const metadata = JSON.parse(source);
  const names = new Set();
  for (const plugins of Object.values(metadata.plugins ?? {})) {
    for (const plugin of plugins ?? []) {
      if (plugin?.name) names.add(plugin.name);
    }
  }
  return names;
}

export function validateRoleGraph({
  role,
  declaredPackages,
  pluginPackages,
  policy = packageGraphPolicy,
}) {
  const contract = policy[role];
  if (!contract) return [`Unknown app role '${role}'.`];
  const findings = [];
  for (const packageName of contract.requiredPackages) {
    if (!declaredPackages.has(packageName)) {
      findings.push(`${role}: required package '${packageName}' is absent.`);
    }
  }
  for (const packageName of contract.forbiddenPackages) {
    if (declaredPackages.has(packageName)) {
      findings.push(`${role}: forbidden package '${packageName}' is present.`);
    }
  }
  for (const packageName of declaredPackages) {
    if (contract.allowedPackages && !contract.allowedPackages.includes(packageName)) {
      findings.push(`${role}: dependency '${packageName}' is outside the ${role === "catch_tokens" ? "Flutter-only token" : "presentation-only UI"} boundary.`);
    }
  }
  for (const pluginName of contract.requiredPlugins) {
    if (!pluginPackages.has(pluginName)) {
      findings.push(`${role}: required native plugin '${pluginName}' is absent.`);
    }
  }
  for (const pluginName of contract.forbiddenPlugins) {
    if (pluginPackages.has(pluginName)) {
      findings.push(`${role}: forbidden native plugin '${pluginName}' is present.`);
    }
  }
  return findings;
}

export function scanAppPackageGraphs({
  root = defaultRoot,
  policy = packageGraphPolicy,
} = {}) {
  const findings = [];
  const reports = {};
  for (const [role, contract] of Object.entries(policy)) {
    const projectRoot = path.join(root, contract.projectRoot);
    const pubspecPath = path.join(projectRoot, "pubspec.yaml");
    const pluginsPath = path.join(projectRoot, ".flutter-plugins-dependencies");
    if (!fs.existsSync(pubspecPath)) {
      findings.push(`${role}: missing ${path.relative(root, pubspecPath)}.`);
      continue;
    }
    const pubspecSource = fs.readFileSync(pubspecPath, "utf8");
    if (!/^resolution:\s+workspace\s*$/mu.test(pubspecSource)) {
      findings.push(`${role}: pubspec must use the repository workspace lock.`);
    }
    const declaredPackages = declaredPackageNamesFromPubspec(pubspecSource);
    const policyPluginNames = new Set([
      ...contract.requiredPlugins,
      ...contract.forbiddenPlugins,
    ]);
    const hasGeneratedPluginMetadata = fs.existsSync(pluginsPath);
    const pluginPackages = hasGeneratedPluginMetadata
      ? pluginNamesFromMetadata(fs.readFileSync(pluginsPath, "utf8"))
      : new Set(
          [...declaredPackages].filter((packageName) =>
            policyPluginNames.has(packageName)
          ),
        );
    findings.push(
      ...validateRoleGraph({
        role,
        declaredPackages,
        pluginPackages,
        policy,
      }),
    );
    reports[role] = {
      projectRoot: contract.projectRoot,
      declaredPackageCount: declaredPackages.size,
      pluginCount: pluginPackages.size,
      pluginMetadataSource: hasGeneratedPluginMetadata
        ? "flutter-generated"
        : "declared-policy-plugins",
      hasHealth: declaredPackages.has("health"),
      hasRazorpay: declaredPackages.has("razorpay_flutter"),
    };
  }
  return {findings, reports};
}

function runCli() {
  const result = scanAppPackageGraphs();
  console.log(JSON.stringify(result, null, 2));
  if (result.findings.length > 0) process.exitCode = 1;
}

const isMain = process.argv[1]
  ? path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)
  : false;
if (isMain) runCli();
