#!/usr/bin/env node

"use strict";

const fs = require("node:fs");
const path = require("node:path");
const {spawnSync} = require("node:child_process");

const functionsRoot = path.resolve(__dirname, "..");

function discoverTestFiles(root = functionsRoot) {
  return fs.globSync(["lib/**/*.test.js", "test/**/*.test.cjs"], {cwd: root})
    .filter((file) => !file.endsWith(".rules.test.cjs"))
    .map((file) => file.split(path.sep).join("/"))
    .sort();
}

function run(argv = process.argv.slice(2)) {
  const testFiles = discoverTestFiles();
  if (argv.includes("--list")) {
    process.stdout.write(`${testFiles.join("\n")}\n`);
    return 0;
  }
  if (testFiles.length === 0) {
    console.error("No compiled Functions or harness tests were discovered.");
    return 1;
  }
  console.log(`Running ${testFiles.length} discovered Functions test files.`);
  const result = spawnSync(process.execPath, ["--test", ...testFiles], {
    cwd: functionsRoot,
    stdio: "inherit",
  });
  return result.status ?? 1;
}

if (require.main === module) {
  process.exitCode = run();
}

module.exports = {discoverTestFiles};
