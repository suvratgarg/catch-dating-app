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
  for (const shell of manifest.shells ?? []) {
    const shellKey = JSON.stringify(shell);
    if (checkedOwners.has(shellKey)) continue;
    checkedOwners.add(shellKey);
    checkOwner({root, owner: shell, findings, ownerKind: "shell contract"});
  }
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
      checkOwner({root, owner, findings, ownerKind: "scroll owner"});
    }
  }

  checkStateViewportOwnership({root, findings});

  return summarize(manifest, findings);
}

function checkStateViewportOwnership({root, findings}) {
  const libRoot = path.join(root, "lib");
  if (!fs.existsSync(libRoot)) return;
  for (const absolutePath of dartFiles(libRoot)) {
    const relativePath = path.relative(root, absolutePath).split(path.sep).join("/");
    if (!relativePath.includes("/presentation/")) continue;
    const source = fs.readFileSync(absolutePath, "utf8");
    for (const block of callBlocks(source, "SliverFillRemaining")) {
      if (!/Catch(?:Empty|Error)State(?:\.fromError)?\s*\(/u.test(block)) {
        continue;
      }
      findings.push({
        code: "raw-sliver-state-viewport",
        path: relativePath,
        message:
          "Empty and error slivers must use CatchSliverStateViewport, " +
          "CatchSliverEmptyState, or CatchSliverErrorState so shell overlay " +
          "geometry is applied consistently.",
      });
    }
  }
}

function* dartFiles(directory) {
  for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
    const entryPath = path.join(directory, entry.name);
    if (entry.isDirectory()) yield* dartFiles(entryPath);
    else if (entry.isFile() && entry.name.endsWith(".dart")) yield entryPath;
  }
}

function callBlocks(source, callName) {
  const blocks = [];
  const marker = `${callName}(`;
  let cursor = 0;
  while ((cursor = source.indexOf(marker, cursor)) >= 0) {
    let depth = 0;
    let end = cursor + marker.length;
    for (let index = cursor + callName.length; index < source.length; index++) {
      if (source[index] === "(") depth += 1;
      if (source[index] === ")") depth -= 1;
      if (depth === 0) {
        end = index + 1;
        break;
      }
    }
    blocks.push(source.slice(cursor, end));
    cursor = end;
  }
  return blocks;
}

function checkOwner({root, owner, findings, ownerKind}) {
  const relativePath = owner.path;
  const absolutePath = path.join(root, relativePath);
  if (!fs.existsSync(absolutePath)) {
    findings.push({
      code: "missing-owner",
      path: relativePath,
      message: `Declared tab-root ${ownerKind} does not exist.`,
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
  if (manifest.schemaVersion !== 2) {
    findings.push({
      code: "invalid-schema-version",
      path: manifestPath,
      message: "schemaVersion must be 2.",
    });
  }
  if (!Array.isArray(manifest.shells) || manifest.shells.length === 0) {
    findings.push({
      code: "missing-shells",
      path: manifestPath,
      message: "shells must register the adaptive consumer and Host owners.",
    });
  } else {
    for (const shell of manifest.shells) {
      if (typeof shell.path !== "string" || shell.path.length === 0) {
        findings.push({
          code: "invalid-shell-path",
          path: manifestPath,
          message: "Every shell contract requires a non-empty path.",
        });
      }
      if (!Array.isArray(shell.requires) || shell.requires.length === 0) {
        findings.push({
          code: "missing-shell-requirements",
          path: manifestPath,
          message: `${shell.path ?? "unknown shell"} requires adoption markers.`,
        });
      }
    }
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
    shellCount: 0,
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
    shellCount: manifest.shells?.length ?? 0,
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
manifest, verifies semantic terminal clearance, and rejects raw empty/error
SliverFillRemaining composition in presentation code.`);
    return;
  }

  const rootIndex = args.indexOf("--root");
  const root = rootIndex >= 0 ? args[rootIndex + 1] : repoRoot;
  const result = checkTabRootScrollContracts({root});
  if (args.includes("--json")) {
    console.log(JSON.stringify(result, null, 2));
  } else if (result.findings.length === 0) {
    console.log(
      `Tab-root scroll contracts: ${result.shellCount} shells, ` +
        `${result.branchCount} branches, ` +
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
