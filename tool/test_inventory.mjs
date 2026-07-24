#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {execFileSync} from "node:child_process";
import {fileURLToPath} from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const outputPath = path.join(repoRoot, "docs/audit_registry/test_inventory.json");

function trackedFiles() {
  return execFileSync("git", ["ls-files", "--cached", "--others", "--exclude-standard"], {cwd: repoRoot, encoding: "utf8"}).trim().split("\n").filter(Boolean);
}

export function classifyTest(file) {
  if (/^integration_test\/.*_test\.dart$/.test(file)) return "flutter_integration";
  if (/^test\/.*_test\.dart$/.test(file)) return "flutter_unit_widget";
  if (/^functions\/src\/.*\.test\.ts$/.test(file)) return "functions_source";
  if (/^functions\/test\/.*rules\.test\.cjs$/.test(file)) return "firebase_rules";
  if (/^(admin|website)\/.*\.(test|spec)\.(ts|tsx|js|mjs)$/.test(file)) return "web";
  if (/^tool\/.*(?:\.test\.mjs|_test\.dart|\.test\.sh)$/.test(file)) return "tooling";
  if (/^functions\/test\/.*\.test\.cjs$/.test(file)) return "functions_harness";
  return null;
}

export function buildInventory(files = trackedFiles()) {
  const groups = {};
  for (const file of files) {
    const category = classifyTest(file);
    if (!category) continue;
    (groups[category] ??= []).push(file);
  }
  for (const values of Object.values(groups)) values.sort();
  const categories = Object.fromEntries(Object.entries(groups).sort().map(([name, values]) => [name, {count: values.length, files: values}]));
  return {
    schemaVersion: 1,
    generatedFrom: "git ls-files --cached --others --exclude-standard",
    generatedBy: "node tool/test_inventory.mjs",
    total: Object.values(categories).reduce((sum, entry) => sum + entry.count, 0),
    categories,
  };
}

export function renderInventory(inventory = buildInventory()) {
  return `${JSON.stringify(inventory, null, 2)}\n`;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const rendered = renderInventory();
  if (process.argv.includes("--check")) {
    if (!fs.existsSync(outputPath) || fs.readFileSync(outputPath, "utf8") !== rendered) {
      console.error("Test inventory is stale. Run: node tool/test_inventory.mjs");
      process.exit(1);
    }
    console.log("Test inventory is current.");
  } else {
    fs.writeFileSync(outputPath, rendered);
    console.log(`Wrote ${path.relative(repoRoot, outputPath)}.`);
  }
}
