#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {fromRepo} from "../lib/repo_paths.mjs";

const isCliEntrypoint =
  process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isCliEntrypoint) {
  runCli(process.argv.slice(2));
}

export function buildCoverageReport(lcovSource) {
  const files = parseLcov(lcovSource);
  const handwrittenFiles = files.filter((file) => !isGeneratedDartPath(file.path));
  const generatedFiles = files.filter((file) => isGeneratedDartPath(file.path));
  const features = aggregateByFeature(handwrittenFiles);

  return {
    schemaVersion: 1,
    policy: "visibility_only_no_global_threshold",
    summary: summarize(handwrittenFiles),
    observedInstrumented: summarize(files),
    excludedGeneratedOrConfig: summarize(generatedFiles),
    features,
  };
}

export function parseLcov(source) {
  const byPath = new Map();
  let currentPath = null;

  for (const line of String(source).split(/\r?\n/u)) {
    if (line.startsWith("SF:")) {
      currentPath = normalizeSourcePath(line.slice(3));
      if (!byPath.has(currentPath)) byPath.set(currentPath, new Map());
      continue;
    }
    if (line === "end_of_record") {
      currentPath = null;
      continue;
    }
    if (currentPath == null || !line.startsWith("DA:")) continue;

    const [lineNumberSource, hitsSource] = line.slice(3).split(",", 2);
    const lineNumber = Number(lineNumberSource);
    const hits = Number(hitsSource);
    if (!Number.isInteger(lineNumber) || lineNumber <= 0 || !Number.isFinite(hits)) {
      throw new Error(`Invalid LCOV line record: ${line}`);
    }
    const lineHits = byPath.get(currentPath);
    lineHits.set(lineNumber, Math.max(lineHits.get(lineNumber) ?? 0, hits));
  }

  return [...byPath.entries()]
    .filter(([filePath]) => filePath === "lib" || filePath.startsWith("lib/"))
    .map(([filePath, lineHits]) => ({
      path: filePath,
      linesFound: lineHits.size,
      linesHit: [...lineHits.values()].filter((hits) => hits > 0).length,
    }))
    .sort((a, b) => a.path.localeCompare(b.path));
}

export function renderCoverageMarkdown(report) {
  const summary = report.summary;
  const generated = report.excludedGeneratedOrConfig;
  const rows = report.features
    .map(
      (feature) =>
        `| ${feature.feature} | ${feature.linesHit} / ${feature.linesFound} | ` +
        `${formatPercent(feature.percent)} | ${feature.files} |`,
    )
    .join("\n");

  return `# Flutter coverage visibility

- Handwritten lines observed: ${summary.linesHit} / ${summary.linesFound} (${formatPercent(summary.percent)})
- Handwritten files observed: ${summary.files}
- Generated/config lines excluded from the headline: ${generated.linesFound}

This report is visibility-only. It intentionally does not impose an aggregate
percentage threshold; feature-level gaps should drive focused test decisions.
Files that the test process never loads are not represented in LCOV and are not
silently counted as covered.

| Feature | Covered / observed lines | Coverage | Files |
| --- | ---: | ---: | ---: |
${rows || "| (none) | 0 / 0 | n/a | 0 |"}
`;
}

function aggregateByFeature(files) {
  const groups = new Map();
  for (const file of files) {
    const feature = featureForPath(file.path);
    const aggregate = groups.get(feature) ?? {
      feature,
      files: 0,
      linesFound: 0,
      linesHit: 0,
      percent: null,
    };
    aggregate.files += 1;
    aggregate.linesFound += file.linesFound;
    aggregate.linesHit += file.linesHit;
    groups.set(feature, aggregate);
  }

  return [...groups.values()]
    .map((entry) => ({
      ...entry,
      percent:
        entry.linesFound === 0 ? null : (entry.linesHit / entry.linesFound) * 100,
    }))
    .sort(
      (a, b) =>
        b.linesFound - a.linesFound || a.feature.localeCompare(b.feature),
    );
}

function summarize(files) {
  const linesFound = files.reduce((sum, file) => sum + file.linesFound, 0);
  const linesHit = files.reduce((sum, file) => sum + file.linesHit, 0);
  return {
    files: files.length,
    linesFound,
    linesHit,
    percent: linesFound === 0 ? null : (linesHit / linesFound) * 100,
  };
}

function normalizeSourcePath(sourcePath) {
  const normalized = sourcePath.replaceAll("\\", "/");
  const libIndex = normalized.lastIndexOf("/lib/");
  if (libIndex >= 0) return normalized.slice(libIndex + 1);
  return normalized.replace(/^\.?\//u, "");
}

function featureForPath(filePath) {
  const relative = filePath.replace(/^lib\/?/u, "");
  if (!relative.includes("/")) return "(app root)";
  return relative.split("/", 1)[0];
}

function isGeneratedDartPath(filePath) {
  return (
    filePath.endsWith(".g.dart") ||
    filePath.endsWith(".freezed.dart") ||
    filePath.startsWith("lib/l10n/generated/") ||
    /^lib\/firebase_options(?:_[^/]+)?\.dart$/u.test(filePath)
  );
}

function formatPercent(value) {
  return value == null ? "n/a" : `${value.toFixed(1)}%`;
}

function runCli(argv) {
  const args = parseArgs(argv);
  const lcovPath = path.resolve(fromRepo(), args.lcov);
  if (!fs.existsSync(lcovPath)) {
    throw new Error(
      `LCOV file not found: ${args.lcov}. Run flutter test --coverage first.`,
    );
  }
  const report = buildCoverageReport(fs.readFileSync(lcovPath, "utf8"));
  const rendered =
    args.format === "json"
      ? `${JSON.stringify(report, null, 2)}\n`
      : renderCoverageMarkdown(report);

  if (args.output == null) {
    process.stdout.write(rendered);
    return;
  }
  const outputPath = path.resolve(fromRepo(), args.output);
  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, rendered);
  console.log(`Wrote ${path.relative(fromRepo(), outputPath)}.`);
}

function parseArgs(argv) {
  const args = {
    lcov: "coverage/lcov.info",
    format: "markdown",
    output: null,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--lcov") args.lcov = requireValue(argv, ++index, arg);
    else if (arg === "--format") args.format = requireValue(argv, ++index, arg);
    else if (arg === "--output") args.output = requireValue(argv, ++index, arg);
    else if (arg === "--help" || arg === "-h") {
      printHelp();
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  if (!["markdown", "json"].includes(args.format)) {
    throw new Error("--format must be markdown or json.");
  }
  return args;
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (value == null || value.startsWith("--")) {
    throw new Error(`${flag} requires a value.`);
  }
  return value;
}

function printHelp() {
  console.log(`Usage: node tool/test/flutter_coverage_report.mjs [options]

Options:
  --lcov <path>       LCOV input (default: coverage/lcov.info)
  --format <format>   markdown or json (default: markdown)
  --output <path>     Write the rendered report instead of stdout
`);
}
