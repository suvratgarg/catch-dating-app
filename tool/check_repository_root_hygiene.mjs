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

function git(args, options = {}) {
  return execFileSync("git", args, {cwd: repoRoot, encoding: "utf8", ...options}).trim();
}

export function checkRepository({root = repoRoot, checkGit = true} = {}) {
  const manifest = JSON.parse(fs.readFileSync(path.join(root, "tool/repository_root_manifest.json"), "utf8"));
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
