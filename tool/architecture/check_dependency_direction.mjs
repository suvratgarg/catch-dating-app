#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";

const defaultBaselinePath = fromRepo(
  "tool/architecture/dependency_direction_baseline.json",
);

const hardGateRules = new Set([
  "barrelPresentationExport",
  "untrackedStateAdapter",
]);

const allowedDomainPackages = new Set([
  "catch_dating_app",
  "collection",
  "freezed_annotation",
  "json_annotation",
  "meta",
  "pub_semver",
]);

const pluginPackages = new Set([
  "audioplayers",
  "connectivity_plus",
  "firebase_analytics",
  "firebase_app_check",
  "firebase_crashlytics",
  "firebase_messaging",
  "firebase_remote_config",
  "geolocator",
  "google_maps_flutter",
  "health",
  "image_picker",
  "mobile_scanner",
  "package_info_plus",
  "razorpay_flutter",
  "share_plus",
  "shared_preferences",
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
  allFindings.push(...scanArchitectureRegistryFindings({root, files}));

  const baselineKeys = new Set(
    (baseline.allowedFindings ?? []).map((finding) => findingKey(finding)),
  );
  const findings = [];
  const baselineFindings = [];
  for (const finding of allFindings) {
    if (!hardGateRules.has(finding.rule) && baselineKeys.has(findingKey(finding))) {
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
  const addSourceFinding = ({rule, line, reason}) => {
    if (findings.some((finding) => finding.rule === rule && finding.import == null)) {
      return;
    }
    findings.push({rule, path: relativePath, line, reason});
  };

  for (const match of source.matchAll(/^import\s+['"]([^'"]+)['"][^;]*;/gmu)) {
    const uri = match[1];
    const line = lineForOffset(source, match.index ?? 0);
    if (isDomainFile(relativePath)) {
      if (!isAllowedDomainImport(uri)) {
        findings.push({
          rule: "domainFrameworkImport",
          path: relativePath,
          import: uri,
          line,
          reason:
            "domain files must import only dart SDK, app domain/core primitives, and approved pure Dart annotation/value packages",
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

    if (
      isPresentationFile(relativePath) &&
      !isControllerOrServiceFile(relativePath) &&
      isPluginPackageImport(uri)
    ) {
      findings.push({
        rule: "presentationPluginImport",
        path: relativePath,
        import: uri,
        line,
        reason:
          "presentation widgets must route plugin/platform side effects through controllers or services",
      });
    }
  }

  if (isFeatureRootBarrel(relativePath)) {
    for (const match of source.matchAll(/^export\s+['"]([^'"]+)['"][^;]*;/gmu)) {
      const uri = match[1];
      if (!uri.includes("presentation/")) continue;
      const line = lineForOffset(source, match.index ?? 0);
      if (hasPublicApiAnnotation({source, line})) continue;
      findings.push({
        rule: "barrelPresentationExport",
        path: relativePath,
        import: uri,
        line,
        reason:
          "feature-root barrels may export presentation files only with a // public-api: annotation explaining the cross-feature seam",
      });
    }
  }

  if (isDomainFile(relativePath)) {
    const match = /DateTime\s*\.\s*now\s*\(/u.exec(source);
    if (match) {
      findings.push({
        rule: "domainClockAccess",
        path: relativePath,
        line: lineForOffset(source, match.index),
        reason:
          "domain time predicates must accept an injected clock instead of calling DateTime.now() internally",
      });
    }
  }

  if (isDataFile(relativePath)) {
    for (const match of source.matchAll(/\.timeout\s*\(/gu)) {
      const line = lineForOffset(source, match.index ?? 0);
      if (hasStreamTimeoutOverride({source, line})) continue;
      findings.push({
        rule: "dataStreamTimeout",
        path: relativePath,
        line,
        reason:
          "realtime Firestore streams must not be idle-timed-out; annotate non-Firestore protocol deadlines with architecture:allow stream-timeout",
      });
      break;
    }
  }

  if (isPresentationFile(relativePath)) {
    const widgetRefLine = firstMatchingLine(source, (line) => {
      return /\bWidgetRef\s+\w+\s*[,)]/u.test(line) && !line.includes("Widget build(");
    });
    if (widgetRefLine != null) {
      addSourceFinding({
        rule: "widgetRefParameter",
        line: widgetRefLine,
        reason:
          "presentation helpers and constructors must not receive WidgetRef; lift provider reads to the route/controller boundary",
      });
    }

    if (!isControllerServiceOrViewModelFile(relativePath)) {
      const repositoryRead = /ref\.(?:watch|read|listen)\s*\(\s*[a-z]\w*[Rr]epositoryProvider\b/u.exec(
        source,
      );
      if (repositoryRead) {
        addSourceFinding({
          rule: "widgetRepositoryProviderRead",
          line: lineForOffset(source, repositoryRead.index),
          reason:
            "presentation widgets must not read repository providers directly; this name-based scanner catches *RepositoryProvider reads outside controllers, services, and view models",
        });
      }
    }

    if (isStateFile(relativePath) && stateFileHasProviderCoupling(source)) {
      addSourceFinding({
        rule: "stateFileProviderImport",
        line: lineForStateFileProviderCoupling(source),
        reason:
          "presentation *_state.dart files are provider-free display adapters by naming convention",
      });
    }

    if (isMisplacedStateClassFile(relativePath, source)) {
      addSourceFinding({
        rule: "misplacedStateClass",
        line: lineForMisplacedStateClass(source),
        reason:
          "provider-free display state classes with from/resolve factories should live in *_state.dart files and be tracker-visible",
      });
    }

    const screenCount = routeScreenClassCount(source);
    if (screenCount >= 2) {
      addSourceFinding({
        rule: "multiRouteScreenFile",
        line: lineForRouteScreenClass(source),
        reason:
          "presentation files should keep route-level screens findable; files declaring multiple route screens are split candidates",
      });
    }
  }

  if (isHandwrittenLibFile(relativePath)) {
    const keepAliveLine = firstKeepAliveLineWithoutMarker(source);
    if (keepAliveLine != null) {
      addSourceFinding({
        rule: "undocumentedKeepAlive",
        line: keepAliveLine,
        reason:
          "keepAlive providers must document lifecycle rationale with // keepalive: within the three lines above the annotation/declaration",
      });
    }

    if (!relativePath.startsWith("lib/core/")) {
      const providerDeclaration = manualProviderDeclarationMatch(source);
      if (providerDeclaration) {
        addSourceFinding({
          rule: "manualProviderDeclaration",
          line: lineForOffset(source, providerDeclaration.index),
          reason:
            "handwritten providers outside core should use @riverpod codegen unless explicitly grandfathered",
        });
      }
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
      .filter((finding) => !hardGateRules.has(finding.rule))
      .map(({rule, path: findingPath, import: uri}) => {
        const finding = {rule, path: findingPath};
        if (uri != null) finding.import = uri;
        return finding;
      })
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
  return finding.import == null
    ? `${finding.rule}|${finding.path}`
    : `${finding.rule}|${finding.path}|${finding.import}`;
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

function isDataFile(relativePath) {
  return /^lib\/[^/]+\/data\/.+\.dart$/u.test(relativePath);
}

function isPresentationFile(relativePath) {
  return /^lib\/[^/]+\/presentation\/.+\.dart$/u.test(relativePath);
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

function isControllerOrServiceFile(relativePath) {
  return /(?:^|\/)[^/]+_(?:controller|service)\.dart$/u.test(relativePath);
}

function isControllerServiceOrViewModelFile(relativePath) {
  return /(?:^|\/)[^/]+_(?:controller|service|view_model)\.dart$/u.test(
    relativePath,
  );
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

function scanArchitectureRegistryFindings({root, files}) {
  const trackerPath = path.join(
    root,
    "docs/audit_registry/architecture_pattern_adoption.json",
  );
  if (!fs.existsSync(trackerPath)) return [];
  const tracker = JSON.parse(fs.readFileSync(trackerPath, "utf8"));
  const registeredPaths = new Set();
  for (const pattern of tracker.patterns ?? []) {
    for (const collectionName of ["prototypeFiles", "adopters", "variants", "candidateQueue"]) {
      for (const entry of pattern[collectionName] ?? []) {
        if (typeof entry === "string") {
          registeredPaths.add(entry);
        } else if (entry?.path) {
          registeredPaths.add(entry.path);
        }
      }
    }
  }

  const findings = [];
  for (const file of files) {
    const relativePath = normalizePath(path.relative(root, file));
    if (!isStateFile(relativePath)) continue;
    if (registeredPaths.has(relativePath)) continue;
    findings.push({
      rule: "untrackedStateAdapter",
      path: relativePath,
      line: 1,
      reason:
        "presentation *_state.dart files must be registered in architecture_pattern_adoption.json so provider-free and migration obligations stay visible",
    });
  }
  return findings;
}

function isFeatureRootBarrel(relativePath) {
  const match = /^lib\/([^/]+)\/([^/]+)\.dart$/u.exec(relativePath);
  return match != null && match[1] === match[2];
}

function hasPublicApiAnnotation({source, line}) {
  const lines = source.split(/\r?\n/u);
  return [line - 1, line - 2].some((index) => {
    if (index < 0) return false;
    return /\/\/\s*public-api:\s*\S/u.test(lines[index]);
  });
}

function firstMatchingLine(source, predicate) {
  const lines = source.split(/\r?\n/u);
  for (let index = 0; index < lines.length; index += 1) {
    if (predicate(lines[index])) return index + 1;
  }
  return null;
}

function isStateFile(relativePath) {
  return /^lib\/[^/]+\/presentation\/.+_state\.dart$/u.test(relativePath);
}

function stateFileHasProviderCoupling(source) {
  return (
    /^import\s+['"]package:(?:flutter_riverpod|hooks_riverpod|riverpod_annotation)\//mu.test(
      source,
    ) ||
    /\bProvider<|\bref\.(?:watch|read|listen)\b/u.test(source)
  );
}

function lineForStateFileProviderCoupling(source) {
  const match =
    /^import\s+['"]package:(?:flutter_riverpod|hooks_riverpod|riverpod_annotation)\//mu.exec(
      source,
    ) ?? /\bProvider<|\bref\.(?:watch|read|listen)\b/u.exec(source);
  return match == null ? 1 : lineForOffset(source, match.index);
}

function isMisplacedStateClassFile(relativePath, source) {
  if (isStateFile(relativePath)) return false;
  return lineForMisplacedStateClass(source) != null;
}

function lineForMisplacedStateClass(source) {
  for (const block of classBlocks(source)) {
    if (!/\w+(?:Screen)?State$/u.test(block.name)) continue;
    if (/\bfactory\s+\w+(?:Screen)?State\.(?:from|resolve)\s*\(/u.test(block.body)) {
      return lineForOffset(source, block.start);
    }
  }
  return null;
}

function routeScreenClassCount(source) {
  return [...source.matchAll(/\bclass\s+\w+Screen\s+extends\s+(?:Consumer(?:Stateful)?|Stateless|Stateful)Widget\b/gu)]
    .length;
}

function lineForRouteScreenClass(source) {
  const match = /\bclass\s+\w+Screen\s+extends\s+(?:Consumer(?:Stateful)?|Stateless|Stateful)Widget\b/u.exec(
    source,
  );
  return match == null ? 1 : lineForOffset(source, match.index);
}

function isHandwrittenLibFile(relativePath) {
  return (
    relativePath.startsWith("lib/") &&
    relativePath.endsWith(".dart") &&
    !relativePath.endsWith(".g.dart") &&
    !relativePath.endsWith(".freezed.dart")
  );
}

function firstKeepAliveLineWithoutMarker(source) {
  const lines = source.split(/\r?\n/u);
  for (let index = 0; index < lines.length; index += 1) {
    if (!/@Riverpod\s*\([^)]*\bkeepAlive\s*:\s*true/u.test(lines[index])) {
      if (!/\bkeepAlive\s*:\s*true/u.test(lines[index])) continue;
    }
    const hasMarker = [index - 1, index - 2, index - 3].some((candidate) => {
      return candidate >= 0 && /\/\/\s*keepalive:\s*\S/u.test(lines[candidate]);
    });
    if (!hasMarker) return index + 1;
  }
  return null;
}

function manualProviderDeclarationMatch(source) {
  return (
    /=\s*Provider(?:\.family)?(?:<|\()/u.exec(source) ??
    /\b(?:StateProvider|FutureProvider|StreamProvider)(?:\.family)?(?:<|\()/u.exec(
      source,
    )
  );
}

function classBlocks(source) {
  const blocks = [];
  for (const match of source.matchAll(/\bclass\s+(\w+)\b[^{]*\{/gu)) {
    const start = match.index ?? 0;
    const bodyStart = start + match[0].length;
    const end = matchingBraceOffset(source, bodyStart - 1);
    if (end == null) continue;
    blocks.push({
      name: match[1],
      start,
      body: source.slice(bodyStart, end),
    });
  }
  return blocks;
}

function matchingBraceOffset(source, openBraceOffset) {
  let depth = 0;
  for (let index = openBraceOffset; index < source.length; index += 1) {
    const char = source[index];
    if (char === "{") depth += 1;
    if (char === "}") {
      depth -= 1;
      if (depth === 0) return index;
    }
  }
  return null;
}

function isAllowedDomainImport(uri) {
  if (uri.startsWith("dart:")) return true;
  if (!uri.startsWith("package:")) return true;
  return allowedDomainPackages.has(packageNameFor(uri));
}

function packageNameFor(uri) {
  return /^package:([^/']+)/u.exec(uri)?.[1] ?? "";
}

function isPluginPackageImport(uri) {
  if (!uri.startsWith("package:")) return false;
  return pluginPackages.has(packageNameFor(uri));
}

function hasStreamTimeoutOverride({source, line}) {
  const lines = source.split(/\r?\n/u);
  return [line - 1, line - 2].some((index) => {
    if (index < 0) return false;
    return /\/\/\s*architecture:allow\s+stream-timeout\s+--\s+reason:\s*\S/u.test(
      lines[index],
    );
  });
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
    const detail = finding.import == null ? "" : `: ${finding.import}`;
    console.error(`  L${finding.line} ${finding.rule}${detail}`);
  }
}

function printHelp() {
  console.log(`Usage:
  node tool/architecture/check_dependency_direction.mjs
  node tool/architecture/check_dependency_direction.mjs --json
  node tool/architecture/check_dependency_direction.mjs --write-baseline

Scans lib/**/*.dart for dependency-direction violations:
- domain files importing packages outside the small domain allowlist;
- data/domain files importing feature presentation code;
- feature presentation files importing sibling feature presentation internals;
- feature-root barrel presentation exports missing // public-api: annotations;
- presentation helpers leaking WidgetRef below the route/controller boundary;
- presentation widgets reading repository providers directly;
- *_state.dart display adapters coupled to Riverpod/provider declarations;
- unregistered presentation state adapters;
- keepAlive providers without // keepalive: lifecycle rationale markers;
- handwritten provider declarations outside core;
- display-state classes hidden inside non-state files;
- presentation files that declare multiple route screens;
- domain files calling DateTime.now() internally;
- data files wrapping streams in timeout() without an override comment;
- presentation widgets importing plugin/platform packages outside controllers
  and services.

The baseline file ratchets existing debt. Normal runs fail only on findings not
listed in tool/architecture/dependency_direction_baseline.json, except hard-gate
rules such as barrelPresentationExport and untrackedStateAdapter.`);
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
