#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {execFileSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import {fromRepo} from "../lib/repo_paths.mjs";
import {
  classifyTest,
  looksLikeExecutableTest,
} from "../test_inventory.mjs";

const configPath = "docs/audit_registry/test_lifecycle.json";
const baselinePath = "tool/test/flutter_test_size_baseline.json";
const rulesPath = "docs/audit_registry/rules.json";
const regressionLedgerPath = "docs/agent_regression_ledger.json";
const isCliEntrypoint =
  process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isCliEntrypoint) runCli(process.argv.slice(2));

export function checkTestLifecycle({
  files,
  config,
  oversizedBaseline,
  rules = {rules: {}},
  regressionLedger = {entries: []},
  sources = new Map(),
  today = new Date(),
}) {
  const findings = [];
  const retirementCandidates = [];
  const fileSet = new Set(files);
  const allowedLifecycles = new Set(
    config.policy?.allowedLifecycles ?? [],
  );
  const allowedReasons = new Set(config.policy?.exceptionReasons ?? []);
  const knownContractIds = new Set([
    ...Object.keys(rules.rules ?? {}),
    ...(regressionLedger.entries ?? []).map((entry) => entry.id),
  ]);
  const exceptionalByPath = new Map();

  if (config.schemaVersion !== 1) {
    findings.push("test lifecycle schemaVersion must be 1");
  }
  if (!Number.isInteger(config.reviewCadenceDays) ||
      config.reviewCadenceDays <= 0) {
    findings.push("reviewCadenceDays must be a positive integer");
  }
  for (const file of files.filter(looksLikeExecutableTest)) {
    if (classifyTest(file) == null) {
      findings.push(`${file}: executable test is not classified`);
    }
  }

  for (const entry of config.exceptionalTests ?? []) {
    if (exceptionalByPath.has(entry.path)) {
      findings.push(`${entry.path}: duplicate exceptional lifecycle entry`);
      continue;
    }
    exceptionalByPath.set(entry.path, entry);
    if (!fileSet.has(entry.path)) {
      findings.push(`${entry.path}: exceptional test path does not exist`);
    } else if (!looksLikeExecutableTest(entry.path) ||
        classifyTest(entry.path) == null) {
      findings.push(`${entry.path}: exceptional path is not an executable test`);
    }
    if (typeof entry.owner !== "string" || entry.owner.trim() === "") {
      findings.push(`${entry.path}: owner is required`);
    }
    if (!allowedLifecycles.has(entry.lifecycle)) {
      findings.push(`${entry.path}: invalid lifecycle ${entry.lifecycle}`);
    }
    if (!allowedReasons.has(entry.reason)) {
      findings.push(`${entry.path}: invalid exception reason ${entry.reason}`);
    }
    if (!Array.isArray(entry.contractIds) || entry.contractIds.length === 0) {
      findings.push(`${entry.path}: at least one contractIds entry is required`);
    }
    for (const contractId of entry.contractIds ?? []) {
      if (!knownContractIds.has(contractId)) {
        findings.push(`${entry.path}: unknown contract id ${contractId}`);
      }
    }
    if (!Array.isArray(entry.ownerPaths) || entry.ownerPaths.length === 0) {
      findings.push(`${entry.path}: at least one ownerPaths entry is required`);
    }
    for (const ownerPath of entry.ownerPaths ?? []) {
      if (!pathExists(fileSet, ownerPath)) {
        retirementCandidates.push({
          path: entry.path,
          missingOwnerPath: ownerPath,
          sunsetWhen: entry.sunsetWhen,
        });
        findings.push(
          `${entry.path}: owner anchor is missing; review retirement: ${ownerPath}`,
        );
      }
    }
    if (typeof entry.sunsetWhen !== "string" ||
        entry.sunsetWhen.trim() === "") {
      findings.push(`${entry.path}: sunsetWhen is required`);
    }
    const reviewDate = parseDateOnly(entry.reviewBy);
    if (reviewDate == null) {
      findings.push(`${entry.path}: reviewBy must be an ISO date`);
    } else if (reviewDate < startOfUtcDay(today)) {
      findings.push(
        `${entry.path}: lifecycle review is overdue (${entry.reviewBy})`,
      );
    }
  }

  const oversizedPaths = new Set(
    (oversizedBaseline.allowedFindings ?? []).map((entry) => entry.path),
  );
  for (const oversizedPath of oversizedPaths) {
    const lifecycleEntry = exceptionalByPath.get(oversizedPath);
    if (lifecycleEntry?.reason !== "oversized") {
      findings.push(
        `${oversizedPath}: oversized baseline requires lifecycle metadata`,
      );
    }
  }
  for (const entry of exceptionalByPath.values()) {
    if (entry.reason === "oversized" && !oversizedPaths.has(entry.path)) {
      findings.push(
        `${entry.path}: oversized lifecycle entry is absent from the size baseline`,
      );
    }
  }

  const obligationIds = new Set();
  for (const obligation of config.criticalObligations ?? []) {
    if (obligationIds.has(obligation.id)) {
      findings.push(`${obligation.id}: duplicate critical obligation id`);
      continue;
    }
    obligationIds.add(obligation.id);
    if (typeof obligation.owner !== "string" ||
        obligation.owner.trim() === "") {
      findings.push(`${obligation.id}: critical obligation owner is required`);
    }
    if (!Array.isArray(obligation.sourcePaths) ||
        obligation.sourcePaths.length === 0) {
      findings.push(`${obligation.id}: sourcePaths are required`);
    }
    if (!Array.isArray(obligation.testPaths) ||
        obligation.testPaths.length === 0) {
      findings.push(`${obligation.id}: testPaths are required`);
    }
    for (const sourcePath of obligation.sourcePaths ?? []) {
      if (!pathExists(fileSet, sourcePath)) {
        findings.push(
          `${obligation.id}: critical source path is missing: ${sourcePath}`,
        );
      }
    }
    for (const testPath of obligation.testPaths ?? []) {
      if (!fileSet.has(testPath)) {
        findings.push(
          `${obligation.id}: required test path is missing: ${testPath}`,
        );
      } else if (!looksLikeExecutableTest(testPath) ||
          classifyTest(testPath) == null) {
        findings.push(
          `${obligation.id}: required test path is not classified: ${testPath}`,
        );
      }
    }
    if (typeof obligation.rationale !== "string" ||
        obligation.rationale.trim() === "") {
      findings.push(`${obligation.id}: rationale is required`);
    }
  }

  for (const file of files.filter(looksLikeExecutableTest)) {
    const source = sources.get(file);
    if (source == null || !containsSkippedTest(source, file)) continue;
    const lifecycleEntry = exceptionalByPath.get(file);
    if (!["platform_specific", "quarantined"].includes(
      lifecycleEntry?.lifecycle,
    )) {
      findings.push(
        `${file}: skipped test requires platform_specific or quarantined lifecycle metadata`,
      );
    }
  }

  return {
    findings: findings.sort(),
    retirementCandidates: retirementCandidates.sort((left, right) =>
      left.path.localeCompare(right.path)
    ),
    counts: {
      exceptionalTests: exceptionalByPath.size,
      criticalObligations: obligationIds.size,
      retirementCandidates: retirementCandidates.length,
    },
  };
}

function pathExists(fileSet, candidate) {
  return fileSet.has(candidate) ||
    [...fileSet].some((file) => file.startsWith(`${candidate}/`));
}

export function containsSkippedTest(source, file) {
  if (file.endsWith(".dart")) {
    return /\bskip\s*:\s*(?:true|['"])/u.test(source);
  }
  return /\b(?:test|it|describe)\.skip\s*\(/u.test(source) ||
    /\{\s*skip\s*:/u.test(source);
}

function parseDateOnly(value) {
  if (typeof value !== "string" ||
      !/^\d{4}-\d{2}-\d{2}$/u.test(value)) {
    return null;
  }
  const date = new Date(`${value}T00:00:00.000Z`);
  return Number.isNaN(date.valueOf()) ? null : date;
}

function startOfUtcDay(date) {
  return new Date(Date.UTC(
    date.getUTCFullYear(),
    date.getUTCMonth(),
    date.getUTCDate(),
  ));
}

function runCli(argv) {
  const json = argv.includes("--json");
  const files = trackedFiles();
  const sources = new Map(
    files
      .filter(looksLikeExecutableTest)
      .map((file) => [file, fs.readFileSync(fromRepo(file), "utf8")]),
  );
  const result = checkTestLifecycle({
    files,
    sources,
    config: readJson(configPath),
    oversizedBaseline: readJson(baselinePath),
    rules: readJson(rulesPath),
    regressionLedger: readJson(regressionLedgerPath),
  });
  if (json) {
    console.log(JSON.stringify(result, null, 2));
  } else if (result.findings.length === 0) {
    console.log(
      `Test lifecycle check passed: ${result.counts.exceptionalTests} ` +
      `exceptional test(s), ${result.counts.criticalObligations} critical ` +
      "obligation(s), zero retirement candidates.",
    );
  } else {
    console.error(
      `Test lifecycle check failed (${result.findings.length} finding(s)):`,
    );
    for (const finding of result.findings) console.error(`- ${finding}`);
  }
  if (result.findings.length > 0) process.exitCode = 1;
}

function trackedFiles() {
  return execFileSync(
    "git",
    ["ls-files", "--cached", "--others", "--exclude-standard"],
    {cwd: fromRepo(), encoding: "utf8"},
  )
    .trim()
    .split(/\r?\n/u)
    .filter(Boolean);
}

function readJson(relativePath) {
  return JSON.parse(fs.readFileSync(fromRepo(relativePath), "utf8"));
}
