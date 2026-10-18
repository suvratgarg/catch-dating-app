#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";

const root = fileURLToPath(new URL("../", import.meta.url));

try {
  // Keep the package's two intentional, nonrecursive selection roots.
  const files = ["test", "src/workflows/outreach-drafting"].flatMap((directory) => {
    let entries;
    try {
      entries = fs.readdirSync(path.join(root, directory), {withFileTypes: true});
    } catch (error) {
      if (error.code === "ENOENT") return [];
      throw error;
    }
    return entries
      .filter((entry) => entry.isFile() && !entry.name.startsWith(".") && entry.name.endsWith(".test.mjs"))
      .map((entry) => `${directory}/${entry.name}`);
  }).sort();
  if (files.length === 0) {
    throw new Error("No Operations test files were discovered in the selected roots.");
  }
  console.log(`Running ${files.length} discovered Operations test files.`);
  const result = spawnSync(process.execPath, ["--test", ...process.argv.slice(2), ...files], {
    cwd: root,
    stdio: "inherit",
  });
  if (result.error) throw result.error;
  if (result.signal) console.error(`Operations test process terminated by ${result.signal}.`);
  process.exitCode = result.status ?? 1;
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
