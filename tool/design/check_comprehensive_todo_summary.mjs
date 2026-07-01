#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fromRepo, relativeToRepo, repoRoot} from "../lib/repo_paths.mjs";

const todoPath = fromRepo("docs/design_parity/comprehensive_todo.md");
const screenContractsPath = fromRepo("design/screens/catch.screens.json");
const stateMatrixPath = fromRepo("docs/design_parity/state_matrix.json");

const args = process.argv.slice(2);
const command = args[0] ?? "--help";

if (command === "--help" || command === "-h" || command === "help") {
  printHelp();
} else if (command === "--check" || command === "check") {
  checkSummary({summary: args.includes("--summary")});
} else if (command === "--summary" || command === "summary") {
  checkSummary({summary: true});
} else {
  console.error(`Unknown command: ${command}`);
  printHelp();
  process.exit(64);
}

function checkSummary({summary = false} = {}) {
  const todo = fs.readFileSync(todoPath, "utf8");
  const screenContracts = readJson(screenContractsPath);
  const stateMatrix = readJson(stateMatrixPath);
  const errors = [
    ...validateSummaryTable(todo, screenContracts),
    ...validateScreenRegistryCounts(todo, screenContracts),
    ...validateMatrixGapCount(todo, stateMatrix),
  ];

  if (summary || errors.length === 0) {
    printSummary(screenContracts, stateMatrix);
  }

  if (errors.length > 0) {
    console.error("Comprehensive todo summary check failed:");
    for (const error of errors) console.error(`- ${error}`);
    process.exit(1);
  }
}

function validateSummaryTable(todo, screenContracts) {
  const errors = [];
  const screenById = new Map(
    (screenContracts.screens ?? []).map((screen) => [screen.id, screen]),
  );
  const seen = new Set();

  for (const row of parsePriorityRows(todo)) {
    const screen = screenById.get(row.screenId);
    if (!screen) continue;
    seen.add(row.screenId);
    const expected = formatOpenRegistryGaps(screen);
    if (normalizeCell(row.openRegistryGaps) !== normalizeCell(expected)) {
      errors.push(
        `${row.screenId}: summary table Open registry gaps is '${row.openRegistryGaps}', expected '${expected}'.`,
      );
    }
  }

  for (const screen of screenContracts.screens ?? []) {
    if (screen.priority === "P1" && !seen.has(screen.id)) {
      errors.push(`${screen.id}: P1 screen is missing from the comprehensive todo summary table.`);
    }
  }

  return errors;
}

function validateScreenRegistryCounts(todo, screenContracts) {
  const match = todo.match(
    /Screen registry migration gaps:\s+(\d+)\s+open,\s+(\d+)\s+blocked,\s+and\s+(\d+)\s+closed/u,
  );
  if (!match) {
    return ["Missing screen registry migration gap count line."];
  }
  const expected = screenRegistryCounts(screenContracts);
  const actual = {
    open: Number(match[1]),
    blocked: Number(match[2]),
    closed: Number(match[3]),
  };
  const errors = [];
  for (const key of ["open", "blocked", "closed"]) {
    if (actual[key] !== expected[key]) {
      errors.push(
        `Screen registry migration gap ${key} count is ${actual[key]}, expected ${expected[key]}.`,
      );
    }
  }
  return errors;
}

function validateMatrixGapCount(todo, stateMatrix) {
  const match = todo.match(/(\d+)\s+open matrix gaps across/u);
  if (!match) {
    return ["Missing design parity matrix open gap count line."];
  }
  const actual = Number(match[1]);
  const expected = matrixOpenGapCount(stateMatrix);
  return actual === expected
    ? []
    : [`Design parity matrix open gap count is ${actual}, expected ${expected}.`];
}

function parsePriorityRows(todo) {
  return todo
    .split("\n")
    .filter((line) => /^\|\s*P\d\s*\|/u.test(line))
    .map((line) => {
      const cells = line
        .split("|")
        .slice(1, -1)
        .map((cell) => cell.trim());
      return {
        screenId: stripBackticks(cells[1] ?? ""),
        openRegistryGaps: cells[6] ?? "",
      };
    })
    .filter((row) => row.screenId.startsWith("screen."));
}

function formatOpenRegistryGaps(screen) {
  const gaps = (screen.openGaps ?? []).filter((gap) => gap.status !== "closed");
  if (gaps.length === 0) return "None";
  return gaps
    .map((gap) => {
      const id = `\`${gap.id}\``;
      return gap.status === "blocked" ? `${id} blocked` : id;
    })
    .join(", ");
}

function screenRegistryCounts(screenContracts) {
  const counts = {open: 0, blocked: 0, closed: 0};
  for (const gap of (screenContracts.screens ?? []).flatMap((screen) => screen.openGaps ?? [])) {
    if (gap.status === "closed") {
      counts.closed += 1;
    } else if (gap.status === "blocked") {
      counts.blocked += 1;
    } else {
      counts.open += 1;
    }
  }
  return counts;
}

function matrixOpenGapCount(stateMatrix) {
  const features = stateMatrix.features ?? [];
  const screens = features.flatMap((feature) => feature.screens ?? []);
  const gaps = [
    ...features.flatMap((feature) => feature.lintCandidates ?? []),
    ...features.flatMap((feature) => feature.previewPlan ?? []),
    ...screens.flatMap((screen) => screen.gaps ?? []),
  ];
  return gaps.filter((gap) => gap.status !== "closed").length;
}

function normalizeCell(value) {
  return value.replace(/\s+/gu, " ").trim();
}

function stripBackticks(value) {
  return value.replace(/^`|`$/gu, "");
}

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"));
  } catch (error) {
    console.error(`Failed to parse ${path.relative(repoRoot, file)}: ${error.message}`);
    process.exit(1);
  }
}

function printSummary(screenContracts, stateMatrix) {
  const counts = screenRegistryCounts(screenContracts);
  console.log(
    [
      `Comprehensive todo summary: ${relativeToRepo(todoPath)}`,
      `Screen registry gaps: ${counts.open} open, ${counts.blocked} blocked, ${counts.closed} closed`,
      `Matrix open gaps: ${matrixOpenGapCount(stateMatrix)}`,
    ].join("\n"),
  );
}

function printHelp() {
  console.log(`Usage:
  node tool/design/check_comprehensive_todo_summary.mjs --check
  node tool/design/check_comprehensive_todo_summary.mjs --summary

Validates docs/design_parity/comprehensive_todo.md summary counts and table
Open registry gaps against design/screens/catch.screens.json and
docs/design_parity/state_matrix.json.`);
}
