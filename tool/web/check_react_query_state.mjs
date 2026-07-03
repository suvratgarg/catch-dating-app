#!/usr/bin/env node
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";

const defaultBaselinePath = fromRepo("tool/web/react_query_state_baseline.json");

const surfaces = {
  admin: {
    root: "admin/src/features",
  },
  website: {
    root: "website/src/features",
  },
};

const checkedExtensions = new Set([".ts", ".tsx"]);
const asyncStateNamePattern =
  /(?:loading|saving|submitting|refreshing|pending|inflight)/iu;

const isCliEntrypoint =
  process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isCliEntrypoint) runCli();

export function scanReactQueryState({root, surfaceNames = Object.keys(surfaces)}) {
  const findings = [];
  let checkedFiles = 0;
  for (const surfaceName of surfaceNames) {
    const surface = surfaces[surfaceName];
    if (!surface) throw new Error(`Unknown surface: ${surfaceName}`);
    const surfaceRoot = path.join(root, surface.root);
    for (const filePath of walk(surfaceRoot)) {
      const relativePath = normalizePath(relativeToRepo(filePath));
      if (!isCandidateFile(relativePath)) continue;
      checkedFiles += 1;
      const source = fs.readFileSync(filePath, "utf8");
      findings.push(...scanSource({relativePath, source, surfaceName}));
    }
  }
  return {
    checkedFiles,
    findings: findings.sort(compareFinding),
  };
}

export function scanSource({relativePath, source, surfaceName}) {
  const findings = [];
  const statePattern =
    /const\s+\[\s*([A-Za-z_$][\w$]*)\s*,\s*([A-Za-z_$][\w$]*)\s*\]\s*=\s*useState(?:<[\s\S]*?>)?\s*\(/gu;
  for (const match of source.matchAll(statePattern)) {
    const stateName = match[1];
    const setterName = match[2];
    if (!isAsyncStateName(stateName) && !isAsyncSetterName(setterName)) {
      continue;
    }
    findings.push({
      surface: surfaceName,
      path: relativePath,
      line: lineForOffset(source, match.index ?? 0),
      stateName,
      setterName,
      reason:
        "manual async/loading state in a feature controller or hook should migrate to TanStack Query when it represents server state",
    });
  }
  return findings;
}

function isAsyncStateName(name) {
  return asyncStateNamePattern.test(name);
}

function isAsyncSetterName(name) {
  return /^set[A-Z]/u.test(name) && asyncStateNamePattern.test(name);
}

function isCandidateFile(relativePath) {
  const extension = path.extname(relativePath);
  if (!checkedExtensions.has(extension)) return false;
  if (relativePath.includes("/__tests__/")) return false;
  if (relativePath.includes("/stories/")) return false;
  const baseName = path.basename(relativePath);
  return (
    relativePath.includes("/controllers/") ||
    /^use[A-Z].*\.(?:ts|tsx)$/u.test(baseName)
  );
}

function splitFindingsByBaseline(findings, baseline) {
  const allowedKeys = new Set(
    (baseline.allowedFindings ?? []).map((finding) => findingKey(finding))
  );
  const baselineFindings = [];
  const newFindings = [];
  for (const finding of findings) {
    if (allowedKeys.has(findingKey(finding))) {
      baselineFindings.push(finding);
    } else {
      newFindings.push(finding);
    }
  }
  return {baselineFindings, newFindings};
}

function baselineFromFindings(findings) {
  return {
    version: 1,
    updated: new Date().toISOString().slice(0, 10),
    description:
      "Current React feature controller/hook manual async-state baseline. Normal scanner runs fail only on findings not listed here.",
    allowedFindings: findings
      .map(({surface, path: findingPath, stateName, setterName}) => ({
        surface,
        path: findingPath,
        stateName,
        setterName,
      }))
      .sort((a, b) => findingKey(a).localeCompare(findingKey(b))),
  };
}

function findingKey(finding) {
  return [
    finding.surface,
    finding.path,
    finding.stateName,
    finding.setterName,
  ].join("|");
}

function summarize(findings) {
  const bySurface = {};
  const byPath = {};
  for (const finding of findings) {
    bySurface[finding.surface] = (bySurface[finding.surface] ?? 0) + 1;
    byPath[finding.path] = (byPath[finding.path] ?? 0) + 1;
  }
  return {bySurface, byPath};
}

function readBaseline(filePath) {
  if (!fs.existsSync(filePath)) {
    return {allowedFindings: [], path: normalizePath(relativeToRepo(filePath))};
  }
  return {
    ...JSON.parse(fs.readFileSync(filePath, "utf8")),
    path: normalizePath(relativeToRepo(filePath)),
  };
}

function walk(directory) {
  const files = [];
  if (!fs.existsSync(directory)) return files;
  for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
    const fullPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      if (entry.name === "dist" || entry.name === "storybook-static") continue;
      files.push(...walk(fullPath));
      continue;
    }
    if (entry.isFile()) files.push(fullPath);
  }
  return files.sort((a, b) => a.localeCompare(b));
}

function lineForOffset(source, offset) {
  let line = 1;
  for (let index = 0; index < offset; index += 1) {
    if (source.charCodeAt(index) === 10) line += 1;
  }
  return line;
}

function normalizePath(value) {
  return value.split(path.sep).join("/");
}

function compareFinding(a, b) {
  return findingKey(a).localeCompare(findingKey(b));
}

function parseArgs(argv) {
  const parsed = {
    baseline: defaultBaselinePath,
    check: false,
    help: false,
    json: false,
    selfTest: false,
    summary: false,
    surface: "all",
    writeBaseline: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--baseline") {
      parsed.baseline = fromRepo(requiredValue(argv, ++index, arg));
    } else if (arg === "--check") {
      parsed.check = true;
    } else if (arg === "--help" || arg === "-h") {
      parsed.help = true;
    } else if (arg === "--json") {
      parsed.json = true;
    } else if (arg === "--self-test") {
      parsed.selfTest = true;
    } else if (arg === "--summary") {
      parsed.summary = true;
    } else if (arg === "--surface") {
      parsed.surface = requiredValue(argv, ++index, arg);
    } else if (arg === "--write-baseline") {
      parsed.writeBaseline = true;
    } else {
      fail(`Unknown argument: ${arg}`);
    }
  }
  if (parsed.surface !== "all" && !surfaces[parsed.surface]) {
    fail(`Unknown surface: ${parsed.surface}`);
  }
  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) fail(`${flag} requires a value.`);
  return value;
}

function fail(message) {
  console.error(message);
  process.exit(64);
}

function runSelfTest() {
  const source = `
import {useState} from "react";

export function useSampleController() {
  const [isLoading, setIsLoading] = useState(false);
  const [formValue, setFormValue] = useState("");
  const [decisionInFlight, setDecisionInFlight] =
    useState<Record<string, boolean>>({});
  return {formValue, isLoading, decisionInFlight};
}
`;
  const findings = scanSource({
    relativePath: "admin/src/features/sample/controllers/useSampleController.ts",
    source,
    surfaceName: "admin",
  });
  assert.equal(findings.length, 2);
  assert.equal(findings[0].stateName, "isLoading");
  assert.equal(findings[1].stateName, "decisionInFlight");
  const split = splitFindingsByBaseline(findings, {
    allowedFindings: [findings[0]],
  });
  assert.equal(split.baselineFindings.length, 1);
  assert.equal(split.newFindings.length, 1);
  console.log("React query-state scanner self-test passed.");
}

function runCli() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    printHelp();
    return;
  }
  if (args.selfTest) {
    runSelfTest();
    return;
  }

  const surfaceNames = args.surface === "all" ?
    Object.keys(surfaces) :
    [args.surface];
  const result = scanReactQueryState({
    root: fromRepo(),
    surfaceNames,
  });
  const baseline = args.writeBaseline ?
    {allowedFindings: []} :
    readBaseline(args.baseline);
  const {baselineFindings, newFindings} = splitFindingsByBaseline(
    result.findings,
    baseline
  );

  if (args.writeBaseline) {
    const nextBaseline = baselineFromFindings(result.findings);
    fs.mkdirSync(path.dirname(args.baseline), {recursive: true});
    fs.writeFileSync(args.baseline, `${JSON.stringify(nextBaseline, null, 2)}\n`);
    console.log(
      `Wrote React query-state baseline with ${nextBaseline.allowedFindings.length} finding(s): ${normalizePath(relativeToRepo(args.baseline))}`
    );
    return;
  }

  if (args.json) {
    console.log(JSON.stringify({
      checkedFiles: result.checkedFiles,
      baseline: baseline.path ?? normalizePath(relativeToRepo(args.baseline)),
      newFindings,
      baselineFindings,
      summary: {
        newFindings: summarize(newFindings),
        baselineFindings: summarize(baselineFindings),
      },
    }, null, 2));
  } else if (args.summary || args.check) {
    console.log(
      `React query-state scan: ${result.checkedFiles} controller/hook file(s), ${newFindings.length} new finding(s), ${baselineFindings.length} baseline finding(s).`
    );
  }

  if (args.check && newFindings.length > 0) {
    console.error("Unbaselined React manual async-state findings:");
    for (const finding of newFindings) {
      console.error(
        `- ${finding.path}:${finding.line} ${finding.stateName}/${finding.setterName}`
      );
    }
    console.error(
      "Move server-state pending/loading state to TanStack Query or refresh the baseline only after recording intentional debt."
    );
    process.exit(1);
  }
}

function printHelp() {
  console.log(`Usage: node tool/web/check_react_query_state.mjs [--check] [--summary] [--json] [--surface all|admin|website]
       node tool/web/check_react_query_state.mjs --write-baseline
       node tool/web/check_react_query_state.mjs --self-test

Scans React feature controllers and feature use* hooks for manual async/loading
state that should migrate to TanStack Query when it represents server state.
Normal --check runs fail only on findings outside
tool/web/react_query_state_baseline.json.`);
}
