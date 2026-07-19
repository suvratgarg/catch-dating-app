#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {execFileSync} from "node:child_process";
import {fileURLToPath} from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const manifestPath = path.join(repoRoot, "tool/repository_root_manifest.json");

export function matchesPattern(name, pattern) {
  const escaped = pattern.replace(/[.+^${}()|[\]\\]/g, "\\$&").replaceAll("*", ".*").replaceAll("?", ".");
  return new RegExp(`^${escaped}$`).test(name);
}

export function classify(name, manifest) {
  const matches = [];
  for (const entry of manifest.entries) if (entry.names.includes(name)) matches.push(entry);
  for (const entry of manifest.patterns) if (matchesPattern(name, entry.pattern)) matches.push(entry);
  return matches;
}

export function portableLinkViolations(markdown) {
  const violations = [];
  const link = /\]\(([^)]+)\)/g;
  for (const match of markdown.matchAll(link)) {
    const destination = match[1].trim().replace(/^<|>$/g, "");
    if (/^(?:file:\/\/|\/Users\/|[A-Za-z]:[\\/])/.test(destination)) violations.push(destination);
  }
  return violations;
}

export function matchesImpactPath(value, pattern) {
  const doubleStar = "\u0000";
  const escaped = pattern
    .replace(/[.+^${}()|[\]\\]/g, "\\$&")
    .replaceAll("**", doubleStar)
    .replaceAll("*", "[^/]*")
    .replaceAll("?", "[^/]")
    .replaceAll(doubleStar, ".*");
  return new RegExp(`^${escaped}$`).test(value);
}

export function relationshipViolations({manifest, toolIds, root, trackedPaths = []}) {
  const errors = [];
  const relationshipIds = new Set();
  for (const relationship of manifest.relationships ?? []) {
    if (!relationship.id) errors.push("relationship is missing id");
    if (relationship.id && relationshipIds.has(relationship.id)) {
      errors.push(`duplicate relationship id ${relationship.id}`);
    }
    if (relationship.id) relationshipIds.add(relationship.id);
    if (!manifest.ownerVocabulary.includes(relationship.owner)) {
      errors.push(`${relationship.id}: unknown owner ${relationship.owner}`);
    }
    const patterns = [
      ...(relationship.sources ?? []),
      ...(relationship.generatedOutputs ?? []),
      ...(relationship.consumers ?? []),
    ];
    if (patterns.length === 0) errors.push(`${relationship.id}: no path relationships`);
    for (const toolId of relationship.checks ?? []) {
      if (!toolIds.has(toolId)) errors.push(`${relationship.id}: unknown tool ${toolId}`);
    }
    for (const workflow of relationship.ciWorkflows ?? []) {
      if (!fs.existsSync(path.join(root, workflow))) {
        errors.push(`${relationship.id}: missing CI workflow ${workflow}`);
      }
    }
  }
  for (const policy of manifest.auditPolicies ?? []) {
    if (!policy.pattern) errors.push("audit policy is missing pattern");
    if (!['aggregate', 'file'].includes(policy.review)) {
      errors.push(`${policy.pattern}: invalid audit review policy ${policy.review}`);
    }
    if (!manifest.ownerVocabulary.includes(policy.owner)) {
      errors.push(`${policy.pattern}: unknown audit owner ${policy.owner}`);
    }
  }
  for (const trackedPath of trackedPaths) {
    const matched = (manifest.relationships ?? []).some((relationship) => [
      ...(relationship.sources ?? []),
      ...(relationship.generatedOutputs ?? []),
      ...(relationship.consumers ?? []),
    ].some((pattern) => matchesImpactPath(trackedPath, pattern)));
    if (!matched) errors.push(`${trackedPath}: no impact relationship`);
  }
  return errors;
}

function git(args, options = {}) {
  return execFileSync("git", args, {cwd: repoRoot, encoding: "utf8", ...options}).trim();
}

export function checkRepository({root = repoRoot, checkGit = true} = {}) {
  const manifest = JSON.parse(fs.readFileSync(path.join(root, "tool/repository_root_manifest.json"), "utf8"));
  const toolsManifest = JSON.parse(fs.readFileSync(path.join(root, "tool/tools_manifest.json"), "utf8"));
  const errors = [];
  const rootNames = fs.readdirSync(root).sort();
  for (const name of rootNames) {
    const matches = classify(name, manifest);
    if (matches.length !== 1) errors.push(`${name}: expected exactly one classification, found ${matches.length}`);
    if (manifest.prohibitedRootEntries.includes(name)) errors.push(`${name}: prohibited root entry`);
  }
  for (const entry of [...manifest.entries, ...manifest.patterns]) {
    if (!manifest.ownerVocabulary.includes(entry.owner)) errors.push(`${entry.names?.join(",") ?? entry.pattern}: unknown owner ${entry.owner}`);
    if (!entry.recovery) errors.push(`${entry.names?.join(",") ?? entry.pattern}: missing recovery command or guidance`);
    if (entry.kind === "curated-artifact" && (!entry.consumer || !fs.existsSync(path.join(root, entry.consumer)))) {
      errors.push(`${entry.names?.join(",")}: curated artifact lacks an existing consumer manifest`);
    }
  }
  for (const target of manifest.cleanupTargets) {
    if (manifest.protectedPaths.some((protectedPath) => target.path === protectedPath || target.path.startsWith(`${protectedPath}/`))) {
      errors.push(`${target.path}: cleanup target overlaps protected path`);
    }
  }
  const trackedPaths = checkGit && root === repoRoot ?
    git(["ls-files"]).split("\n").filter(Boolean) : [];
  errors.push(...relationshipViolations({
    manifest,
    toolIds: new Set((toolsManifest.tools ?? []).map((tool) => tool.id)),
    root,
    trackedPaths,
  }));
  if (checkGit && root === repoRoot) {
    const trackedIgnored = git(["ls-files", "-ci", "--exclude-standard"]);
    if (trackedIgnored) errors.push(`tracked files are also ignored:\n${trackedIgnored}`);
    for (const name of rootNames) {
      const [entry] = classify(name, manifest);
      if (!entry) continue;
      const tracked = Boolean(git(["ls-files", "--cached", "--others", "--exclude-standard", "--", name]));
      let ignored = false;
      try { execFileSync("git", ["check-ignore", "-q", "--", name], {cwd: repoRoot}); ignored = true; } catch {}
      if (entry.expectation === "tracked" && !tracked) errors.push(`${name}: expected tracked content`);
      if (entry.expectation === "ignored" && !ignored) errors.push(`${name}: expected Git ignore coverage`);
      if (entry.expectation === "ignored-or-unmanaged" && tracked) errors.push(`${name}: protected local entry must not be tracked`);
    }
    const markdownFiles = git(["ls-files", "*.md"]).split("\n").filter(Boolean);
    for (const relative of markdownFiles) {
      if (!fs.existsSync(path.join(repoRoot, relative))) continue;
      const violations = portableLinkViolations(fs.readFileSync(path.join(repoRoot, relative), "utf8"));
      for (const destination of violations) errors.push(`${relative}: non-portable Markdown link ${destination}`);
    }
  }
  return errors;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const errors = checkRepository();
  if (errors.length) {
    console.error("Repository root hygiene check failed:");
    for (const error of errors) console.error(`- ${error}`);
    process.exit(1);
  }
  console.log("Repository root hygiene check passed.");
}
