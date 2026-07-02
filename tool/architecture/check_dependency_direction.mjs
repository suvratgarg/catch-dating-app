#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";

const defaultBaselinePath = fromRepo(
  "tool/architecture/dependency_direction_baseline.json",
);

const disallowedDomainPackages = new Set([
  "cloud_firestore",
  "connectivity_plus",
  "device_info_plus",
  "firebase_auth",
  "firebase_core",
  "firebase_functions",
  "firebase_storage",
  "flutter",
  "flutter_riverpod",
  "geocoding",
  "geolocator",
  "go_router",
  "google_maps_flutter",
  "google_sign_in",
  "hooks_riverpod",
  "image_picker",
  "in_app_purchase",
  "map_launcher",
  "package_info_plus",
  "permission_handler",
  "riverpod",
  "share_plus",
  "shared_preferences",
  "sign_in_with_apple",
  "url_launcher",
]);

const isCliEntrypoint =
  process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isCliEntrypoint) runCli();

export function scanDependencyDirection({root, baseline = emptyBaseline()}) {
  const files = collectDartFiles(path.join(root, "lib"));
  const allFindings = [];
  for (const file of files) {
    const source = fs.readFileSync(file, "utf8");
    const relativePath = normalizePath(path.relative(root, file));
    allFindings.push(...scanFile({relativePath, source}));
  }

  const baselineKeys = new Set(
    (baseline.allowedFindings ?? []).map((finding) => findingKey(finding)),
  );
  const findings = [];
  const baselineFindings = [];
  for (const finding of allFindings) {
    if (baselineKeys.has(findingKey(finding))) {
      baselineFindings.push(finding);
    } else {
      findings.push(finding);
    }
  }

  return {
    checkedFiles: files.length,
    baselinePath: baseline.path ?? null,
    findings,
    baselineFindings,
    allFindings,
    summary: summarizeFindings({findings, baselineFindings}),
  };
}

export function scanFile({relativePath, source}) {
  const findings = [];
  for (const match of source.matchAll(/^import\s+'([^']+)';/gmu)) {
    const uri = match[1];
    const line = lineForOffset(source, match.index ?? 0);
    if (isDomainFile(relativePath)) {
      const packageName = packageNameFor(uri);
      if (disallowedDomainPackages.has(packageName)) {
        findings.push({
          rule: "domainFrameworkImport",
          path: relativePath,
          import: uri,
          line,
          reason:
            "domain files must not import Flutter, Firebase, Riverpod, routing, or plugin packages directly",
        });
      }
    }

    if (isDataOrDomainFile(relativePath) && isFeaturePresentationImport(uri)) {
      findings.push({
        rule: "dataDomainPresentationImport",
        path: relativePath,
        import: uri,
        line,
        reason: "data/domain files must not import feature presentation code",
      });
    }

    const sourceFeature = presentationSourceFeature(relativePath);
    const targetFeature = featurePresentationImportTarget(uri);
    if (
      sourceFeature != null &&
      targetFeature != null &&
      targetFeature !== "core" &&
      targetFeature !== sourceFeature &&
      !isSanctionedCrossFeaturePresentationSeam({
        sourcePath: relativePath,
        targetImport: uri,
      })
    ) {
      findings.push({
        rule: "crossFeaturePresentationImport",
        path: relativePath,
        import: uri,
        line,
        reason:
          "feature presentation files must not import sibling feature presentation internals without a sanctioned seam",
      });
    }
  }
  return findings;
}

function baselineFromFindings(findings) {
  return {
    version: 1,
    updated: new Date().toISOString().slice(0, 10),
    description:
      "Current dependency-direction debt baseline. Normal scanner runs fail on findings not listed here.",
    allowedFindings: findings
      .map(({rule, path: findingPath, import: uri}) => ({
        rule,
        path: findingPath,
        import: uri,
      }))
      .sort((a, b) => findingKey(a).localeCompare(findingKey(b))),
  };
}

function summarizeFindings({findings, baselineFindings}) {
  return {
    newFindingsByRule: countByRule(findings),
    baselineFindingsByRule: countByRule(baselineFindings),
  };
}

function countByRule(findings) {
  const counts = {};
  for (const finding of findings) {
    counts[finding.rule] = (counts[finding.rule] ?? 0) + 1;
  }
  return counts;
}

function findingKey(finding) {
  return `${finding.rule}|${finding.path}|${finding.import}`;
}

function collectDartFiles(root) {
  if (!fs.existsSync(root)) return [];
  const files = [];
  walk(root, files);
  return files
    .filter((file) => file.endsWith(".dart"))
    .filter((file) => !file.endsWith(".g.dart"))
    .filter((file) => !file.endsWith(".freezed.dart"))
    .sort((a, b) => a.localeCompare(b));
}

function walk(directory, files) {
  for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
    const absolutePath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      walk(absolutePath, files);
    } else if (entry.isFile()) {
      files.push(absolutePath);
    }
  }
}

function isDomainFile(relativePath) {
  return /^lib\/[^/]+\/domain\/.+\.dart$/u.test(relativePath);
}

function isDataOrDomainFile(relativePath) {
  return /^lib\/[^/]+\/(?:data|domain)\//u.test(relativePath);
}

function presentationSourceFeature(relativePath) {
  return /^lib\/([^/]+)\/presentation\//u.exec(relativePath)?.[1] ?? null;
}

function isSanctionedCrossFeaturePresentationSeam({sourcePath, targetImport}) {
  return (
    isScreenOrControllerFile(sourcePath) &&
    isPresentationControllerImport(targetImport)
  );
}

function isScreenOrControllerFile(relativePath) {
  return /(?:^|\/)[^/]+_(?:screen|controller)\.dart$/u.test(relativePath);
}

function isPresentationControllerImport(uri) {
  return /^package:catch_dating_app\/[^/]+\/presentation\/.+_controller\.dart$/u.test(
    uri,
  );
}

function featurePresentationImportTarget(uri) {
  return (
    /^package:catch_dating_app\/([^/]+)\/presentation\//u.exec(uri)?.[1] ??
    null
  );
}

function isFeaturePresentationImport(uri) {
  return /^package:catch_dating_app\/[^/]+\/presentation\//u.test(uri);
}

function packageNameFor(uri) {
  return /^package:([^/']+)/u.exec(uri)?.[1] ?? "";
}

function lineForOffset(source, offset) {
  let line = 1;
  for (let index = 0; index < offset; index += 1) {
    if (source.charCodeAt(index) === 10) line += 1;
  }
  return line;
}

function readBaseline(file) {
  if (!fs.existsSync(file)) return emptyBaseline(file);
  try {
    return {
      ...JSON.parse(fs.readFileSync(file, "utf8")),
      path: relativeToRepo(file),
    };
  } catch (error) {
    console.error(`Failed to parse ${relativeToDisplay(fromRepo(), file)}: ${error.message}`);
    process.exit(1);
  }
}

function emptyBaseline(file = null) {
  return {path: file == null ? null : relativeToRepo(file), allowedFindings: []};
}

function parseArgs(rawArgs) {
  const parsed = {
    baseline: null,
    help: false,
    json: false,
    root: null,
    writeBaseline: false,
  };

  for (let index = 0; index < rawArgs.length; index += 1) {
    const arg = rawArgs[index];
    if (arg === "--help" || arg === "-h") {
      parsed.help = true;
    } else if (arg === "--json") {
      parsed.json = true;
    } else if (arg === "--write-baseline") {
      parsed.writeBaseline = true;
    } else if (arg === "--baseline") {
      parsed.baseline = requireValue(rawArgs, (index += 1), arg);
    } else if (arg === "--root") {
      parsed.root = requireValue(rawArgs, (index += 1), arg);
    } else {
      console.error(`Unknown argument: ${arg}`);
      process.exit(2);
    }
  }

  return parsed;
}

function requireValue(argsList, index, flag) {
  const value = argsList[index];
  if (value == null || value.startsWith("--")) {
    console.error(`Missing value for ${flag}`);
    process.exit(2);
  }
  return path.resolve(value);
}

function printFindings(result) {
  console.error(
    `Dependency direction check failed (${result.findings.length} new finding(s); ${result.baselineFindings.length} baseline finding(s) acknowledged).`,
  );
  for (const finding of result.findings) {
    console.error(`- ${finding.path}: ${finding.reason}`);
    console.error(`  L${finding.line} ${finding.rule}: ${finding.import}`);
  }
}

function printHelp() {
  console.log(`Usage:
  node tool/architecture/check_dependency_direction.mjs
  node tool/architecture/check_dependency_direction.mjs --json
  node tool/architecture/check_dependency_direction.mjs --write-baseline

Scans lib/**/*.dart for dependency-direction violations:
- domain files importing Flutter, Firebase, Riverpod, routing, or plugin packages;
- data/domain files importing feature presentation code;
- feature presentation files importing sibling feature presentation internals.

The baseline file ratchets existing debt. Normal runs fail only on findings not
listed in tool/architecture/dependency_direction_baseline.json.`);
}

function normalizePath(filePath) {
  return filePath.split(path.sep).join("/");
}

function relativeToDisplay(root, file) {
  return normalizePath(path.relative(root, file));
}

function runCli() {
  const args = parseArgs(process.argv.slice(2));

  if (args.help) {
    printHelp();
    process.exit(0);
  }

  const baselinePath = args.baseline ?? defaultBaselinePath;
  const root = args.root ?? fromRepo();
  const baseline = args.writeBaseline
    ? emptyBaseline()
    : readBaseline(baselinePath);
  const result = scanDependencyDirection({root, baseline});

  if (args.writeBaseline) {
    const nextBaseline = baselineFromFindings(result.allFindings);
    fs.mkdirSync(path.dirname(baselinePath), {recursive: true});
    fs.writeFileSync(
      baselinePath,
      `${JSON.stringify(nextBaseline, null, 2)}\n`,
    );
    if (!args.json) {
      console.log(
        `Wrote dependency direction baseline with ${nextBaseline.allowedFindings.length} finding(s): ${relativeToDisplay(root, baselinePath)}`,
      );
    }
    if (args.json) {
      console.log(JSON.stringify({...result, writtenBaseline: nextBaseline}, null, 2));
    }
    return;
  }

  if (args.json) {
    console.log(JSON.stringify(result, null, 2));
  }

  if (result.findings.length > 0) {
    if (!args.json) printFindings(result);
    process.exit(1);
  }

  if (!args.json && !args.writeBaseline) {
    console.log(
      `Dependency direction check passed (${result.checkedFiles} lib Dart files scanned; ${result.baselineFindings.length} baseline finding(s) acknowledged).`,
    );
  }
}
