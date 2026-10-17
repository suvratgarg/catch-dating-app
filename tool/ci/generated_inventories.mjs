#!/usr/bin/env node
import assert from "node:assert/strict";
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import {fromRepo} from "../lib/repo_paths.mjs";
import {buildInventory} from "../ui_capture/check_route_inventory.mjs";
import {buildWidgetCatalog, renderCatalogInventory, replaceCatalogInventory,
  catalogStart, catalogEnd} from "../design/generate_widget_catalog.mjs";
import {productionWidgetRoots} from "../design/lib/production_widget_roots.mjs";

const routePath = "tool/ui_capture/route_inventory.json";
const catalogPath = "docs/widget_catalog.md";
const outputs = [routePath, catalogPath];
const digest = value => crypto.createHash("sha256").update(value).digest("hex");

function git(root, ...args) {
  const result = spawnSync("git", args, {cwd: root, encoding: "utf8", maxBuffer: 16 * 1024 * 1024});
  assert.equal(result.status, 0, result.stderr || "Cannot verify inventory source.");
  return result.stdout.trim();
}

function regularDestination(root, relative) {
  let current = root;
  const segments = relative.split("/");
  for (const [index, segment] of segments.entries()) {
    current = path.join(current, segment);
    const stat = fs.lstatSync(current);
    assert.ok(!stat.isSymbolicLink(), `Inventory destination is a symlink: ${relative}`);
    assert.ok(index === segments.length - 1 ? stat.isFile() : stat.isDirectory(),
      `Invalid inventory destination: ${relative}`);
  }
  return current;
}

// These two cheap Node generators run in each consumer's exact-source checkout.
// No downloaded inventory or old checked-in generated region is authoritative.
export function materializeInventories({sourceSha, repoRoot = fromRepo(".")}) {
  assert.match(sourceSha ?? "", /^[a-f0-9]{40}$/u, "An exact source SHA is required.");
  const root = fs.realpathSync(repoRoot);
  assert.equal(git(root, "rev-parse", "HEAD"), sourceSha, "Inventory source does not match checkout HEAD.");
  assert.ok(!git(root, "ls-files", "-v", "-z").split("\0").some(entry => /^[a-zS] /u.test(entry)),
    "Inventory generation requires complete files without skip-worktree or assume-unchanged flags.");
  for (const directory of productionWidgetRoots) {
    assert.ok(fs.existsSync(path.join(root, directory)) && fs.statSync(path.join(root, directory)).isDirectory(),
      `A full source checkout is required; missing ${directory}.`);
  }
  const dirty = git(root, "diff", "HEAD", "--name-only", "-z").split("\0").filter(Boolean);
  assert.deepEqual(dirty.filter(file => !outputs.includes(file)), [], "Authored inventory inputs must match the selected commit.");
  assert.equal(git(root, "ls-files", "--others", "--exclude-standard"), "", "Untracked source cannot enter generated inventories.");
  const ignoredDart = git(root, "ls-files", "--others", "-z", "--", ...productionWidgetRoots)
    .split("\0").filter(file => file.endsWith(".dart"));
  assert.deepEqual(ignoredDart, [], "Ignored untracked Dart cannot enter exact-source inventories.");
  const destinations = outputs.map(file => regularDestination(root, file));
  const before = destinations.map(file => fs.readFileSync(file, "utf8"));
  const committedCatalog = spawnSync("git", ["show", `HEAD:${catalogPath}`], {cwd: root, encoding: "utf8"});
  assert.equal(committedCatalog.status, 0, "Cannot read authored catalog source.");
  assert.equal(replaceCatalogInventory(before[1], ""), replaceCatalogInventory(committedCatalog.stdout, ""),
    "Authored catalog guidance must match the selected commit.");
  const routes = buildInventory({repoRoot: root});
  const rows = buildWidgetCatalog({repoRoot: root});
  const region = renderCatalogInventory(rows);
  const catalog = replaceCatalogInventory(before[1], region);
  // The existing replacement validates unique, ordered markers. Assert that
  // authored guidance on both sides remains byte-for-byte unchanged as well.
  assert.equal(catalog.slice(0, catalog.indexOf(catalogStart)), before[1].slice(0, before[1].indexOf(catalogStart)));
  assert.equal(catalog.slice(catalog.indexOf(catalogEnd) + catalogEnd.length),
    before[1].slice(before[1].indexOf(catalogEnd) + catalogEnd.length));
  const after = [`${JSON.stringify(routes, null, 2)}\n`, catalog];
  // Derive and validate both complete inventories before replacing either file.
  for (const [index, destination] of destinations.entries()) {
    if (before[index] === after[index]) continue;
    const temporary = `${destination}.ci-${process.pid}.tmp`;
    try {
      fs.writeFileSync(temporary, after[index], {flag: "wx"});
      fs.renameSync(temporary, destination);
    } finally {
      if (fs.existsSync(temporary)) fs.unlinkSync(temporary);
    }
  }
  return {sourceSha, sourceTree: git(root, "rev-parse", "HEAD^{tree}"),
    routes: routes.routes.length, widgets: rows.length,
    files: outputs.map((file, index) => ({path: file, changed: before[index] !== after[index], sha256: digest(after[index])}))};
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  try {
    assert.equal(process.argv.length, 4, "Usage: node tool/ci/generated_inventories.mjs --source-sha <40-character-sha>");
    assert.equal(process.argv[2], "--source-sha", "Expected --source-sha.");
    console.log(JSON.stringify(materializeInventories({sourceSha: process.argv[3]}), null, 2));
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
