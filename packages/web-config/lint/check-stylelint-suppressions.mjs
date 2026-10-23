#!/usr/bin/env node
// Fails when an app's stylelint-suppressions.json allows more violations than
// its stylesheets still have. stylelint fails on any count above the recorded
// one but never lowers a count after a fix, so without this check a fixed raw
// value would leave room for a new one.
//
// Run from the app directory with the same globs its stylelint command uses:
//   node ../packages/web-config/lint/check-stylelint-suppressions.mjs "src/**/*.css"
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import stylelint from "stylelint";

const globs = process.argv.slice(2);
if (globs.length === 0) {
  console.error("Usage: check-stylelint-suppressions.mjs <glob> [glob...]");
  process.exit(2);
}

const committedPath = path.resolve("stylelint-suppressions.json");
const committed = fs.existsSync(committedPath)
  ? JSON.parse(fs.readFileSync(committedPath, "utf8"))
  : {};

const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "catch-stylelint-"));
const actualPath = path.join(scratch, "stylelint-suppressions.json");
try {
  await stylelint.lint({files: globs, suppressAll: true, suppressLocation: actualPath});
  const actual = fs.existsSync(actualPath)
    ? JSON.parse(fs.readFileSync(actualPath, "utf8"))
    : {};
  const stale = [];
  for (const [file, rules] of Object.entries(committed)) {
    for (const [rule, {count}] of Object.entries(rules)) {
      const remaining = actual[file]?.[rule]?.count ?? 0;
      if (remaining < count) stale.push(`${file}: ${rule} allows ${count}, ${remaining} remain`);
    }
  }
  if (stale.length > 0) {
    console.error("stylelint-suppressions.json allows more raw values than remain:");
    for (const line of stale) console.error(`  - ${line}`);
    console.error(`Record the fixes: npx stylelint ${globs.map((glob) => JSON.stringify(glob)).join(" ")} --suppress`);
    process.exit(1);
  }
  console.log("stylelint suppressions match the remaining violations.");
} finally {
  fs.rmSync(scratch, {recursive: true, force: true});
}
