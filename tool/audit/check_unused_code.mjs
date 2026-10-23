#!/usr/bin/env node
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {parseArgs} from "node:util";
import {fileURLToPath} from "node:url";
import {fromRepo, repoRoot} from "../lib/repo_paths.mjs";

// Shrink-only ratchet over Knip (tool/audit/knip.jsonc): unused files, exports,
// types and dependencies, plus imports of packages a workspace does not declare.
// A new finding fails; a fixed one must leave the baseline in the same change.
// Each CI lane checks the workspaces it owns with --workspace.
export const configPath = fromRepo("tool/audit/knip.jsonc");
export const defaultBaselinePath = fromRepo("tool/audit/unused_code_baseline.json");
export const workspaces = Object.freeze(["admin", "website", "packages/web-ui", "packages/web-config", "functions", "."]);

export function workspaceOf(file) {
  return workspaces.find((name) => name !== "." && file.startsWith(`${name}/`)) ?? ".";
}

/** Stable finding keys from Knip's JSON reporter. */
export function findingKeys(report) {
  const keys = [];
  for (const issue of report.issues ?? []) {
    const file = issue.file;
    if ((issue.files ?? []).length > 0) keys.push(`file ${file}`);
    for (const [kind, entries] of [["export", issue.exports], ["type", issue.types],
      ["unlisted", issue.unlisted], ["unresolved", issue.unresolved],
      ["dependency", issue.dependencies], ["devDependency", issue.devDependencies],
      ["binary", issue.binaries]]) {
      for (const entry of entries ?? []) keys.push(`${kind} ${file} ${entry.name}`);
    }
    for (const group of issue.duplicates ?? []) {
      keys.push(`duplicate ${file} ${group.map((entry) => entry.name).sort().join("|")}`);
    }
  }
  return [...new Set(keys)].sort();
}

/** Findings new since the baseline, and baseline entries now fixed, within scope. */
export function compare({found, baseline, scope}) {
  const inScope = (key) => scope.includes(workspaceOf(key.split(" ")[1]));
  const known = new Set(baseline.filter(inScope));
  const current = new Set(found.filter(inScope));
  return {
    added: [...current].filter((key) => !known.has(key)),
    fixed: [...known].filter((key) => !current.has(key)),
  };
}

/** The baseline with this scope's fixed findings removed; refuses to grow. */
export function shrinkBaseline({baseline, added, fixed}) {
  assert.deepEqual(added, [], `The baseline only shrinks. Remove these new findings instead:\n${added.join("\n")}`);
  return baseline.filter((key) => !fixed.includes(key));
}

function runKnip(scope) {
  const binary = path.join(repoRoot, "node_modules", ".bin", "knip");
  assert.ok(fs.existsSync(binary), "Knip is not installed; run npm ci at the repository root.");
  const args = ["--config", configPath, "--reporter", "json", "--no-exit-code", "--no-progress",
    ...scope.flatMap((name) => ["--workspace", name])];
  const result = spawnSync(binary, args, {cwd: repoRoot, encoding: "utf8", maxBuffer: 64 * 1024 * 1024});
  assert.equal(result.status, 0, result.stderr || "Knip failed.");
  return JSON.parse(result.stdout);
}

export function main(argv = process.argv.slice(2), {baselinePath = defaultBaselinePath, knip = runKnip} = {}) {
  const {values} = parseArgs({args: argv, options: {
    check: {type: "boolean"}, update: {type: "boolean"},
    workspace: {type: "string", multiple: true},
  }});
  assert.ok(values.check !== values.update, "Pass exactly one of --check or --update.");
  const scope = values.workspace?.length ? values.workspace : [...workspaces];
  for (const name of scope) assert.ok(workspaces.includes(name), `Unknown workspace: ${name}`);
  const baseline = JSON.parse(fs.readFileSync(baselinePath, "utf8")).findings;
  const {added, fixed} = compare({found: findingKeys(knip(scope)), baseline, scope});
  if (values.update) {
    const findings = shrinkBaseline({baseline, added, fixed});
    fs.writeFileSync(baselinePath, `${JSON.stringify({version: 1, findings}, null, 2)}\n`);
    console.log(`Removed ${fixed.length} fixed findings from the baseline.`);
    return 0;
  }
  if (added.length) console.error(`New unused code or undeclared imports (Knip):\n${added.join("\n")}`);
  if (fixed.length) {
    console.error(`Fixed findings still listed in ${path.relative(repoRoot, baselinePath)}; ` +
      `run node tool/audit/check_unused_code.mjs --update${scope.map((name) => ` --workspace ${name}`).join("")}:\n` +
      fixed.join("\n"));
  }
  if (added.length || fixed.length) return 1;
  console.log(`Unused-code ratchet passed for ${scope.join(", ")}.`);
  return 0;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) process.exitCode = main();
