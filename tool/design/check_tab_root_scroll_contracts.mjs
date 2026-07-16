#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {repoRoot} from "../lib/repo_paths.mjs";

const defaultManifestPath = "tool/design/tab_root_scroll_contracts.json";
const branchKeyPattern =
  /StatefulShellBranch\s*\(\s*navigatorKey\s*:\s*([A-Za-z_$][\w$]*)/gu;

const isCliEntrypoint =
  process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isCliEntrypoint) runCli();

export function checkTabRootScrollContracts({
  root = repoRoot,
  manifestPath = defaultManifestPath,
} = {}) {
  const findings = [];
  const absoluteManifestPath = path.join(root, manifestPath);
  if (!fs.existsSync(absoluteManifestPath)) {
    return resultWith(findings, {
      code: "missing-manifest",
      path: manifestPath,
      message: "Tab-root scroll contract manifest does not exist.",
    });
  }

  const manifest = JSON.parse(fs.readFileSync(absoluteManifestPath, "utf8"));
  validateManifest(manifest, findings, manifestPath);
  const routerPath = manifest.routerPath;
  if (typeof routerPath !== "string" || routerPath.length === 0) {
    return summarize(manifest, findings);
  }

  const absoluteRouterPath = path.join(root, routerPath);
  if (!fs.existsSync(absoluteRouterPath)) {
    findings.push({
      code: "missing-router",
      path: routerPath,
      message: "Configured router source does not exist.",
    });
    return summarize(manifest, findings);
  }

  const routerSource = fs.readFileSync(absoluteRouterPath, "utf8");
  const actualBranchKeys = new Set(
    [...routerSource.matchAll(branchKeyPattern)].map((match) => match[1]),
  );
  const expectedBranchKeys = new Set(
    (manifest.branches ?? []).map((branch) => branch.branchKey),
  );

  for (const branchKey of actualBranchKeys) {
    if (expectedBranchKeys.has(branchKey)) continue;
    findings.push({
      code: "unregistered-branch",
      path: routerPath,
      message: `Stateful shell branch ${branchKey} has no terminal-clearance contract.`,
    });
  }
  for (const branchKey of expectedBranchKeys) {
    if (actualBranchKeys.has(branchKey)) continue;
    findings.push({
      code: "missing-branch",
      path: routerPath,
      message: `Manifest branch ${branchKey} is not declared by the router.`,
    });
  }

  const checkedOwners = new Set();
  for (const branch of manifest.branches ?? []) {
    if (
      typeof branch.routeName === "string" &&
      !routerSource.includes(branch.routeName)
    ) {
      findings.push({
        code: "missing-route-name",
        path: routerPath,
        message: `${branch.branchKey} route marker ${branch.routeName} is absent.`,
      });
    }

    for (const owner of branch.owners ?? []) {
      const ownerKey = JSON.stringify(owner);
      if (checkedOwners.has(ownerKey)) continue;
      checkedOwners.add(ownerKey);
      checkOwner({root, owner, findings});
    }
  }

  return summarize(manifest, findings);
}

function checkOwner({root, owner, findings}) {
  const relativePath = owner.path;
  const absolutePath = path.join(root, relativePath);
  if (!fs.existsSync(absolutePath)) {
    findings.push({
      code: "missing-owner",
      path: relativePath,
      message: "Declared tab-root scroll owner does not exist.",
    });
    return;
  }

  const source = fs.readFileSync(absolutePath, "utf8");
  for (const requirement of owner.requires ?? []) {
    const minimumOccurrences = requirement.minimumOccurrences ?? 1;
    const actualOccurrences = countOccurrences(source, requirement.text);
    if (actualOccurrences >= minimumOccurrences) continue;
    findings.push({
      code: "missing-required-text",
      path: relativePath,
      message:
        `Expected at least ${minimumOccurrences} occurrence(s) of ` +
        `${JSON.stringify(requirement.text)}, found ${actualOccurrences}.`,
    });
  }

  for (const forbidden of owner.forbids ?? []) {
    const actualOccurrences = countOccurrences(source, forbidden.text);
    if (actualOccurrences === 0) continue;
    findings.push({
      code: "forbidden-text",
      path: relativePath,
      message:
        `Forbidden terminal-clearance pattern ${JSON.stringify(forbidden.text)} ` +
        `appears ${actualOccurrences} time(s).`,
    });
  }
}

function validateManifest(manifest, findings, manifestPath) {
  if (manifest.schemaVersion !== 1) {
    findings.push({
      code: "invalid-schema-version",
      path: manifestPath,
      message: "schemaVersion must be 1.",
    });
  }
  if (!Array.isArray(manifest.branches) || manifest.branches.length === 0) {
    findings.push({
      code: "missing-branches",
      path: manifestPath,
      message: "branches must be a non-empty array.",
    });
    return;
  }

  const branchKeys = new Set();
  for (const branch of manifest.branches) {
    if (typeof branch.branchKey !== "string" || branch.branchKey.length === 0) {
      findings.push({
        code: "invalid-branch-key",
        path: manifestPath,
        message: "Every branch requires a non-empty branchKey.",
      });
    } else if (branchKeys.has(branch.branchKey)) {
      findings.push({
        code: "duplicate-branch-key",
        path: manifestPath,
        message: `Duplicate branch contract ${branch.branchKey}.`,
      });
    }
    branchKeys.add(branch.branchKey);
    if (!Array.isArray(branch.owners) || branch.owners.length === 0) {
      findings.push({
        code: "missing-owners",
        path: manifestPath,
        message: `${branch.branchKey ?? "unknown branch"} requires an owner.`,
      });
    }
  }
}

function countOccurrences(source, text) {
  if (typeof text !== "string" || text.length === 0) return 0;
  return source.split(text).length - 1;
}

function resultWith(findings, finding) {
  findings.push(finding);
  return {
    branchCount: 0,
    ownerCount: 0,
    findings,
  };
}

function summarize(manifest, findings) {
  const ownerPaths = new Set();
  for (const branch of manifest.branches ?? []) {
    for (const owner of branch.owners ?? []) ownerPaths.add(owner.path);
  }
  return {
    branchCount: manifest.branches?.length ?? 0,
    ownerCount: ownerPaths.size,
    findings,
  };
}

function runCli() {
  const args = process.argv.slice(2);
  if (args.includes("--help") || args.includes("-h")) {
    console.log(`Usage: node tool/design/check_tab_root_scroll_contracts.mjs [--check|--json]

Checks every StatefulShellBranch against the versioned root-scroll owner
manifest and verifies that each owner retains semantic terminal clearance.`);
    return;
  }

  const rootIndex = args.indexOf("--root");
  const root = rootIndex >= 0 ? args[rootIndex + 1] : repoRoot;
  const result = checkTabRootScrollContracts({root});
  if (args.includes("--json")) {
    console.log(JSON.stringify(result, null, 2));
  } else if (result.findings.length === 0) {
    console.log(
      `Tab-root scroll contracts: ${result.branchCount} branches, ` +
        `${result.ownerCount} owner files, 0 findings.`,
    );
  } else {
    for (const finding of result.findings) {
      console.error(`${finding.path}: ${finding.code}: ${finding.message}`);
    }
  }

  if (args.includes("--check") && result.findings.length > 0) {
    process.exitCode = 1;
  }
}
