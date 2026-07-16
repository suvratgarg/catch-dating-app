#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {execFileSync} from "node:child_process";
import {fileURLToPath} from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const manifest = JSON.parse(fs.readFileSync(path.join(repoRoot, "tool/repository_root_manifest.json"), "utf8"));
const args = process.argv.slice(2);
const apply = args.includes("--apply");
const json = args.includes("--json");
const scopeIndex = args.indexOf("--scope");
const requestedScope = scopeIndex >= 0 ? args[scopeIndex + 1] : "all-regenerable";
const scopeAliases = {
  "all-regenerable": new Set(["flutter", "native", "node", "evidence", "logs", "ide", "all-regenerable"]),
  flutter: new Set(["flutter"]), native: new Set(["native"]), node: new Set(["node"]),
  evidence: new Set(["evidence"]), logs: new Set(["logs"]), ide: new Set(["ide"]),
};
if (!scopeAliases[requestedScope]) fail(`Unknown scope: ${requestedScope}`);
if (apply && scopeIndex < 0) fail("Mutation requires an explicit --scope.");

function fail(message) { console.error(message); process.exit(64); }
function isTracked(relative) {
  const tracked = execFileSync("git", ["ls-files", "--", relative], {cwd: repoRoot, encoding: "utf8"}).trim().split("\n").filter(Boolean);
  return tracked.some((file) => fs.existsSync(path.join(repoRoot, file)));
}
function sizeOf(target) {
  const stat = fs.lstatSync(target);
  if (stat.isSymbolicLink()) throw new Error(`refusing symlink: ${path.relative(repoRoot, target)}`);
  if (!stat.isDirectory()) return stat.size;
  return fs.readdirSync(target).reduce((sum, name) => sum + sizeOf(path.join(target, name)), 0);
}
function selectRetentionChildren(target, days) {
  const cutoff = Date.now() - days * 86400000;
  return fs.readdirSync(target).map((name) => path.join(target, name)).filter((child) => fs.lstatSync(child).mtimeMs < cutoff);
}

const candidates = [];
for (const target of manifest.cleanupTargets) {
  if (!scopeAliases[requestedScope].has(target.scope)) continue;
  const absolute = path.resolve(repoRoot, target.path);
  if (absolute !== repoRoot && !absolute.startsWith(`${repoRoot}${path.sep}`)) throw new Error(`path escapes repository: ${target.path}`);
  if (!fs.existsSync(absolute)) continue;
  const selected = target.contentsOnly ? selectRetentionChildren(absolute, target.retentionDays ?? 14) : [absolute];
  for (const item of selected) {
    const relative = path.relative(repoRoot, item);
    if (!relative || relative.startsWith("..")) throw new Error(`refusing unsafe path: ${relative}`);
    if (manifest.protectedPaths.some((p) => relative === p || relative.startsWith(`${p}/`))) throw new Error(`refusing protected path: ${relative}`);
    if (isTracked(relative)) throw new Error(`refusing tracked path: ${relative}`);
    candidates.push({path: relative, bytes: sizeOf(item), reason: target.reason, scope: target.scope});
  }
}
for (const pattern of manifest.patterns.filter((entry) => entry.cleanable && scopeAliases[requestedScope].has(entry.scope))) {
  const regex = new RegExp(`^${pattern.pattern.replace(/[.+^${}()|[\]\\]/g, "\\$&").replaceAll("*", ".*").replaceAll("?", ".")}$`);
  for (const name of fs.readdirSync(repoRoot)) {
    if (!regex.test(name)) continue;
    const absolute = path.join(repoRoot, name);
    if (isTracked(name)) throw new Error(`refusing tracked path: ${name}`);
    candidates.push({path: name, bytes: sizeOf(absolute), reason: `Generated ${pattern.kind}`, scope: pattern.scope});
  }
}
const unique = [...new Map(candidates.map((entry) => [entry.path, entry])).values()].sort((a, b) => a.path.localeCompare(b.path));
if (apply) for (const entry of unique) fs.rmSync(path.join(repoRoot, entry.path), {recursive: true, force: true});
const result = {mode: apply ? "apply" : "dry-run", scope: requestedScope, candidates: unique, totalBytes: unique.reduce((sum, entry) => sum + entry.bytes, 0)};
if (json) console.log(JSON.stringify(result, null, 2));
else {
  console.log(`Repository hygiene ${result.mode} (${requestedScope}): ${unique.length} paths, ${result.totalBytes} bytes`);
  for (const entry of unique) console.log(`- ${entry.path} (${entry.bytes} bytes): ${entry.reason}`);
}
