#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fromRepo} from "../lib/repo_paths.mjs";

const args = new Set(process.argv.slice(2));
if (args.has("--self-test")) {
  const findings = validateRows([
    {path: "FeatureScreen.tsx", lines: 901},
    {path: "privatePanels.tsx", lines: 1201},
  ], {maxRouteOrWorkspaceLines: 900, maxPrivateModuleLines: 1200});
  if (findings.length !== 2) throw new Error("self-test failed to reject both oversized fixtures");
  console.log("Admin feature UI size self-test passed.");
  process.exit(0);
}

const budget = JSON.parse(fs.readFileSync(fromRepo("admin/feature-ui-size-budget.json"), "utf8"));
const rows = walk(fromRepo("admin/src/features"))
  .filter((file) => file.endsWith(".tsx") && !file.endsWith(".test.tsx"))
  .map((file) => ({
    path: path.relative(fromRepo("."), file).split(path.sep).join("/"),
    lines: fs.readFileSync(file, "utf8").split(/\r?\n/u).length,
  }));
const findings = validateRows(rows, budget);
if (findings.length > 0) {
  console.error(`Admin feature UI size check failed (${findings.length} finding(s)):`);
  findings.forEach((finding) => console.error(`- ${finding}`));
  process.exit(1);
}
const largest = rows.slice().sort((a, b) => b.lines - a.lines)[0];
console.log(
  `Admin feature UI size check passed: ${rows.length} files; largest ${largest.path} ` +
  `${largest.lines}/${budget.maxPrivateModuleLines} lines.`
);

function validateRows(rows, budget) {
  return rows.flatMap((row) => {
    const isEntry = /(?:Screen|Workspace)\.tsx$/u.test(row.path);
    const limit = isEntry ? budget.maxRouteOrWorkspaceLines : budget.maxPrivateModuleLines;
    return row.lines > limit ? [`${row.path}: ${row.lines} lines exceeds ${limit}`] : [];
  });
}

function walk(root) {
  const files = [];
  for (const entry of fs.readdirSync(root, {withFileTypes: true})) {
    const absolute = path.join(root, entry.name);
    if (entry.isDirectory()) files.push(...walk(absolute));
    else if (entry.isFile()) files.push(absolute);
  }
  return files;
}
