#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import {fileURLToPath} from "node:url";

const isCliEntrypoint =
  process.argv[1] != null &&
  fileURLToPath(import.meta.url) === path.resolve(process.argv[1]);

export function parseWidgetCleanupSummary(source) {
  const counts = {};
  for (const line of String(source).split(/\r?\n/u)) {
    const match = /^\s{2}([a-z0-9_]+):\s+(\d+)\s*$/u.exec(line);
    if (!match) continue;
    counts[match[1]] = Number.parseInt(match[2], 10);
  }
  return counts;
}

export function compareWidgetCleanupCounts({actual, maxCounts}) {
  const errors = [];
  const actualKeys = Object.keys(actual).sort();
  const baselineKeys = Object.keys(maxCounts).sort();

  for (const key of baselineKeys) {
    if (!(key in actual)) {
      errors.push(`Live widget cleanup summary is missing category ${key}.`);
      continue;
    }
    const maximum = maxCounts[key];
    if (!Number.isInteger(maximum) || maximum < 0) {
      errors.push(
        `Widget cleanup baseline ${key} must be a non-negative integer.`,
      );
      continue;
    }
    if (actual[key] > maximum) {
      errors.push(`${key}: live ${actual[key]} exceeds baseline maximum ${maximum}.`);
    }
  }

  for (const key of actualKeys) {
    if (!(key in maxCounts)) {
      errors.push(`Live widget cleanup summary has unbaselined category ${key}.`);
    }
  }

  return errors;
}

export function totalCounts(counts) {
  return Object.values(counts).reduce((total, count) => total + count, 0);
}

async function main() {
  const baselineFlag = process.argv.indexOf("--baseline");
  const baselinePath =
    baselineFlag === -1 ? null : process.argv[baselineFlag + 1];
  if (!baselinePath) {
    console.error(
      "Usage: node tool/lib/widget_cleanup_ratchet.mjs --baseline <path>",
    );
    process.exitCode = 64;
    return;
  }

  const source = await readStdin();
  const actual = parseWidgetCleanupSummary(source);
  const baseline = JSON.parse(fs.readFileSync(baselinePath, "utf8"));
  const maxCounts = baseline.maxCounts;
  if (
    maxCounts == null ||
    typeof maxCounts !== "object" ||
    Array.isArray(maxCounts)
  ) {
    console.error(`${baselinePath} must define a maxCounts object.`);
    process.exitCode = 1;
    return;
  }

  const errors = compareWidgetCleanupCounts({actual, maxCounts});
  if (errors.length > 0) {
    console.error("Widget cleanup ratchet failed:");
    for (const error of errors) console.error(`- ${error}`);
    process.exitCode = 1;
    return;
  }

  console.log(
    `Widget cleanup ratchet passed: ${totalCounts(actual)} live candidate(s), ` +
      `${totalCounts(maxCounts)} baseline maximum.`,
  );
}

function readStdin() {
  return new Promise((resolve, reject) => {
    let value = "";
    process.stdin.setEncoding("utf8");
    process.stdin.on("data", (chunk) => {
      value += chunk;
    });
    process.stdin.on("end", () => resolve(value));
    process.stdin.on("error", reject);
  });
}

if (isCliEntrypoint) {
  await main();
}
